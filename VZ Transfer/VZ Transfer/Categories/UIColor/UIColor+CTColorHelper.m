//
//  UIColor+CTColorHelper.m
//  contenttransfer
//
//  Created by Sun, Xin on 8/16/17.
//  Copyright © 2017 Verizon Wireless Inc. All rights reserved.
//

#import "UIColor+CTColorHelper.h"

@implementation UIColor (CTColorHelper)

+ (UIColor *)colorFromHexString:(NSString *)hexString {
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:0];
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

+ (NSString*)hexOFColor:(CGColorRef)cgColor {
    const CGFloat *components = CGColorGetComponents(cgColor);
    CGFloat r = components[0];
    CGFloat g = components[1];
    CGFloat b = components[2];
    NSString *hexString=[NSString stringWithFormat:@"%02X%02X%02X", (int)(r * 255), (int)(g * 255), (int)(b * 255)];
    DebugLog(@"%@", hexString);
    return hexString;
}

@end
