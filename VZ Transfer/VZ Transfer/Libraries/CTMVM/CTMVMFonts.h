//
//  CTMVMFonts.h
//  myverizon
//
//  Created by Scott Pfeil on 11/17/14.
//  Copyright (c) 2014 Verizon Wireless. All rights reserved.
//
//  Commonly used mvm fonts

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface CTMVMFonts : NSObject

+ (UIFont *)mfFont55Rg:(CGFloat)size;
+ (UIFont *)mvmNHaasGroteskDSStd65Md:(CGFloat)size;

// These functions automatically scale for device size.
+ (UIFont *)mvmMediumFontOfSize:(CGFloat)size;
+ (UIFont *)mvmMediumItalicFontOfSize:(CGFloat)size;
+ (UIFont *)mvmBoldFontOfSize:(CGFloat)size;
+ (UIFont *)mvmBoldItalicFontOfSize:(CGFloat)size;
+ (UIFont *)mvmBookFontOfSize:(CGFloat)size;
+ (UIFont *)mvmBookItalicFontOfSize:(CGFloat)size;

// Same as above but does not scale. Exact sizes.
+ (UIFont *)mvmMediumFontOfSizeWithoutScaling:(CGFloat)size;
+ (UIFont *)mvmMediumItalicFontOfSizeWithoutScaling:(CGFloat)size;
+ (UIFont *)mvmBoldFontOfSizeWithoutScaling:(CGFloat)size;
+ (UIFont *)mvmBoldItalicFontOfSizeWithoutScaling:(CGFloat)size;
+ (UIFont *)mvmBookFontOfSizeWithoutScaling:(CGFloat)size;
+ (UIFont *)mvmBookItalicFontOfSizeWithoutScaling:(CGFloat)size;

// Used for certain buttons.
+ (UIFont *)mvmBoldArialFontOfSize:(CGFloat)size;

// Pass in the size and this will return the proper size based on device.
+ (CGFloat)sizeFontForCurrentDevice:(CGFloat)size;

@end
