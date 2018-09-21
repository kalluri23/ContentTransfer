//
//  UILabel+CTLabelAdjust.m
//  contenttransfer
//
//  Created by Sun, Xin on 6/27/17.
//  Copyright © 2017 Verizon Wireless Inc. All rights reserved.
//

#import "UILabel+CTLabelAdjust.h"

@implementation UILabel (CTLabelAdjust)

- (CGFloat)getTextWidth {
    CGRect frame = [self getTextFrame];
    return frame.size.width;
}

- (CGFloat)getTextHeight {
    CGRect frame = [self getTextFrame];
    return frame.size.height;
}

- (CGRect)getTextFrame {
    CGRect frame = [self.text boundingRectWithSize:self.frame.size options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:self.font} context:nil];
    return frame;
}

@end
