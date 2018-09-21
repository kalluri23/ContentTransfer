//
//  CTSingleLabelCheckboxCell.m
//  contenttransfer
//
//  Created by Sun, Xin on 4/21/17.
//  Copyright © 2017 Verizon Wireless Inc. All rights reserved.
//

#import "CTSingleLabelCheckboxCell.h"
#import "UIImage+Helper.h"

@implementation CTSingleLabelCheckboxCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.isUserInteractionEnabled = YES;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.checkboxImageView.image = [UIImage getImageFromBundleWithImageName:@"oval25Copy3"];
}

- (void)highlightCell:(BOOL)highlight {
    
    if (highlight) {
        self.checkboxImageView.image = [UIImage getImageFromBundleWithImageName:@"RadioButtonChecked"];
        
    }else {
        self.checkboxImageView.image = [UIImage getImageFromBundleWithImageName:@"oval25Copy3"];
    }
}

- (void)enableUserInteraction:(BOOL)shouldEnable {
    self.isUserInteractionEnabled = shouldEnable;
}

@end
