//
//  VZEventsExport.h
//  myverizon
//
//  Created by Tourani, Sanjay on 4/5/16.
//  Copyright © 2016 Verizon Wireless. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VZEventManager.h"
#import "CTMVMAlertAction.h"
#import "CTMVMAlertObject.h"
#import "CTMVMAlertHandler.h"
#import "EKEvent+Utilities.h"
#import "MXLCalendarManager.h"

/*! Permission success callback.*/
typedef void (^successHandler)(void);
/*!
 Permission failure callback.
 @param status @b EKAuthorizationStatus value indicate the failure reason.
 */
typedef void (^failureHandler)(EKAuthorizationStatus status);
/*! Import success callback.*/
typedef void (^importSuccessHandler)(void);
/*! Import failure callback.*/
typedef void (^importFailureHandler)(void);

/*! Protocol for calendar import object.*/
@protocol CalendarImportDelegate <NSObject>
/*!
 Call this when calendar saving got response and needs to update progress for it.
 @param eventCount Count number of saved events for current batch.
 */
- (void)shouldUpdateCalendarNumber:(NSInteger)eventCount;

@end

/*! Helper class for importing the calendar events.*/
@interface VZCalenderEventsImport : NSObject
/*!
 Delegate for calendar import helper. Target needs to be specified as @b CalendarImportDelegate.
 @see CalendarImportDelegate
 */
@property (nonatomic, weak) id<CalendarImportDelegate> delegate;
/*! Event manager using in the helper to store the event*/
@property (nonatomic,strong) VZEventManager *eventManager;
/*! Bool indicate that user granted permission to access calendar data or not.*/
@property (nonatomic) BOOL isAccessToEventStoreGranted;

#pragma mark - Class methods
/*!
 Check accessable for calendar events.
 @param success Callback when user granted permission.
 @param failure Callback when user doesn't grant permission.
 @see successHandler
 @see failureHandler
 */
+ (void)checkAuthorizationStatusToAccessEventStoreSuccess:(successHandler)success andFailureHandler:(failureHandler)failure;

#pragma mark - Instance methods.
/*!
 Create calender with events.
 @param success Callback when import done.
 @param failure Callback when import failed.
 @see importSuccessHandler
 @see importFailureHandler
 */
- (void)createCalendarsSuccess:(importSuccessHandler)success failure:(importFailureHandler)failure;
/*! Get local saved calendar data on device.*/
- (void)getLocalCalData;
/*!
 Get total count of events saved on device.
 @param handler Callback to show the result, a integer included represents the number.
 */
- (void)getTotalCalendarEventCount:(void(^)(NSInteger eventCount))handler;

@end





