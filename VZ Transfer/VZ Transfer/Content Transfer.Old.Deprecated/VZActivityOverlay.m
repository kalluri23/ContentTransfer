//
//  VZActivityOverlay.m
//  VZTransferSocket
//
//  Created by Prakash Mac on 12/29/15.
//  Copyright © 2015 Testing. All rights reserved.
//

#import "VZActivityOverlay.h"

@interface VZActivityOverlay ()

@end

@implementation VZActivityOverlay

@synthesize overLay;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor redColor];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)CancelBtnPressed:(id)sender {
    
    [self removeFromParentViewController];
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
