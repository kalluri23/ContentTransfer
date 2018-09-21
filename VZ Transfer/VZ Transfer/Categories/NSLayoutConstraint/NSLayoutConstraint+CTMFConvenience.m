//
//  NSLayoutConstraint+CTMFConvenience.m
//  myverizon
//
//  Created by Chris Yang on 1/15/16.
//  Copyright © 2016 Verizon Wireless. All rights reserved.
//

#import "NSLayoutConstraint+CTMFConvenience.h"

//constarint
NSString *const ConstraintTop = @"top";
NSString *const ConstraintBot = @"bot";
NSString *const ConstraintLeading = @"leading";
NSString *const ConstraintTrailing = @"trailing";
NSString *const ConstraintCenterX = @"centerX";
NSString *const ConstraintCenterY = @"centerY";
NSString *const ConstraintHeight = @"height";
NSString *const ConstraintWidth = @"width";

@implementation NSLayoutConstraint (Convenience)

+ (NSDictionary *)constraintPinSubview:(nonnull UIView *)subview toSuperview:(nonnull UIView *)superview {
    return [NSLayoutConstraint constraintPinSubview:subview toSuperview:superview pinTop:YES pinBottom:YES pinLeft:YES pinRight:YES];
}

+ (NSDictionary *)constraintPinSubview:(nonnull UIView *)subview toSuperview:(nonnull UIView *)superview pinTop:(BOOL)pinTop pinBottom:(BOOL)pinBottom pinLeft:(BOOL)pinLeft pinRight:(BOOL)pinRight {
    return [NSLayoutConstraint constraintPinSubview:subview toSuperview:superview pinTop:pinTop topConstant:0 pinBottom:pinBottom bottomConstant:0 pinLeft:pinLeft leftConstant:0 pinRight:pinRight rightConstant:0];
}

+ (NSDictionary *)constraintPinSubview:(nonnull UIView *)subview toSuperview:(nonnull UIView *)superview pinTop:(BOOL)pinTop topConstant:(CGFloat)topConstant pinBottom:(BOOL)pinBottom bottomConstant:(CGFloat)bottomConstant pinLeft:(BOOL)pinLeft leftConstant:(CGFloat)leftConstant pinRight:(BOOL)pinRight rightConstant:(CGFloat)rightConstant {
    NSMutableDictionary *constraintDic = [[NSMutableDictionary alloc] init];
    if (pinTop){
        NSLayoutConstraint *top = [NSLayoutConstraint constraintWithItem:subview attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:superview attribute:NSLayoutAttributeTop multiplier:1 constant:topConstant];
        top.priority = 999;
        if (SYSTEM_VERSION_LESS_THAN(@"8.0")){
            [superview addConstraint:top];
        }else{
            top.active = YES;
        }
        [constraintDic setObject:top forKey:ConstraintTop];
    }
    if (pinBottom){
        NSLayoutConstraint *bottom = [NSLayoutConstraint constraintWithItem:superview attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:subview attribute:NSLayoutAttributeBottom multiplier:1 constant:bottomConstant];
        bottom.priority = 999;
        if (SYSTEM_VERSION_LESS_THAN(@"8.0")){
            [superview addConstraint:bottom];
        } else {
            bottom.active = YES;
        }
        [constraintDic setObject:bottom forKey:ConstraintBot];
    }
    if (pinLeft) {
        NSLayoutConstraint *leading = [NSLayoutConstraint constraintWithItem:subview attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:superview attribute:NSLayoutAttributeLeading multiplier:1 constant:leftConstant];
        leading.priority = 999;
        if (SYSTEM_VERSION_LESS_THAN(@"8.0")){
            [superview addConstraint:leading];
        } else {
            leading.active = YES;
        }
        [constraintDic setObject:leading forKey:ConstraintLeading];
    }
    if (pinRight){
        NSLayoutConstraint *trailing = [NSLayoutConstraint constraintWithItem:superview attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:subview attribute:NSLayoutAttributeTrailing multiplier:1 constant:rightConstant];
        trailing.priority = 999;
        if (SYSTEM_VERSION_LESS_THAN(@"8.0")){
            [superview addConstraint:trailing];
        } else {
            trailing.active = YES;
        }
        [constraintDic setObject:trailing forKey:ConstraintTrailing];
    }
    return constraintDic;
    
}


+ (nullable NSDictionary *)constraintPinSubview:(nonnull UIView *)subview toCenterOfSuperview:(nonnull UIView *)superview {
    return [NSLayoutConstraint constraintPinSubview:subview toSuperview:superview pinCenterX:YES pinCenterY:YES];
}


+ (nullable NSDictionary *)constraintPinSubview:(nonnull UIView *)subview toSuperview:(nonnull UIView *)superview pinCenterX:(BOOL)pinCenterX pinCenterY:(BOOL)pinCenterY {
    return [NSLayoutConstraint constraintPinSubview:subview toSuperview:superview pinCenterX:pinCenterX centerXConstant:0 pinCenterY:pinCenterY centerYConstant:0];
}


+ (nullable NSDictionary *)constraintPinSubview:(nonnull UIView *)subview toSuperview:(nonnull UIView *)superview pinCenterX:(BOOL)pinCenterX centerXConstant:(CGFloat)centerXConstant pinCenterY:(BOOL)pinCenterY centerYConstant:(CGFloat)centerYConstant {
    NSMutableDictionary *constraintDic = [[NSMutableDictionary alloc]init];
    if (pinCenterX){
        NSLayoutConstraint *centerX = [NSLayoutConstraint constraintWithItem:subview attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:superview attribute:NSLayoutAttributeCenterX multiplier:1 constant:centerXConstant];
        centerX.priority = 999;
        if (SYSTEM_VERSION_LESS_THAN(@"8.0")){
            [superview addConstraint:centerX];
        } else {
            centerX.active = YES;
        }
        [constraintDic setObject:centerX forKey:ConstraintCenterX];
    }
    if (pinCenterY) {
        NSLayoutConstraint *centerY = [NSLayoutConstraint constraintWithItem:subview attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:superview attribute:NSLayoutAttributeCenterY multiplier:1 constant:centerYConstant];
        centerY.priority = 999;
        if (SYSTEM_VERSION_LESS_THAN(@"8.0")){
            [superview addConstraint:centerY];
        } else {
            centerY.active = YES;
        }
        [constraintDic setObject:centerY forKey:ConstraintCenterY];
    }
    return constraintDic;
}

+ (nullable NSDictionary *)constraintPinView:(nonnull UIView*)view heightConstraint:(BOOL)pinHeight heightConstant:(CGFloat)heightConstant widthConstraint:(BOOL)pinWidth widthConstant:(CGFloat)widthConstant {
     NSMutableDictionary *constraintDic = [[NSMutableDictionary alloc]init];
    if (pinHeight) {
        NSLayoutConstraint *height = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:heightConstant];
        height.priority = 999;
        if (SYSTEM_VERSION_LESS_THAN(@"8.0")){
            [view addConstraint:height];
        }
        else {
            height.active = YES;
        }
        [constraintDic setObject:height forKey:ConstraintHeight];
    }
    if (pinWidth) {
        NSLayoutConstraint *width = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:widthConstant];
        width.priority = 999;
        if (SYSTEM_VERSION_LESS_THAN(@"8.0")){
            [view addConstraint:width];
        } else{
            width.active = YES;
        }
        [constraintDic setObject:width forKey:ConstraintWidth];
    }
    return constraintDic;
}

+(NSLayoutConstraint *)constraintPinFirstView :(nonnull UIView*)firstView toSecondView :(nonnull UIView*)secondView withConstant :(CGFloat)constant directionVertical :(BOOL)directionVertical
{
    //@Chris: Added the commont braces as to avoid crash when a negative constant comes in -Arun
    NSString *pinString;
    if(directionVertical)
    {
        pinString = [NSString stringWithFormat:@"V:[firstView]-(%f)-[secondView]",constant];
    }
    else
    {
        pinString = [NSString stringWithFormat:@"H:[firstView]-(%f)-[secondView]",constant];
    }
   
    NSArray *constraints = [NSLayoutConstraint constraintsWithVisualFormat:pinString options:NSLayoutFormatDirectionLeadingToTrailing metrics:nil views:NSDictionaryOfVariableBindings(firstView, secondView)];
    
    [NSLayoutConstraint activateConstraints:constraints];
    
    return constraints[0];
}


@end
