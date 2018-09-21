//
//  UILabel+CTLabelAdjust.h
//  contenttransfer
//
//  Created by Sun, Xin on 6/27/17.
//  Copyright © 2017 Verizon Wireless Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UILabel (CTLabelAdjust)
/*!
    @brief Get the width of the text in label based on label font and size.
    @discussion This method actually calling the getTextFrame method, and return width of it.
    @return Width of the text message in label.
    @see getTextFrame;
 */
- (CGFloat)getTextWidth;
/*!
    @brief Get the height of the text in label based on label font and size.
    @discussion This method actually calling the getTextFrame method, and return height of it.
    @return Height of the text message in label.
    @see getTextFrame;
 */
- (CGFloat)getTextHeight;
/*!
    @brief Get the frame of the text in label based on label font and size.
    @return CGRect structure represents the text message frame in label.
 */
- (CGRect)getTextFrame;

@end
