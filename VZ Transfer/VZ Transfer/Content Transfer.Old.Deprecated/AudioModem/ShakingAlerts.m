//
//  ShakingAlerts.m
//  FileShareDemo
//
//  Created by Sun, Xin on 1/28/16.
//  Copyright © 2016 vz. All rights reserved.
//

#import "ShakingAlerts.h"

@implementation ShakingAlerts

+ (void)showHeadsetAlerts:(UIViewController *)controller withHandler:(AlertHandle)handler
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        CTMVMAlertAction *cancelAction = [CTMVMAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            if (handler) {
                handler();
            }
        }];
        
        
        [[CTMVMAlertHandler sharedAlertHandler] showAlertWithTitle:@"Headset is plugged in" message:@"Please unplug your headset on your device before you use shaking to connect." cancelAction:cancelAction otherActions:nil isGreedy:NO];
    });
}


+ (void)showVolumeAlerts:(UIViewController *)controller
{
    dispatch_async(dispatch_get_main_queue(), ^{
        CTMVMAlertAction *cancelAction = [CTMVMAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
        
        
        [[CTMVMAlertHandler sharedAlertHandler] showAlertWithTitle:@"Volume Too Low" message:@"Please turn up your volume before you use shaking to connect." cancelAction:cancelAction otherActions:nil isGreedy:NO];
    });
}

+ (void)showDeviceAlerts:(UIViewController *)controller
{
    dispatch_async(dispatch_get_main_queue(), ^{
      
        CTMVMAlertAction *cancelAction = [CTMVMAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
        
        
        [[CTMVMAlertHandler sharedAlertHandler] showAlertWithTitle:@"Invalid Operation" message:@"Cannot connect two devices both have old phone setting." cancelAction:cancelAction otherActions:nil isGreedy:NO];
        
        
    });
}





+ (void)showDeviceModelAlerts:(UIViewController *)controller withHandler:(AlertHandle)handler
{
    dispatch_async(dispatch_get_main_queue(), ^{
        CTMVMAlertAction *cancelAction = [CTMVMAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
        
        CTMVMAlertAction *okAction = [CTMVMAlertAction actionWithTitle:@"Connect" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
            handler();
        }];
        
        
        [[CTMVMAlertHandler sharedAlertHandler] showAlertWithTitle:@"Content Transfer" message:@"Your device only supports Hotspot method." cancelAction:cancelAction otherActions:@[okAction] isGreedy:NO];
    });
}

@end
