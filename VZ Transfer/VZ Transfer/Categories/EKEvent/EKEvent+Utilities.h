//
//  Category.h
//  EKEventToiCal
//
//  Created by Dan Willoughby on 6/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <EventKit/EventKit.h>

@interface EKEvent (Utilities)
/*!
 Generate 36 characters long string with random character in set.
 
 Availble will be A-Z and 0-9, generated result will be used in creating calendar event key.
 @note Key string generated will be under format: "(8 chracters)-(8 chracters)-(8 chracters)-(8 chracters)-(8 chracters)@verizonwireless.com"
 @return NSString value represents the random key for event.
 */
- (NSString *)genRandStringLength;
/*!
 Generate calendar ics string for EKEvent object. @b ics @b version: @b 2.0
 @return String value represent the calendar string. It can be write into text file and name that file with ics extension to create working ics file. String is mutable, can be edited.
 */
- (NSMutableString*)iCalString;


@end
