//
//  CTProgressView.h
//  contenttransfer
//
//  Created by Mehta, Snehal Natwar on 8/18/16.
//  Copyright © 2016 Verizon. All rights reserved.
//

#import <UIKit/UIKit.h>

/*!Progress view for content transfer.*/
@interface CTProgressView : UIView
/*!Progress bar embeded in view.*/
@property (nonatomic, strong) UIView *progressView;
/*!Progress bar color.*/
@property (nonatomic, strong) UIColor *progressColor;
/*!Progress bar background color.*/
@property (nonatomic, strong) UIColor *trackColor;
/*!Progress value. This value must between 0 to 1.*/
@property (nonatomic, assign) float progress;

@end
