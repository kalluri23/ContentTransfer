//
//  EKEventManager.h
//  remindersApp
//
//  Created by Tourani, Sanjay on 3/29/16.
//  Copyright © 2016 Tourani, Sanjay. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <EventKit/EventKit.h>

/*!
 @brief Event manager object for content transfer. 
 
 This is singleton class, to make sure all the events in content transfer will use same EKEventStore library.
 */
@interface VZEventManager : NSObject
/*! EKEventStore using for whole content transfer app for calendars and reminders.*/
@property (nonatomic, strong) EKEventStore *eventStore;

/*!
 @brief Event manager singleton initializer. A EKEventStore object will be init inside this method.
 @return VZEventManager object.
 */
+ (instancetype)sharedEvent;

@end
