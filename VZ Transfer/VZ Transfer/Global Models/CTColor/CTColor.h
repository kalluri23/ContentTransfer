//
//  CTColor.h
//  contenttransfer
//
//  Created by Mehta, Snehal Natwar on 8/18/16.
//  Copyright © 2016 Verizon. All rights reserved.
//
/*!
    @header CTColor.h
    @discussion This is the header of CTColor object.
 */
#import "CTMVMColor.h"

/*!
    @brief This object related to Verizon Content Transfer style color.
    @discussion All the color use for Verizon Content Transfer brand will be included in this class, and any future color need to be added in this object.
 
                This object inherit from CTMVMColor which include all the brand color for MVM.
    @see CTMVMColor
 */
@interface CTColor : CTMVMColor
/*!Brand blue color. Color RGB:.62/.85/.95.*/
+ (UIColor *)darkSkyBlueColor;
/*!Primary red color use for general Verizon app: #CD040B.*/
+ (CTColor *)primaryRedColor;
/*!Inactive button color: #F6F6F6*/
+ (CTColor *)buttonColorInactive;
/*!Inactive button title color: #959595*/
+ (CTColor *)buttonTitleColorInactive;
/*!Highlighted button color: #990308*/
+ (CTColor *)buttonColorHighlighted;
/*!Charcoal color: #333333*/
+ (CTColor *)charcoalColor;
/*!Green color for progres bar: #82CEAC*/
+ (CTColor *)progressGreenColor;
/*!Battleshipgreycolor for track color. Color RGB:116/118/118*/
+ (UIColor *)trackColor;
/*!Grey color for progress color. Color RGB:243/243/243*/
+ (UIColor *)progressColor;

@end
