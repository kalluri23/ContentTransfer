//
//  VZUserDefaults.m
//  contenttransfer
//
//  Created by Mehta, Snehal Natwar on 7/15/16.
//  Copyright © 2016 Hadapad, Prakash. All rights reserved.
//

#import "CTUserDefaults.h"

@interface CTUserDefaults ()

@property (nonatomic, strong, readwrite) NSUserDefaults *userDefaults;

@end

@implementation CTUserDefaults

+ (instancetype)sharedInstance {

    static CTUserDefaults *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[CTUserDefaults alloc] init];
    });

    return sharedInstance;
}

- (instancetype)init {
    self = [super init];

    if (self) {
        self.userDefaults = [NSUserDefaults standardUserDefaults];
    }

    return self;
}

// USER_DEFAULTS_PHOTODUPLICATELIST
- (void)setPhotoDuplicateList:(NSMutableArray *)photoDuplicateList {
    [self.userDefaults setObject:photoDuplicateList forKey:USER_DEFAULTS_PHOTODUPLICATELIST];
}

- (NSMutableArray *)photoDuplicateList {
    return [[self.userDefaults objectForKey:USER_DEFAULTS_PHOTODUPLICATELIST] mutableCopy];
}

// USER_DEFAULTS_VIDEODUPLICATELIST
- (void)setVideoDuplicateList:(NSMutableArray *)videoDuplicateList {
    [self.userDefaults setObject:videoDuplicateList forKey:USER_DEFAULTS_VIDEODUPLICATELIST];
}

- (NSMutableArray *)videoDuplicateList {
    return [[self.userDefaults objectForKey:USER_DEFAULTS_VIDEODUPLICATELIST] mutableCopy];
}

// USER_DEFAULTS_VCARDDUPLICATELIST
- (void)setVCardDuplicateList:(BOOL)vCardDuplicateList {
    [self.userDefaults setBool:vCardDuplicateList forKey:USER_DEFAULTS_VCARDDUPLICATELIST];
}

- (BOOL)isVCardDuplicateList {
    return [self.userDefaults boolForKey:USER_DEFAULTS_VCARDDUPLICATELIST];
}

// USER_DEFAULTS_CALENDARDUPLICATELIST
- (void)setCalenderDuplicateList:(BOOL)calenderDuplicateList {
    [self.userDefaults setBool:calenderDuplicateList forKey:USER_DEFAULTS_CALENDARDUPLICATELIST];
}

- (BOOL)isCalenderDuplicateList {
    return [self.userDefaults boolForKey:USER_DEFAULTS_CALENDARDUPLICATELIST];
}

// USER_DEFAULTS_TOTALFILESRECEIVED
- (void)setTotalFilesReceived:(NSString *)totalFilesReceived {
    [self.userDefaults setObject:totalFilesReceived forKey:USER_DEFAULTS_TOTALFILESRECEIVED];
}

- (NSString *)totalFilesReceived {
    return [self.userDefaults objectForKey:USER_DEFAULTS_TOTALFILESRECEIVED];
}

// USER_DEFAULTS_photoFilteredFileList
- (void)setPhotoFilteredFileList:(NSMutableArray *)photoFilteredFileList {
    [self.userDefaults setObject:photoFilteredFileList forKey:USER_DEFAULTS_photoFilteredFileList];
}

- (NSMutableArray *)photoFilteredFileList {
    return [[self.userDefaults objectForKey:USER_DEFAULTS_photoFilteredFileList] mutableCopy];
}

// USER_DEFAULTS_videoFilteredFileList
- (void)setVideoFilteredFileList:(NSMutableArray *)videoFilteredFileList {
    [self.userDefaults setObject:videoFilteredFileList forKey:USER_DEFAULTS_videoFilteredFileList];
}

- (NSMutableArray *)videoFilteredFileList {
    return [[self.userDefaults objectForKey:USER_DEFAULTS_videoFilteredFileList] mutableCopy];
}

// USER_DEFAULTS_itemList
- (void)setItemList:(NSMutableDictionary *)itemList {
    [self.userDefaults setObject:itemList forKey:USER_DEFAULTS_itemList];
}

- (NSMutableDictionary *)itemList {
    return [[self.userDefaults objectForKey:USER_DEFAULTS_itemList] mutableCopy];
}

// USER_DEFAULTS_TOTALFILETRANSFERED
- (void)setTotalFilesTransferred:(NSString *)totalFilesTransferred {
    [self.userDefaults setObject:totalFilesTransferred forKey:USER_DEFAULTS_TOTALFILETRANSFERED];
}

- (NSString *)totalFilesTransferred {
    return [self.userDefaults objectForKey:USER_DEFAULTS_TOTALFILETRANSFERED];
}

// USER_DEFAULTS_REMINDERDUPLICATELIST
- (void)setReminderDuplicateList:(BOOL)reminderDuplicateList {
    [self.userDefaults setBool:reminderDuplicateList forKey:USER_DEFAULTS_REMINDERDUPLICATELIST];
}

- (BOOL)isReminderDuplicateList {
    return [self.userDefaults boolForKey:USER_DEFAULTS_REMINDERDUPLICATELIST];
}

// USER_DEFAULTS_VIDEOALBUMLIST
- (void)setVideoAlbumList:(NSMutableArray *)videoAlbumList {
    [self.userDefaults setObject:videoAlbumList forKey:USER_DEFAULTS_VIDEOALBUMLIST];
}

- (NSMutableArray *)videoAlbumList {
    return [[self.userDefaults objectForKey:USER_DEFAULTS_VIDEOALBUMLIST] mutableCopy];
}

// USER_DEFAULTS_PHOTOALBUMLIST
- (void)setPhotoAlbumList:(NSMutableArray *)photoAlbumList {
    [self.userDefaults setObject:photoAlbumList forKey:USER_DEFAULTS_PHOTOALBUMLIST];
}

- (NSMutableArray *)photoAlbumList {
    return [[self.userDefaults objectForKey:USER_DEFAULTS_PHOTOALBUMLIST] mutableCopy];
}

// USER_DEFAULTS_STARTTIME
- (void)setStartTime:(NSDate *)startTime {
    [self.userDefaults setObject:startTime forKey:USER_DEFAULTS_STARTTIME];
}

- (NSDate *)startTime {
    return [self.userDefaults objectForKey:USER_DEFAULTS_STARTTIME];
}

// USER_DEFAULTS_ENDTIME
- (void)setEndTime:(NSDate *)endTime {
    [self.userDefaults setObject:endTime forKey:USER_DEFAULTS_ENDTIME];
}

- (NSDate *)endTime {
    return [self.userDefaults objectForKey:USER_DEFAULTS_ENDTIME];
}

// USER_DEFAULTS_TOTALDOWNLOADEDDATA
- (void)setTotalDownloadedData:(NSString *)totalDownloadedData {
    [self.userDefaults setObject:totalDownloadedData forKey:USER_DEFAULTS_TOTALDOWNLOADEDDATA];
}

- (NSString *)totalDownloadedData {
    return [self.userDefaults objectForKey:USER_DEFAULTS_TOTALDOWNLOADEDDATA];
}

// USER_DEFAULTS_TOTALNUMBEROFCONTACT
- (void)setTotalNumberOfContacts:(NSString *)totalNumberOfContacts {
    [self.userDefaults setObject:totalNumberOfContacts forKey:USER_DEFAULTS_TOTALNUMBEROFCONTACT];
}

- (NSString *)totalNumberOfContacts {
    return [self.userDefaults objectForKey:USER_DEFAULTS_TOTALNUMBEROFCONTACT];
}

// USER_DEFAULTS_CONTACTTOTALSIZE
- (void)setContactTotalSize:(NSString *)contactTotalSize {
    [self.userDefaults setObject:contactTotalSize forKey:USER_DEFAULTS_CONTACTTOTALSIZE];
}

- (NSString *)contactTotalSize {
    return [self.userDefaults objectForKey:USER_DEFAULTS_CONTACTTOTALSIZE];
}

// USER_DEFAULTS_REMINDERLOGSIZE
- (void)setReminderLogSize:(NSString *)reminderLogSize {
    [self.userDefaults setObject:reminderLogSize forKey:USER_DEFAULTS_REMINDERLOGSIZE];
}

- (NSString *)reminderLogSize {
    return [self.userDefaults objectForKey:USER_DEFAULTS_REMINDERLOGSIZE];
}

// TODO : USER_DEFAULTS_isAndriodPlatfclearxvorm

// USER_DEFAULTS_calFileList

- (void)setCalFileList:(NSMutableArray *)calFileList {
    [self.userDefaults setObject:calFileList forKey:USER_DEFAULTS_calFileList];
}

- (NSMutableArray *)calFileList {
    return [[self.userDefaults objectForKey:USER_DEFAULTS_calFileList] mutableCopy];
}

// USER_DEFAULTS_batteryAlertSent
- (void)setBatteryAlertSent:(NSNumber *)batteryAlertSent {
    [self.userDefaults setObject:batteryAlertSent forKey:USER_DEFAULTS_batteryAlertSent];
}

- (NSNumber *)batteryAlertSent {
    return [self.userDefaults objectForKey:USER_DEFAULTS_batteryAlertSent];
}

// USER_DEFAULTS_CONTACTSIMPORTED
- (void)setContactsImported:(NSString *)contactsImported {
    [self.userDefaults setObject:contactsImported forKey:USER_DEFAULTS_CONTACTSIMPORTED];
}

- (NSString *)contactsImported {
    return [self.userDefaults objectForKey:USER_DEFAULTS_CONTACTSIMPORTED];
}

// USER_DEFAULTS_LOCALANALYTICS

- (void)setLocalAnalytics:(NSMutableArray *)localAnalytics {
    [self.userDefaults setObject:localAnalytics forKey:USER_DEFAULTS_LOCALANALYTICS];
}

- (NSMutableArray *)localAnalytics {
    return [[self.userDefaults objectForKey:USER_DEFAULTS_LOCALANALYTICS] mutableCopy];
}

// USER_DEFAULTS_videoFileList
- (void)setVideoFileList:(NSMutableArray *)videoFileList {
    [self.userDefaults setObject:videoFileList forKey:USER_DEFAULTS_videoFileList];
}

- (NSMutableArray *)videoFileList {
    return [[self.userDefaults objectForKey:USER_DEFAULTS_videoFileList] mutableCopy];
}

// USER_DEFAULTS_photoFileList
- (void)setPhotoFileList:(NSMutableArray *)photoFileList {
    [self.userDefaults setObject:photoFileList forKey:USER_DEFAULTS_photoFileList];
}

- (NSMutableArray *)photoFileList {
    return [[self.userDefaults objectForKey:USER_DEFAULTS_photoFileList] mutableCopy];
}

// CONTENT_TRANSFER_EULA_AGREEMENT
- (void)setContentTransferEulaAgreement:(BOOL)contentTransferEulaAgreement {
    [self.userDefaults setBool:contentTransferEulaAgreement forKey:USER_DEFAULTS_EULA_AGREEMENT];
}

- (BOOL)isContentTransferEulaAgreement {
    return [self.userDefaults boolForKey:USER_DEFAULTS_EULA_AGREEMENT];
}

// USER_DEFAULTS_SIZE_OF_DATA_TO_TRANSFER
- (void)setSizeOfAllDataToTransfer:(NSNumber *)sizeOfAllDataToTransfer {
    [self.userDefaults setObject:sizeOfAllDataToTransfer forKey:USER_DEFAULTS_SIZE_OF_DATA_TO_TRANSFER];
}

- (NSNumber *)sizeOfAllDataToTransfer {
    return [self.userDefaults objectForKey:USER_DEFAULTS_SIZE_OF_DATA_TO_TRANSFER];
}


- (void)setPairingInfo:(NSDictionary *)pairingInfo {
    [self.userDefaults setObject:[pairingInfo objectForKey:USER_DEFAULTS_PAIRING_DEVICE_ID] forKey:USER_DEFAULTS_PAIRING_DEVICE_ID];
    [self.userDefaults setObject:[pairingInfo objectForKey:USER_DEFAULTS_PAIRING_OS_VERSION] forKey:USER_DEFAULTS_PAIRING_OS_VERSION];
    [self.userDefaults setObject:[pairingInfo objectForKey:USER_DEFAULTS_PAIRING_MODEL] forKey:USER_DEFAULTS_PAIRING_MODEL];
    [self.userDefaults setObject:[pairingInfo objectForKey:USER_DEFAULTS_PAIRING_DEVICE_TYPE] forKey:USER_DEFAULTS_PAIRING_DEVICE_TYPE];
    [self.userDefaults setObject:[pairingInfo objectForKey:USER_DEFAULTS_PAIRING_TYPE] forKey:USER_DEFAULTS_PAIRING_TYPE];
    [self.userDefaults synchronize];
}

// Store the hash table for calendar file name and calendar file PATH
- (void)setCalendarList:(NSDictionary *)calendarList {
    [self.userDefaults setObject:calendarList forKey:USER_DEFAULTS_CALENDAR_HASH_KEY];
}

- (NSDictionary *)calendarList {
    return [self.userDefaults objectForKey:USER_DEFAULTS_CALENDAR_HASH_KEY];
}

- (void)setPhotoTempFolder:(NSString *)photoTempFolder {
    [self.userDefaults setObject:photoTempFolder forKey:USER_DEFAULTS_TEMP_PHOTO_FOLDER];
}

- (NSString *)photoTempFolder {
    return [self.userDefaults objectForKey:USER_DEFAULTS_TEMP_PHOTO_FOLDER];
}

- (void)setLivePhotoTempFolder:(NSString *)livePhotoTempFolder {
    [self.userDefaults setObject:livePhotoTempFolder forKey:USER_DEFAULTS_TEMP_LIVEPHOTO_FOLDER];
}

- (NSString *)livePhotoTempFolder {
    return [self.userDefaults objectForKey:USER_DEFAULTS_TEMP_LIVEPHOTO_FOLDER];
}

- (void)setVideoTempFolder:(NSString *)videoTempFolder {
    [self.userDefaults setObject:videoTempFolder forKey:USER_DEFAULTS_TEMP_VIDEO_FOLDER];
}

- (NSString *)videoTempFolder {
    return [self.userDefaults objectForKey:USER_DEFAULTS_TEMP_VIDEO_FOLDER];
}

- (NSArray *)tempPhotoLists {
    return [self.userDefaults objectForKey:USER_DEFAULTS_TEMP_PHOTO_LIST];
}

- (void)setTempPhotoLists:(NSArray *)tempPhotoLists {
    [self.userDefaults removeObjectForKey:USER_DEFAULTS_TEMP_PHOTO_LIST];
    [self.userDefaults setObject:tempPhotoLists forKey:USER_DEFAULTS_TEMP_PHOTO_LIST];
}

- (NSArray *)tempVideoLists {
    return [self.userDefaults objectForKey:USER_DEFAULTS_TEMP_VIDEO_LIST];
}

- (void)setTempVideoLists:(NSArray *)tempVideoLists {
    [self.userDefaults removeObjectForKey:USER_DEFAULTS_TEMP_VIDEO_LIST];
    [self.userDefaults setObject:tempVideoLists forKey:USER_DEFAULTS_TEMP_VIDEO_LIST];
}

- (NSArray *)receiveFlags {
    return [self.userDefaults objectForKey:USER_DEFAULTS_RECEIVE_FLAGS];
}

- (void)setReceiveFlags:(NSArray *)receiveFlags {
    [self.userDefaults setObject:receiveFlags forKey:USER_DEFAULTS_RECEIVE_FLAGS];
}

- (NSInteger)numberOfPhotosReceived {
    return [[self.userDefaults objectForKey:USER_DEFAULTS_NUMBER_OF_PHOTOS] integerValue];
}

- (void)setNumberOfPhotosReceived:(NSInteger)numberOfPhotos {
    [self.userDefaults setObject:[NSString stringWithFormat:@"%ld", (long)numberOfPhotos] forKey:USER_DEFAULTS_NUMBER_OF_PHOTOS];
}

- (NSInteger)numberOfVideosReceived {
    return [[self.userDefaults objectForKey:USER_DEFAULTS_NUMBER_OF_VIDEOS] integerValue];
}

- (void)setNumberOfVideosReceived:(NSInteger)numberOfVideos {
    [self.userDefaults setObject:[NSString stringWithFormat:@"%ld", (long)numberOfVideos] forKey:USER_DEFAULTS_NUMBER_OF_VIDEOS];
}

- (BOOL)isCancel {
    return [[self.userDefaults objectForKey:USER_DEFAULTS_IS_CANCEL] boolValue];
}

- (void)setIsCancel:(BOOL)isCancel {
    [self.userDefaults setObject:[NSString stringWithFormat:@"%ld", (long)isCancel] forKey:USER_DEFAULTS_IS_CANCEL];
}

- (BOOL)hasVcardPermissionError {
    return [[self.userDefaults objectForKey:USER_DEFAULTS_VCARD_PERMISSION_ERR] boolValue];
}

- (void)setHasVcardPermissionError:(BOOL)hasVcardPermissionError {
    [self.userDefaults setObject:[NSString stringWithFormat:@"%ld", (long)hasVcardPermissionError] forKey:USER_DEFAULTS_VCARD_PERMISSION_ERR];
}

- (BOOL)hasPhotoPermissionError {
    return [[self.userDefaults objectForKey:USER_DEFAULTS_PHOTO_PERMISSION_ERR] boolValue];
}

- (void)setHasPhotoPermissionError:(BOOL)hasPhotoPermissionError {
    [self.userDefaults setObject:[NSString stringWithFormat:@"%ld", (long)hasPhotoPermissionError] forKey:USER_DEFAULTS_PHOTO_PERMISSION_ERR];
}

- (BOOL)hasCameraPermissionError {
    return [[self.userDefaults objectForKey:USER_DEFAULTS_CAMERA_PERMISSION_ERR] boolValue];
}

- (void)setHasCameraPermissionError:(BOOL)hasCameraPermissionError {
    [self.userDefaults setObject:[NSString stringWithFormat:@"%ld", (long)hasCameraPermissionError] forKey:USER_DEFAULTS_CAMERA_PERMISSION_ERR];
}

- (BOOL)hasCalendarPermissionError {
    return [[self.userDefaults objectForKey:USER_DEFAULTS_CALENDAR_PERMISSION_ERR] boolValue];
}

- (void)setHasCalendarPermissionError:(BOOL)hasCalendarPermissionError {
    [self.userDefaults setObject:[NSString stringWithFormat:@"%ld", (long)hasCalendarPermissionError] forKey:USER_DEFAULTS_CALENDAR_PERMISSION_ERR];
}

- (BOOL)hasReminderPermissionError {
    return [[self.userDefaults objectForKey:USER_DEFAULTS_REMINDER_PERMISSION_ERR] boolValue];
}

- (void)setHasReminderPermissionError:(BOOL)hasReminderPermissionError {
    [self.userDefaults setObject:[NSString stringWithFormat:@"%ld", (long)hasReminderPermissionError] forKey:USER_DEFAULTS_REMINDER_PERMISSION_ERR];
}

- (BOOL)hasAudioPermissionError {
    return [self.userDefaults boolForKey:USER_DEFAULTS_AUDIO_PERMISSION_ERR];
}

- (void)setHasAudioPermissionError:(BOOL)hasAudioPermissionError {
    [self.userDefaults setBool:hasAudioPermissionError forKey:USER_DEFAULTS_AUDIO_PERMISSION_ERR];
}

- (void)setBeaconUUID:(NSString *)beaconUUID {
    [self.userDefaults setObject:beaconUUID forKey:@"beaconUUID"];
}

- (NSString *)beaconUUID {
    
    if ([self.userDefaults objectForKey:@"beaconUUID"]) {
        return [self.userDefaults objectForKey:@"beaconUUID"];
    }
    
    return @"";
}

- (void)setBeaconMajor:(NSString *)beaconMajor {
    [self.userDefaults setObject:beaconMajor forKey:@"beaconMajor"];
}

- (NSString *)beaconMajor {
    if ([self.userDefaults objectForKey:@"beaconMajor"]) {
        return [self.userDefaults objectForKey:@"beaconMajor"];
    }
    
    return @"";
}

- (void)setBeaconMinor:(NSString *)beaconMinor {
    [self.userDefaults setObject:beaconMinor forKey:@"beaconMinor"];
}

- (NSString *)beaconMinor {
    if ([self.userDefaults objectForKey:@"beaconMinor"]) {
        return [self.userDefaults objectForKey:@"beaconMinor"];
    }
    
    return @"";
}

- (BOOL)hasShownMDNAlert{
    return [self.userDefaults boolForKey:@"hasShownMDNAlert"];
}

- (void)setHasShownMDNAlert:(BOOL)hasShownMDNAlert{
    [self.userDefaults setBool:hasShownMDNAlert forKey:@"hasShownMDNAlert"];
}

- (void)setTransferStarted:(BOOL)transferStarted {
    [self.userDefaults setBool:transferStarted forKey:@"VZTRANSFER_STARTED"];
}

- (BOOL)transferStarted {
    return [self.userDefaults boolForKey:@"VZTRANSFER_STARTED"];
}

-(NSString*)launchTimeStamp {
    
    return [self.userDefaults stringForKey:@"launchTimeStamp"];
}

-(void)setLaunchTimeStamp:(NSString *)launchTimeStamp {
    
    [self.userDefaults setObject:launchTimeStamp forKey:@"launchTimeStamp"];
}

- (void)setDeviceVID:(NSString *)deviceVID {
    [self.userDefaults setObject:deviceVID forKey:USER_DEFAULTS_DEVICE_VID];
}

- (NSString *)deviceVID {
    return [self.userDefaults objectForKey:USER_DEFAULTS_DEVICE_VID];
}

- (NSInteger)itunesReviewStatus {
    return [self.userDefaults integerForKey:APP_USERDEFAULT_ITUNE_REVIEW_KEY];
}

- (void)setItunesReviewStatus:(NSInteger)itunesReviewStatus {
    [self.userDefaults setInteger:itunesReviewStatus forKey:APP_USERDEFAULT_ITUNE_REVIEW_KEY];
}

- (void)setScanType:(NSString *)scanType {
    [self.userDefaults setObject:scanType forKey:USER_DEFAULTS_SCAN_TYPE];
}

- (NSString *)scanType {
    return [self.userDefaults objectForKey:USER_DEFAULTS_SCAN_TYPE];
}

- (NSString *)transferFinished {
    return [self.userDefaults stringForKey:USER_DEFAULTS_TRANSFER_FINISHED];
}

- (void)setTransferFinished:(NSString *)transferFinished {
    [self.userDefaults setValue:transferFinished forKey:USER_DEFAULTS_TRANSFER_FINISHED];
}

- (NSArray *)errorLivePhotoList {
    NSArray *storedList = [self.userDefaults arrayForKey:USER_DEFAULTS_ERROR_LIVE_PHOTO];
    if (!storedList) { // Empty then create a new one.
        storedList = [[NSMutableArray alloc] init];
    }
    
    return storedList;
}

- (void)setErrorLivePhotoList:(NSArray *)errorLivePhotoList {
    if (errorLivePhotoList) {
        [self.userDefaults setObject:errorLivePhotoList forKey:USER_DEFAULTS_ERROR_LIVE_PHOTO];
    } else {
        if ([self.userDefaults arrayForKey:USER_DEFAULTS_ERROR_LIVE_PHOTO]) { // Exist
            [self.userDefaults removeObjectForKey:USER_DEFAULTS_ERROR_LIVE_PHOTO];
        }
    }
}

- (void)addErrorLivePhoto:(NSString *)photoName {
    NSMutableArray *storedList = [self.errorLivePhotoList mutableCopy];
    [storedList addObject:photoName];
    self.errorLivePhotoList = storedList;
}

@end
