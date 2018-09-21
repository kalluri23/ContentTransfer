//
//  CTPhoneCombinationViewController.h
//  contenttransfer
//
//  Created by Development on 8/12/16.
//  Copyright © 2016 Verizon. All rights reserved.
//

#import "CTViewController.h"

/*! Phone combination page. This page allow user to pick new/old pair for their device.*/
@interface CTPhoneCombinationViewController : CTViewController

@property (nonatomic, weak) IBOutlet UITableView *phoneCombinationTableView;
@property (nonatomic, weak) IBOutlet UIButton *nextButton;
@property (weak, nonatomic) IBOutlet UIButton *stmButton;

@end
