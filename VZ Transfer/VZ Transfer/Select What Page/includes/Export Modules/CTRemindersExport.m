//
//  CTRemindersExport.m
//  contenttransfer
//
//  Created by Guntupalli, Neelima on 8/31/16.
//  Copyright © 2016 Verizon. All rights reserved.
//

#import "CTRemindersExport.h"
#import "CTFileManager.h"
#import "NSDate+CTMVMConvenience.h"
#import "CTColor.h"
#import "CTDataCollectionManager.h"
#import "UIColor+CTColorHelper.h"

@interface CTRemindersExport ()
/*! EKEventStore object use for retrieving the reminder event.*/
@property(nonatomic,strong) EKEventStore *eventStore;

@end

@implementation CTRemindersExport

#pragma mark - Initializer
+ (instancetype)remindersExport {
    
    static CTRemindersExport *reminderExport = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        reminderExport = [[CTRemindersExport alloc] init];
    });
    
    return reminderExport;
}

- (instancetype)init {
    if (self = [super init]) {
        
        self.eventStore = [EKEventStore new];
    }
    return self;
}

#pragma mark - Instance Methods
- (void)fetchReminders:(void(^)(NSInteger countOfReminders,float lengthOfData))completionBlock failureBlock:(void(^)(NSError *err))failureBlock {
    
    __block NSInteger allRemindersCount = 0;
    __block NSInteger reminderListCount = 0;

    
    NSArray *allRemindersLists = [self.eventStore calendarsForEntityType:EKEntityTypeReminder];
    
    NSMutableArray *allRemindersArray = [NSMutableArray new];
    
    __block NSInteger count = [allRemindersLists count];
    reminderListCount = count;
    if (count == 0) {
        completionBlock(0,0);
    }
    [allRemindersLists enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        *stop = [CTDataCollectionManager sharedManager].isRemindersFetchingOperationCancelled;
        
        EKCalendar *eachReminderList = (EKCalendar *)obj;
        
        [self remindersinReminderList:eachReminderList completionBlock:^(NSDictionary *reminderListDict, NSInteger remindersCount) {
            
            count--;
            
            if (remindersCount > 0) {
                [allRemindersArray addObject:reminderListDict];
                allRemindersCount = allRemindersCount + remindersCount;
            }
            //updateBlock (allRemindersCount);
            
            if (count==0) {
                
                NSError *error;
                NSData *remindersData = [NSJSONSerialization dataWithJSONObject:allRemindersArray options:NSJSONWritingPrettyPrinted error:&error];
                if (error) {
                    DebugLog(@"%@",error.description);
                    failureBlock(error);
                }else{
                    if (allRemindersCount == 0) {
                        completionBlock(0, 0);
                    } else {
                        [CTFileManager createDirectory:@"Reminders" withFileName:@"RemindersFile.txt" withContents:remindersData completionBlock:^(NSString *filePath, NSError *error) {
                            if (!error) {
                                completionBlock(allRemindersArray.count, remindersData.length);
                            }
                        }];
                    }
                }
            }
        }];
    }];
}

#pragma mark - Convenient
/*!
 Read the reminder event inside given list and generate the reminder information dictionary for log.
 @param eachReminderList Target reminder list.
 @param block Callback when process is done. reminderListDict is complete dictionary for all the reminder lists; remindersCount is the count of events in current list.
 */
- (void)remindersinReminderList:(EKCalendar*)eachReminderList completionBlock:(void(^)(NSDictionary* reminderListDict , NSInteger remindersCount))block{
    
    
    NSMutableDictionary *eachReminderListDict = [NSMutableDictionary new];
    
    NSPredicate *predicate = [self.eventStore predicateForRemindersInCalendars:@[eachReminderList]];
    
    [self.eventStore fetchRemindersMatchingPredicate:predicate completion:^(NSArray<EKReminder *> * _Nullable reminders) {
        
        NSMutableArray *allReminderEvents = [NSMutableArray new];
        // Date format use for NSDate object
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        
        // Reminder event loop
        for (EKReminder *reminderEvent in reminders) {
            NSMutableDictionary *eventDict = [NSMutableDictionary new];
            
            // For duplicate purpose
            [eventDict setValue:reminderEvent.calendarItemIdentifier forKey:@"REMINDERID"];
            // Title
            if (reminderEvent.title.length > 0 ) {
                [eventDict setValue:reminderEvent.title forKey:@"TITLE"];
            }
            // Note
            if (reminderEvent.notes.length > 0) {
                [eventDict setValue:reminderEvent.notes forKey:@"NOTES"];
            }
            // Priority
            [eventDict setValue:[NSString stringWithFormat:@"%d", (int)reminderEvent.priority] forKey:@"PRIORITY"];
            // Completed
            if (reminderEvent.completed) {
                [eventDict setObject:@"YES" forKey:@"COMPLETED"];
            } else {
                [eventDict setValue:@"NO" forKey:@"COMPLETED"];
            }
            // Due date
            if (reminderEvent.dueDateComponents) {
                NSCalendar *calendar = [NSCalendar currentCalendar];
                NSDate *dueDate = [calendar dateFromComponents:reminderEvent.dueDateComponents];
                NSString *dueDateStr = [dateFormatter stringFromDate:dueDate];
                if (dueDateStr.length > 0) {
                    [eventDict setValue:dueDateStr forKey:@"DUEDATECOMPONENTS"];
                }
            }
            // Alarms
            if ([reminderEvent.alarms count] > 0) {
                
                NSMutableArray *alarmsList = [[NSMutableArray alloc] init];
                
                for (EKAlarm *alarms in reminderEvent.alarms) {
                    
                    NSMutableDictionary *newAlarms = [[NSMutableDictionary alloc] init];
                    if (alarms.relativeOffset) {
                        
                        [newAlarms setValue:[NSString stringWithFormat:@"%f", alarms.relativeOffset] forKey:@"RELATIVEOFFSET"];
                    }
                    if (alarms.absoluteDate) {
                        NSString *absoluteDateStr = [dateFormatter stringFromDate:alarms.absoluteDate];
                        
                        if (absoluteDateStr.length > 0) {
                            [newAlarms setValue:absoluteDateStr forKey:@"ABSOLUTEDATE"];
                        }
                    }
                    
                    [newAlarms setValue:[NSString stringWithFormat:@"%d",(int)alarms.proximity] forKey:@"PROXIMITY"];
                    
                    if (alarms.structuredLocation !=nil) {
                        
                        if (alarms.structuredLocation.title.length > 0) {
                            [newAlarms setValue:alarms.structuredLocation.title forKey:@"ALARMS_LOCATION_TITLE"];
                        }
                        
                        if(alarms.structuredLocation.radius > 0) {
                            [newAlarms setValue:[NSString stringWithFormat:@"%f",alarms.structuredLocation.radius] forKey:@"ALARMS_LOCATION_RADIUS"];
                        }
                        
                        if(alarms.structuredLocation.geoLocation != nil) {
                            
                            NSString *geolocatoonStr = [NSString stringWithFormat:@"%f#%f",alarms.structuredLocation.geoLocation.coordinate.latitude,alarms.structuredLocation.geoLocation.coordinate.longitude];
                            [newAlarms setValue:geolocatoonStr forKey:@"ALARMS_LOCATION"];
                        }
                        [alarmsList addObject:newAlarms];
                    }else {
                        [alarmsList addObject:newAlarms];
                    }
                }
                
               [eventDict setValue:alarmsList forKey:@"ALARMSLIST"];
            }
            // Start date
            if (reminderEvent.startDateComponents != NULL) {
                NSCalendar *calendar = [NSCalendar currentCalendar];
                NSDate *completionDate = [calendar dateFromComponents:reminderEvent.startDateComponents];
                NSString *completionDateStr = [dateFormatter stringFromDate:completionDate];
                if (completionDateStr.length > 0) {
                    [eventDict setValue:completionDateStr forKey:@"STARTDATE"];
                }
            }
            // Completion date
            if (reminderEvent.completionDate != NULL) {
                NSString *completionDateStr = [dateFormatter stringFromDate:reminderEvent.completionDate];
                [eventDict setValue:completionDateStr forKey:@"COMPLETIONDATE"];
            }
            
            // Recurrence rules
            NSString *recurrenceString = [NSString stringWithFormat:@"%@", reminderEvent.recurrenceRules];
            NSArray *partsArray = [recurrenceString componentsSeparatedByString:@"RRULE "];
            
            if ([partsArray count] > 1) {
                NSString *secondHalf = [[[[[partsArray objectAtIndex:1] stringByReplacingOccurrencesOfString:@"\n" withString:@""] stringByReplacingOccurrencesOfString:@")" withString:@""] stringByReplacingOccurrencesOfString:@"\r" withString:@""] stringByReplacingOccurrencesOfString:@"\"" withString:@""];
                [eventDict setValue:secondHalf forKey:@"RRULE"];
            }
            
            // Add reminder in event into event list
            [allReminderEvents addObject:eventDict];
        }
        
        if (reminders.count > 0) { // Only transfer reminder list has events in it(no matter is completed or not).
            [eachReminderListDict setObject:allReminderEvents forKey:@"reminder"];
            [eachReminderListDict setObject:eachReminderList.title forKey:@"reminderName"];
            [eachReminderListDict setObject:[UIColor hexOFColor:eachReminderList.CGColor] forKey:@"REMINDERLISTCOLOR"];

        }
        
        block(eachReminderListDict,[reminders count]);
    }];
}

@end
