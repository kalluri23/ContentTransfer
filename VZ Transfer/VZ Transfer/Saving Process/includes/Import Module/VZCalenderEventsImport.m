//
//  VZEventsExport.m
//  myverizon
//
//  Created by Tourani, Sanjay on 4/5/16.
//  Copyright © 2016 Verizon Wireless. All rights reserved.
//

#import "VZCalenderEventsImport.h"
#import "NSString+CTRootDocument.h"
#import "UIColor+CTColorHelper.h"
#import "CTUserDevice.h"

@interface VZCalenderEventsImport()

@property (nonatomic, strong) NSMutableDictionary *calendarHash;
@property (nonatomic, assign) NSInteger count;
@property (nonatomic, assign) BOOL errHappened;

@end

@implementation VZCalenderEventsImport
@synthesize eventManager;

- (id) init {
    if (self = [super init]) {
        eventManager = [VZEventManager sharedEvent];
        
        self.calendarHash = [[NSMutableDictionary alloc] init];
        [self getLocalCalData];
    }
    
    return self;
}


+ (void)checkAuthorizationStatusToAccessEventStoreSuccess:(successHandler)success andFailureHandler:(failureHandler)failure {
    
    //Need to check authorization for Event
    EKAuthorizationStatus authorizationStatus = [EKEventStore authorizationStatusForEntityType:EKEntityTypeEvent];
    
    switch (authorizationStatus) {
            
        case EKAuthorizationStatusDenied: {
            failure(EKAuthorizationStatusDenied);
            break;
        }
            
        case EKAuthorizationStatusRestricted: {
            failure(EKAuthorizationStatusRestricted);
            
            break;
        }
            
        case EKAuthorizationStatusAuthorized: {
            success();
            
            break;
        }
            
        case EKAuthorizationStatusNotDetermined: {
            
            [[VZEventManager sharedEvent].eventStore requestAccessToEntityType:EKEntityTypeEvent
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
            
        default: {
            failure(EKAuthorizationStatusDenied);
        }
    }
    
    
}

- (void)getLocalCalData
{
    NSArray *allCalendars = [self.eventManager.eventStore calendarsForEntityType:EKEntityTypeEvent];
//    DebugLog(@"All Calendars: %@",allCalendars);
    
    //Now only look for LOCAL Calendars. Ignore iCloud Calendars
    
    for (int i=0; i<allCalendars.count; i++) {
        EKCalendar *currentCalendar = [allCalendars objectAtIndex:i];
        if (currentCalendar.type == EKCalendarTypeLocal) {
            [self.calendarHash setObject:currentCalendar forKey:currentCalendar.title];
        }
    }
}


- (void)createCalendarsSuccess:(importSuccessHandler)success failure:(importFailureHandler)failure {
    
    // Find all the ics files in the folder
    NSString *folder = [[NSString appRootDocumentDirectory] stringByAppendingPathComponent:@"ReceivedCal"];
    NSArray *dirFiles = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:folder error:nil];

    EKSource *calSource = nil;
    
    for (int i=0; i<self.eventManager.eventStore.sources.count; i++) {
        EKSource *source = (EKSource *)[self.eventManager.eventStore.sources objectAtIndex:i];
        EKSourceType currentSourceType = source.sourceType;
        
        if (currentSourceType == EKSourceTypeLocal) {
            calSource = source;
            break;
        }
    }
    
    if (dirFiles.count > 0) {
        [self enumerateCalendars:dirFiles calSource:calSource success:success failure:failure];
    } else {
        failure();
    }
}

- (void)getTotalCalendarEventCount:(void(^)(NSInteger eventCount))handler {
    // Find all the ics files in the folder
    NSString *folder = [[NSString appRootDocumentDirectory] stringByAppendingPathComponent:@"ReceivedCal"];
    NSArray *dirFiles = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:folder error:nil];
    
    if (dirFiles.count > 0) {
        __block int finishCount = 0;
        __block NSInteger totalEventCount = 0;
        for (NSString *fileName in dirFiles) {
            DebugLog(@"calendar name: %@", fileName);
            
            MXLCalendarManager *calendarManager = [[MXLCalendarManager alloc] init];
            NSString *fullPath = [folder stringByAppendingPathComponent:fileName];
            DebugLog(@"path:%@", fullPath);

            NSURL *fileURL = [NSURL fileURLWithPath:fullPath];
            [calendarManager scanICSFileForCountAtRemoteURL:fileURL withCompletionHandler:^(NSInteger calendarCount) {
                totalEventCount += calendarCount;
                if (++finishCount == dirFiles.count) {
                    handler(totalEventCount);
                }
            }];
        }
    }
}

- (void)enumerateCalendars:(NSArray *)dirFiles calSource:(EKSource *)calSource success:(importSuccessHandler)success failure:(importFailureHandler)failure
{
    NSString *fileName = (NSString *)[dirFiles objectAtIndex:_count];
    DebugLog(@"calendar name: %@", fileName);
    UIColor *color = nil;
    NSString *calendarName = @"";
    
    if ([[CTUserDevice userDevice].phoneCombination isEqualToString:IOS_IOS]) {
        NSArray *conponents = [fileName componentsSeparatedByString:@"_"];
        NSString *hexString = (NSString *)[conponents objectAtIndex:0];
        
        // Get color from hex string
        color = [UIColor colorFromHexString:hexString];
        
        for (int i = 1; i<conponents.count; i++) {
            if (calendarName.length == 0) {
                calendarName = conponents[i];
            } else {
                calendarName = [NSString stringWithFormat:@"%@_%@",calendarName,conponents[i]];
            }
        }
        calendarName = [calendarName stringByDeletingPathExtension];
    } else {
        NSArray *conponents = [fileName componentsSeparatedByString:@"."];
        
        for (int i = 0; i<conponents.count-1; i++) {
            if (calendarName.length == 0) {
                calendarName = conponents[i];
            } else {
                calendarName = [NSString stringWithFormat:@"%@.%@",calendarName,conponents[i]];
            }
        }
    }
    
    EKCalendar *calendar = nil;
    if ([self.calendarHash objectForKey:calendarName]) {
        // use the same calendar
        calendar = (EKCalendar *)[self.calendarHash objectForKey:calendarName];
        //            DebugLog(@"Calendar exists: %@", calendar);
        if (color) {
            calendar.CGColor = [color CGColor];
        }
        [self parseICSFileAtPath:[dirFiles objectAtIndex:_count] forCalendar:calendar failure:^{
            DebugLog(@"scan error");
            _errHappened = YES;
            
            [self delete:[dirFiles objectAtIndex:_count]];
            _count ++;
            if (dirFiles.count == _count) {
                failure();
            } else {
                [self enumerateCalendars:dirFiles calSource:calSource success:success failure:failure];
            }
        } success:^{
            
            [self delete:[dirFiles objectAtIndex:_count]];
            _count ++;
            if (dirFiles.count == _count) {
                if (_errHappened) {
                    failure();
                } else {
                    success();
                }
            } else {
                [self enumerateCalendars:dirFiles calSource:calSource success:success failure:failure];
            }
        }];
    } else {
        // create a new calendar
        calendar = [EKCalendar calendarForEntityType:EKEntityTypeEvent eventStore:self.eventManager.eventStore];
        // give string the ics filename
        calendar.title = calendarName;
        calendar.source = calSource;
        if (color) {
            calendar.CGColor = [color CGColor];
        }
        
        NSError *error;
        [self.eventManager.eventStore saveCalendar:calendar commit:YES error:&error];
        
        if (error == nil) {
            //                DebugLog(@"Calendar was created succesfully:%@", calendar);
            [self parseICSFileAtPath:[dirFiles objectAtIndex:_count] forCalendar:calendar failure:^{
                DebugLog(@"scan error");
                _errHappened = YES;
                [self delete:[dirFiles objectAtIndex:_count]];
                _count ++;
                if (dirFiles.count == _count) {
                    failure();
                } else {
                    [self enumerateCalendars:dirFiles calSource:calSource success:success failure:failure];
                }
            } success:^{
                [self delete:[dirFiles objectAtIndex:_count]];
                _count ++;
                if (dirFiles.count == _count) {
                    if (_errHappened) {
                        failure();
                    } else {
                        success();
                    }
                } else {
                    [self enumerateCalendars:dirFiles calSource:calSource success:success failure:failure];
                }
            }];
        } else {
            [self delete:[dirFiles objectAtIndex:_count]];
            _errHappened = YES;
            
            _count ++;
            if (dirFiles.count == _count) {
                failure();
            } else {
                [self enumerateCalendars:dirFiles calSource:calSource success:success failure:failure];
            }
        }
    }
}

- (void)delete:(NSString *)fileName {
    NSString *documentsDirectory1 = [[NSString appRootDocumentDirectory] stringByAppendingPathComponent:@"ReceivedCal"];
    NSString *filePath = [documentsDirectory1 stringByAppendingPathComponent:fileName];
    
    [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
}

- (void)parseICSFileAtPath:(NSString *)path forCalendar:(EKCalendar *)calendar failure:(importFailureHandler)failure success:(importSuccessHandler)success {
    
    MXLCalendarManager *calendarManager = [[MXLCalendarManager alloc] init];
    
    NSString *folder = [[NSString appRootDocumentDirectory] stringByAppendingPathComponent:@"ReceivedCal"];
    NSString *fullPath = [folder stringByAppendingPathComponent:path];
    DebugLog(@"path:%@", fullPath);
    NSURL *fileURL = [NSURL fileURLWithPath:fullPath];
    [calendarManager scanICSFileAtRemoteURL:fileURL intoCalendar:calendar withCompletionHandler:^(MXLCalendar *calendar, NSError *error) {
        // remove the file after save process done
        [[NSFileManager defaultManager] removeItemAtPath:fullPath error:nil];
        
         if (error) {
             failure();
         } else {
             DebugLog(@"ICS scanned successfully");
             success();
         }
    } update:^(NSInteger count) {
        [self.delegate shouldUpdateCalendarNumber:count];
    }];
}

@end
