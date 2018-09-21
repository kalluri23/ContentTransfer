//
//  VZEventsImport.h
//  myverizon
//
//  Created by Tourani, Sanjay on 4/6/16.
//  Copyright © 2016 Verizon Wireless. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VZEventManager.h"
#import "CTMVMAlertAction.h"
#import "CTMVMAlertObject.h"
#import "CTMVMAlertHandler.h"
#import "EKEvent+Utilities.h"

typedef void (^successHandler)(void);
typedef void (^failureHandler)(EKAuthorizationStatus status);

typedef void (^fetchSuccessHandler)(NSInteger numberOfEvents);
typedef void (^fetchFailureHandler)(NSError *err);

@protocol CalendarUpdateUIDelegate <NSObject>

@optional
- (void)shouldUpdateCalendarNumber:(NSInteger)number;

@end

@interface VZCalenderEventsExport : NSObject

@property (weak, nonatomic) id<CalendarUpdateUIDelegate> delegate;

@property (nonatomic,strong) VZEventManager *eventManager;
@property (nonatomic) BOOL isAccessToEventStoreGranted;
@property (copy, nonatomic) NSArray *events;
@property (nonatomic,strong)NSMutableArray *calenderList;
@property (nonatomic, assign) NSInteger numberOfEvents;

- (void)fetchLocalCalendarsWithSuccessHandler:(fetchSuccessHandler)success andFailureHandler:(fetchFailureHandler)failure;

- (void)checkAuthorizationStatusToAccessEventStoreSuccess:(successHandler)success andFailureHandler:(failureHandler)failure;

- (NSString *)getEventURL:(NSString *)hashKey;

@end
