//
//  CTCalendarExport.m
//  contenttransfer
//
//  Created by Guntupalli, Neelima on 8/31/16.
//  Copyright © 2016 Verizon. All rights reserved.
//

#import "CTCalendarExport.h"
#import "CTFileManager.h"
#import "EKEvent+Utilities.h"
#import "CTColor.h"
#import "CTUserDefaults.h"
#import "CTDataCollectionManager.h"
#import "UIColor+CTColorHelper.h"

#import <EventKit/EventKit.h>

@interface CTCalendarExport ()

@property (nonatomic, assign) NSInteger totalnumberOfCalender;
@property (nonatomic, strong) EKEventStore *eventStore;
@property (nonatomic, strong) NSMutableDictionary *calendarHashTable;
@end

@implementation CTCalendarExport

@synthesize totalnumberOfCalender;

- (NSMutableDictionary *)calendarHashTable {
    if (!_calendarHashTable) {
        _calendarHashTable = [[NSMutableDictionary alloc] init];
    }
    
    return _calendarHashTable;
}

+ (instancetype)calendarsExport {
    
    static CTCalendarExport *calendarExport = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        calendarExport = [[CTCalendarExport alloc] init];
    });
    
    return calendarExport;
}

- (instancetype)init {
    if (self = [super init]) {
        self.eventStore = [EKEventStore new];
    }
    return self;
}

- (void)fetchCalendars:(void(^)(NSInteger countOfEvents,float lengthOfData))completionBlock
          failureBlock:(void(^)(NSError *err))failureBlock
           updateBlock:(void(^)(NSInteger calendarCount))updateBlock {
    
    totalnumberOfCalender = 0;
    
    __block NSInteger allCalendarsCount = 0;
    NSArray *allCalendarsLists = [self.eventStore calendarsForEntityType:EKEntityTypeEvent];
    
    NSMutableArray *allCalendarsArray = [NSMutableArray new];
    
    __block NSInteger count = [allCalendarsLists count];
    __block int calendarCount = 0;
    __block NSInteger sizeOfAllCalendars = 0;
    
    if (count==0) { // no calendar list
        completionBlock(0,0);
        return;
    }
    
    [allCalendarsLists enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        *stop = [CTDataCollectionManager sharedManager].isCalendarsFetchingOperationCancelled;
        
        EKCalendar *eachCalendarList = (EKCalendar *)obj;
    
        if (eachCalendarList.type != EKCalendarTypeLocal) { // If current calendar is not local calendar, no need to fetch the events
            [self eventStoreDidFetchedCalendarEvents:--count andTotalEventCount:allCalendarsCount andTotalSize:sizeOfAllCalendars andCalendarArray:allCalendarsArray withCompletion:completionBlock andFailure:failureBlock];
            
            return;
        }
        
        [self eventsInCalendarList:eachCalendarList completionBlock:^(NSDictionary *eachCalendarLog, NSInteger eventsCount) {
            if (eventsCount > 0) {
                sizeOfAllCalendars = sizeOfAllCalendars + [[eachCalendarLog objectForKey:@"Size"] integerValue];
                [allCalendarsArray addObject:eachCalendarLog];
                updateBlock(++calendarCount);
                
                allCalendarsCount = allCalendarsCount + eventsCount;
            }
            
            [self eventStoreDidFetchedCalendarEvents:--count andTotalEventCount:allCalendarsCount andTotalSize:sizeOfAllCalendars andCalendarArray:allCalendarsArray withCompletion:completionBlock andFailure:failureBlock];
        }];
    }];
}

- (void)eventStoreDidFetchedCalendarEvents:(NSInteger)count
                        andTotalEventCount:(NSInteger)allCalendarsCount
                              andTotalSize:(NSInteger)sizeOfAllCalendars
                          andCalendarArray:(NSArray *)allCalendarsArray
                            withCompletion:(void(^)(NSInteger countOfEvents,float lengthOfData))completionBlock
                                andFailure:(void(^)(NSError *err))failureBlock  {
    if (count == 0) {
        if (allCalendarsCount==0) { // have calendar but no event
            completionBlock(0,0);
            return;
        }
        NSError *error;
        NSData *calendarData = [NSJSONSerialization dataWithJSONObject:allCalendarsArray options:NSJSONWritingPrettyPrinted error:&error];
        
        [CTFileManager createFileWithName:@"CTCalendarLogFile.txt" withContents:calendarData];
        if (error) {
            DebugLog(@"%@",error.description);
            failureBlock(error);
        } else {
            [CTUserDefaults sharedInstance].calendarList = self.calendarHashTable;
            completionBlock(totalnumberOfCalender,sizeOfAllCalendars);
        }
    }
}

- (void)eventsInCalendarList:(EKCalendar*)eachCalendarList completionBlock:(void(^)(NSDictionary* eachCalendarLog , NSInteger eventsCount))block {
    
    int twoYearsSeconds = 60*60*24*365*2;
    
    NSPredicate *predicate = [self.eventStore predicateForEventsWithStartDate:[NSDate dateWithTimeIntervalSinceNow:-twoYearsSeconds] endDate:[NSDate dateWithTimeIntervalSinceNow:twoYearsSeconds] calendars:@[eachCalendarList]];
    
    NSMutableDictionary *dataSet = [[NSMutableDictionary alloc] init];
    [self.eventStore enumerateEventsMatchingPredicate:predicate usingBlock:^(EKEvent * _Nonnull event, BOOL * _Nonnull stop) {
        *stop = [CTDataCollectionManager sharedManager].isCalendarsFetchingOperationCancelled;
        if (event && event.eventIdentifier && ![dataSet objectForKey:event.eventIdentifier]) {
            [dataSet setObject:event forKey:event.eventIdentifier];
        }
    }];
    
    NSArray *calendarEvents = dataSet.allValues;
    
    //TBD: Logic to generate ics file and store it
    if (calendarEvents.count > 0) {
        totalnumberOfCalender++;
        [self createICSfileforCalender:calendarEvents Calname:eachCalendarList.title andColor:eachCalendarList.CGColor completionBlock:^(NSDictionary *eachCalendarLog) {
            block(eachCalendarLog, calendarEvents.count);
        }];
    } else {
        //failureBlock(@"No Events found for this ics file");
        block(@{},0);
    }
    
}

//- (NSArray*)filterDuplicateEvents:(NSArray*)allEventsArray {
//    
//    NSMutableDictionary *eventHash = [[NSMutableDictionary alloc] init];
//    NSMutableArray *filteredEvents = [[NSMutableArray alloc] init];
//    for (EKEvent *event in allEventsArray) {
//        if (![eventHash valueForKey:event.eventIdentifier]) {
//            if (event.eventIdentifier) { // if event without identifier is a invalid event
//                [eventHash setValue:event forKey:event.eventIdentifier]; // Update the hash table
//                [filteredEvents addObject:event];
//            }
//        }
//    }
//    
//    return [filteredEvents copy];
//}

- (void)createICSfileforCalender:(NSArray *)eachCalendarEvents Calname:(NSString*)filename  andColor:(CGColorRef)calColor completionBlock:(void(^)(NSDictionary* eachCalendarLog))block {
    
    NSString *icalRepresentation = [NSString string];
    
    NSMutableString *ical = [NSMutableString string];
    [ical appendString:@"BEGIN:VCALENDAR"];
    [ical appendString:@"\r\nVERSION:2.0"];
    
    for (EKEvent *event in eachCalendarEvents) {
        @autoreleasepool {
            // DebugLog(@"%@", event.eventIdentifier);
            icalRepresentation = [event iCalString];
            [ical appendString:icalRepresentation];
        }
    }
    [ical appendString:@"\r\nEND:VCALENDAR"];
    //DebugLog(@"%@",ical);
    
    NSData *calendarData = [ical dataUsingEncoding:NSUTF8StringEncoding];
    NSString *fileName = [NSString stringWithFormat:@"%@.ics",filename];
    [CTFileManager createDirectory:@"Calendars" withFileName:fileName withContents:calendarData completionBlock:^(NSString *filePath, NSError *error) {
        
        if (!error) { // if error is nil, file path must exist
            [self.calendarHashTable setObject:filePath forKey:fileName];
            
            NSMutableDictionary *eachCalLogDict = [NSMutableDictionary new];
            [eachCalLogDict setObject:fileName forKey:@"Path"];
            [eachCalLogDict setObject:[NSString stringWithFormat:@"%lu",(unsigned long)calendarData.length] forKey:@"Size"];
            [eachCalLogDict setObject:[UIColor hexOFColor:calColor] forKey:@"CalColor"];
            [eachCalLogDict setObject:[NSString stringWithFormat:@"%lu",(unsigned long)eachCalendarEvents.count] forKey:@"NumberOfEvents"];
            block(eachCalLogDict);
        } else {
            DebugLog(@"create file failed:%@", error.localizedDescription);
        }
    }];
    
}
@end
