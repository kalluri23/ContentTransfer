//
//  ShakingAlerts.h
//  FileShareDemo
//
//  Created by Sun, Xin on 1/28/16.
//  Copyright © 2016 vz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CTMVMAlertAction.h"
#import "CTMVMAlertObject.h"
#import "CTMVMAlertHandler.h"

typedef void (^AlertHandle)(void);

@interface ShakingAlerts : UIAlertController

+ (void)showHeadsetAlerts:(UIViewController *)controller withHandler:(AlertHandle)handler;

+ (void)showVolumeAlerts:(UIViewController *)controller;

+ (void)showDeviceAlerts:(UIViewController *)controller;

+ (void)showDeviceModelAlerts:(UIViewController *)controller withHandler:(AlertHandle)handler;

@end
