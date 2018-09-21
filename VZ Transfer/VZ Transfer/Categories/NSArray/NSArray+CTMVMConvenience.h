//
//  NSArray+CTMVMConvenience.h
//  contenttransfer
//
//  Created by Hadapad, Prakash on 8/31/16.
//  Copyright © 2016 Hadapad, Prakash. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (CTMVMConvenience)

/*!
 Convenient function check if array is Not null or is nil.

 Returns YES if the array is not NUll and has a count > 0, otherwise return NO.
 @return Bool value indicate the result.
 */
- (BOOL)isNotNUllOrNil;

/*!
 Gets the object from the array and verfies that it is of a given type.
 @param type Class type wants to read from array.
 @return Object will be returned is it exists in array and its type matches given type; Otherwise nil will be returned.
 */
- (id)objectAtIndex:(NSUInteger)index ofType:(Class)type;

/*! 
    @brief Get the string object at a given index.
    @param Index NSUInteger value represent the index in the NSArray.
    @return Empty string if object at index is not a valid string.
 */
- (NSString *)stringAtIndex:(NSUInteger)index;

@end
