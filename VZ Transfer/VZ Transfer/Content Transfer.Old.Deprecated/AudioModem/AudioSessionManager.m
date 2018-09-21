//
//  AudioSessionManager.m
//  FileShareDemo
//
//  Created by VVM-MAC02 on 1/25/16.
//  Copyright © 2016 vz. All rights reserved.
//

#import "AudioSessionManager.h"
#import <AVFoundation/AVFoundation.h>

@interface AudioSessionManager()

@end

@implementation AudioSessionManager

+ (void)enablePlayingSoundInSlientMode:(OperationHandler)handler
{
    NSError *error = noErr;
    [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayback error: &error]; // allow app to play sound even in slient mode
    if (handler != nil) {
        handler(error);
    }
}

+ (void)enablePlayingAndRecordMode:(OperationHandler)handler
{
    NSError *error = noErr;
    [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayAndRecord error: &error]; // allow record mode
    if (handler != nil) {
        handler(error);
    }
}

+ (void)enableTrackingSystemVolumeChangeForController:(UIViewController *)targetController
{
    [[AVAudioSession sharedInstance] addObserver:targetController forKeyPath:@"outputVolume" options:NSKeyValueObservingOptionNew context:nil];
}

+ (float)getCurrentSystemVolume
{
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setActive:YES error:nil]; // output volume only return last active volume;
    return [session outputVolume];
}

+ (BOOL)isHeadsetPluggedIn
{
    AVAudioSessionRouteDescription* route = [[AVAudioSession sharedInstance] currentRoute];
    for (AVAudioSessionPortDescription* desc in [route outputs]) {
        if ([[desc portType] isEqualToString:AVAudioSessionPortHeadphones])
            return YES;
    }
    return NO;
}
@end
