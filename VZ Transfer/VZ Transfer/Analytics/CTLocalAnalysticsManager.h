//
//  CTLocalAnalysticsManager.h
//  contenttransfer
//
//  Created by Sun, Xin on 7/25/16.
//  Copyright © 2016 Hadapad, Prakash. All rights reserved.
//

#import <Foundation/Foundation.h>
/*!
    @brief This class is designed for handle all the logic for local analytics.
    @discussion This class will contains every logic that upload, parsing or creating the proper formatted local analytics for content transfer.
            
                This is a singlton class. Use
    @code [CTLocalAnalysticsManager sharedInstance] @endcode
                to init the object.
 */
@interface CTLocalAnalysticsManager : NSObject
/*! @brief Global parameter to indicate this analytic manager is for sender or receiver.*/
@property (nonatomic, assign) BOOL isSender;
/*!
    @brief singlton init method for CTLocalAnalysticsManager.
    @return A singlton object that represent CTLocalAnalysticsManager class.
 */
+ (instancetype)sharedInstance;
/*! @brief Mark this analytics manager is for sender side.*/
- (void)sender;
/*! @brief Mark this analytics manager is for recevier side.*/
- (void)receiver;
/*! @brief Upload the saved analytics into server and remove the uploaded one from app memory.*/
- (void)uploadLocalAnalytics;
/*!
    @brief Check network reachability for uploading the analytics.
    @discussion The way this method is using to check Internet connection is trying to pin www.google.com to see if block can get response within timeout.
 
                System default timeout is 60s, that is too long for uploading check. Right now timeout is reseted to 10s.
    @warning This way is the easiest implementation for now. But maybe can be changed for better way.
 */
- (void)reachabilityCheckToUploadAnalyticsForMDN:(NSString*)phoneNumber;
/*!
    @brief This method is designed for generate the local analytics in proper format, and store them in NSUserDefault for sending.
    @discussion The localAnalytics should follow below format:
    @code
 {
    "mode": "debug",
    "deviceId": "3873e730cb244e44abef4de366d767be",
    "pairingDeviceId": "869f361f96dc46ce934a07125d88f4d0",
    "deviceModel": "SM-G900V",
    "pairingDeviceModel": "SM-N910V",
    "deviceOsVersion": "Android SDK: 23 (6.0.1)",
    "pairingDeviceOsVersion": "Android SDK: 23 (6.0.1)",
    "deviceType": "samsung",
    "pairingDeviceType": "samsung",
    "pairingType": "phone wifi",
    "status": "869f361f96dc46ce934a07125d88f4d0 - Transfer cancelled.",
    "errorMessage": "",
    "contacts": 0,
    "photos": 22,
    "videos": 0,
    "sms": 0,
    "audio": 0,
    "callLogs": 0,
    "documents": 0,
    "calendars": 0,
    "reminders": 0,
    "wifiSettings": 0,
    "deviceSettings": 0,
    "deviceApps": 0,
    "alarms": 0,
    "wallpapers": 0,
    "voiceRecordings": 0,
    "ringtones": 0,
    "sNotes": 0,
    "transferType": "Receiver",
    "wifiAccessPoint": "NETGEAR88-5G-A",
    "dataTransferred": "91.0",
    "transferSpeed": "48 Mbps",
    "duration": "784567", //in milliseconds
    "buildVersion": "3.2.22-DEBUG",
    "description": "",
    "transferDate": "2016-09-12 03:29:29",
    "appType": "STANDALONE",
    "mdn": "7324849494",
    "locationRadioId": "d8c7c8205b40",
    "bluetoothBeaconMajorId": "1",
    "bluetoothBeaconMinorId": "5",
    "storeId": "795",
    "location": "Warren",
    "state": "NJ",
    "region": "northeast"
 }
    @endcode
 */
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
              averageSpeed:(NSString*)averageSpeed
               description:(NSString *)descriptionMsg;



/**
 @brief Checks network reachability and uploads the analytics to server if internet connection is active.
 @discussion The way this method is using to check Internet connection is trying to ping www.google.com to see if block can get response within timeout. System default timeout is 60s, that is too long for uploading check. Right now timeout is set to 10s.
 @remark Following is a sample JSON dictionary that can be posted to Analytics server
 @code
 {
 "deviceId" : "39d2118fed3a498c9175b2017ff4b240",
 "globalUUID" : "b32904c1909646b295bca95ea3dd83a5",
 "didClickImage" : 1
 }
 @endcode
 @param dict NSMutableDictionary that contains key value pairs in JSON disctionary
 */
- (void)uploadBannerAnalyticsJSONDictionary:(NSMutableDictionary *)dict;

@end
