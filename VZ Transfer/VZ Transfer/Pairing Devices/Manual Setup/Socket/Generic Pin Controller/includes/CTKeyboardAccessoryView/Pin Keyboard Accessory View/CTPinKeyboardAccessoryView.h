//
//  CTPinKeyboardAccessoryView.h
//  contenttransfer
//
//  Created by Development on 8/16/16.
//  Copyright © 2016 Verizon. All rights reserved.
//

#import "CTKeyboardAccessoryView.h"

/*! Accessory view on top of the keyboard. Providing Dismiss and Connect button for user.*/
@interface CTPinKeyboardAccessoryView : CTKeyboardAccessoryView

@property (nonatomic, weak) IBOutlet UIButton *dismissButton;
@property (nonatomic, weak) IBOutlet UIButton *connectButton;

/*!
 Initializer for accessory view.
 return CTPinKeyboardAccessoryView object.
 */
+ (instancetype)customView;

@end
