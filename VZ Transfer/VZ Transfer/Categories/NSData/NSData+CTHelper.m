//
//  NSData+CTHelper.m
//  contenttransfer
//
//  Created by Mehta, Snehal Natwar on 9/6/16.
//  Copyright © 2016 Hadapad, Prakash. All rights reserved.
//

#import "NSData+CTHelper.h"
#import "GCDAsyncSocket.h"

@implementation NSData (CTHelper)

+ (NSData *)dataWithContentsOfFile:(NSURL *)path atOffset:(off_t)offset withSize:(size_t)size {
    @try {
        NSError *error = nil;
        NSFileHandle *fileHandle = [NSFileHandle fileHandleForReadingFromURL:path error:&error];
        if (error) {
            DebugLog(@"error : %@", error.localizedDescription);
            return nil;
        }
        [fileHandle seekToFileOffset:offset];
        
        // NSData takes ownership and will call free(data) when it's released
        return [fileHandle readDataOfLength:size];
    } @catch (NSException *exception) {
        NSLog(@"Exception raised when reading the data:%@", exception.description);
    }
}

- (NSData *)appendCRLFData {
    NSMutableData *tmpData = nil;
    if (![self isKindOfClass:[NSMutableData class]]) {
        tmpData = [self mutableCopy];
    } else {
        tmpData = (NSMutableData *)self;
    }
    
    [tmpData appendData:[GCDAsyncSocket CRLFData]];
    
    return tmpData;
}

//#warning Please dont use this method to convert NSData to NSString, it is not it is it returns null if data length is too large 255
//- (NSString *)toString {
//    
//    if (self) {
//        return [NSString stringWithUTF8String:[self bytes]];
//    }else {
//        return nil;
//    }
//}

@end
