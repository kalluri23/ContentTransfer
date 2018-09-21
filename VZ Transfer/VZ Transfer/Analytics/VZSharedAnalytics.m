//
//  VZSharedAnalytics.m
//  contenttransfer
//
//  Created by Mehta, Snehal Natwar on 7/26/16.
//  Copyright © 2016 Hadapad, Prakash. All rights reserved.
//

#import "VZSharedAnalytics.h"
#import "ADBMobile.h"
#import "NSString+CTRootDocument.h"

@interface VZSharedAnalytics (){
    
    NSString *filePath;
}

@end
@implementation VZSharedAnalytics

+ (instancetype)sharedInstance {
    
    static VZSharedAnalytics *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[VZSharedAnalytics alloc] init];
    });
    
    return sharedInstance;
}

- (instancetype)init {
    
    self = [super init];
    
    if (self) {
        NSString *basePath = [NSString appRootDocumentDirectory];
        filePath = [basePath stringByAppendingPathComponent:@"AnalyticsLogfile.txt"];
    }
    
    return self;
}

- (void)trackState:(nullable NSString *)state data:(nullable NSDictionary *)dataDictionary {
    
   
    if([[NSFileManager defaultManager] fileExistsAtPath:filePath]){
        [self writeData:dataDictionary AnalyticsToFile:filePath];
    }
    DebugLog(@"Analytics --- State  %@",dataDictionary);
    
#if SITE_CATALYST
    [ADBMobile trackState:state data:dataDictionary];
#endif

}
- (void)trackAction:(nullable NSString *)action data:(nonnull NSDictionary *)dataDictionary {

    DebugLog(@"Track action %@", action);
    DebugLog(@"Analytics --- Action dictionary %@",dataDictionary);
    if([[NSFileManager defaultManager] fileExistsAtPath:filePath]){
        [self writeData:dataDictionary AnalyticsToFile:filePath];
    }
    
#if SITE_CATALYST
    
    [ADBMobile trackAction:action data:dataDictionary];
#endif
    
}

-(void) writeData:(NSDictionary*)logData AnalyticsToFile:(NSString*)path{
    
    NSFileHandle *file = [NSFileHandle fileHandleForUpdatingAtPath:path];
    [file seekToEndOfFile];
    NSString *allstring = [NSString stringWithFormat:@"%@",logData];
    [file writeData:[allstring dataUsingEncoding:NSUTF8StringEncoding]];
    [file closeFile];
}

@end
