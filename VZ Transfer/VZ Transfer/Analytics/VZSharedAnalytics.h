//
//  VZSharedAnalytics.h
//  contenttransfer
//
//  Created by Mehta, Snehal Natwar on 7/26/16.
//  Copyright © 2016 Hadapad, Prakash. All rights reserved.
//

#import <Foundation/Foundation.h>
/**
 Deprecated.
 */
@interface VZSharedAnalytics : NSObject

+ (nonnull instancetype)sharedInstance;

- (void)trackState:(nullable NSString *)state data:(nullable NSDictionary *)dataDictionary;
- (void)trackAction:(nullable NSString *)action data:(nonnull NSDictionary *)dataDictionary;

@end
