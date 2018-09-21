//
//  VZTransferFInishViewController.m
//  VZTransferSocket
//
//  Created by VVM-MAC02 on 12/2/15.
//  Copyright © 2015 Testing. All rights reserved.
//

#import "VZTransferFinishViewController.h"
#import "CTMVMFonts.h"
#import "VZContentTrasnferConstant.h"

#import "VZSummaryWithVideoErrorTableViewController.h"
#import "VZRemindersImoprt.h"
#import "VZCalenderEventsImport.h"

#import "NSString+CTMVMConvenience.h"
#import "VZDeviceMarco.h"
#import "VZLocalAnalysticsManager.h"
#import "NSMutableDictionary+CTMVMConvenience.h"

@interface VZTransferFinishViewController () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *finishTopConstraints;
//REVIEW : @property (weak, nonatomic) IBOutlet NSLayoutConstraint *circularTopConstaints;
//REVIEW : (Code commented) @property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageTopConstaints;
//REVIEW : @property (weak, nonatomic) IBOutlet NSLayoutConstraint *timeLabelTopConstains;
//REVIEW : (Code commented) @property (weak, nonatomic) IBOutlet NSLayoutConstraint *totalTimeConstaints;
//REVIEW : (Code commented) @property (weak, nonatomic) IBOutlet NSLayoutConstraint *backViewTopConstraints;//used ?
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topConstraintMDNSurveyInfo;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topConstraintMDNTextField;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *summaryButtonTopConstraint;
//REVIEW : (Code commented) @property (weak, nonatomic) IBOutlet NSLayoutConstraint *labelTopConstraintsForCircular;
//REVIEW : (Code commented) @property (weak, nonatomic) IBOutlet NSLayoutConstraint *labelTopConstraintsForImage; //used ?
//REVIEW : @property (weak, nonatomic) IBOutlet NSLayoutConstraint *buttonTopConstaints;
//REVIEW : (Code commented) @property (weak, nonatomic) IBOutlet NSLayoutConstraint *videoTypeFormatLabelTopConstaints;
//REVIEW : (Code commented) @property (weak, nonatomic) IBOutlet NSLayoutConstraint *cancelBottomConstaints;
//REVIEW : (Code commented) @property (weak, nonatomic) IBOutlet NSLayoutConstraint *textFieldTop;

@property (assign, nonatomic) BOOL isCrossplatform;

// constraits added by Xin
// change UI for iphone 4 screen size, making space for textfield bar & its instruction

// Small the circle & phone image
//REVIEW : (Code commented) @property (weak, nonatomic) IBOutlet NSLayoutConstraint *circularHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *circularWidth;
//REVIEW : (Code commented) @property (weak, nonatomic) IBOutlet NSLayoutConstraint *iconHeight;
//REVIEW : (Code commented) @property (weak, nonatomic) IBOutlet NSLayoutConstraint *iconWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *totalReceivedDataTitleTop;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *totalDowloadTop;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *labelSec2Bottom;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *timeBottom;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *timeTitleBottom;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *circularViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *downloadedDataTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *closeButtonBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *arrowHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *alignmentIcon;


@property (assign, nonatomic) BOOL keyboardShowed;

@property (assign, nonatomic) BOOL firstLayout;
@property (assign, nonatomic) CGFloat downloadDataSize;
@end

@implementation VZTransferFinishViewController
@synthesize totalTimeElapsed;
@synthesize timeLbl;
@synthesize totaldataDownloaded;
@synthesize  downloadLbl;
@synthesize totalFileReceived;
@synthesize downLoadedDataProcessingLbl;
@synthesize downLoadDataLblStr;
@synthesize delegate;
@synthesize okBtn;
@synthesize numberOfPhotos;
@synthesize numberOfVideos;
@synthesize summaryBtn;
@synthesize summaryDisplayFlag;
//REVIEW : (Code commented) @synthesize videoSavingLbl;
//REVIEW : (Code commented) @synthesize videoFormatSpecificInfoLbl;
@synthesize numberOfContacts;
@synthesize app;
@synthesize videoErrList;
@synthesize photoErrList;
@synthesize maxspeed;
@synthesize avgSpeed;
@synthesize transferInterrupted;
@synthesize importReminder;
@synthesize mediaTypePiped;
@synthesize transferStarted;

//@synthesize asyncsocket;
//@synthesize listernSocket;

- (id)init {
    if (self = [super init]) {
        delegate = self;
    }
    return self;
}


- (void)viewDidLoad {
    
    if ([[UIApplication sharedApplication] isIgnoringInteractionEvents]) {
        
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
    }
    
    self.firstLayout = YES;
    
    self.delegate = self;
    self.mdnTextField.delegate = self;
    
    self.mdnTextField.placeholder = @"Enter Phone number";
    
    [self.mdnTextField addTarget:self
                            action:@selector(textFieldDidChange:)
                  forControlEvents:UIControlEventEditingChanged];
    
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    
    
    NSDate *starttime;
    
    NSDate *endtime;
  
    int hh = 0;
    int mm = 0;
    int ss = 0;
    double rem = 0;
    NSTimeInterval secondsBetween = -1;
    
    NSString *str = [[NSString alloc] init];

    if ([userDefault valueForKey:@"STARTTIME"] && [userDefault valueForKey:@"ENDTIME"]) {
        
         starttime = [userDefault valueForKey:@"STARTTIME"];
        
         endtime = [userDefault valueForKey:@"ENDTIME"];
        
        secondsBetween = [endtime timeIntervalSinceDate:starttime];
        
         hh = secondsBetween / (60*60);
         rem = fmod(secondsBetween, (60*60));
         mm = rem / 60;
        rem = fmod(rem, 60);
         ss = rem;
        
        str = [NSString stringWithFormat:@"%02d:%02d:%02d",hh,mm,ss];
        
        if(secondsBetween < 0) {
            str = [NSString stringWithFormat:@"00:00:00"];
            [userDefault setValue:@"0MB" forKey:@"TOTALDOWNLOADEDDATA"];
        }
        
        _downloadDataSize = 0;
        NSString *downloadDataString = [userDefault valueForKey:@"TOTALDOWNLOADEDDATA"];
        if ([downloadDataString isEqualToString:@"Less than 1MB"]) {
            _downloadDataSize = 1.f;
        } else {
            _downloadDataSize = [[downloadDataString substringToIndex:downloadDataString.length-2] floatValue];
        }
        
        avgSpeed = _downloadDataSize/secondsBetween * 8;
    } else {
        
        str = [NSString stringWithFormat:@"00:00:00"];
        [userDefault setValue:@"0MB" forKey:@"TOTALDOWNLOADEDDATA"];
    }
    
    [self.finishedLbl setText:@"Finished!"];
    
#if STANDALONE
    
    self.finishedLbl.textColor = [CTMVMColor mvmPrimaryRedColor];
    self.finishedLbl.font = [CTMVMFonts mvmBookFontOfSizeWithoutScaling:24];
#else
    
    self.finishedLbl.textColor = [CTMVMColor mvmPrimaryRedColor];
    self.finishedLbl.font = [CTMVMFonts mvmBookFontOfSizeWithoutScaling:24];
    
#endif
    
    self.totalTimeElapsed.font = [CTMVMFonts mvmBookFontOfSize:15];
    self.timeLbl.font = [CTMVMFonts mvmBookFontOfSize:10];
    self.totaldataDownloaded.font = [CTMVMFonts mvmBookFontOfSize:15];
    self.downloadLbl.font = [CTMVMFonts mvmBookFontOfSize:10];
    self.totalFileReceived.font = [CTMVMFonts mvmBookFontOfSize:10];
    if([[UIScreen mainScreen] bounds].size.height <= 480){
        self.downLoadedDataProcessingLbl.font = [CTMVMFonts mvmBookFontOfSize:12];
    } else {
        self.downLoadedDataProcessingLbl.font = [CTMVMFonts mvmBookFontOfSize:14];
    }
    //REVIEW : (Code commented) self.videoFormatSpecificInfoLbl.font = [CTMVMFonts mvmBookFontOfSize:12];
    self.mdnValidationStatusLbl.font = [CTMVMFonts mvmBookFontOfSize:10];
    self.mdnSurveyInfo.textColor = [CTMVMColor mvmDarkGrayColor];

    [CTMVMButtons primaryRedButton:self.okBtn constrainHeight:NO];
    [CTMVMButtons primaryGreyButton:self.summaryBtn constrainHeight:YES];
    
    
    self.navigationItem.title = @"Content Transfer";
    

    if (!self.isSender) { // receiver
        
        self.finishImage.image = [ UIImage getImageFromBundleWithImageName:@"icon_recieve" ];
        [self.downLoadedDataProcessingLbl setText:downLoadDataLblStr];
        
        if (transferInterrupted) {
            
            [self.finishedLbl setText:@"Transfer interrupted"];
//            [self.finishedLbl setFont:[CTMVMFonts mvmBookFontOfSize:25]];
            
            self.downLoadedDataProcessingLbl.textColor = [CTMVMColor mvmDarkGrayColor];
            
//            [self.downLoadedDataProcessingLbl setText:@"Transfer did not complete. Please review transfer summary."];
        }

        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(receivedNotification:)
                                                     name:@"ALLPHOTODOWNLOADCOMPLETED"
                                                   object:nil];
        
        
        [timeLbl setText:@"Total Time Elapsed"];
        
        [totalTimeElapsed setText:str];
        
        [downloadLbl setText:@"Total Received Data"];
        
        [totaldataDownloaded setText:(NSString *)[userDefault valueForKey:@"TOTALDOWNLOADEDDATA"]];
        
        [totalFileReceived setText:[NSString stringWithFormat:@" %d File(s) Received",[[userDefault valueForKey:@"TOTALFILESRECEIVED"] intValue]]];
        
        NSMutableDictionary *infoDict = [[NSMutableDictionary alloc] init];
        
        [infoDict setObjectIfValid:[NSString stringWithFormat:@"%ld",(long)self.numberOfContacts] forKey:@"ContactCount" defaultObject:@0];
        [infoDict setObjectIfValid:[NSString stringWithFormat:@"%lu", (unsigned long)self.numberOfPhotos] forKey:@"PhotosCount" defaultObject:@0];
        [infoDict setObjectIfValid:[NSString stringWithFormat:@"%lu",(unsigned long)self.numberOfVideos] forKey:@"VideosCount" defaultObject:@0];
        [infoDict setObjectIfValid:[NSString stringWithFormat:@"%d",[[userDefault valueForKey:@"TOTALFILESRECEIVED"] intValue]] forKey:@"Total_file_Recevied" defaultObject:@0];
        [infoDict setObjectIfValid:str forKey:@"TotalTime" defaultObject:@0];
        
        [infoDict setObjectIfValid:[userDefault valueForKey:@"TOTALDOWNLOADEDDATA"] forKey:@"TotalDownload" defaultObject:@0];
        [infoDict setObjectIfValid:[NSString stringWithFormat:@"%f",self.maxspeed] forKey:@"MaxSpeed" defaultObject:@0];
        [infoDict setObjectIfValid:[NSString stringWithFormat:@"%f",self.avgSpeed] forKey:@"AvgSpeed" defaultObject:@0];
        [infoDict setValue:self.uuid_string forKey:CONTENT_TRANSFER_DEVICE_UUID];
//        [infoDict setObject:@"Success" forKey:@"dataTransferStatusMsg"];
        [infoDict setObject:@"UNKNOWN" forKey:@"duplicatePhotoCount"];
        [infoDict setObject:@"UNKNOWN" forKey:@"duplicateMusicCount"];
        [infoDict setObject:@"UNKNOWN" forKey:@"duplicateVideoCount"];
//        [infoDict setObject:[NSString stringWithFormat:@"%f",starttime.timeIntervalSince1970] forKey:@"StartTime"];
//        [infoDict setObject:[NSString stringWithFormat:@"%f",endtime.timeIntervalSince1970] forKey:@"EndTime"];
         long startTimemilliseconds = (long)([starttime timeIntervalSince1970]);
         long endTimemilliseconds = (long)([endtime timeIntervalSince1970]);
        
        [infoDict setObjectIfValid:[NSString stringWithFormat:@"%ld",startTimemilliseconds] forKey:@"StartTime" defaultObject:@0];
        [infoDict setObjectIfValid:[NSString stringWithFormat:@"%ld",endTimemilliseconds] forKey:@"EndTime" defaultObject:@0];
        
        if (transferInterrupted) {
            [infoDict setObject:@"Data transfer interrupted" forKey:@"dataTransferStatusMsg "];
        } else {
            [infoDict setObject:@"Success" forKey:@"dataTransferStatusMsg "];

        }
        
        [[CTMVMSessionSingleton sharedGlobal].vzctAnalyticsObject trackEvent:self.view withTrackTag:@"TransferSummaryScreen" withExtraInfo:infoDict isEncryptedExtras:false];
        
        if (!self.processEnd || self.calendarReceived || self.importReminder){  // still saving...
            [self blockingUIUntilSavingCompleted];
        } else {
            self.mdnTextField.hidden = NO;
            self.mdnValidationStatusLbl.hidden = NO;
            self.mdnSurveyInfo.hidden = NO;
            //REVIEW : (Code commented) self.videoFormatSpecificInfoLbl.hidden = NO;
            self.sendMDNBtn.hidden = NO;

        }
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationDidEnterBackground:)
                                                     name:UIApplicationDidEnterBackgroundNotification
                                                   object:nil];

    } else { // sender side
    
        self.finishImage.image = [ UIImage getImageFromBundleWithImageName:@"icon_sent" ];
        
        if (transferInterrupted) {
            
            [self.finishedLbl setText:@"Transfer interrupted"];
//            [self.finishedLbl setFont:[CTMVMFonts mvmBookFontOfSize:25]];
            
             self.downLoadedDataProcessingLbl.textColor = [CTMVMColor mvmDarkGrayColor];
            
            [self.downLoadedDataProcessingLbl setText:@"Transfer did not complete. Please review transfer summary."];
        } else {
            [self.downLoadedDataProcessingLbl setText:@"Data Transfer completed successfully!"];
        }
        
        totaldataDownloaded.adjustsFontSizeToFitWidth = YES;
        
        [downloadLbl setText:@""];
        
        [totaldataDownloaded setText:[NSString stringWithFormat:@" %d File(s) Transferred ", [[[NSUserDefaults standardUserDefaults] valueForKey:@"TOTALFILETRANSFERED"] intValue]]];
        
        NSMutableDictionary *infoDict = [[NSMutableDictionary alloc] init];
        
        [infoDict setObjectIfValid:[NSString stringWithFormat:@"%ld",(long)self.numberOfContacts] forKey:@"ContactCount" defaultObject:@0];
        [infoDict setObjectIfValid:[NSString stringWithFormat:@"%lu", (unsigned long)self.numberOfPhotos] forKey:@"PhotosCount" defaultObject:@0];
        [infoDict setObjectIfValid:[NSString stringWithFormat:@"%lu",(unsigned long)self.numberOfVideos] forKey:@"VideosCount" defaultObject:@0];
        
        long  startTimemilliseconds = (long)([starttime timeIntervalSince1970]);
        long  endTimemilliseconds = (long)([endtime timeIntervalSince1970]);
        
        [infoDict setObjectIfValid:[NSString stringWithFormat:@"%ld",startTimemilliseconds] forKey:@"StartTime" defaultObject:@0];
        [infoDict setObjectIfValid:[NSString stringWithFormat:@"%ld",endTimemilliseconds] forKey:@"EndTime" defaultObject:@0];
        
        if (transferInterrupted) {
             [infoDict setObject:@"Data transfer interrupted" forKey:@"dataTransferStatusMsg"];
        } else {
             [infoDict setObject:@"Success" forKey:@"dataTransferStatusMsg "];
        }
//        [infoDict setObject:[NSString stringWithFormat:@""] forKey:];
        
        [[CTMVMSessionSingleton sharedGlobal].vzctAnalyticsObject trackEvent:self.view withTrackTag:CONTENT_TRANSFER_TRASNFERED withExtraInfo:infoDict isEncryptedExtras:false];
        
        
        self.mdnTextField.hidden = YES;
        self.mdnSurveyInfo.hidden = YES;

        //REVIEW : (Code commented) self.videoFormatSpecificInfoLbl.hidden = YES;
        self.sendMDNBtn.hidden = YES;
        self.mdnValidationStatusLbl.hidden = YES;

    }
    
    [self.downLoadedDataProcessingLbl layoutIfNeeded];
    
//    DebugLog(@"%Platfrom name is %@",[userDefaults valueForKey:@"isAndriodPlatform"]);
    
    if ([[userDefault valueForKey:@"isAndriodPlatform"] isEqualToString:@"TRUE"]) {
        
        self.isCrossplatform = YES;
//        if ( [[UIScreen mainScreen] bounds].size.height > 480 && !self.isSender) {
//            self.videoFormatSpecificInfoLbl.text = @"\"Only *.m4v, *.mp4,  and *.mov video formats will be received from Android device(s) and others will be ignored\"";
//            [self.videoFormatSpecificInfoLbl layoutIfNeeded];
//        }
    }
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tap];
    
    // LOCAL ANALYTICS DATA PREPARATION
    NSString *strAvgSpeed = [NSString stringWithFormat:@"%.f",self.avgSpeed];
    
    if ([strAvgSpeed isEqualToString:@"nan"]) {
        strAvgSpeed = @"0";
    }

    if (_analyticsTypeID == TRANSFER_SUCCESS) {
        // Store local analystics for both sender & receiver sides
        
        [[VZLocalAnalysticsManager sharedInstance] localAnalyticsData:@"Success"
                                                  andNumberOfContacts:numberOfContacts
                                                    andNumberOfPhotos:numberOfPhotos
                                                    andNumberOfVideos:numberOfVideos
                                                 andNumberOfCalendars:_numberOfCalendar
                                                 andNumberOfReminders:_numberOfReminder
                                                      totalDownloaded:totaldataDownloaded.text
                                                     totalTimeElapsed:totalTimeElapsed.text
                                                         averageSpeed:strAvgSpeed];
    } else if (_analyticsTypeID == TRANSFER_INTERRUPTED) {
        
        // Sender side crash
        [[VZLocalAnalysticsManager sharedInstance] localAnalyticsData:@"Data Transfer Interrupted"
                                                  andNumberOfContacts:numberOfContacts
                                                    andNumberOfPhotos:numberOfPhotos
                                                    andNumberOfVideos:numberOfVideos
                                                 andNumberOfCalendars:_numberOfCalendar
                                                 andNumberOfReminders:_numberOfReminder
                                                      totalDownloaded:totaldataDownloaded.text
                                                     totalTimeElapsed:totalTimeElapsed.text
                                                         averageSpeed:strAvgSpeed];
    } else if (_analyticsTypeID == TRANSFER_CANCELLED) {
        
        // Sender & receiver side cancelled
        [[VZLocalAnalysticsManager sharedInstance] localAnalyticsData:@"Transfer Cancelled"
                                                  andNumberOfContacts:numberOfContacts
                                                    andNumberOfPhotos:numberOfPhotos
                                                    andNumberOfVideos:numberOfVideos
                                                 andNumberOfCalendars:_numberOfCalendar
                                                 andNumberOfReminders:_numberOfReminder
                                                      totalDownloaded:totaldataDownloaded.text
                                                     totalTimeElapsed:totalTimeElapsed.text
                                                         averageSpeed:strAvgSpeed];
    } else if (_analyticsTypeID == INSUFFICIENT_STORAGE) {
        
        // Transfer cancelled because of insufficient storage
        [[VZLocalAnalysticsManager sharedInstance] localAnalyticsData:@"Transfer Cancelled(Insufficient Storage)"
                                                  andNumberOfContacts:numberOfContacts
                                                    andNumberOfPhotos:numberOfPhotos
                                                    andNumberOfVideos:numberOfVideos
                                                 andNumberOfCalendars:_numberOfCalendar
                                                 andNumberOfReminders:_numberOfReminder
                                                      totalDownloaded:totaldataDownloaded.text
                                                     totalTimeElapsed:totalTimeElapsed.text
                                                         averageSpeed:strAvgSpeed];
    } else if (_analyticsTypeID == CONNECTION_FAILED) {
        
        // Transfer cancelled because of insufficient storage
        [[VZLocalAnalysticsManager sharedInstance] localAnalyticsData:@"Connection Failed"
                                                  andNumberOfContacts:numberOfContacts
                                                    andNumberOfPhotos:numberOfPhotos
                                                    andNumberOfVideos:numberOfVideos
                                                 andNumberOfCalendars:_numberOfCalendar
                                                 andNumberOfReminders:_numberOfReminder
                                                      totalDownloaded:totaldataDownloaded.text
                                                     totalTimeElapsed:totalTimeElapsed.text
                                                         averageSpeed:strAvgSpeed];
    }
    
    [self captureAbodeAnalyticsOnTransferFinish:self.isSender time:secondsBetween];
    
    [super viewDidLoad];
}

- (void)viewDidLayoutSubviews
{
    if (self.firstLayout) {
        if (!self.isSender) {
            self.alignmentIcon.constant -= 11.f;
        }
        
        if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad) { // UI adaption for iPhones
            // Build selection list UI adaption
            CGFloat screenHeight = [[UIScreen mainScreen] bounds].size.height;
            if (screenHeight <= 480) { // IPhone 4 UI resolution.
                //REVIEW : (Code commented) self.titleTopConstaints.constant /= 2.f;
                self.finishTopConstraints.constant += 3.f;
                
                //REVIEW : (Code commented) self.circularTopConstaints.constant /= 4;
                self.circularViewTopConstraint.constant /= 2;
                
                self.circularWidth.constant -= 65.f;
                //REVIEW : (Code commented) self.labelTopConstraintsForCircular.constant /= 4;
                
                self.totalDowloadTop.constant -= 1.5f;
                self.totalReceivedDataTitleTop.constant /= 2;
                
                self.timeBottom.constant = -2;
                self.labelSec2Bottom.constant = -7;
                
                //REVIEW : (Code commented) self.imageTopConstaints.constant -= 4.5f;
                
                self.totaldataDownloaded.font = [CTMVMFonts mvmBookFontOfSize:12];
                self.mdnSurveyInfo.font = [CTMVMFonts mvmBookFontOfSize:10];
                
                self.downloadedDataTopConstraint.constant /= 2;
                
                if (!self.isSender) {
                    self.finishTopConstraints.constant = 60;
                }
            } else if (screenHeight <= 568) {
                //REVIEW : (Code commented) self.titleTopConstaints.constant /= 2;
                
                //REVIEW : (Code commented) self.circularTopConstaints.constant /= 4;
                self.circularViewTopConstraint.constant /= 4;
                
                //REVIEW : (Code commented) self.labelTopConstraintsForCircular.constant /= 3;
                //REVIEW : (Code commented) self.textFieldTop.constant -= 2;
                
                self.circularWidth.constant -= 3.f;
                self.mdnSurveyInfo.font = [CTMVMFonts mvmBookFontOfSize:12];
                
                self.downloadedDataTopConstraint.constant /= 2;
    
                if (!self.isSender) {
                    self.finishTopConstraints.constant = 65.f;
                    self.finishTopConstraints.constant += 6.f;
                }
            } else {
                self.finishTopConstraints.constant = 82.f;
                
                //REVIEW : (Code commented) self.videoTypeFormatLabelTopConstaints.constant = 10.f;
                self.mdnSurveyInfo.font = [CTMVMFonts mvmBookFontOfSize:13];
            }
        }
        
        self.firstLayout = NO;
    }
    
    [self.view layoutIfNeeded];
}

- (void)textFieldDidChange:(UITextField *)textField
{
    textField.layer.borderWidth = 0;
}

- (void)dismissKeyboard
{
    if (!_keyboardShowed) {
        return;
    }
    self.keyboardShowed = NO;
    [self.view endEditing:YES];
    
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:.3
                     animations:^{[self.view setFrame:CGRectMake(0, 0,[[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height)];
                         [weakSelf.view setNeedsLayout];
                     } completion:^(BOOL finished) {
                         NSString *email = _mdnTextField.text;
                         if ((email.length==10) && ([[email substringToIndex:1] integerValue] > 1)) {
                             _mdnTextField.layer.borderWidth = 0;
                             self.mdnValidationStatusLbl.text = @"Thank you,we appreciate your interest.";
                             self.mdnValidationStatusLbl.textColor = [CTMVMColor blackColor];

                         } else if(email.length>0) {
                             _mdnTextField.layer.borderColor = [[UIColor redColor] CGColor];
                             _mdnTextField.layer.borderWidth = 1;
                             _mdnTextField.layer.cornerRadius = 3.f;
                             self.mdnValidationStatusLbl.text = @"Please enter valid phone number";
                             self.mdnValidationStatusLbl.textColor = [CTMVMColor mvmPrimaryRedColor];

                             
                             [weakSelf sakeTextBar];
                         } else {
                             self.mdnValidationStatusLbl.text = @"";
                             
                         }
                     }];
}

- (IBAction)sendEmail:(id)sender {
    
    if ([self isValidMDN]) {
        self.mdnValidationStatusLbl.text = @"Thank you, we appreciate your interest.";
        self.mdnValidationStatusLbl.textColor = [CTMVMColor blackColor];

    }else if(self.mdnTextField.text.length>0){
        
        self.mdnValidationStatusLbl.text = @"Please enter valid phone number";
        self.mdnValidationStatusLbl.textColor = [CTMVMColor mvmPrimaryRedColor];
        [self dismissKeyboard];
    }else {
        self.mdnValidationStatusLbl.text = @"";
        
    }
    
    
}
- (void)sakeTextBar
{
    [UIView animateWithDuration:.1f animations:^{
        _mdnTextField.frame = CGRectMake(_mdnTextField.frame.origin.x-3, _mdnTextField.frame.origin.y, _mdnTextField.frame.size.width, _mdnTextField.frame.size.height);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:.1f animations:^{
            _mdnTextField.frame = CGRectMake(_mdnTextField.frame.origin.x + 6, _mdnTextField.frame.origin.y, _mdnTextField.frame.size.width, _mdnTextField.frame.size.height);
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:.1f animations:^{
                _mdnTextField.frame = CGRectMake(_mdnTextField.frame.origin.x - 6, _mdnTextField.frame.origin.y, _mdnTextField.frame.size.width, _mdnTextField.frame.size.height);
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:.1f animations:^{
                    _mdnTextField.frame = CGRectMake(_mdnTextField.frame.origin.x + 3, _mdnTextField.frame.origin.y, _mdnTextField.frame.size.width, _mdnTextField.frame.size.height);
                }];
            }];
        }];
    }];
}

- (void)applicationDidEnterBackground:(NSNotification *)notification {
    
    NSString *pageLink = pageLink(ANALYTICS_TrackState_Value_PageName_PhoneFinish, @"click on home button finished screen");

    NSMutableDictionary *paramDictionary = [NSMutableDictionary dictionary];
    
    [paramDictionary setObject:@"click on home button finished screen" forKey:ANALYTICS_TrackAction_Key_LinkName];
    [paramDictionary setObject:pageLink forKey:ANALYTICS_TrackAction_Key_PageLink];
    
    
    if ( ! self.isSender && [self isValidMDN]) {
        [paramDictionary setObject:self.mdnTextField.text forKey:ANALYTICS_TrackAction_Param_Key_MDN];
    }else {
        [paramDictionary setObject:@"null" forKey:ANALYTICS_TrackAction_Param_Key_MDN];
    }

    [self.sharedAnalytics trackAction:@"click on home button finished screen" data:paramDictionary];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [self dismissKeyboard];
    
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    
    if (textField.text.length == 0) {
        textField.placeholder = @"Enter your mobile number";
    }
   
    
    
    return YES;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField {
    
    self.keyboardShowed = YES;
    //textField.placeholder = @"";
    if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad) { // UI adaption for iPhones
        if ([[UIScreen mainScreen] bounds].size.height <= 667) { // iphone 5 screen size
            
            [UIView animateWithDuration:.5
                             animations:^{
                                 [self.view setFrame:CGRectMake(0,-210,[[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height)];
                             }];
            
        } else {
            [UIView animateWithDuration:.5
                             animations:^{
                                 [self.view setFrame:CGRectMake(0,-150,[[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height)];
                             }];
        }
    }
    
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    NSString *resultText = [textField.text stringByReplacingCharactersInRange:range withString:string];
    return resultText.length <= 10;
}

-(BOOL) isValidMDN{
    
    NSString *email = _mdnTextField.text;
    
    if((email.length==10) && ([[email substringToIndex:1] integerValue] > 1)) {
        
        return true;
    } else {
        
        return false;
    }
}



- (void) blockingUIUntilSavingCompleted {
    
    CGFloat screenHeight = [[UIScreen mainScreen] bounds].size.height;
    
    [[self okBtn] setEnabled:NO];
    [[self okBtn] setAlpha:0.4];
    [[self summaryBtn] setEnabled:NO];
    [[self summaryBtn] setAlpha:0.4];
    
    NSMutableAttributedString * title = [[NSMutableAttributedString alloc] initWithString:@"Saving in progress\n  Please do not close the app until saving is complete."];
    
    if (screenHeight <= 480) {
        [title addAttribute:NSFontAttributeName value:[CTMVMFonts mvmBookFontOfSize:20] range:NSMakeRange(0,20)];
    } else {
        [title addAttribute:NSFontAttributeName value:[CTMVMFonts mvmBookFontOfSize:23] range:NSMakeRange(0,20)];
    }
    [title addAttribute:NSFontAttributeName value:[CTMVMFonts mvmBookFontOfSize:11] range:NSMakeRange(20,title.length-20)];
    [title addAttribute:NSForegroundColorAttributeName value:[CTMVMColor mvmPrimaryRedColor] range:NSMakeRange(20,title.length-20)];
    [self.finishedLbl setAttributedText:title];

}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}


- (void)receivedNotification:(NSNotification *) notification {
    if ([[notification name] isEqualToString:@"ALLPHOTODOWNLOADCOMPLETED"]) {
        
        [self.downLoadedDataProcessingLbl setText:@"Data Processing Completed."];
        
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"ALLPHOTODOWNLOADCOMPLETED" object:nil];
        
        self.okBtn.enabled = YES;
        self.okBtn.alpha = 1.0;
    }
}



- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (!self.isSender) { // receiver
        if (!transferInterrupted) { // not cancel
            if (self.processEnd){  // saving photos & vidoes ends
                
                if (self.calendarReceived) {
//                    [self blockingUIUntilSavingCompleted];
                    
                    NSInvocationOperation *newoperation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(importCalendar) object:nil];
                    [[[NSOperationQueue alloc] init] addOperation:newoperation];
                } else if (self.importReminder){
//                    [self blockingUIUntilSavingCompleted];
                    
                    [self.downLoadedDataProcessingLbl setText:@"Please wait.. Importing reminders"];
//                    [UIView ani]
                    
                    NSInvocationOperation *newoperation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(importReminderMethod) object:nil];
                    [[[NSOperationQueue alloc] init] addOperation:newoperation];
                }
            }
        }
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)updateSavingProcessDataWithPhotoNumber:(int)savedPhotoNumber
                                andVideoNumber:(int)savedVideoNumber
                            andVideoFailedInfo:(NSArray *)videoFailedList
                            andPhotoFailedInfo:(NSArray *)photoFailedList
{
    __weak typeof(self) weakSelf = self;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if (savedVideoNumber && savedPhotoNumber) {
            [weakSelf.downLoadedDataProcessingLbl setText:[NSString stringWithFormat:@"Please wait.. %d Photo(s) and %d Video(s) to be saved",savedPhotoNumber, savedVideoNumber]];
            [[weakSelf okBtn] setEnabled:NO];
            [[weakSelf okBtn] setAlpha:0.4];
            [[weakSelf summaryBtn] setEnabled:NO];
            [[weakSelf summaryBtn] setAlpha:0.4];
        } else if (savedPhotoNumber) {
            [weakSelf.downLoadedDataProcessingLbl setText:[NSString stringWithFormat:@"Please wait.. %d Photo(s) to be saved",savedPhotoNumber]];
            [[weakSelf okBtn] setEnabled:NO];
            [[weakSelf okBtn] setAlpha:0.4];
            [[weakSelf summaryBtn] setEnabled:NO];
            [[weakSelf summaryBtn] setAlpha:0.4];
        } else if (savedVideoNumber) {
            [weakSelf.downLoadedDataProcessingLbl setText:[NSString stringWithFormat:@"Please wait.. %d Video(s) to be saved",savedVideoNumber]];
            [[weakSelf okBtn] setEnabled:NO];
            [[weakSelf okBtn] setAlpha:0.4];
            [[weakSelf summaryBtn] setEnabled:NO];
            [[weakSelf summaryBtn] setAlpha:0.4];
        } else {
            videoErrList = videoFailedList; // assign as globle property
            photoErrList = photoFailedList;
            
            if (weakSelf.calendarReceived) {
                [weakSelf.downLoadedDataProcessingLbl setText:@"Please wait... Importing calendars"];
                
                NSInvocationOperation *newoperation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(importCalendar) object:nil];
                [[[NSOperationQueue alloc] init] addOperation:newoperation];
            } else if (weakSelf.importReminder){
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf.downLoadedDataProcessingLbl setText:@"Please wait... Importing reminders"];
                    
                    NSInvocationOperation *newoperation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(importReminderMethod) object:nil];
                    [[[NSOperationQueue alloc] init] addOperation:newoperation];
                });
            } else {
                
                if (!self.isSender) { // only show email textfield in receiver
                    self.mdnValidationStatusLbl.hidden = NO;
                    self.mdnTextField.hidden = NO;
                    self.mdnSurveyInfo.hidden = NO;
                    //REVIEW : (Code commented) self.videoFormatSpecificInfoLbl.hidden = NO;
                    self.sendMDNBtn.hidden = NO;
                }
                
                if (transferInterrupted) {
                    [self.downLoadedDataProcessingLbl setText:@"Transfer did not complete. Please review transfer summary."];
                } else if (videoErrList.count > 0 || photoErrList.count > 0 || self.hasVcardPermissionErr || self.hasAlbumPermissionErr) {
                    [weakSelf.downLoadedDataProcessingLbl setText:@"Download completed with Error(s). Tap on Summary to view details."];
                } else {
                    [weakSelf.downLoadedDataProcessingLbl setText:@"Data Transfer completed successfully!"];
                }
                
                [[weakSelf okBtn] setEnabled:YES];
                [[weakSelf okBtn] setAlpha:1.0];
                [[weakSelf summaryBtn] setEnabled:YES];
                [[weakSelf summaryBtn] setAlpha:1.0];
                
                if (transferInterrupted) {
                    [weakSelf.finishedLbl setText:@"Transfer interrupted"];
//                    [weakSelf.finishedLbl setFont:[CTMVMFonts mvmBookFontOfSize:25]];
                } else {
                    [weakSelf.finishedLbl setText:@"Finished!"];
//                    weakSelf.finishedLbl.font = [CTMVMFonts mvmBookFontOfSize:30];
                    
                    // Only remove the duplicate list when one transfer finished
                    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"PHOTODUPLICATELIST"];
                    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"VIDEODUPLICATELIST"]; // after all data saved finished, remove the duplicate list
                    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"VCARDDUPLICATELIST"];
                    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"CALENDARDUPLICATELIST"];
                    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"REMINDERDUPLICATELIST"];
                    
                    [[NSUserDefaults standardUserDefaults] synchronize];
                }
            }
        }
        
        [weakSelf.downLoadedDataProcessingLbl layoutIfNeeded];
    });
}

- (void)importReminderMethod
{
    __weak typeof(self) weakSelf = self;
    VZRemindersImoprt *reminderImport = [[VZRemindersImoprt alloc] init];
    
    reminderImport.completionHandler = ^(NSInteger totalnumberOfReminder) {
        
        DebugLog(@"Total reminder added %ld",(long)totalnumberOfReminder);
        
        weakSelf.importReminder = NO;
        [weakSelf updateSavingProcessDataWithPhotoNumber:0 andVideoNumber:0 andVideoFailedInfo:videoErrList andPhotoFailedInfo:photoErrList];
    };
    
    [reminderImport importAllReminder];
}

- (void)importCalendar
{
    VZCalenderEventsImport *calendarImport = [[VZCalenderEventsImport alloc] init];
    
    __weak typeof(self) weakSelf = self;
    [calendarImport createCalendarsSuccess:^{
        weakSelf.calendarReceived = NO;
        [weakSelf updateSavingProcessDataWithPhotoNumber:0 andVideoNumber:0 andVideoFailedInfo:videoErrList andPhotoFailedInfo:photoErrList];
        
    } failure:^{
        DebugLog(@"saving calendar failed");
        
        weakSelf.calendarReceived = NO;
        [weakSelf updateSavingProcessDataWithPhotoNumber:0 andVideoNumber:0 andVideoFailedInfo:videoErrList andPhotoFailedInfo:photoErrList];
    }];
}


- (IBAction)clickedOnSummary:(id)sender {

    [self dismissKeyboard];
    
    if (videoErrList.count > 0 || photoErrList.count > 0 || self.hasAlbumPermissionErr || self.hasVcardPermissionErr) { // pop up a new view for error message
        [self performSegueWithIdentifier:@"video_err_segue" sender:self];
    } else { // pop up alert for summary
        
        NSString *alertString = [NSString stringWithFormat:@"Contacts: %li  \r Photos: %ld \r Videos : %ld \r Calendars : %ld ", (long)numberOfContacts, numberOfPhotos, numberOfVideos, _numberOfCalendar];
        if (!_isCrossplatform) {
            alertString = [NSString stringWithFormat:@"%@ \r Reminders: %ld", alertString, _numberOfReminder];
        }
        
        NSString *alertTitle = [[NSString alloc] init];
        
        if(summaryDisplayFlag == 1) {
            alertTitle = [NSString stringWithFormat:@"Data Sent"];
        }
        else if(summaryDisplayFlag == 2) {
            alertTitle = [NSString stringWithFormat:@"Data Received"];
        }
        
        else alertTitle = [NSString stringWithFormat:@"Transfer Summary"];
        
        CTMVMAlertAction *cancelAction = [CTMVMAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];

        [[CTMVMAlertHandler sharedAlertHandler] showAlertWithTitle:alertTitle message:alertString cancelAction:cancelAction otherActions:nil isGreedy:NO];
    }
}

- (IBAction)clickOnClose:(UIButton *)sender {
    
    if (!self.transferInterrupted) {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"PHOTODUPLICATELIST"];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"VIDEODUPLICATELIST"]; // after all data saved finished, remove the duplicate list
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"VCARDDUPLICATELIST"];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"CALENDARDUPLICATELIST"];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"REMINDERDUPLICATELIST"];
        
        [[NSUserDefaults standardUserDefaults] synchronize];
    }

#if STANDALONE

    [[self navigationController] popToRootViewControllerAnimated:YES];
    
#else
    
    [self exitContentTransfer];
    
#endif
    
        NSString *pageLink = pageLink(ANALYTICS_TrackState_Value_PageName_PhoneFinish, ANALYTICS_TrackAction_Name_Close);
        
        NSMutableDictionary *paramDictionary = [NSMutableDictionary dictionary];
        
        [paramDictionary setObject:ANALYTICS_TrackAction_Name_Close forKey:ANALYTICS_TrackAction_Key_LinkName];
        [paramDictionary setObject:pageLink forKey:ANALYTICS_TrackAction_Key_PageLink];
        
        
        if ( !self.isSender) {
            
            if ([self isValidMDN]) {
                
                [paramDictionary setObject:self.mdnTextField.text forKey:ANALYTICS_TrackAction_Param_Key_MDN];
                
            }else {
                    [paramDictionary setObject:@"null" forKey:ANALYTICS_TrackAction_Param_Key_MDN];
            }
        
        }
        
        [self.sharedAnalytics trackAction:ANALYTICS_TrackAction_Name_Close data:paramDictionary];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"video_err_segue"]) {
        VZSummaryWithVideoErrorTableViewController *targetController = (VZSummaryWithVideoErrorTableViewController *)segue.destinationViewController;
        targetController.videoErrList = self.videoErrList;
        targetController.photoErrList = self.photoErrList;
        
        targetController.videoList = self.videoList;
        targetController.videoErrHeights = self.videoErrHeights;
        
        targetController.numberOfPhotos = self.numberOfPhotos;
        targetController.numberOfVideos = self.numberOfVideos;
        targetController.numberOfContacts = self.numberOfContacts;
        
        targetController.hasVcardPermissionErr = self.hasVcardPermissionErr;
        targetController.hasAlbumPermissionErr = self.hasAlbumPermissionErr;
    }
}

- (void)captureAbodeAnalyticsOnTransferFinish:(BOOL)sender  time:(NSInteger)totaldurationInSeconds {
    
    //REVIEW : Is this right data ?
    self.pageName = ANALYTICS_TrackState_Value_PageName_PhoneFinish;
    
     NSMutableDictionary *dataToPost = [NSMutableDictionary dictionary];

    
    if (sender) {
//Prakash_Analytics changes
//        [dataToPost setObject:ANALYTICS_TrackAction_Value_SenderReceiver_Sender forKey:ANALYTICS_TrackAction_Key_SenderReceiver];
        
    } else {
        if (transferStarted) {
            [dataToPost setObject:ANALYTICS_TrackAction_Param_Value_FlowName_TransferToReceiver forKey:ANALYTICS_TrackAction_Param_Key_FlowName];
            
            [dataToPost setObjectIfValid:[NSString stringWithFormat:@"%.f", _downloadDataSize]
                                  forKey:ANALYTICS_TrackAction_Key_DataVolumeTransferred defaultObject:@0];
            
            NSString *strAvgSpeed = [NSString stringWithFormat:@"%.f",self.avgSpeed];
            
            if ([strAvgSpeed isEqualToString:@"nan"]) {
                strAvgSpeed = @"0";
            }
            
            [dataToPost setObjectIfValid:strAvgSpeed forKey:ANALYTICS_TrackAction_Key_TransferSpeed defaultObject:@0];
            
            if (totaldurationInSeconds > 0) {
                [dataToPost setObjectIfValid:[NSString stringWithFormat:@"%lld",(long long)totaldurationInSeconds] forKey:ANALYTICS_TrackAction_Key_TransferDuration defaultObject:@0];
            } else {
                
                [dataToPost setObjectIfValid:@"0" forKey:ANALYTICS_TrackAction_Key_TransferDuration defaultObject:@0];
            }

        }
        
        [dataToPost setObject:self.uuid_string forKey:ANALYTICS_TrackAction_Key_TransactionId];
    
         [dataToPost setObject:ANALYTICS_TrackAction_Value_SenderReceiver_Receiver forKey:ANALYTICS_TrackAction_Key_SenderReceiver];
        
        NSMutableString *tempMediaType = [[NSMutableString alloc] init];
// Prakash_Analytics Changes
        if (mediaTypePiped.length > 0) {
//            tempMediaType = [mediaTypePiped mutableCopy];
            
            if ([mediaTypePiped rangeOfString:@"photos"].location != NSNotFound) {
               
                if (self.numberOfPhotos) {
                    
                    [dataToPost setObject:[NSString stringWithFormat:@"%li",self.numberOfPhotos]
                                   forKey:ANALYTICS_TrackAction_Key_NbPhotosTransferred];
                } else {
                    
                    [dataToPost setObject:[NSString stringWithFormat:@"0"]
                                   forKey:ANALYTICS_TrackAction_Key_NbPhotosTransferred];
                }
                
                [tempMediaType appendString:@"photos"];
                
            }
            if ([mediaTypePiped rangeOfString:@"videos"].location != NSNotFound) {
                
                if (self.numberOfVideos) {
                    
                    [dataToPost setObject:[NSString stringWithFormat:@"%li",self.numberOfVideos]
                                   forKey:ANALYTICS_TrackAction_Key_NbVideosTransferred];
                } else {
                    
                    [dataToPost setObject:[NSString stringWithFormat:@"0"]
                                   forKey:ANALYTICS_TrackAction_Key_NbVideosTransferred];
                }
                if (tempMediaType.length > 0) {
                    
                    [tempMediaType appendString:@"|"];
                }
                
                [tempMediaType appendString:@"videos"];
                
            }
            if ([mediaTypePiped rangeOfString:@"calendars"].location != NSNotFound) {
                
                if (self.numberOfCalendar) {
                    
                    [dataToPost setObject:[NSString stringWithFormat:@"%li",self.numberOfCalendar]
                                   forKey:ANALYTICS_TrackAction_Key_NbCalendarsTransferred];
                } else {
                    
                    [dataToPost setObject:[NSString stringWithFormat:@"0"]
                                   forKey:ANALYTICS_TrackAction_Key_NbCalendarsTransferred];
                }
                
                if (tempMediaType.length > 0) {
                    
                    [tempMediaType appendString:@"|"];
                }
                [tempMediaType appendString:@"calendars"];
                
            }
            if ([mediaTypePiped rangeOfString:@"contacts"].location != NSNotFound) {
                
                if (self.numberOfContacts) {
                    
                    [dataToPost setObject:[NSString stringWithFormat:@"%li",(long)self.numberOfContacts]
                                   forKey:ANALYTICS_TrackAction_Key_NbContactsTransferred];
                } else {
                    
                    [dataToPost setObject:[NSString stringWithFormat:@"0"]
                                   forKey:ANALYTICS_TrackAction_Key_NbContactsTransferred];
                }
                if (tempMediaType.length > 0) {
                    
                    [tempMediaType appendString:@"|"];
                }
                [tempMediaType appendString:@"contacts"];
                
            }
            if ([mediaTypePiped rangeOfString:@"reminders"].location != NSNotFound) {
                
                if (self.numberOfReminder) {
                    
                    [dataToPost setObject:[NSString stringWithFormat:@"%li",self.numberOfReminder]
                                   forKey:ANALYTICS_TrackAction_Key_NbReminderTransferred];
                } else {
                    
                    [dataToPost setObject:[NSString stringWithFormat:@"0"]
                                   forKey:ANALYTICS_TrackAction_Key_NbReminderTransferred];
                }
                if (tempMediaType.length > 0) {
                     [tempMediaType appendString:@"|"];
                }
                [tempMediaType appendString:@"reminders"];
                
            }
            
        } else {
                // if media selected is nil
        }
        
//        [dataToPost setObjectIfValid:tempMediaType forKey:ANALYTICS_TrackAction_Key_MediaSelected defaultObject:@""];
        
        NSMutableString *senderDeviceId = [[NSUserDefaults standardUserDefaults] valueForKey:USER_DEFAULTS_PAIRING_DEVICE_ID];
        if (senderDeviceId) {
            NSString *allId = [senderDeviceId stringByAppendingString:[NSString stringWithFormat:@"|%@",self.uuid_string]];
            [dataToPost setObject:allId forKey:ANALYTICS_TrackAction_SenderReceiverTransactionId];
        } else {
            NSString *allId = [NSString stringWithFormat:@"senderId|%@",self.uuid_string];
            [dataToPost setObject:allId forKey:ANALYTICS_TrackAction_SenderReceiverTransactionId];
        }
    }
    
    NSString *message = @"";
    if (_analyticsTypeID == TRANSFER_SUCCESS) {
        // Store local analystics for both sender & receiver sides
        message = @"success";
    } else if (_analyticsTypeID == TRANSFER_INTERRUPTED) {
        
        // Sender side crash
        message = @"data transfer interrupted";
    } else if (_analyticsTypeID == TRANSFER_CANCELLED) {
        
        // Sender & receiver side cancelled
        message = @"transfer cancelled";
    } else if (_analyticsTypeID == INSUFFICIENT_STORAGE) {
        
        // Transfer cancelled because of insufficient storage
        message = @"transfer cancelled insufficient storage";
    } else if (_analyticsTypeID == CONNECTION_FAILED) {
        
        // Transfer cancelled because of insufficient storage
        message = @"connection failed";
    } else if (_analyticsTypeID == USER_FORCE_CLOSE) {
        
        // User force close the app on one side failed the connection
        message = @"transfer cancelled user force close";
    }
    
    if (!self.isSender) {
       
        if (_analyticsTypeID != TRANSFER_SUCCESS) {
            
            [dataToPost setObject:message forKey:ANALYTICS_TrackAction_Key_ErrorMessage];
            
            if ((_analyticsTypeID == TRANSFER_CANCELLED) && transferStarted) {
                
                [dataToPost setObject:ANALYTICS_TrackAction_Param_Value_FlowInitiated_1 forKey:ANALYTICS_TrackAction_Key_FlowCompleted];
            }
            
        } else if (transferStarted) {
            
            [dataToPost setObject:ANALYTICS_TrackAction_Param_Value_FlowInitiated_1 forKey:ANALYTICS_TrackAction_Key_FlowCompleted];
        }
    }
    
    self.analyticsData = dataToPost;

}

- (void)exitContentTransfer {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ExitContentTransfer" object:self.navigationController];
}


@end
