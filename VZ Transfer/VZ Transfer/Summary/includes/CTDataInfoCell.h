//
//  CTDataInfoCell.h
//  contenttransfer
//
//  Created by Sun, Xin on 4/21/17.
//  Copyright © 2017 Verizon Wireless Inc. All rights reserved.
//

#import "CTCustomTableViewCell.h"

/*!Table view cell using to show in recap page.*/
@interface CTDataInfoCell : CTCustomTableViewCell

/*!YES when there was an error while transferring.*/
@property (nonatomic, assign) BOOL isTransferError;

@property (nonatomic, weak) IBOutlet UIImageView *statusImageView;
@property (nonatomic, weak) IBOutlet UILabel *dataLabel;
@property (nonatomic, weak) IBOutlet UILabel *dataInfoLabel;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *iconWidth;
@property (weak, nonatomic) IBOutlet UIView *customerSeparator;

@end
