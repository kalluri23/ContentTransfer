//
//  CTSenderTransferTableViewCell.m
//  contenttransfer
//
//  Created by Sun, Xin on 9/28/17.
//  Copyright © 2017 Verizon Wireless Inc. All rights reserved.
//

#import "CTSenderTransferTableViewCell.h"
#import "UILabel+CTLabelAdjust.h"
#import "UIImage+Helper.h"

@interface CTSenderTransferTableViewCell()

@property(nonatomic, assign) BOOL isUserInteractionEnabled;

@end

@implementation CTSenderTransferTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.isUserInteractionEnabled = YES;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.checkboxImageView.image = [UIImage getImageFromBundleWithImageName:@"checkbox-unchecked"];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)simulateThirdLabelAsAButton {
    // Change third color to a button title color
    self.thirdLabel.textColor = [CTMVMColor blackColor];
    CGFloat txtWidth = [self.thirdLabel getTextWidth];
    
    [self.thirdLabel layoutIfNeeded];
    
    self.moreInfoButton = [[UIButton alloc] initWithFrame:CGRectMake(self.thirdLabel.frame.size.width - txtWidth, 0, txtWidth, self.thirdLabel.frame.size.height)];
    [self.moreInfoButton setBackgroundColor:[UIColor clearColor]];
    [self.thirdLabel addSubview:self.moreInfoButton];
    [self bringSubviewToFront:self.thirdLabel];
}

- (void)highlightCell:(BOOL)highlight {
    if(highlight) {
        self.checkboxImageView.image = [UIImage getImageFromBundleWithImageName:@"checkbox-checked"];
        
    } else {
        self.checkboxImageView.image = [UIImage getImageFromBundleWithImageName:@"checkbox-unchecked"];
    }
}

- (void)enableUserInteraction:(BOOL)shouldEnable {
    self.isUserInteractionEnabled = shouldEnable;
}

@end
