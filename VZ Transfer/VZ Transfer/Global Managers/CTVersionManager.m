//
//  CTVersionManager.m
//  contenttransfer
//
//  Created by Hadapad, Prakash on 6/30/16.
//  Copyright © 2016 Hadapad, Prakash. All rights reserved.
//

#import "CTVersionManager.h"
#import "CTContentTransferSetting.h"
#import "CTUserDevice.h"
#import "NSString+CTMVMConvenience.h"

NS_ENUM(NSInteger, CTVersionResult) {
    CTVersionResultLess    = -1,
    CTVersionResultEqual   =  0,
    CTVersionResultGreater =  1
};

@implementation CTVersionManager

//@synthesize build_flag;
@synthesize supported_version;

#pragma mark - Initializer
- (id)init {
    self = [super init];
    if (self) {
        //_versionChecked = NO; // Version check not done
    }
    
    return self;
}

- (CTVersionCheckStatus)identifyOsVersion:(NSString*)str {
    
    str = [str formatRequestForXPlatform];
    
    DebugLog(@"Data received %@",str);
    
    if (str.length > 0) {
        
        NSRange range = [str rangeOfString:@"AND"];
        
        CTVersionCheckStatus status = CTVersionCheckStatusLesser;
        
        @try {
            if (range.location != NSNotFound) {
                // os is Andriod
                status = [self validiateAndriodBuildVersion:str];
            } else {
                // os is iOS
                status = [self validiateAndriodBuildVersion:str];
            }
        } @catch (NSException *exception) {
            NSLog(@"Error happened when check version:%@", exception.description);
        }
        
        return status;
    }
    
}

- (CTVersionCheckStatus)validiateAndriodBuildVersion:(NSString*)str {

    @try {
        NSString *receviedMsg = [str substringFromIndex:39];
        int meetsCrossMin = 0;
        NSArray *receviedBuildVersion = [receviedMsg componentsSeparatedByString:@"#"];
        
        NSArray *receivedMinbuildVersion = [(NSString *)[receviedBuildVersion objectAtIndex:1] componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"."]];
        
        meetsCrossMin = [self checkCrossPlatformMinVerison:receivedMinbuildVersion];
        
        if ([[CTUserDevice userDevice].deviceType isEqualToString:OLD_DEVICE]) {
            NSString *freespace = [receviedBuildVersion objectAtIndex:2];
            freespace = [freespace stringByReplacingOccurrencesOfString:@"space" withString:@""];
            [CTUserDevice userDevice].maxSpaceAvaiableForTransfer = freespace;
        }

        
        if (meetsCrossMin < 1) {
            // Checking Between same platform
            NSArray *receivedCurrentbuildVersion = [(NSString *)[receviedBuildVersion objectAtIndex:0] componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"."]];
            
            NSString *minimumVerison = nil;
            if ([[CTUserDevice userDevice].phoneCombination isEqualToString:IOS_IOS]) {
                minimumVerison = BUILD_SAME_PLATFORM_MIN_VERSION;
            } else {
                minimumVerison = BUILD_CROSS_PLATFROM_MIN_VERSION;
            }
            
            int currentReceivemajorNumber = [[receivedCurrentbuildVersion objectAtIndex:0] intValue];
            int currentReceiveMinorNumber = [[receivedCurrentbuildVersion objectAtIndex:1] intValue];
            int currentReceiveReleaseNumber = [[receivedCurrentbuildVersion objectAtIndex:2] intValue];
            
            NSArray *currentMinbuildVersion = [minimumVerison componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"."]];
            
            int minCurrentmajorNumber = [[currentMinbuildVersion objectAtIndex:0] intValue];
            int minCurrentMinorNumber = [[currentMinbuildVersion objectAtIndex:1] intValue];
            int minCurrentReleaseNumber = [[currentMinbuildVersion objectAtIndex:2] intValue];
            
            DebugLog(@"Received Build is %@ and Build version is %@",BUILD_CROSS_PLATFROM_MIN_VERSION,receivedCurrentbuildVersion);
            
            if (minCurrentmajorNumber > currentReceivemajorNumber) {
                supported_version = minimumVerison;
                return CTVersionCheckStatusLesser;
            } else if (minCurrentmajorNumber < currentReceivemajorNumber) {
                return CTVersionCheckStatusMatched;
            }
            
            if (minCurrentMinorNumber > currentReceiveMinorNumber) {
                supported_version = minimumVerison;
                return CTVersionCheckStatusLesser;
            } else if (minCurrentMinorNumber < currentReceiveMinorNumber) {
                return CTVersionCheckStatusMatched;
            }
            
            if (minCurrentReleaseNumber > currentReceiveReleaseNumber) {
                supported_version = minimumVerison;
                return CTVersionCheckStatusLesser;
            } else {
                return CTVersionCheckStatusMatched;
            }
        }
        
        NSString *stringWithoutSpaces = [[receviedBuildVersion objectAtIndex:1] stringByReplacingOccurrencesOfString:@"\r\n" withString:@""];
        
        supported_version = [NSString stringWithFormat:@"%@ or higher",stringWithoutSpaces];
        
        return CTVersionCheckStatusGreater;
        
    } @catch (NSException *exception) {
        return CTVersionCheckStatusLesser;
    }
}

- (int)checkCrossPlatformMinVerison:(NSArray *)arr  {
    
    int majorANDMinVer = [[arr objectAtIndex:0] intValue];
    int minorANDMinVer = [[arr objectAtIndex:1] intValue];
    int buildANDMinVer  = [[arr objectAtIndex:2] intValue];
    
    NSString *currentbuild = BUILD_VERSION;
    
    NSArray *currentbuildVersion = [currentbuild componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"."]];
    
    int localIOSMajorVer = [[currentbuildVersion objectAtIndex:0] intValue];
    int localIOSMinorVer = [[currentbuildVersion objectAtIndex:1] intValue];
    int localIOSBuildVer  = [[currentbuildVersion objectAtIndex:2] intValue];
    
    int status ;
    
    if (majorANDMinVer == localIOSMajorVer) {
        if (minorANDMinVer == localIOSMinorVer) {
            if (buildANDMinVer == localIOSBuildVer) {
                status = 0;
            } else {
                status = [self isLower:buildANDMinVer localVer:localIOSBuildVer];
            }
        } else {
            status = [self isLower:minorANDMinVer localVer:localIOSMinorVer];
        }
    } else {
        status = [self isLower:majorANDMinVer localVer:localIOSMajorVer];
    }
    
    return status;
}

// find out max to two number
- (int)isLower:(int) buildANDVer localVer:(int)localIOSBuildVer {
    if (buildANDVer < localIOSBuildVer) {
        return -1; // BUILD_VERSION_IS_GREATER IOS need to upgrade
    } else {
        return 1; // BUILD_VERSION_IS_LESS
    }
}

@end
