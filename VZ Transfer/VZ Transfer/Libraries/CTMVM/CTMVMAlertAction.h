//
//  MVMAlertAction.h
//  VZ Transfer
//
//  Created by Hadapad, Prakash on 5/19/16.
//  Copyright © 2016 Hadapad, Prakash. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface CTMVMAlertAction : NSObject

@property (strong, nonatomic) NSString *title;
@property (nonatomic) UIAlertActionStyle style;
@property (copy, nonatomic) void (^handler)(UIAlertAction *action);

// Mimics the UIAlertAction function.
- (instancetype)initWithTitle:(NSString *)title style:(UIAlertActionStyle)style handler:(void (^)(UIAlertAction *action))handler;
+ (instancetype)actionWithTitle:(NSString *)title style:(UIAlertActionStyle)style handler:(void (^)(UIAlertAction *action))handler;

// Returns an alert action for this mvm action.
- (UIAlertAction *)alertAction;

@end
