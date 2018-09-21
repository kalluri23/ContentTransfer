//
//  CTMFAnimation.m
//  mobilefirst
//
//  Created by Wesolowski, Brendan on 2/19/16.
//  Copyright © 2016 Verizon Wireless. All rights reserved.
//

#import "CTMFAnimation.h"
#import "CTMFAnimatedObjectProtocol.h"

@implementation CTMFAnimation

float const HeightOffsetForAnimation = 10.0;
float const WidthOffsetForAnimation = 10.0;
float const RotationOffsetForAnimation = 0.15;
float const StartAlphaForAnimation = 0.0;
float const EndAlphaForAnimation = 1.0;

float const AnimationDurationExtraLong = 1.0;
float const AnimationDurationLong = 0.5;
float const AnimationDurationDefault = 0.3;
float const AnimationDurationShort = 0.2;
float const AnimationDurationInstant = 0.0;

float const AnimationDelayLong = 0.1;
float const AnimationDelayDefault = 0.05;
float const AnimationDelayShort = 0.01;
float const AnimationDelayInstant = 0.0;


#pragma mark - Lifecycle

-(instancetype)initWithAnimationPriority:(int)newAnimationPriority AnimationDelay:(float)newAnimationDelay AnimationDuration:(float)newAnimationDuration AnimationOptions:(UIViewAnimationOptions)newAnimationOptions AnimationBlock:(CTMFAnimationBlock)newAnimationBlock CompletionBlock:(CTMFCompletionBlock)newCompletionBlock FinalStateAnimationBlock:(CTMFAnimationBlock)newFinalStateAnimationBlock {
	if(self = [super init])
	{
		_animationBlock = newAnimationBlock;
		_completionBlock = newCompletionBlock;
		_finalStateAnimationBlock = newFinalStateAnimationBlock;
		_animationPriority = newAnimationPriority;
		_animationDelay = newAnimationDelay;
		_animationDuration = newAnimationDuration;
		_animationOptions = newAnimationOptions;
		_animationPlayed = NO;
	}
	return self;
}

#pragma mark - Sorting

-(NSComparisonResult)compareDelay:(nonnull CTMFAnimation *)comparisonObject {
	
	if(self.animationDelay > comparisonObject.animationDelay)
	{
		return NSOrderedDescending;
	}
	else if(self.animationDelay < comparisonObject.animationDelay)
	{
		return NSOrderedAscending;
	}
	else
		return NSOrderedSame;
	
	
}

#pragma mark - Generic Animations

+(void)fadeIn:(UIView *)obj IsInitialization:(BOOL)setup {
	if(setup) {
		obj.alpha = StartAlphaForAnimation;
	}
	else {
		obj.alpha = EndAlphaForAnimation;
	}
}

+(void)fadeOut:(UIView *)obj IsInitialization:(BOOL)setup {
	if(setup) {
		obj.alpha = EndAlphaForAnimation;
	}
	else {
		obj.alpha = StartAlphaForAnimation;
	}
}

+(void)fade:(UIView *)obj targetAlpha:(float)alpha {
	obj.alpha = alpha;
}

+(void)fadeInAndShiftUp:(UIView *)obj IsInitialization:(BOOL)setup {
	if(setup) {
		obj.alpha = StartAlphaForAnimation;
		obj.frame = CGRectMake(CGRectGetMinX(obj.frame),
							   CGRectGetMinY(obj.frame) + HeightOffsetForAnimation,
							   CGRectGetWidth(obj.frame),
							   CGRectGetHeight(obj.frame));
	}
	else {
		obj.alpha = EndAlphaForAnimation;
		obj.frame = CGRectMake(CGRectGetMinX(obj.frame),
							   CGRectGetMinY(obj.frame) - HeightOffsetForAnimation,
							   CGRectGetWidth(obj.frame),
							   CGRectGetHeight(obj.frame));
	}
}

+(void)fadeInAndSpinUp:(UIView *)obj TargetFrame:(CGRect)frame IsInitialization:(BOOL)setup {
	if(setup) {
		obj.alpha = StartAlphaForAnimation;
		CATransform3D translate = CATransform3DIdentity;
		translate = CATransform3DTranslate(translate, 0, -CGRectGetHeight(frame)/2.0 + HeightOffsetForAnimation, 0);
		CATransform3D rotationAndPerspectiveTransform = CATransform3DIdentity;
		rotationAndPerspectiveTransform.m34 = 1.0 / -1000.0;
		rotationAndPerspectiveTransform = CATransform3DRotate(rotationAndPerspectiveTransform, RotationOffsetForAnimation, 1.0, 0.0, 0.0);
		obj.layer.anchorPoint = CGPointMake(0.5, 0.0);
		obj.layer.transform = CATransform3DConcat(translate, rotationAndPerspectiveTransform);
	}
	else {
		obj.alpha = EndAlphaForAnimation;
		obj.layer.transform = CATransform3DIdentity;
		obj.layer.frame = frame;
	}
}

+(void)fadeInAndSpinLeft:(UIView *)obj TargetFrame:(CGRect)frame IsInitialization:(BOOL)setup {
	if(setup) {
		obj.alpha = StartAlphaForAnimation;
		CATransform3D translate = CATransform3DIdentity;
		translate = CATransform3DTranslate(translate, -CGRectGetWidth(obj.layer.frame)/2.0+WidthOffsetForAnimation, 0, 0);
		CATransform3D rotationAndPerspectiveTransform = CATransform3DIdentity;
		rotationAndPerspectiveTransform.m34 = 1.0 / -1000.0;
		rotationAndPerspectiveTransform = CATransform3DRotate(rotationAndPerspectiveTransform, -RotationOffsetForAnimation, 0.0, 1.0, 0.0);
		obj.layer.anchorPoint = CGPointMake(0.0, 0.5);
		obj.layer.transform = CATransform3DConcat(translate, rotationAndPerspectiveTransform);
	}
	else {
		obj.alpha = EndAlphaForAnimation;
		obj.layer.transform = CATransform3DIdentity;
		obj.frame = frame;
	}
}

+(void)fadeInAndShiftLeft:(UIView *)obj IsInitialization:(BOOL)setup {
	if(setup) {
		obj.alpha = StartAlphaForAnimation;
		obj.frame = CGRectMake(CGRectGetMinX(obj.frame) + WidthOffsetForAnimation,
							   CGRectGetMinY(obj.frame),
							   CGRectGetWidth(obj.frame),
							   CGRectGetHeight(obj.frame));
	}
	else {
		obj.alpha = EndAlphaForAnimation;
		obj.frame = CGRectMake(CGRectGetMinX(obj.frame) - WidthOffsetForAnimation,
							   CGRectGetMinY(obj.frame),
							   CGRectGetWidth(obj.frame),
							   CGRectGetHeight(obj.frame));
	}
}

+(void)shiftToSide:(UIView *)obj IsInitialization:(BOOL)setup IsLeft:(BOOL)isLeft {
	if(setup) {
		obj.frame = CGRectMake(CGRectGetMinX(obj.frame) + WidthOffsetForAnimation * (isLeft ? 3 : -3),
							   CGRectGetMinY(obj.frame),
							   CGRectGetWidth(obj.frame),
							   CGRectGetHeight(obj.frame));
	}
	else {
		obj.frame = CGRectMake(CGRectGetMinX(obj.frame) - WidthOffsetForAnimation * (isLeft ? 3 : -3),
							   CGRectGetMinY(obj.frame),
							   CGRectGetWidth(obj.frame),
							   CGRectGetHeight(obj.frame));
	}
}

+(void)scale:(UIView *)obj ScaleFactor:(CGFloat)scaleFactor MaintainCenterPosition:(BOOL)maintainCenter {
	if(maintainCenter) {
		float offsetX = CGRectGetWidth(obj.frame) - (CGRectGetWidth(obj.frame) *scaleFactor);
		float offsetY = CGRectGetHeight(obj.frame) - (CGRectGetHeight(obj.frame) *scaleFactor);
		obj.center = CGPointMake(obj.center.x+offsetX/2.0, obj.center.y+offsetY/2.0);
	}
	obj.frame = CGRectMake(CGRectGetMinX(obj.frame),
						   CGRectGetMinY(obj.frame),
						   CGRectGetWidth(obj.frame) * scaleFactor,
						   CGRectGetHeight(obj.frame) * scaleFactor);
	
}

+(void)scaleHeight:(UIView *)obj ScaleFactor:(CGFloat)scaleFactor MaintainCenterPosition:(BOOL)maintainCenter {
	if(maintainCenter) {
		float offsetY = CGRectGetHeight(obj.frame) - (CGRectGetHeight(obj.frame) *scaleFactor);
		obj.center = CGPointMake(obj.center.x, obj.center.y+offsetY/2.0);
	}
	obj.frame = CGRectMake(CGRectGetMinX(obj.frame),
						   CGRectGetMinY(obj.frame),
						   CGRectGetWidth(obj.frame),
						   CGRectGetHeight(obj.frame) * scaleFactor);
	
}

+(void)scaleWidth:(UIView *)obj ScaleFactor:(CGFloat)scaleFactor MaintainCenterPosition:(BOOL)maintainCenter {
	if(maintainCenter) {
		float offsetX = CGRectGetWidth(obj.frame) - (CGRectGetWidth(obj.frame) *scaleFactor);
		obj.center = CGPointMake(obj.center.x+offsetX/2.0, obj.center.y);
	}
	obj.frame = CGRectMake(CGRectGetMinX(obj.frame),
						   CGRectGetMinY(obj.frame),
						   CGRectGetWidth(obj.frame) * scaleFactor,
						   CGRectGetHeight(obj.frame));
	
}

+(void)setFrame:(UIView *)obj NewFrame:(CGRect)frame {
	obj.frame = CGRectMake(CGRectGetMinX(frame),
						   CGRectGetMinY(frame),
						   CGRectGetWidth(frame),
						   CGRectGetHeight(frame));
}

#pragma mark - Cell entrance convenience function
+(void) performCellAnimation:(nonnull UIView *)cell AnimationsRegistered:(BOOL)animationsRegistered {
	if(!animationsRegistered) {
		return;
	}
	
	if([cell respondsToSelector:@selector(prepareAnimations)]) {
		id<CTMFAnimatedObjectProtocol> animObj = (id)cell;
		[animObj prepareAnimations];
		[animObj performAnimations:AnimationDelayDefault];
	} else {
		((UIView*)cell).alpha = 0.0;
		[UIView animateWithDuration:AnimationDurationDefault animations:^{
			((UIView*)cell).alpha = 1.0;
		}];
	}
}


@end
