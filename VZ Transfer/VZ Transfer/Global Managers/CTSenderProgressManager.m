//
//  CTSenderProgressManager.m
//  contenttransfer
//
//  Created by Hadapad, Prakash on 9/8/16.
//  Copyright © 2016 Verizon Wireless. All rights reserved.
//

#import <Photos/Photos.h>
#import <AssetsLibrary/AssetsLibrary.h>

#import "CTSenderProgressManager.h"
#import "NSString+CTMVMConvenience.h"
#import "CTDeviceMarco.h"
#import "NSString+CTRootDocument.h"

#import "CTUserDevice.h"
#import "CTBonjourManager.h"
#import "CTFileManager.h"
#import "CTPhotosManager.h"
#import "CTCommPortClientSocket.h"
#import "CTAVFileTypeGenerator.h"

/*! 
    @brief Duplicate enumeration. 
    @discussion For now, only three type of transfer will have file level duplicate logic, other types' duplicate will happen during the saving progress.
 */
typedef NS_ENUM(NSUInteger, CTDuplicateType) {
    /*! Duplicate type for photo transfer.*/
    CTPhotoDuplicate,
    /*! Duplicate type for video transfer.*/
    CTVideoDuplicate,
    /*! Duplicate type for audio transfer.*/
    CTAudioDuplicate
};

@interface CTSenderProgressManager () <CTSenderP2PManagerDelegate, CTSenderBonjourManagerDelegate>

@property (nonatomic, strong) CTFileList *fileList;

@property (nonatomic, strong) CTPhotosManager *photoManager;
@property (nonatomic, strong) CTPhotosManager *videoManager;

/*! Total count of file transferred.*/
@property (nonatomic, assign) NSInteger totalFileTransferred;
@property (nonatomic, assign) NSInteger localDuplicateCount;
/*! Current file number of current section.*/
@property (nonatomic, assign) NSInteger tartgetFileCount;
/*! Total data size for current section.*/
@property (nonatomic, assign) long long totalDataSent;
/*! Total data size of all transfer. This is the value using to update the UI.*/
@property (nonatomic, assign) long long totalDataSentProcess;
/*! Size for duplicate files*/
@property (nonatomic, assign) long long totalDuplicatedDataSent;

@property (nonatomic, assign) BOOL isXPlatform;
@property (nonatomic, assign) BOOL contactSent;
@property (nonatomic, assign) BOOL reminderSent;
@property (nonatomic, assign) BOOL videoComponentStartSending;
/*! Current media type for transfer.*/
@property (nonatomic, strong) NSString *targetMediaType;

@property (nonatomic, strong) NSString *currentMediaID;

@end

@implementation CTSenderProgressManager

@synthesize totalDataSent;
@synthesize totalDataSentProcess;

- (instancetype)initWithFileList:(CTFileList *)fileList andSocket:(GCDAsyncSocket *)socket commSocket:(CTCommPortClientSocket *)commSocket andPhotoManager:(CTPhotosManager *)photoManager andVideoManager:(CTPhotosManager *)videoManager andDelegate:(id<CTSenderProgressManagerDelegate>)delegate {
    self = [super init];
    if (self) {
        _fileList = fileList;
        _photoManager = photoManager;
        _videoManager = videoManager;
        _receiverProgressManagerDelegate = delegate;
        _isXPlatform = [[CTUserDevice userDevice].phoneCombination isEqualToString:IOS_Andriod];
        [self prepareDataInterruptedList:fileList.selectItemList];
        
        self.pairing_Type = [CTUserDevice userDevice].pairingType;
        if ([self.pairing_Type isEqualToString:kP2P]) { // it's P2P
            [self setreadAsyncSocket:socket andCommSocket:commSocket];
        } else { // it's Bonjour, change the delegate
            self.bonjourManager = [[CTSenderBonjourManager alloc] initWithDelegate:self];
        }
    }
    
    return self;
}

/*!
    @brief Init a transfer item list for sender side.
    @discussion The list will contain total selected number, successfully tranfserred number for each of the data type selected.
    
                The list will be saved in global property.
    @param allFileList select item list for metadata.
 
    @see dataInterruptedList
 */
- (void)prepareDataInterruptedList:(NSDictionary *)itemList {
    
//    NSDictionary *itemList = [allFileList objectForKey:@"itemList"];
    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    
    if ([itemList objectForKey:METADATA_ITEMLIST_KEY_CONTACTS]) {
        NSDictionary *eachDataType = (NSDictionary*)[itemList objectForKey:METADATA_ITEMLIST_KEY_CONTACTS];
        NSMutableDictionary *tempDict = [NSMutableDictionary new];
        BOOL status = [[eachDataType objectForKey:@"status"] boolValue];
        if (status) {
            NSNumber *x = [eachDataType objectForKey:@"totalCount"];
            self.numberOfContacts = [x integerValue];
            [tempDict setObject:x forKey:@"totalSelected"];
            [tempDict setObject:@0 forKey:@"successTransferred"];
            [tempArray addObject:@{@"Contacts":tempDict}];
        }
    }
    
    if ([itemList objectForKey:METADATA_ITEMLIST_KEY_PHOTOS]) {
        NSDictionary *eachDataType = (NSDictionary*)[itemList objectForKey:METADATA_ITEMLIST_KEY_PHOTOS];
        NSMutableDictionary *tempDict = [NSMutableDictionary new];
        BOOL status = [[eachDataType objectForKey:@"status"] boolValue];
        if (status) {
            NSNumber *x = [eachDataType objectForKey:@"totalCount"];
            [tempDict setObject:x forKey:@"totalSelected"];
            [tempDict setObject:@0 forKey:@"successTransferred"];
            [tempArray addObject:@{@"Photos":tempDict}];
        }
    }
    
    if ([itemList objectForKey:METADATA_ITEMLIST_KEY_VIDEOS]) {
        NSDictionary *eachDataType = (NSDictionary*)[itemList objectForKey:METADATA_ITEMLIST_KEY_VIDEOS];
        NSMutableDictionary *tempDict = [NSMutableDictionary new];
        BOOL status = [[eachDataType objectForKey:@"status"] boolValue];
        if (status) {
            NSNumber *x = [eachDataType objectForKey:@"totalCount"];
            [tempDict setObject:x forKey:@"totalSelected"];
            [tempDict setObject:@0 forKey:@"successTransferred"];
            [tempArray addObject:@{@"Videos":tempDict}];
        }
    }
    
    if ([itemList objectForKey:METADATA_ITEMLIST_KEY_CALENDARS]) {
        NSDictionary *eachDataType = (NSDictionary*)[itemList objectForKey:METADATA_ITEMLIST_KEY_CALENDARS];
        NSMutableDictionary *tempDict = [NSMutableDictionary new];
        BOOL status = [[eachDataType objectForKey:@"status"] boolValue];
        if (status) {
            NSNumber *x = [eachDataType objectForKey:@"totalCount"];
            [tempDict setObject:x forKey:@"totalSelected"];
            [tempDict setObject:@0 forKey:@"successTransferred"];
            [tempArray addObject:@{@"Calendars":tempDict}];
        }
    }
    
    if ([itemList objectForKey:METADATA_ITEMLIST_KEY_REMINDERS]) {
        NSDictionary *eachDataType = (NSDictionary*)[itemList objectForKey:METADATA_ITEMLIST_KEY_REMINDERS];
        
        NSMutableDictionary *tempDict = [NSMutableDictionary new];
        
        BOOL status = [[eachDataType objectForKey:@"status"] boolValue];
        
        if (status) {
            
            NSNumber *x = [eachDataType objectForKey:@"totalCount"];
            
            [tempDict setObject:x forKey:@"totalSelected"];
            
            self.numberOfReminders = [x integerValue];
            
            [tempDict setObject:@0 forKey:@"successTransferred"];
            
            [tempArray addObject:@{@"Reminders":tempDict}];
        }
    }
    
    if ([itemList objectForKey:METADATA_ITEMLIST_KEY_AUDIOS]) {
        NSDictionary *eachDataType = (NSDictionary*)[itemList objectForKey:METADATA_ITEMLIST_KEY_AUDIOS];
        
        NSMutableDictionary *tempDict = [NSMutableDictionary new];
        BOOL status = [[eachDataType objectForKey:@"status"] boolValue];
        if (status) {
            NSNumber *x = [eachDataType objectForKey:@"totalCount"];
            [tempDict setObject:x forKey:@"totalSelected"];
            [tempDict setObject:@0 forKey:@"successTransferred"];
            [tempArray addObject:@{@"Audios":tempDict}];
        }
    }
    
    self.dataInterruptedList = tempArray;
}

- (void)updateDataInterruptedList {
    
    [self.dataInterruptedList enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        NSDictionary *eachDict = (NSDictionary*)obj;
        [eachDict enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            NSDictionary *tempDict = (NSDictionary*)obj;

            if ([key isEqualToString:@"Photos"]) {
                [tempDict setValue:[NSNumber numberWithInteger:self.numberOfPhotoSuccess] forKey:@"successTransferred"];
            } else if ([key isEqualToString:@"Videos"]){
                [tempDict setValue:[NSNumber numberWithInteger:self.numberOfVideos] forKey:@"successTransferred"];
            } else if ([key isEqualToString:@"Contacts"] && self.contactSent){
                [tempDict setValue:[NSNumber numberWithInteger:self.numberOfContacts] forKey:@"successTransferred"];
            } else if ([key isEqualToString:@"Calendars"]){
                [tempDict setValue:[NSNumber numberWithInteger:self.numberOfCalendars] forKey:@"successTransferred"];
            } else if ([key isEqualToString:@"Reminders"] && self.reminderSent){
                [tempDict setValue:[NSNumber numberWithInteger:self.numberOfReminders] forKey:@"successTransferred"];
            } else if ([key isEqualToString:@"Audios"]){
                [tempDict setValue:[NSNumber numberWithInteger:self.numberOfAudioSuccess] forKey:@"successTransferred"];
            }
        }];
        
    }];
    
    DebugLog(@"%@",self.dataInterruptedList);
}

- (void)setreadAsyncSocket:(GCDAsyncSocket *)socket andCommSocket:(CTCommPortClientSocket *)commSocket{
    
    self.p2pManager = [[CTSenderP2PManager alloc] init];
    self.p2pManager.p2pManagerDelegate = self;
    [self.p2pManager setsocketDelegate:socket commSocket:commSocket];
}

#pragma mark - Common Delegate Methods
- (NSData *)getAllFileListToBeSend {
    
//    NSData *fileListData = [self createFileListData:self.fileList];
    NSData *fileListData = [self.fileList createFileListData];
    
    if ([self.pairing_Type isEqualToString:kP2P]) {
        [self writePairingInformationToCommPort]; // create Comm port related data
    }
    return fileListData;
}

#pragma mark - CTSenderP2PManagerDelegate method
- (void)identifyReceviedP2pRequest:(NSString *)requestString shouldStoreIncompleteHandler:(void (^)(NSUInteger))handler {
    [self getStateFromRequestString:requestString shouldStoreIncompleteHandler:handler];
}

- (void)senderAudioFileTransferDidFailed:(long long)fileSize {
    self.numberOfAudioSuccess -= 1;        // Remove one success count for audio.
    self.totalFailureSize     += fileSize; // Add on failed size.
    NSLog(@"Audio failed. Removed one success count. Successfully audio transfer count:%ld. Failed size:%lld", (long)self.numberOfAudioSuccess, self.totalFailureSize);
}

- (void)senderPhotoFileTransferDidFailed:(long long)fileSize {
    self.numberOfPhotoSuccess -= 1;        // Remove one success count for photo.
    self.totalFailureSize     += fileSize; // Add on failed size.
    NSLog(@"Photo file failed. Removed one success count. Successfully photo transfer count:%ld. Failed size:%lld", (long)self.numberOfPhotoSuccess, self.totalFailureSize);
}

#pragma mark - Bonjour Sender Delegate
// Added by Xin
- (void)identifyReceviedBonjourRequest:(NSString *)requestString shouldStoreIncompleteHandler:(void(^)(NSUInteger))handler  {
    [self getStateFromRequestString:requestString shouldStoreIncompleteHandler:handler];
}

- (void)transferWillInterrupted:(NSInteger)reason {
    self.transferStatusAnalytics = CTTransferStatus_Interrupted;
}

- (void)senderTransferShouldBlockForReconnect:(NSString *)warningText {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.receiverProgressManagerDelegate transferShouldBlockForReconnect:warningText];
    });
}

- (void)senderTransferShouldEnableForContiue:(BOOL)success {
    [self.receiverProgressManagerDelegate transferShouldEnableForContinue:success];
}

#pragma mark - Common Methods
/*!
    @brief Identify the request string and lead the transfer to the proper place.
    @param requestString String value that received from receiver side.
    @param handler Block that used to save the incomplete data.
 */
- (void)getStateFromRequestString:(NSString *)requestString shouldStoreIncompleteHandler:(void(^)(NSUInteger))handler {
    NSLog(@"->request:%@", requestString);
    
    self.oldState = self.nextState; // Restore last state before analysis the new requirement.
    self.nextState = [self identifyRequest:&requestString];
    switch (self.nextState) {
        case TRANSFER_VCARD_FILE : {
            self.videoComponentStartSending = NO;
            [self transferSelecteditem:TRANSFER_VCARD_FILE receivedData:requestString];
        }
            break;
            
        case TRANSFER_PHOTO_FILE : {
            self.videoComponentStartSending = NO;
            [self transferSelecteditem:TRANSFER_PHOTO_FILE receivedData:requestString];
        }
            break;
            
        case TRANSFER_LIVEPHOTO_FILE : {
            self.videoComponentStartSending = NO;
            [self transferSelecteditem:TRANSFER_LIVEPHOTO_FILE receivedData:requestString];
        }
            break;
            
        case TRANSFER_LIVEPHOTO_VIDEO_FILE : {
            self.videoComponentStartSending = NO;
            [self transferSelecteditem:TRANSFER_LIVEPHOTO_VIDEO_FILE receivedData:requestString];
        }
            break;
            
        case TRANSFER_VIDEO_FILE : {
            self.videoComponentStartSending = NO;
            [self transferSelecteditem:TRANSFER_VIDEO_FILE receivedData:requestString];
        }
            break;
            
        case TRANSFER_NEXT_VIDEO_PART : {
            self.videoComponentStartSending = NO;
            [self transferSelecteditem:TRANSFER_NEXT_VIDEO_PART receivedData:requestString];
        }
            break;
        case TRANSFER_REMINDER_LOG_FILE : {
            self.videoComponentStartSending = NO;
            [self transferSelecteditem:TRANSFER_REMINDER_LOG_FILE receivedData:requestString];
        }
            break;
            
        case TRANSFER_CALENDAR_FILE_START: {
            self.videoComponentStartSending = NO;
            [self transferSelecteditem:TRANSFER_CALENDAR_FILE_START receivedData:requestString];
        }
            break;
            
        case TRANSFER_CALENDAR_FILE: {
            self.videoComponentStartSending = NO;
            [self transferSelecteditem:TRANSFER_CALENDAR_FILE receivedData:requestString];
        }
            break;
            
        case TRANSFER_CALENDAR_FILE_END: {
            self.videoComponentStartSending = NO;
            [self transferSelecteditem:TRANSFER_CALENDAR_FILE_END receivedData:requestString];
        }
            break;
            
        case TRANSFER_AUDIO_FILE: {
            self.videoComponentStartSending = NO;
            [self transferSelecteditem:TRANSFER_AUDIO_FILE receivedData:requestString];
        }
            break;
            
        case TRANSFER_NO_ENOUGH_STORAGE: {
            self.videoComponentStartSending = NO;
            self.transferStatusAnalytics = CTTransferStatus_Insufficient_Storage;

            [self transferShouldGoToNotEnoughStorage];
        }
            break;
            
        case TRANSFER_COMPLETED: {
            self.videoComponentStartSending = NO;
            self.transferStatusAnalytics = CTTransferStatus_Success;
            if ([[CTUserDevice userDevice].pairingType isEqualToString:kBonjour]) {
                self.bonjourManager.transferFinished = YES;
                [[CTBonjourManager sharedInstance] closeStreams];
            } else {
                [self.p2pManager cleanUpAllSocketConnection];
            }
            [self updateDataInterruptedList];
            [self transferDidFinished];
        }
            break;
            
        case TRANSFER_CANCEL: {
            self.videoComponentStartSending = NO;
            self.transferStatusAnalytics = CTTransferStatus_Cancelled;

            [self updateDataInterruptedList];
            if ([[CTUserDevice userDevice].pairingType isEqualToString:kBonjour]) {
                [self.bonjourManager shouldStopTimeoutTimer];
                [[CTBonjourManager sharedInstance] closeStreams];
            } else {
                self.p2pManager.transferFinished = YES;
            }
            [self.receiverProgressManagerDelegate transferDidCancelled];
        }
            break;
            
        case TRASNFER_FILE_DUPLICATE: {
            self.videoComponentStartSending = NO;
            DebugLog(@"receive the duplicate request");
            NSData *responseData = [CT_SEND_FILE_DUPLICATE_RECEIVED dataUsingEncoding:NSUTF8StringEncoding];
            if ([[CTUserDevice userDevice].pairingType isEqualToString:kP2P]) { // P2P NEED TO SEND BACK RESPONSE
                [self.p2pManager writeDataToSocket:responseData];
            } else if ([[CTUserDevice userDevice].pairingType isEqualToString:kBonjour]) { // BONJOUR NEED TO SEND BACK THE RESPONSE
                [self.bonjourManager requestSendingFileListPackage:responseData];
                _localDuplicateCount ++; // Once we received duplicate from receiver side, add one.(This is only valid for Bonjour reconnect)
                NSLog(@"local duplicate number:%ld", (long)_localDuplicateCount);
            }
        }
            break;
            
        case TRANSFER_RECONNECT_VIDEO: { // Only for Bonjour
            self.videoComponentStartSending = NO;
            DebugLog(@"Sender received reconnect request, should continue video transfer process.");
            [self transferSelecteditem:TRANSFER_RECONNECT_VIDEO receivedData:requestString];
        }
            break;
            
        case TRANSFER_RECONNECT_PHOTO: { // Only for Bonjour
            self.videoComponentStartSending = NO;
            DebugLog(@"Sender received reconnect request, should continue photo transfer process.");
            [self transferSelecteditem:TRANSFER_RECONNECT_PHOTO receivedData:requestString];
        }
            break;
            
        case TRANSFER_RECONNECT_LIVE_PHOTO: { // Only for Bonjour
            self.videoComponentStartSending = NO;
            DebugLog(@"Sender received reconnect request, should continue live photo transfer process.");
            [self transferSelecteditem:TRANSFER_RECONNECT_LIVE_PHOTO receivedData:requestString];
        }
            break;
            
        case TRANSFER_RECONNECT_LIVE_PHOTO_VIDEO_COMPO: { // Only for Bonjour
            DebugLog(@"Sender received reconnect request, should continue live photo video component transfer process.");
            [self transferSelecteditem:TRANSFER_RECONNECT_LIVE_PHOTO_VIDEO_COMPO receivedData:requestString];
        }
            break;
            
        case TRANSFER_RECONNECT_DUPLICATE_PHOTO: { // Reconnect for duplicate photo for Bonjour
            self.videoComponentStartSending = NO;
            [self transferSelecteditem:TRANSFER_RECONNECT_DUPLICATE_PHOTO receivedData:requestString];
        }
            break;
            
        case TRANSFER_RECONNECT_DUPLICATE_VIDEO: { // Reconnect for duplicate photo for Bonjour
            self.videoComponentStartSending = NO;
            [self transferSelecteditem:TRANSFER_RECONNECT_DUPLICATE_VIDEO receivedData:requestString];
        }
            break;
           
        default: {
            // store the incomplete data
            if ([self.pairing_Type isEqualToString:kP2P]) { // if it's P2P
                [self.p2pManager requestToReadNextPacketfromSocket]; // keep reading
            }
            
            if (handler) {
                handler(requestString.length);
            }
        } break;
    }
}

/*! 
    @brief Handle the sender logic for specific file in specific data type.
    @param item enum type to show the current state.
    @param response String value decoded from receiver side data.
*/
- (void)transferSelecteditem:(enum state_machine) item receivedData:(NSString *)response {
    switch (item) {
        case TRANSFER_VCARD_FILE: {
            totalDataSent = 0;
            ++self.totalFileTransferred;
            [self getContactsFile];
        }
            break;
            
        case TRANSFER_PHOTO_FILE: {
            ++self.totalFileTransferred;
            // Get photo name
            NSString *photoFileName = nil;
            // Bonjour
            NSArray *photoInfo = [self parsePhotoNameFromData:response forReconnect:NO isLive:NO];
            photoFileName = (NSString *)photoInfo[0];
            self.currentMediaID = photoFileName;
            [self createRequestedPhoto:photoFileName isLive:NO];
        }
            break;
            
        case TRANSFER_LIVEPHOTO_FILE: {
            ++self.totalFileTransferred;
            // Get photo name
            NSString *photoFileName = nil;
            // Bonjour
            NSArray *photoInfo = [self parsePhotoNameFromData:response forReconnect:NO isLive:YES];
            photoFileName = (NSString *)photoInfo[0];
            self.currentMediaID = photoFileName;
            [self createRequestedPhoto:photoFileName isLive:YES];
        }
            break;
            
        case TRANSFER_LIVEPHOTO_VIDEO_FILE: {
            NSAssert(self.currentMediaID, @"Media ID should be current image name.");
            [self createRequestVideoComponentForLivePhoto:self.currentMediaID];
        }
            break;
            
        case TRANSFER_VIDEO_FILE: {
            ++self.totalFileTransferred;
            // Get video name
            NSString *videoFileName = nil;
            NSArray *videoInfo = [self parseVideoFromData:response forReconnect:NO];
            videoFileName = (NSString *)videoInfo[0];
            self.currentMediaID = videoFileName;
            [self createRequestedVideo:videoFileName withByte:0];
        }
            break;
            
        case TRANSFER_RECONNECT_VIDEO: {
            // Get video name
            NSString *videoFileName = nil;
            NSArray *videoInfo = [self parseVideoFromData:response forReconnect:YES];
            videoFileName = (NSString *)videoInfo[0];
            if ([videoFileName isEqualToString:self.currentMediaID]) { // need to resend the current file
                self.numberOfVideos --;
                NSInteger alreadySent = self.bonjourManager.byteActuallyWrite;
                totalDataSent -= alreadySent;
                totalDataSentProcess -= alreadySent;
            } else { // need to send next file
                self.currentMediaID = videoFileName;
            }
            [self createRequestedVideo:videoFileName withByte:0];
        }
            break;
            
        case TRANSFER_RECONNECT_PHOTO: {
            // Get photo name
            NSString *photoFileName = nil;
            NSArray *photoInfo = [self parsePhotoNameFromData:response forReconnect:YES isLive:NO];
            photoFileName = (NSString *)photoInfo[0];
            if ([photoFileName isEqualToString:self.currentMediaID]) { // need to resend the current file
                self.numberOfPhotos --;
                self.numberOfPhotoSuccess --;
                NSInteger alreadySent = self.bonjourManager.byteActuallyWrite;
                totalDataSent -= alreadySent;
                totalDataSentProcess -= alreadySent;
            } else { // need to send next file
                self.currentMediaID = photoFileName;
            }
            [self createRequestedPhoto:photoFileName isLive:NO];
        }
            break;
            
        case TRANSFER_RECONNECT_LIVE_PHOTO: {
            // Get photo name
            NSString *photoFileName = nil;
            NSArray *photoInfo = [self parsePhotoNameFromData:response forReconnect:YES isLive:YES];
            photoFileName = (NSString *)photoInfo[0];
            if ([photoFileName isEqualToString:self.currentMediaID]) { // receiver didn't received file data, need to resend the current file
                self.numberOfPhotos --;
                self.numberOfPhotoSuccess --;
                NSInteger alreadySent = self.bonjourManager.byteActuallyWrite;
                totalDataSent -= alreadySent;
                totalDataSentProcess -= alreadySent;
            } else { // need to send next file
                self.currentMediaID = photoFileName;
            }
            [self createRequestedPhoto:photoFileName isLive:YES];
        }
            break;
            
        case TRANSFER_RECONNECT_LIVE_PHOTO_VIDEO_COMPO: {
            NSAssert(self.currentMediaID, @"Media ID should be current image name.");
            if (self.videoComponentStartSending) { // Video component start sending, receiver didn't received the sent package, should send it again.
                self.videoComponentStartSending = NO;
                NSInteger alreadySent = self.bonjourManager.byteActuallyWrite;
                totalDataSent -= alreadySent;
                totalDataSentProcess -= alreadySent;
            } // Else video component request didn't received by sender, package never start sending, just send again.
            [self createRequestVideoComponentForLivePhoto:self.currentMediaID];
        }
            break;
            
        case TRANSFER_RECONNECT_DUPLICATE_PHOTO: {
            NSArray *duplicateInfo = [self parseReconnectDuplicateInfo:response];
            NSInteger receiverDuplicateCount = [[duplicateInfo objectAtIndex:1] integerValue];
            
            if (receiverDuplicateCount == _localDuplicateCount) { // both count matches, means response failed, only send back and continue
                NSString *str = CT_SEND_FILE_DUPLICATE_RECEIVED;
                [self.bonjourManager requestSendingFileListPackage:[str dataUsingEncoding:NSUTF8StringEncoding]];
            } else { // doesn't match means, sender side never receive last duplicate request, need to update and then send back response
                self.tartgetFileCount = ++self.numberOfPhotos;
                self.numberOfPhotoSuccess ++;
                NSLog(@"->total photo count:%ld", (long)self.numberOfPhotos);
                if (self.numberOfPhotos == 1) {
                    totalDataSent = 0;
                }
                
                DebugLog(@"Total sent data %lld", totalDataSent); // total data for current section
                ++self.totalFileTransferred;
                
                NSInteger duplicateSize = [[duplicateInfo objectAtIndex:0] integerValue];
                totalDataSent += duplicateSize;
                totalDataSentProcess += duplicateSize; // total for all
                self.totalDuplicatedDataSent += duplicateSize;
                [self updateDuplicateProgressOfMediaType:@"photos" transferredFileCount:_tartgetFileCount];
                
                NSString *str = CT_SEND_FILE_DUPLICATE_RECEIVED;
                [self.bonjourManager requestSendingFileListPackage:[str dataUsingEncoding:NSUTF8StringEncoding]];
                _localDuplicateCount ++; // Once we received duplicate from receiver side, add one.(This is only valid for Bonjour reconnect)
                NSLog(@"local duplicate number:%ld", (long)_localDuplicateCount);
            }
            
        }
            break;
            
        case TRANSFER_RECONNECT_DUPLICATE_VIDEO: {
            NSArray *duplicateInfo = [self parseReconnectDuplicateInfo:response];
            NSInteger receiverDuplicateCount = [[duplicateInfo objectAtIndex:1] integerValue];
            
            if (receiverDuplicateCount == _localDuplicateCount) { // both count matches, means response failed, only send back and continue
                NSString *str = CT_SEND_FILE_DUPLICATE_RECEIVED;
                [self.bonjourManager requestSendingFileListPackage:[str dataUsingEncoding:NSUTF8StringEncoding]];
            } else { // doesn't match means, sender side never receive last duplicate request, need to update and then send back response
                self.tartgetFileCount = ++self.numberOfVideos;
                NSLog(@"->total photo count:%ld", (long)self.numberOfVideos);
                if (self.numberOfVideos == 1) {
                    totalDataSent = 0;
                }
                
                DebugLog(@"Total sent data %lld", totalDataSent); // total data for current section
                ++self.totalFileTransferred;
                
                NSInteger duplicateSize = [[duplicateInfo objectAtIndex:0] integerValue];
                totalDataSent += duplicateSize;
                totalDataSentProcess += duplicateSize; // total for all
                self.totalDuplicatedDataSent += duplicateSize;
                [self updateDuplicateProgressOfMediaType:@"videos" transferredFileCount:_tartgetFileCount];
                
                NSString *str = CT_SEND_FILE_DUPLICATE_RECEIVED;
                [self.bonjourManager requestSendingFileListPackage:[str dataUsingEncoding:NSUTF8StringEncoding]];
                _localDuplicateCount ++; // Once we received duplicate from receiver side, add one.(This is only valid for Bonjour reconnect)
                NSLog(@"local duplicate number:%ld", (long)_localDuplicateCount);
            }
            
        }
            break;
            
        case TRANSFER_NEXT_VIDEO_PART: {
            if (self.oldState == TRANSFER_AUDIO_FILE) {
                [self.p2pManager transferChunkofAudio];
            } else {
                [self.p2pManager sendRequestedVideoPart];
            }
        }
            break;
            
        case TRANSFER_REMINDER_LOG_FILE: {
            totalDataSent = 0;
            ++self.totalFileTransferred;
            [self createReminderLogFile];
        }
            break;
        case TRANSFER_CALENDAR_FILE_START: {
            ++self.totalFileTransferred;
            [self createRequestCalendar:[self parseCalendarFromData:response]];
        } break;
            
        case TRANSFER_CALENDAR_FILE: {
            ++self.totalFileTransferred;
            [self createRequestCalendar:[self parseCalendarFromData:response]];
        } break;
            
        case TRANSFER_CALENDAR_FILE_END: {
            ++self.totalFileTransferred;
            [self createRequestCalendar:[self parseCalendarFromData:response]];
        } break;
            
        case TRANSFER_AUDIO_FILE: {
            ++self.totalFileTransferred;
            [self createRequestedAudioFile:[self parseAudioFromData:response]];
        }
            break;
            
        default:
            break;
    }
}

- (NSArray *)parseReconnectDuplicateInfo:(NSString *)request {
    return [request componentsSeparatedByString:@"_"]; // array contains two values, one is size, second one is local count for receiver side
}

/*!
    @brief Identify the request string.
    @param response String value received from receiver side.
    @return enum type to show the current data type.
    @see state_machine
 */
- (enum state_machine)identifyRequest:(NSString **)response {

    DebugLog(@"identify request %@",*response);
    NSRange targetRange = NSMakeRange(NSNotFound, 0);
    if ((*response).length > 0) {
        if ([*response rangeOfString:CT_REQUEST_FILE_CONTACT_HEADER].location != NSNotFound) {
            // Received contact file request
            self.bonjourManager.serverRestarted = NO;
            return TRANSFER_VCARD_FILE;
        } else if ([*response rangeOfString:CT_REQUEST_FILE_REMINDER_HEADER].location != NSNotFound) {
            // Received reminder file request
            self.bonjourManager.serverRestarted = NO;
            return TRANSFER_REMINDER_LOG_FILE;
        } else if ([[CTUserDevice userDevice].phoneCombination isEqualToString:IOS_IOS] && ([*response rangeOfString:CT_REQUEST_FILE_CALENDARS_START_HEADER].location != NSNotFound)) {
            // Calendar for first file, only iOS to iOS, old logic
            self.bonjourManager.serverRestarted = NO;
            return TRANSFER_CALENDAR_FILE_START;
        } else if ([[CTUserDevice userDevice].phoneCombination isEqualToString:IOS_IOS] && ([*response rangeOfString:CT_REQUEST_FILE_CALENDARS_ORIGIN_HEADER].location != NSNotFound)) {
            // Calendar for middle files, only iOS to iOS, old logic
            self.bonjourManager.serverRestarted = NO;
            return TRANSFER_CALENDAR_FILE;
        } else if ([[CTUserDevice userDevice].phoneCombination isEqualToString:IOS_IOS] && ([*response rangeOfString:CT_REQUEST_FILE_CALENDARS_FINAL_HEADER].location != NSNotFound)) {
            // Calendar for last file, only iOS to iOS, old logic
            self.bonjourManager.serverRestarted = NO;
            return TRANSFER_CALENDAR_FILE_END;
        } else if ([[CTUserDevice userDevice].phoneCombination isEqualToString:IOS_Andriod] && ([*response rangeOfString:CT_REQUEST_FILE_CALENDARS_HEADER].location != NSNotFound)) {
            // Calendar for all, only cross platform, old logic
            return TRANSFER_CALENDAR_FILE_END;
        } else if ([*response rangeOfString:CT_REQUEST_FILE_PHOTO_DUPLICATE_HEADER].location != NSNotFound) {
            // Dupicate request for photo transfer
            [self updateDuplicateInformationFor:CTPhotoDuplicate withRequest:*response];
            return TRASNFER_FILE_DUPLICATE;
        } else if ([*response rangeOfString:CT_REQUEST_FILE_PHOTO_HEADER].location != NSNotFound) {
            // Photo file request
            self.bonjourManager.serverRestarted = NO;
            return TRANSFER_PHOTO_FILE;
        } else if ([*response rangeOfString:CT_REQUEST_FILE_RECONNECT_PHOTO_HEADER].location != NSNotFound) {
            // Reconnect for photo transfer
            self.bonjourManager.serverRestarted = NO;
            return TRANSFER_RECONNECT_PHOTO;
        } else if ([*response rangeOfString:CT_REQUEST_FILE_RECONNECT_LIVEPHOTO_PHEADER].location != NSNotFound) {
            // Reconnect for live photo transfer
            self.bonjourManager.serverRestarted = NO;
            return TRANSFER_RECONNECT_LIVE_PHOTO;
        } else if ([*response rangeOfString:CT_REQUEST_FILE_RECONNECT_LIVEPHOTO_VHEADER].location != NSNotFound) {
            // Reconnect for live photo transfer
            self.bonjourManager.serverRestarted = NO;
            return TRANSFER_RECONNECT_LIVE_PHOTO_VIDEO_COMPO;
        } else if ([*response rangeOfString:CT_REQUEST_FILE_RECONNECT_PHOTO_DUPLICATE_HEADER].location != NSNotFound) {
            // Reconnect for photo duplicate
            self.bonjourManager.serverRestarted = NO;
            *response = [*response stringByReplacingOccurrencesOfString:CT_REQUEST_FILE_RECONNECT_PHOTO_DUPLICATE_HEADER withString:@""];
            return TRANSFER_RECONNECT_DUPLICATE_PHOTO;
        } else if ([*response rangeOfString:CT_REQUEST_FILE_LIVEPHOTO_HEADER].location != NSNotFound) {
            // Live photo file request, type still be photo transfer.
            self.bonjourManager.serverRestarted = NO;
            return TRANSFER_LIVEPHOTO_FILE;
        } else if ([*response rangeOfString:CT_REQUEST_FILE_LIVEPHOTO_VIDEO_HEADER].location != NSNotFound) {
            // Live photo video file request, type still be photo transfer.
            self.bonjourManager.serverRestarted = NO;
            return TRANSFER_LIVEPHOTO_VIDEO_FILE;
        } else if ([*response rangeOfString:CT_REQUEST_FILE_VIDEO_DUPLICATE_HEADER].location != NSNotFound) {
            // Dupicate request for video transfer
            [self updateDuplicateInformationFor:CTVideoDuplicate withRequest:*response];
            return TRASNFER_FILE_DUPLICATE;
        } else if ([*response rangeOfString:CT_REQUEST_FILE_VIDEO_HEADER].location != NSNotFound) {
            // Request video file
            self.bonjourManager.serverRestarted = NO;
            return TRANSFER_VIDEO_FILE;
        } else if ( [*response rangeOfString:CT_REQUEST_FILE_NEXT_VIDEO_PART_HEADER].location != NSNotFound) {
            // Request next video part
            return TRANSFER_NEXT_VIDEO_PART;
        } else if ([*response rangeOfString:CT_REQUEST_FILE_RECONNECT_VIDEO_HEADER].location != NSNotFound) {
            // Reconnect for video transfer
            self.bonjourManager.serverRestarted = NO;
            return TRANSFER_RECONNECT_VIDEO;
        } else if ([*response rangeOfString:CT_REQUEST_FILE_RECONNECT_VIDEO_DUPLICATE_HEADER].location != NSNotFound) {
            // Reconnect for video duplicate
            self.bonjourManager.serverRestarted = NO;
            *response = [*response stringByReplacingOccurrencesOfString:CT_REQUEST_FILE_RECONNECT_VIDEO_DUPLICATE_HEADER withString:@""];
            return TRANSFER_RECONNECT_DUPLICATE_VIDEO;
        } else if ([*response rangeOfString:CT_REQUEST_FILE_AUDIO_DUPLICATE_HEADER].location != NSNotFound) {
            // Dupicate request for audio transfer
            [self updateDuplicateInformationFor:CTAudioDuplicate withRequest:*response];
            return TRASNFER_FILE_DUPLICATE;
        } else if ([*response rangeOfString:CT_REQUEST_FILE_AUDIO_HEADER].location != NSNotFound) {
            // Audio file transfer
            return TRANSFER_AUDIO_FILE;
        } else if ((targetRange = [*response rangeOfString:CT_REQUEST_FILE_COMPLETED]).location != NSNotFound) {
            // Transfer finished
            self.bonjourManager.serverRestarted = NO;
            return TRANSFER_COMPLETED;
        } else if ([*response rangeOfString:CT_REQUEST_FILE_NOT_ENOUGH_STORAGE].location != NSNotFound) {
            // No enough storage request, Depricated.
            return TRANSFER_NO_ENOUGH_STORAGE;
        } else if ((targetRange = [*response rangeOfString:CT_REQUEST_FILE_CANCEL]).location != NSNotFound) {
            // Trnasfer cancelled
            self.bonjourManager.serverRestarted = NO;
            return TRANSFER_CANCEL;
        } else if([*response rangeOfString:CT_REQUEST_FILE_CANCEL_CLICKED].location != NSNotFound) {
            // Transfer cancelled, only use for cross platform
            return TRANSFER_CANCEL;
        }
    }
    
    return TRANSFER_HAND_SHAKE;
}

#pragma mark - Duplicate logic related.(New duplicate logic, updated 06/30/2017 by Xin)
/*!
    @brief Update duplciate information from duplicate request.
    @param dataType CTDuplicateType enum value represents the type of request.
    @param request NSString value represents the request
    @see CTDuplicateType
 */
- (void)updateDuplicateInformationFor:(enum CTDuplicateType)dataType withRequest:(NSString *)request {
    // Update information based on type
    switch (dataType) {
        case CTPhotoDuplicate:
            [self preparePhotoDuplicateData:request];
            // Parse size first
            [self generalDuplicateInformationForRequest:request];
            [self updateDuplicateProgressOfMediaType:@"photos" transferredFileCount:_tartgetFileCount];
            break;
        case CTVideoDuplicate:
            [self prepareVideoDuplicateData:request];
            // Parse size first
            [self generalDuplicateInformationForRequest:request];
            [self updateDuplicateProgressOfMediaType:@"videos" transferredFileCount:_tartgetFileCount];
            break;
        case CTAudioDuplicate:
            [self prepareAudioDuplicateData:request];
            // Parse size first
            [self generalDuplicateInformationForRequest:request];
            [self updateDuplicateProgressOfMediaType:@"audios" transferredFileCount:_tartgetFileCount];
            break;
    }
}
/*!
    @brief Prepare the duplicate data for photo transfer.
    @discussion This method will parse the duplicate photo request to get the size, and update necessary information for sender side UI.
    @param request NSString value represents the request received from receiver side. This request is encoded using base64 algorithm.
 */
- (void)preparePhotoDuplicateData:(NSString *)request {
    self.tartgetFileCount = ++self.numberOfPhotos;
    self.numberOfPhotoSuccess ++;
    if (self.numberOfPhotos == 1) {
        totalDataSent = 0;
    }
    
    DebugLog(@"Total sent data %lld", totalDataSent); // total data for current section
}
/*!
    @brief Prepare the duplicate data for video transfer.
    @discussion This method will parse the duplicate video request to get the size, and update necessary information for sender side UI.
    @param request NSString value represents the request received from receiver side. This request is encoded using base64 algorithm.
 */
- (void)prepareVideoDuplicateData:(NSString *)request {
    self.tartgetFileCount = ++self.numberOfVideos;
    if (self.numberOfVideos == 1) {
        totalDataSent = 0;
    }
    
    DebugLog(@"Total sent data %lld", totalDataSent); // total data for current section
}
/*!
    @brief Prepare the duplicate data for audio transfer.
    @discussion This method will parse the duplicate audio request to get the size, and update necessary information for sender side UI.
    @param request NSString value represents the request received from receiver side. This request is encoded using base64 algorithm.
 */
- (void)prepareAudioDuplicateData:(NSString *)request {
    self.tartgetFileCount = ++self.numberOfAudios;
    self.numberOfAudioSuccess += 1; // Add one more audio successfully count
    if (self.numberOfAudios == 1) {
        totalDataSent = 0;
        self.targetMediaType = @"audios";
    }
    DebugLog(@"Total sent data %lld", totalDataSent); // total data for current section
}
/*!
    @brief Parse the request and update gerenal information irrelated to data types.
    @param request NSString value represents the request from receiver side. This request is encoded using base64 algorithm.
 */
- (void)generalDuplicateInformationForRequest:(NSString *)request {
    NSRange range = [request rangeOfString:CT_REQUEST_DUPLICATE_ENCODED];
    NSAssert(range.location != NSNotFound, @"Should have [duplicate_] part in request"); // Duplicate part should always be there
    request = [[[request substringFromIndex:range.location] decodeStringTo64] stringByReplacingOccurrencesOfString:CT_REQUEST_DUPLICATE_KEY withString:@""]; // Remove the header, decode and get the size to be updated
    totalDataSent        += [request integerValue]; // total for section
    totalDataSentProcess += [request integerValue]; // total for all
    self. totalDuplicatedDataSent += [request integerValue];

    ++self.totalFileTransferred; // Update total file transferred count
}

#pragma mark - File Sending Related
// Common method for sending contacts
- (void)getContactsFile {
    
    NSString *basePath = [NSString appRootDocumentDirectory];
    /*
     * We are assigning our filePath variable with our application's document path appended with our file's name.
     */
    NSData *data = [[NSFileManager defaultManager] contentsAtPath:[NSString stringWithFormat:@"%@/Contacts/ContactsFile.vcf", basePath]];
    
    // create header
    NSString *requestStr = [[NSString alloc] initWithFormat:CT_SEND_FILE_CONTACTS_HEADER];
    NSMutableString *tempstr = [[NSMutableString alloc] initWithFormat:@"%d",(int)data.length];
    int gap = 10 - (int)tempstr.length;
    for (int i = 0; i < gap ; i++) {
        [tempstr insertString:@"0" atIndex:0];
    }
    [tempstr insertString:requestStr atIndex:0];
    NSData *requestData = [tempstr dataUsingEncoding:NSUTF8StringEncoding];
    
    // merge all data
    NSMutableData *finaldata = [[NSMutableData alloc] init];
    [finaldata appendData:requestData];
    [finaldata appendData:data];
    
    self.contactSent = YES;
    
    [self sendRequestedData:finaldata actualDataSize:data.length mediaType:@"contacts" transferredFileCount:1];
}

- (void)createRequestCalendar:(NSString *)calName {
    
    NSData *data = [[NSFileManager defaultManager] contentsAtPath:[[CTUserDefaults sharedInstance].calendarList objectForKey:calName]];
    
    // create header
    NSString *requestStr = [[NSString alloc] initWithFormat:CT_SEND_FILE_CALENDARS_HEADER];
    NSMutableString *tempstr = [[NSMutableString alloc] initWithFormat:@"%d",(int)data.length];
    int gap = 10 - (int)tempstr.length;
    for (int i = 0; i < gap ; i++) {
        [tempstr insertString:@"0" atIndex:0];
    }
    [tempstr insertString:requestStr atIndex:0];
    NSData *requestData = [tempstr dataUsingEncoding:NSUTF8StringEncoding];
    
    // merge the data
    NSMutableData *finaldata = [[NSMutableData alloc] init];
    [finaldata appendData:requestData];
    [finaldata appendData:data];

    self.numberOfCalendars += 1;
    if (self.numberOfCalendars == 1) {
        totalDataSent = 0;
    }

    [self sendRequestedData:finaldata actualDataSize:data.length mediaType:@"calendar" transferredFileCount:self.numberOfCalendars];
}

- (void)createReminderLogFile {
    
    NSString *basePath = [NSString appRootDocumentDirectory];
    NSData *reminderdata = [[NSFileManager defaultManager] contentsAtPath:[NSString stringWithFormat:@"%@/Reminders/RemindersFile.txt",basePath]];
    
    // Header
    NSString *requestStr = [[NSString alloc] initWithFormat:CT_SEND_FILE_REMINDERS_HEADER];
    NSMutableString *tempstr = [[NSMutableString alloc] initWithFormat:@"%d",(int)reminderdata.length];
    int gap = 10 - (int)tempstr.length;
    for (int i = 0; i < gap ; i++) {
        [tempstr insertString:@"0" atIndex:0];
    }
    [tempstr insertString:requestStr atIndex:0];
    NSData *requestData = [tempstr dataUsingEncoding:NSUTF8StringEncoding];
    
    // merge data
    NSMutableData *finaldata = [[NSMutableData alloc] init];
    [finaldata appendData:requestData];
    [finaldata appendData:reminderdata];
    
    self.reminderSent = YES;
    
    [self sendRequestedData:finaldata actualDataSize:reminderdata.length mediaType:@"reminder" transferredFileCount:1];
}

/*!
    @brief Try to create the target audio file.
    @param audioName The name of target audio file that receiver side requested.
 */
- (void)createRequestedAudioFile:(NSString *)audioName {
    self.numberOfAudioSuccess += 1;
    self.numberOfAudios       += 1;
    if (self.numberOfAudios == 1) {
        totalDataSent = 0;
        DebugLog(@"Total sent data for section %lld", totalDataSent);
        
        // Update for section
        self.targetMediaType = @"audios";
        [self updateProgressOfMediaType:self.targetMediaType transferredFileCount:self.numberOfAudios];
    }
    self.tartgetFileCount = self.numberOfAudios;
    DebugLog(@"audio sending: %ld", (long)self.tartgetFileCount);
    
    audioName = [audioName decodeStringTo64]; // Decode the file name
    
    [[CTDataCollectionManager sharedManager].audioManager audioFile:audioName getDataWithCompletionHandler:^(NSString *localPath, BOOL success) {
        if (success) {
            [self.p2pManager sendRequestAudioFile:localPath];
        } else { // When fail, there is no file size can get. So use the size previously inserted for metadata. On both side, order should be same.
            NSDictionary *audioInfo = [self.fileList getFileInformationForType:METADATA_ITEMLIST_KEY_AUDIOS andIndex:self.numberOfAudios-1];
            // Directly update the size information for failure file, and waiting for next request.
            long long fileSizeFromList = [[audioInfo objectForKey:@"Size"] longLongValue];
            [self.p2pManager sendAudioRequestFailure:fileSizeFromList outOfFileSize:fileSizeFromList];
        }
    }];
}

- (void)createRequestedPhoto:(NSString *)imgname isLive:(BOOL)isLivePhoto {
    self.numberOfPhotos++;
    self.numberOfPhotoSuccess ++;
    if (self.numberOfPhotos == 1) {
        totalDataSent = 0;
        DebugLog(@"Total sent data for section %lld", totalDataSent);
    }
    DebugLog(@"photo sending: %ld", (long)self.numberOfPhotos);
    
    if ([self.pairing_Type isEqualToString:kP2P]) {
        imgname = [imgname decodeStringTo64];
    }

    [self.photoManager requestPhotoDataForName:imgname forLive:isLivePhoto handler:^(NSData *photoData, NSError *error) {
        if (error) {
            // When fail, there is no file size can get. So use the size previously inserted for metadata. On both side, order should be same.
            NSLog(@"Error when reading the file: %@", error.localizedDescription);
            NSDictionary *photoInfo = [self.fileList getFileInformationForType:METADATA_ITEMLIST_KEY_PHOTOS andIndex:self.numberOfPhotos-1];
            // Directly update the size information for failure file, and waiting for next request.
            long long fileSizeFromList = [[photoInfo objectForKey:@"Size"] longLongValue];
            
            [self sendRequestedSingleFileFailed:fileSizeFromList mediaType:@"photos" transferredFileCount:self.numberOfPhotos shouldConsiderFail:YES];
        } else if (isLivePhoto) {
            NSLog(@"> Live photo image part start.....");
            // Sent live photo image part first, iOS 9.1 and above
            long long totalPhotoSize = photoData.length;
            // header
            NSString *requestStr = [[NSString alloc] initWithFormat:CT_SEND_FILE_LIVEPHOTO_IMAGE_HEADER];
            NSMutableString *tempstr = [[NSMutableString alloc] initWithFormat:@"%@%010lld", requestStr, totalPhotoSize];
            NSData *requestData = [tempstr dataUsingEncoding:NSUTF8StringEncoding];
            // merge
            NSMutableData *finaldata = [[NSMutableData alloc] initWithData:requestData];
            [finaldata appendData:photoData];
            
            NSLog(@"> Sending: %lu", (unsigned long)finaldata.length);
            [self sendRequestedData:finaldata actualDataSize:totalPhotoSize mediaType:@"photos" transferredFileCount:self.numberOfPhotos];
        } else {
            NSLog(@"> Static photo start.....");
            // Static photo
            long long totalPhotoSize = photoData.length;
            // Header
            NSString *requestStr = [[NSString alloc] initWithFormat:@"%@%010lld", CT_SEND_FILE_PHOTO_HEADER, totalPhotoSize];
            NSData *requestData = [requestStr dataUsingEncoding:NSUTF8StringEncoding];
            // Data
            NSMutableData *finaldata = [[NSMutableData alloc] initWithData:requestData];
            [finaldata appendData:photoData];
            
            NSLog(@"> Sending: %lu", (unsigned long)finaldata.length);
            [self sendRequestedData:finaldata actualDataSize:totalPhotoSize mediaType:@"photos" transferredFileCount:self.numberOfPhotos];
        }
    }];
}

- (void)createRequestVideoComponentForLivePhoto:(NSString *)imageName {
    DebugLog(@"photo sending: %ld", (long)self.numberOfPhotos);
    self.videoComponentStartSending = YES;
    
    if ([self.pairing_Type isEqualToString:kP2P]) {
        imageName = [imageName decodeStringTo64];
    }
    
    [self.photoManager requestVideoComponentForLivePhoto:imageName handler:^(NSData *videoData, NSError *error) {
        if (error) {
            // When fail, there is no file size can get. So get video part size for live photo, because image part already sent.
            NSLog(@"Error when reading video resource file: %@", error.localizedDescription);
            long long videoFileSize = [self.photoManager requestVideoComponentSizeForLivePhoto:imageName];
            
            // Add error list if live photo become static photo.
            [[CTUserDefaults sharedInstance] addErrorLivePhoto:imageName];
            [self sendRequestedSingleFileFailed:videoFileSize mediaType:@"photos" transferredFileCount:self.numberOfPhotos shouldConsiderFail:NO];
        } else {
            NSLog(@"> Live photo video component part start.....");
            // Sent live photo video part
            long long totalVideoSize = videoData.length;
            // header
            NSString *requestStr = [[NSString alloc] initWithFormat:CT_SEND_FILE_LIVEPHOTO_VIDEO_HEADER];
            NSMutableString *tempstr = [[NSMutableString alloc] initWithFormat:@"%@%010lld", requestStr, totalVideoSize];
            NSData *requestData = [tempstr dataUsingEncoding:NSUTF8StringEncoding];
            // merge
            NSMutableData *finaldata = [[NSMutableData alloc] initWithData:requestData];
            [finaldata appendData:videoData];
            
            NSLog(@"> Sending: %lu", (unsigned long)finaldata.length);
            [self sendRequestedData:finaldata actualDataSize:totalVideoSize mediaType:@"photos" transferredFileCount:self.numberOfPhotos];
        }
    }];
}

- (void)createRequestedVideo:(NSString *)videoName withByte:(NSString *)bytesSent {
    
    NSLog(@"===================");
    NSLog(@"==>video name before decode:%@", videoName);
    
    self.numberOfVideos++;
    if (self.numberOfVideos == 1) {
        totalDataSent = 0;
        DebugLog(@"Total sent data for section %lld", totalDataSent);
    }
    
    if ([self.pairing_Type isEqualToString:kP2P]) {
        videoName = [videoName decodeStringTo64];
    }
    
    NSLog(@"==>video name:%@", videoName);
    
    __weak typeof(self) weakSelf = self;
    [self.videoManager requestVideoDataForName:videoName handler:^(id asset) {
        NSAssert([asset isKindOfClass:[AVURLAsset class]] || [asset isKindOfClass:[ALAsset class]], @"Wrong format for video object, should not happen, check logic!");
        if ([asset isKindOfClass:[AVURLAsset class]]) { // If it's AVURLAsset
            AVURLAsset *myasset = (AVURLAsset *)asset;
            NSLog(@"asset:%@", asset);
            NSNumber *size;
            [myasset.URL getResourceValue:&size forKey:NSURLFileSizeKey error:nil];
            
            DebugLog(@"=>file size is %lld",[size longLongValue]);
            
            if ([weakSelf.pairing_Type isEqualToString:kP2P]) {
                
                // transfter from iPhone to Android
                
                self.targetMediaType = @"videos";
                
                self.tartgetFileCount = self.numberOfVideos;
                
                [self updateProgressOfMediaType:@"videos" transferredFileCount:self.numberOfVideos];
                
                if ([self isVideoCreateTimeMissing:myasset]) {
                    asset = [self insertCreateTime:myasset withTime:myasset.creationDate];
                }

                [weakSelf.p2pManager sendRequestVideo:asset];
                
            } else {
                
                weakSelf.bonjourManager.videoFileSize = [size longLongValue];
                weakSelf.bonjourManager.videoFirstPacket = YES;
                weakSelf.bonjourManager.currentVideoURL = asset;
                weakSelf.bonjourManager.isVideo = 1;
                
                self.targetMediaType = @"videos";
                self.tartgetFileCount = self.numberOfVideos;
                [self updateProgressOfMediaType:@"videos" transferredFileCount:self.numberOfVideos];
                [weakSelf.bonjourManager requestSendLargeFilePacket];
            }
            
        } else { // Otherwise it will be ALAsset class
            ALAsset *myasset = (ALAsset *)asset;
            
            if ([self.pairing_Type isEqualToString:kP2P]) {
                
                self.targetMediaType = @"videos";
                self.tartgetFileCount = self.numberOfVideos;
                [self updateProgressOfMediaType:@"videos" transferredFileCount:self.numberOfVideos];
                
                [self.p2pManager sendRequestVideo:myasset];
            }
        }
    }];
}

- (BOOL) isVideoCreateTimeMissing:(AVAsset *) asset
{
    NSArray *metadata = [asset commonMetadata];
    
    for (AVMetadataItem *item in metadata) {
        
        if([[item commonKey] isEqualToString:AVMetadataCommonKeyCreationDate])
        {
            return NO;
        }
    }
    
    return YES;
}

- (AVURLAsset *)insertCreateTime:(AVURLAsset *)asset withTime:(AVMetadataItem *)dateItem {
    // Generate Date Value
    AVMutableMetadataItem * commonDate = [[AVMutableMetadataItem alloc] init];
    commonDate.keySpace = AVMetadataKeySpaceCommon;
    commonDate.key = AVMetadataCommonKeyCreationDate;
    
    NSDate * date = dateItem.dateValue;
    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-ddTHH:mm:ss"];
    NSTimeZone *gmt = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    [dateFormatter setTimeZone:gmt];
    
    NSString *dateString = [dateFormatter stringFromDate:date];
    commonDate.value = dateString;
    
    // Get file type
    NSURL *assetURL = asset.URL;
    AVFileType fileType = [CTAVFileTypeGenerator getProperAVFileTypeForFile:asset.URL];
    if (fileType == nil) {
        // File type if not supported, return orignial type.
        return asset;
    }
    
    // Greate asset writer
    NSError *error = nil;
    AVAssetWriter *assetWriter = [[AVAssetWriter alloc] initWithURL:assetURL fileType:fileType error:&error];
    if(!error) {
        NSArray *existingMetadataArray = assetWriter.metadata;
        NSMutableArray *newMetadataArray = nil;
        if (existingMetadataArray) {
            newMetadataArray = [existingMetadataArray mutableCopy]; // To prevent overriding of existing metadata
        } else {
            newMetadataArray = [[NSMutableArray alloc] init];
        }
        
        [newMetadataArray addObject:commonDate];
        assetWriter.metadata = newMetadataArray;
        
        [assetWriter startWriting];
        [assetWriter startSessionAtSourceTime:kCMTimeZero];
    } else {
        NSLog(@"Error when creating asset writer: %@", error.localizedDescription);
    }
    
    return asset;
}

- (void)sendRequestedData:(NSData *)packet actualDataSize:(long long)size mediaType:(NSString*)mediaType transferredFileCount:(NSInteger)fileCount {
    self.targetMediaType = mediaType;
    self.tartgetFileCount = fileCount;
    
    [self updateProgressOfMediaType:_targetMediaType transferredFileCount:_tartgetFileCount];
    
    if ([self.pairing_Type isEqualToString:kP2P]) {
        [self.p2pManager writeDataToSocket:packet actualSize:size];
    } else {
        [self.bonjourManager requestSendingPackage:packet actualSize:size];
    }
}

- (void)sendRequestedSingleFileFailed:(long long)failedSize mediaType:(NSString*)mediaType transferredFileCount:(NSInteger)fileCount shouldConsiderFail:(BOOL)failed {
    self.targetMediaType = mediaType;
    self.tartgetFileCount = fileCount;
    
    [self updateProgressOfMediaType:_targetMediaType transferredFileCount:_tartgetFileCount];
    
    if ([self.pairing_Type isEqualToString:kP2P]) {
        [self.p2pManager sendRequestFailure:failedSize outOfFileSize:failedSize shouldConsiderFail:failed];
    } else {
        [self.bonjourManager requestSendingPackageFailed:failedSize shouldConsiderFail:failed];
    }
}

#pragma mark - UI Update Methods
- (void)senderShouldCreateProcessInfomation:(long long)byteSent {
    totalDataSent += byteSent;
    totalDataSentProcess += byteSent;
//    DebugLog(@"Total sent data for section %lld", totalDataSent);
//    DebugLog(@"Total sent data %lld", totalDataSentProcess);
    if (![_targetMediaType isEqualToString:@"file list"]) { // only calulate the file size (no file list size)
        [self updateProgressOfMediaType:_targetMediaType transferredFileCount:_tartgetFileCount];
    }
}
/*!
    @brief Update the UI Progress Information object.
    @param mediaType NString value to identify the current data type.
    @param fileCount NSInteger value for current file count.
 */
- (void)updateProgressOfMediaType:(NSString*)mediaType transferredFileCount:(NSInteger)fileCount {
    NSLog(@"Update UI for normal transfer");
    CTProgressInfo *progressInfo = [[CTProgressInfo alloc] initWithMediaType:mediaType];
    progressInfo.transferredCount = [NSNumber numberWithInteger:fileCount];
    progressInfo.transferredAmount = [NSNumber numberWithLongLong:totalDataSent];
    progressInfo.totalDataAmount = [NSNumber numberWithLongLong:totalDataSentProcess];
    long long actualTransfeSize = self.totalDataSentProcess - self.totalDuplicatedDataSent;
    progressInfo.acutalTransferredAmount = [NSNumber numberWithLongLong:actualTransfeSize];
    [[NSUserDefaults standardUserDefaults] setObject:progressInfo.acutalTransferredAmount forKey:@"NonDuplicateDataSize"];
    
    [_receiverProgressManagerDelegate updateUIWithProgressInfo:progressInfo];
}
/*!
    @brief Update UI information for duplicate files.
    @param mediaType NString value to identify the current data type.
    @param fileCount NSInteger value for current file count.
 */
- (void)updateDuplicateProgressOfMediaType:(NSString*)mediaType transferredFileCount:(NSInteger)fileCount {
    NSLog(@"Update UI for duplicate.");
    CTProgressInfo *progressInfo = [[CTProgressInfo alloc] initWithMediaType:mediaType];
    progressInfo.transferredCount = [NSNumber numberWithInteger:fileCount];
    progressInfo.transferredAmount = [NSNumber numberWithLongLong:totalDataSent];
    progressInfo.totalDataAmount = [NSNumber numberWithLongLong:totalDataSentProcess];
    long long actualTransfeSize = self.totalDataSentProcess - self.totalDuplicatedDataSent;
    progressInfo.acutalTransferredAmount = [NSNumber numberWithLongLong:actualTransfeSize];
    [[NSUserDefaults standardUserDefaults] setObject:progressInfo.acutalTransferredAmount forKey:@"NonDuplicateDataSize"];
    progressInfo.isDuplicate = YES;
    
    [_receiverProgressManagerDelegate updateUIWithProgressInfo:progressInfo];
}

#pragma mark - Helper Methods
- (void)transferShouldGoToNotEnoughStorage {
    if ([[CTUserDevice userDevice].pairingType isEqualToString:kP2P]) {
        [self.p2pManager cleanUpAllSocketConnection];
    }else {
        [[CTBonjourManager sharedInstance] closeStreams];
    }
    [self.receiverProgressManagerDelegate transferShouldGoToNotEnoughStorage];
}

- (void)transferDidFinished {
    [self.receiverProgressManagerDelegate transferDidFinished];
}

- (void)writePairingInformationToCommPort {
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    
    [dict setValue:[NSString stringWithFormat:@"Device ID: %@",[CTUserDevice userDevice].deviceUDID] forKey:USER_DEFAULTS_DB_PARING_DEVICE_INFO];
    
    CTDeviceMarco *deviceMacro = [[CTDeviceMarco alloc] init];
    NSString *modelCode = [deviceMacro getDeviceModel];
    NSString *model = [deviceMacro.models objectForKey:modelCode];
    if (model.length == 0) {
        model = modelCode;
    }
    
    [dict setValue:model forKey:USER_DEFAULTS_PAIRING_MODEL];
    [dict setValue:self.pairing_Type forKey:USER_DEFAULTS_PAIRING_TYPE];

    [dict setValue:[[UIDevice currentDevice] systemVersion] forKey:USER_DEFAULTS_PAIRING_OS_VERSION];
    [dict setValue:@"iOS" forKey:USER_DEFAULTS_PAIRING_DEVICE_TYPE];
    [dict setValue:[CTUserDevice userDevice].deviceUDID forKey:USER_DEFAULTS_PAIRING_DEVICE_ID];
    
    NSError *error;
    NSData *requestData = [NSJSONSerialization dataWithJSONObject:dict options:kNilOptions error:&error];
    
    if (requestData.length > 0) {
        
        self.p2pManager.dataTobeWrittenToCommPort = requestData;
    }
    
}

- (NSString *)parseCalendarFromData:(NSString *)response {
    // Ignore VZCONTENTTRANSFER_START_REQUEST_FOR_CALENDAR_
    NSString *calInfo ;
    if ([[CTUserDevice userDevice].phoneCombination isEqualToString:IOS_Andriod]) {
        //VZCONTENTTRANSFER_REQUEST_FOR_CALENDAR_
        calInfo = [response substringWithRange:NSMakeRange(39, response.length - 39)];
    } else {
        calInfo = [response substringWithRange:NSMakeRange(45, response.length - 45)];
    }
    
    return calInfo;
}

- (NSArray *)parsePhotoNameFromData:(NSString *)response forReconnect:(BOOL)isReconnect isLive:(BOOL)isLive {
    if (!isReconnect) { // if is not reconnect, both for P2P and Bonjour
        if (isLive) { // it's live photo
            // Skip VZCONTENTTRANSFER_REQUEST_FOR_LIVEPHOTO_ number of characters
            NSString *imgName = [response substringFromIndex:CT_REQUEST_FILE_LIVEPHOTO_HEADER.length];
            return @[imgName];
        } else {
            // Skip VZCONTENTTRANSFER_REQUEST_FOR_PHOTO_ number of characters
            NSString *imgname = [response substringWithRange:NSMakeRange(36, response.length - 36)];
            return [[NSArray alloc] initWithObjects:imgname, @"0", nil]; // first object is media name, second object is size already sent
        }
    } else { // if it's reconnect for Bonjour
        if (isLive) { // if it's live photo
            // Skip VZCONTENTTRANSFER_RECONNECT_FOR_LIVEPHOTO_
            NSString *imgName = [response substringFromIndex:CT_REQUEST_FILE_RECONNECT_LIVEPHOTO_PHEADER.length];
            return @[imgName];
        } else {
            // Skip VZCONTENTTRANSFER_RECONNECT_FOR_PHOTO_ number of characters
            NSString *imgname = [response substringWithRange:NSMakeRange(38, response.length - 38)];
            return [[NSArray alloc] initWithObjects:imgname, @"0", nil];
        }
    }
}

- (NSArray *)parseVideoFromData:(NSString *)response forReconnect:(BOOL)isReconnect {
    if (!isReconnect) {// if is not reconnect, both for P2P and Bonjour
        // Skip VZCONTENTTRANSFER_REQUEST_FOR_PHOTO_ number of characters
        NSString *imgname = [response substringWithRange:NSMakeRange(36, response.length - 36)];
  
        return [[NSArray alloc] initWithObjects:imgname, @"0", nil]; // first object is media name, second object is size already sent
    } else { // if it's reconnect for Bonjour
        // Skip VZCONTENTTRANSFER_RECONNECT_FOR_VIDEO_
        NSString *imgname = [response substringWithRange:NSMakeRange(38, response.length - 38)];
        
        return [[NSArray alloc] initWithObjects:imgname, @"0", nil];
    }
}

- (NSString *)parseAudioFromData:(NSString *)response {
    // Ignore VZCONTENTTRANSFER_REQUEST_FOR_MUSIC_[PATH]
    NSString *header = CT_REQUEST_FILE_AUDIO_HEADER;
    NSString *audioPath = [response substringWithRange:NSMakeRange(header.length, response.length - header.length)];
    
    return audioPath;
}

- (void)cancelTransfer:(CTTransferCancelMode)cancelMode {
    
    if (cancelMode == CTTransferCancelMode_Cancel) {
        self.transferStatusAnalytics = CTTransferStatus_Cancelled;
    }
    
    // Send cancel msg to recevier phone to stop heart beat msg
    NSString *str = CT_REQUEST_FILE_CANCEL;
    if ([[CTUserDevice userDevice].pairingType isEqualToString:kBonjour]) {
        if ([[CTBonjourManager sharedInstance] sendStream:[str dataUsingEncoding:NSUTF8StringEncoding]]) { // send
            self.bonjourManager.cancelRequestSent = YES;
            self.bonjourManager.transferFinished = YES;
            NSLog(@"send cancel in event");
        }
        self.bonjourManager.processCancelled = YES;
    } else { // P2P cancel
        [self.p2pManager writeCancelData:[str dataUsingEncoding:NSUTF8StringEncoding]];
        self.p2pManager.transferFinished = YES;
    }
}

- (void)senderSouldUpdateCurrentPayloadSize:(NSUInteger)payload {
    self.targetMediaType = @"file list";
    self.tartgetFileCount = 1;
    [self.receiverProgressManagerDelegate transferShouldUpdatePayload:payload];
}

- (void)senderRecevieSocketClose {
    
    self.transferStatusAnalytics = CTTransferStatus_Interrupted;
    
    [self updateDataInterruptedList];
    [self.receiverProgressManagerDelegate transferDidCancelled];
}

- (void)mvmCancelTransfer {
    NSString *str = CT_REQUEST_FILE_CANCEL;
    if ([[CTUserDevice userDevice].pairingType isEqualToString:kBonjour]) {
        if ([[CTBonjourManager sharedInstance] sendStream:[str dataUsingEncoding:NSUTF8StringEncoding]]) { // send
            self.bonjourManager.cancelRequestSent = YES;
        }
        self.bonjourManager.processCancelled = YES;
        self.bonjourManager.transferFinished = YES;

    } else { // P2P cancel
        [self.p2pManager writeCancelData:[str dataUsingEncoding:NSUTF8StringEncoding]];
    }

    [self updateDataInterruptedList];
}



@end
