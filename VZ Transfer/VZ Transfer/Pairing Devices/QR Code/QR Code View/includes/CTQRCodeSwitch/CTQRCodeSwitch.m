//
//  CTQRCodeSwitch.m
//  contenttransfer
//
//  Created by Sun, Xin on 2/27/17.
//  Copyright © 2017 Verizon Wireless Inc. All rights reserved.
//

#import "CTQRCodeSwitch.h"

@interface CTQRCodeSwitch()

@property (nonatomic, assign) BOOL allowQRCode;

@end

@implementation CTQRCodeSwitch

+ (instancetype)uniqueSwitch {
    
    static CTQRCodeSwitch *sharedInstance = nil;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        sharedInstance = [[CTQRCodeSwitch alloc] init];
    });
    
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.allowQRCode = YES;
    }
    
    return self;
}

- (BOOL)isOn {
    return _allowQRCode;
}

- (void)off {
    self.allowQRCode = NO;
}

@end
