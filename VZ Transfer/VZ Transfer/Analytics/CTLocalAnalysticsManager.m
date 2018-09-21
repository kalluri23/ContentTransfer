//
//  CTLocalAnalysticsManager.m
//  contenttransfer
//
//  Created by Sun, Xin on 7/25/16.
//  Copyright © 2016 Hadapad, Prakash. All rights reserved.
//

#import "CTLocalAnalysticsManager.h"
//#import "VZDeviceMarco.h"
#import "CTDeviceMarco.h"
#import "CTContentTransferSetting.h"
#import "NSString+CTRootDocument.h"
#import "CTUploadCrashReport.h"
#import "NSString+CTHelper.h"


// Shared instance for boujour manager
static CTLocalAnalysticsManager *managerSharedInstance = nil;

@interface CTLocalAnalysticsManager ()

@property(nonatomic,strong) NSString *phoneNumber;

@end

@implementation CTLocalAnalysticsManager


+ (instancetype)sharedInstance {
    
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        managerSharedInstance = [[CTLocalAnalysticsManager alloc] init];
    });
    
    return managerSharedInstance;
}

- (void)reachabilityCheckToUploadAnalyticsForMDN:(NSString*)phoneNumber {
    
    //Check if there are any user transactions
    NSUserDefaults *userdefault = [NSUserDefaults standardUserDefaults];
    
    NSMutableArray* arr = [[userdefault valueForKey:@"LOCALANALYTICS"] mutableCopy];
    if (!arr.count) {
        return;    //If there are no transactions
    }

    // Set session configuration with 10s timeout
    NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    sessionConfig.timeoutIntervalForRequest  = 10;
    sessionConfig.timeoutIntervalForResource = 10;
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfig];
    [[session dataTaskWithURL:[NSURL URLWithString:@"https://www.google.com"] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
      {
          if (!error) {
              //Your host is reachable
              if (STANDALONE == 1) {
                  self.phoneNumber = [CTUserDevice userDevice].userMDN;
              } else {
                  self.phoneNumber = phoneNumber;
              }
              __block UIBackgroundTaskIdentifier bgTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
                  [[UIApplication sharedApplication] endBackgroundTask:bgTask];
                  
                  bgTask = UIBackgroundTaskInvalid;
              }];
              
              dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                  
                  [self uploadLocalAnalytics];
                  [[UIApplication sharedApplication] endBackgroundTask:bgTask];
                  bgTask = UIBackgroundTaskInvalid;
                  
#if CRASH_REPORT == 1
                  // Only upload crash report when using Wi-Fi
                  CTUploadCrashReport *serverUpload = [[CTUploadCrashReport alloc] init];
                  [serverUpload sendCrashLogsToServer];
#endif
              });
          }
      }] resume];
}

- (void)localAnalyticsData:(NSString *)status
       andNumberOfContacts:(NSInteger)numberOfContacts
         andNumberOfPhotos:(NSInteger)numberOfPhotos
         andNumberOfVideos:(NSInteger)numberOfVideos
      andNumberOfCalendars:(NSInteger)numberOfCalendars
      andNumberOfReminders:(NSInteger)numberOfReminders
           andNumberOfApps:(NSInteger)numberOfApps
         andNumberOfAudios:(NSInteger)numberOfAudios
           totalDownloaded:(NSString *)totalDownloaded
          totalTimeElapsed:(NSString *)totalTimeElapsed
              averageSpeed:(NSString*) averageSpeed
               description:(NSString *)descriptionMsg
{
#if LOCAL_ANALYTICS == 1
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    NSMutableDictionary *localDict = [[NSMutableDictionary alloc] init];
    
    CTDeviceMarco *deviceMacro = [[CTDeviceMarco alloc] init];
    NSString *modelCode = [deviceMacro getDeviceModel];
    NSString *model = [deviceMacro.models objectForKey:modelCode];
    if (model.length == 0) {
        model = [modelCode editDeviceModel];
        //model = modelCode;
    }

    [localDict setValue:[NSString stringWithFormat:@"%@",[CTUserDefaults sharedInstance].launchTimeStamp] forKey:@"transferStart"]; //in milliseconds

    [localDict setValue:[CTUserDevice userDevice].deviceUDID forKey:@"deviceId"];
    [localDict setValue:[CTUserDevice userDevice].globalUDID forKey:@"globalUUID"];

    [localDict setValue:model forKey:@"deviceModel"];

    [localDict setValue:[[UIDevice currentDevice] systemVersion] forKey:@"deviceOsVersion"];

    [localDict setValue:@"iOS" forKey:@"deviceType"];
    
    if ([status isEqualToString:@"Transfer Interrupted"]) {
        if ((numberOfContacts == 0) && (numberOfPhotos == 0) && (numberOfVideos == 0) && (numberOfCalendars == 0) && (numberOfReminders == 0)) {
            status = @"Transfer Cancelled";
        }
    }
     
    [localDict setValue:status forKey:@"status"];
    [localDict setValue:averageSpeed forKey:@"transferSpeed"];
    [localDict setValue:descriptionMsg forKey:@"description"];
    [localDict setValue:[NSString stringWithFormat:@"%ld",(long)numberOfContacts] forKey:@"contacts"];
    [localDict setValue:[NSString stringWithFormat:@"%ld",(long)numberOfReminders] forKey:@"reminders"];

    [localDict setValue:[NSString stringWithFormat:@"%ld",(long)numberOfPhotos] forKey:@"photos"];
    [localDict setValue:[NSString stringWithFormat:@"%ld",(long)numberOfVideos] forKey:@"videos"];
    [localDict setValue:@"0" forKey:@"sms"];
    [localDict setValue:[NSString stringWithFormat:@"%ld",(long)numberOfCalendars] forKey:@"calendars"];
    [localDict setValue:@"0" forKey:@"callLogs"];
    [localDict setValue:[NSString stringWithFormat:@"%ld", (long)numberOfAudios] forKey:@"audio"];
    [localDict setValue:@"0" forKey:@"documents"];
    
//    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
//    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
//    NSString *dateString = [dateFormatter stringFromDate:[NSDate date]];
    NSTimeInterval millisecondDate = [[NSDate date] timeIntervalSince1970] * 1000;
    [localDict setValue:[NSString stringWithFormat:@"%.0f", millisecondDate] forKey:@"transferDate"];

    
    if ([[CTUserDevice userDevice].deviceType isEqualToString:OLD_DEVICE]) {
        [localDict setValue:@"Sender" forKey:@"transferType"];
    } else {
        [localDict setValue:@"Receiver" forKey:@"transferType"];
    }
    
    if (totalDownloaded.length > 0) {
        NSString *newStr = totalDownloaded;
        if ([totalDownloaded containsString:@"MB"]) {
            newStr = [totalDownloaded stringByReplacingOccurrencesOfString:@"MB" withString:@""]; // remove MB
        }
        
        if ([totalDownloaded containsString:@" "]) {
            newStr = [newStr stringByReplacingOccurrencesOfString:@" " withString:@""]; // remove space
        }
        
        if ([newStr isEqualToString:@"0.0"]) {
            [localDict setValue:@"0" forKey:@"dataTransferred"];
        } else {
            [localDict setValue:newStr forKey:@"dataTransferred"];
        }
    } else {
        [localDict setValue:@"0" forKey:@"dataTransferred"];
    }
    
    //[localDict setValue:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"] forKey:@"buildVersion"];
    [localDict setValue:BUILD_VERSION forKey:@"buildVersion"];

    if (totalTimeElapsed.length > 0) {
        [localDict setValue:totalTimeElapsed forKey:@"duration"];
    } else {
        [localDict setValue:@"0" forKey:@"duration"];
    }

    
#if STORE_BUILD == 1
    [localDict setValue:@"RELEASE" forKey:@"mode"];
#else
    [localDict setValue:@"QA" forKey:@"mode"];
#endif
#if STANDALONE == 1
    [localDict setValue:@"STANDALONE" forKey:@"appType"];
#else
    [localDict setValue:@"MVM" forKey:@"appType"];
#endif
    
    [localDict setValue:[CTUserDevice userDevice].deviceUDID forKey:@"deviceId"];
    
    [localDict setValue:[userDefaults valueForKey:USER_DEFAULTS_PAIRING_DEVICE_ID] forKey:@"pairingDeviceId"];
    
//    [localDict setValue:[dict valueForKey:@"deviceModel"] forKey:@"deviceModel"];
    NSString *pairingModel = [userDefaults valueForKey:USER_DEFAULTS_PAIRING_MODEL];
    NSString *editedModel = [pairingModel editDeviceModel];
    [localDict setValue:editedModel forKey:@"pairingDeviceModel"];
    
//    [localDict setValue:[dict valueForKey:@"deviceOsVersion"] forKey:@"deviceOsVersion"];
//    [localDict setValue:@"iOS" forKey:@"deviceType"];
    [localDict setValue:[userDefaults valueForKey:USER_DEFAULTS_PAIRING_DEVICE_TYPE] forKey:@"pairingDeviceType"];
    
    //[localDict setValue:[userDefaults valueForKey:USER_DEFAULTS_PAIRING_TYPE] forKey:@"pairingType"];
    
    if ([[CTUserDevice userDevice].pairingType isEqualToString:kNotDecided]) { // If pairing not happen in any case
        [localDict setValue:kNotDecided forKey:@"pairingType"];
    } else if ([[CTUserDevice userDevice].pairingType isEqualToString:kP2P]){
        if([[CTUserDevice userDevice].softAccessPoint isEqualToString:@"TRUE"]){
            [localDict setValue:@"hotspot wifi" forKey:@"pairingType"];
        } else {
            [localDict setValue:@"router" forKey:@"pairingType"];
        }
    } else {
        [localDict setValue:@"bonjour" forKey:@"pairingType"];
    }
    
    [localDict setValue:[userDefaults valueForKey:USER_DEFAULTS_PAIRING_OS_VERSION] forKey:@"pairingDeviceOsVersion"];
    
    [localDict setValue:@0 forKey:@"wifiSettings"];
    [localDict setValue:@0 forKey:@"deviceSettings"];
    [localDict setValue:[NSString stringWithFormat:@"%ld", (long)numberOfApps] forKey:@"deviceApps"];
    [localDict setValue:@0 forKey:@"wallpapers"];
    [localDict setValue:@0 forKey:@"alarms"];
    [localDict setValue:@0 forKey:@"voiceRecordings"];
    [localDict setValue:@0 forKey:@"ringtones"];
    [localDict setValue:@0 forKey:@"sNotes"];
//    [localDict setValue:[dict valueForKey:@"description"] forKey:@"description"];
    
    // beacon information
    [localDict setValue:[CTUserDefaults sharedInstance].beaconMajor forKey:@"bluetoothBeaconMajorId"];
    [localDict setValue:[CTUserDefaults sharedInstance].beaconMinor forKey:@"bluetoothBeaconMinorId"];
    [localDict setValue:[CTUserDefaults sharedInstance].beaconUUID forKey:@"locationRadioId"];
    
    // Reset beacon
    [CTUserDefaults sharedInstance].beaconUUID = @"";
    [CTUserDefaults sharedInstance].beaconMinor = @"";
    [CTUserDefaults sharedInstance].beaconMajor = @"";
    
    [localDict setValue:@"" forKey:@"storeId"];
    [localDict setValue:@"" forKey:@"location"];
    [localDict setValue:@"" forKey:@"state"];
    [localDict setValue:@"" forKey:@"region"];
    
//    if (self.phoneNumber) {
//        [localDict setValue:self.phoneNumber forKey:@"mdn"];
//    } else {
//        [localDict setValue:@"" forKey:@"mdn"];
//    }
    
//    [localDict setValue:[dict valueForKey:@"transferDate"] forKey:@"transferDate"];
    //[localDict setValue:@"1681632" forKey:@"transferDate"];
    
    //[localDict setValue:@"" forKey:@"createdDate"];// Android not sending it, do we need it ?
    [localDict setValue:@"" forKey:@"errorMessage"];
    
    if ([CTUserDevice userDevice].connectedNetworkName) {
        [localDict setValue:[NSString stringWithFormat:@"%@",[CTUserDevice userDevice].connectedNetworkName] forKey:@"wifiAccessPoint"];
    } else {
        [localDict setValue:@"" forKey:@"wifiAccessPoint"];
    }
    
//    [localDict setValue:[dict valueForKey:@"transferSpeed"] forKey:@"transferSpeed"];
//    [localDict setValue:[dict valueForKey:@"transferType"] forKey:@"transferType"];
//    [localDict setValue:[dict valueForKey:@"buildVersion"] forKey:@"buildVersion"];
    
//    [allTransactionsArray addObject:localDict];
    
    // Scan type
    [localDict setValue:[CTUserDefaults sharedInstance].scanType forKey:@"scanType"];
    
    // Identify that this transfer is one to many or one to one. If it's one to many, how many devices connected in group.
    [localDict setValue:[NSString stringWithFormat:@"%ld", (long)[CTUserDevice userDevice].deviceCount] forKey:@"deviceCount"];

    NSMutableArray *arr = [[userDefaults valueForKey:@"LOCALANALYTICS"] mutableCopy];
    if (arr) {
        [arr addObject:localDict];
    } else {
        arr = [[NSMutableArray alloc] initWithObjects:localDict, nil];
    }
    
    [userDefaults setValue:arr forKey:@"LOCALANALYTICS"];
    [userDefaults synchronize];
    
#endif
    
}

- (void)sender
{
    self.isSender = YES;
}

- (void)receiver
{
    self.isSender = NO;
}

- (void)uploadLocalAnalytics {
#if LOCAL_ANALYTICS == 1
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSArray *allTransactionsArray = [userDefaults valueForKey:@"LOCALANALYTICS"];
    
    NSString *filename = [[NSString appRootDocumentDirectory] stringByAppendingPathComponent:@"app_analytics.txt"];
    
    NSMutableData *jsonData = [NSMutableData new];
    if ([allTransactionsArray count]) {
        
        for (NSDictionary *localDict in allTransactionsArray) {
            @autoreleasepool {
                // Add the phone number
                NSMutableDictionary *mutableLocalDict = [localDict mutableCopy];
                if (self.phoneNumber.length > 0) {
                    [mutableLocalDict setValue:self.phoneNumber forKey:@"mdn"];
                } else {
                    [mutableLocalDict setValue:@"" forKey:@"mdn"];
                }
                
                NSError *error = nil;
                NSData *localjsonData = [NSJSONSerialization dataWithJSONObject:mutableLocalDict options:NSJSONWritingPrettyPrinted error:&error];
                
                [jsonData appendData:localjsonData];
                NSString *newLine = @"\r\n";
                NSData *newLineData = [newLine dataUsingEncoding:NSUTF8StringEncoding];
                [jsonData appendData:newLineData];
            }
        }
        
        // Write data into disk
        [jsonData writeToFile:filename atomically:YES];
        
#if STORE_BUILD == 1
        
#warning ANALYTICS:PROD URL PENDING FOR ANALYTICS
        NSString *urlString = ANALYTICS_PROD_URL;
#else
        NSString *urlString = ANALYTICS_DEV_URL;
#endif
        NSMutableURLRequest *request= [[NSMutableURLRequest alloc] init];
        [request setURL:[NSURL URLWithString:urlString]];
        [request setHTTPMethod:@"POST"];
        NSString *boundary = @"-----VZTXFR";
        NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
        [request addValue:contentType forHTTPHeaderField: @"Content-Type"];
        [request setValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary] forHTTPHeaderField:@"enctype"];
        NSMutableData *postbody = [NSMutableData data];
        [postbody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [postbody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"file\";filename=\"%@\"\r\n", filename] dataUsingEncoding:NSUTF8StringEncoding]];
        [postbody appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [postbody appendData:[NSData dataWithData:jsonData]];
        [postbody appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [request setHTTPBody:postbody];
        
        
        DebugLog(@" ---- Sent parameters -n %@ \n------",[[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding]);
        
        NSURLResponse *response = nil;
        NSError *error = nil;
        
        NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        NSString *someStr = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
        DebugLog(@"%@", someStr);
        
        if (error == nil && [self parseServiceResponse:someStr]) {
            [[NSFileManager defaultManager] removeItemAtPath:filename error:&error];
            [userDefaults removeObjectForKey:@"LOCALANALYTICS"];
            NSString *bannerClickfilePath = [[NSString appRootDocumentDirectory] stringByAppendingPathComponent:@"banner_click_analytics.txt"];
            NSFileManager *fileManager = [NSFileManager defaultManager];
            if ([fileManager fileExistsAtPath:bannerClickfilePath]){
                [self postBannerAnalyticsToServerWithFileAtPath:bannerClickfilePath];
            }
        }
    }
    
#endif
}

/*! 
    @brief Check the service response is sucess or failure.
    @discussion Analytics server side will always return data with "File Uploaded" for sucessful case.
    @param response Response from server side in string format.
    @return BOOL value indicate the result of analytics upload.
 */
- (BOOL)parseServiceResponse:(NSString *)response {
    if ([response rangeOfString:@"File Uploaded"].location != NSNotFound) {
        DebugLog(@"Successfully uploaded!");
        return YES;
    }

    return NO;
}

/*!
    @brief Creates analytics text file containing JSON dictionary and uploads to server if there is active internet connection
    @discussion parses analytics JSON dictionaryand saves content to banner_click_analytics.txt file
    @param JSON dictionary conataining analytics for cloud banner click
 */
- (void) uploadBannerAnalyticsJSONDictionary:(NSDictionary *)dict {
    // Set session configuration with 10s timeout to check internet connectivity
    NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    sessionConfig.timeoutIntervalForRequest  = 10;
    sessionConfig.timeoutIntervalForResource = 10;
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfig];
    [[session dataTaskWithURL:[NSURL URLWithString:@"https://www.google.com"] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
      {
          NSString *filename = [[NSString appRootDocumentDirectory] stringByAppendingPathComponent:@"banner_click_analytics.txt"];
          NSMutableData *jsonData = [NSMutableData new];
          @autoreleasepool {
              NSError *error = nil;
              NSData *localjsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
              [jsonData appendData:localjsonData];
          }
          // Write JSON data to analytics file that was created
          [jsonData writeToFile:filename atomically:YES];
          if (!error) {
              // Your host is reachable
              dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                  // Post banner analytics data from text file to server
                  [self postBannerAnalyticsToServerWithFileAtPath:filename];
              });
          }
      }] resume];
}

/*!
    @brief Sends the banner_click_analytics.txt file to analytics server
    @discussion Prepares header and body to post banner click analytics to server
    @param banner_click_analytics.txt file path
 */
- (void) postBannerAnalyticsToServerWithFileAtPath:(NSString *) path {
#if STORE_BUILD == 1
    
#warning ANALYTICS:PROD URL PENDING FOR ANALYTICS
    NSString *urlString = ANALYTICS_PROD_URL;
#else
    NSString *urlString = ANALYTICS_DEV_URL;
#endif
    NSMutableData *jsonData = [NSMutableData new];
    @autoreleasepool {
        NSData* data = [NSData dataWithContentsOfFile:path];
        [jsonData appendData:data];
        NSString *newLine = @"\r\n";
        NSData *newLineData = [newLine dataUsingEncoding:NSUTF8StringEncoding];
        [jsonData appendData:newLineData];
    }
    NSMutableURLRequest *request= [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:urlString]];
    [request setHTTPMethod:@"POST"];
    NSString *boundary = @"------TCCLK";
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
    [request addValue:contentType forHTTPHeaderField: @"Content-Type"];
    [request setValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary] forHTTPHeaderField:@"enctype"];
    NSMutableData *postbody = [NSMutableData data];
    [postbody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [postbody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"file\";filename=\"%@\"\r\n", path] dataUsingEncoding:NSUTF8StringEncoding]];
    [postbody appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [postbody appendData:[NSData dataWithData:jsonData]];
    [postbody appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [request setHTTPBody:postbody];
    
    
    DebugLog(@" ---- Sent parameters -n %@ \n------",[[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding]);
    
    NSURLResponse *response = nil;
    NSError *error = nil;
    
    NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    NSString *someStr = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
    DebugLog(@"%@", someStr);
    
    if (error == nil && [self parseServiceResponse:someStr]) {
        [[NSFileManager defaultManager] removeItemAtPath:path error:&error];
    }
}

@end
