//
//  CTTransferInProgressTableCell.h
//  contenttransfer
//
//  Created by Mehta, Snehal Natwar on 8/17/16.
//  Copyright © 2016 Verizon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CTCustomLabel.h"

/*!Information cell using in progress page.*/
@interface CTTransferInProgressTableCell : UITableViewCell

@property (nonatomic, weak) IBOutlet CTNHaasGroteskDSStd65MdLabel *keyLabel;
@property (nonatomic, weak) IBOutlet CTRomanFontLabel *valueLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leftMargin;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *rightMargin;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *widthOfValueLabel;

@end
