//
//  CTCustomTableViewCell.m
//  contenttransfer
//
//  Created by Development on 8/12/16.
//  Copyright © 2016 Verizon. All rights reserved.
//

#import "CTCustomTableViewCell.h"
#import "CTMVMStyler.h"
#import "UIImage+Helper.h"

@implementation CTCustomTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    for (UIView *subview in self.contentView.superview.subviews) {
        if ([NSStringFromClass(subview.class) hasSuffix:@"SeparatorView"]) {
            subview.hidden = NO;
        }
    }
}

@end

