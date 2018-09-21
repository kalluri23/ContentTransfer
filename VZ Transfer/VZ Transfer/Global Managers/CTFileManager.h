//
//  CTFileManager.h
//  contenttransfer
//
//  Created by Guntupalli, Neelima on 8/29/16.
//  Copyright © 2016 Verizon. All rights reserved.
//
//  @header CTFileManager.h
#import <Foundation/Foundation.h>

#define DIRECTORY_PATH_REMINDERS @"Reminders/RemindersFile.txt"
#define DIRECTORY_PATH_CONTACTS @"Contacts/ContactsFile.vcf"
#define DIRECTORY_PATH_PHOTOS @"VZPhotoLogfile.txt"
#define DIRECTORY_PATH_VIDEOS @"VZVideoLogfile.txt"
#define DIRECTORY_PATH_CALENDARS @"CTCalendarLogFile.txt"
#define DIRECTORY_PATH_AUDIOS @"VZAudioLogFile.txt"

/*!
 * @brief This is the manager class for file operation
 */
@interface CTFileManager : NSObject

+ (void)createFileWithName:(NSString*)fileName withContents:(NSData*)dataContent;
/*!
 * @brief Create file with given file name with given data. Folders in file's directory path will be created also.
 * @note If file at given path already exists, method will try to remove the old file first.
 * @param directoryName NSString value represents the Path of the file.
 * @param fileName NSString value represents the name of the file.
 * @param dataContent NSData reprsents the content of the file.
 * @param block Completion block call for saving process. filePath is the full path of target file; error contains the error information if anything wrong happened. Error will be nil if it's success.
 */
+ (void)createDirectory:(NSString*)directoryName withFileName:(NSString*)fileName withContents:(NSData*)dataContent
        completionBlock:(void(^)(NSString *filePath, NSError *error))block;
/*!
    @brief get the data from specific path.
    @discussion The path that this method trying to find should under the root of app's document folder.
    @param filePath NSString value represents the file place.
    @return NSData for file contents.
 */
+ (NSData*)dataFromFile:(NSString*)filePath;
/*!
    @brief Get the root document path for current app.
    @return Root path in NSString.
 */
+ (NSString*)documentsDirectoryBasePath;
/*!
    @brief Try to write data into the file saved in specific path.
    @note If the file already exist in directory, method will try to @b remove the old one and create a new one to replace it.
 */
+ (void)writefileWithPath:(NSString *)path andData:(NSData *)data;

@end
