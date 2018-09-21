//
//  CTRoundCheckMarkView.h
//  linePoc
//
//  Created by Sun, Xin on 11/16/16.
//  Copyright © 2016 Sun, Xin. All rights reserved.
//

#import <UIKit/UIKit.h>

/*!Definition of background color*/
enum CheckMarkViewColor {
    /*!Check mark green.*/
    vCheckMarkViewColorGreen,
    /*!Check mark red.*/
    vCheckMarkViewColorRed
};

/*!Checkmark View showing in alert when doing recover saving.*/
@interface CTRoundCheckMarkView : UIView
/*!Indicate that this view should draw check mark with animation or not. If set to YES, need to start drawing manually. Default value: NO;*/
@property (nonatomic, assign) BOOL withAnimate;
/*!
 Indicate the check mark view background color. Color must be member of CheckMarkViewColor enum;
 @see CheckMarkViewColor
 */
@property (nonatomic, assign) enum CheckMarkViewColor bgColor;

/*!
 Initialize checkmark view with given size and center position in its parent view.
 @param size Size of checkmark
 @param centerPoint Center position of checkmark view inside its parent view.
 @param color Color refill into checkmark.
 */
- (instancetype)initWithSize:(CGFloat)size andCenter:(CGPoint)centerPoint andColor:(enum CheckMarkViewColor)color;
/*!Start drawing the line for check mark.*/
- (void)startDrawLine;

@end
