//
//  CTRemindersExport.h
//  contenttransfer
//
//  Created by Guntupalli, Neelima on 8/31/16.
//  Copyright © 2016 Verizon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <EventKit/EventKit.h>

/*! Exporter for reminder in content transfer. This object will contains all the fetching reminder logic. This is singleton class.*/
@interface CTRemindersExport : NSObject
#pragma mark - Class methods
/*!
 Singleton initializer for CTReminderExporter. This method will create a EKEventStore object for general use.
 */
+ (instancetype)remindersExport;

#pragma mark - Instance methods
/*!
 Fetch the reminder events from device. This method will create a reminder log file named "RemindersFile.txt" saved in app's document folder.
 @param completionBlock Completion callback when fetching process is done. countOfReminders is the number of reminder list; lengthOfData is the data length.
 @param failureBlock Failure callback when something wrong hanppens, along with error information.
 */
- (void)fetchReminders:(void(^)(NSInteger countOfReminders,float lengthOfData))completionBlock failureBlock:(void(^)(NSError *err))failureBlock;

@end
