//
//  VZRemindersExport.m
//  myverizon
//
//  Created by Tourani, Sanjay on 4/5/16.
//  Copyright © 2016 Verizon Wireless. All rights reserved.
//
#import "VZRemindersImoprt.h"
#import "NSString+CTContentTransferRootDocuments.h"
#import <MapKit/MapKit.h>

@interface VZRemindersImoprt()
@property (assign, nonatomic) NSInteger reminderSavedCount;
@end

@implementation VZRemindersImoprt


@synthesize eventManager;
@synthesize completionHandler;
@synthesize totalnumberOfReminder;


- (id)init {
    if (self = [super init]) {
        eventManager = [VZEventManager sharedEvent];
    }
    
    return self;
}

+ (NSInteger)getTotalReminderCountForSpecificFile:(NSString *)reminderURL {
    return [VZRemindersImoprt _getReminderCountInFile:reminderURL];
}

- (NSInteger)getTotalReminderCount {
    NSString *fileName = [[NSString appRootDocumentDirectory] stringByAppendingPathComponent:@"reminderLogFile.txt"];
    return [VZRemindersImoprt _getReminderCountInFile:fileName];;
}

+ (NSInteger)_getReminderCountInFile:(NSString *)fileName {
    
    if (fileName.length == 0) {
        return 0;
    }
    
    NSData *reminderdata = [[NSFileManager defaultManager] contentsAtPath:fileName];
    NSError* error = nil;
    
    if (reminderdata.length > 0) {
        NSArray *reminderList = (NSArray *)[NSJSONSerialization JSONObjectWithData:reminderdata
                                                                           options:kNilOptions
                                                                             error:&error];
        return reminderList.count;
    }
    
    return  0;
}

- (void)importAllReminder {
    
//    NSString *documentsDirectory1 = [[NSString appRootDocumentDirectory] stringByAppendingPathComponent:@"Documents"];
    NSString *fileName = [[NSString appRootDocumentDirectory] stringByAppendingPathComponent:@"reminderLogFile.txt"];

    NSData *reminderdata = [[NSFileManager defaultManager] contentsAtPath:fileName];
    
    NSError* error = nil;
    if (reminderdata.length > 0) {
        
        NSArray *reminderList = (NSArray *)[NSJSONSerialization JSONObjectWithData:reminderdata
                                                                           options:kNilOptions
                                                                             error:&error];
        
        EKEventStore *store = [[EKEventStore alloc] init];
        EKSource *localSource = nil;
        for (EKSource *source in store.sources)
            if (source.sourceType == EKSourceTypeLocal){
                localSource = source;
                break;
            }
        
        for (NSDictionary *tempdict in reminderList) {
            
            if (tempdict.count == 0) {
                // empty reminder dic in the list
                continue;
            }
            
            EKCalendar *calendar = [EKCalendar calendarForEntityType:EKEntityTypeReminder eventStore:self.eventManager.eventStore];
            //give string the ics filename
            calendar.title = [tempdict valueForKey:@"reminderName"];
            calendar.source = localSource;
            
            UIColor *tempcolor = [self colorFromHexString:[tempdict valueForKey:@"REMINDERLISTCOLOR"]];
            
            calendar.CGColor = tempcolor.CGColor;
            
            NSArray *allCalendars = [self.eventManager.eventStore calendarsForEntityType:EKEntityTypeReminder];
            
            EKCalendar *currentCalendar;
            
            BOOL flag = true;
            
            for (int i=0; i<allCalendars.count; i++) {
                currentCalendar = [allCalendars objectAtIndex:i];
                if (currentCalendar.type == EKCalendarTypeLocal) {
                    
//                    DebugLog(@"CurrentCalender : %@ and %@",currentCalendar.title,[tempdict valueForKey:@"reminderName"]);
                    
                    if ([currentCalendar.title isEqualToString:[tempdict valueForKey:@"reminderName"]]) {
                        flag = false;
                        break;
                    }
                }
            }
            
            if (flag) {
                NSError *error;
                [self.eventManager.eventStore saveCalendar:calendar commit:YES error:&error];
            }
            
        }
        
        
        totalnumberOfReminder = (int)[reminderList count];
        
        for (NSDictionary *dict  in reminderList) {
            
            NSArray *list = [dict valueForKey:@"reminder"];
            
            [self addReminders:list ToList:[dict valueForKey:@"reminderName"]];
        }
        self.completionHandler(totalnumberOfReminder);

    }
}


- (UIColor *)colorFromHexString:(NSString *)hexString {
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:0];
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

+ (void)updateAuthorizationStatusToAccessEventStoreSuccess:(successHandler)success failed:(failureHandler)failure
{
    // 2
    EKAuthorizationStatus authorizationStatus = [EKEventStore authorizationStatusForEntityType:EKEntityTypeReminder];
    
    switch (authorizationStatus) {
            
        case EKAuthorizationStatusDenied:
            failure(EKAuthorizationStatusDenied);
            break;
            
        case EKAuthorizationStatusRestricted:
            failure(EKAuthorizationStatusRestricted);
            break;
            
        case EKAuthorizationStatusAuthorized:
            DebugLog(@"Authorized");
            success();
            
            break;
            
        case EKAuthorizationStatusNotDetermined: {
            [[VZEventManager sharedEvent].eventStore requestAccessToEntityType:EKEntityTypeReminder
                                                                    completion:^(BOOL granted, NSError *error) {
                                                                        dispatch_async(dispatch_get_main_queue(), ^{
                                                                            
                                                                            if(!granted) {
                                                                                failure(EKAuthorizationStatusDenied);
                                                                            } else {
                                                                                success();
                                                                            }
                                                                        });
                                                                    }];
            break;
        }
    }
}

-(void)addReminders:(NSArray *) reminders ToList:(NSString *) remindersListName {
 
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    for (NSDictionary *reminder1 in reminders) {
        
        //            DebugLog(@"Recevied Reminder  %@", reminder1);
        
        NSArray *allCalendars = [self.eventManager.eventStore calendarsForEntityType:EKEntityTypeReminder];
        
        EKCalendar *currentCalendar;
        
        for (int i=0; i<allCalendars.count; i++) {
            currentCalendar = [allCalendars objectAtIndex:i];
            if (currentCalendar.type == EKCalendarTypeLocal) {
                
                if ([currentCalendar.title isEqualToString:remindersListName]) {
                    
                    break;
                }
            }
        }
        
        
        EKReminder *reminder = [EKReminder reminderWithEventStore:self.eventManager.eventStore];
        reminder.title = [reminder1 valueForKey:@"TITLE"];
        reminder.calendar = currentCalendar;
        //             NSDate *date = [NSDate date];
        //             EKAlarm *alarm = [EKAlarm alarmWithAbsoluteDate:date];
        //             [reminder addAlarm:alarm];
        
        NSString *str = [reminder1 valueForKey:@"PRIORITY"];
        reminder.priority = [str intValue];
        reminder.notes = [reminder1 valueForKey:@"NOTES"];
        
        if ([[reminder1 valueForKey:@"COMPLETED"] isEqualToString:@"YES"]) {
            reminder.completed = true;
        } else {
            reminder.completed = false;
        }
        
        if ([reminder1 valueForKey:@"COMPLETIONDATE"]) {
            NSDate *alarmDate = [dateFormatter dateFromString:(NSString *)[reminder1 valueForKey:@"COMPLETIONDATE"]];
            reminder.completionDate = alarmDate;
        }
        
        if ([reminder1 valueForKey:@"DUEDATECOMPONENTS"]) {
            NSLog(@"%@", [reminder1 valueForKey:@"DUEDATECOMPONENTS"]);
            NSDate *alarmDate = [dateFormatter dateFromString:(NSString *)[reminder1 valueForKey:@"DUEDATECOMPONENTS"]];
            
            unsigned unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth |  NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
            
            NSCalendar * cal = [NSCalendar currentCalendar];
            NSDateComponents *dueDateComponents = [cal components:unitFlags fromDate:alarmDate];
            reminder.dueDateComponents = dueDateComponents;
        }
        
        if ([reminder1 valueForKey:@"ALARMSLIST"]) {
            
            NSArray *tempalarmList = [reminder1 valueForKey:@"ALARMSLIST"];
            
            if ([tempalarmList count] >0) {
                
                for (NSDictionary *tempAlarm in tempalarmList) {
                    
                    EKAlarm *alarm;
                    if([tempAlarm valueForKey:@"ABSOLUTEDATE"]) {
                        NSDate *alarmDate = [dateFormatter dateFromString:(NSString *)[tempAlarm valueForKey:@"ABSOLUTEDATE"]];
                        alarm = [EKAlarm alarmWithAbsoluteDate:alarmDate];
                    }else {
                        alarm = [[EKAlarm alloc] init];
                    }
                    
                    if ([tempAlarm valueForKey:@"RELATIVEOFFSET"]) {
                        alarm.relativeOffset = [[tempAlarm valueForKey:@"RELATIVEOFFSET"] doubleValue];
                    }
                    
                    if ([tempAlarm valueForKey:@"PROXIMITY"]) {
                        alarm.proximity = [[tempAlarm valueForKey:@"PROXIMITY"] integerValue];
                    }
                    if ([tempAlarm valueForKey:@"ALARMS_LOCATION_TITLE"]) {
                        EKStructuredLocation *structuredLocation = [[EKStructuredLocation alloc] init];
                        structuredLocation.title = [tempAlarm valueForKey:@"ALARMS_LOCATION_TITLE"];
                        
                        if ([tempAlarm valueForKey:@"ALARMS_LOCATION_RADIUS"]) {
                            structuredLocation.radius = [[tempAlarm valueForKey:@"ALARMS_LOCATION_RADIUS"] floatValue];
                        }
                        
                        if([tempAlarm valueForKey:@"ALARMS_LOCATION"]) {
                            
                            NSArray *receviedData = [[tempAlarm valueForKey:@"ALARMS_LOCATION"] componentsSeparatedByString:@"#"];
                            CLLocation *location = [[CLLocation alloc] initWithLatitude:[[receviedData objectAtIndex:0] doubleValue] longitude:[[receviedData objectAtIndex:1] doubleValue]];
                            structuredLocation.geoLocation = location;
                            
                        }
                        
                        alarm.structuredLocation = structuredLocation;
                    }
                    
                    [reminder addAlarm:alarm];
                }
                
            }
            
        }
        
        if ([reminder1 valueForKey:@"STARTDATE"]) {
            NSDate *alarmDate = [dateFormatter dateFromString:(NSString *)[reminder1 valueForKey:@"STARTDATE"]];
            
            unsigned unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth |  NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
            
            NSCalendar * cal = [NSCalendar currentCalendar];
            NSDateComponents *dueDateComponents = [cal components:unitFlags fromDate:alarmDate];
            reminder.startDateComponents = dueDateComponents;
        }
        
        
        NSError *error = nil;
        [self.eventManager.eventStore saveReminder:reminder commit:YES error:&error];
        self.updateHandler(++self.reminderSavedCount);
        
        DebugLog(@"Error is After %@",error);
        
        if(error) {
            DebugLog(@"unable to Reminder!: Error= %@", error);
        } else {
            DebugLog(@"Reminder Added successfully");
        }
    }
}


- (NSDate *) datefromString:(NSString*)str {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateStyle = NSDateFormatterFullStyle;
    dateFormatter.timeStyle = NSDateFormatterFullStyle;
    NSDate *date = [dateFormatter dateFromString:str];

    return date;
}

-(void)createListFrom:(NSArray *)reminderLists {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{

    
        
        
    for (EKCalendar *myCal in reminderLists) {
        
        EKCalendar *calendar = [EKCalendar calendarForEntityType:EKEntityTypeReminder eventStore:self.eventManager.eventStore];
        
        calendar.title = myCal.title;
        calendar.CGColor = myCal.CGColor;
        calendar.source = myCal.source;
        
        NSError *error;
        
        [self.eventManager.eventStore saveCalendar:calendar commit:YES error:&error];
        
        
        if (error == nil)
        
        {
            DebugLog(@"List created successfully");
        }
        
        else DebugLog(@"List not created. Error: %@",error);

      }
    });

}
    
    


    
    
    
    
    
    
    







@end
