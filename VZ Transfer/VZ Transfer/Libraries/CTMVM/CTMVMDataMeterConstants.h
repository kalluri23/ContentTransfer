//
//  DataMeterConstants.h
//  dataMeter
//
//  Created by Razzano, Neil Thomas on 6/27/14.
//  Copyright (c) 2014 Neil. All rights reserved.
//

#import <Foundation/Foundation.h>

FOUNDATION_EXTERN NSString * const NMDeviceTokenRegisterSuccess;
FOUNDATION_EXTERN NSString * const NMDeviceTokenRegisterFailure;
FOUNDATION_EXTERN NSString * const NMRegisteredNotificationSettings;

FOUNDATION_EXTERN NSString * const NMReceivedLocalNotification;
FOUNDATION_EXTERN NSString * const NMReceivedLocalNotificationWithChosenAction;
FOUNDATION_EXTERN NSString * const NMRecievedRemoteNotification;
FOUNDATION_EXTERN NSString * const NMRecievedRemoteNotificationWithBackgroundTask;
FOUNDATION_EXTERN NSString * const NMRecievedRemoteNotificationWithChosenAction;

FOUNDATION_EXTERN NSUInteger const LocalNotificationDelay;

FOUNDATION_EXTERN NSString * const NMSawUsageUpdatedInBackground;

FOUNDATION_EXPORT NSString * const DMPlanTypeUnlimited;
FOUNDATION_EXPORT NSString * const DMPlanTypeNCC;
FOUNDATION_EXPORT NSString * const DMPlanTypePerUse;
FOUNDATION_EXPORT NSString * const DMPlanTypeShared;
FOUNDATION_EXPORT NSString * const DMPlanTypePrePay;
FOUNDATION_EXPORT NSString * const DMPlanTypeIndividual;
FOUNDATION_EXPORT NSString * const DMPlanTypeUnknown;
FOUNDATION_EXPORT NSString * const DMPlanTypeMyGigs;

FOUNDATION_EXPORT NSString * const CTApplicationDidBecomeActive;
FOUNDATION_EXPORT NSString * const CTApplicationWillTerminate;
FOUNDATION_EXPORT NSString * const CTApplicationWillResignActive;

// MVM Push Flag.
FOUNDATION_EXPORT NSString * const PUSH_FLAG_KEY;

// Data Meter Flag
FOUNDATION_EXPORT NSString * const DATA_METER_REGISTERED_KEY;

// Flag Values
FOUNDATION_EXPORT NSString * const FLAG_REGISTERED;
FOUNDATION_EXPORT NSString * const FLAG_NEEDS_TO_REGISTER;
FOUNDATION_EXPORT NSString * const FLAG_REJECTED;
FOUNDATION_EXPORT NSString * const FLAG_FAILED;

// for checking for errors
FOUNDATION_EXPORT NSString * const DATA_METER_STATUS_CODE_KEY;

// Key for the authentication hash
FOUNDATION_EXPORT NSString * const AUTH_HASH;

// key for homing to one datacenter
FOUNDATION_EXPORT NSString * const DATA_METER_HOME;

// The shared group name. For Shared Group Storage.
FOUNDATION_EXPORT NSString * const DATA_METER_SUITE_NAME;
FOUNDATION_EXPORT NSString * const DATA_METER_ENTERPRISE_SUITE_NAME;

// Times used for polling and deregistering
FOUNDATION_EXPORT NSString * const DM_SHORT_POLL_TIME;
FOUNDATION_EXPORT NSString * const DM_LONG_POLL_TIME;
FOUNDATION_EXPORT NSString * const DM_WIDGET_REMOVAL_TIME;

// Keys for Watch
FOUNDATION_EXPORT NSString * const WATCH_UPDATE_REQUEST;
FOUNDATION_EXPORT NSString * const WATCH_INIT_REQUEST;
