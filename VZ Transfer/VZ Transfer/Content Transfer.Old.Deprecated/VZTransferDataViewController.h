//
//  VZTransferViewController.h
//  VZTransferSocket
//
//  Created by VVM-MAC02 on 11/30/15.
//  Copyright © 2015 Testing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VZContactsExport.h"
#import "GCDAsyncSocket.h"
#import "VZPhotosExport.h"
#import "VZTransferStatusModel.h"
#import "VZActivityOverlay.h"
#import "CDActivityIndicatorView.h"
#import "CTMVMViewController.h"
#import "CTMVMButtons.h"
#import "CTMVMAlertAction.h"
#import "CTMVMAlertObject.h"
#import "CTMVMAlertHandler.h"
#import "VZContentTransferSingleton.h"
#import "VZCTViewController.h"
#import "VZCalenderEventsExport.h"
#import "CTNoInternetViewController.h"
#import "VZRemindersExport.h"


enum state_machine {
    HAND_SHAKE,
    TRANSFER_ALL_FILE,
    TRANSFER_VCARD_FILE,
    TRANSFER_PHOTO_LOG_FILE,
    TRANSFER_PHOTO_FILE,
    TRANSFER_VIDEO_LOG_FILE,
    TRANSFER_VIDEO_FILE,
    TRANSFER_COMPLETED,
    TRANSFER_NEXT_VIDEO_PART,
    TRANSFER_CALENDER_LOG_FILE,
    TRANSFER_REMINDER_LOG_FILE,
    TRANSFER_CALENDER_ICS_FILE,
    TRASNFER_REMINDER_ICS_FILE,
    TRASNFER_FILE_DUPLICATE,
    TRANSFER_CALENDAR_FILE_START,
    TRANSFER_CALENDAR_FILE,
    TRANSFER_CALENDAR_FILE_END
};

extern NSString *const GCD_ALWAYS_READ_QUEUE;


@interface VZTransferDataViewController : VZCTViewController {
    
//    GCDAsyncSocket *asyncSocket, *asyncNewSocket;
//    GCDAsyncSocket *listenOnPort;
    enum state_machine transfer_state;
    int presentState;
    int nextState;
}

@property(nonatomic,strong) GCDAsyncSocket *asyncSocket,*asyncSocketCOMMPort;
@property(nonatomic,strong) GCDAsyncSocket *listenOnPort,*listenOnPortCOMMPort;
@property(nonatomic,weak)IBOutlet UILabel *numberOfContacts;
@property (weak, nonatomic) IBOutlet UILabel *numberOfContactCrossplatform;
@property(nonatomic,weak)IBOutlet UILabel *numberOfPhotos;
@property (weak, nonatomic) IBOutlet UILabel *numberOfLocalPhotos;
@property (weak, nonatomic) IBOutlet UILabel *numberOfCloudPhotos;
@property(nonatomic,weak)IBOutlet UIButton *transferBtn;
@property(nonatomic,strong)VZPhotosExport *photolist;
@property(nonatomic,assign) int photoCount;
@property(nonatomic,assign) int videoCount;
@property (weak, nonatomic) IBOutlet UIView *crossPlatformListView;
@property(nonatomic,weak)IBOutlet UIView *itemListView;
@property(nonatomic,weak)IBOutlet UIView *sendingStatusView;
@property(nonatomic,weak)IBOutlet UILabel *transferStatusLbl;
@property(nonatomic,weak)IBOutlet UILabel *numberOfVideo;
@property (weak, nonatomic) IBOutlet UILabel *numberOfLocalVideo;
@property (weak, nonatomic) IBOutlet UILabel *numberOfCloudVideo;
@property (weak, nonatomic) IBOutlet UILabel *photosLbl;
@property (weak, nonatomic) IBOutlet UILabel *photoCrossLbl;
@property (weak, nonatomic) IBOutlet UILabel *contactsLbl;
@property (weak, nonatomic) IBOutlet UILabel *contactCrossplatformLbl;
@property (weak, nonatomic) IBOutlet UILabel *videosLbl;
@property (weak, nonatomic) IBOutlet UILabel *videoCrossLbl;
@property(nonatomic,assign) int photoTransferCount;
@property(nonatomic,assign) int videoTransferCount;
@property(nonatomic,assign) long videofileize;
@property(nonatomic,assign) long offset;
@property(nonatomic,assign) int BUFFERSIZE;
@property (weak, nonatomic) IBOutlet UIImageView *trasnferAnimationImgView;
@property(nonatomic,strong) NSMutableDictionary *itemlist;
@property (weak, nonatomic) IBOutlet CDActivityIndicatorView *overlayActivity;
@property(nonatomic,assign) int totalNoOfFilesTransfered;
@property(nonatomic,assign) BOOL isMemoryWarningReceived;
@property (weak, nonatomic) IBOutlet UIButton *selectAllBtn;
@property (weak, nonatomic) IBOutlet UIButton *selectAllBtnCrossPlatform;
@property (weak, nonatomic) IBOutlet UILabel *transferWhtLbl;
@property (weak, nonatomic) IBOutlet UILabel *sendingLbl;

@property (weak, nonatomic) IBOutlet UILabel *selectAllLbl;
@property (weak, nonatomic) IBOutlet UILabel *selectAllCrossPlatform;

@property(nonatomic,strong) ALAssetRepresentation *currentALAseetRep;
@property(nonatomic,assign)long long sentVideoDataSize;
@property(nonatomic,assign) int countOfPhotos;
@property(nonatomic,assign) int countOfVideo;
@property(nonatomic,assign) int countOfContacts;


@property (weak, nonatomic) AppDelegate *app;

- (IBAction)ClickedSelectAll:(id)sender;


- (IBAction)clickedOnTransfer:(id)sender;

//- (IBAction)clickedOnCancel:(id)sender;

@property (weak, nonatomic) IBOutlet UIButton *vcardBtn;
@property (weak, nonatomic) IBOutlet UIButton *vcardBtnCrossPlatform;

@property (weak, nonatomic) IBOutlet UIButton *photoBtn;
@property (weak, nonatomic) IBOutlet UIButton *localPhotoBtn;
@property (weak, nonatomic) IBOutlet UIButton *cloudPhotoBtn;

@property (weak, nonatomic) IBOutlet UIButton *videoBtn;
@property (weak, nonatomic) IBOutlet UIButton *localVideoBtn;
@property (weak, nonatomic) IBOutlet UIButton *cloudVideoBtn;
@property (weak, nonatomic) IBOutlet UIButton *cancelBtn;
@property (weak, nonatomic) IBOutlet UIButton *leftCancelBtn;
@property (weak, nonatomic) IBOutlet UIButton *leftCancelCrossPlatform;

@property (weak, nonatomic) IBOutlet UILabel *videoFormatInfoLbl;
@property (weak, nonatomic) IBOutlet UIButton *cloudPhotoBackBtnCross;

- (IBAction)cloudPhotoCrossAskForPermissions:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *cloudVideoBackBtnCross;
- (IBAction)cloudVideoBackBtnCross:(id)sender;


@end
