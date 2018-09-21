//
//  VZAnDBumpActionSender.m
//  myverizon
//
//  Created by Hadapad, Prakash on 4/1/16.
//  Copyright © 2016 Verizon Wireless. All rights reserved.
//

#import "VZAnDBumpActionSender.h"
#import "CDActivityIndicatorView.h"

#import <SystemConfiguration/SystemConfiguration.h>

// Header for audio
#import "AMRecorder.h"
#import "AudioSessionManager.h"
#import "ShakingAlerts.h"
#import <AVFoundation/AVFoundation.h>

#import "CTMVMFonts.h"
#import "VZContentTrasnferConstant.h"


@interface VZAnDBumpActionSender ()

@property (nonatomic, assign) BOOL invitationSent;
@property (nonatomic, assign) BOOL blockUI;

@property (weak, nonatomic) IBOutlet CDActivityIndicatorView *activityIndicator;

@end

@implementation VZAnDBumpActionSender
@synthesize bumpAnimationImgView;
@synthesize invitationSent;
@synthesize orLbl;
@synthesize availablePhoneLbl;
@synthesize shakeThisPhoneLbl;
@synthesize chooseNewPhone;
@synthesize cancelBtn,notFoundBtn;
@synthesize goBack;
@synthesize app;
@synthesize deviceName;
@synthesize deviceIPaddress;
@synthesize asyncSocket;
@synthesize listenrSocket;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.asyncSocket.delegate = self;
    self.listenrSocket.delegate = self;
    
    self.deviceListView.delegate = self;
    self.deviceListView.dataSource = self;
    
    self.deviceListView.layer.borderWidth = 0.75f;
    self.deviceListView.layer.cornerRadius = 15.0f;
    self.deviceListView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    
    [CTMVMButtons primaryRedButton:self.cancelBtn constrainHeight:YES];
    [CTMVMButtons primaryRedButton:self.notFoundBtn constrainHeight:YES];
    
    // Setup image animation
    [self setupAnimationBumpImageView];
    
    self.availablePhoneLbl.font = [CTMVMFonts mvmBookFontOfSize:18];
    
    self.orLbl.font = self.shakeThisPhoneLbl.font = self.chooseNewPhone.font = [CTMVMFonts mvmBookFontOfSize:14];
    
    self.navigationItem.title = @"Content Transfer";
    //    app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    [[CTMVMSessionSingleton sharedGlobal].vzctAnalyticsObject trackController:self withName:@"VZBumpActionSender" withExtraInfo:@{} isEncryptedExtras:false];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"device_name_cell" forIndexPath:indexPath];
    [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
    
    
    cell.textLabel.text = deviceName;
    [cell.textLabel setTextAlignment:NSTextAlignmentLeft];
    cell.textLabel.font = [CTMVMFonts mvmBookFontOfSize:14];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    // Find the service associated with the cell and start a connection to that
    
    [[CTMVMSessionSingleton sharedGlobal].vzctAnalyticsObject trackEvent:self.view withTrackTag:CONTENT_TRANSFER_BONJOUR_LIST];
    
    [self sendSecurityKeytoOtherDevice];
    
    //    [self performSegueWithIdentifier:@"showTransfersegueAnD" sender:self];
}


- (void) sendSecurityKeytoOtherDevice {
    
    asyncSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    NSError *error = nil;
    uint16_t port = REGULAR_PORT;
    
    if ([asyncSocket connectToHost:self.deviceIPaddress onPort:port withTimeout:-1 error:&error])
    {
        DebugLog(@"Unable to connect to due to invalid configuration: %@", error);
    } else {
        DebugLog(@"Connecting...");
        
    }
    
}

- (void) socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port {
    
    
    NSString *shareKey = [[NSString alloc] initWithFormat:@"VZCONTENTTRANSFERSECURITYKEYFROMSENIOS#123456"];
    
    NSData *requestData = [shareKey dataUsingEncoding:NSUTF8StringEncoding];
    
    [asyncSocket writeData:requestData withTimeout: 0.0 tag:0];
    [asyncSocket writeData:[GCDAsyncSocket CRLFData] withTimeout:0.0 tag:0];
    
    [self performSegueWithIdentifier:@"showTransfersegueAnD" sender:self];
    
    [asyncSocket readDataWithTimeout:-1.0 tag:10];
    
}

- (void) socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag {
    DebugLog(@"socket:didWriteDataWithTag: %ld",tag);
    
}


- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}


- (void) setupAnimationBumpImageView {
    
    self.bumpAnimationImgView.animationImages = [NSArray arrayWithObjects:
                                    [ UIImage getImageFromBundleWithImageName:@"anim_knock_1x_00" ],[ UIImage getImageFromBundleWithImageName:@"anim_knock_1x_01" ],[ UIImage getImageFromBundleWithImageName:@"anim_knock_1x_02" ],[ UIImage getImageFromBundleWithImageName:@"anim_knock_1x_03" ],[ UIImage getImageFromBundleWithImageName:@"anim_knock_1x_04" ],[ UIImage getImageFromBundleWithImageName:@"anim_knock_1x_05" ],[ UIImage getImageFromBundleWithImageName:@"anim_knock_1x_06" ],[ UIImage getImageFromBundleWithImageName:@"anim_knock_1x_07" ],[ UIImage getImageFromBundleWithImageName:@"anim_knock_1x_08" ],[ UIImage getImageFromBundleWithImageName:@"anim_knock_1x_09" ],[ UIImage getImageFromBundleWithImageName:@"anim_knock_1x_10" ],[ UIImage getImageFromBundleWithImageName:@"anim_knock_1x_11" ],[ UIImage getImageFromBundleWithImageName:@"anim_knock_1x_12" ],[ UIImage getImageFromBundleWithImageName:@"anim_knock_1x_13" ],[ UIImage getImageFromBundleWithImageName:@"anim_knock_1x_14" ],[ UIImage getImageFromBundleWithImageName:@"anim_knock_1x_15" ],[ UIImage getImageFromBundleWithImageName:@"anim_knock_1x_16" ],[ UIImage getImageFromBundleWithImageName:@"anim_knock_1x_17" ],[ UIImage getImageFromBundleWithImageName:@"anim_knock_1x_18" ],[ UIImage getImageFromBundleWithImageName:@"anim_knock_1x_18" ],[ UIImage getImageFromBundleWithImageName:@"anim_knock_1x_20" ],[ UIImage getImageFromBundleWithImageName:@"anim_knock_1x_21" ],[ UIImage getImageFromBundleWithImageName:@"anim_knock_1x_22" ],[ UIImage getImageFromBundleWithImageName:@"anim_knock_1x_23" ],[ UIImage getImageFromBundleWithImageName:@"anim_knock_1x_24" ],[ UIImage getImageFromBundleWithImageName:@"anim_knock_1x_25" ],[ UIImage getImageFromBundleWithImageName:@"anim_knock_1x_26" ],[ UIImage getImageFromBundleWithImageName:@"anim_knock_1x_27" ],nil];
    
    // all frames will execute in 1.75 seconds
    self.bumpAnimationImgView.animationDuration = 1.75;
    // repeat the animation forever
    self.bumpAnimationImgView.animationRepeatCount = 0;
}

- (void)startAnimation {
    [self.bumpAnimationImgView startAnimating];
}

- (void)stopAnimation {
    [self.bumpAnimationImgView stopAnimating];
}

- (IBAction)clickedOnCancelBtn:(id)sender {
    // Close stream once this view
    
    [[self navigationController] popViewControllerAnimated:YES];
    //    [[BonjourManager sharedInstance] closeStreamForController:self];
    
    [[CTMVMSessionSingleton sharedGlobal].vzctAnalyticsObject trackEvent:self.view withTrackTag:CONTENT_TRANSFER_CLICKED_CANCEL];
}

- (IBAction)notFoundBtn:(id)sender {
    // Close stream once this view
    //    [[BonjourManager sharedInstance] closeStreamForController:self];
    
    [[CTMVMSessionSingleton sharedGlobal].vzctAnalyticsObject trackEvent:self.view withTrackTag:CONTENT_TRANSFER_NOTFOUND];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showTransfersegueAnD"]) {
        
        //    } else if ([segue.identifier isEqualToString:@"sender_wifi_goback"]) {
        //        VZBumpActionSender *controller = (VZBumpActionSender *)segue.destinationViewController;
        //        controller.goBack = YES;
        
        VZTransferDataViewController *controller = (VZTransferDataViewController *)segue.destinationViewController;
        controller.asyncSocket = asyncSocket;
        controller.listenOnPort = listenrSocket;
    }
}




- (void) socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    
    NSString *response = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    NSRange range = [response rangeOfString:@"VZCONTENTTRANSFERSECURITYKEYFROMSENAND#"];  // total 39
    
    //    overlayActivity.hidden = YES;
    //    [overlayActivity stopAnimating];
    //
    //    if (range.location != NSNotFound) {
    //
    //        NSData *tempdata = [data subdataWithRange:NSMakeRange(39, data.length - 39)];
    //        _deviceName = [[NSString alloc] initWithData:tempdata encoding:NSUTF8StringEncoding];
    //
    //        [self performSegueWithIdentifier:@"AnD_sender_yes_segue" sender:self];
    //    }
}


@end
