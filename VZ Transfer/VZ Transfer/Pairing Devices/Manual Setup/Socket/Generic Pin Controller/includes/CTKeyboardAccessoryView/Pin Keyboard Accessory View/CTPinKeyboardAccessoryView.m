//
//  CTPinKeyboardAccessoryView.m
//  contenttransfer
//
//  Created by Development on 8/16/16.
//  Copyright © 2016 Verizon. All rights reserved.
//

#import "CTPinKeyboardAccessoryView.h"
#import "VZViewUtility.h"

@implementation CTPinKeyboardAccessoryView

- (void)awakeFromNib {
    [super awakeFromNib];
}

+ (CTPinKeyboardAccessoryView *)customView {

    CTPinKeyboardAccessoryView *customView =
        [[[VZViewUtility bundleForFramework] loadNibNamed:NSStringFromClass([CTPinKeyboardAccessoryView class])
                                                    owner:nil
                                                  options:nil] lastObject];

    if ([customView isKindOfClass:[CTPinKeyboardAccessoryView class]]) {
        return customView;
    } else {
        return nil;
    }
}

@end
