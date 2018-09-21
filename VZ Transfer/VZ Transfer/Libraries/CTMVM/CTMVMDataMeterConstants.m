//
//  DataMeterConstants.m
//  dataMeter
//
//  Created by Razzano, Neil Thomas on 6/27/14.
//  Copyright (c) 2014 Neil. All rights reserved.
//

#import "CTMVMDataMeterConstants.h"

// NM = notification manager
// DM = datameter

NSString * const NMDeviceTokenRegisterSuccess = @"NMDeviceTokenRegisterSuccess";
NSString * const NMDeviceTokenRegisterFailure = @"NMDeviceTokenRegisterFailure";
NSString * const NMRegisteredNotificationSettings = @"NMRegisteredNotificationSettings";

NSString * const NMReceivedLocalNotification = @"NMReceivedLocalNotification";
NSString * const NMReceivedLocalNotificationWithChosenAction = @"NMReceivedLocalNotificationWithChosenAction";
NSString * const NMRecievedRemoteNotification = @"NMRecievedRemoteNotification";
NSString * const NMRecievedRemoteNotificationWithBackgroundTask = @"NMRecievedRemoteNotificationWithBackgroundTask";
NSString * const NMRecievedRemoteNotificationWithChosenAction = @"NMRecievedRemoteNotificationWithChosenAction";

// Delay before trigger a local notification (in seconds)
NSUInteger const LocalNotificationDelay = 90;

NSString * const NMSawUsageUpdatedInBackground = @"DMSawUsageUpdatedInBackground";

NSString * const DMPlanTypeUnlimited = @"UNLMTD";
NSString * const DMPlanTypeNCC = @"NCC";
NSString * const DMPlanTypePerUse = @"PER USE";
NSString * const DMPlanTypeShared = @"Shared Data";
NSString * const DMPlanTypePrePay = @"PREPAYLL";
NSString * const DMPlanTypeIndividual = @"Line Usage";
NSString * const DMPlanTypeUnknown = @"Unknown";
NSString * const DMPlanTypeMyGigs = @"My Gigs";

NSString * const CTApplicationWillResignActive = @"CTApplicationWillResignActive";
NSString * const CTApplicationDidBecomeActive = @"CTApplicationDidBecomeActive";
NSString * const CTApplicationWillTerminate = @"CTApplicationWillTerminate";


// MVM Push Flags.
NSString * const PUSH_FLAG_KEY = @"mvmRegisterAck";

// Data Meter Flags
NSString * const DATA_METER_REGISTERED_KEY = @"dmRegisterAck";

// Flag Values
NSString * const FLAG_REGISTERED = @"Y";
NSString * const FLAG_NEEDS_TO_REGISTER = @"N";
NSString * const FLAG_REJECTED = @"R";
NSString * const FLAG_FAILED = @"F";

// key for homing to one datacenter
NSString * const DATA_METER_STATUS_CODE_KEY = @"errorCode";

// Key for the authentication hash
NSString * const AUTH_HASH = @"hashToken";

// key for homing to one datacenter
NSString * const DATA_METER_HOME = @"home";

// The shared group name. For Shared Group Storage.
NSString * const DATA_METER_SUITE_NAME = @"group.vzw.datameter";
NSString * const DATA_METER_ENTERPRISE_SUITE_NAME = @"group.vzw.enterprise.dataMeter";

// Times used for polling and deregistering
NSString * const DM_SHORT_POLL_TIME = @"dmShortPollTime";
NSString * const DM_LONG_POLL_TIME = @"dmLongPollTime";
NSString * const DM_WIDGET_REMOVAL_TIME = @"dmWidgetRemovalTime";

// Keys for Watch
NSString * const WATCH_UPDATE_REQUEST = @"sendWatchData";
NSString * const WATCH_INIT_REQUEST = @"sendWatchInitDataMeter";