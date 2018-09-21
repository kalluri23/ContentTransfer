//
//  CTDataCollectionManager.m
//  contenttransfer
//
//  Created by Hadapad, Prakash on 12/6/16.
//  Copyright © 2016 Verizon Wireless Inc. All rights reserved.
//

#import "CTDataCollectionManager.h"
#import "CTContactsManager.h"
#import "CTPhotosManager.h"
#import "CTFileManager.h"
#import "CTEventStoreManager.h"

#if STANDALONE == 0
    #import "CTContentTransferSetting.h"
#endif

typedef enum enumMediaType: NSUInteger {
    PHOTO,
    VIDEO,
    CONTACTS,
    REMINDER,
    CALENDARS,
    AUDIOS
} enumMediaType;

@interface CTDataCollectionManager()<PhotoManagerDelegate>

@property(nonatomic,assign) BOOL fetchingStarted; // Indicate that fetching process is started;

@property(nonatomic,assign) NSInteger numberOfContacts;
@property(nonatomic,assign) NSInteger numberOfCalendars;
@property(nonatomic,assign) NSInteger numberOfReminders;
@property(nonatomic,assign) NSInteger numberOfPhotos;
@property(nonatomic,assign) NSInteger numberOfVideos;
@property(nonatomic,assign) NSInteger numberOfAudios;
@property(nonatomic,assign) NSInteger sizeOfContacts;
@property(nonatomic,assign) NSInteger sizeOfCalendars;
@property(nonatomic,assign) NSInteger sizeOfReminders;
@property(nonatomic,assign) long long sizeOfPhotos;
@property(nonatomic,assign) long long sizeOfVideos;
@property(nonatomic,assign) long long sizeOfAudios;
@property(nonatomic,assign) NSInteger numberOfStreamPhotosCount;
@property(nonatomic,assign) NSInteger numberOfUnavailableCountPhotosCount;
@property(nonatomic,assign) NSInteger numberOfStreamVideosCount;
@property(nonatomic,assign) NSInteger numberOfUnavailableCountVideosCount;

@property(nonatomic,strong) NSBlockOperation *opeartionCollectContacts;
@property(nonatomic,strong) NSBlockOperation *opeartionCollectCalendars;
@property(nonatomic,strong) NSBlockOperation *opeartionCollectReminders;
@property(nonatomic,strong) NSBlockOperation *opeartionCollectPhotos;
@property(nonatomic,strong) NSBlockOperation *opeartionCollectVideos;
@property(nonatomic,strong) NSBlockOperation *opeartionCollectAudios;

@end

@implementation CTDataCollectionManager

- (CTAudiosManager *)audioManager {
    if (!_audioManager) {
        _audioManager = [[CTAudiosManager alloc] initAudioManager];
    }
    
    return _audioManager;
}

#pragma mark - singleton object create methods

+ (CTDataCollectionManager *)sharedManager {
    static CTDataCollectionManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}

#pragma mark - get Media count and size
-(NSInteger)getNumberOfAudios {
    return self.numberOfAudios;
}

-(NSInteger)getNumberOfContacts {
    return self.numberOfContacts;
}

-(NSInteger)getNumberOfCalendars {
    return self.numberOfCalendars;
}

-(NSInteger)getNumberOfReminders {
    return self.numberOfReminders;
}

-(NSInteger)getNumbersOfPhotos {
    return self.numberOfPhotos;
}

-(NSInteger)getNumbersOfVideos {
    return self.numberOfVideos;
}

-(NSInteger)getNumberOfStreamPhotosCount{
    return self.numberOfStreamPhotosCount;
}

-(NSInteger)getNumberOfUnavailableCountPhotosCount{
    return self.numberOfUnavailableCountPhotosCount;
}

-(NSInteger)getNumberOfStreamVideosCount{
    return self.numberOfStreamVideosCount;
}

-(NSInteger)getNumberOfUnavailableCountVideosCount{
    return self.numberOfUnavailableCountVideosCount;
}

-(NSInteger)getSizeOfContacts {
    return self.sizeOfContacts;
}

-(NSInteger)getSizeOfCalendars{
    return self.sizeOfCalendars;
}

-(NSInteger)getSizeOfReminders{
    return self.sizeOfReminders;
}

-(long long)getSizeOfPhotos{
    return self.sizeOfPhotos;
}

-(long long)getSizeOfVideos{
    return self.sizeOfVideos;
}

-(long long)getSizeOfAudio {
    return self.sizeOfAudios;
}

-(void)initPhotoManagerToCollectData {
    self.photoManager = [[CTPhotosManager alloc] initPhotoManager];
    self.photoManager.delegate = self;
}


#pragma mark - Start Collecting all data
- (void)startCollectAllData {
    
    self.fetchingStarted = YES;
    
    [self setdefaultValueForAllMediaType];
    
    __weak typeof(self) weakSelf = self;
    
    self.isCollectingPhotoCompleted     = FALSE;
    self.isCollectingVideoCompleted     = FALSE;
    self.isCollectingContactsCompleted  = FALSE;
    self.isCollectingReminderCompleted  = FALSE;
    self.isCollectingCalendarsCompleted = FALSE;
    self.isCollectingAudiosCompleted    = FALSE;
    
    // Block operation for reading all contacts
    self.opeartionCollectContacts = [NSBlockOperation new];
    [self.opeartionCollectContacts addExecutionBlock:^{
        
        if ([CTContactsManager contactsAuthorizationStatus] == CTAuthorizationStatusAuthorized) {
            [CTContactsManager numberOfAddressBookContacts:^(NSInteger count, float length) {
                NSLog(@"->contact finish");
                weakSelf.numberOfContacts = count;
                weakSelf.sizeOfContacts = length;
                [weakSelf dataCollectionIsCompleted:CONTACTS];
                [weakSelf setItem:METADATA_ITEMLIST_KEY_CONTACTS withCount:count withSize:length];
            } failureBlock:^(NSError *err) {
                [weakSelf dataCollectionIsCompleted:CONTACTS];
            }];
        }else{
            [weakSelf dataCollectionIsCompleted:CONTACTS];
        }

    }];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // Because NSBlockOperation will block current thread, move start to background
        [self.opeartionCollectContacts start];
    });
    
    // Block operation for reading all calendars
    self.opeartionCollectCalendars = [NSBlockOperation new];
    [self.opeartionCollectCalendars addExecutionBlock:^{
        
        if ([CTEventStoreManager calendarAuthorizationStatus] == CTAuthorizationStatusAuthorized) {
         
            [CTEventStoreManager fetchCalendars:^(NSInteger countOfCalendars, float lengthOfData) {
                NSLog(@"->calendar finish");
                weakSelf.numberOfCalendars = countOfCalendars;
                weakSelf.sizeOfCalendars = lengthOfData;
                [weakSelf setItem:METADATA_ITEMLIST_KEY_CALENDARS withCount:countOfCalendars withSize:lengthOfData];
                [weakSelf dataCollectionIsCompleted:CALENDARS];
            } failureBlock:^(NSError *err) {
                [weakSelf dataCollectionIsCompleted:CALENDARS];
            } updateBlock:^(NSInteger countOfCalendars) {
                if ([weakSelf.delegate respondsToSelector:@selector(updatePhotoCountFromDataCollectionManager:)]) {
                    [weakSelf.delegate updateCalendarCountFromDataCollectionManager:countOfCalendars];
                }
            }];
        
        }else {
            [weakSelf dataCollectionIsCompleted:CALENDARS];
        }
    }];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // Because NSBlockOperation will block current thread, move start to background
        [self.opeartionCollectCalendars start];
    });
    
    // Block operation for reading all reminders
    if ([[CTUserDevice userDevice].phoneCombination isEqualToString:IOS_IOS]) { // reminder
        weakSelf.numberOfAudios = 0;
        weakSelf.sizeOfAudios = 0;
        [weakSelf dataCollectionIsCompleted:AUDIOS];
        DebugLog(@"Audios fetching is completed: iOS to iOS, no audio needed.");
        
        self.opeartionCollectReminders = [NSBlockOperation new];
        [self.opeartionCollectReminders addExecutionBlock:^{
            
            if ([CTEventStoreManager reminderAuthorizationStatus] == CTAuthorizationStatusAuthorized) {
                [CTEventStoreManager fetchReminders:^(NSInteger countOfReminders, float lengthOfData) {
                    NSLog(@"->reminder finish");
                    weakSelf.numberOfReminders = countOfReminders;
                    weakSelf.sizeOfReminders = lengthOfData;
                    [weakSelf setItem:METADATA_ITEMLIST_KEY_REMINDERS withCount:countOfReminders withSize:lengthOfData];
                    [weakSelf dataCollectionIsCompleted:REMINDER];
                } failureBlock:^(NSError *err) {
                    [weakSelf dataCollectionIsCompleted:REMINDER];
                }];
                
            } else {
                [weakSelf dataCollectionIsCompleted:REMINDER];
            }
            
        }];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            // Because NSBlockOperation will block current thread, move start to background
            [self.opeartionCollectReminders start];
        });
    } else { // audio
        [weakSelf dataCollectionIsCompleted:REMINDER];
        DebugLog(@"Reminder fetching is completed: iOS to Android, reminder is not needed.");
        
#if NO_LEGAL_ISSUE_WITH_MUSIC == 1
        // Block operation for reading audios
        self.opeartionCollectAudios = [[NSBlockOperation alloc] init];
        [self.opeartionCollectAudios addExecutionBlock:^{
            if (SYSTEM_VERSION_LESS_THAN(@"9.3")) {
                DebugLog(@"Audios fetching is completed: Verison too low.");
                weakSelf.sizeOfAudios = 0;
                weakSelf.numberOfAudios = 0;
                [weakSelf dataCollectionIsCompleted:AUDIOS];
                
                return;
            }
            
            if ([CTAudiosManager audioLibraryAuthorizationStatus] == CTAuthorizationStatusAuthorized) {
                // fetch audio here
                [weakSelf.audioManager fetchAudioListWithCompletionHandler:^(NSInteger audioCount, long long audioSize) {
                    NSLog(@"->Audio finish");
                    weakSelf.sizeOfAudios = audioSize;
                    weakSelf.numberOfAudios = audioCount;
                    [weakSelf setItem:METADATA_ITEMLIST_KEY_AUDIOS withCount:audioCount withSize:audioSize];
                    [weakSelf dataCollectionIsCompleted:AUDIOS];
                }];
            } else {
                weakSelf.numberOfAudios = 0;
                weakSelf.sizeOfAudios = 0;
                [weakSelf dataCollectionIsCompleted:AUDIOS];
                DebugLog(@"Audios fetching is completed: No permission allowed.");
            }
        }];
        [self.opeartionCollectAudios addObserver:self forKeyPath:@"isCancelled" options:NSKeyValueObservingOptionNew context:nil]; // KvO for operation cancel.
        dispatch_async(dispatch_get_main_queue(), ^{
            // Because NSBlockOperation will block current thread, move start to background
            [self.opeartionCollectAudios start];
        });
#else
        self.numberOfAudios = 0;
        self.sizeOfAudios = 0;
        [self dataCollectionIsCompleted:AUDIOS];
        DebugLog(@"Audios fetching is completed: Legal issue.");
#endif
    }
    
    // Block operation for reading photos
    self.opeartionCollectPhotos = [NSBlockOperation new];
    
    [self.opeartionCollectPhotos addExecutionBlock:^{
        if ([CTPhotosManager photoLibraryAuthorizationStatus] == CTAuthorizationStatusAuthorized) {
            [weakSelf.photoManager fetchPhotos:^(NSInteger photoCount, NSInteger streamCount, NSInteger unavailableCount, BOOL isAllPhotos) {
                NSLog(@"->photo finish");
                weakSelf.isAllPhotos = isAllPhotos;
                long long dataSize = [CTPhotosManager dataSizeFromFile:DIRECTORY_PATH_PHOTOS];
                weakSelf.sizeOfPhotos = dataSize;
                weakSelf.numberOfStreamPhotosCount = streamCount;
                weakSelf.numberOfUnavailableCountPhotosCount = unavailableCount;
                weakSelf.numberOfPhotos = photoCount;
                [weakSelf setItem:METADATA_ITEMLIST_KEY_PHOTOS withCount:photoCount withSize:(NSInteger)dataSize];
                [weakSelf dataCollectionIsCompleted:PHOTO];
            } onFailure:^(NSString *errorMsg) {
                [weakSelf dataCollectionIsCompleted:PHOTO];
            }];
            
            DebugLog(@"Photo fetching is completed");
        } else {
           
            weakSelf.numberOfPhotos = 0;
            [weakSelf dataCollectionIsCompleted:PHOTO];
            DebugLog(@"Photo fetching is completed");
        }
    }];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // Because NSBlockOperation will block current thread, move start to background
        [self.opeartionCollectPhotos start];
    });
    
    // Block operation for reading videos
    self.opeartionCollectVideos = [NSBlockOperation new];
    [self.opeartionCollectVideos addExecutionBlock:^{
       
        if ([CTPhotosManager photoLibraryAuthorizationStatus] == CTAuthorizationStatusAuthorized) {
    
            [weakSelf.photoManager fetchVideos:^(NSInteger videoCount, NSInteger streamCount, NSInteger unavailableCount, BOOL isAllPhotoVideo) {
                NSLog(@"->video finish");
                weakSelf.isAllPhotoVideo = isAllPhotoVideo;
                long long dataSize = [CTPhotosManager dataSizeFromFile:DIRECTORY_PATH_VIDEOS];
                weakSelf.sizeOfVideos = dataSize;
                weakSelf.numberOfStreamVideosCount = streamCount;
                weakSelf.numberOfUnavailableCountVideosCount = unavailableCount;
                weakSelf.numberOfVideos = videoCount;
                [weakSelf setItem:METADATA_ITEMLIST_KEY_VIDEOS withCount:videoCount withSize:(NSInteger)dataSize];
                [weakSelf dataCollectionIsCompleted:VIDEO];
                
            } onFailure:^(NSString *errorMsg) {
                [weakSelf dataCollectionIsCompleted:VIDEO];
            }];
        } else {
            
            weakSelf.numberOfVideos = 0;
            [weakSelf dataCollectionIsCompleted:VIDEO];
            DebugLog(@"Video fetching is completed");
        }
    }];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // Because NSBlockOperation will block current thread, move start to background
        [self.opeartionCollectVideos start];
    });
}


#pragma mark - Stop Collectng all data
- (void)stopCollectAllData {
    [self stopContactDataCollectionTask];
    [self stopCalendarDataCollectionTask];
    [self stopReminderDataCollectionTask];
    [self stopPhotoDataCollectionTask];
    [self stopVideoDataCollectionTask];
    [self stopAudioDataCollectionTask];
}

- (void)stopContactDataCollectionTask {
    [self.opeartionCollectContacts cancel];
}

- (void)stopCalendarDataCollectionTask {
    [self.opeartionCollectCalendars cancel];
}

- (void)stopReminderDataCollectionTask {
    [self.opeartionCollectReminders cancel];
}

- (void)stopPhotoDataCollectionTask {
    [self.opeartionCollectPhotos cancel];
}

- (void)stopVideoDataCollectionTask {
    [self.opeartionCollectVideos cancel];
}

- (void)stopAudioDataCollectionTask {
    [self.opeartionCollectAudios cancel];
}

#pragma mark - Check flag for operation cancel
-(BOOL)isContactFetchingOperationCancelled {
    return [self.opeartionCollectContacts isCancelled];
}

-(BOOL)isCalendarsFetchingOperationCancelled {
    return [self.opeartionCollectCalendars isCancelled];
}

-(BOOL)isRemindersFetchingOperationCancelled {
    return [self.opeartionCollectReminders isCancelled];
}

-(BOOL)isPhotosFetchingOperationCancelled {
    return [self.opeartionCollectPhotos isCancelled];
}

-(BOOL)isVideosFetchingOperationCancelled {
    return [self.opeartionCollectVideos isCancelled];
}

-(BOOL)isAudioFetchingOperationCancelled {
    return [self.opeartionCollectAudios isCancelled];
}

#pragma mark - update photo and vide fetch information

- (void)viewShouldUpdatePhotoCount:(NSInteger)count {
    if ([self.delegate respondsToSelector:@selector(updatePhotoCountFromDataCollectionManager:)]) {
         [self.delegate updatePhotoCountFromDataCollectionManager:count];
    }
    DebugLog("number of Photo fetched is :%ld",(long)count)
}

- (void)viewShouldUpdateVideoCount:(NSInteger)count {
    if ([self.delegate respondsToSelector:@selector(updateVideosCountFromDataCollectionManager:)]) {
        [self.delegate updateVideosCountFromDataCollectionManager:count];
    }
    DebugLog("number of Video fetched is :%ld",(long)count)
}

#pragma mark - Data collectionCompleted

- (void)dataCollectionIsCompleted:(enumMediaType)mediaType {
    
    switch (mediaType) {
        case PHOTO:
        {
            self.isCollectingPhotoCompleted = TRUE;
            if ([self.delegate respondsToSelector:@selector(photoFetchingIsCompleted)]) {
                [self.delegate photoFetchingIsCompleted];
            }
        }
            break;
        case VIDEO: {
            self.isCollectingVideoCompleted = TRUE;
            if ([self.delegate respondsToSelector:@selector(videoFetchingIsCompleted)]) {
                [self.delegate videoFetchingIsCompleted];
            }
        }
            break;
        case CONTACTS:{
            self.isCollectingContactsCompleted = TRUE;
            if ([self.delegate respondsToSelector:@selector(contactFetchingIsCompleted)]) {
                [self.delegate contactFetchingIsCompleted];
            }
        }
            
            break;
        case REMINDER:{
            self.isCollectingReminderCompleted = TRUE;
            if ([self.delegate respondsToSelector:@selector(remindersFetchingIsCompleted)]) {
                [self.delegate remindersFetchingIsCompleted];
            }
        }
            
            break;
        case CALENDARS:{
            self.isCollectingCalendarsCompleted = TRUE;
            if ([self.delegate respondsToSelector:@selector(calendarsFetchingIsCompleted)]) {
                [self.delegate calendarsFetchingIsCompleted];
            }
        }
            break;
        case AUDIOS:{
            self.isCollectingAudiosCompleted = TRUE;
            if ([self.delegate respondsToSelector:@selector(audioFetchingIsCompleted)]) {
                [self.delegate audioFetchingIsCompleted];
            }
        }
            break;
            
        default:
            NSAssert(mediaType, @"Invalid enum is passed and correct the same");
            break;
    }
    
    if (self.isCollectingContactsCompleted && self.isCollectingPhotoCompleted && self.isCollectingVideoCompleted && self.isCollectingReminderCompleted && self.isCollectingCalendarsCompleted && self.isCollectingAudiosCompleted) {
        self.fetchingStarted = NO;
    }
}

- (void)stopCollectDataForExit {
    if (_fetchingStarted) {
        // fetching started
        [self stopCollectAllData];
        _fetchingStarted = NO;
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"isCancelled"]) {
        BOOL isCancelled = (BOOL)object;
        if (isCancelled) {
            NSLog(@"audio operation cancelled.");
            [self.audioManager cancelCollectionProcess];
            [self.opeartionCollectAudios removeObserver:self forKeyPath:@"isCancelled"]; // Remove the observer
        }
    }
}

#pragma mark - set data count
-(void)setItem:(NSString*)itemType withCount:(NSInteger)countOfData withSize:(long long)size{
    
    NSMutableDictionary *eachItemData = [NSMutableDictionary new];
    [eachItemData setObject:@"false" forKey:@"status"];
    [eachItemData setObject:[NSNumber numberWithInteger:countOfData] forKey:@"totalCount"];
    [eachItemData setObject:[NSNumber numberWithLongLong:size] forKey:@"totalSize"];
    [self.selectedItems setObject:eachItemData forKey:itemType];
    
}

- (void)setdefaultValueForAllMediaType {
    
    self.numberOfContacts = 0;
    self.sizeOfContacts = 0;
    [self setItem:METADATA_ITEMLIST_KEY_CONTACTS withCount:0 withSize:0];
    
    self.numberOfPhotos = 0;
    self.sizeOfPhotos = 0;
    [self setItem:METADATA_DICT_KEY_PHOTOS withCount:0 withSize:0];
    
    self.numberOfVideos = 0;
    self.sizeOfVideos = 0;
    [self setItem:METADATA_ITEMLIST_KEY_VIDEOS withCount:0 withSize:0];
    
    self.numberOfCalendars = 0;
    self.sizeOfCalendars = 0;
    [self setItem:METADATA_ITEMLIST_KEY_CALENDARS withCount:0 withSize:0];
    
    self.numberOfReminders = 0;
    self.sizeOfReminders = 0;
    [self setItem:METADATA_ITEMLIST_KEY_REMINDERS withCount:0 withSize:0];
    
    self.numberOfAudios = 0;
    self.sizeOfAudios = 0;
    [self setItem:METADATA_ITEMLIST_KEY_AUDIOS withCount:0 withSize:0];

}

@end
