//
//  CTBonjourSenderScannerViewController.h
//  contenttransfer
//
//  Created by Pena, Ricardo on 2/3/17.
//  Copyright © 2017 Verizon Wireless Inc. All rights reserved.
//

#import "CTCustomButton.h"
#import "CTGenericBonjourViewController.h"
#import <AVFoundation/AVFoundation.h>

/*!
 Handler for getting user's choice.
 @param Integer value represent the type of user's selection.
 */
typedef void (^BonjourSenderHandler)(int);

/*!
    @brief Scanner view controller.
    @discussion This controller is not necessarily be sender side, but every page using camera to scan the QR code.
    
                This controller contains all the logic for pairing devices using Bonjour/Socket.
 */
@interface CTSenderScannerViewController : CTGenericBonjourViewController
/*! Bool indicate that invitation is sent.*/
@property (nonatomic, assign) BOOL invitationSent;
/*! Bool indicate that app comes back from background mode.*/
@property (nonatomic, assign) BOOL backgroundMode;
/*! Bool indicate that app should wait for response or not.*/
@property (nonatomic, assign) BOOL shouldWaitForResponse;
/*! Bool value indicate that this is for one to many scan. Default value is NO.*/
@property (nonatomic, assign) BOOL isForSTM;
/*!
 Callback handler for invitation view. Need to implement this before push invitation to the stack.
 @see BonjourSenderHandler
 */
@property (nonatomic, strong) BonjourSenderHandler handler;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cameraViewTopSpace;
@property (weak, nonatomic) IBOutlet UIView *viewPreview;
@property (weak, nonatomic) IBOutlet CTRomanFontLabel *secondaryLabel;
@property (weak, nonatomic) IBOutlet CTCommonBlackButton *tryAnotherWayBtn;
@property (weak, nonatomic) IBOutlet CTBlackBorderedButton *manualSetupButton;
@property (weak, nonatomic) IBOutlet CTBlackBorderedButton *manualSetupCenterButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leftBtnWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *rightBtnWidth;
@property (weak, nonatomic) IBOutlet CTPrimaryMessageLabel *titleLbl;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *secondaryTop;

@end
