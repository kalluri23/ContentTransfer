//
//  NSNumber+CTHelper.m
//  contenttransfer
//
//  Created by Mehta, Snehal Natwar on 9/19/16.
//  Copyright © 2016 Verizon Wireless. All rights reserved.
//

#import "NSNumber+CTHelper.h"

@implementation NSNumber (CTHelper)

+ (NSString *)formattedDataSizeText:(NSNumber *)amount {
    return [NSString stringWithFormat:@"%@ MB", [self toMBs:amount]];
}

+ (NSString *)toMBs:(NSNumber *)amount {
    
    double bytes = [amount doubleValue];
    bytes /= (1024*1024);
    
    if (bytes > 0 && bytes < 0.1) {
        return @"0.1";
    }else if (bytes < 0) {
        return @"0.0";
    }
    
    return [NSString stringWithFormat:@"%.1f", bytes];
}

+ (double)toMB:(long long)amount {
    
    double result = (double)amount / (1024.f * 1024.f);
    
    if (result > 0 && result < 0.1) {
        result = 0.1f;
    }else if (result < 0) {
        return 0.0f;
    }
    
    return result;
}

+ (double)getOnly2Decimal:(double)input {
    return [[NSString stringWithFormat:@"%.2f", input] doubleValue];
}

@end
