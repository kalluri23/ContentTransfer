//
//  NSDictionary+CTMVMConvenience.m
//  contenttransfer
//
//  Created by Hadapad, Prakash on 8/31/16.
//  Copyright © 2016 Hadapad, Prakash. All rights reserved.
//

#import "NSDictionary+CTMVMConvenience.h"

@implementation NSDictionary (CTMVMConvenience)

-(BOOL)isNotNUllOrNil {
    
    if(![self isKindOfClass:[NSNull class]] && self.count>0) {
        
        return YES;
    }
    return NO;
}

- (id)objectForKey:(id<NSCopying>)key ofType:(Class)type; {
    id theObject = [self objectForKey:key];
    
    return ([theObject isKindOfClass:type] ? theObject : nil);
}

- (NSString *)string:(id<NSCopying>)key {
    return [self objectForKey:key ofType:[NSString class]];
}

- (id)dict:(id<NSCopying>)key {
    return [self objectForKey:key ofType:[NSDictionary class]];
}

- (id)array:(id<NSCopying>)key {
    return [self objectForKey:key ofType:[NSArray class]];
}

- (BOOL)boolForKey:(id<NSCopying>) key {
   	return [[self objectForKey:key ofType:[NSNumber class]] boolValue];
}
- (CGFloat)floatForKey:(id<NSCopying>)key {
    return [[self objectForKey:key ofType:[NSNumber class]] floatValue];
}
- (NSInteger)integer:(id<NSCopying>)key {
    return [[self objectForKey:key ofType:[NSNumber class]] intValue];
}
- (NSDictionary *)dictionaryWithChainOfKeysOrIndexes:(NSArray *)keysOrIndexes {
    NSDictionary *dict = [self objectChainOfKeysOrIndexes:keysOrIndexes validType:[NSDictionary class]];
    return dict ? dict : @{};
}

- (id)objectChainOfKeysOrIndexes:(NSArray *)keysOrIndexes {
    
    __block id previousObject = self;
    [keysOrIndexes enumerateObjectsUsingBlock:^(id currentKeyOrIndex, NSUInteger index, BOOL *stop){
        
        if ([currentKeyOrIndex isKindOfClass:[NSString class]] && [previousObject isKindOfClass:[NSDictionary class]]) {
            
            // If it is a string key and the previous object in the chain is a dictionary, grab the next object.
            previousObject = [previousObject objectForKey:currentKeyOrIndex];
        } else if ([currentKeyOrIndex isKindOfClass:[NSNumber class]] && [previousObject isKindOfClass:[NSArray class]]) {
            
            NSInteger i = [currentKeyOrIndex integerValue];
            if (i < [previousObject count]) {
                
                // If it is a number key and the previous object is an array, grab the next object.
                previousObject = [previousObject objectAtIndex:i];
            } else {
                previousObject = nil;
                *stop = YES;
            }
        } else {
            previousObject = nil;
            *stop = YES;
        }
    } ];
    
    return previousObject;
}

- (id)objectChainOfKeysOrIndexes:(NSArray *)keysOrIndexes validType:(Class)type {
    id object = [self objectChainOfKeysOrIndexes:keysOrIndexes];
    return ([object isKindOfClass:type] ? object : nil);
}

- (NSArray *)arrayForChainOfKeysOrIndexes:(NSArray *)keysOrIndexes {
    return [self objectChainOfKeysOrIndexes:keysOrIndexes validType:[NSArray class]];
}

- (NSString *)stringForChainOfKeysOrIndexes:(NSArray *)keysOrIndexes {
    return ([self objectChainOfKeysOrIndexes:keysOrIndexes validType:[NSString class]] ?: @"");
}

- (NSString *)stringForKey:(NSString *)key {
    return ([self objectForKey:key ofType:[NSString class]] ?: @"");
}

#pragma mark - Common Values

- (NSString *)pageType {
    NSString *pageTypeString = [self stringForChainOfKeysOrIndexes:@[PAGE_INFO, PAGE_TYPE]];
    if (pageTypeString.length == 0) {
        pageTypeString = [self stringForChainOfKeysOrIndexes:@[PAGE_INFO_LOWER_CASE, PAGE_TYPE]];
    }
    return pageTypeString;
}


@end
