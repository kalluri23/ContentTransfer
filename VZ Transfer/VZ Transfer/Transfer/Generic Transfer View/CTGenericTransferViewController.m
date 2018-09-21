//
//  CTGenericTransferViewController.m
//  contenttransfer
//
//  Created by Development on 8/16/16.
//  Copyright © 2016 Verizon. All rights reserved.
//

#import "CTGenericTransferViewController.h"
#import "CTNetworkUtility.h"

@interface CTGenericTransferViewController ()

@end

//static float kProgress = .65;

@implementation CTGenericTransferViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [CTUserDevice userDevice].connectedNetworkName = [CTNetworkUtility connectedNetworkName];

    // Do any additional setup after loading the view.
    self.title = CTLocalizedString(CT_TRANSFER_NAV_TITLE, nil);
//    self.progressView.progress = kProgress;

#if STANDALONE
    [self setNavigationControllerMode:CTNavigationControllerMode_None];
#else
    [self setNavigationControllerMode:CTNavigationControllerMode_BackAndHamburgar];
#endif
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
