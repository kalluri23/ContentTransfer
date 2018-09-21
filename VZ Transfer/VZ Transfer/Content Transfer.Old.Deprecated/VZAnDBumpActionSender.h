//
//  VZAnDBumpActionSender.h
//  myverizon
//
//  Created by Hadapad, Prakash on 4/1/16.
//  Copyright © 2016 Verizon Wireless. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CTMVMViewController.h"
#import "CTMVMButtons.h"
#import "CTMVMAlertAction.h"
#import "CTMVMAlertObject.h"
#import "CTMVMAlertHandler.h"
#import "VZContentTransferSingleton.h"
#import "AppDelegate.h"
#import "VZCTViewController.h"
#import "VZTransferDataViewController.h"

@interface VZAnDBumpActionSender :VZCTViewController <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *bumpAnimationImgView;
- (IBAction)clickedOnCancelBtn:(id)sender;

- (IBAction)notFoundBtn:(id)sender;
@property (weak, nonatomic) IBOutlet UITableView *deviceListView;

// Server parameters
@property (nonatomic, copy, readwrite) NSString *registeredName;
@property (weak, nonatomic) IBOutlet UILabel *availablePhoneLbl;
@property (weak, nonatomic) IBOutlet UILabel *chooseNewPhone;
@property (weak, nonatomic) IBOutlet UILabel *orLbl;
@property (weak, nonatomic) IBOutlet UILabel *shakeThisPhoneLbl;
@property (weak, nonatomic) IBOutlet UIButton *cancelBtn;
@property (weak, nonatomic) IBOutlet UIButton *notFoundBtn;
@property (weak, nonatomic) AppDelegate *app;
@property (nonatomic, assign) BOOL goBack;
@property (nonatomic, strong) NSString *deviceName;
@property (nonatomic,strong) NSString *deviceIPaddress;
@property (nonatomic,strong) GCDAsyncSocket *asyncSocket;
@property (nonatomic,strong) GCDAsyncSocket *listenrSocket;

@end
