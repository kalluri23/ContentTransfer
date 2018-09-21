//
//  NSMutableArray+CTMVMConvenience.m
//  contenttransfer
//
//  Created by Hadapad, Prakash on 8/31/16.
//  Copyright © 2016 Hadapad, Prakash. All rights reserved.
//

#import "NSMutableArray+CTMVMConvenience.h"

@implementation NSMutableArray (CTMVMConvenience)

- (void)addObjectWithValidations:(id)anObject
{
    if (anObject && ![anObject isKindOfClass:[NSNull class]]) {
        [self addObject:anObject];
    }
    // else it will ignore it
}


@end
