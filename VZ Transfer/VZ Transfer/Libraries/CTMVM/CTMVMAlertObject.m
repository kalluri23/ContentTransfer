//
//  MVMAlertObject.m
//  VZ Transfer
//
//  Created by Hadapad, Prakash on 5/19/16.
//  Copyright © 2016 Hadapad, Prakash. All rights reserved.
//

#import "CTMVMAlertObject.h"

@implementation CTMVMAlertObject

- (instancetype)initWithTitle:(NSString *)title message:(NSString *)message cancelAction:(CTMVMAlertAction *)cancelAction otherActions:(NSArray *)otherActions isGreedy:(BOOL)isGreedy {
    if (self = [super init]) {
        self.title = title;
        self.message = message;
        self.cancelAction = cancelAction;
        self.otherActions = otherActions;
        self.isGreedy = isGreedy;
        self.alertStyle = AlertStylePopup;
    }
    return self;
    
}

- (instancetype)initWithMessage:(NSString *)message alertType:(CTAlertType)alertType {
    if (self = [super init]) {
        self.message = message;
        self.alertType = alertType;
        self.alertStyle = AlertStyleAlertView;
    }
    return self;
}

- (instancetype)initWithTitle:(NSString *)title message:(NSString *)message cancelAction:(CTMVMAlertAction *)cancelAction otherActions:(NSArray *)otherActions isGreedy:(BOOL)isGreedy alertType:(CTAlertType)alertType {
    if (self = [super init]) {
        self.title = title;
        self.message = message;
        self.cancelAction = cancelAction;
        self.otherActions = otherActions;
        self.isGreedy = isGreedy;
        self.alertType = alertType;
        self.alertStyle = AlertStyleAvailable;
    }
    return self;
}


@end
