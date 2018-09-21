//
//  NSString+CTMVMConvenience.m
//  contenttransfer
//
//  Created by Hadapad, Prakash on 8/31/16.
//  Copyright © 2016 Hadapad, Prakash. All rights reserved.
//

#import "NSString+CTMVMConvenience.h"

@implementation NSString (CTMVMConvenience)

- (NSString *)formatRequestForXPlatform
{
    NSString *temp = @"";
    temp = [self stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    temp = [temp stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    
    return temp;
}

+ (nonnull NSString *)formattedDataSizeText:(double)bytes {
    
    bytes /= (1024*1024);
    
    if (bytes > 0 && bytes<0.1) {
        return @"0.1 MB";
    }
    
    return [NSString stringWithFormat:@"%.1f MB", bytes];
}

+ (nonnull NSString *)formattedDataSizeTextInTransferWhatScreen:(double)bytes {
    
    if ((bytes/(1024*1024) >=1)) {
        
        bytes /= (1024*1024);
        return [NSString stringWithFormat:@"%.1f %@", bytes, @"MB"];
        
    }else if (bytes){
        return [NSString stringWithFormat:@"%@", CTLocalizedString(CT_STM_SENDER_LESS_THAN_1MB, nil)];
        
    } else {
        return [NSString stringWithFormat:@"0 MB"];
    }
    
}

- (NSString *)removeHeartBeat
{
    NSString *temp = @"";
    temp = [self stringByReplacingOccurrencesOfString:@"VZTRANSFER_KEEP_ALIVE_HEARTBEAT" withString:@""];
    
    return temp;
}


@end
