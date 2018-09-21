//
//  CTMFAnimationController.h
//  mobilefirst
//
//  Created by Wesolowski, Brendan on 2/19/16.
//  Copyright © 2016 Verizon Wireless. All rights reserved.

#import <Foundation/Foundation.h>

@class CTMFAnimation;
@interface CTMFAnimationController : NSObject

#pragma mark - Animation Methods

// Returns the shared instance of this singleton
+ (nullable instancetype)sharedGlobal;

-(void)registerAnimation:(nonnull CTMFAnimation *) animation;

-(void)startAnimations:(nonnull NSString *)className;

-(void)endAnimations:(BOOL)pageTransition;

-(BOOL)shouldShowFullAnimations:(nonnull NSString *)className;

@end
