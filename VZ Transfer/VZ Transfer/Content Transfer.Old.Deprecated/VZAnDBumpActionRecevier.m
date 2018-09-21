//
//  VZAnDBumpActionRecevier.m
//  myverizon
//
//  Created by Hadapad, Prakash on 4/4/16.
//  Copyright © 2016 Verizon Wireless. All rights reserved.
//

#import "VZAnDBumpActionRecevier.h"
#import "CDActivityIndicatorView.h"
#import "CTMVMFonts.h"
#import "VZContentTrasnferConstant.h"

@interface VZAnDBumpActionRecevier ()

@property (weak, nonatomic) IBOutlet UILabel *recevierTitleLabel;
@property (weak, nonatomic) IBOutlet CDActivityIndicatorView *activityIndcator;

@end

@implementation VZAnDBumpActionRecevier

@synthesize bumpImageView;
@synthesize availablePhoneLbl;
@synthesize app;
@synthesize goBack;
@synthesize asyncSocket;
@synthesize listenOnPort;


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.availablePhoneLbl.font = [CTMVMFonts mvmBookFontOfSize:18];
    self.shakeThisPhone.font = [CTMVMFonts mvmBookFontOfSize:14];
    
    self.availablePhoneLbl.text= [[UIDevice currentDevice] name];
    
    [CTMVMButtons primaryRedButton:self.cancelBtn constrainHeight:YES];
    [CTMVMButtons primaryRedButton:self.notFoundBtn constrainHeight:YES];
    
    self.navigationItem.title = @"Content Transfer";
    
    app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    [[CTMVMSessionSingleton sharedGlobal].vzctAnalyticsObject trackController:self withName:@"VZAnDBumpActionReceiver" withExtraInfo:@{} isEncryptedExtras:false];
    
    // Setup image animation
    [self setupAnimationBumpImageView];
    
    [self startAnimation];
    
    
    listenOnPort = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    NSError *error = nil;
    uint16_t port = REGULAR_PORT;
    
    if (![listenOnPort acceptOnPort:port error:&error]) {
        DebugLog(@"No i am not able to listen on this port");
    } else {
        DebugLog(@"Yes i am able to listen on this port");
    }
    
    
    asyncSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    
    //    listenOnPort = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    
    if (![listenOnPort acceptOnPort:port error:&error]) {
        
        DebugLog(@"Yes i am able to listen on this port");
    } else {
        
        DebugLog(@"No i am not able to listen on this port");
    }
    
    asyncSocket.delegate = self;
    listenOnPort.delegate = self;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"CurrentViewController" object:nil userInfo:[NSDictionary dictionaryWithObjectsAndKeys:self, @"lastViewController", nil]]; // post a notification to save current view controller
    
    //    if ([VZDeviceMarco isiPhone4AndBelow] && !goBack) {
    //        CTMVMAlertAction *cancelAction = [CTMVMAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    //
    //        CTMVMAlertAction *okAction = [CTMVMAlertAction actionWithTitle:@"Connect" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
    //            [self performSegueWithIdentifier:@"receiver_go_to_p2p_segue" sender:self];
    //        }];
    //
    //
    //        [[CTMVMAlertHandler sharedAlertHandler] showAlertWithTitle:@"Content transfer" message:@"Your device only supports Hotspot method." cancelAction:cancelAction otherActions:@[okAction] isGreedy:NO];
    //    }
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
}


- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

- (IBAction)clickedCancelBtn:(id)sender {
    // Close stream once this view
    
    [[self navigationController] popViewControllerAnimated:YES];
    //    [[BonjourManager sharedInstance] closeStreamForController:self];
    
    [[CTMVMSessionSingleton sharedGlobal].vzctAnalyticsObject trackEvent:self.view withTrackTag:CONTENT_TRANSFER_CLICKED_CANCEL];
}

- (IBAction)clickedNotFoundBtn:(id)sender {
    // Close stream once this view
    //    [[BonjourManager sharedInstance] closeStreamForController:self];
    
    [[CTMVMSessionSingleton sharedGlobal].vzctAnalyticsObject trackEvent:self.view withTrackTag:CONTENT_TRANSFER_NOTFOUND];
}


- (void) setupAnimationBumpImageView {
   
    self.bumpImageView.animationImages = [NSArray arrayWithObjects:
                                          [UIImage getImageFromBundleWithImageName:@"anim_knock_1x_00"],
                                          [UIImage getImageFromBundleWithImageName:@"anim_knock_1x_01"],
                                          [ UIImage getImageFromBundleWithImageName:@"anim_knock_1x_02" ],[ UIImage getImageFromBundleWithImageName:@"anim_knock_1x_03" ],[ UIImage getImageFromBundleWithImageName:@"anim_knock_1x_04" ],[ UIImage getImageFromBundleWithImageName:@"anim_knock_1x_05" ],[ UIImage getImageFromBundleWithImageName:@"anim_knock_1x_06" ],[ UIImage getImageFromBundleWithImageName:@"anim_knock_1x_07" ],[ UIImage getImageFromBundleWithImageName:@"anim_knock_1x_08" ],[ UIImage getImageFromBundleWithImageName:@"anim_knock_1x_09" ],[ UIImage getImageFromBundleWithImageName:@"anim_knock_1x_10" ],[ UIImage getImageFromBundleWithImageName:@"anim_knock_1x_11" ],[ UIImage getImageFromBundleWithImageName:@"anim_knock_1x_12" ],[ UIImage getImageFromBundleWithImageName:@"anim_knock_1x_13" ],[ UIImage getImageFromBundleWithImageName:@"anim_knock_1x_14" ],[ UIImage getImageFromBundleWithImageName:@"anim_knock_1x_15" ],[ UIImage getImageFromBundleWithImageName:@"anim_knock_1x_16" ],[ UIImage getImageFromBundleWithImageName:@"anim_knock_1x_17" ],[ UIImage getImageFromBundleWithImageName:@"anim_knock_1x_18" ],[ UIImage getImageFromBundleWithImageName:@"anim_knock_1x_18" ],[ UIImage getImageFromBundleWithImageName:@"anim_knock_1x_20" ],[ UIImage getImageFromBundleWithImageName:@"anim_knock_1x_21" ],[ UIImage getImageFromBundleWithImageName:@"anim_knock_1x_22" ],[ UIImage getImageFromBundleWithImageName:@"anim_knock_1x_23" ],[ UIImage getImageFromBundleWithImageName:@"anim_knock_1x_24" ],[ UIImage getImageFromBundleWithImageName:@"anim_knock_1x_25" ],[ UIImage getImageFromBundleWithImageName:@"anim_knock_1x_26" ],[ UIImage getImageFromBundleWithImageName:@"anim_knock_1x_27" ],nil];
    
    // all frames will execute in 1.75 seconds
    self.bumpImageView.animationDuration = 1.75;
    // repeat the animation forever
    self.bumpImageView.animationRepeatCount = 0;
}

- (void)stopAnimation {
    [self.bumpImageView stopAnimating];
}

- (void)startAnimation {
    [self.bumpImageView startAnimating];
}

#pragma mark - Shaking detect methods

// Enable Shaking support for current controller
- (void)enableShakeDectectSupport {
    [[UIApplication sharedApplication] setApplicationSupportsShakeToEdit:YES];
    [self becomeFirstResponder];
}


- (void) socket:(GCDAsyncSocket *)sock didAcceptNewSocket:(GCDAsyncSocket *)newSocket {
    
    asyncSocket = newSocket;
    asyncSocket.delegate = self;
    
    [asyncSocket readDataWithTimeout:-1 tag:0];
    [[CTMVMSessionSingleton sharedGlobal].vzctAnalyticsObject trackEvent:self.view withTrackTag:CONTENT_TRANSFER_CONNECTION_IS_SUCCESSFUL_RECEIVER];
    
}

- (void) socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port {
    
    DebugLog(@"Connected to Host : %@",host);
}

- (void) socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    
    NSString *response = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    NSRange range = [response rangeOfString:@"VZCONTENTTRANSFERSECURITYKEYFROMSENAND#"];  // total 39
    
    //    overlayActivity.hidden = YES;
    //    [overlayActivity stopAnimating];
    
    if (range.location != NSNotFound) {
        
        NSData *tempdata = [data subdataWithRange:NSMakeRange(39, data.length - 39)];
        NSString *str = [[NSString alloc] initWithData:tempdata encoding:NSUTF8StringEncoding];
        
        NSString *shareKey = [[NSString alloc] initWithFormat:@"VZCONTENTTRANSFERSECURITYKEYFROMRECIOS#%@",str];
        
        NSData *requestData = [shareKey dataUsingEncoding:NSUTF8StringEncoding];
        
        [asyncSocket writeData:requestData withTimeout: 0.0 tag:0];
        [asyncSocket writeData:[GCDAsyncSocket CRLFData] withTimeout:0.0 tag:0];
        
        [asyncSocket readDataWithTimeout:-1.0 tag:10];
        
        [self performSegueWithIdentifier:@"VZReceiveSegueAnD" sender:self];
    }
    
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"VZReceiveSegueAnD"]) {
        
        //    } else if ([segue.identifier isEqualToString:@"receiver_wifi_back"]) {
        //        VZBumpActionReceiver *controller = (VZBumpActionReceiver *)segue.destinationViewController;
        //        controller.goBack = YES;
        
        VZReceiveDataViewController *controller = (VZReceiveDataViewController *)segue.destinationViewController;
        //        controller.deviceIPaddress = address;
        controller.asyncSocket = asyncSocket;
        controller.listenOnPort = listenOnPort;
    }
}

@end
