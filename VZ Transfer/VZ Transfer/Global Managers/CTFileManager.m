//
//  CTFileManager.m
//  contenttransfer
//
//  Created by Guntupalli, Neelima on 8/29/16.
//  Copyright © 2016 Verizon. All rights reserved.
//

#import "CTFileManager.h"

@implementation CTFileManager

+ (void)createFileWithName:(NSString*)fileName withContents:(NSData*)dataContent{
    
    NSString *basePath = [CTFileManager documentsDirectoryBasePath];
    NSString *filePath = [NSString stringWithFormat:@"%@/%@",basePath,fileName];
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        [[NSFileManager defaultManager] removeItemAtPath:fileName error:nil];
    }
    [[NSFileManager defaultManager] createFileAtPath:filePath contents:dataContent attributes:nil];
}

+ (void)createDirectory:(NSString*)directoryName withFileName:(NSString*)fileName withContents:(NSData*)dataContent
        completionBlock:(void(^)(NSString *filePath, NSError *error))block {
    
    NSFileManager *fileManager = [NSFileManager defaultManager];

    NSString *basePath = [CTFileManager documentsDirectoryBasePath];
    
    NSString *docPath = [NSString stringWithFormat:@"%@/%@",basePath,directoryName];
    NSError *error = nil;

    if (![fileManager fileExistsAtPath:docPath]) {
        
        if (![[NSFileManager defaultManager] createDirectoryAtPath:docPath withIntermediateDirectories:YES attributes:nil error:&error]) {
            block(nil, error);
            return;
        }
        
    }
    
    NSString *filePath = [NSString stringWithFormat:@"%@/%@",docPath,fileName];
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        if (![[NSFileManager defaultManager] removeItemAtPath:filePath error:&error]) {
            block(nil, error);
            return;
        }
    }
    [fileManager createFileAtPath:filePath contents:dataContent attributes:nil];
    
    block(filePath, nil);
}

+(NSString*)documentsDirectoryBasePath {
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    return basePath;
}

+(NSData*)dataFromFile:(NSString*)filePath {

    NSString *basePath = [CTFileManager documentsDirectoryBasePath];
    
    NSData *fileData = [[NSFileManager defaultManager] contentsAtPath:[NSString stringWithFormat:@"%@/%@",basePath,filePath]];
    return fileData;
}

+ (void)writefileWithPath:(NSString *)path andData:(NSData *)data {
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) { // exist, then delete first
        [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
    }
    
    [data writeToFile:path atomically:NO];
}
@end
