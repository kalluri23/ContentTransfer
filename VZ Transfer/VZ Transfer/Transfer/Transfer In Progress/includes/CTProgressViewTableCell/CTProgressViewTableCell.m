//
//  CTProgressViewTableCell.m
//  contenttransfer
//
//  Created by Mehta, Snehal Natwar on 8/17/16.
//  Copyright © 2016 Verizon. All rights reserved.
//

#import "CTProgressViewTableCell.h"
#import "CTColor.h"

@implementation CTProgressViewTableCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.customProgressView.trackColor = [CTColor trackColor];
    self.customProgressView.progressColor = [CTColor progressColor];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
