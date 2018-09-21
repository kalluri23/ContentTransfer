//
//  CTReceiveManagerHelper.m
//  contenttransfer
//
//  Created by Sun, Xin on 9/14/16.
//  Copyright © 2016 Verizon Wireless. All rights reserved.
//

#import "CTUserDevice.h"
#import "CTFileManager.h"
#import "CTPhotosManager.h"
#import "CTDuplicateLists.h"
#import "CTBonjourManager.h"
#import "CTDeviceStatusUtility.h"
#import "CTReceiveManagerHelper.h"

#import "NSString+CTHelper.h"
#import "NSString+CTRootDocument.h"

#if STANDALONE == 0
    #import <contentTransferFramework/contenttransfer-Swift.h>
#endif

@interface CTReceiveManagerHelper() <MediaStoreHelperDelegate>
/*! 
    @brief Mutable data type to store incomplete received data.
           
           Each time when received new package, process will check this parameter, and append this data with newly received data if this parameter is not empty.
           
           On the other hand, if some data is considered as imcomplete. It will be stored in this parameter and waiting for further packages.
 */
@property (nonatomic, strong) NSMutableData *pendingData;
/*! Received data for current file.*/
@property (nonatomic, strong) NSMutableData *receivedData;
/*! Time captured when transfer start receiving the first byte.*/
@property (nonatomic, strong) NSDate *startTime;

/*! File list for current receiving section. This list read from metadata.*/
@property (nonatomic, strong) NSArray *targetFileList;
/*! File information for current receiving file. This list read from file list metadata.*/
@property (nonatomic, strong) NSDictionary *targetInfo;
/*! File list index for current receiving files.*/
@property (nonatomic, assign) NSInteger targetFileListIdx;

/*! Bool type indicate that this is the first package received for single file or not. NO means this is first one.*/
@property (nonatomic, assign) BOOL fileStartFound;
/*! Size of the current receiving file.*/
@property (nonatomic, assign) long long fileSize;
/*! Size count for video file tracking. Since video is sending by chunk, use number value instead of NSData length to track.*/
@property (nonatomic, assign) long long tillNowReceived;

/*! Check if contacts transfer finished or not. If no contact needed, then set this to YES as default.*/
@property (nonatomic, assign) BOOL contactsSaved;
/*! Check if photos transfer finished or not. If no photos needed, then set this to YES as default.*/
@property (nonatomic, assign) BOOL photosSaved;
/*! Check if videos transfer finished or not. If no photos needed, then set this to YES as default.*/
@property (nonatomic, assign) BOOL videosSaved;
/*! Check if calendar transfer finished or not. If no calendar needed, then set this to YES as default.*/
@property (nonatomic, assign) BOOL calendarsSaved;
/*! Check if reminder transfer finished or not. If no reminder needed, then set this to YES as default.*/
@property (nonatomic, assign) BOOL remindersSaved;
/*! Check if app list transfer finished or not. If no app list needed, then set this to YES as default.*/
@property (nonatomic, assign) BOOL appsSaved;

/*! Check if contacts received.*/
@property (nonatomic, strong) NSString *contactsReceived;
/*! Check if reminder received.*/
@property (nonatomic, strong) NSString *reminderReceived;
/*! Check if photo received.*/
@property (nonatomic, strong) NSString *photoReceived;
/*! Check if video received.*/
@property (nonatomic, strong) NSString *videoReceived;
/*! Check if calendar received.*/
@property (nonatomic, strong) NSString *calendarReceived;
/*! Check if app list received.*/
@property (nonatomic, strong) NSString *appsReceived;

/*! Count indicate that how many calendar file actually saved in local storage.*/
@property (atomic, assign) NSInteger calendarFileSaved;
/*! Count indicate that how many app icons saved in local storage.*/
@property (atomic, assign) NSInteger appSaved;
/*! Count for calulate how many duplicate files sent by sender side*/
@property (nonatomic, assign) NSInteger localDuplicateCount;

/*! BOOL value indicate that last received file is duplicate photo file. Default value is NO.*/
@property (nonatomic, assign) BOOL lastIsDuplicatePhotoFile;
/*! BOOL value indicate that last received file is duplicate video file. Default value is NO.*/
@property (nonatomic, assign) BOOL lastIsDuplicateVideoFile;
/*! Bool value indicate that current transfer is for live photo image part.*/
@property (nonatomic, assign) BOOL isLivePhotoVideoPart;
@end

@implementation CTReceiveManagerHelper

@synthesize numberOfCalendar;
@synthesize calendarFileSaved;

#pragma mark - Lazy Allocation
- (NSMutableData *)receivedData {
    if (!_receivedData) {
        _receivedData = [[NSMutableData alloc] init];
    }
    
    return _receivedData;
}

- (CTFileLogManager *)fileListManager {
    if (!_fileListManager) {
        _fileListManager = [[CTFileLogManager alloc] init];
    }
    
    return _fileListManager;
}

- (CTMediaStoreHelper *)storeHelper {
    if (!_storeHelper) {
        _storeHelper = [[CTMediaStoreHelper alloc] init];
    }
    
    return _storeHelper;
}

#pragma mark - Initializer
- (instancetype)initWithDelegate:(id<ReceiveHelperManager>)delegate {
    self = [super init];
    if (self) {
        _delegate = delegate;
        self.currentStat = RECEIVE_ALL_FILE_LOG; // receive file list as the first stat
        self.contactsReceived      = @"false";
        self.reminderReceived      = @"false";
        self.calendarReceived      = @"false";
        self.photoReceived         = @"false";
        self.videoReceived         = @"false";
        self.appsReceived          = @"false";
        self.storeHelper.delegate  = self;
        self.isLivePhotoVideoPart  = NO;
        
        // Newly added for failure handshake
        self.transferFailureCounts = [[NSMutableArray alloc] initWithObjects:[NSNumber numberWithLongLong:0], [NSNumber numberWithLongLong:0], [NSNumber numberWithLongLong:0], [NSNumber numberWithLongLong:0], [NSNumber numberWithLongLong:0], [NSNumber numberWithLongLong:0], nil];
        self.transferFailureSize   = [[NSMutableArray alloc] initWithObjects:[NSNumber numberWithLongLong:0], [NSNumber numberWithLongLong:0], [NSNumber numberWithLongLong:0], [NSNumber numberWithLongLong:0], [NSNumber numberWithLongLong:0], [NSNumber numberWithLongLong:0], nil];
    }
    
    return self;
}

#pragma mark - Public API Access
- (enum ReceiveState)type {
    return self.currentStat;
}

#pragma mark - Data Receive Logic
/*!
    @brief Check header using is valid header or not.
    @param headerStr NSString value reprsents the header string using for transfer.
    @return BOOL value indicate that the header is valid or not.
 */
- (BOOL)receiverCheckIfHeaderIsValidHeaderForTransfer:(NSString *)headerStr {
    if ([headerStr isEqualToString:CT_SEND_FILE_LIST_HEADER]                      // file list
        || [headerStr isEqualToString:CT_SEND_FILE_CONTACTS_HEADER]               // contacts
        || [headerStr isEqualToString:CT_SEND_FILE_CALENDARS_HEADER]              // calendars
        || [headerStr isEqualToString:CT_SEND_FILE_REMINDERS_HEADER]              // reminders
        || [headerStr isEqualToString:CT_SEND_FILE_PHOTO_HEADER]                  // photos
        || [headerStr isEqualToString:CT_SEND_FILE_VIDEO_HEADER]                  // videos
        || [headerStr isEqualToString:CT_SEND_FILE_APP_HEADER]) {                 // apps list
        return YES;
    } else if ([headerStr isEqualToString:CT_SEND_FILE_LIVEPHOTO_IMAGE_HEADER]) { // live photo image part
        NSLog(@"> Live photo image part.");
//        self.isLivePhotoVideoPart = NO;
        return YES;
    } else if ([headerStr isEqualToString:CT_SEND_FILE_LIVEPHOTO_VIDEO_HEADER]) { // live photo video part
        NSLog(@"> Live photo video part.");
//        self.isLivePhotoVideoPart = YES;
        return YES;
    }
    
    return NO;
}

- (BOOL)receiverCheckIfHeaderIsForLivePhotoVideoComponent:(NSString *)headerStr {
    return [headerStr isEqualToString:CT_SEND_FILE_LIVEPHOTO_VIDEO_HEADER];
}

/*!
    @brief Receiver check if specific file received complete or not.
    @return BOOL value indicate the result of receiving process.
 */
- (BOOL)receiverCheckIfReceivedCompletedFile {
    if (self.currentStat != RECEIVE_VIDEO_FILE) { // Not video file
        return self.receivedData.length == self.fileSize;
    } else { // Is video file
        return self.tillNowReceived == self.fileSize;
    }
}
/*!
    @brief Receiver check if received error message from the another side.
    @headerStr NSString value represents the header.
    @return BOOL value that indicate that this header is error messge or not.
 */
- (BOOL)receiverCheckIfReceivedErrorMessage:(NSString *)headerStr {
    return [headerStr isEqualToString:CT_SEND_FILE_FAILURE];
}
/*!
    @brief Try to handle the file after complete data received.
    @discussion This method will try to handle the file based on the file type, and push the trasnfer into next stage.
    @param localData NSData represents the data received for specific file.
    @see receiverShouldGoToNextState
 */
- (void)receiverDidFinishRecvFile:(NSData *)localData {
    if (self.currentStat != RECEIVE_VIDEO_FILE && !localData) { // if there is no data for current file, request next one.
        [self receiverDidFinishRecvErrorMessage];
        [self receiverShouldGoToNextState];
        
        return;
    }
    __weak typeof(self) weakSelf = self;
    switch (self.currentStat) {
        case RECEIVE_ALL_FILE_LOG: {
            NSLog(@"[Receive data] Processing file list file....");
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                @autoreleasepool {
                    [weakSelf.fileListManager storeFileList:localData];
                    
                    // Reset all the flags for saving
                    [weakSelf prepareForReceiveData];
                    
                    BOOL enoughStorage = [weakSelf calculatetotalDownloadableDataSize];
                    if (enoughStorage) { // Should be always YES
                        [weakSelf receiverShouldGoToNextState];
                    }
                    
                    [self.delegate receiverShouldUpdateInfo:NO packageSize:0];
                }
            });
        } break;
            
        case RECEIVE_VCARD_FILE: {
            NSLog(@"[Receive data] Processing vcard file....");
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSString *documentsDirectory = [NSString appRootDocumentDirectory];
                NSString *filePath = [documentsDirectory stringByAppendingPathComponent:@"VZAllContactBackup.vcf"];
                [CTFileManager writefileWithPath:filePath andData:localData];

                weakSelf.contactsSaved = YES;
                [weakSelf transferShouldCheckStoreStatus];
            });
            
            [self receiverShouldGoToNextState];
        } break;
            
        case RECEIVE_CALENDAR_FILE: {
            NSLog(@"[Receive data] Processing calendar file....");
            // create received calendar folder to store calendars
            NSString *calendarPath = [[NSString appRootDocumentDirectory] stringByAppendingPathComponent:@"ReceivedCal"];
            // create new folder
            if (![[NSFileManager defaultManager] fileExistsAtPath:calendarPath]) {
                [[NSFileManager defaultManager] createDirectoryAtPath:calendarPath withIntermediateDirectories:NO attributes:nil error:nil]; // create folder
            }
            
            NSDictionary *calendar = self.targetInfo; // Keep it in local
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                @autoreleasepool {
                    NSString *fullPath = nil;
                    if ([[CTUserDevice userDevice].phoneCombination isEqualToString:IOS_Andriod]) { // x-platform
                        fullPath = [NSString stringWithFormat:@"%@/%@", calendarPath, [[calendar objectForKey:@"Path"] lastPathComponent]]; // Name from android only contains calendar name
                    } else {
                        fullPath = [NSString stringWithFormat:@"%@/%@_%@", calendarPath, [calendar objectForKey:@"CalColor"], [calendar objectForKey:@"Path"]]; // Name from iOS contains calendar color in HEX and calendar name.
                    }
                    [CTFileManager writefileWithPath:fullPath andData:localData];
                    
                    @synchronized (self) {
                        self.calendarFileSaved ++;
                        if (self.numberOfCalendar == self.calendarFileSaved) { // All calendar file getting saved in local
                            self.calendarFileSaved = 0; // Reset file saved count
                            self.calendarsSaved = YES;
                            [self transferShouldCheckStoreStatus];
                        }
                    }
                }
            });
            
            [self receiverShouldGoToNextState];
        } break;
            
        case RECEVIE_REMINDER_FILE: {
            NSLog(@"[Receive data] Processing reminder file....");
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                @autoreleasepool {
                    NSString *fileName = [[NSString appRootDocumentDirectory] stringByAppendingPathComponent:@"reminderLogFile.txt"];
                    [CTFileManager writefileWithPath:fileName andData:localData];
                    
                    self.remindersSaved = YES;
                    [self transferShouldCheckStoreStatus];
                }
            });
            
            [self receiverShouldGoToNextState];
        } break;
            
        case RECEIVE_PHOTO_FILE: {
            NSLog(@"[Receive data] Processing photo file....");
            if ([CTLivePhoto isCurrentImageLivePhoto:self.targetInfo]) {
                // It is live photo
                if (!self.isLivePhotoVideoPart) {
                    // It's live photo image part, hold and request video part.
                    self.storeHelper.imageResourceHolder = localData;
                    self.isLivePhotoVideoPart = YES;
                    [self livePhotoShouldRequestVideoResource];
                } else {
                    self.isLivePhotoVideoPart = NO;
                    // It's live photo video part, save and request next.
                    // Get image resource and clear the holder.
                    NSData *localImageData = self.storeHelper.imageResourceHolder;
                    self.storeHelper.imageResourceHolder = nil;
                    // Store the image with video.
                    [self.storeHelper storePhotoIntoTempDocumentFolder:localImageData videoComponent:localData isLivePhoto:YES photoInfo:self.targetInfo];
                    localImageData = nil;
                    [self receiverShouldGoToNextState];
                }
            } else {
                // It's static photo, save and request next.
                [self.storeHelper storePhotoIntoTempDocumentFolder:localData videoComponent:nil isLivePhoto:NO photoInfo:self.targetInfo];
                [self receiverShouldGoToNextState];
            }
        } break;
            
        case RECEIVE_VIDEO_FILE: {
            NSLog(@"[Receive data] Processing video file....");
            [self receiverShouldGoToNextState];
        } break;
            
        case RECEIVE_APP_LIST_FILE: {
            NSLog(@"[Receive data] Processing apps list file....");
            // Create app icon folder to store photos
            NSString *document = [NSString appRootDocumentDirectory];
            NSString *docPath = [document stringByAppendingPathComponent:@"ReceivedAppIcons"];
            
            // create new folder
            if (![[NSFileManager defaultManager] fileExistsAtPath:docPath]) {
                [[NSFileManager defaultManager] createDirectoryAtPath:docPath withIntermediateDirectories:NO attributes:nil error:nil]; // create folder
            }
            
            NSDictionary *appsInfo = self.targetInfo; // keep it in local
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                @autoreleasepool {
                    NSString *fullPath = [NSString stringWithFormat:@"%@/%@.png", docPath, [appsInfo objectForKey:@"name"]];
                    
                    [CTFileManager writefileWithPath:fullPath andData:localData];
                    
                    @synchronized (self) {
                        self.appSaved ++;
                        if (self.numberOfApps == self.appSaved) {
                            self.appsSaved = YES;
                            [self transferShouldCheckStoreStatus];
                        }
                    }
                }
            });
            
            [self receiverShouldGoToNextState];
        } break;
            
        default:
            break;
    }
}
/*!
    @brief Try to handle the file after received error message.
    @discussion This method will try to handle the file based on the file type.
 */
- (void)receiverDidFinishRecvErrorMessage {
    __weak typeof(self) weakSelf = self;
    switch (self.currentStat) {
        case RECEIVE_VCARD_FILE: {
            NSLog(@"[Receive data] Processing vcard file error....");
            weakSelf.contactsSaved = YES;
        } break;
            
        case RECEIVE_CALENDAR_FILE: {
            NSLog(@"[Receive data] Processing calendar file error....");
            
            @synchronized (self) {
                self.calendarFileSaved ++;
                if (self.numberOfCalendar == self.calendarFileSaved) { // All calendar file getting saved in local
                    self.calendarFileSaved = 0; // Reset file saved count
                    self.calendarsSaved = YES;
                }
            }
        } break;
            
        case RECEVIE_REMINDER_FILE: {
            NSLog(@"[Receive data] Processing reminder error file....");
            
            self.remindersSaved = YES;
        } break;
            
        case RECEIVE_PHOTO_FILE: {
            NSLog(@"[Receive data] Processing photo error file....");
            
            if ([self isReceivingLivePhotoVideoComponent]) { // If video component failed. Try to save as static photo
                self.isLivePhotoVideoPart = NO;
                // It's live photo video part, save and request next.
                // Get image resource and clear the holder.
                NSData *localImageData = self.storeHelper.imageResourceHolder;
                self.storeHelper.imageResourceHolder = nil;
                // Store the image with video.
                [self.storeHelper storePhotoIntoTempDocumentFolder:localImageData videoComponent:nil isLivePhoto:NO photoInfo:self.targetInfo];
                localImageData = nil;
            } else {
                self.lastIsDuplicatePhotoFile = YES;
                
                @synchronized (self) {
                    self.storeHelper.tempPhotoSavedCount ++;
                }
            }
            
        } break;
            
        case RECEIVE_VIDEO_FILE: {
            NSLog(@"[Receive data] Processing video error file....");

            self.lastIsDuplicateVideoFile = YES;
            @synchronized (self) {
                self.storeHelper.tempVideoSavedCount ++;
            }
        } break;
            
        case RECEIVE_APP_LIST_FILE: {
            NSLog(@"[Receive data] Processing apps list error file....");
            
            @synchronized (self) {
                self.appSaved ++;
                if (self.numberOfApps == self.appSaved) {
                    self.appsSaved = YES;
                    [self transferShouldCheckStoreStatus];
                }
            }
        } break;
            
        default:
            break;
    }
}
/*!
    @brief Try to go to next stage of transfer for different types of transfer.
 */
- (void)receiverShouldGoToNextState {
    if (self.currentStat == RECEIVE_CALENDAR_FILE) {
        [self didFinishReceivedCalendarFile];
    } else if (self.currentStat == RECEIVE_PHOTO_FILE) {
        [self didFinishReceivedPhotoFile];
    } else if (self.currentStat == RECEIVE_VIDEO_FILE) {
        [self didFinishReceivedVideoFile];
    } else if (self.currentStat == RECEIVE_APP_LIST_FILE) {
        [self didFinishReceivedAppFile];
    } else {
        [self didCompleteReceiveFile];
    }
}
/*!
 Request video resource for same live photo object.
 */
- (void)livePhotoShouldRequestVideoResource {
    // request
    NSString *requestHeader = CT_REQUEST_FILE_LIVEPHOTO_VIDEO_HEADER;
    
    NSData *requestData = [requestHeader dataUsingEncoding:NSUTF8StringEncoding];
    [self sendRequestToSender:requestData];
}
/*!
    @brief Add up size for file into total size received parameter.
    @param size NSUInteger represents the size of file need to be updated.
 */
- (void)receiverCheckShouldUpdateTotalSize:(NSUInteger)size {
    if (self.currentStat != RECEIVE_ALL_FILE_LOG) { // Non file list size will be calculated into total transfer size.
        self.totalSizeReceived += size;
    }
}
/*!
    @brief Update information for regular transfer. No UI updated needed for file log.
    @param isDuplicate BOOL value indicate that this is duplicate file or not.
 */
- (void)receiverCheckShouldUpdateUIInformation:(BOOL)isDuplicate withPackgeSize:(long long)packageSize {
    if (self.currentStat != RECEIVE_ALL_FILE_LOG) { // Non file list transfer, update UI for each package received.
        [self.delegate receiverShouldUpdateInfo:isDuplicate packageSize:packageSize];
    }
}
/*!
    @brief Update number for different types of file trasfer.
 */
- (void)receiverCheckShouldUpdateStartRecevingCountForDataSection {
    if (self.currentStat == RECEIVE_CALENDAR_FILE) {
        self.numberOfCalStartReceiving += 1;
    } else if (self.currentStat == RECEIVE_PHOTO_FILE) {
        self.numberOfPhotosStartReceiving += 1;
    } else if (self.currentStat == RECEIVE_VIDEO_FILE) {
        self.numberOfVideosStartReceiving += 1;
    } else if (self.currentStat == RECEIVE_APP_LIST_FILE) {
        self.numberOfAppsStartReceiving += 1;
    }
}
/*!
    @brief Receiver should update failure number for error case.
    @errorSize Long long value represents the size of error file.
 */
- (void)receiverUpdateFailureArrayWithSize:(long long)errorSize {
    switch (self.currentStat) {
        case RECEIVE_VCARD_FILE:
            [self.transferFailureCounts replaceObjectAtIndex:0 withObject:[NSNumber numberWithInteger:[self.transferFailureCounts[0] integerValue] + 1]];
            [self.transferFailureSize replaceObjectAtIndex:0 withObject:[NSNumber numberWithLongLong:[self.transferFailureSize[0] longLongValue] + errorSize]];
            break;
        case RECEIVE_CALENDAR_FILE:
            [self.transferFailureCounts replaceObjectAtIndex:1 withObject:[NSNumber numberWithInteger:[self.transferFailureCounts[1] integerValue] + 1]];
            [self.transferFailureSize replaceObjectAtIndex:1 withObject:[NSNumber numberWithLongLong:[self.transferFailureSize[1] longLongValue] + errorSize]];
            break;
        case RECEVIE_REMINDER_FILE:
            [self.transferFailureCounts replaceObjectAtIndex:2 withObject:[NSNumber numberWithInteger:[self.transferFailureCounts[2] integerValue] + 1]];
            [self.transferFailureSize replaceObjectAtIndex:2 withObject:[NSNumber numberWithLongLong:[self.transferFailureSize[2] longLongValue] + errorSize]];
            break;
        case RECEIVE_PHOTO_FILE:
            [self.transferFailureCounts replaceObjectAtIndex:3 withObject:[NSNumber numberWithInteger:[self.transferFailureCounts[3] integerValue] + 1]];
            [self.transferFailureSize replaceObjectAtIndex:3 withObject:[NSNumber numberWithLongLong:[self.transferFailureSize[3] longLongValue] + errorSize]];
            break;
        case RECEIVE_VIDEO_FILE:
            [self.transferFailureCounts replaceObjectAtIndex:4 withObject:[NSNumber numberWithInteger:[self.transferFailureCounts[4] integerValue] + 1]];
            [self.transferFailureSize replaceObjectAtIndex:4 withObject:[NSNumber numberWithLongLong:[self.transferFailureSize[4] longLongValue] + errorSize]];
            break;
        case RECEIVE_APP_LIST_FILE:
            [self.transferFailureCounts replaceObjectAtIndex:5 withObject:[NSNumber numberWithInteger:[self.transferFailureCounts[5] integerValue] + 1]];
            [self.transferFailureSize replaceObjectAtIndex:5 withObject:[NSNumber numberWithLongLong:[self.transferFailureSize[5] longLongValue] + errorSize]];
            break;
        default:
            break;
    }
}
/*!
    @brief Receiver should update size information after received error message, and add current file into failure array.
    @param fileSizeStr NSString value represents the bytes for error size. This size is read from error header for the last 10 digits.
    @param isStartedWithError BOOL value indicate that this error received as first header of file or last package in the middle of transfer.
 */
- (void)receiverShouldUpdateInformationForErrorMessage:(NSString *)fileSizeStr fromBeginning:(BOOL)isStartedWithError {
    
    if (isStartedWithError && ![self isReceivingLivePhotoVideoComponent]) { // If error message is the first package of the file(before transfer)
        // Update necessary count
        self.numberOfFileReceived += 1;
        [self receiverCheckShouldUpdateStartRecevingCountForDataSection];
    }
    
    self.dataSizeSection += [fileSizeStr longLongValue];
    [self receiverCheckShouldUpdateTotalSize:[fileSizeStr integerValue]];
    if (![self isReceivingLivePhotoVideoComponent]) { // If it's video component failed, consider as success, and save as static image.
        [self receiverUpdateFailureArrayWithSize:[fileSizeStr longLongValue]];
    }
    // Update UI information
    [self receiverCheckShouldUpdateUIInformation:YES withPackgeSize:[fileSizeStr longLongValue]];
    // Handle files
    [self receiverDidFinishRecvErrorMessage];
    // Request for next file
    [self receiverShouldGoToNextState];
}

- (BOOL)isReceivingLivePhotoVideoComponent {
    return self.currentStat == RECEIVE_PHOTO_FILE && [CTLivePhoto isCurrentImageLivePhoto:self.targetInfo] && self.isLivePhotoVideoPart;
}

- (void)receiverDidRecvDataPackage:(NSData *)data {
    
    if (self.pendingData.length > 0) { // if we have pending data, then merge the new data with it, get the new package
        [self.pendingData appendData:data];
        data = (NSData *)self.pendingData;
        self.pendingData = nil; // make sure clear pending data everytime, keep it length 0
    }
    
    if (!self.fileStartFound) { // First package, need to parse the header first, and reset necessary parameter.
        DebugLog(@"=================Start receiving file====================");
        if (self.currentStat == RECEIVE_ALL_FILE_LOG) { // If it's file list receiving, capture the start time.
            self.startTime = [NSDate date];
        }
        
        if (data.length < 37) { // if header less than 37, package not complete, store it and wait for next package comes
            self.pendingData = [NSMutableData dataWithData:data];
            return;
        }
        
        NSData *headerData = [data subdataWithRange:NSMakeRange(0, 37)]; // Fetch the header data
        NSString *headerStr = [[NSString alloc] initWithData:headerData encoding:NSUTF8StringEncoding]; // Parse header string
        NSString *headerKey = [headerStr substringToIndex:27];
        if ([self receiverCheckIfHeaderIsValidHeaderForTransfer:headerKey]) {
            NSString *fileSizeStr = [headerStr substringFromIndex:27]; // last 10 digit number indicate the size of current file
            self.fileSize = [fileSizeStr longLongValue];
            NSLog(@"> Target size: %lld", self.fileSize);
            self.fileStartFound = YES;
            
            if (self.currentStat == RECEIVE_ALL_FILE_LOG) {
                self.totalSizeOfFileList = self.fileSize; // If it's file list, store file list size.
            } else {
                if (![self receiverCheckIfHeaderIsForLivePhotoVideoComponent:headerKey]) { // No need to add one file count for video component of live photo.
                    self.numberOfFileReceived += 1; // If non file list file, add number of file received. File size will be stored in metadata.
                    [self receiverCheckShouldUpdateStartRecevingCountForDataSection];
                }
                
                if (self.currentStat == RECEIVE_VIDEO_FILE) { // If it's video section, should reset video related parameters
                    self.tillNowReceived = 0;
                }
            }
            
            if (data.length > 37) { // if initial data package attached with header
                if (data.length >= 74) { // check last 37 is error message or not
                    NSData *subData = [data subdataWithRange:NSMakeRange(data.length - 37, 37)];
                    NSString *lastString = [[NSString alloc] initWithData:subData encoding:NSUTF8StringEncoding];
                    if (lastString != nil && lastString.length >= 27 && [self receiverCheckIfReceivedErrorMessage:[lastString substringToIndex:27]]) { // if it's error message
                        // Update bytes already got
                        self.dataSizeSection += data.length - 74; // normal header + error header
                        [self receiverCheckShouldUpdateTotalSize:data.length - 74];
                        
                        // Reset properties
                        self.fileSize = 0;
                        self.fileStartFound = NO;
                        
                        
                        NSString *fileSizeStr = [lastString substringFromIndex:27]; // last 10 digit number as size need to be updated.
                        [self receiverShouldUpdateInformationForErrorMessage:fileSizeStr fromBeginning:NO];
                        
                        return;
                    }
                }
                
                if (self.currentStat != RECEIVE_VIDEO_FILE) {
                    [self.receivedData appendData:[data subdataWithRange:NSMakeRange(37, data.length - 37)]];
                    
                    self.dataSizeSection += self.receivedData.length;
                    [self receiverCheckShouldUpdateTotalSize:self.receivedData.length];
                    
                    NSLog(@"> First package of data received: %lu of %lld...", (unsigned long)self.receivedData.length, self.fileSize);
                } else {
                    NSData *tempDAta = [data subdataWithRange:NSMakeRange(37, data.length - 37)];
                    self.tillNowReceived = (long long)data.length - 37;
                    
                    [self.storeHelper storeVideoReceivedPacketToTempFile:tempDAta forFile:self.targetInfo tillNowReceived:self.tillNowReceived totalSize:self.fileSize remove:YES];
                    
                    self.dataSizeSection += tempDAta.length;
                    [self receiverCheckShouldUpdateTotalSize:tempDAta.length];
                }
            }
        } else if ([self receiverCheckIfReceivedErrorMessage:headerKey]) {
            NSString *fileSizeStr = [headerStr substringFromIndex:27]; // last 10 digit number as size need to be updated.
            [self receiverShouldUpdateInformationForErrorMessage:fileSizeStr fromBeginning:YES];
            return;
        } else { // should check error message.
            NSLog(@"[Receive data] Header received is not valid: %@", headerStr);
        }
        
        if (self.currentStat != RECEIVE_VIDEO_FILE) {
            [self receiverCheckShouldUpdateUIInformation:NO withPackgeSize:self.receivedData.length];
        } else {
            [self receiverCheckShouldUpdateUIInformation:NO withPackgeSize:self.tillNowReceived];
        }
    } else {
        if (data.length >= 37) { // check last 37 is error message or not
            NSData *subData = [data subdataWithRange:NSMakeRange(data.length - 37, 37)];
            NSString *lastString = [[NSString alloc] initWithData:subData encoding:NSUTF8StringEncoding];
            if (lastString != nil && lastString.length >= 27 && [self receiverCheckIfReceivedErrorMessage:[lastString substringToIndex:27]]) { // if it's error message
                // Update byte already got
                self.dataSizeSection += data.length - 37;
                [self receiverCheckShouldUpdateTotalSize:data.length - 37];
                
                // Reset properties
                self.tillNowReceived = 0;
                self.fileSize = 0;
                self.receivedData = nil;
                self.fileStartFound = NO;
                
                // Update unfinished bytes
                NSString *fileSizeStr = [lastString substringFromIndex:27]; // last 10 digit number as size need to be updated.
                [self receiverShouldUpdateInformationForErrorMessage:fileSizeStr fromBeginning:NO];
                
                return;
            }
        }
        
        if (self.currentStat != RECEIVE_VIDEO_FILE) {
            [self.receivedData appendData:data];
            NSLog(@"> Rest data received: %lu of %lld...", (unsigned long)self.receivedData.length, self.fileSize);
        } else {
            self.tillNowReceived += data.length;
            
            if ([[CTUserDevice userDevice].pairingType isEqualToString:kP2P] && ((self.tillNowReceived - 1024) % (self.fileListManager.packageSize * 1024 * 1024) == 0) && self.tillNowReceived != self.fileSize) { // Ask for next chunk of video if package full and video incomplete
                [self requestForNextVideoChuck];
            }
            
            [self.storeHelper storeVideoReceivedPacketToTempFile:data forFile:self.targetInfo tillNowReceived:self.tillNowReceived totalSize:self.fileSize remove:NO];
        }
        self.dataSizeSection += data.length;
        
        [self receiverCheckShouldUpdateTotalSize:data.length];
        [self receiverCheckShouldUpdateUIInformation:NO withPackgeSize:data.length];
    }
    
    if ([self receiverCheckIfReceivedCompletedFile]) { // If received complete file
        DebugLog(@"=================End receiving file====================");
        // reset package indicator
        self.fileStartFound = NO;
        
        NSData *localData = nil;
        if (self.fileSize > 0 && self.receivedData) {
            // process file received
            localData = self.receivedData;
        }
        
        // clear globle
        self.receivedData = nil;
        self.fileSize = 0;
        
        [self receiverDidFinishRecvFile:localData];
    } else {
        NSAssert(self.receivedData.length < self.fileSize, @"Size is bigger, check the code!");
    }
}

#pragma mark - Data Receive Helper Methods
/*!
    @brief Setup necessary count value and array using for transfer.
 */
- (void)prepareForReceiveData {
    NSDictionary *dict = self.fileListManager.fileList.selectItemList;
    if ([CTUserDefaults sharedInstance].hasVcardPermissionError || ![dict valueForKey:@"contacts"] || [[[dict valueForKey:@"contacts"] valueForKey:@"status"] isEqualToString:@"false"]) {
        self.contactsSaved = YES;
    }
    if ([CTUserDefaults sharedInstance].hasPhotoPermissionError || ![dict valueForKey:@"photos"] || [[[dict valueForKey:@"photos"] valueForKey:@"status"] isEqualToString:@"false"] || ((NSArray *)[[NSUserDefaults standardUserDefaults] valueForKey:@"photoFilteredFileList"]).count == 0) {
        self.photosSaved = YES;
    }
    if ([CTUserDefaults sharedInstance].hasPhotoPermissionError || ![dict valueForKey:@"videos"] ||[[[dict valueForKey:@"videos"] valueForKey:@"status"] isEqualToString:@"false"] || ((NSArray *)[[NSUserDefaults standardUserDefaults] valueForKey:@"videoFilteredFileList"]).count == 0) {
        self.videosSaved = YES;
    }
    if ([CTUserDefaults sharedInstance].hasCalendarPermissionError || ![dict valueForKey:@"calendar"] ||[[[dict valueForKey:@"calendar"] valueForKey:@"status"] isEqualToString:@"false"] || ((NSArray *)[[NSUserDefaults standardUserDefaults] valueForKey:@"calFileList"]).count == 0) {
        self.calendarsSaved = YES;
    }
    if ([CTUserDefaults sharedInstance].hasReminderPermissionError || ![dict valueForKey:@"reminder"] || [[[dict valueForKey:@"reminder"] valueForKey:@"status"] isEqualToString:@"false"]) {
        self.remindersSaved = YES;
    }
    if (![dict valueForKey:@"apps"] || [[[dict valueForKey:@"apps"] valueForKey:@"status"] isEqualToString:@"false"] || ((NSArray *)[[NSUserDefaults standardUserDefaults] valueForKey:@"appsFileList"]).count == 0) {
        self.appsSaved = YES;
    }
    
    self.totalNumberOfPhotos = ((NSArray *)[[NSUserDefaults standardUserDefaults] valueForKey:@"photoFilteredFileList"]).count;
    self.totalNumberOfVideos = ((NSArray *)[[NSUserDefaults standardUserDefaults] valueForKey:@"videoFilteredFileList"]).count;
    self.storeHelper.totalNumberOfPhotos = self.totalNumberOfPhotos;
    self.storeHelper.totalNumberOfVideos = self.totalNumberOfVideos;
}
/*!
    @brief Calculate the total size of the transfer needed and available space device has. Return if this device can contain all the contents.
    @note This method is old flow for checking storage. Since checking process now move to version check with commport. This method should never return false. But still need to call it, since there are some value check still working for receiver side.
    @return BOOL value indicate that current device can contain all the contents or not.
 */
- (BOOL)calculatetotalDownloadableDataSize {
    
    long long totaldownloadableData = 0;
    long long totalPayLoadSize = 0;
    long long availableStorage = 0;
    
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    
    NSMutableDictionary *dict = [[userDefault valueForKey:@"itemsList_MF"] mutableCopy];
    
    if (dict != nil) {
        
        if ([[[dict valueForKey:@"photos"] objectForKey:@"status"] isEqualToString:@"true"]) {
            self.totalSizeOfPhoto = [[[dict valueForKey:@"photos"] objectForKey:@"totalSize"] longLongValue];
            DebugLog(@"photo size:%lld", self.totalSizeOfPhoto);
            [userDefault setObject:[[dict valueForKey:@"photos"] objectForKey:@"totalCount"] forKey:@"PHOTO_TOTAL_COUNT"];
        }
        
        if ([[[dict valueForKey:@"videos"] objectForKey:@"status"] isEqualToString:@"true"]) {
            self.totalSizeOfVideo = [[[dict objectForKey:@"videos"] valueForKey:@"totalSize"] longLongValue];
            DebugLog(@"video size:%lld", self.totalSizeOfVideo);
            [userDefault setObject:[[dict valueForKey:@"videos"] objectForKey:@"totalCount"] forKey:@"VIDEO_TOTAL_COUNT"];
        }
        
        if ([[[dict valueForKey:@"contacts"] objectForKey:@"status"] isEqualToString:@"true"]) {
            self.totalSizeOfVcard = [[[dict objectForKey:@"contacts"] valueForKey:@"totalSize"] longLongValue];
            DebugLog(@"contact size:%lld", self.totalSizeOfVcard);
            [userDefault setObject:[[dict valueForKey:@"contacts"] objectForKey:@"totalCount"] forKey:@"CONTACTS_TOTAL_COUNT"];
        }
        
        if ([[[dict valueForKey:@"calendar"] objectForKey:@"status"] isEqualToString:@"true"]) {
            self.totalSizeOfCalendar = [[[dict objectForKey:@"calendar"] objectForKey:@"totalSize"] longLongValue];
            DebugLog(@"photo size:%lld", self.totalSizeOfPhoto);
            [userDefault setObject:[[dict valueForKey:@"calendar"] objectForKey:@"totalCount"] forKey:@"CALENDAR_TOTAL_COUNT"];
        }
        
        // For apps
        if ([[[dict valueForKey:@"apps"] objectForKey:@"status"] isEqualToString:@"true"]) {
            self.totalSizeOfApps = [[[dict objectForKey:@"apps"] objectForKey:@"totalSize"] longLongValue];
            DebugLog(@"app icon total size:%lld", self.totalSizeOfApps);
            [userDefault setObject:[[dict valueForKey:@"apps"] objectForKey:@"totalCount"] forKey:@"APPS_TOTAL_COUNT"];
        }
        
        if ([[[dict valueForKey:@"reminder"] objectForKey:@"status"] isEqualToString:@"true"]) {
            self.totalSizeOfReminder = [[[dict objectForKey:@"reminder"] objectForKey:@"totalSize"] longLongValue]; // byte
            DebugLog(@"reminder total size:%lld", self.totalSizeOfReminder);
            [userDefault setObject:[[dict valueForKey:@"reminder"] objectForKey:@"totalCount"] forKey:@"REMINDER_TOTAL_COUNT"];
        }
        
        totaldownloadableData = self.totalSizeOfVcard + self.totalSizeOfPhoto + self.totalSizeOfVideo + self.totalSizeOfCalendar + self.totalSizeOfReminder + self.totalSizeOfApps;
        
        //#endif
        totalPayLoadSize =(double)(totaldownloadableData/(1024 * 1024)); // MB
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithLongLong:totaldownloadableData] forKey:USER_DEFAULTS_TOTAL_PAYLOAD];
        [[NSUserDefaults standardUserDefaults] synchronize];
        DebugLog(@"----> total size: %lld", totalPayLoadSize);
        availableStorage = [CTDeviceStatusUtility getFreeDiskSpaceInMegaBytes];
        
        if (totalPayLoadSize > availableStorage) {
            // Send INSUFFICENTSTORAGE MSG TO SENDER
            [self sendInSufficentStorageMsgToSender];
            [self.delegate inSufficentStorageAvailalbe:[NSNumber numberWithLongLong:availableStorage]];
            return NO;
        } else {
            [self.delegate totalPayLoadRecevied:[NSNumber numberWithLongLong:totaldownloadableData]];
            return YES;
        }
    } else {
        return NO;
    }
}
/*!
    @brief Check if everything getting transferred and ready to start saving process.
 
           Since most of temp file saving is in seperate thread, there is no grantee that which one will finish first. So this method will be called after each of type of data finished their temp file store as regular check.
 
           If all check pass, this method will send signal, allow transfer move to save stage.
 */
- (void)transferShouldCheckStoreStatus {
    if (self.lastIsDuplicatePhotoFile && self.storeHelper.tempPhotoSavedCount == self.storeHelper.totalNumberOfPhotos && !self.photosSaved) {
        self.photosSaved = YES;
        [self.storeHelper storePhotoList];
    }
    
    if (self.lastIsDuplicateVideoFile && self.storeHelper.tempVideoSavedCount == self.storeHelper.totalNumberOfVideos && !self.videosSaved) {
        self.videosSaved = YES;
        [self.storeHelper storeVideoList];
    }
    
    if (self.contactsSaved && self.photosSaved && self.videosSaved && self.calendarsSaved && self.remindersSaved && self.appsSaved) { // All types of temp file saved, should notify to allow store process
        
        NSArray *flags = @[self.contactsReceived, self.calendarReceived, self.reminderReceived, self.photoReceived, self.videoReceived, self.appsReceived];
        [CTUserDefaults sharedInstance].receiveFlags = flags;
        [self.delegate transferShouldAllowSaving]; // should allow save
    }
}

#pragma mark - Duplicate Receiving Logic
/*!
    @brief Check current file is duplicate file or not.
    @discussion Basically, duplicate logic is working based on maintaining the duplicate map stored in NSUserDefault. So it will not work when user remove the app from their device and re-install again.
    @param fileName NSString value represents the file name. This value should be unique, and will be used as mapping key for duplicate.
    @param type NSString value represents the type of the file.
 */
- (BOOL)checkDuplicateForFile:(NSString *)fileName MediaType:(NSString *)type {
    
    if ([[CTUserDevice userDevice].phoneCombination isEqualToString:IOS_IOS]) {
        // iOS
        NSString *localIdentifier = nil;
        if ([type isEqualToString:@"photo"]) { // photo duplicate list
            if ([[CTDuplicateLists uniqueList] checkPhotoFileInDuplicateList:fileName localIdentifierReturn:&localIdentifier]) {
                if ([self _checkPhotoFor:localIdentifier]) {
                    return YES;
                } else {
                    [[CTDuplicateLists uniqueList] removePhotoFileFromDuplicateList:fileName];
                }
            }
        } else { // video duplicate
            if ([[CTDuplicateLists uniqueList] checkVideoFileInDuplicateList:fileName localIdentifierReturn:&localIdentifier]) {
                if ([self _checkVideoFor:localIdentifier]) {
                    return YES;
                } else {
                    [[CTDuplicateLists uniqueList] removeVideoFileFromDuplicateList:fileName];
                }
            }
        }
    } else {
        // Android
        NSMutableDictionary *duplicateList = nil;
        if ([type isEqualToString:@"photo"]) { // photo duplicate list
            duplicateList = [(NSDictionary *)[[NSUserDefaults standardUserDefaults] objectForKey:@"PHOTODUPLICATELIST"] mutableCopy];
        } else { // video duplicate
            duplicateList = [(NSDictionary *)[[NSUserDefaults standardUserDefaults] objectForKey:@"VIDEODUPLICATELIST"] mutableCopy];
        }
        NSString *localIdentifier = [duplicateList stringForKey:fileName];
        if (localIdentifier) { // if current file name is in the list, check physical file is exist or not
            if ([type isEqualToString:@"photo"] && [self _checkPhotoFor:localIdentifier]) {
                return YES;
            } else if ([type isEqualToString:@"video"] && [self _checkVideoFor:localIdentifier]) {
                return YES;
            }
            
            [duplicateList removeObjectForKey:fileName];
            if ([type isEqualToString:@"photo"]) {
                [[NSUserDefaults standardUserDefaults] setObject:duplicateList forKey:@"PHOTODUPLICATELIST"];
            } else {
                [[NSUserDefaults standardUserDefaults] setObject:duplicateList forKey:@"VIDEODUPLICATELIST"];
            }
        }
        
    }
    
    return NO;
}

/*! 
    @brief Check photo existence using localID.
    @return BOOL value indicate photo with speicific ID exist or removed already.
    @see CTPhotoManager
 */
- (BOOL)_checkPhotoFor:(NSString *)localIdentifier {
    return [CTPhotosManager checkPhotoWithID:localIdentifier];
}
/*!
    @brief Check video existence using localID.
    @return BOOL value indicate video with speicific ID exist or removed already.
    @see CTPhotoManager
 */
- (BOOL)_checkVideoFor:(NSString *)localIdentifier {
    return [CTPhotosManager checkVideoWithID:localIdentifier];
}

#pragma mark - Transfer Flow Control
/*!
    @brief This method will try to init the transfer for next type of file.
    @note File order is fixed, it will follow file list/contacts/calendars/reminders/photos/videos/app lists.
 
          This method will also reset necessary global paramters using for next section.
 */
- (void)didCompleteReceiveFile {
    
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    
    if (self.fileListManager.fileList && self.fileListManager.fileList.contactSelected && !self.fileListManager.contactStarted) { // receive contacts
        self.lastIsDuplicatePhotoFile = NO;
        self.lastIsDuplicateVideoFile = NO;
        self.contactsReceived = @"true";
        
        self.fileListManager.contactStarted = YES;
        
        if ([CTUserDefaults sharedInstance].hasVcardPermissionError) {
            [self didCompleteReceiveFile];
            
            return;
        }
        
        self.dataSizeSection = 0;
        
        // create header
        NSString *shareKey = [[NSString alloc] initWithFormat:CT_REQUEST_FILE_CONTACT_HEADER];
        NSData *requestData = [shareKey dataUsingEncoding:NSUTF8StringEncoding];
        
        self.currentStat = RECEIVE_VCARD_FILE;
        [self sendRequestToSender:requestData];
        
    } else if (self.fileListManager.fileList && self.fileListManager.fileList.calendarSelected && ((NSArray *)[userDefault valueForKey:@"calFileList"]).count > 0 && !self.fileListManager.calendarStarted) { // receive calendars
        self.lastIsDuplicatePhotoFile = NO;
        self.lastIsDuplicateVideoFile = NO;
        self.calendarReceived = @"true";
        
        self.fileListManager.calendarStarted = YES;
        
        if ([CTUserDefaults sharedInstance].hasCalendarPermissionError) {
            [self didCompleteReceiveFile];
            
            return;
        }
        
        self.dataSizeSection = 0;
        
        self.targetFileList = (NSArray *)[userDefault valueForKey:@"calFileList"];
        self.numberOfCalendar = self.targetFileList.count;
        
        self.targetFileListIdx = 0; // 0 index init
        
        self.targetInfo = [self.targetFileList objectAtIndex:self.targetFileListIdx];
        
        DebugLog(@"Calendar info:\n%@", self.targetInfo);
        
        // create response
        NSString *ackMsg = nil;
        if ([[CTUserDevice userDevice].phoneCombination isEqualToString:IOS_Andriod]) {
            ackMsg = [NSString stringWithFormat:@"%@%@", CT_REQUEST_FILE_CALENDARS_HEADER, [self.targetInfo valueForKey:@"Path"]];
        } else if (self.targetFileList.count == 1) { // only one calendar in the list
            ackMsg = [NSString stringWithFormat:@"%@%@", CT_REQUEST_FILE_CALENDARS_FINAL_HEADER, [self.targetInfo valueForKey:@"Path"]];
        } else {
            ackMsg = [NSString stringWithFormat:@"%@%@", CT_REQUEST_FILE_CALENDARS_START_HEADER, [self.targetInfo valueForKey:@"Path"]];
        }
        NSData *requestData = [ackMsg dataUsingEncoding:NSUTF8StringEncoding];
        
        self.currentStat = RECEIVE_CALENDAR_FILE;
        [self sendRequestToSender:requestData];
        
    } else if (self.fileListManager.fileList && self.fileListManager.fileList.reminderSelected && !self.fileListManager.reminderStarted) { // receive reminder
        self.lastIsDuplicatePhotoFile = NO;
        self.lastIsDuplicateVideoFile = NO;
        self.reminderReceived = @"true";
        
        self.fileListManager.reminderStarted = YES;
        
        if ([CTUserDefaults sharedInstance].hasReminderPermissionError) {
            [self didCompleteReceiveFile];
            
            return;
        }
        
        self.dataSizeSection = 0;
        
        // request
        NSString *ackMsg = [NSString stringWithFormat:CT_REQUEST_FILE_REMINDER_HEADER];
        NSData *requestData = [ackMsg dataUsingEncoding:NSUTF8StringEncoding];
        
        self.currentStat = RECEVIE_REMINDER_FILE;
        [self sendRequestToSender:requestData];
    } else if (self.fileListManager.fileList && self.fileListManager.fileList.photoSelected && ((NSArray *)[userDefault valueForKey:@"photoFilteredFileList"]).count > 0 && !self.fileListManager.photoStarted) { // receive photos
        
        self.photoReceived = @"true";
        self.fileListManager.photoStarted = YES;
        
        if ([CTUserDefaults sharedInstance].hasPhotoPermissionError) {
            [self didCompleteReceiveFile];
            
            return;
        }
        
        self.dataSizeSection = 0;
        
        self.currentStat = RECEIVE_PHOTO_FILE;
        
        self.targetFileList = [userDefault valueForKey:@"photoFilteredFileList"];
        
        self.targetFileListIdx = 0; // 0 index init
        self.targetInfo = [self.targetFileList objectAtIndex:self.targetFileListIdx];
        
        // Check local duplicate file for current photo
        NSString *fileName = @"";
        if ([[CTUserDevice userDevice].phoneCombination isEqualToString:IOS_Andriod]) { // is cross platform
            fileName = [[self.targetInfo objectForKey:@"Path"] stringByReplacingOccurrencesOfString:@"/" withString:@"_"];
        } else {
            fileName = [self.targetInfo objectForKey:@"Path"];
        }
        
        NSString *ackMsg = @"";
        if (![self checkDuplicateForFile:fileName MediaType:@"photo"]) { // Not duplicate file
            // request
            self.lastIsDuplicatePhotoFile = NO;
            
            NSString *requestHeader = nil;
            if ([[self.targetInfo valueForKey:@"isLivePhoto"] boolValue]) {
                requestHeader = CT_REQUEST_FILE_LIVEPHOTO_HEADER;
            } else {
                requestHeader = CT_REQUEST_FILE_PHOTO_HEADER;
            }
            
            if ([[CTUserDevice userDevice].pairingType isEqualToString:kP2P]) {
                ackMsg = [NSString stringWithFormat:@"%@%@", requestHeader, [[self.targetInfo valueForKey:@"Path"] encodeStringTo64]];
            } else {
                ackMsg = [NSString stringWithFormat:@"%@%@", requestHeader, [self.targetInfo valueForKey:@"Path"]];
            }
            
            NSData *requestData = [ackMsg dataUsingEncoding:NSUTF8StringEncoding];
            [self sendRequestToSender:requestData];
        } else {
            self.lastIsDuplicatePhotoFile = YES;
            
            long long size = [[self.targetInfo valueForKey:@"Size"] longLongValue];
            ackMsg = [NSString stringWithFormat:@"%@%@", CT_REQUEST_FILE_PHOTO_HEADER, [[NSString stringWithFormat:@"DUPLICATE_%lld", size] encodeStringTo64]];
            
            NSData *requestData = [ackMsg dataUsingEncoding:NSUTF8StringEncoding];
            [self sendRequestToSender:requestData];
            
            self.dataSizeSection += size;
            self.totalSizeReceived += size;
            self.numberOfPhotosStartReceiving ++;
            self.storeHelper.tempPhotoSavedCount ++;
            self.localDuplicateCount++;
            
            NSLog(@"photo saved count:%ld of %ld", (long)self.storeHelper.tempPhotoSavedCount, (long)self.storeHelper.totalNumberOfPhotos);
            NSLog(@"current photo idx:%ld of %lu", (long)self.targetFileListIdx+1, (unsigned long)self.targetFileList.count);
            
            // Update the dummy data for duplicate
            [self.delegate receiverShouldUpdateInfo:YES packageSize:size];
        }
    } else if (self.fileListManager.fileList && self.fileListManager.fileList.videoSelected && !self.fileListManager.videoStarted && ((NSArray *)[userDefault valueForKey:@"videoFilteredFileList"]).count > 0) {
        self.lastIsDuplicateVideoFile = NO;
        self.videoReceived = @"true";
        
        self.fileListManager.videoStarted = YES;
        
        if ([CTUserDefaults sharedInstance].hasPhotoPermissionError) {
            [self didCompleteReceiveFile];
            
            return;
        }
        
        self.dataSizeSection = 0;
        
        self.currentStat = RECEIVE_VIDEO_FILE;
        
        self.targetFileList = [userDefault valueForKey:@"videoFilteredFileList"];
        
        self.targetFileListIdx = 0;
        self.targetInfo = [self.targetFileList objectAtIndex:self.targetFileListIdx];
        
        // Check local duplicate file for current photo
        NSString *fileName = @"";
        if ([[CTUserDevice userDevice].phoneCombination isEqualToString:IOS_Andriod]) { // is cross platform
            fileName = [[self.targetInfo objectForKey:@"Path"] stringByReplacingOccurrencesOfString:@"/" withString:@"_"];
        } else {
            fileName = [self.targetInfo objectForKey:@"Path"];
        }
        
        NSString *ackMsg = @"";
        if (![self checkDuplicateForFile:fileName MediaType:@"video"]) { // Not duplicate file
            // request
            self.lastIsDuplicateVideoFile = NO;
            if ([[CTUserDevice userDevice].pairingType isEqualToString:kP2P]) {
                ackMsg = [NSString stringWithFormat:@"%@%@", CT_REQUEST_FILE_VIDEO_HEADER, [[self.targetInfo valueForKey:@"Path"] encodeStringTo64]];
            } else {
                ackMsg = [NSString stringWithFormat:@"%@%@", CT_REQUEST_FILE_VIDEO_HEADER, [self.targetInfo valueForKey:@"Path"]];
            }
            
            NSData *requestData = [ackMsg dataUsingEncoding:NSUTF8StringEncoding];
            [self sendRequestToSender:requestData];
        } else {
            self.lastIsDuplicateVideoFile = YES;
            long long size = [[self.targetInfo valueForKey:@"Size"] longLongValue];
            ackMsg = [NSString stringWithFormat:@"%@%@", CT_REQUEST_FILE_VIDEO_HEADER, [[NSString stringWithFormat:@"DUPLICATE_%lld", size] encodeStringTo64]];
            
            NSData *requestData = [ackMsg dataUsingEncoding:NSUTF8StringEncoding];
            [self sendRequestToSender:requestData];
            
            self.dataSizeSection += size;
            self.totalSizeReceived += size;
            self.numberOfVideosStartReceiving ++;
            self.storeHelper.tempVideoSavedCount ++;
            self.localDuplicateCount++;
            
            // Update the dummy data for duplicate
            [self.delegate receiverShouldUpdateInfo:YES packageSize:size];
        }
    } else if (self.fileListManager.fileList && self.fileListManager.fileList.appListSelected && !self.fileListManager.appListStarted && ((NSArray *)[userDefault valueForKey:@"appsFileList"]).count > 0) { // Request apps
        self.appsReceived = @"true";
        self.fileListManager.appListStarted = YES;
        
        self.dataSizeSection = 0;
        
        self.targetFileList = (NSArray *)[userDefault valueForKey:@"appsFileList"];
        self.numberOfApps = self.targetFileList.count;
        
        self.targetFileListIdx = 0; // 0 index init
        
        self.targetInfo = [self.targetFileList objectAtIndex:self.targetFileListIdx];
        
        DebugLog(@"Apps info:\n%@", self.targetInfo);
        
        // create response
        NSString *ackMsg = [NSString stringWithFormat:@"VZCONTENTTRANSFER_REQUEST_FOR_APPS_%@", [[self.targetInfo valueForKey:@"Path"] encodeStringTo64]];
        NSData *requestData = [ackMsg dataUsingEncoding:NSUTF8StringEncoding];
        
        self.currentStat = RECEIVE_APP_LIST_FILE;
        [self sendRequestToSender:requestData];
    }  else {
        [self dataTransferWillFinish];
    }
}
/*!
    @brief This method will track the calendar transfer process.
           Method will go through all the calendar file from file list and when all done, move to next transfer status.
    @see didCompleteReceiveFile
 */
- (void)didFinishReceivedCalendarFile {
    self.lastIsDuplicatePhotoFile = NO;
    self.lastIsDuplicateVideoFile = NO;
    ++ self.targetFileListIdx;
    
    if (self.targetFileListIdx == self.targetFileList.count) {
        [self didCompleteReceiveFile];
    } else {
        self.targetInfo = [self.targetFileList objectAtIndex:self.targetFileListIdx];
        DebugLog(@"Calendar info:\n%@",self.targetInfo);

        // send request
        NSString *ackMsg = nil;
        if ([[CTUserDevice userDevice].phoneCombination isEqualToString:IOS_Andriod]) {
            ackMsg = [NSString stringWithFormat:@"%@%@", CT_REQUEST_FILE_CALENDARS_HEADER, [self.targetInfo valueForKey:@"Path"]];
        } else if (self.targetFileListIdx == self.targetFileList.count - 1) { // last one
            ackMsg = [NSString stringWithFormat:@"%@%@", CT_REQUEST_FILE_CALENDARS_FINAL_HEADER, [self.targetInfo valueForKey:@"Path"]];
        } else {
            ackMsg = [NSString stringWithFormat:@"%@%@", CT_REQUEST_FILE_CALENDARS_ORIGIN_HEADER, [self.targetInfo valueForKey:@"Path"]];
        }
        
        NSData *requestData = [ackMsg dataUsingEncoding:NSUTF8StringEncoding];
        [self sendRequestToSender:requestData];
    }
}
/*!
    @brief This method will track the app icon files in app list transfer process.
           Method will go through all the icon files from file list and when all done, move to next transfer status.
    @see didCompleteReceiveFile
 */
- (void)didFinishReceivedAppFile {
    ++ self.targetFileListIdx;
    
    if (self.targetFileListIdx == self.targetFileList.count) {
        [self didCompleteReceiveFile];
    } else {
        self.targetInfo = [self.targetFileList objectAtIndex:self.targetFileListIdx];
        DebugLog(@"App info:\n%@",self.targetInfo);
        
        // send request
        NSString *ackMsg = [NSString stringWithFormat:@"VZCONTENTTRANSFER_REQUEST_FOR_APPS_%@", [[self.targetInfo valueForKey:@"Path"] encodeStringTo64]];
        NSData *requestData = [ackMsg dataUsingEncoding:NSUTF8StringEncoding];
        
        [self sendRequestToSender:requestData];
    }
}
/*!
    @brief This method will track the photo transfer process.
           Method will go through all the photo files from file list and when all done, move to next transfer status.
    @see didCompleteReceiveFile
 */
- (void)didFinishReceivedPhotoFile {
    ++ self.targetFileListIdx;
    if (self.targetFileListIdx == [self.targetFileList count]) { // no more photos
        [self didCompleteReceiveFile];
    } else {
        
        self.targetInfo = [self.targetFileList objectAtIndex:self.targetFileListIdx];
        
        // Check local duplicate file for current photo
        NSString *fileName = @"";
        if ([[CTUserDevice userDevice].phoneCombination isEqualToString:IOS_Andriod]) { // is cross platform
            fileName = [[self.targetInfo objectForKey:@"Path"] stringByReplacingOccurrencesOfString:@"/" withString:@"_"];
        } else {
            fileName = [self.targetInfo objectForKey:@"Path"];
        }
        
        // request
        NSString *ackMsg = @"";
        if (![self checkDuplicateForFile:fileName MediaType:@"photo"]) { // Not duplicate file
            // request
            self.lastIsDuplicatePhotoFile = NO;
            
            NSString *requestHeader = nil;
            if ([[self.targetInfo valueForKey:@"isLivePhoto"] boolValue]) {
                requestHeader = CT_REQUEST_FILE_LIVEPHOTO_HEADER;
            } else {
                requestHeader = CT_REQUEST_FILE_PHOTO_HEADER;
            }
            
            if ([[CTUserDevice userDevice].pairingType isEqualToString:kP2P]) {
                ackMsg = [NSString stringWithFormat:@"%@%@", requestHeader, [[self.targetInfo valueForKey:@"Path"] encodeStringTo64]];
            } else {
                ackMsg = [NSString stringWithFormat:@"%@%@", requestHeader, [self.targetInfo valueForKey:@"Path"]];
            }
            
            NSData *requestData = [ackMsg dataUsingEncoding:NSUTF8StringEncoding];
            [self sendRequestToSender:requestData];
        } else {
            self.lastIsDuplicatePhotoFile = YES;
            long long size = [[self.targetInfo valueForKey:@"Size"] longLongValue];
            ackMsg = [NSString stringWithFormat:@"%@%@", CT_REQUEST_FILE_PHOTO_HEADER, [[NSString stringWithFormat:@"DUPLICATE_%lld", size] encodeStringTo64]];
            
            NSData *requestData = [ackMsg dataUsingEncoding:NSUTF8StringEncoding];
            [self sendRequestToSender:requestData];
            
            self.dataSizeSection += size;
            self.totalSizeReceived += size;
            self.numberOfPhotosStartReceiving ++;
            self.storeHelper.tempPhotoSavedCount ++;
            self.localDuplicateCount++;
            
            NSLog(@"photo saved count:%ld of %ld", (long)self.storeHelper.tempPhotoSavedCount, (long)self.storeHelper.totalNumberOfPhotos);
            NSLog(@"current photo idx:%ld of %lu", (long)(self.targetFileListIdx+1), (unsigned long)self.targetFileList.count);
            
            // Update the dummy data for duplicate
            [self.delegate receiverShouldUpdateInfo:YES packageSize:size];
        }
    }
}
/*!
    @brief This method will track the video transfer process.
           Method will go through all the video files from file list and when all done, move to next transfer status.
    @see didCompleteReceiveFile
 */
- (void)didFinishReceivedVideoFile {
    ++ self.targetFileListIdx;
    if (self.targetFileListIdx == self.targetFileList.count) { // last video
        [self didCompleteReceiveFile];
    } else {
        self.targetInfo = [self.targetFileList objectAtIndex:self.targetFileListIdx];
        
        // Check local duplicate file for current photo
        NSString *fileName = @"";
        if ([[CTUserDevice userDevice].phoneCombination isEqualToString:IOS_Andriod]) { // is cross platform
            fileName = [[self.targetInfo objectForKey:@"Path"] stringByReplacingOccurrencesOfString:@"/" withString:@"_"];
        } else {
            fileName = [self.targetInfo objectForKey:@"Path"];
        }
        
        NSString *ackMsg = @"";
        if (![self checkDuplicateForFile:fileName MediaType:@"video"]) { // Not duplicate file
            // request
            self.lastIsDuplicateVideoFile = NO;
            if ([[CTUserDevice userDevice].pairingType isEqualToString:kP2P]) {
                ackMsg = [NSString stringWithFormat:@"%@%@", CT_REQUEST_FILE_VIDEO_HEADER, [[self.targetInfo valueForKey:@"Path"] encodeStringTo64]];
            } else {
                ackMsg = [NSString stringWithFormat:@"%@%@", CT_REQUEST_FILE_VIDEO_HEADER, [self.targetInfo valueForKey:@"Path"]];
            }
            
            NSData *requestData = [ackMsg dataUsingEncoding:NSUTF8StringEncoding];
            [self sendRequestToSender:requestData];
        } else {
            self.lastIsDuplicateVideoFile = YES;
            long long size = [[self.targetInfo valueForKey:@"Size"] longLongValue];
            ackMsg = [NSString stringWithFormat:@"%@%@", CT_REQUEST_FILE_VIDEO_HEADER, [[NSString stringWithFormat:@"DUPLICATE_%lld", size] encodeStringTo64]];
            
            NSData *requestData = [ackMsg dataUsingEncoding:NSUTF8StringEncoding];
            [self sendRequestToSender:requestData];
            
            self.dataSizeSection += size;
            self.totalSizeReceived += size;
            self.numberOfVideosStartReceiving ++;
            self.storeHelper.tempVideoSavedCount ++;
            self.localDuplicateCount++;
            
            // Update the dummy data for duplicate
            [self.delegate receiverShouldUpdateInfo:YES packageSize:size];
        }
    }
}
/*! 
    @brief Transfer will finish.
 */
- (void)dataTransferWillFinish {
    DebugLog(@"->Transfer finished!");
    
    [self.delegate transferDidFinished:YES];
    [self transferShouldCheckStoreStatus];
}

#pragma mark - Media Store Helper Delegate
- (void)transferShouldPassPhoto {
    self.photosSaved = YES;
    [self transferShouldCheckStoreStatus];
}

- (void)transferShouldPassVideo {
    self.videosSaved = YES;
    [self transferShouldCheckStoreStatus];
}

#pragma mark - Handshake Methods
/*!
    @brief Try to send data to sender side. Method will choose proper way based on the connection type.
    @param data NSData value represents the data that needs to be sent.
 */
- (void)sendRequestToSender:(NSData *)data {
    if ([[CTUserDevice userDevice].pairingType isEqualToString:kP2P]) {
        [self.delegate writeDataToTheSocket:data];
    } else {
        [[CTBonjourManager sharedInstance] sendFileStream:data];
    }
}
/*!
    @brief When video receiving filled up all the package, then send back request for next video trunk.
           This is part of logic to avoid memory issue when transferring large size(GB) of file.
 */
- (void)requestForNextVideoChuck {
    NSString *shareKey = [[NSString alloc] initWithFormat:@"VZCONTENTTRANSFER_REQUEST_FOR_VPART_"];
    NSData *requestData = [shareKey dataUsingEncoding:NSUTF8StringEncoding];
    [self sendRequestToSender:requestData];
}
/*!
    @brief Try to send insufficent storage message to other side. Since new logic for storage check, this method should never be called.
 */
- (void)sendInSufficentStorageMsgToSender {
    NSData *requestData = [CT_REQUEST_FILE_NOT_ENOUGH_STORAGE dataUsingEncoding:NSUTF8StringEncoding];
    [self sendRequestToSender:requestData];
}

#pragma mark - Cancellation
- (void)notifyProcessCancelled {
    [self checkCancelConditions];
    [self transferShouldCheckStoreStatus];
    if (!self.photosSaved) {
        [self.storeHelper transferDidCancelledPhoto];
    }
    if (!self.videosSaved) {
        [self.storeHelper transferDidCancelledVideo];
    }
}

- (void)checkCancelConditions {
    if (!self.contactsSaved) {
        self.contactsSaved = YES;
        self.contactsReceived = @"false";
    }
    
    if (!self.remindersSaved) {
        self.remindersSaved = YES;
        self.reminderReceived = @"false";
    }
    
    if (!self.calendarsSaved) {
        self.calendarsSaved = YES;
        self.calendarReceived = @"false";
    }
    
    if (!self.appsSaved) {
        self.appsSaved = YES;
        self.appsReceived = @"false";
    }
    
    if (!self.photosSaved) {
        if (![self.photoReceived isEqualToString:@"true"]) {
            self.photosSaved = YES;
        }
    }
    
    if (!self.videosSaved) {
        if (![self.videoReceived isEqualToString:@"true"]) {
            self.videosSaved = YES;
        }
    }
}

#pragma mark - Reconnect Logic
- (void)createReconnectRequestHeader {
    switch (self.currentStat) {
        case RECEIVE_PHOTO_FILE: {
            if (self.fileSize != 0) { // complete current photo file
                self.totalSizeReceived -= self.receivedData.length;
                if (self.numberOfPhotosStartReceiving > 0 && ![self isReceivingLivePhotoVideoComponent]) {
                    // Only reduce the receiving number for static photo transfer (live photo static image part).
                    self.numberOfPhotosStartReceiving --;
                }
            }
            
            if (self.lastIsDuplicatePhotoFile) { // if last file was duplicate file, just resend the same request with the duplicate number
                self.targetInfo = [self.targetFileList objectAtIndex:self.targetFileListIdx];
                long long size = [[self.targetInfo valueForKey:@"Size"] longLongValue];
                NSString *ackMsg = [NSString stringWithFormat:@"%@%lld_%ld", CT_REQUEST_FILE_RECONNECT_PHOTO_DUPLICATE_HEADER, size, (long)self.localDuplicateCount];
                
                NSData *requestData = [ackMsg dataUsingEncoding:NSUTF8StringEncoding];
                [self sendRequestToSender:requestData];
                
                NSLog(@"photo saved count:%ld of %ld", (long)self.storeHelper.tempPhotoSavedCount, (long)self.storeHelper.totalNumberOfPhotos);
                NSLog(@"current photo idx:%ld of %lu", (long)(self.targetFileListIdx+1), (unsigned long)self.targetFileList.count);
            } else { // it is normal file
                if (self.targetFileListIdx == [self.targetFileList count]) { // no more photos
                    [self didCompleteReceiveFile];
                } else {
                    if ([self isReceivingLivePhotoVideoComponent]) {
                        // If it's video component of live photo
                        NSString *ackMsg = [NSString stringWithFormat:@"%@", CT_REQUEST_FILE_RECONNECT_LIVEPHOTO_VHEADER];
                        NSData *requestData = [ackMsg dataUsingEncoding:NSUTF8StringEncoding];
                        [self sendRequestToSender:requestData];
                        // Reset properties
                        self.fileStartFound = NO;
                        self.fileSize = 0;
                        self.receivedData = nil;
                    } else {
                        // If it's static image (live photo static image part)
                        self.targetInfo = [self.targetFileList objectAtIndex:self.targetFileListIdx];
                        
                        NSString * ackMsg = nil;
                        if ([[self.targetInfo valueForKey:@"isLivePhoto"] boolValue]) {
                            // It's live photo
                            ackMsg = [NSString stringWithFormat:@"%@%@", CT_REQUEST_FILE_RECONNECT_LIVEPHOTO_PHEADER, [self.targetInfo valueForKey:@"Path"]];
                        } else {
                            // It's not live photo
                            ackMsg = [NSString stringWithFormat:@"%@%@", CT_REQUEST_FILE_RECONNECT_PHOTO_HEADER, [self.targetInfo valueForKey:@"Path"]];
                        }
                        
                        NSData *requestData = [ackMsg dataUsingEncoding:NSUTF8StringEncoding];
                        [self sendRequestToSender:requestData];
                        
                        self.fileStartFound = NO;
                        self.fileSize = 0;
                        self.receivedData = nil;
                    }
                }
            }
        }
            break;
            
        case RECEIVE_VIDEO_FILE: {
            if (self.fileSize != 0) { // incomplete current video file
                self.totalSizeReceived -= self.tillNowReceived;
                if (self.numberOfVideosStartReceiving > 0) {
                    self.numberOfVideosStartReceiving --;
                }
            }
            
            if (self.lastIsDuplicateVideoFile) { // if last file was duplicate file, just resend the same request with the duplicate number
                self.targetInfo = [self.targetFileList objectAtIndex:self.targetFileListIdx];
                long long size = [[self.targetInfo valueForKey:@"Size"] longLongValue];
                NSString *ackMsg = [NSString stringWithFormat:@"%@%lld_%ld", CT_REQUEST_FILE_RECONNECT_VIDEO_DUPLICATE_HEADER, size, (long)self.localDuplicateCount];
                
                NSData *requestData = [ackMsg dataUsingEncoding:NSUTF8StringEncoding];
                [self sendRequestToSender:requestData];
                
                NSLog(@"photo saved count:%ld of %ld", (long)self.storeHelper.tempPhotoSavedCount, (long)self.storeHelper.totalNumberOfPhotos);
                NSLog(@"current photo idx:%ld of %lu", (long)(self.targetFileListIdx+1), (unsigned long)self.targetFileList.count);
            } else { // it is normal file
                if (self.targetFileListIdx == self.targetFileList.count) { // last video
                    [self didCompleteReceiveFile];
                } else {
                    self.targetInfo = [self.targetFileList objectAtIndex:self.targetFileListIdx];
                    NSString *ackMsg = [NSString stringWithFormat:@"%@%@", CT_REQUEST_FILE_RECONNECT_VIDEO_HEADER, [self.targetInfo valueForKey:@"Path"]];
                    
                    NSData *requestData = [ackMsg dataUsingEncoding:NSUTF8StringEncoding];
                    [self sendRequestToSender:requestData];
                    
                    self.fileStartFound = NO;
                    self.fileSize = 0;
                }
            }
        }
            break;
            
        default:
            break;
    }
}

@end
