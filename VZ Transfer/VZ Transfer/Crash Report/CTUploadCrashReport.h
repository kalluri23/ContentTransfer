//
//  CTUploadCrashReport.h
//  VZ Transfer
//
//  Created by Hadapad, Prakash on 6/22/16.
//  Copyright © 2016 Hadapad, Prakash. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface CTUploadCrashReport : NSObject<NSURLConnectionDataDelegate>
/*!
 Send crash logs to the server. If device is currently connect to Internet.
 */
- (void)sendCrashLogsToServer;
/*!
 Store the crash log into local file system. You can find the log in CrashLog.txt in document folder inside content transfer's sandbox.
 @param logs Dictionary with detail information want to saved in file system.
 */
- (void)storeLogToLocalDatabase:(NSDictionary *)logs;

@end
