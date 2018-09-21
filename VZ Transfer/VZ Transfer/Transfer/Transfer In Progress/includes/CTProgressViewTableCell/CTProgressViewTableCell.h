//
//  CTProgressViewTableCell.h
//  contenttransfer
//
//  Created by Mehta, Snehal Natwar on 8/17/16.
//  Copyright © 2016 Verizon. All rights reserved.
//

#import "CTProgressView.h"
#import "CTTransferInProgressTableCell.h"
#import <UIKit/UIKit.h>

/*!Progress cell using in progress view.*/
@interface CTProgressViewTableCell : CTTransferInProgressTableCell

@property (nonatomic, weak) IBOutlet CTProgressView *customProgressView;

@end
