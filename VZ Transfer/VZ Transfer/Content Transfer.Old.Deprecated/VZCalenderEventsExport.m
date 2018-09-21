//
//  VZEventsImport.m
//  myverizon
//
//  Created by Tourani, Sanjay on 4/6/16.
//  Copyright © 2016 Verizon Wireless. All rights reserved.
//

#import "VZCalenderEventsExport.h"
#import "VZContentTrasnferConstant.h"
#import "NSString+CTContentTransferRootDocuments.h"
#import "CTUserDevice.h"

@interface VZCalenderEventsExport()

@property (nonatomic, strong) NSMutableDictionary *eventHash;

@property (nonatomic, assign) NSInteger totalSize;

@end

@implementation VZCalenderEventsExport

@synthesize eventManager;
@synthesize calenderList;

- (NSMutableDictionary *)eventHash
{
    if (!_eventHash) {
        _eventHash = [[NSMutableDictionary alloc] init];
    }
    
    return _eventHash;
}

- (id) init {
    if (self = [super init]) {
        eventManager = [VZEventManager sharedEvent];
        
        self.calenderList = [[NSMutableArray alloc] init];
        self.numberOfEvents = 0;
    }
    
    return self;
}


- (void)checkAuthorizationStatusToAccessEventStoreSuccess:(successHandler)success andFailureHandler:(failureHandler)failure {
    
    //Need to check authorization for Event
    EKAuthorizationStatus authorizationStatus = [EKEventStore authorizationStatusForEntityType:EKEntityTypeEvent];
    
    switch (authorizationStatus) {
            
        case EKAuthorizationStatusDenied: {
            self.isAccessToEventStoreGranted = NO;
            failure(EKAuthorizationStatusDenied);
            break;
        }
            
        case EKAuthorizationStatusRestricted: {
            self.isAccessToEventStoreGranted = NO;
            failure(EKAuthorizationStatusRestricted);
            
            break;
        }
            
        case EKAuthorizationStatusAuthorized: {
            self.isAccessToEventStoreGranted = YES;
            success();
            
            break;
        }
            
        case EKAuthorizationStatusNotDetermined: {
            
            [self.eventManager.eventStore requestAccessToEntityType:EKEntityTypeEvent
                                                         completion:^(BOOL granted, NSError *error) {
                                                             dispatch_async(dispatch_get_main_queue(), ^{
                                                                 
                                                                 if(!granted) {
                                                                     self.isAccessToEventStoreGranted = NO;
                                                                     failure(EKAuthorizationStatusDenied);
                                                                 } else {
                                                                     success();
                                                                 }
                                                             });
                                                         }];
            break;

        }
            
        default: {
            self.isAccessToEventStoreGranted = NO;
            failure(EKAuthorizationStatusDenied);
        }
    }
    
    
}


- (void)fetchLocalCalendarsWithSuccessHandler:(fetchSuccessHandler)success andFailureHandler:(fetchFailureHandler)failure
{
    NSArray *allCalendars = [self.eventManager.eventStore calendarsForEntityType:EKEntityTypeEvent];
    DebugLog(@"All Calendars: %@",allCalendars);
    //Now only look for LOCAL Calendars. Ignore iCloud Calendars
//    NSMutableArray *localCalendars = [[NSMutableArray alloc]init];
    
    for (int i=0; i<allCalendars.count; i++) {
        EKCalendar *currentCalendar = [allCalendars objectAtIndex:i];
        if (currentCalendar.type == EKCalendarTypeLocal) { // iCloud calendar not sending? cross platform as iCloud photos?
//            [localCalendars addObject:currentCalendar];
            [self fetchEventsForCalendar:currentCalendar Calname:currentCalendar.title withFailureHandler:^(NSError *err) {
                failure(err);
            }];
            
        }
    }
    
    NSData *CalenderData = [NSJSONSerialization dataWithJSONObject:self.calenderList options:NSJSONWritingPrettyPrinted error:nil];
    
    NSUserDefaults *userdefault = [NSUserDefaults standardUserDefaults];
    [userdefault setObject:[NSString stringWithFormat:@"%ld",CalenderData.length] forKey:@"CALENDARTOTALSIZE"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
//    NSString *docPath = [[NSString appRootDocumentDirectory] stringByAppendingPathComponent:@"Documents"];
    [fileManager createFileAtPath:[[NSString appRootDocumentDirectory] stringByAppendingPathComponent:@"VZCalenderLogoFile.txt"] contents:CalenderData attributes: nil];
    
    success(self.numberOfEvents);
}

- (void)fetchEventsForCalendar:(EKCalendar *)calendar Calname:(NSString *)calenderName withFailureHandler:(fetchFailureHandler)failure {
    
    // Fetch events starting from 2 years ago until the next 2 years
    NSArray *calendarsArray = nil;
    if (calendar != nil) {
        calendarsArray = @[calendar];
    }
    
    int twoYearsSeconds = 60*60*24*365*2;
    
    NSPredicate *predicate = [self.eventManager.eventStore predicateForEventsWithStartDate:[NSDate dateWithTimeIntervalSinceNow:-twoYearsSeconds] endDate:[NSDate dateWithTimeIntervalSinceNow:twoYearsSeconds] calendars:calendarsArray];
    self.events = [self.eventManager.eventStore eventsMatchingPredicate:predicate];
    DebugLog(@"events:%lu\n%@",(unsigned long)self.events.count, self.events);
    if (self.events && self.events.count > 0) {
        [self filterDuplicateEvents];
        [self createICSfileforCalender:self.events Calname:calenderName andColor:calendar.CGColor withFailure:failure];
    }
}

- (void)filterDuplicateEvents
{
    NSMutableDictionary *eventHash = [[NSMutableDictionary alloc] init];
    NSMutableArray *filteredEvents = [[NSMutableArray alloc] init];
    for (EKEvent *event in self.events) {
        if (![eventHash valueForKey:event.eventIdentifier]) {
            [eventHash setValue:event forKey:event.eventIdentifier]; // Update the hash table
            [filteredEvents addObject:event];
        }
    }
    
    self.events = filteredEvents; // assign back
}


- (void)createICSfileforCalender:(NSArray *)event Calname:(NSString *)name andColor:(CGColorRef)calColor withFailure:(fetchFailureHandler)failure {
    
    NSString *icalRepresentation = [NSString string];
    
    NSMutableString *ical = [NSMutableString string];
    [ical appendString:@"BEGIN:VCALENDAR"];
    [ical appendString:@"\r\nVERSION:2.0"];
    
//    int i = 0;
    for (EKEvent *event in _events) {
        @autoreleasepool {
            DebugLog(@"%@", event.eventIdentifier);
//            i++;
            icalRepresentation = [event iCalString];
            [ical appendString:icalRepresentation];
        }
    }
    [ical appendString:@"\r\nEND:VCALENDAR"];
    DebugLog(@"%@",ical);
    NSError *error = nil;
    
    NSURL* fileURL = nil;
    
    // Create MyPhoto folder to store photos
    NSString *docPath = [[NSString appRootDocumentDirectory] stringByAppendingPathComponent:@"Cal"];
    
    // create new folder
    if (![[NSFileManager defaultManager] fileExistsAtPath:docPath]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:docPath withIntermediateDirectories:YES attributes:nil error:&error]; //Create folder
    }
    NSString *fullPath = [docPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.ics",name]];
    if ([[NSFileManager defaultManager] fileExistsAtPath:fullPath]) {
        [[NSFileManager defaultManager] removeItemAtPath:fullPath error:&error];
    }
    fileURL = [NSURL fileURLWithPath:fullPath];
    [ical writeToURL:fileURL atomically:NO encoding:NSUTF8StringEncoding error:&error];
    
    if (error) {
        failure(error);
    } else {
        // ics file created succesfully
        unsigned long long fileSize = [[[NSFileManager defaultManager] attributesOfItemAtPath:fullPath error:nil] fileSize];
        
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        
        NSString *fileName = [NSString stringWithFormat:@"%@.ics",name];
        if ([[CTUserDevice userDevice].phoneCombination isEqualToString:IOS_IOS]) {
            [dict setValue:fileName forKey:@"Path"];
        } else {
            [dict setValue:[NSString stringWithFormat:@"/storage/emulated/0/Download/vztransfer/calendar/%@", fileName] forKey:@"Path"];
        }
        [dict setValue:[NSString stringWithFormat:@"%lu",(unsigned long)fileSize] forKey:@"Size"];
        [dict setValue:[NSString stringWithFormat:@"%lu", (unsigned long)_events.count] forKey:@"NumberOfEvents"];
        [UIColor blueColor];
        const CGFloat *components = CGColorGetComponents(calColor);
        CGFloat r = components[0];
        CGFloat g = components[1];
        CGFloat b = components[2];
        NSString *hexString=[NSString stringWithFormat:@"%02X%02X%02X", (int)(r * 255), (int)(g * 255), (int)(b * 255)];
#ifdef DEV_ENV
        DebugLog(@"%@", hexString);
#endif
        
        [dict setValue:hexString forKey:@"CalColor"];
        
        [self.eventHash setObject:fullPath forKey:fileName];
        
        [self.calenderList addObject:dict];
        
        self.numberOfEvents += 1;
        [self.delegate shouldUpdateCalendarNumber:self.numberOfEvents];
    }
}

- (NSString *)getEventURL:(NSString *)hashKey
{
    return (NSString *)[self.eventHash objectForKey:hashKey];
}

@end
