//
//  CTSenderWaitingViewController.m
//  contenttransfer
//
//  Created by Mehta, Snehal Natwar on 9/8/16.
//  Copyright © 2016 Verizon Wireless. All rights reserved.
//

#import "CTSenderWaitingViewController.h"
#import "CTStartedViewController.h"
#import "CTSenderTransferViewController.h"
#import "CTStoryboardHelper.h"
#import "CTCustomAlertView.h"

@interface CTSenderWaitingViewController ()

@property (nonatomic, strong) CTCustomAlertView * alertView;

@property (nonatomic, strong) CTSenderTransferViewController *transferWhatPage;

@end

//static float kProgress = .49;

@implementation CTSenderWaitingViewController

- (CTCustomAlertView *)alertView {
    if (!_alertView) {
        _alertView = [[CTCustomAlertView alloc] initCustomAlertViewWithText:CTLocalizedString(kConnectingDialogContext, nil) withOritation:CTAlertViewOritation_HORIZONTAL];
    }
    
    return _alertView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = CTLocalizedString(CT_WIFI_SETUP_VC_NAV_TITLE, nil);
#if STANDALONE
    [self setNavigationControllerMode:CTNavigationControllerMode_None];
#else
    [self setNavigationControllerMode:CTNavigationControllerMode_BackAndHamburgar];
#endif
    
//    self.progressView.progress = kProgress;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self showConnectingDialog];
}

- (void)senderWaitingViewShouldGoBack {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)senderWaitingViewShouldGoForward {
    // alert to upgrade other device
    //Add logic for moving to WiFi
    self.transferWhatPage = [CTSenderTransferViewController initialiseFromStoryboard:[CTStoryboardHelper transferStoryboard]];
    self.transferWhatPage.transferFlow = self.transferFlow;
    [self.navigationController pushViewController:self.transferWhatPage animated:YES];
}

- (void)senderWaitingViewShouldPopToRoot {
    NSArray *viewStacks = self.navigationController.viewControllers;
    for (int i=0; i<viewStacks.count; i++) { // find to root view controller in the view stack, in case of adding more views in stack and change the index of the view
        UIViewController *controller = (UIViewController *)[viewStacks objectAtIndex:i];
        if ([controller isKindOfClass:[CTStartedViewController class]]) { // pop to root
            [self.navigationController popToViewController:controller animated:YES];
            break;
        }
    }
}

- (void)showConnectingDialog {
    [self.alertView show];
}

- (void)dismissConnectingDialog {
    [self.alertView hide:nil];
}

- (void)senderShouldPushCancel {
    if (self.transferWhatPage) {
        [self.transferWhatPage viewShouldGoToCancelPage];
    }
}

@end
