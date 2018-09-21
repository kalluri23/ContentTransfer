//
//  UIView+CTMVMRect.m
//  contenttransfer
//
//  Created by Hadapad, Prakash on 8/31/16.
//  Copyright © 2016 Hadapad, Prakash. All rights reserved.
//

#import "UIView+CTMVMRect.h"

@implementation UIView (CTMVMRect)

- (CGFloat)viewHeight {
    [self layoutIfNeeded];
    [self setNeedsLayout];
    return CGRectGetHeight(self.bounds);
}

-(CGFloat)subviewContentHeight {
    CGFloat h = 0;
    for (UIView *v in [self subviews]) {
        h = MAX(CGRectGetMaxY(v.frame), h);
    }
    return h;
}

- (void) matchFrameWidthTo:(UIView *)view {
    CGRect frame = self.frame;
    frame.size.width = CGRectGetWidth(view.frame);
    self.frame = frame;
}


@end
