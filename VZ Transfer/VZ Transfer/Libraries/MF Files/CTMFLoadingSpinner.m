//
//  CTMFLoadingSpinner.m
//  mobilefirst
//
//  Created by Wesolowski, Brendan on 3/10/16.
//  Copyright © 2016 Verizon Wireless. All rights reserved.
//

#import "CTMFLoadingSpinner.h"
#import "CTMFAnimation.h"
#import "CTMFAnimationController.h"

@interface CTMFLoadingSpinner ()

@property (strong, nonatomic) CAShapeLayer *myCircle;
@property (strong, nonatomic) CADisplayLink *myDisplay;

@property (nonatomic) double prevFrame;

@property (nonatomic) BOOL isFast;

@end

@implementation CTMFLoadingSpinner

@synthesize animationsRegistered = _animationsRegistered;
@synthesize shouldAnimate = _shouldAnimate;
@synthesize showFullAnimations = _showFullAnimations;

const float radius = 18.0;
const float lineWidth = 3.0;
const float slowSpeed = 0.5;
const float fastSpeed = 2.0;
const float startSpeed = 1.0;
const float fastDistance = .45;
const float slowDistance = 0.1;


-(void)finalize {
	[self.myDisplay invalidate];
	self.myDisplay = nil;
}

-(void)setUpCircle {
	[self setUpCircle:[UIColor blackColor]];
}

-(void)setUpCircle:(UIColor *)strokeColor {
	if(self.myCircle)
	{
		return;
	}
	
	CAShapeLayer *circle = [CAShapeLayer layer];
	circle.path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(radius, radius) radius:radius startAngle:-M_PI_2 endAngle:3.5*M_PI clockwise:YES].CGPath;
	circle.lineWidth = lineWidth;
	circle.fillColor = [UIColor clearColor].CGColor;
	circle.strokeColor = strokeColor.CGColor;
	circle.lineCap = kCALineCapButt;
	circle.strokeStart = 0;
	circle.strokeEnd = 0+.05;
	[self.layer addSublayer:circle];
	self.myCircle = circle;
	
	self.isFast = YES;
	
	NSMutableDictionary *newActions = [[NSMutableDictionary alloc] initWithObjectsAndKeys:[NSNull null], @"strokeStart",
									   [NSNull null], @"strokeEnd",
									   [NSNull null], @"strokeColor",
									   nil];
	circle.actions = newActions;

	self.myDisplay = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateSpinner)];
	[self.myDisplay addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
	self.myDisplay.frameInterval = 2;
	self.prevFrame = CACurrentMediaTime();
}

-(void)changeColor:(UIColor *)strokeColor {
	self.myCircle.strokeColor = strokeColor.CGColor;
}

-(void)updateSpinner {
	double currentTime = CACurrentMediaTime();
	double renderTime = currentTime - self.prevFrame;
	self.prevFrame = currentTime;
	
	if(self.myCircle.strokeStart > 0.5 && self.myCircle.strokeEnd > 0.5) {
		self.myCircle.strokeStart -= 0.5;
		self.myCircle.strokeEnd -= 0.5;
	}

	float distanceToStart = self.myCircle.strokeEnd - self.myCircle.strokeStart;
	if(distanceToStart < slowDistance && !self.isFast) {
		self.isFast = YES;
	}
	else if(distanceToStart > fastDistance && self.isFast) {
		self.isFast = NO;
	}
	self.myCircle.strokeEnd += (self.isFast ? fastSpeed : slowSpeed) * renderTime;
	self.myCircle.strokeStart+= startSpeed * renderTime;
}

-(void)pauseSpinner {
	self.myDisplay.paused = YES;
}

-(void)resumeSpinner {
	if(!self.myCircle) {
		[self setUpCircle];
		return;
	}
	
	self.myDisplay.paused = NO;
	self.prevFrame = CACurrentMediaTime();
}

//float const AnimationDurationDefault = 0.3;

-(void)removeFromSuperviewAnimated {
	__weak CTMFLoadingSpinner *weakSelf = self;
	[UIView animateWithDuration:AnimationDurationDefault animations:^{
		weakSelf.alpha = 0;
	} completion:^(BOOL finished) {
		[weakSelf removeFromSuperview];
	}];
}
#pragma mark - Animations

-(void)registerAnimations {
	[self registerAnimations:CTMFAnimationPriorityBody];
}

-(void)registerAnimations:(uint)animationPriority {
	if(self.animationsRegistered || !self.shouldAnimate) {
		return;
	}
	self.animationsRegistered = YES;
	
	CTMFAnimationController *animationController = [CTMFAnimationController sharedGlobal];
	
	__weak CTMFLoadingSpinner *weakSelf = self;
	
	float originalAlpha = self.alpha;
	[CTMFAnimation fade:self targetAlpha:StartAlphaForAnimation];
	
	CTMFAnimation *fadeInAnimation = [CTMFAnimation new];
	fadeInAnimation.animationPriority = animationPriority;
	fadeInAnimation.animationDuration = AnimationDurationDefault;
	fadeInAnimation.animationDelay = AnimationDelayDefault;
	fadeInAnimation.animationOptions = UIViewAnimationOptionCurveEaseOut;
	fadeInAnimation.animationBlock = ^{
		[CTMFAnimation fade:weakSelf targetAlpha:originalAlpha];
	};
	fadeInAnimation.finalStateAnimationBlock = fadeInAnimation.animationBlock;
	fadeInAnimation.completionBlock = nil;
	
	[animationController registerAnimation: fadeInAnimation];
	
}

-(void)prepareAnimations {
	[CTMFAnimation fadeOut:self IsInitialization:YES];
}

-(void)performAnimations {
	[UIView animateWithDuration:0.3 delay:0.1 options:UIViewAnimationOptionCurveEaseOut animations:^{
		[CTMFAnimation fadeOut:self IsInitialization:NO];
	} completion:nil];
}

@end
