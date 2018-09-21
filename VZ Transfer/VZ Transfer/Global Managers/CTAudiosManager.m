//
//  CTAudiosManager.m
//  contenttransfer
//
//  Created by Sun, Xin on 5/26/17.
//  Copyright © 2017 Verizon Wireless Inc. All rights reserved.
//

#import "CTAudiosManager.h"
#import "NSString+CTMVMConvenience.h"
#import "NSString+CTRootDocument.h"
#import "CTDataCollectionManager.h"

@interface CTAudiosManager()
/*! Hash table to save all the audio files. Key is file name, value is related AVAsset object for transfer.*/
@property (atomic, strong) NSMutableDictionary *audioHash;
/*! Hash table to save all the audio metadata. Key is file name, value is related metadata array object for transfer.*/
@property (atomic, strong) NSMutableDictionary *audioMetaDataHash;
/*! Path to save the audio file list.*/
@property (nonatomic, strong) NSString *audioFileListPath;
/*! Bool type value represent keep file in local or not, default is Yes, change to NO after first file saved.*/
@property (atomic, assign) BOOL keepFile;
/*! Task list for all unfinished exporter.*/
@property (atomic, strong) NSMutableDictionary *taskList;
/*! Task list for all unfinished exporter when put in background.*/
@property (atomic, strong) NSMutableDictionary *backgroundTaskList;
/*! File name list mapping the song name using in their metadata.*/
@property (nonatomic, strong) NSMutableDictionary *fileNameMapping;
/*! Bool value represents there was a background mode running or not. Default value is NO, when app goes to background, change to YES.*/
@property (nonatomic, assign) BOOL backgroundMode;

@end

@implementation CTAudiosManager
@synthesize keepFile;
@synthesize taskList;
@synthesize backgroundTaskList;
@synthesize audioHash;
@synthesize audioMetaDataHash;


static const NSString *audioAlbumName = @"CT_Audio";

#pragma mark - PERMISSION RELATED
+ (CTAuthorizationStatus)audioLibraryAuthorizationStatus
{
    if(MPMediaLibrary.authorizationStatus == MPMediaLibraryAuthorizationStatusAuthorized) {
        return CTAuthorizationStatusAuthorized;
    } else if (MPMediaLibrary.authorizationStatus == MPMediaLibraryAuthorizationStatusNotDetermined) {
        return CTAuthorizationNotDetermined;
    } else {
        return CTAuthorizationStatusDenied;
    }
}

+ (void)requestAudioLibraryAuthorisation:(void(^)(CTAuthorizationStatus status))completionBlock
{
    [MPMediaLibrary requestAuthorization:^(MPMediaLibraryAuthorizationStatus mpStatus){
        
        if(completionBlock)
        {
            if(mpStatus == MPMediaLibraryAuthorizationStatusAuthorized)
            {
                completionBlock(CTAuthorizationStatusAuthorized);
            }
            else
            {
                completionBlock(CTAuthorizationStatusDenied);
            }
        }
    
    }];
}

#pragma mark - INITIALIZER
- (instancetype)initAudioManager {
    self = [super init];
    if (self) {
        self.audioFileListPath  = [[[NSString appRootDocumentDirectory] stringByAppendingPathComponent:@"VZAudioLogFile"] stringByAppendingPathExtension:@"txt"];
        [self resetMangerProperties];
        
        // Add observer for background mode
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    }
    
    return self;
}

- (void)applicationDidEnterBackground:(NSNotification *)notification {
    self.backgroundMode = YES;
}

- (void)applicationDidBecomeActive:(NSNotification *)notification {
    [self.backgroundTaskList removeAllObjects];
}

/*!
    @brief This method will reset the properties for fetching audio files to the idle status. Need to call it every time fetch the audio files.
 */
- (void)resetMangerProperties {
    self.totalAudioFilesSize = 0;
    self.backgroundMode = NO;
    self.keepFile = YES;
    // Audio file list
    if (self.audioFileList.count > 0) {
        self.audioFileList = nil; // release
    }
    
    if (!self.audioFileList) {
        self.audioFileList = [[NSMutableArray alloc] init];
    }
    // Audio file list hash
    if (self.audioHash.count > 0) {
        self.audioHash = nil; // release
    }
    
    if (!self.audioHash) {
        self.audioHash = [[NSMutableDictionary alloc] init];
    }
    // Metadata hash
    if (self.audioMetaDataHash.count > 0) {
        self.audioMetaDataHash = nil; // release
    }
    
    if (!self.audioMetaDataHash) {
        self.audioMetaDataHash = [[NSMutableDictionary alloc] init];
    }
    // Normal task list
    if (self.taskList.count > 0) {
        self.taskList = nil; // release
    }
    
    if (!self.taskList) {
        self.taskList = [[NSMutableDictionary alloc] init];
    }
    // Background task list
    if (self.backgroundTaskList.count > 0) {
        self.backgroundTaskList = nil; // release
    }
    
    if (!self.backgroundTaskList) {
        self.backgroundTaskList = [[NSMutableDictionary alloc] init];
    }
    // File name mapping
    if (self.fileNameMapping.count > 0) {
        self.fileNameMapping = nil;
    }
    
    if (!self.fileNameMapping) {
        self.fileNameMapping = [[NSMutableDictionary alloc] init];
    }
    // Reset the auto increment count.
    self.localAudioFileCount = self.cloudAudioFileCount = self.unavailableFileCount = self.duplicateFileCount = 0;
}

#pragma mark - AUDIO FETCH METHOD
- (void)fetchAudioListWithCompletionHandler:(void(^)(NSInteger audioCount, long long audioSize))completionBlock {
    
    [self resetMangerProperties];
    
#warning TODO: THERE ARE MULTIPLE TYPE OF AUDIO, SHOULD WE FETCH THEM ALL? RIGHT NOW ONLY FOR MUSIC FILES.
    MPMediaQuery *query = [MPMediaQuery songsQuery];
    self.totalAudioFileCount = [query items].count;
    NSLog(@"Audio items:%ld", (long)self.totalAudioFileCount);
    
    if (self.totalAudioFileCount == 0) { // No audio
        [self checkIfAudioFetchFinishedWithHandler:completionBlock];
        return;
    }
    
    for (MPMediaItem *audioItem in query.items) {
        
        if ([CTDataCollectionManager sharedManager].isAudioFetchingOperationCancelled) {
            break;
        }
        
        @autoreleasepool {
            if (!audioItem.isCloudItem) {
                NSURL *url = [audioItem valueForKey:MPMediaItemPropertyAssetURL]; // Only local saved item will have URL value
                if (url) {
                    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:url options:nil];

                    if (asset) {
                        // Get all metadata of audio file
                        NSArray *newMetaData = [self prepareForMetaData:audioItem];
                        // Get the size of audio file
                        [self exportFile:asset
                                withName:[self createFileNameForSong:audioItem]
                            withMetaData:newMetaData
                             forTransfer:NO
                              forRestart:NO
                              completion:^(bool result, NSString *name, AVURLAsset *audio, unsigned long long size) {
                                  
                                  if (result && size > 0) {
                                      NSString *fullName = [name stringByAppendingPathExtension:@"m4a"];
                                      @synchronized (self) {
                                          if (![self.audioHash objectForKey:fullName]) {
                                              [self.audioHash setObject:audio forKey:fullName];
                                              [self.audioMetaDataHash setObject:newMetaData forKey:fullName];
                                              self.totalAudioFilesSize += size;
                                              // Create audio information
                                              NSMutableDictionary *audioInfo = [[NSMutableDictionary alloc] initWithObjects:@[[fullName encodeStringTo64], [NSString stringWithFormat:@"%llu", size], @[/*[audioAlbumName encodeStringTo64]*/]] forKeys:@[@"Path", @"Size", @"AlbumName"]];
                                              [self.audioFileList addObject:audioInfo];
                                              
                                              self.localAudioFileCount += 1;
                                              [self checkIfAudioFetchFinishedWithHandler:completionBlock];
                                          } else {
                                              self.duplicateFileCount += 1;
                                              [self checkIfAudioFetchFinishedWithHandler:completionBlock];
                                          }
                                      }
                                  } else {
                                      NSLog(@"Audio fetch failed");
                                      self.unavailableFileCount += 1;
                                      [self checkIfAudioFetchFinishedWithHandler:completionBlock];
                                  }
                              }];
                    } else {
                        self.unavailableFileCount += 1;
                        NSLog(@"Asset is not exist.");
                        [self checkIfAudioFetchFinishedWithHandler:completionBlock];
                    }
                } else {
                    self.unavailableFileCount += 1;
                    NSLog(@"No URL for asset.");
                    [self checkIfAudioFetchFinishedWithHandler:completionBlock];
                }
            } else {
                self.cloudAudioFileCount += 1;
                NSLog(@"This is iCloud item, not saving in local device.");
                [self checkIfAudioFetchFinishedWithHandler:completionBlock];
            }
        }
    }
}

/*!
    @brief Check if audio fetch process complete.
    @dicussion This method will check if all the audio files checked once, and try to save the local file list.
    @param completionBlock block given from upper level method.
 */
- (void)checkIfAudioFetchFinishedWithHandler:(void(^)(NSInteger audioCount, long long audioSize))completionBlock {
    NSLog(@"Check audio file:%ld/%ld", (long)(self.localAudioFileCount + self.cloudAudioFileCount + self.unavailableFileCount + self.duplicateFileCount), (long)self.totalAudioFileCount);
    if (self.localAudioFileCount + self.cloudAudioFileCount + self.unavailableFileCount + self.duplicateFileCount == self.totalAudioFileCount) {
        // Check background mode
        if (self.backgroundMode && self.backgroundTaskList.count > 0) {
            self.backgroundMode = NO;
            NSLog(@"Should continue audio fetching.");
            [self restartBackgroundListExporter:completionBlock];
            
            return;
        }
        
        // Save file list
        if (self.audioFileList.count == 0) {
            completionBlock(0, 0);
        }
        
        if ([NSJSONSerialization isValidJSONObject:self.audioFileList]) {
            NSData *audioData = [NSJSONSerialization dataWithJSONObject:self.audioFileList options:NSJSONWritingPrettyPrinted error:nil];
            [[NSFileManager defaultManager] createFileAtPath:self.audioFileListPath contents:audioData attributes: nil];
            
            completionBlock(self.localAudioFileCount, self.totalAudioFilesSize);
        } else {
            NSLog(@"Json failed when write the audio files.");
            completionBlock(0, 0);
        }
    }
}

/*!
    @brief Create all possible metadata for audio file.
    @discussion This method will try to assign every metadata that apple m4a format supported. When send to Andorid side, non-supported item will not show up.
    @warning Still some of the information in metadata are not capturing properly, need to fix it in the future.
    @param audioItem MPMediaItem represent audio information.
    @return NSArray of AVMetadataItem.
 */
- (NSArray *)prepareForMetaData:(MPMediaItem *)audioItem {
    NSMutableArray *newMetaData = [[NSMutableArray alloc] init];
#warning TODO: ONLY SEND NECESSARY METADATA FOR NOW, NEED TO COMPLETE IN THE FUTURE IF IT'S NECESSARY.
    // Metadata for media item
    NSString *title             = [audioItem valueForProperty:MPMediaItemPropertyTitle];            // title
    NSString *albumTitle        = [audioItem valueForProperty:MPMediaItemPropertyAlbumTitle];       // album title
    NSString *artist            = [audioItem valueForProperty:MPMediaItemPropertyArtist];           // artist
    NSString *albumArtist       = [audioItem valueForProperty:MPMediaItemPropertyAlbumArtist];      // album artist
    NSString *genre             = [audioItem valueForProperty:MPMediaItemPropertyGenre];            // genre
    NSString *composer          = [audioItem valueForProperty:MPMediaItemPropertyComposer];         // composer
    NSNumber *trackNumber       = [audioItem valueForProperty:MPMediaItemPropertyAlbumTrackNumber]; // track number
    NSNumber *trackCount        = [audioItem valueForProperty:MPMediaItemPropertyAlbumTrackCount];  // track count
    NSNumber *diskNumber        = [audioItem valueForProperty:MPMediaItemPropertyDiscNumber];       // disk number
    NSNumber *diskCount         = [audioItem valueForProperty:MPMediaItemPropertyDiscCount];        // disk count
//    NSNumber *isExplicit        = [audioItem valueForProperty:MPMediaItemPropertyIsExplicit];       // is explicit
    NSString *lyrics            = [audioItem valueForProperty:MPMediaItemPropertyLyrics];           // lyrics
//    NSNumber *isCompilation     = [audioItem valueForProperty:MPMediaItemPropertyIsCompilation];    // is compilation
//      NSDate *releaseDate       = [audioItem valueForProperty:MPMediaItemPropertyReleaseDate];      // release date
//    NSNumber *bpm               = [audioItem valueForProperty:MPMediaItemPropertyBeatsPerMinute];   // bpm
    NSString *comments          = [audioItem valueForProperty:MPMediaItemPropertyComments];         // comments
//    NSNumber *playCount         = [audioItem valueForProperty:MPMediaItemPropertyPlayCount];        // play count
//    NSNumber *skipCount         = [audioItem valueForProperty:MPMediaItemPropertySkipCount];        // skip count
//    NSNumber *rating            = [audioItem valueForProperty:MPMediaItemPropertyRating];           // rating
//      NSDate *lastPlayedDate    = [audioItem valueForProperty:MPMediaItemPropertyLastPlayedDate];   // last play date
//    NSString *userGrouping      = [audioItem valueForProperty:MPMediaItemPropertyUserGrouping];     // user grouping
//    NSNumber *bookmarkTime      = [audioItem valueForProperty:MPMediaItemPropertyBookmarkTime];     // bookmark time
//      NSDate *propertyDateAdded = [audioItem valueForProperty:MPMediaItemPropertyDateAdded];        // date added
    MPMediaItemArtwork *artwork = [audioItem valueForProperty:MPMediaItemPropertyArtwork];          // artwork
    // Covert artwork to UIImage, size is irrelavent.
    UIImage *artworkImage = [artwork imageWithSize:CGSizeMake(250.00, 250.00)];
    
    // Setup new metadata
    // Song name
    if (title.length > 0) {
        AVMutableMetadataItem *titleMetadata = [[AVMutableMetadataItem alloc] init];
        titleMetadata.key = AVMetadataiTunesMetadataKeySongName;
        titleMetadata.keySpace = AVMetadataKeySpaceiTunes;
//        titleMetadata.locale = [NSLocale currentLocale];
        titleMetadata.value = title;
        
        [newMetaData addObject:titleMetadata];
    }
    // Set album
    if (albumTitle.length > 0) {
        AVMutableMetadataItem *albumMetadata = [[AVMutableMetadataItem alloc] init];
        albumMetadata.key = AVMetadataiTunesMetadataKeyAlbum;
        albumMetadata.keySpace = AVMetadataKeySpaceiTunes;
//        albumMetadata.locale = [NSLocale currentLocale];
        albumMetadata.value = albumTitle;
        
        [newMetaData addObject:albumMetadata];
    }
    // Artist
    if (artist.length > 0) {
        AVMutableMetadataItem *artistMetadata = [[AVMutableMetadataItem alloc] init];
        artistMetadata.key = AVMetadataiTunesMetadataKeyArtist;
        artistMetadata.keySpace = AVMetadataKeySpaceiTunes;
//        artistMetadata.locale = [NSLocale currentLocale];
        artistMetadata.value = artist;
        
        [newMetaData addObject:artistMetadata];
    }
    // Album artist album
    if (albumArtist.length > 0) {
        AVMutableMetadataItem *albumArtistMetadata = [[AVMutableMetadataItem alloc] init];
        albumArtistMetadata.key = AVMetadataiTunesMetadataKeyAlbumArtist;
        albumArtistMetadata.keySpace = AVMetadataKeySpaceiTunes;
//        albumArtistMetadata.locale = [NSLocale currentLocale];
        albumArtistMetadata.value = albumArtist;
        
        [newMetaData addObject:albumArtistMetadata];
    }
    // Genre
    if (genre.length > 0) {
        AVMutableMetadataItem *genreMetadata = [[AVMutableMetadataItem alloc] init];
        genreMetadata.key = AVMetadataiTunesMetadataKeyUserGenre;
        genreMetadata.keySpace = AVMetadataKeySpaceiTunes;
//        genreMetadata.locale = [NSLocale currentLocale];
        genreMetadata.value = genre;
        
        [newMetaData addObject:genreMetadata];
    }
    // Composor
    if (composer.length > 0) {
        AVMutableMetadataItem *composorMetadata = [[AVMutableMetadataItem alloc] init];
        composorMetadata.key = AVMetadataiTunesMetadataKeyComposer;
        composorMetadata.keySpace = AVMetadataKeySpaceiTunes;
//        composorMetadata.locale = [NSLocale currentLocale];
        composorMetadata.value = composer;
        
        [newMetaData addObject:composorMetadata];
    }
    // Track number
    AVMutableMetadataItem *trackNumberMetadata = [[AVMutableMetadataItem alloc] init];
    trackNumberMetadata.key = AVMetadataiTunesMetadataKeyTrackNumber;
    trackNumberMetadata.keySpace = AVMetadataKeySpaceiTunes;
    trackNumberMetadata.locale = [NSLocale currentLocale];
    int16_t trackNumberData[4] = { 0, htons([trackNumber intValue]), htons([trackCount intValue]), 0 };
    trackNumberMetadata.value = [NSData dataWithBytes:trackNumberData length:sizeof(trackNumberData)];
    [newMetaData addObject:trackNumberMetadata];
    // Disc number
    AVMutableMetadataItem *diskNumberMetadata = [[AVMutableMetadataItem alloc] init];
    diskNumberMetadata.key = AVMetadataiTunesMetadataKeyDiscNumber;
    diskNumberMetadata.keySpace = AVMetadataKeySpaceiTunes;
    diskNumberMetadata.locale = [NSLocale currentLocale];
    int16_t discNumberData[4] = { 0, htons([diskNumber intValue]), htons([diskCount intValue]), 0 };
    diskNumberMetadata.value = [NSData dataWithBytes:discNumberData length:sizeof(discNumberData)];
    [newMetaData addObject:diskNumberMetadata];
    // Lyrics
    if (lyrics.length > 0) {
        AVMutableMetadataItem *lyricsMetadata = [[AVMutableMetadataItem alloc] init];
        lyricsMetadata.key = AVMetadataiTunesMetadataKeyLyrics;
        lyricsMetadata.keySpace = AVMetadataKeySpaceiTunes;
        lyricsMetadata.locale = [NSLocale currentLocale];
        lyricsMetadata.value = lyrics;
        
        [newMetaData addObject:lyricsMetadata];
    }
    // comments
    if (comments.length > 0) {
        AVMutableMetadataItem *commentsMetaData = [[AVMutableMetadataItem alloc] init];
        commentsMetaData.key = AVMetadataiTunesMetadataKeyUserComment;
        commentsMetaData.keySpace = AVMetadataKeySpaceiTunes;
        commentsMetaData.locale = [NSLocale currentLocale];
        commentsMetaData.value = comments;
        
        [newMetaData addObject:commentsMetaData];
    }
    // Set artwork
    if (artworkImage) {
        AVMutableMetadataItem *imageMetadata = [[AVMutableMetadataItem alloc] init];
        imageMetadata.key = AVMetadataiTunesMetadataKeyCoverArt;
        imageMetadata.keySpace = AVMetadataKeySpaceiTunes;
        imageMetadata.locale = [NSLocale currentLocale];
        imageMetadata.value = [NSData dataWithData:UIImagePNGRepresentation(artworkImage)]; //imageData is NSData of UIImage.
        
        [newMetaData addObject:imageMetadata];
    }
    
    return newMetaData;
}

/*!
    @brief Export the audio asset file and save in device app document.
    @discussion This method will covert the itunes audio file into m4a format. And save them in VZTransferAudio folder under app root directory.
    @warning This exporter will work asynchronously, so this method will return based on block. Upper level need to handle based on return value.
    @param asset AVURLAsset object represent audio file in iPod library.
    @param audioName audio name(title).
    @param metadata metadata need to be assigned to new file. This is an array of AVMetadataItems.
    @param forTransfer Bool type represent this exporter is running for transfer or collection.
    @param isRestart Bool type represent this exporter is restarted from background or not.
    @param completion return block.
 */
- (void)exportFile:(AVURLAsset *)asset withName:(NSString *)audioName withMetaData:(NSArray *)metadata forTransfer:(BOOL)forTransfer forRestart:(BOOL)isRestart completion:(void(^)(bool, NSString *, AVURLAsset *, unsigned long long))completion {
    NSString *identicalFileName = audioName;
    if (!forTransfer && !isRestart) { // Check the file name first only if this is for collection and it's not restart process
        identicalFileName = [self revisedFileName:audioName];
    }
    
    AVAssetExportSession *exporter = [[AVAssetExportSession alloc] initWithAsset:asset presetName: AVAssetExportPresetAppleM4A];
    exporter.outputFileType = AVFileTypeAppleM4A;
    // Check file existance
    NSString *path = [[[NSString appRootDocumentDirectory] stringByAppendingPathComponent:@"VZTransferAudio"] stringByAppendingPathComponent:[identicalFileName stringByAppendingPathExtension:@"m4a"]];
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
    }
    exporter.outputURL = [NSURL fileURLWithPath:path];
    exporter.metadata = metadata;
    
    // Export the audio file asynchronously
    if (exporter != nil && identicalFileName != nil) {
        @synchronized (self) {
            [self.taskList setObject:exporter forKey:identicalFileName]; // add in task list
        }
    } else {
        NSLog(@"AV export failed with error: no exporter or file name found.");
        completion(NO, identicalFileName, (AVURLAsset *)exporter.asset, 0);
    }
    
    [exporter exportAsynchronouslyWithCompletionHandler:^{ // start exporting
        
        @synchronized (self) { // When finish, remove from task list
            if ([self.taskList objectForKey:identicalFileName]) {
                [self.taskList removeObjectForKey:identicalFileName];
            }
        }
        
        if (exporter.status == AVAssetExportSessionStatusCompleted) {
            NSLog(@"AV export succeeded.");
            
            NSError *attributesError = nil;
            NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:exporter.outputURL.path error:&attributesError];
            unsigned long long fileSize = 0;
            if (!attributesError) {
                fileSize = [fileAttributes fileSize];
                NSLog(@"file size:%lld", fileSize);
            } else {
                NSLog(@"reading file error: %@", attributesError.localizedDescription);
            }
            
            if (keepFile || forTransfer) { // Should keep the first file or if fetch file during transfer
                NSLog(@"keep the file");
                @synchronized (self) {
                    keepFile = NO;
                }
            } else {
                [[NSFileManager defaultManager] removeItemAtPath:exporter.outputURL.path error:nil];
            }
            
            completion(YES, identicalFileName, (AVURLAsset *)exporter.asset, fileSize);
            
        } else if (exporter.status == AVAssetExportSessionStatusCancelled) {
            NSLog(@"AV export cancelled.");
            completion(NO, identicalFileName, (AVURLAsset *)exporter.asset, 0);
        } else {
            NSLog(@"AV export failed with error: %@ (%ld)", exporter.error.localizedDescription, (long)exporter.error.code);
            if (self.backgroundMode && exporter!= nil && identicalFileName != nil) {
                @synchronized(self) {
                    [self.backgroundTaskList setObject:exporter forKey:identicalFileName]; // add exporter for background list;
                }
            }
            completion(NO, identicalFileName, (AVURLAsset *)exporter.asset, 0);
        }
    }];
}

/*!
    @brief Restart the unfinished exporter after app went to background.
    @discussion When app goes to background (like user try to connect to hotspot, and switch to setting app), existing exporter will failed. Store those exporter in the list and try to retry after app comes back to active mode.
 
    @warning Each exporter object can only be executed once, once it returns the result, no matter success or failure, it needs to be initialize as a new exporter with exactly same properties to restart a new export session.
    @param completionBlock the block will called when export process done, and return the total avaiable audio file count and total file size.
    @see - (void)exportFile:(AVURLAsset *)asset withName:(NSString *)audioName withMetaData:(NSArray *)metadata completion:(void(^)(bool, NSString *, AVURLAsset *, unsigned long long))completion.
 */
- (void)restartBackgroundListExporter:(void(^)(NSInteger audioCount, long long audioSize))completionBlock {
    self.unavailableFileCount -= self.backgroundTaskList.count;
    NSLog(@"task list: %@", self.backgroundTaskList);
    
    NSArray *allKeys = [self.backgroundTaskList allKeys];
    for (NSString *audioName in allKeys) {
        AVAssetExportSession *oldExporter = (AVAssetExportSession *)[self.backgroundTaskList objectForKey:audioName];
        
        [self exportFile:(AVURLAsset *)oldExporter.asset
                withName:audioName
            withMetaData:oldExporter.metadata
             forTransfer:NO
              forRestart:YES
              completion:^(bool result, NSString *name, AVURLAsset *audio, unsigned long long size) {
                  
                  if (result && size > 0) {
                      NSString *fullName = [name stringByAppendingPathExtension:@"m4a"];
                      @synchronized (self) {
                          if (![self.audioHash objectForKey:fullName]) {
                              [self.audioHash setObject:audio forKey:fullName];
                              [self.audioMetaDataHash setObject:oldExporter.metadata forKey:fullName];
                              self.totalAudioFilesSize += size;
                              // Create audio information
                              NSMutableDictionary *audioInfo = [[NSMutableDictionary alloc] initWithObjects:@[[fullName encodeStringTo64], [NSString stringWithFormat:@"%llu", size], @[/*[audioAlbumName encodeStringTo64]*/]] forKeys:@[@"Path", @"Size", @"AlbumName"]];
                              [self.audioFileList addObject:audioInfo];
                              
                              self.localAudioFileCount += 1;
                              [self checkIfAudioFetchFinishedWithHandler:completionBlock];
                          } else {
                              self.duplicateFileCount += 1;
                              [self checkIfAudioFetchFinishedWithHandler:completionBlock];
                          }
                      }
                  } else {
                      self.unavailableFileCount += 1;
                      [self checkIfAudioFetchFinishedWithHandler:completionBlock];
                  }
              }];
    }
}

- (void)cancelCollectionProcess {
    for (AVAssetExportSession *exporter in [self.taskList allValues]) {
        [exporter cancelExport]; // Cancel all the unfinish task.
    }
}

/*!
    @brief Try to get the revised name from original name.
    @discussion Sometimes user may have music file with same title, file name will try to identify these kind of files.
 
                Basically, this method will maintain the mapping for the duplicate count and original file name. All the files with duplicate name will be renamed based on pattern "original name(duplicate number).format".
    @param originalName The original file name. For audio is song name recored in their metadata.
    @return Revised file name identify the duplicate song name file. Or there is no dulicate song name, then return original file name.
*/
- (NSString *)revisedFileName:(NSString *)originalName {
    NSString *currentCount = (NSString *)[self.fileNameMapping objectForKey:originalName];
    if (!currentCount) { // Didn't use this name yet.
        [self.fileNameMapping setObject:@"0" forKey:originalName]; // Record the current name using for this original name.
        
        return originalName;
    } else { // Already use name for this original name.
        NSInteger duplicateNum = [currentCount integerValue]; // Get current count of duplicate names
        NSString *revisedName = [NSString stringWithFormat:@"%@(%ld)", originalName, (long)(++duplicateNum)];
        // Store updated number
        [self.fileNameMapping setObject:[NSString stringWithFormat:@"%ld", (long)duplicateNum] forKey:originalName];
        
        return revisedName;
    }
}

/*!
    @brief This method will create the file name for specific audio file.
    @discussion To avoid some music from different artist has same song name, the file name of a music will be the combination of song name and artist name.
 
                So only one song with same name and same artist name will be considered as duplicate file, and run duplicate file name logic.
    @param mediaItem MPMediaItem represent current audio file.
    @return NSString represent the file name of audio file.
 */
- (NSString *)createFileNameForSong:(MPMediaItem *)mediaItem {
    NSString *songName   = mediaItem.title;
    NSString *artistName = mediaItem.artist;
    return [NSString stringWithFormat:@"%@-%@", songName, artistName];
}

#pragma mark - AUDIO REQUEST METHODS
- (void)audioFile:(NSString *)audioName getDataWithCompletionHandler:(void(^)(NSString * localPath, BOOL success))completionHandler {
    
    // Check if file already exist in local, directly read and send.
    NSString *fullPath = [[[NSString appRootDocumentDirectory] stringByAppendingPathComponent:@"VZTransferAudio"] stringByAppendingPathComponent:audioName];
    // Check existences
    if ([[NSFileManager defaultManager] fileExistsAtPath:fullPath]) {
        completionHandler(fullPath, YES); // directly read audio file.
        return;
    }
    
    
    // Try to fetch the file.
    AVURLAsset *asset = (AVURLAsset *)[self.audioHash objectForKey:audioName];
    NSArray* metaData = (NSArray *)[self.audioMetaDataHash objectForKey:audioName];
    
    if (!asset) {
        NSLog(@"Audio sending error: No asset found!");
        completionHandler(nil, NO);
        return;
    }
    
    if (!metaData) {
        NSLog(@"Audio sending error: No metaData found!");
        completionHandler(nil, NO);
        return;
    }
#warning TODO: EXPORTER WILL TAKE A LONE TIME, DO WE NEED TO OPTIMIZE IT?
    [self exportFile:asset
            withName:[audioName stringByDeletingPathExtension]
        withMetaData:metaData
         forTransfer:YES
          forRestart:NO
          completion:^(bool result, NSString *name, AVURLAsset *audioAsset, unsigned long long size) {
              
              if (result) { // success
                  completionHandler(fullPath, YES);
              } else {
                  completionHandler(nil, NO);
              }
          }];
}

@end
