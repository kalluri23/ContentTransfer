//
//  CTFileList.m
//  contenttransfer
//
//  Created by Sun, Xin on 6/14/17.
//  Copyright © 2017 Verizon Wireless Inc. All rights reserved.
//

#import "CTFileList.h"
#import "CTFileManager.h"
#import "CTDeviceMarco.h"
#import "NSMutableDictionary+CTMVMConvenience.h"
#import "NSString+CTHelper.h"
#import "CTSTMService2.h"

@interface CTFileList()

/*! Selected item list dictionary object.*/
@property (nonatomic, strong) NSMutableDictionary *selectedItems;
/*! Complete file list dictionary object.*/
@property (nonatomic, strong) NSMutableDictionary *fileList;

/*! Total data size in file list.*/
@property (nonatomic, assign) long long           totalDataSize;

@end

@implementation CTFileList

#pragma mark - Lazy loading
- (NSMutableSet *)photoAlbumList {
    if (!_photoAlbumList) {
        _photoAlbumList = [[NSMutableSet alloc] init];
    }
    
    return _photoAlbumList;
}


#pragma mark - Initializer
- (instancetype)initFileList {
    self = [super init];
    if (self) {
        _selectedItems  = [[NSMutableDictionary alloc] init];
        _fileList       = [[NSMutableDictionary alloc] init];
        _totalDataSize  = 0;
        _totalFileCount = 0;
        
        [self setVideoPackageSizeBasedOnCurrentDevice];
    }
    
    return self;
}

- (instancetype)initFileListWithData:(NSData *)data {
    self = [super init];
    if (self) {
        NSError* error = nil;
        // Save complete file list
        _fileList = [[NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error] mutableCopy];
        if (error) {
            NSLog(@"File list create reading data error:%@", error.localizedDescription);
        }
        
        // Save selected item list
        _selectedItems = [[_fileList valueForKey:@"itemList"] mutableCopy];
        
        // Save video package size
        _videoPackageSize = [[_fileList valueForKey:@"videoPkgSize"] integerValue];
        
        // Save sender VID for iOS device
        if ([[CTUserDevice userDevice].phoneCombination isEqualToString:IOS_IOS]) {
            _senderVID = (NSString *)[_fileList valueForKey:@"senderVID"];
        }
        
        // Get device count for one-to-many
        NSString *deviceCount = [_fileList valueForKey:@"deviceCount"];
        if (deviceCount) {
            _deviceCount = [deviceCount integerValue];
        } else {
            _deviceCount = -1;
        }
        
        // Save other flags
        _hasCloudPhotos = [_fileList boolForKey:@"hasCloudPhotos"];
        _hasCloudVideos = [_fileList boolForKey:@"hasCloudVideos"];
        
        // Parse file list
        [self _storeFileList];
    }
    
    return self;
}

#pragma mark - Item Operations
- (void)initItem:(NSString *)itemType withCount:(NSInteger)countOfData withSize:(long long)size {
    NSMutableDictionary *eachItemData = [NSMutableDictionary new];
    [eachItemData setObject:@"false" forKey:@"status"];
    [eachItemData setObject:[NSNumber numberWithInteger:countOfData] forKey:@"totalCount"];
    [eachItemData setObject:[NSNumber numberWithLongLong:size] forKey:@"totalSize"];
    [_selectedItems setObject:eachItemData forKey:itemType];
}

- (void)selectItem:(NSString *)itemType {
    NSDictionary *metaDataDict = [_selectedItems objectForKey:itemType];
    [metaDataDict setValue:@"true" forKey:@"status"];
    [_selectedItems setObject:metaDataDict forKey:itemType];
}

- (void)deselectItem:(NSString*)itemType {
    NSDictionary *metaDataDict = [_selectedItems objectForKey:itemType];
    [metaDataDict setValue:@"false" forKey:@"status"];
    [_selectedItems setObject:metaDataDict forKey:itemType];
}

- (void)resetAllItemList {
    for (NSString *key in [_selectedItems allKeys]) {
        [self deselectItem:key];
    }
}

#pragma mark - File List Operations
- (void)creatCompleteFileList:(NSArray *)selectedRows {
    [self resetAllItemList];
    
    for (NSIndexPath *index in selectedRows) {
        switch (index.row) {
            case CTTransferItemsTableBreakDown_Contacts:
                [self selectItem:METADATA_ITEMLIST_KEY_CONTACTS];
                break;
                
            case CTTransferItemsTableBreakDown_Photos:{
                [self selectItem:METADATA_ITEMLIST_KEY_PHOTOS];
                NSArray *photoFileList = [self fetchFileListForItem:CTTransferItemsTableBreakDown_Photos];
                if (!photoFileList) { // If there is no file list, deselect photo type.
                    [self deselectItem:METADATA_ITEMLIST_KEY_PHOTOS];
                } else {
                    [self addFileListIntoCompleteFileList:photoFileList forType:METADATA_DICT_KEY_PHOTOS];
                }
            } break;
                
            case CTTransferItemsTableBreakDown_Videos: {
                [self selectItem:METADATA_ITEMLIST_KEY_VIDEOS];
                NSArray *videoFileList = [self fetchFileListForItem:CTTransferItemsTableBreakDown_Videos];
                if (!videoFileList) {
                    [self deselectItem:METADATA_ITEMLIST_KEY_VIDEOS];
                } else {
                    [self addFileListIntoCompleteFileList:videoFileList forType:METADATA_DICT_KEY_VIDEOS];
                }
            }
                break;
                
            case CTTransferItemsTableBreakDown_Calenders: {
                [self selectItem:METADATA_ITEMLIST_KEY_CALENDARS];
                NSArray *calFileList = [self fetchFileListForItem:CTTransferItemsTableBreakDown_Calenders];
                if (!calFileList) {
                    [self deselectItem:METADATA_ITEMLIST_KEY_CALENDARS];
                } else {
                    [self addFileListIntoCompleteFileList:calFileList forType:METADATA_DICT_KEY_CALENDAR];
                }
            }
                break;
            case CTTransferItemsTableBreakDown_RemindersOrAudios:
                if ([[CTUserDevice userDevice].phoneCombination isEqualToString:IOS_IOS]) { // Reminder
                    [self selectItem:METADATA_ITEMLIST_KEY_REMINDERS];
                } else { // Audio
                    [self selectItem:METADATA_ITEMLIST_KEY_AUDIOS];
                    NSArray *audioFileList = [self fetchFileListForItem:CTTransferItemsTableBreakDown_RemindersOrAudios];
                    if (!audioFileList) {
                        [self deselectItem:METADATA_ITEMLIST_KEY_AUDIOS];
                    } else {
                        [self addFileListIntoCompleteFileList:audioFileList forType:METADATA_DICT_KEY_AUDIOS];
                    }
                }
                break;
            default:
                break;
        }
    }
    [self.fileList setObject:_selectedItems forKey:@"itemList"];
    
    // Adding video package based on device
    [self.fileList setObjectIfValid:[NSString stringWithFormat:@"%ld", (long)self.videoPackageSize] forKey:@"videoPkgSize" defaultObject:@0];
    
    // Get Sender Side device vendor ID
    if ([[CTUserDevice userDevice].phoneCombination isEqualToString:IOS_IOS]) {
        NSString *deviceVID = [NSString deviceVID];
        [self.fileList setObject:deviceVID forKey:@"senderVID"];
    }
    
    // Add additonal information for icloud info
    [self.fileList setObject:[NSNumber numberWithBool:[[NSUserDefaults standardUserDefaults] boolForKey:@"VZTRANSFER_HAS_CLOUD_PHOTO"]] forKey:@"hasCloudPhotos"];
    [self.fileList setObject:[NSNumber numberWithBool:[[NSUserDefaults standardUserDefaults] boolForKey:@"VZTRANSFER_HAS_CLOUD_VIDEO"]]forKey:@"hasCloudVideos"];
    
    if ([[CTUserDevice userDevice].pairingType isEqualToString:kP2M]) {
        [self.fileList setObject:[NSString stringWithFormat:@"%ld", (long)[[CTSTMService2 sharedInstance] getNumOfConnectedDevice]] forKey:@"deviceCount"]; // column to specify how many devices connected. This column only exist in one-to-many transfer
    }
    
    // Calculate the data size related on current file list.
    [self calculateFileListTotalDataSize];
}

- (NSData *)createFileListData {
    
    NSMutableData *finaldata = [[NSMutableData alloc] init];
    @try {
        NSError *err = nil;
        NSData *fileListData = [NSJSONSerialization dataWithJSONObject:_fileList options:NSJSONWritingPrettyPrinted error:&err];
        
        // Prepare file list data package header
        NSString *requestStr = [[NSString alloc] initWithFormat:@"%@%010lu", CT_SEND_FILE_LIST_HEADER, (unsigned long)fileListData.length];
        NSData *requestData = [requestStr dataUsingEncoding:NSUTF8StringEncoding];
        
        // Merge the data
        [finaldata appendData:requestData];
        [finaldata appendData:fileListData];
        
    } @catch (NSException *exception) {
        DebugLog(@"File list data crecoooate failed:%@", exception.debugDescription);
    }
    
    return finaldata;
}

#pragma mark - Public APi For Parameters
- (NSDictionary *)listObject {
    return _fileList;
}

- (NSDictionary *)selectItemList {
    return _selectedItems;
}

- (long long)totalDataSize {
    return _totalDataSize;
}

- (NSDictionary *)getFileInformationForType:(NSString *)type andIndex:(NSUInteger)idx {
    if ([type isEqualToString:METADATA_ITEMLIST_KEY_PHOTOS]) { // photos
        return (NSDictionary *)[[_fileList objectForKey:METADATA_DICT_KEY_PHOTOS] objectAtIndex:idx];
    } else if ([type isEqualToString:METADATA_ITEMLIST_KEY_VIDEOS]) { // videos
        return (NSDictionary *)[[_fileList objectForKey:METADATA_DICT_KEY_VIDEOS] objectAtIndex:idx];
    } else if ([type isEqualToString:METADATA_ITEMLIST_KEY_CALENDARS]) { // calendars
        return (NSDictionary *)[[_fileList objectForKey:METADATA_DICT_KEY_CALENDAR] objectAtIndex:idx];
    } else if ([type isEqualToString:METADATA_ITEMLIST_KEY_AUDIOS]) { // audio
        return (NSDictionary *)[[_fileList objectForKey:METADATA_DICT_KEY_AUDIOS] objectAtIndex:idx];
    } else { // Contacts, reminders no file list saved. Should never be called
        NSLog(@"Someone called this method with contact and reminder key. Should not use this way!");
        return nil;
    }
}

#pragma mark - Private Operations
/*!
    @brief Fetch file list for specific items. File list saved in app local storange during the collection process.
    @param itemType Enum CTTransferItemsTableBreakDown type value to indicate the data type.
    @return NSArray object contains the file list. Return nil if no file list found or error happened during reading.
 */
- (NSArray *)fetchFileListForItem:(enum CTTransferItemsTableBreakDown)itemType {
    NSError  *jsonError = nil;
    NSString *filePath  = nil;
    switch (itemType) {
        case CTTransferItemsTableBreakDown_Photos: {
            filePath = DIRECTORY_PATH_PHOTOS;
        } break;
        
        case CTTransferItemsTableBreakDown_Videos: {
            filePath = DIRECTORY_PATH_VIDEOS;
        } break;
            
        case CTTransferItemsTableBreakDown_Calenders: {
            filePath = DIRECTORY_PATH_CALENDARS;
        } break;
            
        case CTTransferItemsTableBreakDown_RemindersOrAudios: {
            if ([[CTUserDevice userDevice].phoneCombination isEqualToString:IOS_Andriod]) { // It's audio
                filePath = DIRECTORY_PATH_AUDIOS;
            }
        } break;
        default:
            break;
    }
    
    if (!filePath) { // Invalid file path
        return nil;
    }
    
    NSData *fileListData = [CTFileManager dataFromFile:filePath];
    if (fileListData) {
        NSArray *fileList = [NSJSONSerialization JSONObjectWithData:fileListData options:0 error:&jsonError];
        if (!jsonError) {
            return fileList;
        } else {
            NSLog(@"File list error:%@", jsonError.localizedDescription);
        }
    }
    
    return nil;
}
/*!
    @brief Try to add file list for data type into complete file list. If no filelist given, empty array will be assigned as default.
    @param fileList NSArray represents the file list for specific data type.
    @param type NSString value to indicate the type of the data.
 */
- (void)addFileListIntoCompleteFileList:(NSArray *)fileList forType:(NSString *)type {
    [_fileList setObjectIfValid:fileList forKey:type defaultObject:@[]];
}
/*!
    @brief Setup package size for video sending in P2P based on current device model. Size will be saved to local parameter, and also send to the other side through metadata.
 */
- (void)setVideoPackageSizeBasedOnCurrentDevice {
    if ([CTDeviceMarco isiPhone4AndBelow]) {
        self.videoPackageSize = 50; // set for each of the package size for video receiving
    } else if ([CTDeviceMarco isiPhone5Serial]) {
        self.videoPackageSize = 100;
    } else {
        self.videoPackageSize = 150;
    }
}
/*! 
    @brief Calulate the total size of the data, also the total count for each type. Size will be stored in local param.
 */
- (void)calculateFileListTotalDataSize {
    // Reset the count
    self.totalFileCount = 0;
    self.totalDataSize  = 0;
    
    // Calulation
    [_selectedItems enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        NSDictionary *eachDataType = (NSDictionary*)obj;
        BOOL status = [[eachDataType objectForKey:@"status"] boolValue];
        if (status) {
            self.totalDataSize += [[eachDataType objectForKey:@"totalSize"] longLongValue];
            
            if ([key isEqualToString:METADATA_ITEMLIST_KEY_CONTACTS]) {
                _numberOfContacts = [[eachDataType objectForKey:@"totalCount"] integerValue];
                _totalFileCount += 1;
            } else if ([key isEqualToString:METADATA_ITEMLIST_KEY_PHOTOS]){
                _numberOfPhotos = [[eachDataType objectForKey:@"totalCount"]   integerValue];
                _totalFileCount += _numberOfPhotos;
            } else if ([key isEqualToString:METADATA_ITEMLIST_KEY_VIDEOS]){
                _numberOfVideos = [[eachDataType objectForKey:@"totalCount"]   integerValue];
                _totalFileCount += _numberOfVideos;
            } else if ([key isEqualToString:METADATA_ITEMLIST_KEY_REMINDERS]){
                _numberOfReminder = [[eachDataType objectForKey:@"totalCount"] integerValue];
                _totalFileCount += 1;
            } else if ([key isEqualToString:METADATA_ITEMLIST_KEY_CALENDARS]){
                _numberOfCalendar = [[eachDataType objectForKey:@"totalCount"] integerValue];
                _totalFileCount += _numberOfCalendar;
            } else if ([key isEqualToString:METADATA_ITEMLIST_KEY_AUDIOS]){
                _numberOfAudios = [[eachDataType objectForKey:@"totalCount"]   integerValue];
                _totalFileCount += _numberOfAudios;
            }
        }
    }];
}
/*!
    @brief Parse the file list data, and save in local parameter. It's file list manager's job to store them in UserDefault.
 */
- (void)_storeFileList {
    if ([[[_selectedItems valueForKey:@"contacts"] valueForKey:@"status"] isEqualToString:@"true"]) {
        _contactSelected = YES;
        _numberOfContacts = [[[_selectedItems valueForKey:@"contacts"] valueForKey:@"totalCount"] integerValue];
    }
    
    if ([[[_selectedItems valueForKey:@"photos"] valueForKey:@"status"] isEqualToString:@"true"]) {
        _photoSelected = YES;
        [self _createNewPhotoLogFile:[_fileList valueForKey:@"photoFileList"]];
        _numberOfPhotos = [[[_selectedItems valueForKey:@"photos"] valueForKey:@"totalCount"] integerValue];
    }
    
    if ([[[_selectedItems valueForKey:@"videos"] valueForKey:@"status"] isEqualToString:@"true"]) {
        _videoSelected = YES;
        [self _createNewVideoLogFile:[_fileList valueForKey:@"videoFileList"]];
        _numberOfVideos = [[[_selectedItems valueForKey:@"videos"] valueForKey:@"totalCount"] integerValue];
    }
    
    if ([[[_selectedItems valueForKey:@"calendar"] valueForKey:@"status"] isEqualToString:@"true"]) {
        _calendarSelected = YES;
        self.calendarFilelist = [_fileList valueForKey:@"calendarFileList"];
        _numberOfCalendar = [[[_selectedItems valueForKey:@"calendar"] valueForKey:@"totalCount"] integerValue];
    }
    
    if ([[[_selectedItems valueForKey:@"reminder"] valueForKey:@"status"] isEqualToString:@"true"]) {
        _reminderSelected = YES;
        _numberOfReminder = [[[_selectedItems valueForKey:@"reminder"] valueForKey:@"totalCount"] integerValue];
    }
    
    if ([[[_selectedItems valueForKey:@"apps"] valueForKey:@"status"] isEqualToString:@"true"]) {
        _appListSelected = YES;
        [self _createAppsLogFile:[_fileList valueForKey:@"appsFileList"]];
        _numberOfApps = [[[_selectedItems valueForKey:@"apps"] valueForKey:@"totalCount"] integerValue];
    }
}
/*!
    @brief Create photo log files. Adapted file list will be stored in local params. It's file manager's response to store them properly.
    @param photoFileListReceived photo file list that received from file list.
 */
- (void)_createNewPhotoLogFile:(NSArray *)photoFileListReceived {
    _photoFileLog = [photoFileListReceived mutableCopy];
    _photoFileDic = [[NSMutableDictionary alloc] init];
    
    NSUInteger idx = 0;
    for (NSDictionary *dict in photoFileListReceived) {
        @autoreleasepool {
            NSMutableDictionary *newdict = [dict mutableCopy];
            
            [newdict setValue:[[dict valueForKey:@"Path"] decodeStringTo64] forKey:@"Path"];
            [newdict setValue:@"NO" forKey:@"status"];
            [newdict setValue:@"NO" forKey:@"albumPath"];
            
            if ([dict valueForKey:@"AlbumName"]) { // AlbumName is exist
                [newdict setValue:[self _parseAlbumInformation:[dict valueForKey:@"AlbumName"]] forKey:@"albumName"];
                [newdict removeObjectForKey:@"AlbumName"];
            } else {
                [newdict setValue:@[] forKey:@"albumName"]; // set empty
            }
            // Replace the array
            [_photoFileLog replaceObjectAtIndex:idx withObject:newdict];
            
            // Setup dictionary
//            if ([[CTUserDevice userDevice].phoneCombination isEqualToString:IOS_Andriod]) {
                [_photoFileDic setObject:newdict forKey:[[newdict valueForKey:@"Path"] stringByReplacingOccurrencesOfString:@"/" withString:@"_"]];
//            } else {
//                [_photoFileDic setObject:newdict forKey:[[newdict valueForKey:@"Path"] lastPathComponent]];
//            }
            
            // Find universal album name
            for (NSString *albumName in [newdict valueForKey:@"albumName"]) {
                [self.photoAlbumList addObject:albumName];
            }
            
            idx += 1;
        }
    }
}
/*!
    @brief Create video log files. Adapted file list will be stored in local params. It's file manager's response to store them properly.
    @param videoFileListReceived photo file list that received from file list.
 */
- (void)_createNewVideoLogFile:(NSArray *)videoFileListReceived {
    _videoFileLog = [videoFileListReceived mutableCopy];
    _videoFileDic = [[NSMutableDictionary alloc] init];
    
    NSUInteger idx = 0;
    for (NSDictionary *dict in videoFileListReceived) {
        @autoreleasepool {
            NSString *encodedPath = [dict stringForKey:@"Path"];
            if (encodedPath.length == 0) {
                // No Path found in dict, dict is not valid, ignore.
                [_videoFileLog removeObject:dict];
                continue;
            }
            
            NSString *path = [encodedPath decodeStringTo64];
            NSString *type = [[path componentsSeparatedByString:@"."] lastObject]; // last component should be extension
            
            if (([[CTUserDevice userDevice].phoneCombination isEqualToString:IOS_Andriod] && type && ([[type lowercaseString] isEqualToString:@"m4v"] || [[type lowercaseString] isEqualToString:@"mp4"] || [[type lowercaseString] isEqualToString:@"mov"]))
                || [[CTUserDevice userDevice].phoneCombination isEqualToString:IOS_IOS]) {
                
                NSMutableDictionary *newdict = [dict mutableCopy];
                [newdict setValue:path forKey:@"Path"];
                [newdict setValue:@"NO" forKey:@"status"];
                [newdict setValue:@"NO" forKey:@"albumPath"];
                
                if ([dict valueForKey:@"AlbumName"]) { // AlbumName is exist
                    [newdict setValue:[self _parseAlbumInformation:[dict valueForKey:@"AlbumName"]] forKey:@"albumName"];
                    [newdict removeObjectForKey:@"AlbumName"];
                } else {
                    [newdict setValue:@[] forKey:@"albumName"]; // set empty
                }
                // Replace the array
                [_videoFileLog replaceObjectAtIndex:idx withObject:newdict];
                
                // Setup dictionary
                if ([[CTUserDevice userDevice].phoneCombination isEqualToString:IOS_Andriod]) {
                    [_videoFileDic setObject:newdict forKey:[[newdict valueForKey:@"Path"] stringByReplacingOccurrencesOfString:@"/" withString:@"_"]];
                } else {
                    [_videoFileDic setObject:newdict forKey:[[newdict valueForKey:@"Path"] lastPathComponent]];
                }
                
                // Find universal album name
                for (NSString *albumName in [newdict valueForKey:@"albumName"]) {
                    [self.photoAlbumList addObject:albumName];
                }
                
                idx += 1; // Add when success
            } else {
                NSLog(@"file removed from list due to unsupported file type.");
                [_videoFileLog removeObject:dict]; // failed, total count of array will be reduce to match the idx
            }
        }
    }
}
/*!
    @brief Parse album information from file list.
    @discussion All the albums are identified by name.
    @param encodedAlbums Array of albums names with encoded string.
    @return Array of decoded album name.
 */
- (NSArray *)_parseAlbumInformation:(NSArray *)encodedAlbums {
    NSMutableArray *encodedAlbumsMutable = [encodedAlbums mutableCopy]; // mutable copy
    
    NSUInteger idx = 0;
    for (NSString *album in encodedAlbums) { // itnerate on immutable array, and change same entry in mutable one.
        NSString *albumDecoded = [album decodeStringTo64];
        
        if ([[CTUserDevice userDevice].phoneCombination isEqualToString:IOS_Andriod]) { // If it's cross platform
            if (albumDecoded.length > 0 && [[albumDecoded lastPathComponent] rangeOfString:@"DCIM"].location == NSNotFound) {
                [encodedAlbumsMutable replaceObjectAtIndex:idx withObject:[albumDecoded lastPathComponent]];
            }
        } else { // iOS to iOS
            [encodedAlbumsMutable replaceObjectAtIndex:idx withObject:albumDecoded];
        }
        
        idx += 1;
    }
    
    return encodedAlbumsMutable;
}
/*!
    @brief create app list log file. File list will be store in local parameter.
    @param receivedAppList raw app list log file received from metadata.
 */
- (void)_createAppsLogFile:(NSArray *)receivedAppList {
    self.appFileList = [receivedAppList mutableCopy];
    for (int idx = 0; idx<self.appFileList.count; idx++) {
        NSMutableDictionary *tempInfo = [[self.appFileList objectAtIndex:idx] mutableCopy];
        NSString *decodedPath = [[tempInfo valueForKey:@"Path"] decodeStringTo64];
        [tempInfo setObject:decodedPath forKey:@"Path"];
        NSString *decodedName = [[tempInfo valueForKey:@"name"] decodeStringTo64];
        [tempInfo setObject:decodedName forKey:@"name"];
        [self.appFileList replaceObjectAtIndex:idx withObject:tempInfo];
    }
}

@end
