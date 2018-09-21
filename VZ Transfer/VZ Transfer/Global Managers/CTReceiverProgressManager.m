//
//  CTReceiverProgressManager.m
//  contenttransfer
//
//  Created by Hadapad, Prakash on 9/8/16.
//  Copyright © 2016 Verizon Wireless. All rights reserved.
//

#import "CTReceiverProgressManager.h"
#import "NSString+CTRootDocument.h"
#import "CTUserDefaults.h"
#import "CTReceiverProgressViewController.h"
#import "CTBonjourManager.h"
#import "CTReceiverReadyViewController.h"

@interface CTReceiverProgressManager () <CTReceiverBonjourManagerDelegate,CTReceiverP2pManagerDelegate>

@property (nonatomic, strong) NSString *pairingType;
/*! Transfer time duration for acutal receving files.*/
@property (nonatomic, assign) NSTimeInterval actualReceivingTime;
/*! Date restored when last time received the package and updated the UI.*/
@property (nonatomic, copy) NSDate *lastPackageReceivedDate;
/*! Average speed data.*/
@property (nonatomic, assign) double currentDataDownloadSpeed;

@end

@implementation CTReceiverProgressManager
@synthesize progressInfo;

- (instancetype)initWithDelegate:(id<CTReceiverProgressManagerDelegate>)delegate {
    self = [super init];
    if (self) {
        _delegate = delegate;
        
        _pairingType = [CTUserDevice userDevice].pairingType;
        if ([_pairingType isEqualToString:kBonjour]) {
            [self initBonjourManager];
        }
        
        progressInfo = [[CTProgressInfo alloc] init];
        [progressInfo addObserver:self forKeyPath:@"transferredAmount" options:NSKeyValueObservingOptionNew context:nil];
        
        _totalPayload = 0;
    }
    
    return self;
}

- (void)initBonjourManager {
    self.bonjourManager = [[CTReceiverBonjourManager alloc] initWithDelegate:self];
}

- (void)setwriteAsyncSocket:(GCDAsyncSocket *)socket {
    self.p2pManager = [[CTReceiverP2PManager alloc] init]; // init p2pRecevierManager
    self.p2pManager.delegate = self;
    [self.p2pManager setsocketDelegate:socket];
}

- (void)createClientCommportSocket {
    if (self.p2pManager) {
        [self.p2pManager createClientCommPortSocket];
    }
}

#pragma mark - Receiver Bonjour Manager Delegate
- (void)transferWillStart {
    self.transferStartTime = [NSDate date];
    self.maxSpeed = 0;
    [self.delegate viewShouldGotoNextView];
}

- (void)transferShouldCancel {
    if ([self.delegate respondsToSelector:@selector(viewShouldCancel)]) {
        [self.delegate viewShouldCancel];
    }
}

- (void)RequestToPopToRootViewController {
    if ([self.delegate respondsToSelector:@selector(goToRootViewController)]) {
        [self.delegate goToRootViewController];
    }
}

- (void)transferDidFinished {
    if ([self.delegate respondsToSelector:@selector(viewShouldGotoSavingView)]) {
        [self.delegate viewShouldGotoSavingView];
    }
}

- (void)transferDidCancelled {
    if ([self.delegate respondsToSelector:@selector(viewShouldGotoSavingView)]) {
        [self.delegate viewShouldGotoSavingView];
    }else if ([self.delegate isKindOfClass:[CTReceiverReadyViewController class]]){
        [self.delegate viewShouldCancel];
    }
}

- (void)transferShouldAllowSaving {
    if ([self.delegate respondsToSelector:@selector(viewShouldAllowSavingProcess)]) {
        [self.delegate viewShouldAllowSavingProcess];
    }
}

- (void)transferWillInterrupted:(NSInteger)reason {
    if ([self.delegate respondsToSelector:@selector(viewShouldInterrupt)]) {
        [self.delegate viewShouldInterrupt];
    }
}

- (void)senderTransferShouldBlockForReconnect:(NSString *)warningText {
    if ([self.delegate respondsToSelector:@selector(transferShouldBlockForReconnect:)]) {
        [self.delegate transferShouldBlockForReconnect:warningText];
    }
}

- (void)senderTransferShouldEnableForContiue:(BOOL)success {
    if ([self.delegate respondsToSelector:@selector(transferShouldEnableForContinue:)])
        [self.delegate transferShouldEnableForContinue:success];
}

#pragma Other methods
- (void)cancelTransfer:(CTTransferCancelMode)cancelMode {
    // Send cancel msg to recevier phone to stop heart beat msg
    NSString *str = CT_REQUEST_FILE_CANCEL;
    if ([[CTUserDevice userDevice].pairingType isEqualToString:kBonjour]) {
        if ([[CTBonjourManager sharedInstance] sendStream:[str dataUsingEncoding:NSUTF8StringEncoding]]) {
            if (cancelMode != CTTransferCancelMode_UserForceExit) {
                [self.bonjourManager processDidPressCancel];
            }
        }
    } else {
        [self.p2pManager writeDataToSocketCommSocket:[str dataUsingEncoding:NSUTF8StringEncoding]];
        [self.p2pManager processDidPressCancel];
    }
}

- (void)inSufficentStorageAvailalbe:(NSNumber *)availalbeSpace {
    
    [self.delegate didGetErrorLowSpaceForAmount:availalbeSpace];
}

- (void)totalPayLoadRecevied:(NSNumber *)totalPayload {
    
    self.totalPayload = [totalPayload longLongValue];
}

- (void)dataPacketRecevied:(long)packetSize mediaInfo:(NSDictionary *)mediaInfo {
#warning TODO: Should change this logic for one-to-many. Now just keep it. When one-to-many become public, need to change.
    
    double totalDataRecevied = [[mediaInfo objectForKey:@"totalSizeReceived"] doubleValue] / (1024 * 1024); // Total data received in MB including duplicate size.
    if (totalDataRecevied > 0 && totalDataRecevied < 0.1) {
        totalDataRecevied = 0.1f;
    }
    NSString *only2DecimalsStr = [NSString stringWithFormat:@"%.2f", totalDataRecevied];
    totalDataRecevied = [only2DecimalsStr doubleValue];
    
    // Calulate the time diff with start time
    NSDate *currentTime = [NSDate date];
    NSTimeInterval secondsBetween = [currentTime timeIntervalSinceDate:self.transferStartTime]; // Total time, use for update UI information.
    if (![[mediaInfo objectForKey:@"isDuplicate"] boolValue]) { // If it's not duplicate
        if (!self.lastPackageReceivedDate) {
            // Very first time received package, actual time will be equal to total time.
            self.actualReceivingTime += secondsBetween;
        } else {
            // Get time diff between current time and the time received last package, and add them all.
            self.actualReceivingTime += [currentTime timeIntervalSinceDate:self.lastPackageReceivedDate];
        }
    }
    self.lastPackageReceivedDate = currentTime;
    
    // Calulate current speed
    double updateUISpeed            = 0;
    if ([[mediaInfo objectForKey:@"isDuplicate"] boolValue]) { // If it's duplicate, speed always be 1Mbps.
        updateUISpeed = 1.0f;
    } else { // If it's not duplicate logic, speed will be actually received file size / acutally receiving time.
        updateUISpeed = self.currentDataDownloadSpeed = ([[mediaInfo objectForKey:@"actualReceived"] doubleValue] / (1024 * 1024)) / (double)self.actualReceivingTime * 8;
    }
//    DebugLog(@"->Transfer Speed: %f", updateUISpeed);
//    DebugLog(@"->Avg Speed: %f", self.currentDataDownloadSpeed);
    // Update the max speed for local analytics. Not using, keep it for now.
    if (self.currentDataDownloadSpeed > self.maxSpeed) {
        self.maxSpeed = self.currentDataDownloadSpeed;
    }
    
    // Calulate the time left.
    if (updateUISpeed == 0) {
        updateUISpeed = 1.0f;
    }
    NSTimeInterval estimatedSeconds = (self.totalPayload / (1024 * 1024) - totalDataRecevied) / updateUISpeed * 8;
    
    int hh = estimatedSeconds / (60 * 60);
    double rem = fmod(estimatedSeconds, (60 * 60));
    int mm = rem / 60;
    rem = fmod(rem, 60);
    int ss = rem;
    
    if (ss < 0) {
        ss = 0;
    }
    NSString *estimatedtimeLefted = [NSString stringWithFormat:@"%02d:%02d:%02d", hh, mm, ss];
    @synchronized (self) {
//        NSLog(@"queue:creating new object!");
        self.progressInfo.timeLeft                    = estimatedtimeLefted;
        self.progressInfo.speed                       = [NSNumber numberWithDouble:updateUISpeed];
        self.progressInfo.generalAvgSpeed             = [NSNumber numberWithDouble:self.currentDataDownloadSpeed];
        self.progressInfo.totalDataAmount             = [NSNumber numberWithLongLong:self.totalPayload];
        self.progressInfo.acutalTransferredAmount     = [mediaInfo objectForKey:@"actualReceived"];
        [[NSUserDefaults standardUserDefaults] setObject:self.progressInfo.acutalTransferredAmount forKey:@"NonDuplicateDataSize"];
        self.progressInfo.mediaType                   = [mediaInfo valueForKey:@"MEDIATYPE"];
        self.progressInfo.transferredCount            = [mediaInfo valueForKey:@"TOTALFILERECEVIED"];
        self.progressInfo.totalFileCount              = [mediaInfo valueForKey:@"TOTALFILECOUNT"];
        self.progressInfo.totalSectionSize            = (NSNumber *)[mediaInfo valueForKey:@"sectionSize"];
        self.progressInfo.totalSectionSizeTransferred = (NSNumber *)[mediaInfo valueForKey:@"sectionTransferred"];
        
        // Newly added for failure handshake
        self.progressInfo.transferFailureCounts       = (NSArray *)[mediaInfo objectForKey:@"transferFailureCounts"];
        self.progressInfo.transferFailureSize         = (NSArray *)[mediaInfo objectForKey:@"transferFailureSize"];
        self.progressInfo.transferredAmount           = [NSNumber numberWithDouble:totalDataRecevied];
    }
}

- (void)receiverPermissionCancelRequestForBonjour {
    [self.bonjourManager stopTransferDueToPermission];
}

- (void)mvmCancelTransfer {
    NSString *str = CT_REQUEST_FILE_CANCEL;
    if ([[CTUserDevice userDevice].pairingType isEqualToString:kBonjour]) {
        [[CTBonjourManager sharedInstance] sendStream:[str dataUsingEncoding:NSUTF8StringEncoding]];
        [[CTBonjourManager sharedInstance] closeStreams];
    } else { // P2P cancel
        [self.p2pManager writeDataToSocketCommSocket:[str dataUsingEncoding:NSUTF8StringEncoding]];
        [self.p2pManager processDidPressCancelFromMVM];
    }
}

- (void)tansferFailedBeforeStarted {
    [self.delegate tansferFailedBeforeStarted];
}

- (CTFileList *)fileList {
    if ([self.pairingType isEqualToString:kBonjour]) {
        return self.bonjourManager.helper.fileListManager.fileList;
    } else {
        return self.p2pManager.helper.fileListManager.fileList;
    }
}

#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"transferredAmount"]) {
        if ([self.delegate respondsToSelector:@selector(updateUIWithProgressInfo:)]) { // Update information by size change, not by package received(too many times).
            [self.delegate updateUIWithProgressInfo:self.progressInfo];
        }
    }
}

- (void)removeObeserver {
    @try {
        [progressInfo removeObserver:self forKeyPath:@"transferredAmount" context:nil];
    } @catch (NSException *exception) {
        NSLog(@"No observer added.");
    }
}

- (void)dealloc {
    [self removeObeserver];
}

@end
