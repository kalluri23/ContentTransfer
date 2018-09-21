//
//  CTBonjourSenderViewController.h
//  contenttransfer
//
//  Created by Development on 8/15/16.
//  Copyright © 2016 Verizon. All rights reserved.
//

#import "CTCustomButton.h"
#import "CTGenericBonjourViewController.h"

/*! Bonjour sender page.*/
@interface CTBonjourSenderViewController : CTGenericBonjourViewController

@property (nonatomic, weak) IBOutlet UITableView *devicesTableView;
@property (nonatomic, weak) IBOutlet CTCommonBlackButton *nextButton;
@property (nonatomic, weak) IBOutlet CTBlackBorderedButton *searchAgainButton;

@end
