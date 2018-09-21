//
//  VZReceiveDetailTableViewCell.h
//  myverizon
//
//  Created by Sun, Xin on 5/2/16.
//  Copyright © 2016 Verizon Wireless. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VZReceiveDetailTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *numberLbl;
@property (weak, nonatomic) IBOutlet UILabel *titleLbl;
@property (weak, nonatomic) IBOutlet UIImageView *arrowIcon;

@property (assign, nonatomic) BOOL expand;
@end
