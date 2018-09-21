//
//  VZAnDBumpActionRecevier.h
//  myverizon
//
//  Created by Hadapad, Prakash on 4/4/16.
//  Copyright © 2016 Verizon Wireless. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VZCTViewController.h"
#import "GCDAsyncSocket.h"
#import "VZReceiverViewController.h"

@interface VZAnDBumpActionRecevier : VZCTViewController {
    
    //    GCDAsyncSocket *asyncSocket;
    //    GCDAsyncSocket *listenOnPort;
}

- (IBAction)clickedCancelBtn:(id)sender;
- (IBAction)clickedNotFoundBtn:(id)sender;
@property (weak, nonatomic) IBOutlet UIImageView *bumpImageView;

// Server parameters
@property (nonatomic, copy, readwrite) NSString *registeredName;
@property (weak, nonatomic) IBOutlet UILabel *availablePhoneLbl;
@property (weak, nonatomic) IBOutlet UILabel *shakeThisPhone;
@property (weak, nonatomic) IBOutlet UIButton *cancelBtn;
@property (weak, nonatomic) IBOutlet UIButton *notFoundBtn;
@property (weak, nonatomic) AppDelegate *app;
@property (nonatomic, assign) BOOL goBack;
@property(nonatomic,strong) GCDAsyncSocket *asyncSocket;
@property(nonatomic,strong) GCDAsyncSocket *listenOnPort;


@end
