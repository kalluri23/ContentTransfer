//
//  CTVersionManager.h
//  contenttransfer
//
//  Created by Hadapad, Prakash on 6/30/16.
//  Copyright © 2016 Hadapad, Prakash. All rights reserved.
//

#import <Foundation/Foundation.h>

/*!Version check status*/
typedef NS_ENUM(NSInteger, CTVersionCheckStatus){
    /*!Version match each other.*/
    CTVersionCheckStatusMatched,
    /*!Verizon is lower.*/
    CTVersionCheckStatusLesser,
    /*!Version is higher.*/
    CTVersionCheckStatusGreater
};

/*!
 Manager class for content transfer version check. Version will be done during device pairing process. Only versions match can be paired.
 
 Content transfer will have two embeded verison, one is release verison, specified in project setting. Another one is minimum version, setup in setting file.
 
 When doing version check. Each device will compare the @b release @b verison of its own with the target @b minimum @b verison.
 */
@interface CTVersionManager : NSObject
/*!Bool value indicate that version is checked or not.*/
@property(nonatomic, assign) BOOL versionChecked;
/*!Supported version in string format.*/
@property(nonatomic,strong) NSString *supported_version;

/*!
 Identify the version for current device.
 @param str Target version string, this is minimum version received from other side.
 @return CTVersionCheckStatus represents the result.
 @see CTVersionCheckStatus
 */
- (CTVersionCheckStatus)identifyOsVersion:(NSString*)str;

@end
