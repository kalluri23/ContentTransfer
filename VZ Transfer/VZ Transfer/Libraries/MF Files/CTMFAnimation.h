//
//  CTMFAnimation.h
//  mobilefirst
//
//  Created by Wesolowski, Brendan on 2/19/16.
//  Copyright © 2016 Verizon Wireless. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef void (^CTMFAnimationBlock)(void);
typedef void (^CTMFCompletionBlock)(BOOL);

typedef NS_ENUM(NSInteger, CTMFAnimationPriority) {
	CTMFAnimationPriorityIntro = 0,
	CTMFAnimationPriorityHeaderIntro,
	CTMFAnimationPriorityHeader,
	CTMFAnimationPriorityHeaderOutro,
	CTMFAnimationPriorityBodyIntro,
	CTMFAnimationPriorityBody,
	CTMFAnimationPriorityBodyOutro,
	CTMFAnimationPriorityFooterIntro,
	CTMFAnimationPriorityFooter,
	CTMFAnimationPriorityFooterOutro,
	CTMFAnimationPriorityOutro,
	CTMFAnimationPriorityTriggeredOnEnd,
	CTMFAnimationPriorityTriggeredOnPageTransition
};

@interface CTMFAnimation : NSObject

@property (nonnull, strong, nonatomic) CTMFAnimationBlock animationBlock;
@property (nullable, strong, nonatomic) CTMFCompletionBlock completionBlock;

//This is used to jump the object to its correct final state if the animations are cancelled
@property (nonnull, strong, nonatomic) CTMFAnimationBlock finalStateAnimationBlock;

@property (nonatomic) UIViewAnimationOptions animationOptions;

@property (nonatomic) CTMFAnimationPriority animationPriority;
@property (nonatomic) float animationDelay;
@property (nonatomic) float animationDuration;
@property (nonatomic) BOOL animationPlayed;


extern float const HeightOffsetForAnimation;
extern float const WidthOffsetForAnimation;
extern float const RotationOffsetForAnimation;
extern float const StartAlphaForAnimation;
extern float const EndAlphaForAnimation;

extern float const AnimationDurationExtraLong;
extern float const AnimationDurationLong;
extern float const AnimationDurationDefault;
extern float const AnimationDurationShort;
extern float const AnimationDurationInstant;
extern float const AnimationDelayLong;
extern float const AnimationDelayDefault;
extern float const AnimationDelayShort;
extern float const AnimationDelayInstant;


#pragma mark - Lifecycle

-(nullable instancetype) initWithAnimationPriority : (int) newAnimationPriority AnimationDelay : (float) newAnimationDelay AnimationDuration : (float) newAnimationDuration AnimationOptions: (UIViewAnimationOptions) newAnimationOptions AnimationBlock : (nonnull CTMFAnimationBlock) newAnimationBlock CompletionBlock : (nullable CTMFCompletionBlock) newCompletionBlock FinalStateAnimationBlock : (nonnull CTMFAnimationBlock) newFinalStateAnimationBlock;

#pragma mark - Sorting

-(NSComparisonResult) compareDelay:(nonnull CTMFAnimation *)comparisonObject;

#pragma mark - Generic Animations
//In all functions below, IsInitialization is whether this is the intial state (YES) or the animation state (NO)

//Generally used for buttons and images
+(void) fadeIn:(nonnull UIView *)obj IsInitialization:(BOOL)setup;

//Generally used for buttons and images
+(void) fadeOut:(nonnull UIView *)obj IsInitialization:(BOOL)setup;

+(void) fade:(nonnull UIView *)obj targetAlpha:(float)alpha;

//Table cells and text
+(void) fadeInAndShiftUp:(nonnull UIView *)obj IsInitialization:(BOOL)setup;

//Feed cells
+(void) fadeInAndSpinUp:(nonnull UIView *)obj TargetFrame:(CGRect)frame IsInitialization:(BOOL)setup;

//Feature cells
+(void) fadeInAndSpinLeft:(nonnull UIView *)obj TargetFrame:(CGRect)frame IsInitialization:(BOOL)setup;

//Feature cells in Collection Views
+(void) fadeInAndShiftLeft:(nonnull UIView *)obj IsInitialization:(BOOL)setup;

//Feature cells in Collection Views
+(void) shiftToSide:(nonnull UIView *)obj IsInitialization:(BOOL)setup IsLeft:(BOOL)isLeft;


#pragma mark - Frame helper functions
+(void) scale:(nonnull UIView *)obj ScaleFactor:(CGFloat)scaleFactor MaintainCenterPosition:(BOOL)maintainCenter;

+(void) scaleHeight:(nonnull UIView *)obj ScaleFactor:(CGFloat)scaleFactor MaintainCenterPosition:(BOOL)maintainCenter;

+(void) scaleWidth:(nonnull UIView *)obj ScaleFactor:(CGFloat)scaleFactor MaintainCenterPosition:(BOOL)maintainCenter;

+(void) setFrame:(nonnull UIView *)obj NewFrame:(CGRect)frame;

#pragma mark - Cell entrance convenience function
+(void) performCellAnimation:(nonnull UIView *)cell AnimationsRegistered:(BOOL)animationsRegistered;




@end
