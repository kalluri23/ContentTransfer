//
//  CTMVMFonts.m
//  myverizon
//
//  Created by Scott Pfeil on 11/17/14.
//  Copyright (c) 2014 Verizon Wireless. All rights reserved.
//

#import "CTMVMFonts.h"
//#import "Utility.h"

@implementation CTMVMFonts

+ (UIFont *)mfFont55Rg:(CGFloat)size {
    NSString *fontName = @"NHaasGroteskDSStd-55Rg";
    return [UIFont fontWithName:fontName size:size];
}

+ (UIFont *)mvmNHaasGroteskDSStd65Md:(CGFloat)size {
    NSString *fontName = @"NHaasGroteskDSStd-65Md";
    return [UIFont fontWithName:fontName size:size];
}

+ (UIFont *)mvmMediumFontOfSize:(CGFloat)size {
    
    return [UIFont fontWithName:@"NHaasGroteskTXStd-65Md" size:[CTMVMFonts sizeFontForCurrentDevice:size]];

}

+ (UIFont *)mvmMediumItalicFontOfSize:(CGFloat)size {
    
    return [UIFont fontWithName:@"NHaasGroteskTXStd-66MdIt" size:[CTMVMFonts sizeFontForCurrentDevice:size]];
}

+ (UIFont *)mvmBoldFontOfSize:(CGFloat)size {
    
    return [UIFont fontWithName:@"NHaasGroteskDSStd-75Bd" size:[CTMVMFonts sizeFontForCurrentDevice:size]];
}

+ (UIFont *)mvmBoldItalicFontOfSize:(CGFloat)size {

    return [UIFont fontWithName:@"NHaasGroteskTXStd-76BdIt" size:[CTMVMFonts sizeFontForCurrentDevice:size]];
}

+ (UIFont *)mvmBookFontOfSize:(CGFloat)size {
    
    return [UIFont fontWithName:@"NHaasGroteskDSStd-55Rg" size:[CTMVMFonts sizeFontForCurrentDevice:size]];
}

+ (UIFont *)mvmBookItalicFontOfSize:(CGFloat)size {

    return [UIFont fontWithName:@"NHaasGroteskDSStd-56It" size:[CTMVMFonts sizeFontForCurrentDevice:size]];
}

+ (UIFont *)mvmMediumFontOfSizeWithoutScaling:(CGFloat)size {

    return [UIFont fontWithName:@"NHaasGroteskTXStd-65Md" size:size];
}

+ (UIFont *)mvmMediumItalicFontOfSizeWithoutScaling:(CGFloat)size {
    
    return [UIFont fontWithName:@"NHaasGroteskTXStd-66MdIt" size:size];
}

+ (UIFont *)mvmBoldFontOfSizeWithoutScaling:(CGFloat)size {
    return [UIFont fontWithName:@"NHaasGroteskDSStd-75Bd" size:size];

}

+ (UIFont *)mvmBoldItalicFontOfSizeWithoutScaling:(CGFloat)size {
    
    return [UIFont fontWithName:@"NHaasGroteskTXStd-76BdIt" size:size];
}

+ (UIFont *)mvmBookFontOfSizeWithoutScaling:(CGFloat)size {
    
    return [UIFont fontWithName:@"NHaasGroteskDSStd-55Rg" size:size];

}

+ (UIFont *)mvmBookItalicFontOfSizeWithoutScaling:(CGFloat)size {
    
    return [UIFont fontWithName:@"NHaasGroteskDSStd-56It" size:size];

}


+ (UIFont *)mvmBoldArialFontOfSize:(CGFloat)size {
    
    return [UIFont fontWithName:@"Arial-BoldMT" size:[CTMVMFonts sizeFontForCurrentDevice:size]];
}


+ (CGFloat)screenHeight {
    CGRect screenFrame = [[UIScreen mainScreen] bounds];
    return CGRectGetHeight(screenFrame);
}


+(BOOL)screenIsBiggerThaniPhone5 {
    return [self screenHeight] > 600.0;
}


+ (CGFloat)sizeFontForCurrentDevice:(CGFloat)size {
    CGFloat newSize = size;
    if ([self screenIsBiggerThaniPhone5]) {
        
        // This is for bigger screens.
        newSize = newSize * 1.2;
    }
    return newSize;
}


@end
