//
//  CTDeviceMarco.m
//  contenttransfer
//
//  Created by Sun, Xin on 9/6/16.
//  Copyright © 2016 Hadapad, Prakash. All rights reserved.
//

#import "CTDeviceMarco.h"
#import <sys/utsname.h>

@implementation CTDeviceMarco

/*!
 Screen size type for simulator to show.
 
 Valid value will be @b 4, @b 5, @b 6, @b 10, represents iPhone 4, 5, 6, X series.
 @warning Invaid value will cause unexpected behavior for UI and functionality on simulator.
 @note If needed, add support for iPad seperatly from iPhone.
 */
static int SimulatorForiPhoneScreenType = 10;

- (NSDictionary *)models {
    if (_models == nil) {
        _models = @{
                    @"iPod1,1"   : @"iPod Touch",
                    @"iPod2,1"   : @"iPod Touch 2nd Generation",
                    @"iPod3,1"   : @"iPod Touch 3rd Generation",
                    @"iPod4,1"   : @"iPod Touch 4th Generation",
                    @"iPod5,1"   : @"iPod Touch 5th Generation",
                    @"iPod7,1"   : @"iPod Touch 6th Generation",
                    @"iPad1,1"   : @"iPad",
                    @"iPad2,1"   : @"iPad 2",
                    @"iPad2,2"   : @"iPad 2",
                    @"iPad2,3"   : @"iPad 2",
                    @"iPad2,4"   : @"iPad 2",
                    @"iPad2,5"   : @"iPad Mini",
                    @"iPad2,6"   : @"iPad Mini",
                    @"iPad2,7"   : @"iPad Mini",
                    @"iPad3,1"   : @"3rd Generation iPad",
                    @"iPad3,2"   : @"iPad 3(GSM+CDMA)",
                    @"iPad3,3"   : @"iPad 3(GSM)",
                    @"iPad3,4"   : @"iPad 4(WiFi)",
                    @"iPad3,5"   : @"iPad 4(GSM)",
                    @"iPad3,6"   : @"iPad 4(GSM+CDMA)",
                    @"iPad4,1"   : @"iPad Air(Wifi)",
                    @"iPad4,2"   : @"iPad Air(Cellular)",
                    @"iPad4,3"   : @"iPad Air",
                    @"iPad4,4"   : @"iPad Mini-Wifi",
                    @"iPad4,5"   : @"iPad Mini-Cellular",
                    @"iPad4,6"   : @"iPad Mini 2nd Gen",
                    @"iPad4,7"   : @"iPad Mini 3rd Gen",
                    @"iPad4,8"   : @"iPad Mini 3rd Gen",
                    @"iPad4,9"   : @"iPad Mini 3rd Gen",
                    @"iPad5,1"   : @"iPad Mini 4",
                    @"iPad5,2"   : @"iPad Mini 4",
                    @"iPad5,3"   : @"iPad Air 2",
                    @"iPad5,4"   : @"iPad Air 2",
                    @"iPad6,3"   : @"iPad Pro 9.7 inch",
                    @"iPad6,4"   : @"iPad Pro 9.7 inch",
                    @"iPad6,7"   : @"iPad Pro 12.9 inch",
                    @"iPad6,8"   : @"iPad Pro 12.9 inch",
                    @"iPhone1,1" : @"iPhone",
                    @"iPhone1,2" : @"iPhone 3G",
                    @"iPhone2,1" : @"iPhone 3GS",
                    @"iPhone3,1" : @"iPhone 4",
                    @"iPhone3,2" : @"iPhone 4",
                    @"iPhone3,3" : @"iPhone 4 (CDMA/Verizon)",
                    @"iPhone4,1" : @"iPhone 4S",
                    @"iPhone5,1" : @"iPhone 5(GSM)",
                    @"iPhone5,2" : @"iPhone 5(GSM+CDMA)",
                    @"iPhone5,3" : @"iPhone 5C(GSM)",
                    @"iPhone5,4" : @"iPhone 5C(GSM+CDMA)",
                    @"iPhone6,1" : @"iPhone 5S(GSM)",
                    @"iPhone6,2" : @"iPhone 5S(GSM+CDMA)",
                    @"iPhone7,1" : @"iPhone 6 Plus",
                    @"iPhone7,2" : @"iPhone 6",
                    @"iPhone8,1" : @"iPhone 6S",
                    @"iPhone8,2" : @"iPhone 6S Plus",
                    @"iPhone8,4" : @"iPhone SE",
                    @"iPhone9,1" : @"iPhone 7",
                    @"iPhone9,2" : @"iPhone 7 Plus",
                    @"iPhone9,3" : @"iPhone 7",
                    @"iPhone9,4" : @"iPhone 7 Plus",
                    @"iPhone10,1": @"iPhone 8 (CDMA)",
                    @"iPhone10,2": @"iPhone 8 Plus (CDMA)",
                    @"iPhone10,3": @"iPhone X (CDMA)",
                    @"iPhone10,4": @"iPhone 8 (GSM)",
                    @"iPhone10,5": @"iPhone 8 Plus (GSM)",
                    @"iPhone10,6": @"iPhone X (GSM)"
                    };
    }
    
    return _models;
}

- (NSString *)getDeviceModel
{
    struct utsname systemInfo;
    uname(&systemInfo);
    
    NSString *str = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    
    return str;
}

#warning TODO: Tablet UI using same configuration as iPhone; Should seperate them in future.
+ (BOOL)isiPhone4AndBelow
{
    NSString *model = [[[self alloc] init] getDeviceModel];
    if ([model isEqualToString:@"x86_64"]) { // Simulator for iPhone 4
        NSAssert(SimulatorForiPhoneScreenType == 4 || SimulatorForiPhoneScreenType == 5 || SimulatorForiPhoneScreenType == 6 || SimulatorForiPhoneScreenType == 10, @"Invalid type value for simulator. 4, 5, 6, 10 are acceptable.");
        if (SimulatorForiPhoneScreenType == 4) {
            return YES;
        } else {
            return NO; // Stop if it's simulator
        }
    }
    
    if ([[model substringToIndex:5] isEqualToString:@"iPod1"]
        || [[model substringToIndex:5] isEqualToString:@"iPod2"]
        || [[model substringToIndex:5] isEqualToString:@"iPod3"]
        || [[model substringToIndex:5] isEqualToString:@"iPod4"]
        || ([[model substringToIndex:7] isEqualToString:@"iPhone1"] && [model rangeOfString:@"iPhone10"].location == NSNotFound)
        || [[model substringToIndex:7] isEqualToString:@"iPhone2"]
        || [[model substringToIndex:7] isEqualToString:@"iPhone3"]
        || [[model substringToIndex:7] isEqualToString:@"iPhone4"]
        || [[model substringToIndex:5] isEqualToString:@"iPad1"]
        || [[model substringToIndex:5] isEqualToString:@"iPad2"]
        || [[model substringToIndex:7] isEqualToString:@"iPad3,1"]
        || [[model substringToIndex:7] isEqualToString:@"iPad3,2"]
        || [[model substringToIndex:7] isEqualToString:@"iPad3,3"]) {
        return YES;
    }
    
    return NO;
}

+ (BOOL)isiPhone5Serial {
    NSString *model = [[[self alloc] init] getDeviceModel];
    
    if ([model isEqualToString:@"x86_64"]) { // Simulator for iPhone 5
        NSAssert(SimulatorForiPhoneScreenType == 4 || SimulatorForiPhoneScreenType == 5 || SimulatorForiPhoneScreenType == 6 || SimulatorForiPhoneScreenType == 10, @"Invalid type value for simulator. 4, 5, 6, 10 are acceptable.");
        if (SimulatorForiPhoneScreenType == 5) {
            return YES;
        } else {
            return NO; // Stop if it's simulator
        }
    }
    
    if ([[model substringToIndex:5] isEqualToString:@"iPod5"] // iPod 5
        || [[model substringToIndex:7] isEqualToString:@"iPhone5"] // iPhone 5/5C
        || [[model substringToIndex:7] isEqualToString:@"iPhone6"] // iPhone 5S
        || [model isEqualToString:@"iPhone8,4"]) {                 // iPhone SE
        return YES;
    }
    
    return NO;
}

+ (BOOL)isiPhone6AndAbove {
    NSString *model = [[[self alloc] init] getDeviceModel];
    
    if ([model isEqualToString:@"x86_64"]) { // Simulator for iPhone 6
        NSAssert(SimulatorForiPhoneScreenType == 4 || SimulatorForiPhoneScreenType == 5 || SimulatorForiPhoneScreenType == 6 || SimulatorForiPhoneScreenType == 10, @"Invalid type value for simulator. 4, 5, 6, 10 are acceptable.");
        if (SimulatorForiPhoneScreenType == 6) {
            return YES;
        } else {
            return NO; // Stop if it's simulator
        }
    }
    
    if ([[model substringToIndex:5] isEqualToString:@"iPod6"] // iPod 6
        || [[model substringToIndex:5] isEqualToString:@"iPod7"] // iPod 7
        || [[model substringToIndex:7] isEqualToString:@"iPhone7"] // iPhone 6/Plus
        || ([[model substringToIndex:7] isEqualToString:@"iPhone8"] && ![model isEqualToString:@"iPhone8,4"]) // iPhone 6S/Plus
        || [[model substringToIndex:7] isEqualToString:@"iPhone9"] // iPhone 7/plus
        || (model.length >= 8 && [[model substringToIndex:8] isEqualToString:@"iPhone10"])) { // iPhone 8/Plus/X
        return YES;
    }
    
    return NO;
}

+ (BOOL)isiPhoneX {
    NSString *model = [[[self alloc] init] getDeviceModel];
    
    if ([model isEqualToString:@"x86_64"]) { // Simulator for iPhone X
        NSAssert(SimulatorForiPhoneScreenType == 4 || SimulatorForiPhoneScreenType == 5 || SimulatorForiPhoneScreenType == 6 || SimulatorForiPhoneScreenType == 10, @"Invalid type value for simulator. 4, 5, 6, 10 are acceptable.");
        if (SimulatorForiPhoneScreenType == 10) {
            return YES;
        } else {
            return NO; // Stop if it's simulator
        }
    }
    
    if ([model isEqualToString:@"iPhone10,3"]
        || [model isEqualToString:@"iPhone10,6"]) { // x86_64 is for bypass the simulator check
        return YES;
    } else {
        return NO;
    }
}

@end
