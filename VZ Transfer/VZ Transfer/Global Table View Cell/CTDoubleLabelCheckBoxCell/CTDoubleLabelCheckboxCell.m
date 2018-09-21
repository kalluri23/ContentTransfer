//
//  CTDoubleLabelCheckboxCell.m
//  contenttransfer
//
//  Created by Sun, Xin on 4/21/17.
//  Copyright © 2017 Verizon Wireless Inc. All rights reserved.
//

#import "CTDoubleLabelCheckboxCell.h"
#import "UILabel+CTLabelAdjust.h"

@implementation CTDoubleLabelCheckboxCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
}

- (void)simulateThirdLabelAsAButton {
    // Change third color to a button title color
    self.thirdLabel.textColor = [CTMVMColor mvmPrimaryBlueColor];
    CGFloat txtWidth = [self.thirdLabel getTextWidth];
    
    [self.thirdLabel layoutIfNeeded];
    
    self.moreInfoButton = [[UIButton alloc] initWithFrame:CGRectMake(self.thirdLabel.frame.size.width - txtWidth, 0, txtWidth, self.thirdLabel.frame.size.height)];
    [self.moreInfoButton setBackgroundColor:[UIColor clearColor]];
    [self.thirdLabel addSubview:self.moreInfoButton];
    [self bringSubviewToFront:self.thirdLabel];
}
@end
