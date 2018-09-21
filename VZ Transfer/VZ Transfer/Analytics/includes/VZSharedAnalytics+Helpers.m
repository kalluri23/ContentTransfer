//
//  VZSharedAnalytics+Helpers.m
//  contenttransfer
//
//  Created by Snehal on 8/3/16.
//  Copyright © 2016 Hadapad, Prakash. All rights reserved.
//

#import "VZSharedAnalytics+Helpers.h"

@implementation VZSharedAnalytics (Helpers)


//Prakash_Analytics changes

- (void)getMediaInfoForMedia:(NSDictionary *)mediaData
 withAnalyticsMediaInfoBlock:(AnalyticsMediaInfoBlock)block {
    
    NSMutableDictionary *paramDictionary = [NSMutableDictionary dictionary];
    NSMutableString *selectedMediaTypesString = [NSMutableString string];
    
    [mediaData enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        
        if ([key isEqualToString:@"photos"]) {
            NSDictionary *mediaInfo = (NSDictionary *)obj;
            
            if ([mediaInfo objectForKey:@"totalCount"] &&
                [[[mediaInfo objectForKey:@"status"] lowercaseString] isEqualToString:@"true"]) {
                [paramDictionary setObject:[mediaInfo objectForKey:@"totalCount"]
                                    forKey:ANALYTICS_TrackAction_Key_NbOfPhotosToTransfer];
                
                (selectedMediaTypesString.length > 0)?[selectedMediaTypesString appendString:@"|photos"]:[selectedMediaTypesString appendString:@"photos"];
            }
        }
        
        if ([key isEqualToString:@"videos"]) {
            NSDictionary *mediaInfo = (NSDictionary *)obj;
            
            if ([mediaInfo objectForKey:@"totalCount"] &&
                [[[mediaInfo objectForKey:@"status"] lowercaseString] isEqualToString:@"true"]) {
                [paramDictionary setObject:[mediaInfo objectForKey:@"totalCount"]
                                    forKey:ANALYTICS_TrackAction_Key_NbOfVideosToTransfer];
                
               (selectedMediaTypesString.length > 0)?[selectedMediaTypesString appendString:@"|videos"]:[selectedMediaTypesString appendString:@"videos"];
            }
        }
        
        if ([key isEqualToString:@"calendar"]) {
            NSDictionary *mediaInfo = (NSDictionary *)obj;
            
            if ([mediaInfo objectForKey:@"totalCount"] &&
                [[[mediaInfo objectForKey:@"status"] lowercaseString] isEqualToString:@"true"]) {
                [paramDictionary setObject:[mediaInfo objectForKey:@"totalCount"]
                                    forKey:ANALYTICS_TrackAction_Key_NbOfCalendarsToTransfer];
                
                (selectedMediaTypesString.length > 0)?[selectedMediaTypesString appendString:@"|calendars"]:[selectedMediaTypesString appendString:@"calendars"];
            }
        }
        
        if ([key isEqualToString:@"contacts"]) {
            NSDictionary *mediaInfo = (NSDictionary *)obj;
            
            if ([mediaInfo objectForKey:@"totalCount"] &&
                [[[mediaInfo objectForKey:@"status"] lowercaseString] isEqualToString:@"true"]) {
                [paramDictionary setObject:[mediaInfo objectForKey:@"totalCount"]
                                    forKey:ANALYTICS_TrackAction_Key_NbOfContactsToTransfer];
                
                (selectedMediaTypesString.length > 0)?[selectedMediaTypesString appendString:@"|contacts"]:[selectedMediaTypesString appendString:@"contacts"];
            }
        }
        
        if ([key isEqualToString:@"reminder"]) {
            NSDictionary *mediaInfo = (NSDictionary *)obj;
            
            if ([mediaInfo objectForKey:@"totalCount"] &&
                [[[mediaInfo objectForKey:@"status"] lowercaseString] isEqualToString:@"true"]) {
                [paramDictionary setObject:[mediaInfo objectForKey:@"totalCount"]
                                    forKey:ANALYTICS_TrackAction_Key_NbRemindersToTransfer];
                
                (selectedMediaTypesString.length > 0)?[selectedMediaTypesString appendString:@"|reminders"]:[selectedMediaTypesString appendString:@"reminders"];
            }
        }
        

    }];
    
    if (selectedMediaTypesString.length > 0) {
        [paramDictionary setObject:selectedMediaTypesString forKey:ANALYTICS_TrackAction_Key_MediaSelected];
    }
    
    block(paramDictionary);
}

@end
