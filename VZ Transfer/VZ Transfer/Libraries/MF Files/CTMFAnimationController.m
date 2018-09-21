//
//  CTMFAnimationController.m
//  myverizon
//
//  Created by Wesolowski, Brendan on 2/19/16.
//  Copyright © 2016 Verizon Wireless. All rights reserved.
//

#import "CTMFAnimationController.h"
#import "CTMFAnimation.h"

@interface CTMFAnimationController ()

@property (nonnull, strong, atomic) NSMutableArray *animationPriorityArray;
@property (nullable, strong, nonatomic) NSTimer *animationHeartbeatTimer;
@property (nonatomic) int currentAnimationPriority;
@property (nonatomic) int lastPlayedAnimation;
@property (nonatomic) float currentAnimationTime;
@property (nonatomic) float currentAnimationSetDuration;
@property (nonnull, strong, nonatomic) NSMutableDictionary *previouslyAnimatedPages;


@end

//CurrentAnimationPriority is an int that tells us which cell of the animationPriorityArray we're in. currentAnimationTime is a float updated each heartbeat and is used to go through the nested array (compare the current time to the anim offset time in the object).

#pragma mark - Lifecycle

@implementation CTMFAnimationController

int const NumberOfTransitionsBeforeAnimateAgain = 3;

+ (nullable instancetype)sharedGlobal {
	static dispatch_once_t once;
	static id sharedInstance;
	
	dispatch_once(&once, ^
				  {
					  sharedInstance = [[self alloc] init];
				  });
	
	return sharedInstance;
}

-(nullable instancetype) init {
	if (self = [super init]) {
		_animationPriorityArray = [NSMutableArray new];
		_previouslyAnimatedPages = [NSMutableDictionary new];
	}
	return self;
}

#pragma mark - Animation Methods

//NOTE: it tracks objects by ClassName+NavigationItemTitle. This may cause issues
//if pages have the same class and the same title
-(BOOL)shouldShowFullAnimations:(NSString *)className
{
	if([self.previouslyAnimatedPages objectForKey:className]) {
		return [self.previouslyAnimatedPages[className] intValue] <= 0;
	}
	return YES;
}

//Registrations called while the page is animated are added to the end of the priority bucket they specify.
//This can lead to animations being skipped if self.currentAnimationPriority is higher than the specified priority.
-(void)registerAnimation:(nonnull CTMFAnimation *)animation {
	while(animation.animationPriority >= self.animationPriorityArray.count) {
		[self.animationPriorityArray addObject: [NSMutableArray new]];
	}
	
	[self.animationPriorityArray[animation.animationPriority] addObject: animation];
}

-(void)startAnimations:(NSString *)className {
	if(self.animationHeartbeatTimer) {
		[self.animationHeartbeatTimer invalidate];
		self.animationHeartbeatTimer = nil;
	}
	
	__weak __block CTMFAnimationController *weakSelf = self;
	[self.previouslyAnimatedPages enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
		if(![key isEqualToString:className]) {
			weakSelf.previouslyAnimatedPages[key] = [NSNumber numberWithInt:[obj intValue] - 1];
		}
		if([obj intValue] <= 0) {
			[weakSelf.previouslyAnimatedPages removeObjectForKey:key];
		}
	}];
	
	if([self.previouslyAnimatedPages objectForKey:className]) {
		self.previouslyAnimatedPages[className] = [NSNumber numberWithInt:NumberOfTransitionsBeforeAnimateAgain];
	}
	
	[self.previouslyAnimatedPages setObject:[NSNumber numberWithInt:NumberOfTransitionsBeforeAnimateAgain] forKey:className];
	
	self.animationHeartbeatTimer = [NSTimer scheduledTimerWithTimeInterval:.01 target:self selector:@selector(animationTimerTick) userInfo:nil repeats:YES];
	
	[[NSRunLoop currentRunLoop] addTimer:self.animationHeartbeatTimer forMode:NSRunLoopCommonModes];
	
	self.currentAnimationPriority = 0;
	self.currentAnimationTime = 0.0;
	self.currentAnimationSetDuration = 0.0;
	self.lastPlayedAnimation = 0;
	
	//Uncomment to re-enable absolute delays. --Brendan Wesolowski
	/*[self.animationPriorityArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
		[obj sortUsingSelector:@selector(compareDelay:)];
	}];*/
}

-(void) animationTimerTick {
	if(self.currentAnimationPriority == self.animationPriorityArray.count ||
	   self.currentAnimationPriority == CTMFAnimationPriorityTriggeredOnEnd) {
		[self endAnimations:NO];
		return;
	}
	
	self.currentAnimationSetDuration -= self.animationHeartbeatTimer.timeInterval;
	
	if(self.currentAnimationSetDuration > 0 && self.lastPlayedAnimation == 0)
		return;
	
	self.currentAnimationTime += self.animationHeartbeatTimer.timeInterval;
	
	NSMutableArray *currentAnimationList = (NSMutableArray *)self.animationPriorityArray[self.currentAnimationPriority];
	for(int i = self.lastPlayedAnimation; i <= currentAnimationList.count; ++i)
	{
		if(i == currentAnimationList.count) {
			++self.currentAnimationPriority;
			self.currentAnimationTime = 0.0;
			self.lastPlayedAnimation = 0;
			break;
		}
		
		CTMFAnimation * currentAnimation = currentAnimationList[i];
		if(currentAnimation.animationPlayed) {
			continue;
		}
		if(self.currentAnimationTime < currentAnimation.animationDelay) {
			self.lastPlayedAnimation = i;
			break;
		}
		
		if(self.currentAnimationSetDuration < currentAnimation.animationDuration) {
			self.currentAnimationSetDuration = currentAnimation.animationDuration;
		}
		
		[UIView animateWithDuration:currentAnimation.animationDuration
							  delay:0
							options:currentAnimation.animationOptions
						 animations:currentAnimation.animationBlock
						 completion:currentAnimation.completionBlock];
		
		currentAnimation.animationPlayed = YES;
		
		self.currentAnimationTime = 0.0f; //Remove this to switch back to absolute delays  --Brendan Wesolowski
	}
}

-(void)endAnimations:(BOOL)pageTransition {
	[self.animationHeartbeatTimer invalidate];
	self.animationHeartbeatTimer = nil;
	
	if(!(self.currentAnimationPriority == self.animationPriorityArray.count)) {
		//Perform all cancelation animations from the current timestamp forward.
		for(int i = self.currentAnimationPriority; i < self.animationPriorityArray.count; ++i) {
			if(i == CTMFAnimationPriorityTriggeredOnPageTransition && !pageTransition) {
				break;
			}
			
			NSArray *currentAnimationList = (NSArray *)self.animationPriorityArray[self.currentAnimationPriority];
			
			for(int j = self.lastPlayedAnimation; j <= currentAnimationList.count; ++j) {
				if(j == currentAnimationList.count) {
					++self.currentAnimationPriority;
					self.currentAnimationTime = 0.0;
					self.lastPlayedAnimation = 0;
					break;
				}
				
				CTMFAnimation * currentAnimation = currentAnimationList[j];
				
				if(currentAnimation.animationPlayed) {
					continue;
				}
				currentAnimation.animationPlayed = YES;
				
				if(i == CTMFAnimationPriorityTriggeredOnEnd || i == CTMFAnimationPriorityTriggeredOnPageTransition) {
					[UIView animateWithDuration:currentAnimation.animationDuration
										  delay:currentAnimation.animationDelay
										options:currentAnimation.animationOptions
									 animations:currentAnimation.animationBlock
									 completion:currentAnimation.completionBlock];
					
				} else {
					[UIView animateWithDuration:0
										  delay:0
										options:currentAnimation.animationOptions
									 animations:currentAnimation.finalStateAnimationBlock
									 completion:currentAnimation.completionBlock];
				}
			}
		}
	}
	
	if(!pageTransition) {
		return;
	}
	
	[self.animationPriorityArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
		[obj removeAllObjects];
	}];
    
	[self.animationPriorityArray removeAllObjects];
	
	self.currentAnimationPriority = 0;
	self.currentAnimationTime = 0.0;
	self.currentAnimationSetDuration = 0.0;
	self.lastPlayedAnimation = 0;
}


@end
