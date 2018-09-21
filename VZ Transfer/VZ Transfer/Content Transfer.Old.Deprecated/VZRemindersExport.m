//
//  VZRemindersImport.m
//  myverizon
//
//  Created by Tourani, Sanjay on 4/4/16.
//  Copyright © 2016 Verizon Wireless. All rights reserved.
//

#import "VZRemindersExport.h"
#import "VZContentTrasnferConstant.h"
#import "NSString+CTContentTransferRootDocuments.h"

@implementation VZRemindersExport

@synthesize eventManager;
@synthesize reminders;
@synthesize reminderCount;
@synthesize remindercallBackHandler;
@synthesize totalNumberOfReminder;

- (NSMutableArray *)reminderLists {
    if (!_reminderLists) {
        _reminderLists = [[NSMutableArray alloc] init];
    }
    
    return _reminderLists;
}

- (id) init {
    if (self = [super init]) {
        eventManager = [VZEventManager sharedEvent];
        
    }
    
    return self;
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
        }
            
            break;
    }
}

- (void)fetchLocalReminderLists:(remindercompletionHandler)reminderComplete {
    
    [eventManager.eventStore reset];
    NSArray *allReminderLists = [eventManager.eventStore calendarsForEntityType:EKEntityTypeReminder];

//    DebugLog(@"All reminder lists: %@",allReminderLists);
    
    self.reminderCount = (int)[allReminderLists count];
    
    if (self.reminderCount == 0) {
        reminderComplete(0);
        
        return;
    }
    
    __block int reminderCalCount = 0;
    for (EKCalendar *tempCal in allReminderLists) {
        DebugLog(@"type:%ld", (long)tempCal.type);
        @autoreleasepool {
            [self fetchRemindersForList:tempCal reminderListName:tempCal.title completion:^{
                if (++reminderCalCount == self.reminderCount) {
                    
                    [self storeRimenderFile];
                    reminderComplete(self.totalNumberOfReminder);
                }
            }];
        }
    }
}

- (void) fetchRemindersForList:(EKCalendar *)calendar reminderListName:(NSString *)name completion:(void (^)(void))completion {
    
    NSPredicate *predicate = [self.eventManager.eventStore predicateForRemindersInCalendars:@[calendar]];
    [self.eventManager.eventStore fetchRemindersMatchingPredicate:predicate completion:^(NSArray *reminderslist) {
        DebugLog(@"reminders for %@ list: \n %@",calendar,reminderslist);

        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        
        [dict setObject:reminderslist forKey:@"reminder"];
        [dict setObject:name forKey:@"reminderName"];
        
        const CGFloat *components = CGColorGetComponents(calendar.CGColor);
        CGFloat r = components[0];
        CGFloat g = components[1];
        CGFloat b = components[2];
        NSString *hexString=[NSString stringWithFormat:@"%02X%02X%02X", (int)(r * 255), (int)(g * 255), (int)(b * 255)];
        DebugLog(@"%@", hexString);
        [dict setObject:hexString forKey:@"REMINDERLISTCOLOR"];
        
        [self.reminderLists addObject:dict];
        
        self.totalNumberOfReminder = self.totalNumberOfReminder + (int)reminderslist.count;
        
//        if (self.reminderLists.count == self.reminderCount ) {
//            [self storeRimenderFile];
//        }
        remindercallBackHandler(self.totalNumberOfReminder);
        
        completion(); // finished
    }];
}

- (void)storeRimenderFile {
    
    NSMutableArray *finalRimender = [[NSMutableArray alloc] init];
    
    for (NSMutableDictionary *dict in self.reminderLists) {
        
        NSArray *list = [dict valueForKey:@"reminder"];
        
        NSMutableArray *reminderEventList = [[NSMutableArray alloc] init];
        
        for (EKReminder *reminderEvent in list) {
            
            NSMutableDictionary *event = [[NSMutableDictionary alloc] init];
            
            if (reminderEvent.title.length > 0 ) {
                [event setObject:reminderEvent.title forKey:@"TITLE"];
            }
            
//            if (reminderEvent.dueDateComponents != NULL ) {
//                [event setObject:reminderEvent.dueDateComponents forKey:@"DUEDATE"];
//            }
            
            if (reminderEvent.completionDate != NULL ) {
                
                [event setObject:[self stringWithDate:reminderEvent.completionDate] forKey:@"COMPLETIONDATE"];
            }
            
            [event setObject:[NSString stringWithFormat:@"%d",(int)reminderEvent.priority] forKey:@"PRIORITY"];
            
            if (reminderEvent.notes.length > 0 ) {
                [event setObject:reminderEvent.notes forKey:@"NOTES"];
            }
            
            if (reminderEvent.location.length > 0 ) {
                [event setObject:reminderEvent.location forKey:@"LOCATION"];
            }
            
            if (reminderEvent.completed) {
                [event setObject:@"YES" forKey:@"COMPLETED"];
            }else {
                [event setObject:@"NO" forKey:@"COMPLETED"];
            }
            
            [reminderEventList addObject:event];
        }
        
        [dict setObject:reminderEventList forKey:@"reminder"];
        
        [finalRimender addObject:dict];
    }
    
    NSData *CalenderData = nil;
    @try {
         CalenderData = [NSJSONSerialization dataWithJSONObject:finalRimender options:NSJSONWritingPrettyPrinted error:nil];
    } @catch (NSException *exception) {
        DebugLog(@"Json Exception:%@", CalenderData.description);
    }
    
    if (CalenderData != nil) {
        NSUserDefaults *userdefault = [NSUserDefaults standardUserDefaults];
        
        [userdefault setObject:[NSString stringWithFormat:@"%ld",CalenderData.length] forKey:@"REMINDERLOGSIZE"];
        
        [userdefault synchronize];
        
        NSFileManager *fileManager;
        
        fileManager = [NSFileManager defaultManager];
        
        NSString *docPath = [[NSString appRootDocumentDirectory] stringByAppendingPathComponent:@"Reminder"];
        
        // Remove old files
        if ([[NSFileManager defaultManager] fileExistsAtPath:docPath]) {
            [[NSFileManager defaultManager] removeItemAtPath:docPath error:nil];
        }
        
        NSError *error = nil;
        // create new folder
        [[NSFileManager defaultManager] createDirectoryAtPath:docPath withIntermediateDirectories:YES attributes:nil error:&error];
        
        
        [fileManager createFileAtPath:[docPath stringByAppendingPathComponent:@"ReminderLogoFile.txt"] contents:CalenderData attributes: nil];
    } else {
        // If something wrong happend when fetching the reminders, reset number to 0, not allow user to send it instead of crash the app.
        self.totalNumberOfReminder = 0;
    }
}

- (NSString *)stringWithDate:(NSDate *)date
{
    return [NSDateFormatter localizedStringFromDate:date
                                          dateStyle:NSDateFormatterFullStyle
                                          timeStyle:NSDateFormatterFullStyle];
}


@end
