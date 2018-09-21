//
//  CTAppReviewManager.m
//  contenttransfer
//
//  Created by Sun, Xin on 6/13/17.
//  Copyright © 2017 Verizon Wireless Inc. All rights reserved.
//

#import "CTAppReviewManager.h"
#import "CTMVMAlertObject.h"
#import "CTMVMAlertHandler.h"
#import "CTSettingsUtility.h"
#import <StoreKit/StoreKit.h>

#if STANDALONE == 0
#import <contentTransferFramework/contenttransfer-Swift.h>
#endif

@interface CTAppReviewManager() {
    /*!Indicate current flow.*/
    enum CTTransferFlow   _flow;
    /*!Indicate current status.*/
    enum CTTransferStatus _status;
    /*!CTUserDefault object for saving review related flags.*/
    CTUserDefaults *_standardDefault;
    /*!Indicate that review dialog already showed or not. This is a local parameter, will be reset for every manager object.*/
    BOOL _bItuneReviewDisplayed;
}
@end

@implementation CTAppReviewManager
#pragma mark - Initializer
- (instancetype)initManagerFor:(enum CTTransferFlow)flow withResult:(enum CTTransferStatus)status {
    self = [super init];
    if (self) {
        _flow   = flow;
        _status = status;
        _standardDefault = [CTUserDefaults sharedInstance];
        _bItuneReviewDisplayed = NO;
    }
    
    return self;
}

#pragma mark - Public Methods
- (void)showReviewDialogIfUserNeedToReviewTheAppForTarget:(UIViewController *)target {
#if STANDALONE == 1
    if(_status == CTTransferStatus_Success && _flow == CTTransferFlow_Receiver && !_bItuneReviewDisplayed) { // Each dialog will only showed once per manager.
        _bItuneReviewDisplayed = YES;
//        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"10.3")) { // If it's 10.3 at least, then support in-app rating
//            // Note: This method will be controlled by Apple to show to user 3 times per year per app. No way to manually control pop up; Everytime user finished one transfer, method will try to show rating dialog, until they reach 3 times limit.
//            [SKStoreReviewController requestReview];
//        } else { // Otherwise, use deep link
        [self _displayItuneStoreReviewPopup:target];
//        }
    }
#endif
}

#pragma mark - Private Methods
/*! @brief Create and display the review dialog for content transfer.*/
- (void)_displayItuneStoreReviewPopup:(UIViewController *)target {
    if([CTUserDefaults sharedInstance].itunesReviewStatus != CTItunesReviewStatus_NotYet) {
        return;
    }
    
    if (USES_CUSTOM_VERIZON_ALERTS){
        [CTVerizonAlertCreateFactory showThreeButtonsAlertAlertWithTitle:CTLocalizedString(CT_APP_REVIEW_ALERT_TITLE, nil) context:CTLocalizedString(CT_APP_REVIEW_ALERT_CONTEXT, nil) primaryBtnText:CTLocalizedString(CT_APP_REVIEW_ALERT_NO_THANKS, nil) secondaryBtnText:CTLocalizedString(CT_APP_REVIEW_ALERT_NOT_NOW, nil) teritiaryBtnText:CTLocalizedString(CT_APP_REVIEW_ALERT_RATE_APP, nil) primaryBtnHandler:^(CTVerizonAlertViewController *alertVC){
            [CTUserDefaults sharedInstance].itunesReviewStatus = CTItunesReviewStatus_Never;
        } secondaryBtnHandler:nil teritiaryBtnHandler:^(CTVerizonAlertViewController *alertVC) {
            [CTUserDefaults sharedInstance].itunesReviewStatus = CTItunesReviewStatus_Reviewed;
            [CTSettingsUtility openAppStoreReviewLink];
        } isGreedy:NO from: target];
    } else {
        CTMVMAlertAction *rateAction = [CTMVMAlertAction actionWithTitle:CTLocalizedString(CT_APP_REVIEW_ALERT_RATE_APP, nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            [CTUserDefaults sharedInstance].itunesReviewStatus = CTItunesReviewStatus_Reviewed;
            [CTSettingsUtility openAppStoreReviewLink];
        }];
        CTMVMAlertAction *remindAction = [CTMVMAlertAction actionWithTitle:CTLocalizedString(CT_APP_REVIEW_ALERT_NOT_NOW, nil) style:UIAlertActionStyleDefault handler:nil];
        CTMVMAlertAction *cancelAction =  [CTMVMAlertAction actionWithTitle:CTLocalizedString(CT_APP_REVIEW_ALERT_NO_THANKS, nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [CTUserDefaults sharedInstance].itunesReviewStatus = CTItunesReviewStatus_Never;
        }];
        
        CTMVMAlertObject *alertObject = [[CTMVMAlertObject alloc] initWithTitle:CTLocalizedString(CT_APP_REVIEW_ALERT_TITLE, nil)
                                                                        message:CTLocalizedString(CT_APP_REVIEW_ALERT_CONTEXT, nil)
                                                                   cancelAction:rateAction
                                                                   otherActions:@[remindAction, cancelAction]
                                                                       isGreedy:NO];
        
        [[CTMVMAlertHandler sharedAlertHandler] showAlertWithAlertObject:alertObject];
    }
    
    
}

@end
