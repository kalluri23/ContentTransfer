//
//  VZHomeViewController.m
//  VZTransferSocket
//
//  Created by VVM-MAC02 on 11/29/15.
//  Copyright © 2015 Testing. All rights reserved.
//

#import "VZContentHomeViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "VZDeviceMarco.h"
//#import <AVKit/AVKit.h>
#import "VZContentTrasnferConstant.h"


@interface VZContentHomeViewController ()

@end

@implementation VZContentHomeViewController
@synthesize assets,assetsGroup,assetsLibrary,hashTableUrltofileName;
@synthesize phoneSetupLbl,setAutoLockLbl,plugAutoLbl,repeatLbl,phoneSetupCompleted;
@synthesize lbl1,lbl2,lbl3,Yesbtn;
@synthesize app;



- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // To Remove all Default NSUser Default
    
//    AppDelegate *app1 = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    
//    app1.VZCTAppAnalytics = [[VZAnalytics alloc] initWithApplicationName:CONTENT_TRANSFER_APP_NAME withUploadURL:nil isLockFrameWork:NO withExtraInfo:nil];
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"TOTALDOWNLOADEDDATA"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"STARTTIME"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"ENDTIME"];
    
    self.navigationItem.title = @"Content Transfer";
    
    // set All UILabel
    self.setAutoLockLbl.font= self.plugAutoLbl.font = self.repeatLbl.font = [CTMVMFonts mvmBookFontOfSize:14];
    self.phoneSetupLbl.font  = [CTMVMFonts mvmBookFontOfSize:24];
    self.phoneSetupCompleted.font = [CTMVMFonts mvmBookFontOfSize:16];
    self.lbl1.font = self.lbl2.font = self.lbl3.font = [CTMVMFonts mvmBookFontOfSize:14];
    
    [CTMVMButtons primaryRedButton:self.Yesbtn constrainHeight:YES];
    
    [[CTMVMSessionSingleton sharedGlobal] setContentTransferActive:YES];
    
    [[VZContentTransferSingleton sharedGlobal] registerWithMVM];
    
//    app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    [[CTMVMSessionSingleton sharedGlobal].vzctAnalyticsObject trackController:self withName:@"VZContentHomeViewController" withExtraInfo:@{} isEncryptedExtras:false];
    
    [self.Yesbtn addTarget:self action:@selector(clickOnnOkBtn:) forControlEvents:UIControlEventTouchUpInside];
    
//    [self.Yesbtn addTarget:self action:@selector(clickOnnOkBtn:) forControlEvents:UIControlEventTouchUpInside];
    
    self.uuid_string = [NSString stringWithFormat:@"%@",[[NSUUID UUID] UUIDString]];
    
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    
    [userDefault setValue:self.uuid_string forKey:CONTENT_TRANSFER_DEVICE_UUID];

    
}


- (IBAction)appVersion:(id)sender {
    
    [self displayAlter:@"Build Version: 1.0.0\n Date : 03.25.2016"];
    
//    [self.navigationController popToRootViewControllerAnimated:YES];
    
//[((UINavigationController*)appDelegate.tabBarController.selectedViewController) pushViewController:myViewController animated:YES];
    
}


//- (void)fetchImageNow {
//    
//    NSURL *imageUrl = [[NSURL alloc] init];
//    __block UIImage *largeimage = [[UIImage alloc] init];
//    __block NSData *imageData = [[NSData alloc] init];
//
//    
//    for (NSDictionary *photmetaData in hashTableUrltofileName) {
//        
//    
//            NSArray *arrayUrl = [photmetaData allValues];
//        
//        imageUrl = [arrayUrl objectAtIndex:0];
//        
//            
//            ALAssetsLibraryAssetForURLResultBlock resultblock = ^(ALAsset *myasset)
//            {
//                ALAssetRepresentation *rep = [myasset defaultRepresentation];
//                CGImageRef iref = [rep fullResolutionImage];
//                if (iref) {
//                    largeimage = [UIImage imageWithCGImage:iref];
//                    
//                    imageData = UIImageJPEGRepresentation(largeimage,0.0);
//                    
//                     imageData = UIImagePNGRepresentation(largeimage);
//                    
//                    
////                    NSRange range = [imageName rangeOfString:@"JPG"];
////                    if (range.location != NSNotFound) {
////                        
////                        imageData = UIImageJPEGRepresentation(largeimage,0.0);
////                        
////                    } else {
////                        
////                        imageData = UIImagePNGRepresentation(largeimage);
////                    }
//                }
//                
//                
//            };
//            
//            //
//            ALAssetsLibraryAccessFailureBlock failureblock  = ^(NSError *myerror)
//            {
//                DebugLog(@"booya, cant get image - %@",[myerror localizedDescription]);
//                
//            };
//            
//            if(imageUrl!=nil)
//            {
//                
//                ALAssetsLibrary* assetslibrary = [[ALAssetsLibrary alloc] init];
//                [assetslibrary assetForURL:imageUrl
//                               resultBlock:resultblock
//                              failureBlock:failureblock];
//            }
//
//        
//    }
//    
//    
//   }

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)clickedSettingBtn:(id)sender {
    
    [self displayAlter:@"Launch settings Icon,\nChoose general,\nChoose auto-lock,\nChoose never"];
    
    [[CTMVMSessionSingleton sharedGlobal].vzctAnalyticsObject trackEvent:self.view withTrackTag:CONTENT_TRANSFER_CLICKED_SETTING];
    
}
- (IBAction)clickedBatteryStatusBtn:(id)sender {
    
    [self displayAlter:@"To prevent possible data loss, please connect both phones to chargers"];
    
    [[CTMVMSessionSingleton sharedGlobal].vzctAnalyticsObject trackEvent:self.view withTrackTag:CONTENT_TRANSFER_CLICKED_BATTERY];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void) displayAlter:(NSString *)str {
    
    
    CTMVMAlertAction *cancelAction = [CTMVMAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
    
 
    
    CTMVMAlertObject* alertObject = [[CTMVMAlertObject alloc] initWithTitle:@"Content Transfer"
                                                                message:str
                                                           cancelAction:cancelAction otherActions:nil isGreedy:NO];
    
    
    [[CTMVMAlertHandler sharedAlertHandler] showAlertWithAlertObject:alertObject];
    
    
    
    
//    [[CTMVMAlertHandler sharedAlertHandler] showAlertWithTitle:@"Content transfer" message:str cancelAction:cancelAction otherActions:nil isGreedy:NO];
    
   
    
    }



// Override function for tabcar controller

//- (void) backButtonPressed {
//    
//    
////    UIAlertController * alert=   [UIAlertController
////                                  alertControllerWithTitle:@"Back"
////                                  message:[NSString stringWithFormat:@"Are you sure you want to go back to the home page"]
////                                  preferredStyle:UIAlertControllerStyleAlert];
////    
////    UIAlertAction* ok = [UIAlertAction
////                         actionWithTitle:@"Yes"
////                         style:UIAlertActionStyleDefault
////                         handler:^(UIAlertAction * action)
////                         {
////                             [self.navigationController popToRootViewControllerAnimated:YES];
////                             [alert dismissViewControllerAnimated:YES completion:nil];
////                         }];
////    
////    
////    
////    UIAlertAction* no = [UIAlertAction
////                         actionWithTitle:@"No"
////                         style:UIAlertActionStyleDefault
////                         handler:^(UIAlertAction * action)
////                         {
////                             
////                             [alert dismissViewControllerAnimated:YES completion:nil];
////                         }];
////    
////    
////    [alert addAction:no];
////    [alert addAction:ok];
////    
////    
////    [self presentViewController:alert animated:YES completion:nil];
//    
//    
//    
//    
//    CTMVMAlertAction *okAction = [CTMVMAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
//        [[VZContentTransferSingleton sharedGlobal] deregisterWithMVM];
////        [self.navigationController popToRootViewControllerAnimated:YES];
//                                 }];
//    
//    
//    CTMVMAlertAction *cancelAction = [CTMVMAlertAction actionWithTitle:@"No" style:UIAlertActionStyleCancel handler:nil];
//
//    
//[[CTMVMAlertHandler sharedAlertHandler] showAlertWithTitle:@"Back" message:@"Are you sure you want to go back to the home page" cancelAction:cancelAction otherActions:@[okAction] isGreedy:NO];
//    
//    
//}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

-(void)clickOnnOkBtn:(id)sender {
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    
    NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
    
    [dict setValue:currSysVer forKey:CONTENT_TRANSFER_OS_VERSION];
    
    VZDeviceMarco *deviceMacro = [[VZDeviceMarco alloc] init];
    
    NSString *deviceModel = [deviceMacro.models objectForKey:[deviceMacro getDeviceModel]];
    
    [dict setValue:deviceModel forKey:CONTENT_TRANSFER_PHONE_MODEL];
    
    [dict setValue:self.uuid_string forKey:@"DeviceUUID"];
    
//    [[CTMVMSessionSingleton sharedGlobal].vzctAnalyticsObject trackEvent:self.view withTrackTag:CONTENT_TRANSFER_PHONE_HOME_SCREEN];
    
    [[CTMVMSessionSingleton sharedGlobal].vzctAnalyticsObject trackEvent:self.view withTrackTag:CONTENT_TRANSFER_PHONE_HOME_SCREEN withExtraInfo:dict isEncryptedExtras:false];
    
   
}


@end
