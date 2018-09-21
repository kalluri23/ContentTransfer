//
//  CTDuplicateLists.m
//  contenttransfer
//
//  Created by Sun, Xin on 12/5/16.
//  Copyright © 2016 Verizon Wireless Inc. All rights reserved.
//
//  Dulicate list structure:
//  Key->Device Vendor ID(VID); value->Local Duplicate List(Hash table:Key->Received file name; Value: local asset ID).
//

#import "CTDuplicateLists.h"

#import "CTUserDefaults.h"

@interface CTDuplicateLists()

@property (nonatomic, strong) NSUserDefaults *userDefaults;
@property (nonatomic, strong) NSString *deviceVID;

@end

@implementation CTDuplicateLists

#define CTPhotoDuplicateListKey @"PHOTODUPLICATELIST"
#define CTVideoDuplicateListKey @"VIDEODUPLICATELIST"
#define CTReminderDuplicateListKey @"REMINDERDUPLICATELIST"
#define CTCalendarDuplicateListKey @"CALENDARDUPLICATELIST"

#pragma mark - Initializer
+ (instancetype)uniqueList {
    static dispatch_once_t token;
    static CTDuplicateLists *duplicateListUnique;
    dispatch_once(&token, ^{
        duplicateListUnique = [[self alloc] init];
        if (duplicateListUnique) {
            duplicateListUnique.userDefaults = [NSUserDefaults standardUserDefaults];
            duplicateListUnique.deviceVID = [CTUserDefaults sharedInstance].deviceVID; // read other device's device vendor ID
        }
    });
    
    return duplicateListUnique;
}

/**
 * Update the photo duplicate for specified device.
 */
- (void)updatePhotos:(NSDictionary *)localDuplicateList {
    
    if ([[CTUserDevice userDevice].phoneCombination isEqualToString:IOS_IOS]) {
        if (!_deviceVID) {
            return;
        }
        
        NSMutableDictionary *duplicatePhotoLists = [(NSDictionary *)[_userDefaults valueForKey:CTPhotoDuplicateListKey] mutableCopy];
        if (!duplicatePhotoLists) { // No sigle duplicate list for photo now.
            duplicatePhotoLists = [[NSMutableDictionary alloc] init];
        }
        
        NSMutableDictionary *duplilcatePhotosForDevice = [[duplicatePhotoLists objectForKey:_deviceVID] mutableCopy]; // Get the duplicate list for current device.
        if (!duplilcatePhotosForDevice) { // No duplicate for this certain device
            duplilcatePhotosForDevice = [[NSMutableDictionary alloc] init];
        }
        
        [duplilcatePhotosForDevice addEntriesFromDictionary:localDuplicateList];
        
        // Update list for certain device
        [duplicatePhotoLists setObject:duplilcatePhotosForDevice forKey:_deviceVID];
        
        // Update the whole list into user defaults
        [_userDefaults setObject:duplicatePhotoLists forKey:CTPhotoDuplicateListKey];
    } else {
        NSMutableDictionary *duplicateList = [(NSDictionary *)[_userDefaults valueForKey:CTPhotoDuplicateListKey] mutableCopy];
        if (!duplicateList) {
            duplicateList = [[NSMutableDictionary alloc] init];
        }
        [duplicateList addEntriesFromDictionary:localDuplicateList];
        [_userDefaults setObject:duplicateList forKey:CTPhotoDuplicateListKey];
    }
}

/**
 * Update the video duplicate for specified device.
 */
- (void)updateVideos:(NSDictionary *)localDuplicateList {
    
    if ([[CTUserDevice userDevice].phoneCombination isEqualToString:IOS_IOS]) {
        if (!_deviceVID) {
            return;
        }
        
        NSMutableDictionary *duplicateVideoLists = [(NSDictionary *)[_userDefaults valueForKey:CTVideoDuplicateListKey] mutableCopy];
        if (!duplicateVideoLists) { // No sigle duplicate list for photo now.
            duplicateVideoLists = [[NSMutableDictionary alloc] init];
        }
        
        NSMutableDictionary *duplilcateVideosForDevice = [[duplicateVideoLists objectForKey:_deviceVID] mutableCopy]; // Get the duplicate list for current device.
        if (!duplilcateVideosForDevice) { // No duplicate for this certain device
            duplilcateVideosForDevice = [[NSMutableDictionary alloc] init];
        }
        
        [duplilcateVideosForDevice addEntriesFromDictionary:localDuplicateList];
        
        // Update list for certain device
        [duplicateVideoLists setObject:duplilcateVideosForDevice forKey:_deviceVID];
        
        // Update the whole list into user defaults
        [_userDefaults setObject:duplicateVideoLists forKey:CTVideoDuplicateListKey];
    } else {
        NSMutableDictionary *duplicateList = [(NSDictionary *)[_userDefaults valueForKey:CTVideoDuplicateListKey] mutableCopy];
        if (!duplicateList) {
            duplicateList = [[NSMutableDictionary alloc] init];
        }
        [duplicateList addEntriesFromDictionary:localDuplicateList];
        [_userDefaults setObject:duplicateList forKey:CTVideoDuplicateListKey];
    }
    
}

/**
 * Fetch photo duplicate list
 */
- (NSDictionary *)photoList {
    if (!_deviceVID) {
        return nil;
    }
    NSDictionary *duplicatePhotoLists = (NSDictionary *)[_userDefaults valueForKey:CTPhotoDuplicateListKey];
    if (duplicatePhotoLists) {
        return (NSDictionary *)[duplicatePhotoLists objectForKey:_deviceVID];
    }
    
    return nil;
}

/**
 * Fetch video duplicate list
 */
- (NSDictionary *)videoList {
    if (!_deviceVID) {
        return nil;
    }
    NSDictionary *duplicateVideoLists = (NSDictionary *)[_userDefaults valueForKey:CTVideoDuplicateListKey];
    if (duplicateVideoLists) {
        return (NSDictionary *)[duplicateVideoLists objectForKey:_deviceVID];
    }
    
    return nil;
}

/**
 * Replace the whole photo list for certain device
 */
- (void)replacePhotoDuplicateList:(NSDictionary *)duplicateList {
    if (!_deviceVID) {
        return;
    }
    
    NSMutableDictionary *duplicatePhotoLists = [(NSDictionary *)[_userDefaults valueForKey:CTPhotoDuplicateListKey] mutableCopy];
    if (!duplicatePhotoLists) { // No sigle duplicate list for photo now.
        duplicatePhotoLists = [[NSMutableDictionary alloc] init];
    }
    
    // Update list for certain device
    [duplicatePhotoLists setObject:duplicateList forKey:_deviceVID];
    
    // Update the whole list into user defaults
    [_userDefaults setObject:duplicatePhotoLists forKey:CTPhotoDuplicateListKey];
}

/**
 * Replace the whole video list for certain device
 */
- (void)replaceVideoDuplicateList:(NSDictionary *)duplicateList {
    if (!_deviceVID) {
        return;
    }
    
    NSMutableDictionary *duplicateVideoLists = [(NSDictionary *)[_userDefaults valueForKey:CTVideoDuplicateListKey] mutableCopy];
    if (!duplicateVideoLists) { // No sigle duplicate list for photo now.
        duplicateVideoLists = [[NSMutableDictionary alloc] init];
    }
    
    // Update list for certain device
    [duplicateVideoLists setObject:duplicateList forKey:_deviceVID];
    
    // Update the whole list into user defaults
    [_userDefaults setObject:duplicateVideoLists forKey:CTVideoDuplicateListKey];
}

#pragma mark - Query Duplicate List Operations
- (BOOL)checkPhotoFileInDuplicateList:(NSString *)fileName localIdentifierReturn:(NSString **)localIdentifier {
    NSDictionary *photoDuplicateList = [self photoList];
    if (photoDuplicateList) { // has duplicate list
        NSString *_localIdentifier = (NSString *)[photoDuplicateList objectForKey:fileName];
        if (_localIdentifier) { // Exist
            *localIdentifier = _localIdentifier;
            return YES;
        }
    }
    
    *localIdentifier = nil;
    return NO;
}

- (BOOL)checkVideoFileInDuplicateList:(NSString *)fileName localIdentifierReturn:(NSString **)localIdentifier {
    NSDictionary *videoDuplicateList = [self videoList];
    if (videoDuplicateList) { // has duplicate list
        NSString *_localIdentifier = (NSString *)[videoDuplicateList objectForKey:fileName];
        if (_localIdentifier) { // Exist
            *localIdentifier = _localIdentifier;
            return YES;
        }
    }
    
    *localIdentifier = nil;
    return NO;
}

#pragma mark - Duplicate List Manipulation
- (void)removePhotoFileFromDuplicateList:(NSString *)fileName {
    NSMutableDictionary *photoDuplicateList = [[self photoList] mutableCopy];
    if (photoDuplicateList) {
        [photoDuplicateList removeObjectForKey:fileName];
        [self replacePhotoDuplicateList:photoDuplicateList];
    }
}

- (void)removeVideoFileFromDuplicateList:(NSString *)fileName {
    NSMutableDictionary *videoDuplicateList = [[self photoList] mutableCopy];
    if (videoDuplicateList) {
        [videoDuplicateList removeObjectForKey:fileName];
        [self replaceVideoDuplicateList:videoDuplicateList];
    }
}

/**
 * Fetch reminder duplicate list
 */
- (NSDictionary *)reminderList {
    if (!_deviceVID) {
        return nil;
    }
    NSDictionary *duplicateReminderLists = (NSDictionary *)[_userDefaults valueForKey:CTReminderDuplicateListKey];
    if (duplicateReminderLists) {
        return (NSDictionary *)[duplicateReminderLists objectForKey:_deviceVID];
    }
    
    return nil;
}

/**
 * Fetch calendar duplicate list
 */
- (NSDictionary *)calendarList {
    if (!_deviceVID) {
        return nil;
    }
    
    NSDictionary *duplicateCalendarLists = (NSDictionary *)[_userDefaults valueForKey:CTCalendarDuplicateListKey];
    if (duplicateCalendarLists) {
        return (NSDictionary *)[duplicateCalendarLists objectForKey:_deviceVID];
    }
    
    return nil;
}

/**
 * Replace the whole reminder list for certain device
 */
- (void)replaceReminderDuplicateList:(NSDictionary *)reminderDupList {
    if (!_deviceVID || reminderDupList == nil) {
        return;
    }
    
    NSMutableDictionary *duplicateReminderLists = [(NSDictionary *)[_userDefaults valueForKey:CTReminderDuplicateListKey] mutableCopy];
    if (!duplicateReminderLists) { // No sigle duplicate list for photo now.
        duplicateReminderLists = [[NSMutableDictionary alloc] init];
    }
    
    // Update list for certain device
    [duplicateReminderLists setObject:reminderDupList forKey:_deviceVID];
    
    // Update the whole list into user defaults
    [_userDefaults setObject:duplicateReminderLists forKey:CTReminderDuplicateListKey];
}

/**
 * Replace the whole calendar list for certain device
 */
- (void)replaceCalendarDuplicateList:(NSDictionary *)calendarDupList {
    if (!_deviceVID) {
        return;
    }
    
    NSMutableDictionary *duplicateReminderLists = [(NSDictionary *)[_userDefaults valueForKey:CTCalendarDuplicateListKey] mutableCopy];
    if (!duplicateReminderLists) { // No sigle duplicate list for photo now.
        duplicateReminderLists = [[NSMutableDictionary alloc] init];
    }
    
    // Update list for certain device
    [duplicateReminderLists setObject:calendarDupList forKey:_deviceVID];
    
    // Update the whole list into user defaults
    [_userDefaults setObject:duplicateReminderLists forKey:CTCalendarDuplicateListKey];
}

@end
