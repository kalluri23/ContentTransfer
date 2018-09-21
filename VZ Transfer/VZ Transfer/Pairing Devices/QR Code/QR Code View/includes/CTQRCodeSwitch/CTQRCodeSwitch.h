//
//  CTQRCodeSwitch.h
//  contenttransfer
//
//  Created by Sun, Xin on 2/27/17.
//  Copyright © 2017 Verizon Wireless Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

/*!
 Switch class help to save user's choice for using QR Code.
 
 This is singlton object and will be reset if user kill the app.
 */
@interface CTQRCodeSwitch : NSObject
/*!
 Singlton initializer.
 @return CTQRCodeSwitch contains user's decision.
 */
+ (instancetype)uniqueSwitch;

/*!
 Check if QR code option is on or off.
 @return YES if should use QR Code; Otherwise NO.
 */
- (BOOL)isOn;
/*!True off the QR code and use manual setup.*/
- (void)off;

@end
