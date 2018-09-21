//
//  NSDictionary+CTMVMConvenience.h
//  contenttransfer
//
//  Created by Hadapad, Prakash on 8/31/16.
//  Copyright © 2016 Hadapad, Prakash. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (CTMVMConvenience)

/*!
 Check dictionary is not null or is nil.
 @return YES if the dictionary is not NUll and has a count > 0; Otherwise return NO.
 */
- (BOOL)isNotNUllOrNil;
/*! 
    @brief Gets the object from the dictionary and verfies that it is of a given type.
    @param key Key using in dictionary.
    @param type Type of class use to identify the value type.
    @return Object if value is specific type, or nil if it's not.
 */
- (id)objectForKey:(id<NSCopying>)key ofType:(Class)type;
/*!
 Convenient function to return string value for given key. Value has to be NSString/String saved in dictionary.
 @param key String value represent the key in dictionary.
 @return NSString value saved in dictionary.
 */
- (NSString *)string:(id<NSCopying>)key;
/*!
 Convenient function to return dictionary object for given key. Value has to be dictionary saved in dictionary.
 @param key String value represent the key in dictionary.
 @return NSDictionary object saved in dictionary.
 */
- (id)dict:(id<NSCopying>)key;
/*!
 Convenient function to return array object for given key. Value has to be array saved in dictionary.
 @param key String value represent the key in dictionary.
 @return NSArray object saved in dictionary.
 */
- (id)array:(id<NSCopying>)key;
/*!
 Convenient function to return integer value for given key. Value has to be integer saved in dictionary.
 @param key String value represent the key in dictionary.
 @return NSInteger saved in dictionary.
 */
- (NSInteger)integer:(id<NSCopying>)key;
/*!
 Convenient function to return float value for given key. Value has to be float saved in dictionary.
 @param key String value represent the key in dictionary.
 @return CGFloat object saved in dictionary.
 */
- (CGFloat)floatForKey:(id<NSCopying>)key;
/*!
 Gets an object that is nested using a series of keys or indexes to reach it. Root object should be either a NSDictionary or NSArray.
 @note All keys should be of type NSString and is used for nested dictionaries.
 
 All indexes should be of type NSNumber and is used for nested arrays.
 @param keysOrIndics Array of indics to search
 @return Object contains all the matching result.
 */
- (id)objectChainOfKeysOrIndexes:(NSArray *)keysOrIndics;
/*!
 Gets an object that is nested using a series of keys or indexes to reach it and verifies it is of a specific type. Root object should be either a NSDictionary or NSArray, and value should be the same type of given class.
 @note All keys should be of type NSString and is used for nested dictionaries.
 
 All indexes should be of type NSNumber and is used for nested arrays.
 @param keysOrIndics Array of indics to search.
 @param type Class type given.
 @return Object contains all that matching the conditions.
 */
- (id)objectChainOfKeysOrIndexes:(NSArray *)keysOrIndics validType:(Class)type;
/*! 
    @brief Gets the string object for a given key.
    @param key NSString value represents the key using for dictionary.
    @return NSString value saved in dictionary. Return empty string if object for key is not a valid string.
 */
- (NSString *)stringForKey:(NSString *)key;
/*!
 Gets a string value that is nested using a series of keys or indexes to reach it. Root object should be either a NSDictionary or NSArray.
 @note All keys should be of type NSString and is used for nested dictionaries.
 
 All indexes should be of type NSNumber and is used for nested arrays.
 @param keysOrIndics Array of indics to search
 @return String that matchs result.
 */
- (NSString *)stringForChainOfKeysOrIndexes:(NSArray *)keysOrIndics;
/*!
 Convenient function to return bool value for given key. Value has to be bool saved in dictionary.
 @param key String value represent the key in dictionary.
 @return BOOL object saved in dictionary.
 */
- (BOOL)boolForKey:(id<NSCopying>)key;
/*!
 Gets a dictionary object that is nested using a series of keys or indexes to reach it. Root object should be either a NSDictionary or NSArray.
 @note All keys should be of type NSString and is used for nested dictionaries.
 
 All indexes should be of type NSNumber and is used for nested arrays.
 @param keysOrIndics Array of indics to search
 @return NSDictionary object that matchs result.
 */
- (NSDictionary *)dictionaryWithChainOfKeysOrIndexes:(NSArray *)keysOrIndexes;
/*!
 Gets a array object that is nested using a series of keys or indexes to reach it. Root object should be either a NSDictionary or NSArray.
 @note All keys should be of type NSString and is used for nested dictionaries.
 
 All indexes should be of type NSNumber and is used for nested arrays.
 @param keysOrIndics Array of indics to search
 @return NSArray object that matchs result.
 */
- (NSArray *)arrayForChainOfKeysOrIndexes: (NSArray *) keysOrIndexes;
/*!
 Get page type string.
 @return NSString value represents the type of the page.
 */
- (NSString *)pageType;

@end
