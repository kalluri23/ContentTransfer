//
//  MVMAlertAction.m
//  VZ Transfer
//
//  Created by Hadapad, Prakash on 5/19/16.
//  Copyright © 2016 Hadapad, Prakash. All rights reserved.
//

#import "CTMVMAlertAction.h"

@implementation CTMVMAlertAction

- (instancetype)initWithTitle:(NSString *)title style:(UIAlertActionStyle)style handler:(void (^)(UIAlertAction *action))handler {
    if (self = [super init]) {
        self.title = title;
        self.style = style;
        self.handler = handler;
    }
    return self;
}

+ (instancetype)actionWithTitle:(NSString *)title style:(UIAlertActionStyle)style handler:(void (^)(UIAlertAction *action))handler {
    return [[CTMVMAlertAction alloc] initWithTitle:title style:style handler:handler];
}

- (UIAlertAction *)alertAction {
    return [UIAlertAction actionWithTitle:self.title style:self.style handler:self.handler];
}


@end
