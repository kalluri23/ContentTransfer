//
//  CTUploadCrashReport.m
//  VZ Transfer
//
//  Created by Hadapad, Prakash on 6/22/16.
//  Copyright © 2016 Hadapad, Prakash. All rights reserved.
//

#import "CTUploadCrashReport.h"
#import "NSString+CTRootDocument.h"
#import "CTMVMReachability.h"
#import "CTUserDevice.h"
#import "CTContentTransferSetting.h"


@import SystemConfiguration.CaptiveNetwork;

@implementation CTUploadCrashReport

- (NSString *)fetchSSIDInfo
{
    NSArray *interfaceNames = CFBridgingRelease(CNCopySupportedInterfaces());
    DebugLog(@"%s: Supported interfaces: %@", __func__, interfaceNames);
    
    NSDictionary *SSIDInfo;
    for (NSString *interfaceName in interfaceNames) {
        SSIDInfo = CFBridgingRelease(
                                     CNCopyCurrentNetworkInfo((__bridge CFStringRef)interfaceName));
        DebugLog(@"%s: %@ => %@", __func__, interfaceName, SSIDInfo);
        
        BOOL isNotEmpty = (SSIDInfo.count > 0);
        if (isNotEmpty) {
            break;
        }
    }
    return [SSIDInfo valueForKey:@"SSID"];
}

- (void)sendCrashLogsToServer{
    
    if ([[CTMVMReachability reachabilityForInternetConnection] currentReachabilityStatus] == ReachableViaWiFi) {
        
        NSString *filePath = [[self getApplicationDocumentsDirectory] stringByAppendingPathComponent:CRASH_LOG_NAME];
        
        NSError *error = nil;
        NSData *errorData = [NSData dataWithContentsOfFile:filePath options:kNilOptions error:&error];
        
        if (errorData) {
            
                    
            NSMutableArray *logs = [[NSKeyedUnarchiver unarchiveObjectWithData:errorData] mutableCopy];
            
            UIDevice *currentDevice = [UIDevice currentDevice];
            
            NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
            [paramDict setObject:currentDevice.model forKey:@"model"];
            [paramDict setObject:@"Apple" forKey:@"app_type"];
            [paramDict setObject:@"logCrashReport" forKey:@"RequestParameters"];
            [paramDict setObject:@"311480" forKey:@"sim_operator_code"];
            [paramDict setObject:@"true" forKey:@"support_location_services"];
            [paramDict setObject:@"EDT" forKey:@"timeZone"];
            [paramDict setObject:@"iOS" forKey:@"type"];
            [paramDict setObject:@"contenttranfer" forKey:@"app_name"];
            [paramDict setObject:(NSString *)[[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey] forKey:@"current_app_version"];
            [paramDict setObject:[[UIDevice currentDevice] name] forKey:@"device_name"];
            [paramDict setObject:@"1.0" forKey:@"static_cache_version"];
            [paramDict setObject:@"2036412409" forKey:@"deviceMdn"];
            [paramDict setObject:@"handset" forKey:@"formfactor"];
            [paramDict setObject:@"mvm_hybrid" forKey:@"application_id"];
            [paramDict setObject:@"logCrashReport" forKey:@"requestedPageType"];
            [paramDict setObject:@"ctrc" forKey:@"sourceID"];
            [paramDict setObject:@"6.0.1" forKey:@"fw_version"];
            [paramDict setObject:@"false" forKey:@"no_sim_present"];
            [paramDict setObject:currentDevice.systemVersion forKey:@"os_version"];
            [paramDict setObject:@"" forKey:@"static_cache_timestamp"];
            [paramDict setObject:@"localDB" forKey:@"upgrade_check_flag"];
            [paramDict setObject:@"311480" forKey:@"network_operator_code"];
            [paramDict setObject:@"iOS" forKey:@"os_name"];
            [paramDict setObject:@"23.0" forKey:@"apiLevel"];
            [paramDict setObject:@"Verizon Wireless" forKey:@"brand"];
            [paramDict setObject:@"4G" forKey:@"deviceMode"];
            [paramDict setObject:logs forKey:@"crashLogsList"];
            
            NSURL *url;
            
#if STORE_BUILD == 1
            
            url = [[NSURL alloc] initWithString:@"http://mobile.vzw.com/mvmrc/mvm/logCrashReport"];
            
#else
            
            url = [[NSURL alloc] initWithString:@"http://mobile-edev.vzw.com/dev03/mvmrc/mvm/logCrashReport"];
            
#endif
            
            NSError *error = nil;
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:paramDict
                                                               options:NSJSONWritingPrettyPrinted
                                                                 error:&error];
            NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            DLog(@"\n\n************************** MVM Request **************************");
            DLog(@"sendParams %@",jsonString);
            jsonString = nil;
            
            
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:TIME_OUT_TIME];
            [request setHTTPMethod:@"POST"];
            [request setValue:@"no-cache" forHTTPHeaderField:@"Cache-Control"];
            
            // Either adds the params to the body or the header.
            [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
            [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
            
            NSData *data = [NSJSONSerialization dataWithJSONObject:paramDict options:0 error:&error];
            if (data) {
                [request setHTTPBody:data];
            }
            
            NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&error];
            
            
            if (response) {
                
                NSString *urlString = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
                DebugLog(@"%@", urlString);
                
                NSDictionary *jsonObject=[NSJSONSerialization
                                          JSONObjectWithData:response
                                          options:NSJSONReadingMutableLeaves
                                          error:nil];
                DebugLog(@"jsonObject is %@",jsonObject);
                
                if ([[[jsonObject valueForKey:@"ErrInfo"] valueForKey:@"errMsg"] isEqualToString:@"Success"]) {
                    
                    DebugLog(@"upload successful");
                    
                    NSString *filePath = [[self getApplicationDocumentsDirectory] stringByAppendingPathComponent:CRASH_LOG_NAME];
                    
                    [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
                    
                }
                
            }
            
        } else {
            
            DebugLog(@"No log avialable to upload");
        }
        
        
    } else {
        
        DebugLog(@"Not connected to Internet ");
    }
    
    
}

- (void)storeLogToLocalDatabase:(NSDictionary *)logs {
    
    NSString *filePath = [[self getApplicationDocumentsDirectory] stringByAppendingPathComponent:CRASH_LOG_NAME];
    
    
    NSError *error = nil;
    NSData *errorData = [NSData dataWithContentsOfFile:filePath options:kNilOptions error:&error];
    if (errorData) {
        
        NSMutableArray *arr = [[NSKeyedUnarchiver unarchiveObjectWithData:errorData] mutableCopy];
        
        [arr addObject:logs];
        
        errorData = [NSKeyedArchiver archivedDataWithRootObject:arr];
        
    } else {
        
        NSArray *arr = [[NSArray alloc] initWithObjects:logs, nil];
        
        errorData = [NSKeyedArchiver archivedDataWithRootObject:arr];
    }
    
    [errorData writeToFile:filePath options:NSDataWritingAtomic error:&error];
}

- (NSString *)getApplicationDocumentsDirectory {
    
    NSString *basePath = [NSString appRootDocumentDirectory];
    return basePath;
}

@end
