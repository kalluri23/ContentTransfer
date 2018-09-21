//
//  CTTransferDetailsViewController.m
//  contenttransfer
//
//  Created by Mehta, Snehal Natwar on 8/30/16.
//  Copyright © 2016 Verizon. All rights reserved.
//

#import "CTTransferDetailsViewController.h"

@interface CTTransferDetailsViewController()

@property (nonatomic, strong) NSMutableDictionary *errorsInfoDic;

@end

@implementation CTTransferDetailsViewController

- (NSMutableDictionary *)errorsInfoDic {
    if (!_errorsInfoDic) {
        _errorsInfoDic = [[NSMutableDictionary alloc] init];
    }
    
    return _errorsInfoDic;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = CTLocalizedString(CT_TRANSFER_DETAILS_VC_NAV_TITLE, nil);

#if STANDALONE
    [self setNavigationControllerMode:CTNavigationControllerMode_None];
#else
    [self setNavigationControllerMode:CTNavigationControllerMode_BackAndHamburgar];
#endif
    self.transferStatusDetailLabel.text = @"";
    
    switch (self.dataTransferStatus) {
        case CTDataTransferStatus_Ok:
            // Show green check mark
            self.statusImageView.image = [UIImage getImageFromBundleWithImageName:@"greenCheck"];
            self.transferStatusLabel.text = CTLocalizedString(CT_TRANSFER_DETAILS_ALL_SET_MESSAGE, nil);
            [self.transferStatusDetailLabel setHidden:YES];
            break;
        case CTDataTransferStatus_Warning:
            // Show warning check mark
            self.statusImageView.image = [UIImage getImageFromBundleWithImageName:@"yellowExclaimation"];
            self.transferStatusLabel.text = CTLocalizedString(CT_TRANSFER_DETAILS_ERROR_MESSAGE, nil);
            self.transferStatusDetailLabel.text = CTLocalizedString(CT_TRANSFER_DETAILS_MANUAL_BACKUP_MESSAGE, nil);

            break;
        case CTDataTransferStatus_Permission_Vcard:
            // Show warning check mark
            self.statusImageView.image = [UIImage getImageFromBundleWithImageName:@"yellowExclaimation"];
            self.transferStatusLabel.text = CTLocalizedString(CT_TRANSFER_DETAILS_NO_PERM_FOR_CONTACTS, nil);
            self.transferStatusDetailLabel.text = CTLocalizedString(CT_TRANSFER_DETAILS_GRANT_PERM_FOR_CONTACTS, nil);
            
            break;
        case CTDataTransferStatus_Permission_Photo:
            // Show warning check mark
            self.statusImageView.image = [UIImage getImageFromBundleWithImageName:@"yellowExclaimation"];
            self.transferStatusLabel.text = CTLocalizedString(CT_TRANSFER_DETAILS_NO_PERM_FOR_PHOTOS, nil);
            self.transferStatusDetailLabel.text = CTLocalizedString(CT_TRANSFER_DETAILS_GRANT_PERM_FOR_PHOTOS, nil);
            
            break;
        case CTDataTransferStatus_Permission_Video:
            // Show warning check mark
            self.statusImageView.image = [UIImage imageNamed:@"yellowExclaimation"];
            self.transferStatusLabel.text = CTLocalizedString(CT_TRANSFER_DETAILS_NO_PERM_FOR_VIDEOS, nil);
            self.transferStatusDetailLabel.text = CTLocalizedString(CT_TRANSFER_DETAILS_GRANT_PERM_FOR_VIDEOS, nil);
            
            break;
        case CTDataTransferStatus_Permission_Calendar:
            // Show warning check mark
            self.statusImageView.image = [UIImage getImageFromBundleWithImageName:@"yellowExclaimation"];
            self.transferStatusLabel.text = CTLocalizedString(CT_TRANSFER_DETAILS_NO_PERM_FOR_CALANDERS, nil);
            self.transferStatusDetailLabel.text = CTLocalizedString(CT_TRANSFER_DETAILS_GRANT_PERM_FOR_CALANDERS, nil);
            
            break;
        case CTDataTransferStatus_Permission_Reminder:
            // Show warning check mark
            self.statusImageView.image = [UIImage getImageFromBundleWithImageName:@"yellowExclaimation"];
            self.transferStatusLabel.text = CTLocalizedString(CT_TRANSFER_DETAILS_NO_PERM_FOR_REMINDERS, nil);
            self.transferStatusDetailLabel.text = CTLocalizedString(CT_TRANSFER_DETAILS_GRANT_PERM_FOR_REMINDERS, nil);
            
            break;
        default:
            break;
    }
    
    if (_shouldShowCloudInfo) {
        self.transferStatusDetailLabel.hidden = NO;
        if (_cloudType == 0) {
            if (self.transferStatusDetailLabel.text.length > 0) {
                self.transferStatusDetailLabel.text = [self.transferStatusDetailLabel.text stringByAppendingString:@"\n"];
            }
            self.transferStatusDetailLabel.text = [self.transferStatusDetailLabel.text stringByAppendingString:CTLocalizedString(CT_TRANSFER_DETAILS_SIGN_IN_TO_ICLOUD_PHOTOS, nil)];
        } else {
            if (self.transferStatusDetailLabel.text.length > 0) {
                self.transferStatusDetailLabel.text = [self.transferStatusDetailLabel.text stringByAppendingString:@"\n"];
            }
            self.transferStatusDetailLabel.text = [self.transferStatusDetailLabel.text stringByAppendingString:CTLocalizedString(CT_TRANSFER_DETAILS_SIGN_IN_TO_ICLOUD_VIDEOS, nil)];
        }
    }
    
    if (_targetFailedList) {
        self.transferStatusDetailLabel.text = [self.transferStatusDetailLabel.text stringByAppendingString:@"\n"];
        [self filterFailedList];
        for (NSString *key in [_errorsInfoDic allKeys]) {
            NSInteger count = [[_errorsInfoDic objectForKey:key] integerValue];
            
            if (self.transferStatusDetailLabel.text.length > 0) {
                self.transferStatusDetailLabel.text = [self.transferStatusDetailLabel.text stringByAppendingString:@"\n"];
            }
            self.transferStatusDetailLabel.text = [self.transferStatusDetailLabel.text stringByAppendingString:[NSString stringWithFormat:CTLocalizedString(CT_TRANSFER_DETAILS_TRANSFER_FAIL_LABEL, nil), (long)count, key]];
        }
    }
    
    if ([CTUserDefaults sharedInstance].errorLivePhotoList.count > 0) {
        self.transferStatusDetailLabel.text = [self.transferStatusDetailLabel.text stringByAppendingString:@"\n"];
        
        if (self.transferStatusDetailLabel.text.length > 0) {
            self.transferStatusDetailLabel.text = [self.transferStatusDetailLabel.text stringByAppendingString:@"\n"];
        }
        
        self.transferStatusDetailLabel.text = CTLocalizedString(CT_TRANSFER_DETAILS_LIVE_PHOTO_BECOME_STATIC, nil);
    }
}

- (IBAction)handleGotItButtonTapped:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)filterFailedList {
    for (NSDictionary *info in _targetFailedList) {
        NSError *err = (NSError *)[info objectForKey:@"Err"];
        NSNumber *count = [self.errorsInfoDic objectForKey:err.localizedDescription];
        if (count) {
            [self.errorsInfoDic setObject:[NSNumber numberWithInteger:[count integerValue]+1] forKey:err.localizedDescription];
        } else {
            [self.errorsInfoDic setObject:[NSNumber numberWithInteger:1] forKey:err.localizedDescription];
        }
    }
}

@end
