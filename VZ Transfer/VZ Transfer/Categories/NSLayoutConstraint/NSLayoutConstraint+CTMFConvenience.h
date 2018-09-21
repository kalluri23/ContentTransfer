//
//  NSLayoutConstraint+Convenience.h
//  myverizon
//
//  Created by Chris Yang on 1/15/16.
//  Copyright © 2016 Verizon Wireless. All rights reserved.
//

#import <UIKit/UIKit.h>

//************************************************************************
//*
//* IMPORTANT::make sure add subView to superView before call the methods
//*
//************************************************************************

@interface NSLayoutConstraint (Convenience)


//this will pin subview to superview
+ (nullable NSDictionary *)constraintPinSubview:(nonnull UIView *)subview toSuperview:(nonnull UIView *)superview;
+ (nullable NSDictionary *)constraintPinSubview:(nonnull UIView *)subview toSuperview:(nonnull UIView *)superview pinTop:(BOOL)pinTop pinBottom:(BOOL)pinBottom pinLeft:(BOOL)pinLeft pinRight:(BOOL)pinRight;
+ (nullable NSDictionary *)constraintPinSubview:(nonnull UIView *)subview toSuperview:(nonnull UIView *)superview pinTop:(BOOL)pinTop topConstant:(CGFloat)topConstant pinBottom:(BOOL)pinBottom bottomConstant:(CGFloat)bottomConstant pinLeft:(BOOL)pinLeft leftConstant:(CGFloat)leftConstant pinRight:(BOOL) pinRight rightConstant:(CGFloat)rightConstant;


/*!
    @brief Set center constraint for a view using super view center value.
    @param subview UIView need to add constaints for.
    @param superView Super level UIView that target view's constraints related to.
    @return NSDictionary contains all the constaints added for target view.
 */
+ (nullable NSDictionary *)constraintPinSubview:(nonnull UIView *)subview toCenterOfSuperview:(nonnull UIView *)superview;
/*!
    @brief Set center constraint for a view using super view center value.
    @param subview UIView need to add constaints for.
    @param superView Super level UIView that target view's constraints related to.
    @param pinCenterX BOOL value indicate should use same center x value as super view.
    @param pinCenterY BOOL value indicate should use same center y value as super view.
    @return NSDictionary contains all the constaints added for target view.
 */
+ (nullable NSDictionary *)constraintPinSubview:(nonnull UIView *)subview toSuperview:(nonnull UIView *)superview pinCenterX:(BOOL)pinCenterX pinCenterY:(BOOL)pinCenterY;
/*!
    @brief Set center constraint for a view related to super view center value.
    @param subview UIView need to add constaints for.
    @param superView Super level UIView that target view's constraints related to.
    @param pinCenterX BOOL value indicate should set constaints for center x.
    @param centerXConstant Constant value for center x.
    @param pinCenterY BOOL value indicate should set constaints for center y.
    @param centerYConstant Constant value for center y.
    @return NSDictionary contains all the constaints added for target view.
 */
+ (nullable NSDictionary *)constraintPinSubview:(nonnull UIView *)subview toSuperview:(nonnull UIView *)superview pinCenterX:(BOOL)pinCenterX centerXConstant:(CGFloat)centerXConstant pinCenterY:(BOOL)pinCenterY centerYConstant:(CGFloat)centerYConstant;
/*!
    @brief Set height and width constraint for a view
    @param view UIView need to add constaints for.
    @param pinHeight BOOL value indicate that there is height constaint need to be assigned.
    @param heightConstant Constant value for height.
    @param pinWidth BOOL value indicate that there is width constaint need to be assigned.
    @param widthConstant Constant value for width.
    @return NSDictionary contains all the constaints added for target view.
 */
+ (nullable NSDictionary *)constraintPinView:(nonnull UIView*)view heightConstraint:(BOOL)pinHeight heightConstant:(CGFloat)heightConstant widthConstraint:(BOOL)pinWidth widthConstant:(CGFloat)widthConstant;

// pins 2 views in same hierarchy
+(nullable NSLayoutConstraint *)constraintPinFirstView :(nonnull UIView*)firstView toSecondView :(nonnull UIView*)secondView withConstant :(CGFloat)constant directionVertical :(BOOL)directionVertical;



@end
