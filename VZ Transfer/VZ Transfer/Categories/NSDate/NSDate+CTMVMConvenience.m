//
//  NSDate+CTMVMConvenience.m
//  contenttransfer
//
//  Created by Hadapad, Prakash on 8/31/16.
//  Copyright © 2016 Hadapad, Prakash. All rights reserved.
//

#import "NSDate+CTMVMConvenience.h"

@implementation NSDate (CTMVMConvenience)

#define SECOND_TO_DAY 86400

+ (NSInteger)numberOfDateBeforeToday:(NSDate *)date {
    NSTimeInterval secondsBetween = [[self date] timeIntervalSinceDate:date];
    NSInteger numberOfDays = secondsBetween / SECOND_TO_DAY;
    return numberOfDays;
}

+ (NSDate *)dateFromString:(NSString * )dateString usingFormat:(NSString *)formatString {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:formatString];
    NSDate *date = [formatter dateFromString:dateString];
    return date;
}

- (NSInteger)daysBetweenDate:(NSDate*)toDateTime {
    NSDate *fromDate;
    NSDate *toDate;
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    [calendar rangeOfUnit:NSCalendarUnitDay startDate:&fromDate
                 interval:NULL forDate:self];
    [calendar rangeOfUnit:NSCalendarUnitDay startDate:&toDate
                 interval:NULL forDate:toDateTime];
    
    NSDateComponents *difference = [calendar components:NSCalendarUnitDay
                                               fromDate:fromDate toDate:toDate options:0];
    
    return [difference day];
}

+ (NSString *)stringWithDate:(NSDate *)date{
    
    return [NSDateFormatter localizedStringFromDate:date
                                          dateStyle:NSDateFormatterFullStyle
                                          timeStyle:NSDateFormatterFullStyle];
}

+ (NSString *)stringFromDate:(NSDate *)date {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSTimeZone *utc = [NSTimeZone timeZoneWithName:@"UTC"];
    [dateFormatter setTimeZone:utc];
    return [dateFormatter stringFromDate:date];
}

+ (NSDate *)dateFromString:(NSString * )dateString {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSTimeZone *utc = [NSTimeZone timeZoneWithName:@"UTC"];
    [dateFormatter setTimeZone:utc];
    return [dateFormatter dateFromString:dateString];
}
@end
