//
//  AMPlayer.h
//  FileShareDemo
//
//  Created by VVM-MAC02 on 1/20/16.
//  Copyright © 2016 vz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AMPlayer : NSObject

/**
 * Operation methods
 */
- (void)play; // should play audio queue
- (void)stop; // should stop audio queue
- (BOOL)isRunning; // check if current audio queue is playing

/**
 * Initializer
 */
- (AMPlayer *)initWithFormat;


/**
 * Update the string to be played via audio queue
 */
- (void)setupPlayInfo:(NSString *)info;

/**
 * Update relative volume for Player Audio Queue
 */
- (void)updateRelativeVolumeForPlayer:(float)newVolume;

@end
