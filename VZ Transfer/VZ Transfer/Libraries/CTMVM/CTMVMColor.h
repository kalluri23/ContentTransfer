//
//  CTMVMColor.h
//  myverizon
//
//  Created by Scott Pfeil on 11/4/14.
//  Copyright (c) 2014 Verizon Wireless. All rights reserved.
//
//  Colors commonly used in mvm.

#import <UIKit/UIKit.h>

/*! @brief MVM Color class for content transfer.*/
@interface CTMVMColor : UIColor

/*! @brief Primary red buttons use this red. Hex code: #cd040b.*/
+ (UIColor *)mvmPrimaryRedColor;

// Primary grey buttons use this grey. #4a4f55 (Given from business)
+ (UIColor *)mvmPrimaryGreyColor;

/*! @brief Primary blue buttons use this color. Hex code: #0066cc.*/
+ (UIColor *)mvmPrimaryBlueColor;

// The darkest gray other than black. Most text uses this. #333333
+ (UIColor *)mvmDarkGrayColor;

// Secondary grey buttons use this grey. #d2d2d2
+ (UIColor *)mvmSecondaryGreyColor;

// Views with light grey backgrounds use this grey #f2f2f2
+ (UIColor *)mvmViewBackgroundGreyColor;

// Another background gray. Slightly darker #eaeaea
+ (UIColor *)mvmBackgroundGrayColor2;

// Provides the medium grey color from the style guideline #99999e
+ (UIColor *)mvmMediumGreyColor;

// Secondary red. #ffcfd1
+ (UIColor *)mvmSecondaryRedColor;

// Provides the mvm green color #00768B
+ (UIColor *)mvmTurquoiseGreenColor;

// Provides the mvm green color #49914c
+ (UIColor *)mvmTertiaryGreenColor;

// Provides the mvm yellow color #ffbe00
+ (UIColor *)mvmTertiaryYellowColor;

// Provides the mvm blue color #3a89de
+ (UIColor *)mvmTertiaryBlueColor;

// Provides the mvm secondary green color #d5f2d6
+ (UIColor *)mvmSecondaryTertiaryGreenColor;

// Provides the mvm secondary yellow color #ffe8a6
+ (UIColor *)mvmSecondaryTertiaryYellowColor;

// Provides the mvm secondary blue color #bcd9ff
+ (UIColor *)mvmSecondaryTertiaryBlueColor;

// The blue used in the wayfinder #3095a9
+ (UIColor *)mvmWayfinderBlueColor;

// The shade of gray used in collapse/expand arrow #7f7f7f
+ (UIColor *)mvmCollapseArrowColor;

// The darker text color in the wayfinder #999999
+ (UIColor *)mvmWayfinderDarkTextColor;

// The lighter text color in the wayfinder #cccccc
+ (UIColor *)mvmWayfinderLightTextColor;

// The darker box color in the wayfinder #6d6e71
+ (UIColor *)mvmWayfinderDarkBoxColor;

// The lighter box color in the wayfinder #edeef0
+ (UIColor *)mvmWayfinderLightBoxColor;

// Returns the color that maps to a given string.
+ (UIColor *)getColorForString:(NSString *)string;

/*!
    @brief Get the color based on Hex value given.
    @param hexString String value represents the hex value of specific color.
    @return UIColor object according to hex value.
 */
+ (UIColor *)getColorForHex:(NSString *) hexString;
@end
