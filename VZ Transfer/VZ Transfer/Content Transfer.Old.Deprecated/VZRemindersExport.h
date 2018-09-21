//
//  VZRemindersImport.h
//  myverizon
//
//  Created by Tourani, Sanjay on 4/4/16.
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

typedef void (^remindercompletionHandler)(int reminderCount);

@interface VZRemindersExport : NSObject

@property (nonatomic,strong) VZEventManager *eventManager;
@property (nonatomic) BOOL isAccessToEventStoreGranted;
@property (strong, nonatomic) NSMutableArray *reminderLists;
@property (strong, nonatomic) NSArray *reminders;
@property (nonatomic,assign) int reminderCount;
@property(nonatomic,copy) remindercompletionHandler remindercallBackHandler;
@property (nonatomic,assign) int totalNumberOfReminder;



+ (void)updateAuthorizationStatusToAccessEventStoreSuccess:(successHandler)success failed:(failureHandler)failure;

- (void)fetchLocalReminderLists:(remindercompletionHandler)reminderComplete;

@end
