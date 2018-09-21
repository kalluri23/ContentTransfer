//
//  CTMFAnimatedObjectProtocol.h
//  mobilefirst
//
//  Created by Wesolowski, Brendan on 2/25/16.
//  Copyright © 2016 Verizon Wireless. All rights reserved.
//

@protocol CTMFAnimatedObjectProtocol <NSObject>

@property (nonatomic) BOOL animationsRegistered;
@property (nonatomic) BOOL shouldAnimate;
@property (nonatomic) BOOL showFullAnimations;

-(void) registerAnimations;

-(void)registerAnimations:(uint)animationPriority;

@optional
-(void)registerAnimations:(uint)animationPriority Delay:(float)animationDelay;

-(void)prepareAnimations;
-(void)performAnimations;
-(void)performAnimations:(float)animationDelay;

@end

