//
//  VZPhoneCombinationVC.m
//  myverizon
//
//  Created by Hadapad, Prakash on 3/21/16.
//  Copyright © 2016 Verizon Wireless. All rights reserved.
//

#import "VZPhoneCombinationVC.h"
#import "CTMVMFonts.h"
#import "CTMVMColor.h"
#import "VZContentTrasnferConstant.h"
#import "UIImage+Helper.h"

@interface VZPhoneCombinationVC()
@property (weak, nonatomic) IBOutlet UIImageView *leftImageView1;
@property (weak, nonatomic) IBOutlet UIImageView *leftImageView2;
@property (weak, nonatomic) IBOutlet UIImageView *rightImageView1;
@property (weak, nonatomic) IBOutlet UIImageView *rightImageView2;

@property (assign, nonatomic) BOOL smallDevice;

@end

@implementation VZPhoneCombinationVC
@synthesize secondPhone;
@synthesize firstPhone;
@synthesize thirdPhone;
@synthesize fourthPhone;
@synthesize firstView;
@synthesize secondView;
@synthesize selectPhoneLbl;
@synthesize firstViewBtn;
@synthesize secondViewBtn;
@synthesize continueBtn;
@synthesize flag;
@synthesize cancelBtn;
@synthesize deviceType;
@synthesize firstviewTopLeadingConstriant;
@synthesize firstVieTopConstaints;
@synthesize secondViewTopConstaints;
@synthesize smallDevice;

- (void)viewDidLoad {
    self.pageName = ANALYTICS_TrackState_Value_PageName_PhoneCombination;

    [super viewDidLoad];
    
    if ([[UIScreen mainScreen] bounds].size.height <= 480) { // IPhone 4 UI resolution.
        [self.firstviewTopLeadingConstriant setConstant:self.firstviewTopLeadingConstriant.constant-10];
        
        firstVieTopConstaints.constant /= 2;
         
        secondViewTopConstaints.constant /= 2;
        secondViewTopConstaints.constant += 10;
        
        smallDevice = YES;
    }
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        smallDevice = YES;
    }
    
    [CTMVMButtons primaryRedButton:self.continueBtn constrainHeight:YES];
    [CTMVMButtons primaryRedButton:self.cancelBtn constrainHeight:YES];
    
    self.firstPhone.font= self.secondPhone.font = self.thirdPhone.font = self.fourthPhone.font= [CTMVMFonts mvmBookFontOfSize:12];
        
#if STANDALONE
    
    self.selectPhoneLbl.font = [CTMVMFonts mvmBookFontOfSizeWithoutScaling:24];
    
    self.selectPhoneLbl.textColor = [CTMVMColor mvmPrimaryRedColor];
#else
    
    self.selectPhoneLbl.font = [CTMVMFonts mvmBookFontOfSizeWithoutScaling:24];
    
    self.selectPhoneLbl.textColor = [CTMVMColor mvmPrimaryRedColor];
    
#endif
    
    [self.firstViewBtn addTarget:self action:@selector(clickOnFirstViewBtn:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.secondViewBtn addTarget:self action:@selector(clickOnSecondViewBtn:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.continueBtn addTarget:self action:@selector(clickOnContinueBtn:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.cancelBtn addTarget:self action:@selector(clickOnCancelBtn:) forControlEvents:UIControlEventTouchUpInside];
    
    firstView.layer.cornerRadius = 5.0f;
    firstView.layer.borderWidth = 2.0f;
    firstView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    
    secondView.layer.cornerRadius = 5.0f;
    secondView.layer.borderWidth = 2.0f;
    secondView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    
    self.continueBtn.enabled = NO;
    self.continueBtn.alpha = 0.4f;
    [self.continueBtn setBackgroundColor:[CTMVMColor grayColor]];
    
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    
    self.deviceType = [userDefault valueForKey:@"DeviceType"];
    
    if ([self.deviceType isEqualToString:@"OldDevice"]) {
        
        [self.firstPhone setText:@"iPhone"];
        [self.secondPhone setText:@"iPhone"];
        [self.thirdPhone setText:@"iPhone"];
        [self.fourthPhone setText:@"Android"];
        
        [self.leftImageView1 setImage:[UIImage getImageFromBundleWithImageName:@"icon_alreadySelect_large_1x"]];
        [self.rightImageView1 setImage:[UIImage getImageFromBundleWithImageName:@"select_large" ]];
        [self.leftImageView2 setImage:[UIImage getImageFromBundleWithImageName:@"icon_alreadySelect_large_1x" ]];
        [self.rightImageView2 setImage:[UIImage getImageFromBundleWithImageName:@"select_large" ]];
        
        
    } else {
        
        [self.firstPhone setText:@"iPhone"];
        [self.secondPhone setText:@"iPhone"];
        [self.thirdPhone setText:@"Android"];
        [self.fourthPhone setText:@"iPhone"];
        
        [self.leftImageView1 setImage:[ UIImage getImageFromBundleWithImageName:@"select_large"]];
        [self.rightImageView1 setImage:[ UIImage getImageFromBundleWithImageName:@"icon_alreadySelect_large_1x"]];
        [self.leftImageView2 setImage:[ UIImage getImageFromBundleWithImageName:@"select_large"]];
        [self.rightImageView2 setImage:[ UIImage getImageFromBundleWithImageName:@"icon_alreadySelect_large_1x"]];
        
    }
    
    [self.selectPhoneLbl updateConstraintsIfNeeded];
    [self.selectPhoneLbl setNeedsLayout];
    [self.selectPhoneLbl layoutIfNeeded];
    
}


- (void) clickOnFirstViewBtn:(id)sender {
   
     firstView.layer.borderColor = [CTMVMColor mvmPrimaryRedColor].CGColor;
     secondView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    
    self.continueBtn.enabled = YES;
    self.continueBtn.alpha = 1.0f;
    [self.continueBtn setBackgroundColor:[CTMVMColor mvmPrimaryRedColor]];
    
    flag = TRUE;
    
    [CTMVMButtons primaryGreyButton:self.cancelBtn constrainHeight:YES];

    
}

- (void) clickOnSecondViewBtn:(id)sender {
    
    firstView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    secondView.layer.borderColor = [CTMVMColor mvmPrimaryRedColor].CGColor;
    
    self.continueBtn.enabled = YES;
    self.continueBtn.alpha = 1.0f;
    [self.continueBtn setBackgroundColor:[CTMVMColor mvmPrimaryRedColor]];
    
    flag = FALSE;
    
    [CTMVMButtons primaryGreyButton:self.cancelBtn constrainHeight:YES];

}


- (void) clickOnContinueBtn:(id)sender {
    
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    
    NSMutableDictionary *infoDict = [[NSMutableDictionary alloc] init];
    
    [infoDict setValue:self.uuid_string forKey:CONTENT_TRANSFER_DEVICE_UUID];


    if (flag) {
        
//        DebugLog(@"Selected iPhone to iPhone");
        
        NSString *segueID = nil;
        if ([self.deviceType isEqualToString:@"OldDevice"]) {
            segueID = smallDevice?@"wifi_sender_direct_segue":@"bonjourSender";
            [self performSegueWithIdentifier:segueID sender:nil];
        } else {
            segueID = smallDevice?@"wifi_receiver_direct_segue":@"bonjourRecevier";
            [self performSegueWithIdentifier:segueID sender:nil];
        }
        
        [userDefault setValue:@"NO" forKey:@"SOFTACCESSPOINT"];
        
        [infoDict setObject:[NSString stringWithFormat:@"IOS to IOS "] forKey:@"PhoneCombination"];
        
        if ([self.deviceType isEqualToString:@"NewDevice"]) {
            NSString *pageLink  = pageLink(ANALYTICS_TrackState_Value_PageName_PhoneCombination, ANALYTICS_TrackAction_Param_Value_LinkName_IOS_TO_IOS);
            [self.sharedAnalytics trackAction:ANALYTICS_TrackAction_Param_Value_LinkName_IOS_TO_IOS
                                         data:@{ANALYTICS_TrackAction_Key_LinkName:ANALYTICS_TrackAction_Param_Value_LinkName_IOS_TO_IOS,
                                                ANALYTICS_TrackAction_Key_PageLink:pageLink
                                                }];

        }
    } else {
        
//        DebugLog(@"Selected iPhone to Andriod");
        
        if ([self.deviceType isEqualToString:@"NewDevice"]) {
            [self performSegueWithIdentifier:@"wifiSetupRecevier" sender:nil];
        } else {
            [self performSegueWithIdentifier:@"wifiSetupSender" sender:nil];
        }
        
        [userDefault setValue:@"YES" forKey:@"SOFTACCESSPOINT"];
        
        [infoDict setObject:[NSString stringWithFormat:@"IOS to Andriod"] forKey:@"PhoneCombination"];
        
        if ([self.deviceType isEqualToString:@"NewDevice"]) {
            NSString *tempLinkName = [self.deviceType isEqualToString:@"OldDevice"]?ANALYTICS_TrackAction_Param_Value_LinkName_IOS_TO_ANDROID:ANALYTICS_TrackAction_Param_Value_LinkName_ANDRIOD_TO_IOS;
            
            NSString *pageLink  = pageLink(ANALYTICS_TrackState_Value_PageName_PhoneCombination,tempLinkName);
            [self.sharedAnalytics trackAction:tempLinkName
                                         data:@{ANALYTICS_TrackAction_Key_LinkName:tempLinkName,
                                                ANALYTICS_TrackAction_Key_PageLink:pageLink
                                                }];
        }
    }
    
    [[CTMVMSessionSingleton sharedGlobal].vzctAnalyticsObject trackEvent:self.view withTrackTag:@"PhoneSelectionScreen" withExtraInfo:infoDict isEncryptedExtras:false];
}

- (void) clickOnCancelBtn:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}

@end
