//
//  VZBonjourTransferDataVC.h
//  VZTransferSocket
//
//  Created by VVM-MAC02 on 2/2/16.
//  Copyright © 2016 Testing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VZContactsExport.h"
#import "GCDAsyncSocket.h"
#import "VZPhotosExport.h"
#import "VZTransferStatusModel.h"
#import "VZActivityOverlay.h"
#import "CDActivityIndicatorView.h"
#import "BonjourManager.h"
#import "CTMVMViewController.h"
#import "CTMVMButtons.h"
#import "VZTransferFinishViewController.h"
#import "CTMVMAlertAction.h"
#import "CTMVMAlertObject.h"
#import "CTMVMAlertHandler.h"
#import "VZContentTransferSingleton.h"
#import "VZCTViewController.h"
#import "CTNoInternetViewController.h"
#import "VZRemindersExport.h"
#define BONJOUR_BUFFERSIZE 8192


enum state_machine {
    
    HAND_SHAKE,
    TRANSFER_ALL_FILE,
    TRANSFER_VCARD_FILE,
    TRANSFER_PHOTO_LOG_FILE,
    TRANSFER_PHOTO_FILE,
    TRANSFER_VIDEO_LOG_FILE,
    TRANSFER_VIDEO_FILE,
    TRANSFER_COMPLETED,
    TRANSFER_PHOTO_RECONNECTED,
    TRANSFER_VIDEO_RECONNECTED,
    TRANSFER_VCARD_RECONNECTED,
    TRANSFER_ALL_FILE_LOG_RECONNECTED,
    TRANSFER_CALENDER_LOG_FILE,
    TRANSFER_REMINDER_LOG_FILE,
    TRANSFER_CALENDER_ICS_FILE,
    TRASNFER_REMINDER_ICS_FILE,
    TRANSFER_CANCEL,
    TRANSFER_CALENDAR_FILE_START,
    TRANSFER_CALENDAR_FILE,
    TRANSFER_CALENDAR_FILE_END
};

@interface VZBonjourTransferDataVC : VZCTViewController {
    
    enum state_machine transfer_state;
    int presentState;
    int nextState;
}
@property (weak, nonatomic) IBOutlet UILabel *transferWhtLbl;
@property (weak, nonatomic) IBOutlet UILabel *sendingLbl;

@property(nonatomic,weak)IBOutlet UILabel *numberOfContacts;
@property(nonatomic,weak)IBOutlet UILabel *numberOfPhotos;
@property(nonatomic,weak)IBOutlet UIButton *transferBtn;
@property(nonatomic,strong)VZPhotosExport *photolist;
@property(nonatomic,assign) int photoCount;
@property(nonatomic,assign) int videoCount;
@property(nonatomic,weak)IBOutlet UIView *itemListView;
@property(nonatomic,weak)IBOutlet UIView *sendingStatusView;
@property(nonatomic,weak)IBOutlet UILabel *transferStatusLbl;
@property(nonatomic,weak)IBOutlet UILabel *numberOfVideo;
@property(nonatomic,assign) int photoTransferCount;
@property(nonatomic,assign) int videoTransferCount;
@property (weak, nonatomic) IBOutlet UILabel *contactsLbl;
@property (weak, nonatomic) IBOutlet UILabel *photosLbl;
@property (weak, nonatomic) IBOutlet UILabel *videosLbl;
@property(nonatomic,assign) long long videofileize;
@property(nonatomic,assign) long offset;
@property(nonatomic,assign) int BUFFERSIZE;
@property (weak, nonatomic) IBOutlet UIImageView *trasnferAnimationImgView;
@property(nonatomic,strong) NSMutableDictionary *itemlist;
@property (weak, nonatomic) IBOutlet CDActivityIndicatorView *overlayActivity;
@property (weak, nonatomic) IBOutlet UILabel *selectAllLbl;
@property(nonatomic,assign) int totalNoOfFilesTransfered;
@property(nonatomic,strong) NSData *dataTobeTransmitted;
@property(nonatomic,assign) int startIndex;
@property(nonatomic,strong) ALAssetRepresentation *videoALAssetRepresentation;
@property(nonatomic,assign) BOOL videofirstPacket;
//@property(nonatomic,assign) long long sentDataSize;
@property(nonatomic,assign) int isVideo;
@property(nonatomic,assign) long long byteActuallyWrite;
@property(nonatomic,assign) int countOfPhotos;
@property(nonatomic,assign) int countOfVideo;
@property(nonatomic,assign) int countOfContacts;

- (IBAction)ClickedSelectAll:(id)sender;


- (IBAction)clickedOnTransfer:(id)sender;

- (IBAction)clickedOnTransferCancel:(id)sender;

@property (weak, nonatomic) IBOutlet UIImageView *vcardIcon;
@property (weak, nonatomic) IBOutlet UIButton *vcardBtn;

@property (weak, nonatomic) IBOutlet UIImageView *photoIcon;
@property (weak, nonatomic) IBOutlet UIButton *photoBtn;

@property (weak, nonatomic) IBOutlet UIImageView *videoIcon;
@property (weak, nonatomic) IBOutlet UIButton *videoBtn;
@property (weak, nonatomic) IBOutlet UIButton *selectAllBtn;
@property (weak, nonatomic) IBOutlet UIButton *cancelBtn;
@property (weak, nonatomic) IBOutlet UIButton *leftCancelBtn;
@property (weak, nonatomic) AppDelegate *app;

@property (weak, nonatomic) IBOutlet UIButton *vcardBackBtn;
@property (weak, nonatomic) IBOutlet UIButton *photoBackBTN;
@property (weak, nonatomic) IBOutlet UIButton *videoBackBtn;
@property (weak, nonatomic) IBOutlet UIButton *selectallBackBtn;
@property (weak, nonatomic) IBOutlet UIView *selectionView;
@property (weak, nonatomic) IBOutlet UILabel *permissionVcardLbl;
@property (weak, nonatomic) IBOutlet UILabel *permissionPhotoLbl;
@property (weak, nonatomic) IBOutlet UILabel *permissionVideoLbl;

@end
