//
//  CTDeviceSelectionViewController.h
//  contenttransfer
//
//  Created by Development on 8/11/16.
//  Copyright © 2016 Verizon. All rights reserved.
//

#import "CTViewController.h"
#import <UIKit/UIKit.h>

/*!
 Device selection page for content transfer during setup process.
 */
@interface CTDeviceSelectionViewController : CTViewController

@property (nonatomic, weak) IBOutlet UITableView *deviceSelectionTable;
@property (nonatomic, weak) IBOutlet UIButton *nextButton;

@end
