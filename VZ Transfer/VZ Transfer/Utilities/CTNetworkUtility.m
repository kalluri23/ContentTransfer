//
//  CTNetworkUtility.m
//  contenttransfer
//
//  Created by Development on 8/15/16.
//  Copyright © 2016 Verizon. All rights reserved.
//

#import "CTNetworkUtility.h"
#import "CTMVMReachability.h"

#import <ifaddrs.h>
#import <net/if.h>
#import <SystemConfiguration/CaptiveNetwork.h>

@implementation CTNetworkUtility
#pragma mark - Static properties
static NSString *ssidKey = @"SSID";

#pragma mark - Public class methods
+ (NSString *)connectedNetworkName {
    NSDictionary *ssidInfo = [self fetchSSIDInfo];
    if (ssidInfo) {
        return [ssidInfo valueForKey:ssidKey];
    } else {
        return nil;
    }
}

+ (NSDictionary *)fetchSSIDInfo {
    NSArray *interfaceNames = CFBridgingRelease(CNCopySupportedInterfaces());
    DebugLog(@"%s: Supported interfaces: %@", __func__, interfaceNames);

    NSDictionary *SSIDInfo;
    for (NSString *interfaceName in interfaceNames) {
        SSIDInfo = CFBridgingRelease(CNCopyCurrentNetworkInfo((__bridge CFStringRef)interfaceName));
        DebugLog(@"%s: %@ => %@", __func__, interfaceName, SSIDInfo);
        BOOL isNotEmpty = (SSIDInfo.count > 0);
        if (isNotEmpty) {
            break;
        }
    }
    return SSIDInfo;
}

+ (BOOL)isConnectedToWifi {
    if ([[CTMVMReachability reachabilityForInternetConnection] currentReachabilityStatus] == ReachableViaWiFi) {
        return YES;
    }

    return NO;
}

+ (BOOL)isWiFiEnabled {
    NSCountedSet * cset = [NSCountedSet new];
    struct ifaddrs *interfaces;
    if(!getifaddrs(&interfaces)) {
        for( struct ifaddrs *interface = interfaces; interface; interface = interface->ifa_next) {
            if ((interface->ifa_flags & IFF_UP) == IFF_UP) {
                [cset addObject:[NSString stringWithUTF8String:interface->ifa_name]];
            }
        }
    }
    
    BOOL result = [cset countForObject:@"awdl0"] > 1 ? YES : NO;
    freeifaddrs (interfaces);
    
    return result;
}

+ (BOOL)isConnectedToHotSpotAccessPoint {
    NSString *ssidName = [self connectedNetworkName];
    return [self _isHotSpotNetwork:ssidName];
}

+ (BOOL)isConnectedToHotSpotAccessPoint:(NSString *)ssid {
    return [self _isHotSpotNetwork:ssid];
}

#pragma mark - Convenients
+ (BOOL)_isHotSpotNetwork:(NSString *)ssidName {
    if (ssidName.length > 6) {
        NSString *chkStr = [ssidName substringWithRange:NSMakeRange(0, 6)];
        if ([chkStr isEqualToString:@"DIRECT"]) { // Andriod hotspot Always start with "DIRECT" word
            return TRUE;
        }
    }
    return FALSE;
}

@end
