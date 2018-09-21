//
//  NSString+CTRootDocument.m
//  contenttransfer
//
//  Created by Sun, Xin on 9/12/16.
//  Copyright © 2016 Verizon Wireless. All rights reserved.
//

#import "NSString+CTRootDocument.h"

@implementation NSString (CTRootDocument)

+ (NSString *)appRootDocumentDirectory
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:basePath]) { // If folder doesn't exist, create it
        [[NSFileManager defaultManager] createDirectoryAtPath:basePath withIntermediateDirectories:YES attributes:nil error:NULL];
    }
    
    return basePath;
}

@end
