//
//  CTDuplicateLists.h
//  contenttransfer
//
//  Created by Sun, Xin on 12/5/16.
//  Copyright © 2016 Verizon Wireless Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

/*!
    @brief This is duplicate list object for duplicate logic. This is a singlton object contains all the operations related to duplicate list.
 */
@interface CTDuplicateLists : NSObject
/*!
    @brief Singlton initializer for CTDuplicateLists object.
    @return An object that represents the CTDuplicateLists object.
 */
+ (instancetype)uniqueList;
/*!
 Duplicate list for reminders.
 @return Dictionary represents the list.
 */
- (NSDictionary *)reminderList;
/*!
 Replace the duplicate list for reminder.
 @param reminderDupList New dupliate list for reminder that want to replace.
 */
- (void)replaceReminderDuplicateList:(NSDictionary *)reminderDupList;
/*!
 Duplicate list for calendars.
 @return Dictionary represents the list.
 */
- (NSDictionary *)calendarList;
/*!
 Replace the duplicate list for calendars.
 @param calendarDupList New dupliate list for calendar that want to replace.
 */
- (void)replaceCalendarDuplicateList:(NSDictionary *)calendarDupList;
/*!
 Replace the duplicate list for photos.
 @param localDuplicateList New dupliate list for photo that want to replace.
 */
- (void)updatePhotos:(NSDictionary *)localDuplicateList;
/*!
 Replace the duplicate list for videos.
 @param localDuplicateList New dupliate list for videos that want to replace.
 */
- (void)updateVideos:(NSDictionary *)localDuplicateList;
/*!
    @brief Check the photo file in duplicate list. 
    @discussion If certain file name exist in duplicate list, then method return YES, and localIdentifier indicate that file locally will be returned in localIdentifier parameter.
 
                Otherwise method will return NO, localIdentifier will be nil.
    @param fileName NSString value represents the file name need to be checked.
    @param localIdentifier NSString pointer that point to the NSString value represents the saving ID for the file if it is duplicate file. It will be nil if it's a new file.
    @return BOOL value indicate this file is duplicate file or not.
 */
- (BOOL)checkPhotoFileInDuplicateList:(NSString *)fileName localIdentifierReturn:(NSString **)localIdentifier;
/*!
    @brief Check the video file in duplicate list.
    @discussion If certain file name exist in duplicate list, then method return YES, and localIdentifier indicate that file locally will be returned in localIdentifier parameter.
 
                Otherwise method will return NO, localIdentifier will be nil.
    @param fileName NSString value represents the file name need to be checked.
    @param localIdentifier NSString pointer that point to the NSString value represents the saving ID for the file if it is duplicate file. It will be nil if it's a new file.
    @return BOOL value indicate this file is duplicate file or not.
 */
- (BOOL)checkVideoFileInDuplicateList:(NSString *)fileName localIdentifierReturn:(NSString **)localIdentifier;

/*!
    @brief Remove certain file from device photo list.
    @param fileName NSString value represents the name of the file.
 */
- (void)removePhotoFileFromDuplicateList:(NSString *)fileName;
/*!
    @brief Remove certain file from device video list.
    @param fileName NSString value represents the name of the file.
 */
- (void)removeVideoFileFromDuplicateList:(NSString *)fileName;

@end
