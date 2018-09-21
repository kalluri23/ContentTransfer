//
//  MXLCalendarManager.m
//  Part of MXLCalendarManager framework
//
//  Created by Kiran Panesar on 09/04/2013.
//  Copyright (c) 2013 MobileX Labs. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

#import "MXLCalendarManager.h"
#import "CTDuplicateLists.h"
#import "CTUserDevice.h"

#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#endif

@interface MXLCalendarManager ()

@property (nonatomic, strong) AppDelegate *appDelegate;

-(void)parseICSString:(NSString *)icsString intoCalendar:(EKCalendar *)cal withCompletionHandler:(void (^)(MXLCalendar *, NSError *))callback update:(void(^)(NSInteger count))updateCallback;

@end

@implementation MXLCalendarManager

@synthesize eventManager;

- (id) init {
    if (self = [super init]) {
        eventManager = [VZEventManager sharedEvent];
    }
    
    return self;
}

-(void)scanICSFileAtRemoteURL:(NSURL *)fileURL intoCalendar:(EKCalendar *)calendar withCompletionHandler:(void (^)(MXLCalendar *, NSError *))callback update:(void(^)(NSInteger count))updateCallback {
#if TARGET_OS_IPHONE
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
#endif
    
    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSError *downloadError;
        NSData *fileData = [[NSData alloc] initWithContentsOfURL:fileURL options:0 error:&downloadError];
        
        if (downloadError) {
#if TARGET_OS_IPHONE
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
#endif
            callback(nil, downloadError);
            return;
        }
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
#if TARGET_OS_IPHONE
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
#endif
            NSString *fileString = [[NSString alloc] initWithData:fileData encoding:NSUTF8StringEncoding];
            [self parseICSString:fileString intoCalendar:calendar withCompletionHandler:callback update:updateCallback];
        });
    });
}

-(void)scanICSFileForCountAtRemoteURL:(NSURL *)fileURL withCompletionHandler:(void (^)(NSInteger calendarCount))callback {
#if TARGET_OS_IPHONE
    dispatch_async(dispatch_get_main_queue(), ^{
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    });
#endif
    
    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSError *downloadError;
        NSData *fileData = [[NSData alloc] initWithContentsOfURL:fileURL options:0 error:&downloadError];
        
        if (downloadError) {
#if TARGET_OS_IPHONE
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
#endif
            callback(0);
            return;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
#if TARGET_OS_IPHONE
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
#endif
            NSString *fileString = [[NSString alloc] initWithData:fileData encoding:NSUTF8StringEncoding];
            [self parseICSStringForCount:fileString withCompletionHandler:callback];
        });
    });
}

- (void)parseICSStringForCount:(NSString *)icsString withCompletionHandler:(void (^)(NSInteger calendarCount))callback {
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\n +" options:NSRegularExpressionCaseInsensitive error:&error];
    NSString *icsStringWithoutNewlines = [regex stringByReplacingMatchesInString:icsString options:0 range:NSMakeRange(0, [icsString length]) withTemplate:@""];
    
    // Pull out each line from the calendar file
    NSMutableArray *eventsArray = [NSMutableArray arrayWithArray:[icsStringWithoutNewlines componentsSeparatedByString:@"BEGIN:VEVENT"]];
    
    //    MXLCalendar *calendar = [[MXLCalendar alloc] init];
    
    NSString *calendarString;
    
    // Remove the first item (that's just all the stuff before the first VEVENT)
    if ([eventsArray count] > 0) {
        NSScanner *scanner = [NSScanner scannerWithString:[eventsArray objectAtIndex:0]];
        [scanner scanUpToString:@"TZID:" intoString:nil];
        
        [scanner scanUpToString:@"\n" intoString:&calendarString];
        
        calendarString = [[[calendarString stringByReplacingOccurrencesOfString:@"\n" withString:@""] stringByReplacingOccurrencesOfString:@"\r" withString:@""] stringByReplacingOccurrencesOfString:@"TZID:" withString:@""];
        
        [eventsArray removeObjectAtIndex:0];
    }
    
    callback(eventsArray.count);
}

-(void)scanICSFileAtLocalPath:(NSString *)filePath intoCalendar:(EKCalendar *)calendar withCompletionHandler:(void (^)(MXLCalendar *, NSError *))callback update:(void(^)(NSInteger count))updateCallback {
    self.appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSError *fileError;
    NSString *calendarFile = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:&fileError];
    
    if (fileError) {
        callback(nil, fileError);
        return;
    }
    
    [self parseICSString:calendarFile intoCalendar:calendar withCompletionHandler:callback update:updateCallback];
    
}

-(MXLCalendarAttendee *)createAttendee:(NSString *) string {
    if (string) {
        
        
        MXLCalendarAttendee *attendee = MXLCalendarAttendee.alloc.init;
        NSString *holder;
        NSScanner *eventScanner;
        eventScanner = [NSScanner scannerWithString:string];
        
        NSString *uri, *attributes;
        [eventScanner scanUpToString:@":" intoString:&attributes];
        [eventScanner scanUpToString:@"\n" intoString:&uri];
        attendee.uri = [uri substringFromIndex:1];
        
        eventScanner = [NSScanner scannerWithString:attributes];
        [eventScanner scanUpToString:@"ROLE=" intoString:nil];
        [eventScanner scanUpToString:@";" intoString:&holder];
        NSString *role = [holder stringByReplacingOccurrencesOfString:@"ROLE=" withString:@""];
        attendee.role = (Role) [NSValue value:&role withObjCType:@encode(Role)];
        
        eventScanner = [NSScanner scannerWithString:attributes];
        [eventScanner scanUpToString:@"CN=" intoString:nil];
        [eventScanner scanUpToString:@";" intoString:&holder];
        NSString *cn = [holder stringByReplacingOccurrencesOfString:@"CN=" withString:@""];
        attendee.commonName = cn;
        
        return attendee;
    } else {
        return nil;
    }
}

-(void)parseICSString:(NSString *)icsString intoCalendar:(EKCalendar *)cal withCompletionHandler:(void (^)(MXLCalendar *, NSError *))callback update:(void(^)(NSInteger count))updateCallback {
    
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\n +" options:NSRegularExpressionCaseInsensitive error:&error];
    NSString *icsStringWithoutNewlines = [regex stringByReplacingMatchesInString:icsString options:0 range:NSMakeRange(0, [icsString length]) withTemplate:@""];
    
    // Pull out each line from the calendar file
    NSMutableArray *eventsArray = [NSMutableArray arrayWithArray:[icsStringWithoutNewlines componentsSeparatedByString:@"BEGIN:VEVENT"]];
    
//    MXLCalendar *calendar = [[MXLCalendar alloc] init];
    
    NSString *calendarString;
    
    // Remove the first item (that's just all the stuff before the first VEVENT)
    if ([eventsArray count] > 0) {
        NSScanner *scanner = [NSScanner scannerWithString:[eventsArray objectAtIndex:0]];
        [scanner scanUpToString:@"TZID:" intoString:nil];
        
        [scanner scanUpToString:@"\n" intoString:&calendarString];
        
        calendarString = [[[calendarString stringByReplacingOccurrencesOfString:@"\n" withString:@""] stringByReplacingOccurrencesOfString:@"\r" withString:@""] stringByReplacingOccurrencesOfString:@"TZID:" withString:@""];
        
        [eventsArray removeObjectAtIndex:0];
    }
    
    NSScanner *eventScanner;
    
    // For each event, extract the data
    NSInteger saveCount = 0;
    
    // Calendar duplicate logic only work for iOS to iOS
    NSMutableDictionary *tempEventArray = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *localEventDuplicateList = [[[CTDuplicateLists uniqueList] calendarList] mutableCopy];
    if (!localEventDuplicateList) { // NOTE: X-platform will be nil also
        localEventDuplicateList = [[NSMutableDictionary alloc] init];
    }
    
    BOOL hasNewEventUpdated = NO; // flag, checking if new event need to commit, default value is NO, change to YES when pass the event hash check. Never change back to NO;
    
    for (NSString *event in eventsArray) {
        
        NSString *eventIdentifier = nil;
        // Extract the event identifier
        eventScanner = [NSScanner scannerWithString:event];
        [eventScanner scanUpToString:@"X-VERZIONWIRELESS-EVENT-IDENTIFIER;" intoString:nil];
        [eventScanner scanUpToString:@"\n" intoString:&eventIdentifier];
        eventIdentifier = [[[[[eventIdentifier stringByReplacingOccurrencesOfString:@"X-VERZIONWIRELESS-EVENT-IDENTIFIER;" withString:@""] stringByReplacingOccurrencesOfString:@"\n" withString:@""] stringByReplacingOccurrencesOfString:@"\r" withString:@""] stringByReplacingOccurrencesOfString:@"\"" withString:@""] stringByReplacingOccurrencesOfString:@"VALUE=EVENTID:" withString:@""];
        
        if (eventIdentifier) {
            NSString *fetchIdentifier = [localEventDuplicateList objectForKey:eventIdentifier];
            if (fetchIdentifier) {
                // Check the event deleted by user or not.
                if (![self.eventManager.eventStore eventWithIdentifier:fetchIdentifier]) { // removed
                    [localEventDuplicateList removeObjectForKey:eventIdentifier];
                } else { // Duplicate, update necessary count information
                    if (++saveCount == 50) {
                        updateCallback(saveCount);
                        saveCount = 0;
                    }
                    continue;
                }
            }
        }
        
        hasNewEventUpdated = YES;
        
        NSString *timezoneIDString;
        NSString *startDateTimeString;
        NSString *endDateTimeString;
        NSString *eventUniqueIDString;
        NSString *recurrenceIDString;
        NSString *createdDateTimeString;
        NSString *descriptionString;
        NSString *lastModifiedDateTimeString;
        NSString *locationString;
        NSString *sequenceString;
        NSString *statusString;
        NSString *summaryString;
        NSString *transString;
        NSString *timeStampString;
        NSString *repetitionString;
        NSString *exceptionRuleString;
        NSString *travelTimeString;
        NSString *urlString;
        NSMutableArray *exceptionDates = [[NSMutableArray alloc] init];
        NSMutableArray<MXLCalendarAttendee> *attendees = (NSMutableArray<MXLCalendarAttendee> *)[[NSMutableArray alloc] init];
        
        // Extract event time zone ID
        eventScanner = [NSScanner scannerWithString:event];
        [eventScanner scanUpToString:@"DTSTART;TZID=" intoString:nil];
        [eventScanner scanUpToString:@":" intoString:&timezoneIDString];
        timezoneIDString = [[timezoneIDString stringByReplacingOccurrencesOfString:@"DTSTART;TZID=" withString:@""] stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        
        if (!timezoneIDString) {
            // Extract event time zone ID
            eventScanner = [NSScanner scannerWithString:event];
            [eventScanner scanUpToString:@"TZID:" intoString:nil];
            [eventScanner scanUpToString:@"\n" intoString:&timezoneIDString];
            timezoneIDString = [[timezoneIDString stringByReplacingOccurrencesOfString:@"TZID:" withString:@""] stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        }
        
        // Extract start time
        eventScanner = [NSScanner scannerWithString:event];
        [eventScanner scanUpToString:[NSString stringWithFormat:@"DTSTART;TZID=%@:", timezoneIDString] intoString:nil];
        [eventScanner scanUpToString:@"\n" intoString:&startDateTimeString];
        startDateTimeString = [[startDateTimeString stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"DTSTART;TZID=%@:", timezoneIDString] withString:@""] stringByReplacingOccurrencesOfString:@"\r" withString:@""];
        
        if (!startDateTimeString) {
            eventScanner = [NSScanner scannerWithString:event];
            [eventScanner scanUpToString:@"DTSTART:" intoString:nil];
            [eventScanner scanUpToString:@"\n" intoString:&startDateTimeString];
            startDateTimeString = [[startDateTimeString stringByReplacingOccurrencesOfString:@"DTSTART:" withString:@""] stringByReplacingOccurrencesOfString:@"\r" withString:@""];
            
            if (!startDateTimeString) {
                eventScanner = [NSScanner scannerWithString:event];
                [eventScanner scanUpToString:@"DTSTART;VALUE=DATE:" intoString:nil];
                [eventScanner scanUpToString:@"\n" intoString:&startDateTimeString];
                startDateTimeString = [[startDateTimeString stringByReplacingOccurrencesOfString:@"DTSTART;VALUE=DATE:" withString:@""] stringByReplacingOccurrencesOfString:@"\r" withString:@""];
            }
        }
        
        // Extract end time
        eventScanner = [NSScanner scannerWithString:event];
        [eventScanner scanUpToString:[NSString stringWithFormat:@"DTEND;TZID=%@:", timezoneIDString] intoString:nil];
        [eventScanner scanUpToString:@"\n" intoString:&endDateTimeString];
        endDateTimeString = [[endDateTimeString stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"DTEND;TZID=%@:", timezoneIDString] withString:@""] stringByReplacingOccurrencesOfString:@"\r" withString:@""];
        
        if (!endDateTimeString) {
            eventScanner = [NSScanner scannerWithString:event];
            [eventScanner scanUpToString:@"DTEND:" intoString:nil];
            [eventScanner scanUpToString:@"\n" intoString:&endDateTimeString];
            endDateTimeString = [[endDateTimeString stringByReplacingOccurrencesOfString:@"DTEND:" withString:@""] stringByReplacingOccurrencesOfString:@"\r" withString:@""];
            
            if (!endDateTimeString) {
                eventScanner = [NSScanner scannerWithString:event];
                [eventScanner scanUpToString:@"DTEND;VALUE=DATE:" intoString:nil];
                [eventScanner scanUpToString:@"\n" intoString:&endDateTimeString];
                endDateTimeString = [[endDateTimeString stringByReplacingOccurrencesOfString:@"DTEND;VALUE=DATE:" withString:@""] stringByReplacingOccurrencesOfString:@"\r" withString:@""];
            }
        }
        
        // Extract timestamp
        eventScanner = [NSScanner scannerWithString:event];
        [eventScanner scanUpToString:@"DTSTAMP:" intoString:nil];
        [eventScanner scanUpToString:@"\n" intoString:&timeStampString];
        timeStampString = [[timeStampString stringByReplacingOccurrencesOfString:@"DTSTAMP:" withString:@""] stringByReplacingOccurrencesOfString:@"\r" withString:@""];
        
        // Extract the unique ID
        eventScanner = [NSScanner scannerWithString:event];
        [eventScanner scanUpToString:@"UID:" intoString:nil];
        [eventScanner scanUpToString:@"\n" intoString:&eventUniqueIDString];
        eventUniqueIDString = [[eventUniqueIDString stringByReplacingOccurrencesOfString:@"UID:" withString:@""] stringByReplacingOccurrencesOfString:@"\r" withString:@""];
        
        // Extract the attendees
        eventScanner = [NSScanner scannerWithString:event];
        bool scannerStatus;
        do {
            NSString *attendeeString;
            if ([eventScanner scanUpToString:@"ATTENDEE;" intoString:nil]) {
                scannerStatus = [eventScanner scanUpToString:@"\n" intoString:&attendeeString];
                if (scannerStatus) {
                    attendeeString = [[attendeeString stringByReplacingOccurrencesOfString:@"ATTENDEE;" withString:@""] stringByReplacingOccurrencesOfString:@"\r" withString:@""];
                    MXLCalendarAttendee *attendee = [self createAttendee:attendeeString];
                    if (attendee) {
                        [attendees addObject:attendee];
                    }
                }
            } else {
                scannerStatus = false;
            }
        } while (scannerStatus);
        
        // Extract the recurrance ID
        eventScanner = [NSScanner scannerWithString:event];
        [eventScanner scanUpToString:[NSString stringWithFormat:@"RECURRENCE-ID;TZID=%@:", timezoneIDString] intoString:nil];
        [eventScanner scanUpToString:@"\n" intoString:&recurrenceIDString];
        recurrenceIDString = [[recurrenceIDString stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"RECURRENCE-ID;TZID=%@:", timezoneIDString] withString:@""] stringByReplacingOccurrencesOfString:@"\r" withString:@""];
        
        // Extract the created datetime
        eventScanner = [NSScanner scannerWithString:event];
        [eventScanner scanUpToString:@"CREATED:" intoString:nil];
        [eventScanner scanUpToString:@"\n" intoString:&createdDateTimeString];
        createdDateTimeString = [[createdDateTimeString stringByReplacingOccurrencesOfString:@"CREATED:" withString:@""] stringByReplacingOccurrencesOfString:@"\r" withString:@""];
        
        
        // Extract event description
        eventScanner = [NSScanner scannerWithString:event];
        [eventScanner scanUpToString:@"DESCRIPTION:" intoString:nil];
        [eventScanner scanUpToString:@"\n" intoString:&descriptionString];
        descriptionString = [[[descriptionString stringByReplacingOccurrencesOfString:@"DESCRIPTION:" withString:@""] stringByReplacingOccurrencesOfString:@"\n" withString:@""] stringByReplacingOccurrencesOfString:@"\r" withString:@""];
        
        // Extract last modified datetime
        eventScanner = [NSScanner scannerWithString:event];
        [eventScanner scanUpToString:@"LAST-MODIFIED:" intoString:nil];
        [eventScanner scanUpToString:@"\n" intoString:&lastModifiedDateTimeString];
        lastModifiedDateTimeString = [[[lastModifiedDateTimeString stringByReplacingOccurrencesOfString:@"LAST-MODIFIED:" withString:@""] stringByReplacingOccurrencesOfString:@"\n" withString:@""] stringByReplacingOccurrencesOfString:@"\r" withString:@""];
        
        // Extract the event location
        eventScanner = [NSScanner scannerWithString:event];
        [eventScanner scanUpToString:@"LOCATION:" intoString:nil];
        [eventScanner scanUpToString:@"\n" intoString:&locationString];
        locationString = [[[locationString stringByReplacingOccurrencesOfString:@"LOCATION:" withString:@""] stringByReplacingOccurrencesOfString:@"\n" withString:@""] stringByReplacingOccurrencesOfString:@"\r" withString:@""];
        
        // Extract the event sequence
        eventScanner = [NSScanner scannerWithString:event];
        [eventScanner scanUpToString:@"SEQUENCE:" intoString:nil];
        [eventScanner scanUpToString:@"\n" intoString:&sequenceString];
        sequenceString = [[[sequenceString stringByReplacingOccurrencesOfString:@"SEQUENCE:" withString:@""] stringByReplacingOccurrencesOfString:@"\n" withString:@""] stringByReplacingOccurrencesOfString:@"\r" withString:@""];
        
        // Extract the event status
        eventScanner = [NSScanner scannerWithString:event];
        [eventScanner scanUpToString:@"STATUS:" intoString:nil];
        [eventScanner scanUpToString:@"\n" intoString:&statusString];
        statusString = [[[statusString stringByReplacingOccurrencesOfString:@"STATUS:" withString:@""] stringByReplacingOccurrencesOfString:@"\n" withString:@""] stringByReplacingOccurrencesOfString:@"\r" withString:@""];
        
        // Extract the event summary
        eventScanner = [NSScanner scannerWithString:event];
        [eventScanner scanUpToString:@"SUMMARY:" intoString:nil];
        [eventScanner scanUpToString:@"\n" intoString:&summaryString];
        summaryString = [[[summaryString stringByReplacingOccurrencesOfString:@"SUMMARY:" withString:@""] stringByReplacingOccurrencesOfString:@"\n" withString:@""] stringByReplacingOccurrencesOfString:@"\r" withString:@""];
        
        // Extract the event transString
        eventScanner = [NSScanner scannerWithString:event];
        [eventScanner scanUpToString:@"TRANSP:" intoString:nil];
        [eventScanner scanUpToString:@"\n" intoString:&transString];
        transString = [[[transString stringByReplacingOccurrencesOfString:@"TRANSP:" withString:@""] stringByReplacingOccurrencesOfString:@"\n" withString:@""] stringByReplacingOccurrencesOfString:@"\r" withString:@""];
        
        // Extract the event repetition rules
        eventScanner = [NSScanner scannerWithString:event];
        [eventScanner scanUpToString:@"RRULE:" intoString:nil];
        [eventScanner scanUpToString:@"\n" intoString:&repetitionString];
        repetitionString = [[[[repetitionString stringByReplacingOccurrencesOfString:@"RRULE:" withString:@""] stringByReplacingOccurrencesOfString:@"\n" withString:@""] stringByReplacingOccurrencesOfString:@"\r" withString:@""] stringByReplacingOccurrencesOfString:@"\"" withString:@""];
        
        // Extract the event exception rules
        eventScanner = [NSScanner scannerWithString:event];
        [eventScanner scanUpToString:@"EXRULE:" intoString:nil];
        [eventScanner scanUpToString:@"\n" intoString:&exceptionRuleString];
        exceptionRuleString = [[[exceptionRuleString stringByReplacingOccurrencesOfString:@"EXRULE:" withString:@""] stringByReplacingOccurrencesOfString:@"\n" withString:@""] stringByReplacingOccurrencesOfString:@"\r" withString:@""];
        
        // Set up scanner for
        eventScanner = [NSScanner scannerWithString:event];
        [eventScanner scanUpToString:@"EXDATE;" intoString:nil];
        
        // Extract the event travel time
        eventScanner = [NSScanner scannerWithString:event];
        [eventScanner scanUpToString:@"X-APPLE-TRAVEL-DURATION;" intoString:nil];
        [eventScanner scanUpToString:@"\n" intoString:&travelTimeString];
        travelTimeString = [[[[[travelTimeString stringByReplacingOccurrencesOfString:@"X-APPLE-TRAVEL-DURATION;" withString:@""] stringByReplacingOccurrencesOfString:@"\n" withString:@""] stringByReplacingOccurrencesOfString:@"\r" withString:@""] stringByReplacingOccurrencesOfString:@"\"" withString:@""] stringByReplacingOccurrencesOfString:@"VALUE=DURATION:" withString:@""];
        travelTimeString = [self reverseTravelTime:travelTimeString];
        
        // Extract the event travel time
        eventScanner = [NSScanner scannerWithString:event];
        [eventScanner scanUpToString:@"URL;VALUE=URI:" intoString:nil];
        [eventScanner scanUpToString:@"\n" intoString:&urlString];
        urlString = [[[[urlString stringByReplacingOccurrencesOfString:@"URL;VALUE=URI:" withString:@""] stringByReplacingOccurrencesOfString:@"\n" withString:@""] stringByReplacingOccurrencesOfString:@"\r" withString:@""] stringByReplacingOccurrencesOfString:@"\"" withString:@""];
        
        while (![eventScanner isAtEnd]) {
            [eventScanner scanUpToString:@":" intoString:nil];
            NSString *exceptionString = [[NSString alloc] init];
            [eventScanner scanUpToString:@"\n" intoString:&exceptionString];
            exceptionString = [[[exceptionString stringByReplacingOccurrencesOfString:@":" withString:@""] stringByReplacingOccurrencesOfString:@"\n" withString:@""] stringByReplacingOccurrencesOfString:@"\r" withString:@""];
            
            if (exceptionString) {
                [exceptionDates addObject:exceptionString];
            }
            
            [eventScanner scanUpToString:@"EXDATE;" intoString:nil];
        }
        
        MXLCalendarEvent *event = [[MXLCalendarEvent alloc] initWithStartDate:startDateTimeString
                                                                      endDate:endDateTimeString
                                                                    createdAt:createdDateTimeString
                                                                 lastModified:lastModifiedDateTimeString
                                                                     uniqueID:eventUniqueIDString
                                                                 recurrenceID:recurrenceIDString
                                                                      summary:summaryString
                                                                  description:descriptionString
                                                                     location:locationString
                                                                       status:statusString
                                                              recurrenceRules:repetitionString
                                                               exceptionDates:exceptionDates
                                                                exceptionRule:exceptionRuleString
                                                           timeZoneIdentifier:timezoneIDString ? timezoneIDString : calendarString
                                                                   travelTime:travelTimeString
                                                                          url:urlString
                                                                    attendees:attendees];
        
        EKEvent *testEvent = [event convertToEKEventOnDate:[event dateFromString:startDateTimeString] store:self.eventManager.eventStore];
        testEvent.calendar = cal;
        
        if (eventIdentifier) {
            [tempEventArray setObject:testEvent forKey:eventIdentifier]; // Key is old eventID, object is current event object
        }
        
        NSError *myError;
        if ([self.eventManager.eventStore saveEvent:testEvent span:EKSpanFutureEvents commit:NO error:&myError]) {
            NSLog(@"Event was successfully added!");
        }  else {
            NSLog(@"Error creating event. Error:%@", myError);
            if (eventIdentifier) {
                [tempEventArray removeObjectForKey:eventIdentifier]; // If failed, remove the item from list
            }
        }
        
        if (++saveCount == 50) {
            updateCallback(saveCount);
            saveCount = 0;
        }
    }
    
    if (saveCount > 0) {
        updateCallback(saveCount);
    }
    
    if (hasNewEventUpdated) { // new events in the list, need to commit
        NSError *commitErr = nil;
        if (![self.eventManager.eventStore commit:&commitErr]) {
            callback(nil, commitErr);
        } else {
            for (NSString *eventIdentifier in [tempEventArray allKeys]) {
                [localEventDuplicateList setObject:((EKEvent *)[tempEventArray objectForKey:eventIdentifier]).eventIdentifier forKey:eventIdentifier]; // key is sender side eventID, value is local event ID
            }
            [[CTDuplicateLists uniqueList] replaceCalendarDuplicateList:localEventDuplicateList];
            
            callback(nil, nil);
        }
    } else {
        callback(nil, nil);
    }
}

- (NSString *)reverseTravelTime:(NSString *)travelFormatted
{
    if (travelFormatted.length == 0) {
        return nil;
    }
    travelFormatted = [travelFormatted stringByReplacingOccurrencesOfString:@"PT" withString:@""];
    NSArray *components = [travelFormatted componentsSeparatedByString:@"H"];
    
    NSString *hour = @"0";
    NSString *min = @"0";
    
    if (components.count > 0) {
        hour = [components objectAtIndex:0];
    }
    
    if (components.count > 1) {
        min = [[components objectAtIndex:1] stringByReplacingOccurrencesOfString:@"M" withString:@""];
    }
    
    return [NSString stringWithFormat:@"%ld",(long)([hour integerValue]*60*60 + [min integerValue]*60)];
}

@end
