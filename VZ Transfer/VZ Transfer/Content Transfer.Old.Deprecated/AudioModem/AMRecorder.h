//
//  AMRecorder.h
//  FileShareDemo
//
//  Created by VVM-MAC02 on 1/21/16.
//  Copyright © 2016 vz. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol RecorderDelegate <NSObject>

- (void)recorderDidFinishRecording;

@end


@interface AMRecorder : NSObject

@property (nonatomic, strong) NSString *result;
@property (nonatomic, weak) id<RecorderDelegate> delegate;

- (AMRecorder *)initWithFormat;

- (BOOL)isRunning;

- (void)startRecording;

- (void)stop;

@end
