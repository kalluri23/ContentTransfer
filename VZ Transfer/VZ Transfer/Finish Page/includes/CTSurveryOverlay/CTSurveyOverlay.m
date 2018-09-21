//
//  CTSurveyOverlay.m
//  contenttransfer
//
//  Created by Mehta, Snehal Natwar on 9/27/16.
//  Copyright © 2016 Verizon Wireless. All rights reserved.
//

#import "CTSurveyOverlay.h"
#import "VZViewUtility.h"
#import "CTDeviceMarco.h"

@implementation CTSurveyOverlay

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)awakeFromNib {
    [super awakeFromNib];
}

+ (CTSurveyOverlay *)customView {
    
    CTSurveyOverlay *customView =
    [[[VZViewUtility bundleForFramework] loadNibNamed:NSStringFromClass([CTSurveyOverlay class])
                                                owner:nil
                                              options:nil] lastObject];
    
    if ([customView isKindOfClass:[CTSurveyOverlay class]]) {
        return customView;
    } else {
        return nil;
    }
}

@end
