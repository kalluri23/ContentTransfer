//
//  CTTransferInProgressTableCell.m
//  contenttransfer
//
//  Created by Mehta, Snehal Natwar on 8/17/16.
//  Copyright © 2016 Verizon. All rights reserved.
//

#import "CTTransferInProgressTableCell.h"
#import "CTMVMStyler.h"

@implementation CTTransferInProgressTableCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    if (IS_STANDARD_IPHONE_6_PLUS || IS_STANDARD_IPHONE_6) {
        self.leftMargin.constant = 32.0;
        self.rightMargin.constant = 32.0;
    }else {
        self.leftMargin.constant = 32.0;
        self.rightMargin.constant = 32.0;
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
