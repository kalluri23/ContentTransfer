//
//  NSMutableDictionary+CTMVMConvenience.h
//  contenttransfer
//
//  Created by Hadapad, Prakash on 8/31/16.
//  Copyright © 2016 Hadapad, Prakash. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableDictionary (CTMVMConvenience)
/*!
    @brief Set object into Dictionary for specific key value.
    @discussion This method will check the the target object is valid or not, if it's valid, then assign; otherwise assign the default value. When process finished, YES will be returned.
    @param obj object need to be assigned to dictionary.
    @param key key for target object.
    @param obj1 default value for the object, if target object is not valid
    @return BOOL value indicate the result of insertion.
 */
- (BOOL)setObjectIfValid:(id) obj forKey:(NSString*)key defaultObject:(id)obj1;
/*!
 Add entries from another dictionary with validation check.
 @param dict Input dictionary
 @return Bool value indicate the result. Return YES if items added into target dictionary, otherwise return NO.
 */
- (BOOL)addEntriesFromDictionaryIfValid:(NSDictionary *)dict;

@end
