//
//  NSData+CTHelper.h
//  contenttransfer
//
//  Created by Mehta, Snehal Natwar on 9/6/16.
//  Copyright © 2016 Hadapad, Prakash. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (CTHelper)
/*!
    @brief Read the chunk of the file saved in specific path with start offset and chunck size.
    @param path File path URL that saving the file. This is NSURL object, use [NSURL fileURLWithPath:] to covert NSString to NSURL.
    @prarm offset Start position of the chunk.
    @param size Size of current chunck.
    @return NSData Data for specific chunk. If error happened, return nil, and a error will be logged in console.
 */
+ (NSData *)dataWithContentsOfFile:(NSURL *)path atOffset:(off_t)offset withSize:(size_t)size;
/*!
 Append CRLF data at the end of NSData and generate a new data object. It will be "/r/n".
 @note CRLF is using for cross platform socket transfer, for Android side to sperate the data and request.
 @return NSData object with old data and CRLF at the end.
 */
- (NSData *)appendCRLFData;

@end
