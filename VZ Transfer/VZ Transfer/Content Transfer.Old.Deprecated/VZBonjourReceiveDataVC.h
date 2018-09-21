//
//  VZBonjourReceiveDataVC.h
//  VZTransferSocket
//
//  Created by VVM-MAC02 on 2/2/16.
//  Copyright © 2016 Testing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VZFileLogManager.h"
#import "BonjourManager.h"
#import "VZContactsImport.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "VZPhotosExport.h"
#import "VZFileLogManager.h"
#import <mach/mach.h>
#import <mach/mach_host.h>
#import "VZTransferFinishViewController.h"
#import "CTMVMViewController.h"
#import "CTMVMButtons.h"
#import "CTMVMAlertAction.h"
#import "CTMVMAlertObject.h"
#import "CTMVMAlertHandler.h"
#import "VZContentTransferSingleton.h"
#import "VZCTViewController.h"
#import "CTNoInternetViewController.h"
#import "VZRemindersImoprt.h"


enum state_machine {
    
    HAND_SHAKE,
    RECEIVE_ALL_FILE_LOG,
    RECEIVE_VCARD_FILE,
    RECEIVE_PHOTO_LOG_FILE,
    RECEIVE_PHOTO_FILE,
    RECEIVE_VIDEO_LOG_FILE,
    RECEIVE_VIDEO_FILE,
    RECEIVE_CALENDAR_FILE,
    RECEVIE_REMINDER_FILE
    
};

@interface VZBonjourReceiveDataVC : VZCTViewController {
    
    BOOL vcardStartFound;
    BOOL newImageFound;
    BOOL vCardFileImportedSucessful;
    BOOL photoLogFileReceived;
    enum state_machine recevier_state;
}


@property(nonatomic,assign) long long vCardfile_size;
@property(nonatomic,assign) long long photofile_size;
@property(nonatomic,assign) int photoCountIndex;
@property(nonatomic,assign) long long videofile_size;
@property(nonatomic,assign) long long tillNowVideoReceived;
@property(nonatomic,assign) int videoCountIndex;
@property(nonatomic,strong) NSMutableData *receivedData;
@property(nonatomic,strong) NSArray *photolist;
@property(nonatomic,strong) NSArray *calList;
@property(nonatomic,strong) NSDictionary *photoinfo;
@property(nonatomic,strong) NSArray *videolist;
@property(nonatomic,strong) NSDictionary *videoinfo;
@property(nonatomic,weak) IBOutlet UILabel *receivedFileStatuLbl;
//@property(nonatomic,strong)NSFileHandle *fileHandle;
@property(nonatomic,strong) NSString *documentsDirectory;
@property(nonatomic,weak) NSString *filePath;
@property(nonatomic,strong) NSString *fileName;

@property (weak, nonatomic) IBOutlet UILabel *totalDownLoadedDataLbl;
@property (weak, nonatomic) IBOutlet UILabel *downloadSpeedLbl;
@property (weak, nonatomic) IBOutlet UILabel *timeElaspedLbl;
@property(nonatomic,assign) double totalDownloadedData;
@property(nonatomic,assign) double downloadSpeed;
@property(nonatomic,strong) NSDate *startTime;
@property(nonatomic,weak) NSDate *endTime;
@property(nonatomic,strong) VZFileLogManager *fileLogManager;
@property(nonatomic,strong) NSMutableDictionary *currentPhotodict;
@property(nonatomic,strong) NSMutableDictionary *currentVideodict;

@property (weak, nonatomic) IBOutlet UIImageView *receiverAnimationImgVIew;
@property(nonatomic,assign) long long totaldownloadableData;
@property (weak, nonatomic) IBOutlet UILabel *totalDownloadDataSizeLbl;
@property (weak, nonatomic) IBOutlet UILabel *timeestimatedLbl;
@property(nonatomic,assign) int totalFilesReceived;
@property(nonatomic,strong) NSOperationQueue *serailPhotoQueue;
@property(nonatomic,strong) NSOperationQueue *serailPhotoQueue2;
@property(nonatomic,strong) NSOperationQueue *serailPhotoQueue3;
@property(nonatomic,strong) NSOperationQueue *serailPhotoQueue4;
@property(nonatomic,strong) NSOperationQueue *serailPhotoQueue5;
@property(nonatomic,strong) NSOperationQueue *serailPhotoQueue6;
@property(nonatomic,strong) NSOperationQueue *serailVideoQueue;
@property(nonatomic,strong) NSOperationQueue *serailVideoQueue2;
@property(nonatomic,assign) BOOL videoFlag;
@property(atomic,assign) int tempPhotoCount;
@property(atomic,assign) int tempVideoCount;
@property(nonatomic,assign) long long totalPayLoadSize;
@property(nonatomic,assign) long long availableStorage;
//@property(nonatomic,strong) dispatch_queue_t serialQueue;
@property (weak, nonatomic) IBOutlet UILabel *dataReceivingStatus;
@property(nonatomic,assign) BOOL memoryWarningFlag;
@property (weak, nonatomic) IBOutlet UILabel *processingDataLbl;
@property(nonatomic,assign) NSTimer *processLblTimer;
@property(nonatomic,assign) BOOL allPhotoDownLoadFlag;
@property(nonatomic,assign) BOOL allfileLogStartFound;
@property(nonatomic,assign) BOOL vcardfileStartfound;
@property(nonatomic,assign) BOOL photofileStartFound;
@property(nonatomic,assign) BOOL videofileStartFound;
- (IBAction)ClickedOnCancelBtn:(id)sender;
@property(nonatomic,strong) NSString *photoFolderPath;
@property(nonatomic,strong) NSString *videoFolderPath;
@property(weak,nonatomic) id<photoStatusUpdate> delegate;

@property (weak, nonatomic) IBOutlet UIButton *cancelBtn;
@property (weak, nonatomic) AppDelegate *app;

@property (atomic, strong) NSMutableArray *localDuplicateList;
@property (atomic, strong) NSMutableArray *localDuplicateVideoList;
@property (nonatomic, strong) NSTimer *heartBeatTimer;
@property (weak, nonatomic) IBOutlet UILabel *keepAppOpenLbl;
@property (nonatomic,assign) BOOL reminderFound;
@property (nonatomic,assign) long long reminderfile_Size;
@property(nonatomic,assign) BOOL reminderStartFound;
@property (nonatomic,assign) BOOL reminderPermissionNotDetermine;
@property (nonatomic,strong) NSString *mediaTypePiped;
@property (nonatomic,assign) BOOL receviedCancelRequest;
@end
