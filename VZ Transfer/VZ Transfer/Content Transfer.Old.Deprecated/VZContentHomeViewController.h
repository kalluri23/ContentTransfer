//
//  VZHomeViewController.h
//  VZTransferSocket
//
//  Created by VVM-MAC02 on 11/29/15.
//  Copyright © 2015 Testing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "CTMVMViewController.h"
#import "AppDelegate.h"
#import "CTMVMStyler.h"
#import "CTMVMFonts.h"
#import "CTMVMButtons.h"
#import "CTMVMSessionSingleton.h"
#import "CTMVMAlertAction.h"
#import "CTMVMAlertObject.h"
#import "CTMVMAlertHandler.h"
#import "VZContentTransferSingleton.h"
#import "VZCTViewController.h"


@interface VZContentHomeViewController : VZCTViewController  {
    
}

@property (nonatomic, strong) ALAssetsLibrary *assetsLibrary;
@property (nonatomic, strong) NSMutableArray *groups;
@property (nonatomic, strong) NSMutableArray *assets;
@property (nonatomic, strong) ALAssetsGroup *assetsGroup;
@property(nonatomic,strong) NSMutableArray *hashTableUrltofileName;

@property (weak, nonatomic) IBOutlet UILabel *phoneSetupLbl;
@property (weak, nonatomic) IBOutlet UILabel *setAutoLockLbl;
@property (weak, nonatomic) IBOutlet UILabel *plugAutoLbl;
@property (weak, nonatomic) IBOutlet UILabel *repeatLbl;
@property (weak, nonatomic) IBOutlet UILabel *phoneSetupCompleted;
@property (weak, nonatomic) IBOutlet UILabel *lbl1;
@property (weak, nonatomic) IBOutlet UILabel *lbl2;
@property (weak, nonatomic) IBOutlet UILabel *lbl3;
@property (weak, nonatomic) IBOutlet UIButton *Yesbtn;
@property (weak,nonatomic) AppDelegate *app;


@end
