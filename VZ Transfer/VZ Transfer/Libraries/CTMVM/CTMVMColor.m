//
//  CTMVMColor.m
//  myverizon
//
//  Created by Scott Pfeil on 11/4/14.
//  Copyright (c) 2014 Verizon Wireless. All rights reserved.
//

#import "CTMVMColor.h"

@implementation CTMVMColor

+ (UIColor *)mvmPrimaryRedColor {
    return [CTMVMColor getColorForHex:@"#cd040b"];
}

+ (UIColor *)mvmPrimaryGreyColor {
    return [UIColor colorWithRed:.29 green:.31 blue:.333 alpha:1.0];
}

+ (UIColor *)mvmPrimaryBlueColor {
    return [UIColor colorWithRed:0 green:.4 blue:.8 alpha:1.0];
}

+ (UIColor *)mvmDarkGrayColor {
    return [UIColor colorWithRed:.2 green:.2 blue:.2 alpha:1.0];
}

+ (UIColor *)mvmSecondaryGreyColor {
    return [UIColor colorWithRed:.824 green:.824 blue:.824 alpha:1.0];
}

+ (UIColor *)mvmViewBackgroundGreyColor {
    return [UIColor colorWithRed:.949 green:.949 blue:.949 alpha:1];
}

+ (UIColor *)mvmBackgroundGrayColor2 {
    return [UIColor colorWithRed:(234.0/255.0) green:(234.0/255.0) blue:(234.0/255.0) alpha:1];
}

+ (UIColor *)mvmMediumGreyColor {
    return [UIColor colorWithRed:.60 green:.60 blue:.62 alpha:1];
}

+ (UIColor *)mvmSecondaryRedColor {
    return [UIColor colorWithRed:1 green:.812 blue:.82 alpha:1];
}

+ (UIColor *)mvmTurquoiseGreenColor {
    return [UIColor colorWithRed:0 green:.489 blue:.588 alpha:1];
}

+ (UIColor *)mvmTertiaryGreenColor {
    return [UIColor colorWithRed:.286 green:.569 blue:.298 alpha:1];
}

+ (UIColor *)mvmTertiaryYellowColor {
    return [UIColor colorWithRed:1 green:.745 blue:0 alpha:1];
}

+ (UIColor *)mvmTertiaryBlueColor {
    return [UIColor colorWithRed:.227 green:.537 blue:.871 alpha:1];
}

+ (UIColor *)mvmSecondaryTertiaryGreenColor {
    return [UIColor colorWithRed:.835 green:.949 blue:.839 alpha:1];
}

+ (UIColor *)mvmSecondaryTertiaryYellowColor {
    return [UIColor colorWithRed:1 green:.91 blue:.651 alpha:1];
}

+ (UIColor *)mvmSecondaryTertiaryBlueColor {
    return [UIColor colorWithRed:.737 green:.851 blue:1 alpha:1];
}

+ (UIColor *)mvmWayfinderBlueColor {
    return [UIColor colorWithRed:.188 green:.584 blue:.663 alpha:1];
}

+ (UIColor *)mvmCollapseArrowColor {
    return [UIColor colorWithRed:.531 green:.531 blue:.531 alpha:1];
}

+ (UIColor *)mvmWayfinderDarkTextColor {
    return [UIColor colorWithRed:.6 green:.6 blue:.6 alpha:1];
}

+ (UIColor *)mvmWayfinderLightTextColor {
    return [UIColor colorWithRed:.8 green:.8 blue:.8 alpha:1];
}

+ (UIColor *)mvmWayfinderDarkBoxColor {
    return [UIColor colorWithRed:.427 green:.431 blue:.443 alpha:1];
}

+ (UIColor *)mvmWayfinderLightBoxColor {
    return [UIColor colorWithRed:.929 green:.933 blue:.941 alpha:1];
}

+ (UIColor *)getColorForString:(NSString *)string {
    static NSDictionary *stringColorMapping;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        
        stringColorMapping = @{@"PrimaryRed":[CTMVMColor mvmPrimaryRedColor],@"PrimaryYellow":[CTMVMColor mvmTertiaryYellowColor],@"PrimaryGreen":[CTMVMColor mvmTertiaryGreenColor],@"PrimaryBlue":[CTMVMColor mvmTertiaryBlueColor],@"SecondaryRed":[CTMVMColor mvmSecondaryRedColor],@"SecondaryYellow":[CTMVMColor mvmSecondaryTertiaryYellowColor],@"SecondaryGreen":[CTMVMColor mvmSecondaryTertiaryGreenColor],@"SecondaryBlue":[CTMVMColor mvmSecondaryTertiaryBlueColor]};
    });
    
    UIColor *color = nil;
    if (string && string.length > 0) {
        color = [stringColorMapping objectForKey:string];
    }
    return color;
}

+ (UIColor *)getColorForHex:(NSString *) hexString {
    unsigned int hexint = 0;
    
    // Create scanner
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    
    // Tell scanner to skip the # character
    [scanner setCharactersToBeSkipped:[NSCharacterSet
                                       characterSetWithCharactersInString:@"#"]];
    [scanner scanHexInt:&hexint];
    
    UIColor *color = [UIColor colorWithRed:((CGFloat) ((hexint & 0xFF0000) >> 16))/255
                    green:((CGFloat) ((hexint & 0xFF00) >> 8))/255
                     blue:((CGFloat) (hexint & 0xFF))/255
                    alpha:1];
    return color;
}

@end
