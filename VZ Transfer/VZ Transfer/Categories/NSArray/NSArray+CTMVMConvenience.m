//
//  NSArray+CTMVMConvenience.m
//  contenttransfer
//
//  Created by Hadapad, Prakash on 8/31/16.
//  Copyright © 2016 Hadapad, Prakash. All rights reserved.
//

#import "NSArray+CTMVMConvenience.h"

@implementation NSArray (CTMVMConvenience)

-(BOOL)isNotNUllOrNil {
    
    if(![self isKindOfClass:[NSNull class]] && self.count>0) {
        
        return YES;
    }
    return NO;
}

- (id)objectAtIndex:(NSUInteger)index ofType:(Class)type {
    id theObject = nil;
    
    if ([self count] > index) {
        theObject = [self objectAtIndex:index];
    }
    
    return ([theObject isKindOfClass:type] ? theObject : nil);
}

- (NSString *)stringAtIndex:(NSUInteger)index {
    id object = [self objectAtIndex:index ofType:[NSString class]];
    
    return (object ? object : @"");
}

@end
