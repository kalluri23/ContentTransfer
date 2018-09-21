//
//  VZTransferFInishViewController.h
//  VZTransferSocket
//
//  Created by VVM-MAC02 on 12/2/15.
//  Copyright © 2015 Testing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CTMVMViewController.h"
#import "CTMVMButtons.h"
#import "VZContactsImport.h"
#import "CTMVMAlertAction.h"
#import "CTMVMAlertObject.h"
#import "CTMVMAlertHandler.h"
#import "VZContentTransferSingleton.h"
#import "GCDAsyncSocket.h"
#import "VZCTViewController.h"
#import "CTMVMColor.h"



@protocol photoStatusUpdate <NSObject>

- (void)updateSavingProcessDataWithPhotoNumber:(int)savedPhotoNumber
                                andVideoNumber:(int)savedVideoNumber
                            andVideoFailedInfo:(NSArray *)videoFailedList
                            andPhotoFailedInfo:(NSArray *)photoFailedList;

@end

@interface VZTransferFinishViewController : VZCTViewController<photoStatusUpdate>

@property (assign, nonatomic) NSInteger analyticsTypeID;

@property (weak, nonatomic) IBOutlet UILabel *totalTimeElapsed;
@property (weak, nonatomic) IBOutlet UILabel *timeLbl;
@property (weak, nonatomic) IBOutlet UILabel *totaldataDownloaded;
@property (weak, nonatomic) IBOutlet UILabel *downloadLbl;
@property (weak, nonatomic) IBOutlet UILabel *totalFileReceived;


//REVIEW : (Code commented) @property (weak, nonatomic) IBOutlet UILabel *videoSavingLbl;
//REVIEW : (Code commented) @property (weak, nonatomic) IBOutlet UILabel *videoFormatSpecificInfoLbl;
@property (weak, nonatomic) IBOutlet UILabel *finishedLbl;
@property (weak, nonatomic) IBOutlet UIButton *okBtn;
@property (weak, nonatomic) IBOutlet UIButton *sendMDNBtn;
@property (weak, nonatomic) IBOutlet UILabel *mdnValidationStatusLbl;
@property (weak, nonatomic) IBOutlet UILabel *mdnSurveyInfo;
@property (weak, nonatomic) IBOutlet UILabel *downLoadedDataProcessingLbl;
@property (weak, nonatomic) IBOutlet UIButton *summaryBtn;
@property (weak, nonatomic) IBOutlet UIImageView *finishImage;
@property (weak, nonatomic) IBOutlet UITextField *mdnTextField;


@property(nonatomic,strong) NSString *downLoadDataLblStr;
@property(weak,nonatomic) id<photoStatusUpdate> delegate;

@property (nonatomic, assign) long numberOfPhotos;
@property (nonatomic, assign) long numberOfVideos;
@property (nonatomic, assign) long numberOfCalendar;
@property (nonatomic, assign) long numberOfReminder;
@property (nonatomic,assign) float maxspeed;
@property (nonatomic,assign) float avgSpeed;

@property (nonatomic, assign) BOOL calendarReceived;

@property (nonatomic, assign) int summaryDisplayFlag;

@property (weak, nonatomic) AppDelegate *app;


@property (assign, nonatomic) BOOL processEnd;

@property (nonatomic, assign) NSInteger numberOfContacts;
//@property (nonatomic,strong) GCDAsyncSocket *asyncsocket;
//@property (nonatomic,strong) GCDAsyncSocket *listernSocket;

@property (nonatomic, assign) NSArray *videoErrList;
@property (nonatomic, assign) NSArray *photoErrList;

@property (nonatomic, strong) NSMutableArray *videoList;
@property (nonatomic, strong) NSMutableArray *videoErrHeights;

@property (nonatomic, assign) BOOL isSender;

@property (nonatomic, assign) BOOL hasVcardPermissionErr;
@property (nonatomic, assign) BOOL hasAlbumPermissionErr;
@property (assign,nonatomic) BOOL transferInterrupted;
@property (nonatomic,assign) BOOL importReminder;
@property (nonatomic,strong) NSString *mediaTypePiped;
@property (nonatomic,assign) BOOL transferStarted;



- (IBAction)clickedOnSummary:(id)sender;
@end

