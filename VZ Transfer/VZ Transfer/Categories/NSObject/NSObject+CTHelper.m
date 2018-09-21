//
//  NSObject+CTHelper.m
//  contenttransfer
//
//  Created by Sun, Xin on 4/25/17.
//  Copyright © 2017 Verizon Wireless Inc. All rights reserved.
//

#import "NSObject+CTHelper.h"

@implementation NSObject (CTHelper)

- (BOOL)hasKey:(NSString *)key {
    @try {
        [self valueForKey:key];
        return YES;
    } @catch(NSException *error) {
        NSLog(@"No key value pair available for object.");
        return NO;
    }
}

@end
