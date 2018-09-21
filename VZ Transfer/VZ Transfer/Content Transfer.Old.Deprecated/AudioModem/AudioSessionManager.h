//
//  AudioSessionManager.h
//  FileShareDemo
//
//  Created by VVM-MAC02 on 1/25/16.
//  Copyright © 2016 vz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef void (^OperationHandler)(NSError *);

@interface AudioSessionManager : NSObject

/**
 * Enable app playing sound even user set the device in the slience
 * Note: Even in slience mode user could set volume for app sound, so if user set volume to 0, app couldn't play sound
 */
+ (void)enablePlayingSoundInSlientMode:(OperationHandler)handler;

/**
 * Change the audio sessionn mode to play and record.
 * Must turn back before recording when turned mode to enable playing sound in slient mode,
 * otherwise record audio queue cannot be start.
 */
+ (void)enablePlayingAndRecordMode:(OperationHandler)handler;

/**
 * Add kvO for volume change for specific view controller
 */
+ (void)enableTrackingSystemVolumeChangeForController:(UIViewController *)targetController;

/**
 * Get System volume user set for device
 */
+ (float)getCurrentSystemVolume;

/**
 * Detect if headphone is plugged in, should alert user to unplug.
 */
+ (BOOL)isHeadsetPluggedIn;

@end
