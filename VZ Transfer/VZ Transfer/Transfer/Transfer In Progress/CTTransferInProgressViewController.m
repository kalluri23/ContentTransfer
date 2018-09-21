//
//  CTTransferInProgressViewController.m
//  contenttransfer
//
//  Created by Mehta, Snehal Natwar on 8/17/16.
//  Copyright © 2016 Verizon. All rights reserved.
//

#import "CTProgressViewTableCell.h"
#import "CTTransferInProgressTableCell.h"
#import "CTTransferInProgressViewController.h"
#import "CTTransferFinishViewController.h"
#import "CTDataSavingViewController.h"
#import "CTStoryboardHelper.h"
#import "CTBundle.h"
#import "CTDeviceSelectionViewController.h"
#import "CTStartedViewController.h"
#import "CTDeviceMarco.h"

@interface CTTransferInProgressViewController ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleTopMarginConstraint;

@end

//static float kProgress = .7;

@implementation CTTransferInProgressViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    NSAssert(self.transferInProgressTableView.dataSource == nil,
             @"transferInProgressTableView datasource should be implemented in subclass");

    self.title = CTLocalizedString(CT_TRANSFER_NAV_TITLE, nil);
//    self.progressView.progress = kProgress;

#if STANDALONE
    [self setNavigationControllerMode:CTNavigationControllerMode_None];
#else
    [self setNavigationControllerMode:CTNavigationControllerMode_BackAndHamburgar];
#endif
    
    if ([CTDeviceMarco isiPhoneX]) {
        self.titleTopMarginConstraint.constant += 24.0;
    }
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    #if STANDALONE
    self.topSpaceConstraint.constant = 30.0;
    #else
    self.topSpaceConstraint.constant = [[UIApplication sharedApplication] statusBarFrame].size.height + [[self.navigationController navigationBar] frame].size.height + 30.0;
    #endif
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showDataSavingsViewController {
    CTDataSavingViewController *dataSavingViewController = [[CTDataSavingViewController alloc]
                                                            initWithNibName:NSStringFromClass([CTDataSavingViewController class])
                                                            bundle:[CTBundle resourceBundle]];
    dataSavingViewController.transferFlow = CTTransferFlow_Sender;
    [self.navigationController pushViewController:dataSavingViewController animated:YES];
}

- (void)showTransferFinishViewController {
    UIStoryboard *transferStoryboard = [CTStoryboardHelper transferStoryboard];
    CTTransferFinishViewController *transferFinishViewController = [CTTransferFinishViewController initialiseFromStoryboard:transferStoryboard];
    [self.navigationController pushViewController:transferFinishViewController animated:YES];
}

- (void)popToRootViewContorller
{
    NSArray *viewStacks = self.navigationController.viewControllers;
    for (int i=0; i<viewStacks.count; i++) { // find to root view controller in the view stack, in case of adding more views in stack and change the index of the view
        UIViewController *controller = (UIViewController *)[viewStacks objectAtIndex:i];
        if ([controller isKindOfClass:[CTStartedViewController class]]) { // pop to root
            [self.navigationController popToViewController:controller animated:YES];
            break;
        }
    }
}

//-(void)cleanupSocket{
//    
//}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
