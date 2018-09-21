//
//  CTTransferFinishViewController.h
//  contenttransfer
//
//  Created by Mehta, Snehal Natwar on 8/22/16.
//  Copyright © 2016 Verizon. All rights reserved.
//

#import "CTViewController.h"
#import "CTFileList.h"

@interface CTTransferFinishViewController : CTViewController
/*!
    @brief This file list that current transfer use. 
    @warning This property will only used on sender side. On receiver side no file list object will be assigned, so this parameter will be the default value nil.
 */
@property (nonatomic, strong) CTFileList *fileList;
/*!When transfer completed, the completed transfer file list on sender side.*/
@property (nonatomic,strong) NSArray *resultItemList;
/*!When transfer completed, the completed transfer file list on receiver side.*/
@property (nonatomic,strong) NSArray *savedItemsList;

@property (weak, nonatomic) IBOutlet UIView *cloudBannerView;
@property (nonatomic, weak) IBOutlet UIView *buttonsContainer;
/*!Enum CTTransferStatus type for the final status of current transfer, cancelled, interrupted, etc.*/
@property (nonatomic, assign) enum CTTransferStatus transferStatusAnalytics;
@property (nonatomic, strong) NSNumber *totalDataTransferred; //As selected by user
/*!Data size that successfully transferred. Type is NSNumber with long long value.*/
@property (nonatomic, strong) NSNumber *dataTransferred;
/*!Uncomment below properties to support banner overlay*/
//@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageBottomMargin;
//@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageTopMargin;
//@property (weak, nonatomic) IBOutlet NSLayoutConstraint *labelBottomMarginConstraint;
/*!Transfer speed data. Formatted string value: xxx.xx Mbps.*/
@property (nonatomic, strong) NSString *transferSpeed;
/*!Transfer time data. Formatted string value: xxx:xxx:xxx.*/
@property (nonatomic, strong) NSString *transferTime;

/*!
    @brief Number of contacts
    @discussion This will be used for local analytics.
                
                On receiver side, this value will be assigned directly.
 
                On sender side, number of contacts will come with CTFileList object, and re-assign to this property when preparing the analytics data.
    @see CTFileList
 */
@property (nonatomic, assign) NSInteger numberOfContacts;
/*!
    @brief Number of photos
    @discussion This will be used for local analytics.
 
                On receiver side, this value will be assigned directly.
 
                On sender side, number of photos will come with CTFileList object, and re-assign to this property when preparing the analytics data.
    @see CTFileList
 */
@property (nonatomic, assign) NSInteger numberOfPhotos;
/*!
    @brief Number of videos
    @discussion This will be used for local analytics.
 
                On receiver side, this value will be assigned directly.
 
                On sender side, number of videos will come with CTFileList object, and re-assign to this property when preparing the analytics data.
    @see CTFileList
 */
@property (nonatomic, assign) NSInteger numberOfVideos;
/*!
    @brief Number of calendar lists
    @discussion This will be used for local analytics.
 
                On receiver side, this value will be assigned directly.
 
                On sender side, number of calendars will come with CTFileList object, and re-assign to this property when preparing the analytics data.
    @see CTFileList
 */
@property (nonatomic, assign) NSInteger numberOfCalendar;
/*!
    @brief Number of reminder lists
    @discussion This will be used for local analytics.
 
                On receiver side, this value will be assigned directly.
 
                On sender side, number of reminders will come with CTFileList object, and re-assign to this property when preparing the analytics data.
    @see CTFileList
 */
@property (nonatomic, assign) NSInteger numberOfReminder;
/*!
    @brief Number of apps in app list before filter them.
    @discussion This will be used for local analytics.
 
                On receiver side, this value will be assigned directly.
 
                On sender side, number of apps will come with CTFileList object, and re-assign to this property when preparing the analytics data.
    @warning Value on sender side will always be 0.
    @see CTFileList
 */
@property (nonatomic, assign) NSInteger numberOfApps;
/*! 
    @brief Number of audio file.
    @discussion This will be used for local analytics.
 
                On receiver side, this value will be 0(No receiver side will assign this value, so default value will be 0).
 
                On sender side, number of audio file will come with CTFileList object, and re-assign to this property when preparing the analytics data.
    @see CTFileList
 */
@property (nonatomic, assign) NSInteger numberOfAudios;

/*! Photo file list contains all the file that fail to save.*/
@property (nonatomic, strong) NSArray *photoFailedList;
/*! Video file list contains all the file that fail to save.*/
@property (nonatomic, strong) NSArray *videoFailedList;

@property (nonatomic) BOOL bMultiDevices;

@end
