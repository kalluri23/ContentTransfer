//
//  NSString+CTHelper.m
//  contenttransfer
//
//  Created by Mehta, Snehal Natwar on 9/13/16.
//  Copyright © 2016 Verizon Wireless. All rights reserved.
//

#import "NSString+CTHelper.h"

@implementation NSString (CTHelper)

- (BOOL)isEqualToCaseInsensitiveString:(NSString *)aString {
    return ([self caseInsensitiveCompare:aString] == NSOrderedSame);
}

- (NSString *)pluralMediaType {
    if ([self isEqualToString:CTLocalizedString(CT_FILE_LIST_STRING, nil)]) {
        return @"file list";
    } else if ([self isEqualToString:@"photo"] || [self isEqualToString:@"photos"]) {
        return CTLocalizedString(CT_PHOTOS_STRING, nil);
    } else if ([self isEqualToString:@"video"] || [self isEqualToString:@"videos"]) {
        return CTLocalizedString(CT_VIDEOS_STRING, nil);
    } else if ([self isEqualToString:@"contact"] || [self isEqualToString:@"contacts"]) {
        return CTLocalizedString(CT_CONTACTS_STRING, nil);
    } else if ([self isEqualToString:@"reminder"] || [self isEqualToString:@"reminders"]) {
        return CTLocalizedString(CT_REMINDERS_STRING, nil);
    } else if ([self isEqualToString:@"calendar"] || [self isEqualToString:@"calendars"]) {
        return CTLocalizedString(CT_CALANDERS_STRING, nil);
    } else if ([self isEqualToString:CTLocalizedString(CT_APPS_STRING, nil)]) {
        return @"apps";
    } else if ([self isEqualToString:@"audios"] || [self isEqualToString:@"audio"]) {
        return CTLocalizedString(CT_AUDIO_STRING, nil);
    } else if ([self isEqualToString:@"unknown"]) {
        return @"";
    } else {
        return self;
    }
}

- (NSString*)lowerUDIDString{
    
    NSString *changedUUID = [self stringByReplacingOccurrencesOfString:@"-" withString:@""];
    return  [changedUUID lowercaseString];
}

- (NSString *)formatTime {
    NSInteger totalTime = [self integerValue];
    NSInteger hh = totalTime / (60 * 60);
    NSInteger mm = totalTime / 60 - (hh * 60);
    NSInteger ss = totalTime - (hh * 60 * 60) - (mm * 60);
    
    NSString *timeFormatted = @"";
    if (hh > 0) {
        timeFormatted = [timeFormatted stringByAppendingString:[NSString stringWithFormat:CTLocalizedString(CT_LOCALIZED_HRS_FORMAT, nil), (long)hh]];
    }
    
    if (mm > 0) {
        if (timeFormatted.length > 0) {
            timeFormatted = [timeFormatted stringByAppendingString:@" "];
        }
        timeFormatted = [timeFormatted stringByAppendingString:[NSString stringWithFormat:CTLocalizedString(CT_LOCALIZED_MIN_FORMAT, nil), (long)mm]];
    }
    
    if (ss > 0) {
        if (timeFormatted.length > 0) {
            timeFormatted = [timeFormatted stringByAppendingString:@" "];
        }
        timeFormatted = [timeFormatted stringByAppendingString:[NSString stringWithFormat:CTLocalizedString(CT_LOCALIZED_SEC_FORMAT, nil), (long)ss]];
    }
    
    if (timeFormatted.length == 0) {
        timeFormatted = CTLocalizedString(CT_LOCALIZED_1SEC_FORMAT, nil);
    }
    
    return timeFormatted;
}

+ (NSString *)deviceVID {
    NSString *vID = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    NSLog(@"vendor ID: %@", vID);
    
    return vID;
}

- (NSString*)editDeviceModel {
    
    NSMutableString *deviceModel = [self mutableCopy];
    if ([deviceModel containsString:@","]) {
        [deviceModel replaceOccurrencesOfString:@"," withString:@"_" options:NSBackwardsSearch range:NSMakeRange(0, [deviceModel length])];
        return deviceModel;
    }
    
    return deviceModel;

}

- (NSString *)printMask:(int)mask {
    if (mask == 0) {
        return @"";
    }
    int digit = mask & 1;
    NSString *string = [self printMask:mask>>1];
    string = [string stringByAppendingString:[NSString stringWithFormat:@"%d", digit]];
    return string;
}


- (NSString*)encodeStringTo64 {
    NSData *plainData = [self dataUsingEncoding:NSUTF8StringEncoding];
    NSString *base64String = [plainData base64EncodedStringWithOptions:kNilOptions];
    
    return base64String;
}

- (NSString*)decodeStringTo64 {
    
    NSData *decodedData = [[NSData alloc] initWithBase64EncodedString:self options:0];
    NSString *decodedString = [[NSString alloc] initWithData:decodedData encoding:NSUTF8StringEncoding];
    
    DebugLog(@"Decoded data is %@",decodedString);
    
    return decodedString;
}

+ (NSString *)generateUDID {
    //Local DB Analytics
    NSString *udid = [[NSUUID UUID] UUIDString];
    NSLog(@"UDID generated:%@", udid);
    
    return udid;
}

@end
