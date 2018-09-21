//
//  CTEventStoreManager.h
//  contenttransfer
//
//  Created by Guntupalli, Neelima on 8/25/16.
//  Copyright © 2016 Verizon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <EventKit/EventKit.h>

/*!Manager object to helper content transfer store the EKEvent into system calendar app.*/
@interface CTEventStoreManager : NSObject
/*!
 Get authorization status for calendar of current device.
 @return CTAuthorizationStatus represents the result.
 @see CTAuthorizationStatus
 */
+ (CTAuthorizationStatus)calendarAuthorizationStatus;
/*!
 Get authorization status for reminder of current device.
 @return CTAuthorizationStatus represents the result.
 @see CTAuthorizationStatus
 */
+ (CTAuthorizationStatus)reminderAuthorizationStatus;

/*!
 Request calendar acess permission from user. Calling this will display a system permission prompt for user.
 @param completionBlock Callback to show the result of request, contains one CTAuthorizationStatus as parameter.
 */
+ (void)requestCalendarAuthorisation:(void(^)(CTAuthorizationStatus status))completionBlock;
/*!
 Request reminder acess permission from user. Calling this will display a system permission prompt for user.
 @param completionBlock Callback to show the result of request, contains one CTAuthorizationStatus as parameter.
 */
+ (void)requestReminderAuthorisation:(void(^)(CTAuthorizationStatus status))completionBlock;

/*!
 Fetch reminders and generate reminder file list in local file system.
 @param completionBlock Callback when process is completed. @b countOfReminders NSInteger value represents the total count of reminders. @b lengthOfData reminder file size.
 @param failureBlock Callback when process is failed. @b err NSError contains all the detail message.
 */
+ (void)fetchReminders:(void(^)(NSInteger countOfReminders,float lengthOfData))completionBlock failureBlock:(void(^)(NSError *err))failureBlock;
/*!
 Fetch calendars and generate ics file list in local file system.
 @param completionBlock Callback when process is completed. @b countOfCalendars NSInteger value represents the total count of calendar lists. @b lengthOfData reminder file size.
 @param failureBlock Callback when process is failed. @b err NSError contains all the detail message.
 @param updateBlock Callback to update progress of fetching. @b countOfCalendars Count of calendar already finished fetching.
 */
+ (void)fetchCalendars:(void(^)(NSInteger countOfCalendars,float lengthOfData))completionBlock failureBlock:(void(^)(NSError *err))failureBlock updateBlock:(void(^)(NSInteger countOfCalendars))updateBlock;


@end
