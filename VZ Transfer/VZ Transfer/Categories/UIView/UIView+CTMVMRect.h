//
//  UIView+CTMVMRect.h
//  contenttransfer
//
//  Created by Hadapad, Prakash on 8/31/16.
//  Copyright © 2016 Hadapad, Prakash. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (CTMVMRect)

// Returns the height of the view
- (CGFloat)viewHeight;

- (CGFloat) subviewContentHeight;

- (void) matchFrameWidthTo:(UIView *)view;

@end
