//
//  CTReminder.h
//  test
//
//  Created by Sun, Xin on 12/14/16.
//  Copyright © 2016 Sun, Xin. All rights reserved.
//

#import <EventKit/EventKit.h>

/*!
 Reminder object for content transfer. Contains EKReminder object for saving and a identifier string value use for duplicate logic.
 
 Use this object when saving the reminder.
 */
@interface CTReminder : NSObject
#pragma mark - Properties
/*! Reminder event ID used in old device. This will be used for identify the duplicate records.*/
@property (nonatomic, strong) NSString *reminderItemIdentifier;
/*! Reminder object use for save in storage.*/
@property (nonatomic, strong) EKReminder *reminderObject;

#pragma mark - Class methods
/*!
 Create CTReminder object for given reminder list using given event store. This is a class method.
 
 This method will create a EKReminder object saved in reminderObject.
 @param eventStore EKEventStore to save the reminder.
 @param EKCalendar Reminder list to contain the reminder event.
 @param reminderInfo Dictionary contains all the information use to create reminder event.
 */
+ (CTReminder *)reminderWithEventStore:(EKEventStore *)eventStore
                           forCalendar:(EKCalendar *)currentCalendar
                                detail:(NSDictionary *)reminderInfo;

@end
