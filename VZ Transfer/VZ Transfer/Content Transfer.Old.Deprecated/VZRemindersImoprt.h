//
//  VZRemindersExport.h
//  myverizon
//
//  Created by Tourani, Sanjay on 4/5/16.
//  Copyright © 2016 Verizon Wireless. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <EventKit/EventKit.h>
#import "VZEventManager.h"
#import "CTMVMAlertAction.h"
#import "CTMVMAlertObject.h"
#import "CTMVMAlertHandler.h"

typedef void (^successHandler)(void);
typedef void (^failureHandler)(EKAuthorizationStatus status);

typedef void (^importCompletionBlock)(NSInteger);

@interface VZRemindersImoprt : NSObject

@property (nonatomic,strong) VZEventManager *eventManager;
@property (nonatomic) BOOL isAccessToEventStoreGranted;
@property (nonatomic, copy) importCompletionBlock completionHandler;
@property (nonatomic, copy) importCompletionBlock updateHandler;
@property (nonatomic,assign)int totalnumberOfReminder;


+ (void)updateAuthorizationStatusToAccessEventStoreSuccess:(successHandler)success failed:(failureHandler)failure;

- (void)addReminders:(NSArray *)reminders ToList:(EKCalendar *)remindersList;
- (void)createListFrom:(NSArray *)reminderLists;
- (void)importAllReminder;

- (NSInteger)getTotalReminderCount;
+ (NSInteger)getTotalReminderCountForSpecificFile:(NSString *)reminderURL;
@end
