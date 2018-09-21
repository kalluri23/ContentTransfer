//
//  EulaViewController.m
//  contenttransfer
//
//  Created by Hadapad, Prakash on 7/13/16.
//  Copyright © 2016 Hadapad, Prakash. All rights reserved.
//

#import "EulaViewController.h"
//#import "VZDeviceSelectionVC.h"
#import "CTMVMButtons.h"
#import "CTMVMAlertHandler.h"
#import "CTCustomButton.h"

@interface EulaViewController ()
@property (weak, nonatomic) IBOutlet CTCommonBlackButton *acceptBtn;
@property (weak, nonatomic) IBOutlet UIWebView *webView;

//@property (weak, nonatomic) IBOutlet CTRedBorderedButton *declineBtn;
@end

@implementation EulaViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = CTLocalizedString(kDefaultAppTitle, nil);
    _webView.scalesPageToFit = YES;
    
    NSString *urlAddress = [[NSBundle mainBundle] pathForResource:@"Eula"
                                                           ofType:@"docx"];
    
    DebugLog(@"the document url address: %@", urlAddress);
    if (urlAddress) {
        NSURL *url  = [NSURL fileURLWithPath:urlAddress];
        NSURLRequest *requestObj  = [NSURLRequest requestWithURL:url];
        
        [_webView loadRequest:requestObj];

    }
    
    [self setNavigationControllerMode:CTNavigationControllerMode_None];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//- (IBAction)declinedAgreement:(id)sender {
//    
//    CTMVMAlertAction *cancelAction = [CTMVMAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil];
//    
//    NSString *message = @"Please accept the Terms and Conditions to continue.";
//    
//    [[CTMVMAlertHandler sharedAlertHandler] showAlertWithTitle:@"Content Transfer" message:message cancelAction:cancelAction otherActions:nil isGreedy:NO];
//    
//}

- (IBAction)acceptAgreement:(id)sender {

    [CTUserDefaults sharedInstance].contentTransferEulaAgreement = YES;
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}


@end
