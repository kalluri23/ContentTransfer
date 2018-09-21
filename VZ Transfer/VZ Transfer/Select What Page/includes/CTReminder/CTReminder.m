//
//  CTReminder.m
//  test
//
//  Created by Sun, Xin on 12/14/16.
//  Copyright © 2016 Sun, Xin. All rights reserved.
//

#import "CTReminder.h"

@implementation CTReminder

#pragma mark - Initializer
+ (CTReminder *)reminderWithEventStore:(EKEventStore *)eventStore
                           forCalendar:(EKCalendar *)currentCalendar
                                detail:(NSDictionary *)reminderInfo {
    
    CTReminder *ctReminder = [[CTReminder alloc] init];
    ctReminder.reminderItemIdentifier = (NSString *)[reminderInfo valueForKey:@"REMINDERID"];
    
    EKReminder *reminder = [EKReminder reminderWithEventStore:eventStore];
    
    // Tile
    reminder.title = [reminderInfo valueForKey:@"TITLE"];
    
    // Calendars
    reminder.calendar = currentCalendar;
    
    // Priority
    NSString *str = [reminderInfo valueForKey:@"PRIORITY"];
    reminder.priority = [str intValue];
    
    // Notes
    reminder.notes = [reminderInfo valueForKey:@"NOTES"];
    
    // Completion
    if ([[reminderInfo valueForKey:@"COMPLETED"] isEqualToString:@"YES"]) {
        reminder.completed = YES;
    } else {
        reminder.completed = NO;
    }
    
    NSDateFormatter *_dateFormatter = [[NSDateFormatter alloc] init];
    [_dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    // Complete date
    if ([reminderInfo valueForKey:@"COMPLETIONDATE"]) {
        NSDate *alarmDate = [_dateFormatter dateFromString:(NSString *)[reminderInfo valueForKey:@"COMPLETIONDATE"]];
        reminder.completionDate = alarmDate;
    }
    
    // Due date
    if ([reminderInfo valueForKey:@"DUEDATECOMPONENTS"]) {
//        NSLog(@"%@", [reminderInfo valueForKey:@"DUEDATECOMPONENTS"]);
        NSDate *alarmDate = [_dateFormatter dateFromString:(NSString *)[reminderInfo valueForKey:@"DUEDATECOMPONENTS"]];
        
        unsigned unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth |  NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
        
        NSCalendar * cal = [NSCalendar currentCalendar];
        NSDateComponents *dueDateComponents = [cal components:unitFlags fromDate:alarmDate];
        reminder.dueDateComponents = dueDateComponents;
    }
    
    // Alarm list
    if ([reminderInfo valueForKey:@"ALARMSLIST"]) {
        
        NSArray *tempalarmList = [reminderInfo valueForKey:@"ALARMSLIST"];
        if ([tempalarmList count] > 0) {
            for (NSDictionary *tempAlarm in tempalarmList) {
                
                EKAlarm *alarm;
                if([tempAlarm valueForKey:@"ABSOLUTEDATE"]) {
                    NSDate *alarmDate = [_dateFormatter dateFromString:(NSString *)[tempAlarm valueForKey:@"ABSOLUTEDATE"]];
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
    
    // Start date
    if ([reminderInfo valueForKey:@"STARTDATE"]) {
        NSDate *alarmDate = [_dateFormatter dateFromString:(NSString *)[reminderInfo valueForKey:@"STARTDATE"]];
        
        unsigned unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth |  NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
        
        NSCalendar * cal = [NSCalendar currentCalendar];
        NSDateComponents *dueDateComponents = [cal components:unitFlags fromDate:alarmDate];
        reminder.startDateComponents = dueDateComponents;
    }
    
    // RRule
    if ([reminderInfo valueForKey:@"RRULE"]) {
        NSString *repetitionString = (NSString *)[reminderInfo valueForKey:@"RRULE"];
        repetitionString = [[[[repetitionString stringByReplacingOccurrencesOfString:@"RRULE:" withString:@""] stringByReplacingOccurrencesOfString:@"\n" withString:@""] stringByReplacingOccurrencesOfString:@"\r" withString:@""] stringByReplacingOccurrencesOfString:@"\"" withString:@""];
        
        NSLog(@"Reminder rrule: %@", repetitionString);
        // Parse rules
        NSArray *rules = [self parseRule:repetitionString];
        if (rules) {
            NSLog(@"Reminder rrule parsed: %@", rules);
            // Add rules
            reminder.recurrenceRules = rules;
        }
    }
    
    ctReminder.reminderObject = reminder;
    
    return ctReminder;
}

#pragma mark - Convenient
/*!
 Parse the repeat rule for reminder events.
 @param rule NSString value represents the repeat rule read from log file.
 @return NSArray of EKRecurrenceRule object.
 */
+ (NSArray *)parseRule:(NSString *)rule {
    
    if (!rule) {
        return nil;
    }
    
    NSScanner *ruleScanner;
    
    NSArray *rulesArray = [rule componentsSeparatedByString:@";"]; // Split up rules string into array
    
    NSString *repeatRuleFrequency;
    NSString *repeatRuleCount;
    NSString *repeatRuleUntilDate;
    NSString *repeatRuleInterval;
    NSString *repeatRuleWeekStart;
    NSArray  *repeatRuleByDay;
    NSArray  *repeatRuleByMonthDay;
    NSArray  *repeatRuleByYearDay;
    NSArray  *repeatRuleByWeekNo;
    NSArray  *repeatRuleByMonth;
    NSArray  *repeatRuleBySetPos;
    
    NSMutableArray * rules = [[NSMutableArray alloc] init];
    
    // Loop through each rule, should be only one rule for each reminder event.
    for (NSString *rule in rulesArray) {
        ruleScanner = [[NSScanner alloc] initWithString:rule];
        
        // If the rule is for the FREQuency
        if ([rule rangeOfString:@"FREQ"].location != NSNotFound) {
            [ruleScanner scanUpToString:@"=" intoString:nil];
            [ruleScanner scanUpToString:@";" intoString:&repeatRuleFrequency];
            repeatRuleFrequency = [repeatRuleFrequency stringByReplacingOccurrencesOfString:@"=" withString:@""];
        }
        
        // If the rule is for the COUNT
        if ([rule rangeOfString:@"COUNT"].location != NSNotFound) {
            [ruleScanner scanUpToString:@"=" intoString:nil];
            [ruleScanner scanUpToString:@";" intoString:&repeatRuleCount];
            repeatRuleCount = [repeatRuleCount stringByReplacingOccurrencesOfString:@"=" withString:@""];
        }
        
        // If the rule is for the UNTIL date
        if ([rule rangeOfString:@"UNTIL"].location != NSNotFound) {
            [ruleScanner scanUpToString:@"=" intoString:nil];
            [ruleScanner scanUpToString:@";" intoString:&repeatRuleUntilDate];
            repeatRuleUntilDate = [repeatRuleUntilDate stringByReplacingOccurrencesOfString:@"=" withString:@""];
        }
        
        // If the rule is for the INTERVAL
        if ([rule rangeOfString:@"INTERVAL"].location != NSNotFound) {
            [ruleScanner scanUpToString:@"=" intoString:nil];
            [ruleScanner scanUpToString:@";" intoString:&repeatRuleInterval];
            repeatRuleInterval = [repeatRuleInterval stringByReplacingOccurrencesOfString:@"=" withString:@""];
        }
        
        // If the rule is for the BYDAY
        if ([rule rangeOfString:@"BYDAY"].location != NSNotFound) {
            NSString *byDay = nil;
            [ruleScanner scanUpToString:@"=" intoString:nil];
            [ruleScanner scanUpToString:@";" intoString:&byDay];
            byDay = [byDay stringByReplacingOccurrencesOfString:@"=" withString:@""];
            repeatRuleByDay = [byDay componentsSeparatedByString:@","];
        }
        
        // If the rule is for the BYMONTHDAY
        if ([rule rangeOfString:@"BYMONTHDAY"].location != NSNotFound) {
            NSString *byMonthDay = nil;
            [ruleScanner scanUpToString:@"=" intoString:nil];
            [ruleScanner scanUpToString:@";" intoString:&byMonthDay];
            byMonthDay = [byMonthDay stringByReplacingOccurrencesOfString:@"=" withString:@""];
            repeatRuleByMonthDay = [byMonthDay componentsSeparatedByString:@","];
        }
        
        // If the rule is for the BYYEARDAY
        if ([rule rangeOfString:@"BYYEARDAY"].location != NSNotFound) {
            NSString *byYearDay = nil;
            [ruleScanner scanUpToString:@"=" intoString:nil];
            [ruleScanner scanUpToString:@";" intoString:&byYearDay];
            byYearDay = [byYearDay stringByReplacingOccurrencesOfString:@"=" withString:@""];
            repeatRuleByYearDay = [byYearDay componentsSeparatedByString:@","];
        }
        
        // If the rule is for the BYWEEKNO
        if ([rule rangeOfString:@"BYWEEKNO"].location != NSNotFound) {
            NSString *byWeekNo = nil;
            [ruleScanner scanUpToString:@"=" intoString:nil];
            [ruleScanner scanUpToString:@";" intoString:&byWeekNo];
            byWeekNo = [byWeekNo stringByReplacingOccurrencesOfString:@"=" withString:@""];
            repeatRuleByWeekNo = [byWeekNo componentsSeparatedByString:@","];
        }
        
        // If the rule is for the BYMONTH
        if ([rule rangeOfString:@"BYMONTH"].location != NSNotFound) {
            NSString *byMonth = nil;
            [ruleScanner scanUpToString:@"=" intoString:nil];
            [ruleScanner scanUpToString:@";" intoString:&byMonth];
            byMonth = [byMonth stringByReplacingOccurrencesOfString:@"=" withString:@""];
            
            repeatRuleByMonth = [byMonth componentsSeparatedByString:@","];
        }
        
        // If the rule is for the WKST
        if ([rule rangeOfString:@"WKST"].location != NSNotFound) {
            [ruleScanner scanUpToString:@"=" intoString:nil];
            [ruleScanner scanUpToString:@";" intoString:&repeatRuleWeekStart];
            repeatRuleWeekStart = [repeatRuleWeekStart stringByReplacingOccurrencesOfString:@"=" withString:@""];
        }
        
        // If the rule is for the BYSETPOS
        if ([rule rangeOfString:@"BYSETPOS"].location != NSNotFound) {
            NSString *position = nil;
            [ruleScanner scanUpToString:@"=" intoString:nil];
            [ruleScanner scanUpToString:@";" intoString:&position];
            position = [position stringByReplacingOccurrencesOfString:@"=" withString:@""];
            repeatRuleBySetPos = [position componentsSeparatedByString:@","];
        }
    }
    
    // Setup rrule
    if (repeatRuleFrequency) {
        // Frequency
        EKRecurrenceFrequency frequency = [self getFrequency:repeatRuleFrequency];
        // Interval
        NSInteger interval = repeatRuleInterval ? [repeatRuleInterval integerValue] : 1;
        // Recurrence end
        EKRecurrenceEnd *endDate = repeatRuleUntilDate ? [EKRecurrenceEnd recurrenceEndWithEndDate:[self dateFromString:repeatRuleUntilDate]] : nil;
        
        EKRecurrenceRule *currentRule = [[EKRecurrenceRule alloc] initRecurrenceWithFrequency:frequency
                                                                                     interval:interval
                                                                                daysOfTheWeek:repeatRuleByDay ? [self getDaysOfWeek:repeatRuleByDay andPosition:repeatRuleBySetPos frequency:repeatRuleFrequency] : nil
                                                                               daysOfTheMonth:repeatRuleByMonthDay ? repeatRuleByMonthDay : nil
                                                                              monthsOfTheYear:repeatRuleByMonth ? repeatRuleByMonth : nil
                                                                               weeksOfTheYear:repeatRuleByWeekNo ? repeatRuleByWeekNo : nil
                                                                                daysOfTheYear:repeatRuleByYearDay ? repeatRuleByYearDay : nil
                                                                                 setPositions:repeatRuleBySetPos ? repeatRuleBySetPos : nil
                                                                                          end:endDate];
        // Add rule
        [rules addObject:currentRule];
    }
    
    return rules;
}
/*!
 Translate the frequency from string value into API readable format.
 @param frequencyString Frequency value in string format.
 @return EKRecurrenceFrequency object represents the same frequency value.
 */
+ (EKRecurrenceFrequency)getFrequency:(NSString *)frequencyString {
    if ([frequencyString isEqualToString:@"DAILY"]) {
        return EKRecurrenceFrequencyDaily;
    } else if ([frequencyString isEqualToString:@"WEEKLY"]) {
        return EKRecurrenceFrequencyWeekly;
    } else if ([frequencyString isEqualToString:@"MONTHLY"]) {
        return EKRecurrenceFrequencyMonthly;
    } else {
        return EKRecurrenceFrequencyYearly;
    }
}
/*!
 Translate the date from string value into API readable format.
 @param dateString Date value in string format.
 @return NSDate object represents the same date value.
 */
+ (NSDate *)dateFromString:(NSString *)dateString {
    // Set up the shared NSDateFormatter instance to convert the strings to NSDate objects
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyMMdd HHmmss"];
    NSDate *date = nil;
    
    dateString = [dateString stringByReplacingOccurrencesOfString:@"T" withString:@" "];
    
    BOOL containsZone = [dateString rangeOfString:@"z" options:NSCaseInsensitiveSearch].location != NSNotFound;
    
    if (containsZone) {
        dateFormatter.dateFormat = @"yyyyMMdd HHmmssz";
    }
    
    [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
    
    date = [dateFormatter dateFromString:dateString];
    
    
    
    if (!date) {
        if (containsZone) {
            dateFormatter.dateFormat = @"yyyyMMddz";
        }
        else {
            dateFormatter.dateFormat = @"yyyyMMdd";
        }
        
        date = [dateFormatter dateFromString:dateString];
    }
    
    dateFormatter.dateFormat = @"yyyyMMdd HHmmss";
    
    return date;
}
/*!
 Translate the repeat values from string value into API readable format.
 @param daysArray Days array value in string format.
 @param position Position array value. Position means when user select which week/day/month of the month/year. Sample: 2nd Monday of the month, position will be 2.
 @param repeatRuleFrequency frenquncy value in string format.
 @return Array of EKRecurrenceDayOfWeek object represents the detail of repeat information.
 */
+ (NSArray <EKRecurrenceDayOfWeek *> *)getDaysOfWeek:(NSArray<NSString *> *)daysArray andPosition:(NSArray *)position frequency:(NSString *)repeatRuleFrequency {
    NSMutableArray <EKRecurrenceDayOfWeek *> *newDaysArray = [[NSMutableArray alloc] init];
    
    if (daysArray.count == 0) {
        return nil;
    }
    
    if ([repeatRuleFrequency isEqualToString:@"YEARLY"]) {
        NSString *day = [daysArray firstObject]; // only one
        NSArray *component = nil;
        
        EKRecurrenceDayOfWeek *dayOfWeek = nil;
        if ([day rangeOfString:@"SU"].location != NSNotFound) {
            component = [day componentsSeparatedByString:@"SU"];
            NSInteger weekNumber = [[component firstObject] integerValue];
            dayOfWeek = [[EKRecurrenceDayOfWeek alloc] initWithDayOfTheWeek:1 weekNumber:weekNumber];
        } else if ([day rangeOfString:@"MO"].location != NSNotFound) {
            component = [day componentsSeparatedByString:@"MO"];
            NSInteger weekNumber = [[component firstObject] integerValue];
            dayOfWeek = [[EKRecurrenceDayOfWeek alloc] initWithDayOfTheWeek:2 weekNumber:weekNumber];
        } else if ([day rangeOfString:@"TU"].location != NSNotFound) {
            component = [day componentsSeparatedByString:@"TU"];
            NSInteger weekNumber = [[component firstObject] integerValue];
            dayOfWeek = [[EKRecurrenceDayOfWeek alloc] initWithDayOfTheWeek:3 weekNumber:weekNumber];
        } else if ([day rangeOfString:@"WE"].location != NSNotFound) {
            component = [day componentsSeparatedByString:@"WE"];
            NSInteger weekNumber = [[component firstObject] integerValue];
            dayOfWeek = [[EKRecurrenceDayOfWeek alloc] initWithDayOfTheWeek:4 weekNumber:weekNumber];
        } else if ([day rangeOfString:@"TH"].location != NSNotFound) {
            component = [day componentsSeparatedByString:@"TH"];
            NSInteger weekNumber = [[component firstObject] integerValue];
            dayOfWeek = [[EKRecurrenceDayOfWeek alloc] initWithDayOfTheWeek:5 weekNumber:weekNumber];
        } else if ([day rangeOfString:@"FR"].location != NSNotFound) {
            component = [day componentsSeparatedByString:@"FR"];
            NSInteger weekNumber = [[component firstObject] integerValue];
            dayOfWeek = [[EKRecurrenceDayOfWeek alloc] initWithDayOfTheWeek:6 weekNumber:weekNumber];
        } else { // Sat
            component = [day componentsSeparatedByString:@"SA"];
            NSInteger weekNumber = [[component firstObject] integerValue];
            dayOfWeek = [[EKRecurrenceDayOfWeek alloc] initWithDayOfTheWeek:7 weekNumber:weekNumber];
        }
        
        [newDaysArray addObject:dayOfWeek];
        
        return newDaysArray;
    }
    
    NSInteger pos = 0;
    if (position.count > 0) {
        pos =[[position firstObject] integerValue];
    }
    for (NSString *day in daysArray) {
        EKRecurrenceDayOfWeek *dayOfWeek = nil;
        if ([day isEqualToString:@"SU"]) {
            dayOfWeek = [[EKRecurrenceDayOfWeek alloc] initWithDayOfTheWeek:1 weekNumber:pos];
        } else if ([day isEqualToString:@"MO"]) {
            dayOfWeek = [[EKRecurrenceDayOfWeek alloc] initWithDayOfTheWeek:2 weekNumber:pos];
        } else if ([day isEqualToString:@"TU"]) {
            dayOfWeek = [[EKRecurrenceDayOfWeek alloc] initWithDayOfTheWeek:3 weekNumber:pos];
        } else if ([day isEqualToString:@"WE"]) {
            dayOfWeek = [[EKRecurrenceDayOfWeek alloc] initWithDayOfTheWeek:4 weekNumber:pos];
        } else if ([day isEqualToString:@"TH"]) {
            dayOfWeek = [[EKRecurrenceDayOfWeek alloc] initWithDayOfTheWeek:5 weekNumber:pos];
        } else if ([day isEqualToString:@"FR"]) {
            dayOfWeek = [[EKRecurrenceDayOfWeek alloc] initWithDayOfTheWeek:6 weekNumber:pos];
        } else {
            dayOfWeek = [[EKRecurrenceDayOfWeek alloc] initWithDayOfTheWeek:7 weekNumber:pos];
        }
        
        [newDaysArray addObject:dayOfWeek];
    }
    
    return newDaysArray;
}

@end
