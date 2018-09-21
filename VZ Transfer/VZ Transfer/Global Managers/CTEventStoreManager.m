//
//  CTEventStoreManager.m
//  contenttransfer
//
//  Created by Guntupalli, Neelima on 8/25/16.
//  Copyright © 2016 Verizon. All rights reserved.
//

#import "CTEventStoreManager.h"
#import "CTRemindersExport.h"
#import "CTCalendarExport.h"

@implementation CTEventStoreManager

+ (CTAuthorizationStatus)calendarAuthorizationStatus {
    if([EKEventStore authorizationStatusForEntityType:EKEntityTypeEvent] == EKAuthorizationStatusAuthorized) {
        return CTAuthorizationStatusAuthorized;
    } else if([EKEventStore authorizationStatusForEntityType:EKEntityTypeEvent] == EKAuthorizationStatusDenied || [EKEventStore authorizationStatusForEntityType:EKEntityTypeEvent] == EKAuthorizationStatusRestricted) {
        return CTAuthorizationStatusDenied;
    } else {
        return CTAuthorizationNotDetermined;
    }
}

+ (CTAuthorizationStatus)reminderAuthorizationStatus{
    if([EKEventStore authorizationStatusForEntityType:EKEntityTypeReminder] == EKAuthorizationStatusAuthorized) {
        return CTAuthorizationStatusAuthorized;
    } else if([EKEventStore authorizationStatusForEntityType:EKEntityTypeEvent] == EKAuthorizationStatusDenied || [EKEventStore authorizationStatusForEntityType:EKEntityTypeEvent] == EKAuthorizationStatusRestricted) {
        return CTAuthorizationStatusDenied;
    } else {
        return CTAuthorizationNotDetermined;
    }
}

+ (void)requestCalendarAuthorisation:(void(^)(CTAuthorizationStatus status))completionBlock {
    
    [[self eventStoreInstance] requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError * _Nullable error) {
        if(granted){
            completionBlock(CTAuthorizationStatusAuthorized);
        }else{
            completionBlock(CTAuthorizationStatusDenied);
        }
    }];
}

+ (void)requestReminderAuthorisation:(void(^)(CTAuthorizationStatus status))completionBlock {
    //EKEventStore *eventStore = [[EKEventStore alloc]init];
    [[self eventStoreInstance] requestAccessToEntityType:EKEntityTypeReminder completion:^(BOOL granted, NSError * _Nullable error) {
        if(granted){
            completionBlock(CTAuthorizationStatusAuthorized);
        }else{
            
            completionBlock(CTAuthorizationStatusDenied);
        }
    }];
}

+ (EKEventStore*)eventStoreInstance {
    
    static EKEventStore *eventStore ;
    if (eventStore) {
        return eventStore;
    }
    eventStore = [[EKEventStore alloc]init];
    return eventStore;
    
}

+ (void)fetchReminders:(void(^)(NSInteger countOfReminders,float lengthOfData))completionBlock failureBlock:(void(^)(NSError *err))failureBlock {
    
    CTRemindersExport *exportReminders = [CTRemindersExport remindersExport];
    [exportReminders fetchReminders:completionBlock failureBlock:failureBlock];
    
}

+ (void)fetchCalendars:(void(^)(NSInteger countOfCalendars,float lengthOfData))completionBlock failureBlock:(void(^)(NSError *err))failureBlock updateBlock:(void(^)(NSInteger countOfCalendars))updateBlock {
    
    CTCalendarExport *exportCalendars = [CTCalendarExport calendarsExport];
    [exportCalendars fetchCalendars:completionBlock failureBlock:failureBlock updateBlock:updateBlock];
    
}

@end
