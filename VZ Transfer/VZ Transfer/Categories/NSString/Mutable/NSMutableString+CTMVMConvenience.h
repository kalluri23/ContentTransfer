//
//  NSMutableString+CTMVMConvenience.h
//  contenttransfer
//
//  Created by Hadapad, Prakash on 8/31/16.
//  Copyright © 2016 Hadapad, Prakash. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableString (CTMVMConvenience)
/*!
 Append string if input is valid. If input string is nil, then nothing will be appended. This method is to prevent unnecessary crash for app.
 @param aString String value want to append to self.
 */
- (void)appendStringIfValid:(NSString *)aString;

@end
