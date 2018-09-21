//
//  CTStoryboardHelper.m
//  contenttransfer
//
//  Created by Development on 8/11/16.
//  Copyright © 2016 Verizon. All rights reserved.
//

#import "CTBundle.h"
#import "CTStoryboardHelper.h"

@implementation CTStoryboardHelper

+ (nonnull UIStoryboard *)devicesStoryboard {
    return [CTStoryboardHelper storyboardFromName:STORYBOARD_DevicesStoryboard];
}

+ (nonnull UIStoryboard *)wifiAndP2PStoryboard {
    return [CTStoryboardHelper storyboardFromName:STORYBOARD_WiFiAndP2PStoryboard];
}

+ (nonnull UIStoryboard *)qrCodeAndScannerStoryboard {
    return [CTStoryboardHelper storyboardFromName:STORYBOARD_QRCodeAndScannerStoryboard];
}

+ (nonnull UIStoryboard *)bonjourStoryboard {
    return [CTStoryboardHelper storyboardFromName:STORYBOARD_BonjourStoryboard];
}

+ (nonnull UIStoryboard *)transferStoryboard {
    return [CTStoryboardHelper storyboardFromName:STORYBOARD_TransferStoryboard];
}

+ (nonnull UIStoryboard *)commonStoryboard {
    return [CTStoryboardHelper storyboardFromName:STORYBOARD_CommonStoryboard];
}

+ (nonnull UIStoryboard *)storyboardFromName:(NSString *)storyboardName {


    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle:[CTBundle resourceBundle]];
    NSAssert(storyboard, @"storyboard can't be nil, please check implementation");

    return storyboard;
}

@end
