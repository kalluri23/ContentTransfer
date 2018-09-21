//
//  UITapGestureRecognizer+CTGestureHelper.h
//  contenttransfer
//
//  Created by Sun, Xin on 4/27/17.
//  Copyright © 2017 Verizon Wireless Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITapGestureRecognizer (CTGestureHelper)
/*!
 Check if user's tap is inside given range in given label with certain text alignment.
 
 This method can be use to bind with button embeded inside UILabel with part of it's string.
 @param label Target UILabel want to detect user's tap.
 @param targetRange Text range in label's text that want to valid the tap position.
 @param alignment Text alignment value for label's text.
 @return YES if tap position is inside the given range; otherwise retuen NO.
 */
- (BOOL)didTapAttributedTextInLabel:(UILabel *)label
                            inRange:(NSRange)targetRange
                          alignment:(NSTextAlignment)alignment;

@end
