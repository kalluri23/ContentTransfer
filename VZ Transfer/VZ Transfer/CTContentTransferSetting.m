//
//  CTContentTransferSetting.m
//  contenttransfer
//
//  Created by Sun, Xin on 10/6/17.
//  Copyright © 2017 Verizon Wireless Inc. All rights reserved.
//

#import "CTContentTransferSetting.h"

@implementation CTContentTransferSetting

+ (BOOL)userCustomVerizonAlert {
    return USES_CUSTOM_VERIZON_ALERTS;
}

+ (BOOL)useHotspotAutoConnection {
    return APPROVE_TO_USE_HOTSPOT_HELPER;
}

@end
