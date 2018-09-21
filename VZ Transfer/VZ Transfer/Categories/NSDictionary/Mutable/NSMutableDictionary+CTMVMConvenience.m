//
//  NSMutableDictionary+CTMVMConvenience.m
//  contenttransfer
//
//  Created by Hadapad, Prakash on 8/31/16.
//  Copyright © 2016 Hadapad, Prakash. All rights reserved.
//

#import "NSMutableDictionary+CTMVMConvenience.h"

@implementation NSMutableDictionary (CTMVMConvenience)

- (BOOL) setObjectIfValid:(id) obj forKey:(NSString*)key defaultObject:(id)obj1{
    
    if(obj) {
        [self setObject:obj forKey:key];
        return true;
    }else{
        [self setObject:obj1 forKey:key];
        return true;
    }
}

- (BOOL) addEntriesFromDictionaryIfValid:(NSDictionary *) dict {
    if(dict && [dict isKindOfClass:[NSDictionary class]]) {
        [self addEntriesFromDictionary:dict];
        return true;
    }
    
    return false;
}


@end
