//
//  CTTransferDetailsViewController.h
//  contenttransfer
//
//  Created by Mehta, Snehal Natwar on 8/30/16.
//  Copyright © 2016 Verizon. All rights reserved.
//

#import "VZCTViewController.h"
#import "CTCustomLabel.h"

/*! Enumerations for data status showing on detail page.*/
typedef NS_ENUM(NSInteger, CTDataTransferStatus) {
    /*! Transfer finished.*/
    CTDataTransferStatus_Ok,
    /*! Transfer has error, showing warning icon.*/
    CTDataTransferStatus_Warning,
    /*! Transfer has photo with permission error.*/
    CTDataTransferStatus_Permission_Photo,
    /*! Transfer has video with permission error.*/
    CTDataTransferStatus_Permission_Video,
    /*! Transfer has contact with permission error.*/
    CTDataTransferStatus_Permission_Vcard,
    /*! Transfer has calendar with permission error.*/
    CTDataTransferStatus_Permission_Calendar,
    /*! Transfer has reminder with permission error.*/
    CTDataTransferStatus_Permission_Reminder
};

/*!
 Detail page for content transfer after transfer finished.
 
 To reach this page, after finish/interrupted one transfer, click "Recap" button to proceed to summary page. Click any cell will push this view controller into stack.
 */
@interface CTTransferDetailsViewController : VZCTViewController

@property (weak, nonatomic) IBOutlet CTPrimaryMessageLabel *transferStatusLabel;
@property (weak, nonatomic) IBOutlet CTRomanFontLabel *transferStatusDetailLabel;
@property (nonatomic, weak) IBOutlet UIImageView *statusImageView;
@property (nonatomic, weak) IBOutlet UIView *surveyLinkContainer;
/*!
 Status of current data type to show. Using CTDataTransferStatus enum.
 @see CTDataTransferStatus
 */
@property (nonatomic, assign) CTDataTransferStatus dataTransferStatus;
/*! BOOL value indicate should show information about iCloud or not. Default is NO. Only set to YES when sender side has cloud photos or videos.*/
@property (nonatomic, assign) BOOL shouldShowCloudInfo;
/*! Type of data for cloud. Used when @b shouldShowCloudInfo set to YES. Available value is 0 and 1. Default is 0, 0 means photo, 1 means video.*/
@property (nonatomic, assign) NSInteger cloudType;
/*! List of file that failed to received in new device. Receiver side only.*/
@property (nonatomic, strong) NSArray *targetFailedList;

@end
