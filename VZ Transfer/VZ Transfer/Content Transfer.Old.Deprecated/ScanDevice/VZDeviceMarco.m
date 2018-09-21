//
//  VZDeviceMarco.m
//  VZTransferSocket
//
//  Created by Sun, Xin on 3/9/16.
//  Copyright © 2016 Testing. All rights reserved.
//

#import "VZDeviceMarco.h"
#import <sys/utsname.h>

@implementation VZDeviceMarco

- (NSDictionary *)models {
    if (_models == nil) {
        _models = @{
                    @"iPod1,1" : @"iPod Touch",
                    @"iPod2,1" : @"iPod Touch 2nd Generation",
                    @"iPod3,1" : @"iPod Touch 3rd Generation",
                    @"iPod4,1" : @"iPod Touch 4th Generation",
                    @"iPod5,1" : @"iPod Touch 5th Generation",
                    @"iPod7,1" : @"iPod Touch 6th Generation",
                    @"iPad1,1" : @"iPad",
                    @"iPad2,1" : @"iPad 2",
                    @"iPad2,2" : @"iPad 2",
                    @"iPad2,3" : @"iPad 2",
                    @"iPad2,4" : @"iPad 2",
                    @"iPad2,5" : @"iPad Mini",
                    @"iPad2,6" : @"iPad Mini",
                    @"iPad2,7" : @"iPad Mini",
                    @"iPad3,1" : @"3rd Generation iPad",
                    @"iPad3,2" : @"iPad 3(GSM+CDMA)",
                    @"iPad3,3" : @"iPad 3(GSM)",
                    @"iPad3,4" : @"iPad 4(WiFi)",
                    @"iPad3,5" : @"iPad 4(GSM)",
                    @"iPad3,6" : @"iPad 4(GSM+CDMA)",
                    @"iPad4,1" : @"iPad Air(Wifi)",
                    @"iPad4,2" : @"iPad Air(Cellular)",
                    @"iPad4,3" : @"iPad Air",
                    @"iPad4,4" : @"iPad Mini-Wifi",
                    @"iPad4,5" : @"iPad Mini-Cellular",
                    @"iPad4,6" : @"iPad Mini 2nd Gen",
                    @"iPad4,7" : @"iPad Mini 3rd Gen",
                    @"iPad4,8" : @"iPad Mini 3rd Gen",
                    @"iPad4,9" : @"iPad Mini 3rd Gen",
                    @"iPad5,1" : @"iPad Mini 4",
                    @"iPad5,2" : @"iPad Mini 4",
                    @"iPad5,3" : @"iPad Air 2",
                    @"iPad5,4" : @"iPad Air 2",
                    @"iPad6,3" : @"iPad Pro 9.7 inch",
                    @"iPad6,4" : @"iPad Pro 9.7 inch",
                    @"iPad6,7" : @"iPad Pro 12.9 inch",
                    @"iPad6,8" : @"iPad Pro 12.9 inch",
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
                    @"iPhone9,2" : @"iPhone 7 Plus"};
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

+ (BOOL)isiPhone4AndBelow
{
    NSString *model = [[[self alloc] init] getDeviceModel];
    if ([[model substringToIndex:5] isEqualToString:@"iPod5"]
        || [[model substringToIndex:7] isEqualToString:@"iPhone5"]
        || [[model substringToIndex:7] isEqualToString:@"iPhone6"]
        || [[model substringToIndex:7] isEqualToString:@"iPhone7"]
        || [[model substringToIndex:7] isEqualToString:@"iPhone8"]) {
		if ([[model substringToIndex:7] isEqualToString:@"iPhone5"] && ([[[UIDevice currentDevice] systemVersion] floatValue] < 8.0f)) {
            return YES;
        }
        return NO;
    }
    
    return YES;
}

+ (BOOL)isiPhone5Serial {
    NSString *model = [[[self alloc] init] getDeviceModel];
    if ([[model substringToIndex:5] isEqualToString:@"iPod5"] || [[model substringToIndex:7] isEqualToString:@"iPhone5"] || [[model substringToIndex:7] isEqualToString:@"iPhone6"]) {
        return YES;
    }
    
    return NO;
}

+ (BOOL)isiPhone6AndAbove {
    NSString *model = [[[self alloc] init] getDeviceModel];
    if ([[model substringToIndex:7] isEqualToString:@"iPhone7"] || [[model substringToIndex:7] isEqualToString:@"iPhone8"]) {
        return YES;
    }
    
    return NO;
}

@end
