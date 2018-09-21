//
//  NSMutableString+CTMVMConvenience.m
//  contenttransfer
//
//  Created by Hadapad, Prakash on 8/31/16.
//  Copyright © 2016 Hadapad, Prakash. All rights reserved.
//

#import "NSMutableString+CTMVMConvenience.h"

@implementation NSMutableString (CTMVMConvenience)

- (void)appendStringIfValid:(NSString *)aString
{
    if(aString)
    {
        [self appendString:aString];
    }
}

@end
