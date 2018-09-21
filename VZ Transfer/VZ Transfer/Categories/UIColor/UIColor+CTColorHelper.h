//
//  UIColor+CTColorHelper.h
//  contenttransfer
//
//  Created by Sun, Xin on 8/16/17.
//  Copyright © 2017 Verizon Wireless Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (CTColorHelper)
/*!
 @brief Get the UIColor from Hex string value.
 @param hexString NSString value represents a color in hex.
 @return UIColor translated from HEX string.
 */
+ (UIColor *)colorFromHexString:(NSString *)hexString;
/*!
 Get Hex string from color
 @param cgColor CGColorRef represents the color need to translate into HEX.
 @return NSString value represents the HEX value of the color.
 */
+ (NSString*)hexOFColor:(CGColorRef)cgColor;

@end
