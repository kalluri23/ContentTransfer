//
//  CTErrorViewController.h
//  contenttransfer
//
//  Created by Mehta, Snehal Natwar on 9/1/16.
//  Copyright © 2016 Verizon. All rights reserved.
//

#import "CTViewController.h"
#import "CTCustomButton.h"
#import "CTCustomLabel.h"

/*!
 Error page when something wrong happened during transfer.
 This page is the "finish view" for unsuccessful transfer. Functionalities are same as finish view but with different layout.
 */
@interface CTErrorViewController : UIViewController
/*! Primary error text message. Show on main label.*/
@property (nonatomic, strong) NSString *primaryErrorText;
/*! Secondary error text message. Show on secondary label.*/
@property (nonatomic, strong) NSString *secondaryErrorText;
/*! Button title on right corner of screen.*/
@property (nonatomic, strong) NSString *rightButtonTitle;
/*! Button title on left corner of screen.*/
@property (nonatomic, strong) NSString *leftButtonTitle;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *trailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomSpaceConstraint;
/*! Bottom space for button container view. Used to adjust bottomSpaceConstraint*/
@property (nonatomic, assign) CGFloat bottomspace;

@property (nonatomic, weak) IBOutlet UIView *buttonContainer;
@property (nonatomic, weak) IBOutlet CTPrimaryMessageLabel *primaryLabel;
@property (nonatomic, weak) IBOutlet UILabel *secondaryLabel;
@property (nonatomic, weak) IBOutlet CTCommonBlackButton *rightButton;
@property (nonatomic, weak) IBOutlet CTBlackBorderedButton *leftButton;

/*! Status list for each of the file type when interrupt/cancel happened.*/
@property (nonatomic,strong) NSArray *dataInterruptedItemsList;
/** List of saved item, this item will be used in receiver side only.*/
@property (nonatomic,strong) NSArray *savedItemsList;

/*! Total data amount transferred when interrupt/cancel happened.*/
@property (nonatomic,strong) NSNumber *totalDataSentUntillInterrupted;
/*! Total data amount that need to be transferred.*/
@property (nonatomic,strong) NSNumber *totalDataAmount;
/*! Transfer average speed. This is string value followed format:"xxx.x Mbps".*/
@property (nonatomic, strong) NSString *transferSpeed;
/*! Transfer time. This is string value contains milliseconds value for total transfer time duration.*/
@property (nonatomic, strong) NSString *transferTime;

/*! Transfer status for analytics. Use CTTransferStatus type.*/
@property (nonatomic, assign) enum CTTransferStatus transferStatusAnalytics;

/*! total number of contacts.*/
@property (nonatomic, assign) NSInteger numberOfContacts;
/*! total number of photos.*/
@property (nonatomic, assign) NSInteger numberOfPhotos;
/*! total number of videos.*/
@property (nonatomic, assign) NSInteger numberOfVideos;
/*! total number of calendars.*/
@property (nonatomic, assign) NSInteger numberOfCalendar;
/*! total number of reminders.*/
@property (nonatomic, assign) NSInteger numberOfReminder;
/*! total number of apps.*/
@property (nonatomic, assign) NSInteger numberOfApps;
/*! total number of audios.*/
@property (nonatomic, assign) NSInteger numberOfAudios;

/*! 
    @brief Indicate this is cancel on transfer what page. 
    @warning This parameter is deprecated.
 */
@property (nonatomic, assign) BOOL cancelInTransferWhatPage;

/** List of photo failed to store locally.*/
@property (nonatomic, strong) NSArray *photoFailedList;
/** List of video failed to store locally.*/
@property (nonatomic, strong) NSArray *videoFailedList;

/*!
 Handle right button click event.
 @param sender Item object that bind this event.
 */
- (void)handleRightButtonTapped:(id)sender;
/*!
 Handle left button click event.
 @param sender Item object that bind this event.
 */
- (void)handleLeftButtonTapped:(id)sender;

@end
