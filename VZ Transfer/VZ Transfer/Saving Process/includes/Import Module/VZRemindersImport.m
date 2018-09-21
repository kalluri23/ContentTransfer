//
//  VZRemindersExport.m
//  myverizon
//
//  Created by Tourani, Sanjay on 4/5/16.
//  Copyright © 2016 Verizon Wireless. All rights reserved.
//
#import "VZRemindersImport.h"
#import "NSString+CTRootDocument.h"
#import "CTReminder.h"
#import "CTDuplicateLists.h"
#import "UIColor+CTColorHelper.h"

#import <MapKit/MapKit.h>

@interface VZRemindersImport()

/*! Count for saving reminder events.*/
@property (assign, nonatomic) NSInteger reminderSavedCount;
/*! Count for saving reminder list.*/
@property (assign, nonatomic) NSInteger reminderListSavedCount;
/*! Total number of reminder events.*/
@property (assign, nonatomic) NSInteger totalReminderCount;
/*! Hash table for local reminder list(calendar).*/
@property (nonatomic, strong) NSMutableDictionary *localCalendarHash;
/*! Hash table for local reminder event identifier.*/
@property (nonatomic, strong) NSMutableDictionary *localDuplicateList;

@end

@implementation VZRemindersImport

@synthesize eventManager;
@synthesize completionHandler;

#pragma mark - Lazy loadings
- (NSMutableDictionary *)localCalendarHash {
    if (!_localCalendarHash) {
        _localCalendarHash = [[NSMutableDictionary alloc] init];
    }
    
    return _localCalendarHash;
}

- (NSMutableDictionary *)localDuplicateList {
    if (!_localDuplicateList) {
        _localDuplicateList = [[[CTDuplicateLists uniqueList] reminderList] mutableCopy];
        if (!_localDuplicateList) {
            _localDuplicateList = [NSMutableDictionary new];
        }
    }
    
    return _localDuplicateList;
}

#pragma mark - Initializer
- (id)init {
    if (self = [super init]) {
        eventManager = [VZEventManager sharedEvent];
        [self checkLocalReminderData];
    }
    
    return self;
}

#pragma mark - Convenients
/*!
 @brief Check local reminder list and generate a map for future duplicate check purpose.
 */
- (void)checkLocalReminderData {
    // Find the exist calendars
    NSArray *allCalendars = [self.eventManager.eventStore calendarsForEntityType:EKEntityTypeReminder];
    
    for (EKCalendar *currentCalendar in allCalendars) {
        if (currentCalendar.source == self.eventManager.eventStore.defaultCalendarForNewReminders.source) { // check current avaliable source
            NSString *hexColor = [UIColor hexOFColor:currentCalendar.CGColor];
            [self.localCalendarHash setObject:currentCalendar forKey:[NSString stringWithFormat:@"%@%@",currentCalendar.title, hexColor]]; // key is calendar name, value is calendar object
        }
    }
}
/*!
 @brief Get reminder list and event counts from reminder log file saved in given URL.
 
 This method will return an array contains two NSNumber objects represents the list count and event count. Array always be valid, and default value is [0,0].
 @note This is private method. There is no public API for this method. Use @code + getTotalReminderCountForSpecificFile: @endcode instead.
 @param fileName The URL for saving reminder log file.
 @return NSArray object contains count of reminder list and reminder events.
 */
+ (NSArray *)_getReminderCountInFile:(NSString *)fileName {
    
    if (fileName.length == 0) {
        return 0;
    }
    
    NSData *reminderdata = [[NSFileManager defaultManager] contentsAtPath:fileName];
    NSError* error = nil;
    
    NSMutableArray *result = [[NSMutableArray alloc] initWithObjects:[NSNumber numberWithInteger:0], [NSNumber numberWithInteger:0],nil]; // Default is [0,0].
    // Get reminder event number & reminder list number
    NSInteger totalReminderEventCount = 0;
    NSInteger totalReminderListCount  = 0;
    if (reminderdata.length > 0) {
        NSArray *reminderList = (NSArray *)[NSJSONSerialization JSONObjectWithData:reminderdata
                                                                           options:kNilOptions
                                                                             error:&error];
        totalReminderListCount = reminderList.count;
        // Loop for each of reminder list.
        for (NSDictionary *reminderItem in reminderList) {
            @autoreleasepool {
                totalReminderEventCount += ((NSArray *)[reminderItem objectForKey:@"reminder"]).count;
            }
        }
    }
    
    // Build result array.
    result[0] = [NSNumber numberWithInteger:totalReminderListCount];
    result[1] = [NSNumber numberWithInteger:totalReminderEventCount];
    
    return result;
}
/*!
 @brief Try to find reminder source. If there is cloud souce, return cloud, otherwise return local source.
 @return EKSource object for saving reminders.
 */
- (EKSource *)findCloudSource {
    EKSource *localSource = nil;
    for (EKSource *source in self.eventManager.eventStore.sources) {
        if (source.sourceType == EKSourceTypeCalDAV && [source.title isEqualToString:@"iCloud"]) {
            return source;
        } else if (source.sourceType == EKSourceTypeLocal) {
            localSource = source;
        }
    }
    
    return localSource;
}
/*!
 Add reminders from given list into specific reminder list. 
 
 This method will check each of the record existance in current device and maintains the duplicate list.
 @param reminders NSArray contains all the reminder events.
 @param currentCalendar The reminder list need to push the events into.
 */
- (void)addReminders:(NSArray *)reminders ToList:(EKCalendar *)currentCalendar {
    
    BOOL hasNewEventComes = NO; // never set to NO, only change to YES
    
    for (NSDictionary *reminderInfo in reminders) {
        @autoreleasepool {
            NSString *key = [reminderInfo objectForKey:@"REMINDERID"];
            NSString *localIdentifier = [self.localDuplicateList objectForKey:key];
            if (localIdentifier) { // exist, need to check item really exist or not.
                if ([self.eventManager.eventStore calendarItemWithIdentifier:localIdentifier]) {
                    NSLog(@"duplicate!! reminder item already exists");
                    self.updateHandler(++self.reminderSavedCount, self.totalReminderCount);
                    continue;
                } else {
                    [self.localDuplicateList removeObjectForKey:[reminderInfo objectForKey:@"REMINDERID"]];
                }
            }
            
            hasNewEventComes = YES;
            
            CTReminder *reminder = [CTReminder reminderWithEventStore:self.eventManager.eventStore forCalendar:currentCalendar detail:reminderInfo];
            
            NSError *error = nil;
            if ([self.eventManager.eventStore saveReminder:reminder.reminderObject commit:NO error:&error]) {
                [self.localDuplicateList setObject:reminder.reminderObject.calendarItemIdentifier forKey:reminder.reminderItemIdentifier];
            } else {
                NSLog(@"shit! saved failed! Error:%@", error.localizedDescription);
            }
            
            self.updateHandler(++self.reminderSavedCount, self.totalReminderCount);
        }
    }
    
    if (hasNewEventComes) {
        NSError *error = nil;
        [self.eventManager.eventStore commit:&error];
        
        if (error) {
            DebugLog(@"unable to Reminder!: Error= %@", error);
        }
    }
}

#pragma mark - Class methods
+ (NSArray *)getTotalReminderCountForSpecificFile:(NSString *)reminderURL {
    return [VZRemindersImport _getReminderCountInFile:reminderURL];
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

#pragma mark - Instance methods
- (void)importAllReminder:(BOOL)hasTotalCount {
    // Clear up
    self.totalReminderCount     = 0;
    self.reminderListSavedCount = 0;
    self.reminderSavedCount     = 0;
    // Get reminder data from list.
    NSString *fileName = [[NSString appRootDocumentDirectory] stringByAppendingPathComponent:@"reminderLogFile.txt"];
    NSData *reminderdata = [[NSFileManager defaultManager] contentsAtPath:fileName];
    
    NSError* error = nil;
    if (reminderdata.length > 0) {
        NSArray *reminderLists = (NSArray *)[NSJSONSerialization JSONObjectWithData:reminderdata options:kNilOptions error:&error];

        // Loop to get total events count for all reminders.
        if (!hasTotalCount) {
            for (NSDictionary *reminderList in reminderLists) {
                @autoreleasepool {
                    self.totalReminderCount += ((NSArray *)[reminderList objectForKey:@"reminder"]).count;
                }
            }
        }
        NSLog(@"Total reminder event count: %ld", (long)self.totalReminderCount);
        self.updateHandler(0, self.totalReminderCount);
        
        // Start saving loop
        for (NSDictionary *reminderList in reminderLists) {
            
            if (reminderList.count == 0 || ((NSArray *)[reminderList objectForKey:@"reminder"]).count == 0) {
                // empty reminder dic in the list or empty list, just ignore.
                continue;
            }
            
            EKCalendar *calendar = nil;
            
            NSString *listTitle = (NSString *)[reminderList valueForKey:@"reminderName"];
            if ([self.localCalendarHash objectForKey:[NSString stringWithFormat:@"%@%@", listTitle, [reminderList valueForKey:@"REMINDERLISTCOLOR"]]]) {
                // Already exists, should use the old one
                calendar = (EKCalendar *)[self.localCalendarHash objectForKey:[NSString stringWithFormat:@"%@%@", listTitle, [reminderList valueForKey:@"REMINDERLISTCOLOR"]]];
            } else { // Create a new one
                calendar = [EKCalendar calendarForEntityType:EKEntityTypeReminder eventStore:self.eventManager.eventStore];
                // Give string the ics filename
                calendar.title = listTitle;
                // Get color from HEX string.
                UIColor *tempcolor = [UIColor colorFromHexString:[reminderList valueForKey:@"REMINDERLISTCOLOR"]];
                calendar.CGColor = tempcolor.CGColor;
                
                if (!self.eventManager.eventStore.defaultCalendarForNewReminders.source) { // reproducible after Reset Content and Settings
                    calendar.source = [self findCloudSource];
                } else {
                    calendar.source = self.eventManager.eventStore.defaultCalendarForNewReminders.source; // default one
                }
                
                NSError *error;
                if (![self.eventManager.eventStore saveCalendar:calendar commit:YES error:&error]) {
                    NSLog(@"shit! failed? Error:%@", error.localizedDescription);
                    
                    // Update counts
                    self.reminderSavedCount += ((NSArray *)[reminderList objectForKey:@"reminder"]).count;
                    
                    self.updateHandler(self.reminderSavedCount, self.totalReminderCount); // Update event number, otherwise it's very hard to update the progress bar.
                    continue;
                }
                
                // Update hash table
                [self.localCalendarHash setObject:calendar forKey:[NSString stringWithFormat:@"%@%@", listTitle, [reminderList valueForKey:@"REMINDERLISTCOLOR"]]];
            }
            
            [self addReminders:(NSArray *)[reminderList objectForKey:@"reminder"] ToList:calendar];
            
            self.reminderListSavedCount += 1;
        }
        
        [[CTDuplicateLists uniqueList] replaceReminderDuplicateList:_localDuplicateList];
        self.completionHandler(self.reminderSavedCount, self.totalReminderCount, self.reminderListSavedCount);
        
    }
    else
    {
        self.completionHandler(self.reminderSavedCount, self.totalReminderCount, self.reminderListSavedCount); // values will be 0,0,0
    }
}

@end
