//
//  LeftRightTextButtonHeaderFooterView.h
//  myverizon
//
//  Created by Scott Pfeil on 1/30/16.
//  Copyright © 2016 Verizon Wireless. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LeftRightTextButtonHeaderFooterView : UITableViewHeaderFooterView

@property (nullable, nonatomic, weak) UIButton *leftButton;
@property (nullable, nonatomic, weak) UIButton *rightButton;

@end
