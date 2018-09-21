//
//  VZSharedAnalytics+Helpers.h
//  contenttransfer
//
//  Created by Snehal on 8/3/16.
//  Copyright © 2016 Hadapad, Prakash. All rights reserved.
//

#import "VZSharedAnalytics.h"

typedef void(^AnalyticsMediaInfoBlock)(NSMutableDictionary *mediaAnalyticsDictionary);
/**
 Deprecated.
 */
@interface VZSharedAnalytics (Helpers)

- (void)getMediaInfoForMedia:(NSDictionary *)mediaData
 withAnalyticsMediaInfoBlock:(AnalyticsMediaInfoBlock)block;

@end
