//
//  CTProgressView.m
//  contenttransfer
//
//  Created by Mehta, Snehal Natwar on 8/18/16.
//  Copyright © 2016 Verizon. All rights reserved.
//

#import "CTColor.h"
#import "CTProgressView.h"

@implementation CTProgressView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
@synthesize progressColor, trackColor, progressView, progress;

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.clipsToBounds = YES;
        self.progressView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, frame.size.height)];
        [self addSubview:self.progressView];
    }

    return self;
}

- (void) setFrame:(CGRect)frame
{
    [super setFrame:frame];
    
    self.progressView.frame = CGRectMake(0, 0, self.frame.size.width * progress, frame.size.height);
   
    
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];

    if (self) {
        self.clipsToBounds = YES;
        self.progressView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, self.frame.size.height)];
        [self addSubview:self.progressView];
    }

    return self;
}

- (void)setProgressColor:(UIColor *)theProgressColor {
    self.progressView.backgroundColor = theProgressColor;
    progressColor = theProgressColor;
}

- (void)setTrackColor:(UIColor *)theTrackColor {
    self.backgroundColor = theTrackColor;
    trackColor = theTrackColor;
}

- (void)setProgress:(float)theProgress {

    NSAssert(self.trackColor, @"trackColor can't be nil, check the code and set trackColor");
    NSAssert(self.progressColor, @"progressColor can't be nil, check the code and set progressColor");

    @try {
        progress = theProgress;
        CGRect theFrame = self.progressView.frame;
        theFrame.size.width = self.frame.size.width * theProgress;
        self.progressView.frame = theFrame;
    } @catch (NSException *exception) {
        DebugLog(@"Exception received %@",[exception description]);      
        progress = 0.0;
        CGRect theFrame = CGRectZero;
        theFrame.size.width = self.frame.size.width * theProgress;
        self.progressView.frame = theFrame;

    }
}
@end
