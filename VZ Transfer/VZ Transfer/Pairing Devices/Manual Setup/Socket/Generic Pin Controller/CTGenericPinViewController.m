//
//  CTGenericPinViewController.m
//  contenttransfer
//
//  Created by Development on 8/16/16.
//  Copyright © 2016 Verizon. All rights reserved.
//

#import "CTGenericPinViewController.h"
#import "CTNetworkUtility.h"

@interface CTGenericPinViewController ()

@end

@implementation CTGenericPinViewController

//static float kProgress = .49;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.title = CTLocalizedString(CT_WIFI_SETUP_VC_NAV_TITLE, nil);
//    self.progressView.progress = kProgress;
#if STANDALONE
    [self setNavigationControllerMode:CTNavigationControllerMode_None];
#else
    [self setNavigationControllerMode:CTNavigationControllerMode_BackAndHamburgar];
#endif
    
    if ([CTNetworkUtility connectedNetworkName]) {
        
        self.wifiNameLabel.text = [CTNetworkUtility connectedNetworkName];
        
    } else {
        
        self.wifiNameLabel.text = CTLocalizedString(NOT_CONNECTED_WIFI_ACCESS_POINT, nil);
    }
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidBecomeActive:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
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
