//
//  NSDate+CTMVMConvenience.h
//  contenttransfer
//
//  Created by Hadapad, Prakash on 8/31/16.
//  Copyright © 2016 Hadapad, Prakash. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (CTMVMConvenience)
#pragma mark - Class methods
/*!
 Giving the date, calculate the number of dates between that date and today's date.
 @return Integer number represents the day differents.
 */
+ (NSInteger)numberOfDateBeforeToday:(NSDate *)date;
/*!
 Convert a string that represents a date with the representing format string to a NSDate object.
 @param dateString Timestamp string want to convert to NSDate.
 @param formatString Format string for timestamp.
 @return NSData object converted from timestamp string.
 */
+ (NSDate *)dateFromString:(NSString *)dateString usingFormat:(NSString *)formatString;
/*!
 Create timestamp string from NSDate object.
 @param date NSDate object to covert to date string.
 @return NSString represents the date from NSDate object.
 */
+ (NSString *)stringWithDate:(NSDate *)date;
/*!
 Create timestamp string from NSDate object.
  @note This method will use default format: "yyyy-MM-dd HH:mm:ss"
 @param date NSDate object to covert to date string.
 @return NSString represents the date from NSDate object.
 */
+ (NSString *)stringFromDate:(NSDate *)date;
/*!
 Convert a string that represents a date with the representing format string to a NSDate object.
 @note This method will use default format: "yyyy-MM-dd HH:mm:ss"
 @param dateString Timestamp string want to convert to NSDate.
 @return NSData object converted from timestamp string.
 */
+ (NSDate *)dateFromString:(NSString * )dateString;

#pragma mark - Instance methods
/*!
 Calculate days different between self date object and the target date given.
 @param toDateTime NSDate object to calulate with self date.
 @return Integer value represents the number of days difference.
 */
- (NSInteger)daysBetweenDate:(NSDate*)toDateTime;

@end
