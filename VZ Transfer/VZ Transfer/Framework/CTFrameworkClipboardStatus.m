//
//  CTFrameworkClipboardStatus.m
//  contenttransfer
//
//  Created by Sun, Xin on 3/28/17.
//  Copyright © 2017 Verizon Wireless Inc. All rights reserved.
//

#import "CTFrameworkClipboardStatus.h"
@interface CTFrameworkClipboardStatus () {
//    BOOL _passwordCopied;
    NSString *_targetPassword;
}
@end

@implementation CTFrameworkClipboardStatus

+ (instancetype)sharedInstance {
    
    static id sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
//        _passwordCopied = NO;
        _targetPassword = nil;
    }
    
    return self;
}

- (void)pasteBoardDidPastePassword:(NSString *)password {
//    _passwordCopied = YES;
    _targetPassword = password;
}

/**
 * Query the result if password for content transfer is copied into Clipboard
 * @return BOOL If copied password, then return NO; Otherwise return YES;
 */
- (BOOL)pasteBoardHasContentTransferPassword {
    return [UIPasteboard.generalPasteboard.string isEqualToString:_targetPassword];
}

@end
