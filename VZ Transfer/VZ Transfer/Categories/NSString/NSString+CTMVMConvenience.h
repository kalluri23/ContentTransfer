//
//  NSString+CTMVMConvenience.h
//  contenttransfer
//
//  Created by Hadapad, Prakash on 8/31/16.
//  Copyright © 2016 Hadapad, Prakash. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (CTMVMConvenience)
#pragma mark - Instance methods
/*!
    @brief Method to remove the \R\N attached from string
    @discussion This is a instance method, need string instance to call.
    @return NString without any \r\n in it.
 */
- (NSString * _Nullable)formatRequestForXPlatform;
/*!
 Remove heart beat request from package.
 @return NSString value represents the result without heart beat bytes.
 */
- (NSString * _Nullable )removeHeartBeat;

#pragma mark - Class methods
/*!
 Compares strings in a case insensitive manner.
 */
+ (nonnull NSString *)formattedDataSizeText:(double)bytes;
/*!
 @brief Format the size string into "XXX.X MB"
 @discussion If size is less than 1MB, then return value "Less Than 1MB"; If size is 0, then return "0 MB".
 @param bytes double value represent size in byte.
 @return NSString formatted size in MB.
 */
+ (nonnull NSString *)formattedDataSizeTextInTransferWhatScreen:(double)bytes;

@end
