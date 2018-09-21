//
//  CTQRCodeViewController.h
//  contenttransfer
//
//  Created by Pena, Ricardo on 1/30/17.
//  Copyright © 2017 Verizon Wireless Inc. All rights reserved.
//

#import "CTViewController.h"
#import "CTQRCode.h"
#import "GCDAsyncSocket.h"
#import "CTBonjourReceiverViewController.h"

/*!
 View controller for pairing device with QR code. This is the first page of setup process.
 */
@interface CTQRCodeViewController : CTGenericBonjourViewController
/*! QR Code object.*/
@property (nonatomic, strong) CTQRCode * ctQRCode;
/*!Socket using for pairing.*/
@property (strong, nonatomic) GCDAsyncSocket *socket;
/*!Bool indicate that app comes back from background mode.*/
@property (nonatomic, assign) BOOL backgroundMode;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *ssidLblTop;
@property (weak, nonatomic) IBOutlet UIImageView *qrCodeImageView;
@property (weak, nonatomic) IBOutlet CTRomanFontLabel *secondaryLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leftBtnWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *rightBtnWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *qrCodeImageTopSpace;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *qrCodeImageViewLeadingSpace;

@property (weak, nonatomic) IBOutlet CTCommonBlackButton *settingButton;
@property (weak, nonatomic) IBOutlet CTBlackBorderedButton *manualSetupBtn;

@end
