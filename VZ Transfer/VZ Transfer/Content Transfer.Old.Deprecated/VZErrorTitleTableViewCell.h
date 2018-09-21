//
//  VZErrorTitleTableViewCell.h
//  myverizon
//
//  Created by Sun, Xin on 5/2/16.
//  Copyright © 2016 Verizon Wireless. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VZErrorTitleTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *fileLbl;
@property (weak, nonatomic) IBOutlet UILabel *DurationLbl;
@property (weak, nonatomic) IBOutlet UILabel *failLbl;
@end
