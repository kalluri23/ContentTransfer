//
//  CTCheckAppStatus.m
//  contenttransfer
//
//  Created by Hadapad, Prakash on 9/2/16.
//  Copyright © 2016 Hadapad, Prakash. All rights reserved.
//
#import <ifaddrs.h>
#import <arpa/inet.h>
#import <CoreBluetooth/CoreBluetooth.h>
#if STANDALONE == 0
#import <contentTransferFramework/contenttransfer-Swift.h>
#endif

#import "CTDeviceStatusUtility.h"

#import "NSString+CTRootDocument.h"

@import SystemConfiguration.CaptiveNetwork;

@implementation CTDeviceStatusUtility

+ (BOOL)isLowBattery {
    
    [[UIDevice currentDevice] setBatteryMonitoringEnabled:NO]; // DON'T ASK ME WHY
    [[UIDevice currentDevice] setBatteryMonitoringEnabled:YES];
    
    if ([[UIDevice currentDevice] batteryState] == UIDeviceBatteryStateUnplugged) {
        // If not plugged check battery
        float percentage = [[UIDevice currentDevice] batteryLevel];
        
        if (percentage <= 0.25f) {
            
            return YES;
        }else {
            return NO;
        }
    } else {
        return NO;
    }
}

+ (NSString *)findIPSeries {

    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;

    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);

    if (success == 0) {
        temp_addr = interfaces;

        while (temp_addr != NULL) {
            // check if interface is en0 which is the wifi connection on the iPhone
            if (temp_addr->ifa_addr->sa_family == AF_INET) {
                if ([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    NSString *ipAddress = [NSString
                        stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                    DebugLog(@"IP address is %@",ipAddress);

                    return ipAddress;
                }
            }

            temp_addr = temp_addr->ifa_next;
        }
    }

    freeifaddrs(interfaces);
    return @"";
}

+ (NSString *)getHotSpotIpAddress {
    
    NSString *ipAdr = [self findIPSeries];
    
    NSMutableArray *listItems = (NSMutableArray *)[ipAdr componentsSeparatedByString:@"."];
    
    if ([listItems count] > 2) {
        [listItems replaceObjectAtIndex:3 withObject:@"1"];
    }
    
    NSString *hotSpotAddress = [listItems componentsJoinedByString:@"."];
    
    return hotSpotAddress;
}

+ (long long)getFreeDiskSpace {
    long long totalSpace = 0;
    long long totalFreeSpace = 0;
    NSError *error = nil;
    NSString *basePath = [NSString appRootDocumentDirectory];
    NSDictionary *dictionary = [[NSFileManager defaultManager]
                                attributesOfFileSystemForPath:basePath
                                error:&error];
    
    if (dictionary) {
        NSNumber *fileSystemSizeInBytes =
        [dictionary objectForKey:NSFileSystemSize];
        NSNumber *freeFileSystemSizeInBytes =
        [dictionary objectForKey:NSFileSystemFreeSize];
        totalSpace = [fileSystemSizeInBytes unsignedLongLongValue];
        totalFreeSpace = [freeFileSystemSizeInBytes unsignedLongLongValue];
    } else {
        DebugLog(@"Error Obtaining System Memory Info: Domain = %@, Code = %ld",
                 [error domain], (long)[error code]);
    }
    
    return totalFreeSpace;
}

+ (double)getFreeDiskSpaceInMegaBytes {
    long long freeSpaceInBytes = [CTDeviceStatusUtility getFreeDiskSpace];
    return (double)(freeSpaceInBytes / (1024 * 1024));
}

+ (BOOL)isDeviceUsingSpanish {
    NSString *locale = [CTLocalizationHelper getDeviceLocalizedSetting];
    return [CTLocalizationHelper compareDeviceLocale:locale with:CTLocalizationHelper.ES];
}

@end
