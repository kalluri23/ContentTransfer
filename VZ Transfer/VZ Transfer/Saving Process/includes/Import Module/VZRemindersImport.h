//
//  VZRemindersExport.h
//  myverizon
//
//  Created by Tourani, Sanjay on 4/5/16.
//  Copyright © 2016 Verizon Wireless. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <EventKit/EventKit.h>
#import "VZEventManager.h"
#import "CTMVMAlertAction.h"
#import "CTMVMAlertObject.h"
#import "CTMVMAlertHandler.h"

#pragma mark - Block define
/*! Permission success handler.*/
typedef void (^successHandler)(void);
/*! 
 Permission failure handler.
 @param status EKAuthorizationStatus value represents the failure status.
 */
typedef void (^failureHandler)(EKAuthorizationStatus status);
/*!
 Update block for importing reminder events.
 @param $0 NSIntger value represents the reminder events saved count.
 @param $1 NSIntger value represents the reminder events total count.
 */
typedef void (^reminderImportUpateBlock)(NSInteger, NSInteger);
/*!
 Completion block for importing reminder events.
 @param $0 NSIntger value represents the reminder events saved count.
 @param $1 NSIntger value represents the reminder events total count.
 @param $2 NSIntger value represents the reminder list acutal saved count. This is used for local analytics.
 */
typedef void (^reminderImportCompletionBlock)(NSInteger, NSInteger, NSInteger);
#pragma mark -

/*! Reminder import object. This class contains all the logic related to importing reminder list/event.*/
@interface VZRemindersImport : NSObject
#pragma mark - Properties
/*! Event manager using for access reminder data.*/
@property (nonatomic, strong) VZEventManager *eventManager;
/*! Completion handler after reminder import finished.*/
@property (nonatomic, copy) reminderImportCompletionBlock completionHandler;
/*! Update handler during importing reminder. Use this to update the UI.*/
@property (nonatomic, copy) reminderImportUpateBlock updateHandler;

#pragma mark - Deprecated properties
/*! Deprecated. Old logic property.*/
@property (nonatomic, assign) BOOL isAccessToEventStoreGranted;

#pragma mark - Class methods
/*!
 @brief Check authorization status for reminders.
 @param success successHandler callback if user granted access.
 @param failed failureHandler callback if user denied access.
 */
+ (void)updateAuthorizationStatusToAccessEventStoreSuccess:(successHandler)success failed:(failureHandler)failure;
/*!
 @brief Get total reminder count for specific reminder log file. This method will get both reminder list count and reminder event count.
 @note Result will be represents using Number object with NSInteger value.
 @param reminderURL The file URL to read reminder log file.
 @return NSArray contains both count. This array will always have 2 items in it. $0 will be list count and $1 will be event count.
 */
+ (NSArray *)getTotalReminderCountForSpecificFile:(NSString *)reminderURL;

#pragma mark - Instance methods
/*!
 @brief Start importing the reminder from reminder log file.
 @param hasTotalCount Bool value indicate that before calling this method, total number of reminder events already be known or not. If known, method will pass the count calculation.
 */
- (void)importAllReminder:(BOOL)hasTotalCount;

@end
