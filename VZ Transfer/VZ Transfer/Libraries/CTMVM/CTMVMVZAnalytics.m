//
//  VZAnalytics.m
//  VZ Transfer
//
//  Created by Hadapad, Prakash on 5/20/16.
//  Copyright © 2016 Hadapad, Prakash. All rights reserved.
//

#import "CTMVMVZAnalytics.h"

@implementation CTMVMVZAnalytics


- (instancetype)initWithApplicationName:(NSString *)name withEncrptionOFF:(BOOL)flag withExtraInfo: (NSDictionary *)extraInfo {
    
    return self;
}

- (void)syncAllDataInBackgroundWithCompletionBlock:(void (^)(void))completionBlock {
    
    
}
- (void)trackEvent:(UIView *)view withTrackTag:(NSString *)tagName {
    
    
}

- (void)trackEvent:(UIView *)view withTrackTag:(NSString *)tagName withExtraInfo:(NSDictionary *)extra isEncryptedExtras:(BOOL)flag {
    
    
}

- (void)trackController:(UIViewController *)controller withName:(NSString *)name withExtraInfo:(NSDictionary *)extra isEncryptedExtras:(BOOL)flag {
    
    
}

@end
