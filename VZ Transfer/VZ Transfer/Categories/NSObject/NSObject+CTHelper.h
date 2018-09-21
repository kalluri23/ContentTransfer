//
//  NSObject+CTHelper.h
//  contenttransfer
//
//  Created by Sun, Xin on 4/25/17.
//  Copyright © 2017 Verizon Wireless Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (CTHelper)

/*!
 This method will check if target object has value for given key.
 
 If key doesn't exist, when calling valueForKey, will throw an excecption. Because valueForKey itself cannot throw any exception, so implement this method in Object-C to catch the unexpected exceptions.
 
 This method will try to use valueForKey, and if no exception thrown, means key exists.
 @parameter key Key want to read from NSObject.
 @return BOOL value indicate key-value exist or not.
 */
- (BOOL)hasKey:(NSString *)key;

@end
