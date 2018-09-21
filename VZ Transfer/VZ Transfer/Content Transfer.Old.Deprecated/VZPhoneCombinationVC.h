//
//  VZPhoneCombinationVC.h
//  myverizon
//
//  Created by Hadapad, Prakash on 3/21/16.
//  Copyright © 2016 Verizon Wireless. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VZCTViewController.h"

@interface VZPhoneCombinationVC : VZCTViewController
@property (weak, nonatomic) IBOutlet UILabel *selectPhoneLbl;
@property (weak, nonatomic) IBOutlet UIView *firstView;
@property (weak, nonatomic) IBOutlet UIView *secondView;
@property (weak, nonatomic) IBOutlet UILabel *firstPhone;
@property (weak, nonatomic) IBOutlet UILabel *secondPhone;
@property (weak, nonatomic) IBOutlet UILabel *thirdPhone;
@property (weak, nonatomic) IBOutlet UILabel *fourthPhone;
@property (weak, nonatomic) IBOutlet UIButton *continueBtn;
@property (weak, nonatomic) IBOutlet UIButton *firstViewBtn;
@property (weak, nonatomic) IBOutlet UIButton *secondViewBtn;
@property (nonatomic, assign) BOOL flag;
@property (weak, nonatomic) IBOutlet UIButton *cancelBtn;
@property (nonatomic, strong) NSString  *deviceType;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *firstviewTopLeadingConstriant;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *secondViewTopConstaints;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *firstVieTopConstaints;

@end
