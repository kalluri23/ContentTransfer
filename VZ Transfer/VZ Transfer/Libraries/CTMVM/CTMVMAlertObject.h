//
//  MVMAlertObject.h
//  VZ Transfer
//
//  Created by Hadapad, Prakash on 5/19/16.
//  Copyright © 2016 Hadapad, Prakash. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CTAlertView.h"

typedef NS_ENUM(NSInteger, AlertStyle) {
    AlertStylePopup,
    AlertStyleAlertView,
    AlertStyleAvailable
};

@class CTMVMAlertAction;

@interface CTMVMAlertObject : NSObject

@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *message;
@property (strong, nonatomic) CTMVMAlertAction *cancelAction;
@property (strong, nonatomic) NSArray *otherActions;
@property (nonatomic) BOOL isGreedy;
@property (nonatomic) CTAlertType alertType;

// The style of how to display the alert. Popup or alertview.
@property (nonatomic) AlertStyle alertStyle;

// Initializes a popup style alert object. Look at the alert handler to see what each is used for.
- (instancetype)initWithTitle:(NSString *)title message:(NSString *)message cancelAction:(CTMVMAlertAction *)cancelAction otherActions:(NSArray *)otherActions isGreedy:(BOOL)isGreedy;

// Initializes an alert view style object.
- (instancetype)initWithMessage:(NSString *)message alertType:(CTAlertType)alertType;

// Initializes an alert view that can show in either a popup or an alert view.
- (instancetype)initWithTitle:(NSString *)title message:(NSString *)message cancelAction:(CTMVMAlertAction *)cancelAction otherActions:(NSArray *)otherActions isGreedy:(BOOL)isGreedy alertType:(CTAlertType)alertType;

@end
