//
//  CTQRCode.m
//  contenttransfer
//
//  Created by Pena, Ricardo on 1/31/17.
//  Copyright © 2017 Verizon Wireless Inc. All rights reserved.
//

#import "CTQRCode.h"
#import "CTUserDevice.h"
#import "CTDeviceMarco.h"

/*
 
 versionName       : 3.3.60-DEBUG
 securityType      : WPA, WEP, OPEN and Empty string if no match found.
 combinationType   : same platform , cross platform
 ssid              : DIRECT-Pj-SM-N900V_test => Hotspot name
 ipaddress         : 0.0.0.0
 password          : fySuW1Mn
 connectionType    : hotspot wifi , wifi direct , router
 setupType         : Receiver , Sender
 service           : Bonjour service name(only for iOS)
 
*/

@implementation CTQRCode

- (instancetype)initWithPlattform:(NSString *)platform
                          andSSID:(NSString *)ssid
                    andIPAddreess:(NSString *)ipAddress
                          andPort:(NSString *)port
                      andPasscode:(NSString *)passcode
                       andService:(NSString *)service
                     andSetupType:(NSString *)setupType {
    
    self = [super init];
    
    if (self) {
        self.appVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
        self.osVersion = [[UIDevice currentDevice] systemVersion];
        self.platform = platform;
        self.ssid = ssid;
        self.ipAddress = ipAddress;
//        self.port = port;
        self.passcode = passcode;
        self.service = service;
        self.setUpType = setupType;
        if ([[CTUserDevice userDevice].phoneCombination isEqualToString:IOS_IOS]) {
            
            if([setupType rangeOfString:@"CTSTMM"].location != NSNotFound)
            {
                self.connectionType = @"multipeer";
            }
            else if (![CTDeviceMarco isiPhone4AndBelow]) {
                self.connectionType = @"bonjour&router";
            } else {
                self.connectionType = @"router";
            }
        } else {
            self.connectionType = @"router";
        }

    }
    
    return self;
}

- (instancetype)initWithPlattform:(NSString *)platform
                          andSSID:(NSString *)ssid
                    andIPAddreess:(NSString *)ipAddress
                     andSetupType:(NSString *)setupType
                      andPasscode:(NSString *)passcode
                       andService:(NSString *)service
                andConnectionType:(NSString *)connectionType {
    
    self = [super init];
    
    if (self) {
        self.appVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
        self.securityType = @"WPA"; // Hardcoded for Android side use
        self.platform = platform;
        self.ssid = ssid;
        self.ipAddress = ipAddress;
        self.passcode = passcode;
        self.connectionType = connectionType;
        self.setUpType = setupType;
        
    }
    
    return self;
}


- (NSString *)toString {
    
    NSString *qrString = @"";
    
    if ([[CTUserDevice userDevice].phoneCombination isEqualToString:IOS_IOS]) {
        qrString = [NSString stringWithFormat:@"VZWCT%@#%@#%@#%@#%@#%@#%@#%@#%@",
                self.appVersion, self.osVersion,
                self.platform, self.ssid,
                self.ipAddress, self.passcode,
                self.connectionType, self.setUpType,
                self.service];
    } else {
        qrString = [NSString stringWithFormat:@"VZWCT%@#%@#%@#%@#%@#%@#%@#%@",
                    self.appVersion, @"WPA",
                    self.platform, self.ssid,
                    self.ipAddress, self.passcode,
                    self.connectionType,self.setUpType];
    }
    
    NSLog(@"==================");
    NSLog(@"Original QR:\n %@(%lu)", qrString, (unsigned long)qrString.length);
    NSLog(@"==================");
    
    qrString = [qrString encodeStringTo64];
    NSLog(@"==================");
    NSLog(@"Encoded QR:\n %@(%lu)", qrString, (unsigned long)qrString.length);
    NSLog(@"==================");
    
    return qrString;
    
}

- (CIImage *)toCIImage {
    
    NSString * qrString = [self toString];
    
    NSData *stringData = [qrString dataUsingEncoding: NSISOLatin1StringEncoding];
    if (!stringData) {
        stringData = [qrString dataUsingEncoding: NSUTF8StringEncoding];
    }
    
    CIFilter *qrFilter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    [qrFilter setValue:stringData forKey:@"inputMessage"];
    
    return qrFilter.outputImage;
}

- (CIImage *)toTransformedCIImageFromLayer:(CALayer *)layer {
    
    CIImage * ciImage = [self toCIImage];
    
    double scaleX = layer.frame.size.width / ciImage.extent.size.width;
    double scaleY = layer.frame.size.height / ciImage.extent.size.height;
    
    CGAffineTransform transform = CGAffineTransformScale(CGAffineTransformIdentity,
                                                         scaleX, scaleY);
    
    CIImage * transformedCIImage = [ciImage imageByApplyingTransform:transform];
    
    return transformedCIImage;
}

- (UIImage *)toUIImageFromLayer:(CALayer *)layer {
    
    CIImage * ciImage = [self toTransformedCIImageFromLayer:layer];
    
    return [[UIImage alloc]initWithCIImage:ciImage];

}

+ (NSArray *)parseQRCodeString:(NSString *)qrString {
    qrString = [qrString decodeStringTo64];
    NSArray *listItems = [qrString componentsSeparatedByString:@"#"];
    return listItems;
}

@end
