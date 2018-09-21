//
//  CTFileList.h
//  contenttransfer
//
//  Created by Sun, Xin on 6/14/17.
//  Copyright © 2017 Verizon Wireless Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

/*! 
    @brief Content transfer file list object. This object contains all the params and operation related to file list.
 */
@interface CTFileList : NSObject

/*! Video package size based on device.*/
@property (nonatomic, assign) NSInteger videoPackageSize;
/*! VID for sender iOS device. Only for iOS to iOS*/
@property (nonatomic, strong) NSString *senderVID;
/*! Device count for current transfer.*/
@property (nonatomic, assign) NSInteger deviceCount;
/*! BOOL type indicate that has cloud saved photos.*/
@property (nonatomic, assign) BOOL hasCloudPhotos;
/*! BOOL type indicate that has cloud saved videos.*/
@property (nonatomic, assign) BOOL hasCloudVideos;
/*! BOOL type indicate that has contact selected or not.*/
@property (nonatomic, assign) BOOL contactSelected;
/*! BOOL type indicate that has photo selected or not.*/
@property (nonatomic, assign) BOOL photoSelected;
/*! BOOL type indicate that has video selected or not.*/
@property (nonatomic, assign) BOOL videoSelected;
/*! BOOL type indicate that has calendar selected or not.*/
@property (nonatomic, assign) BOOL calendarSelected;
/*! BOOL type indicate that has reminder selected or not.*/
@property (nonatomic, assign) BOOL reminderSelected;
/*! BOOL type indicate that has app list selected or not.*/
@property (nonatomic, assign) BOOL appListSelected;
/*! All the possible album received from sender.*/
@property (nonatomic, strong) NSMutableSet *photoAlbumList;

/*! Photo dictionary.*/
@property (nonatomic, strong) NSMutableDictionary *photoFileDic;
/*! Photo log array.*/
@property (nonatomic, strong) NSMutableArray      *photoFileLog;
/*! Video dictionary.*/
@property (nonatomic, strong) NSMutableDictionary *videoFileDic;
/*! Video log array.*/
@property (nonatomic, strong) NSMutableArray      *videoFileLog;
/*! Calendar file list.*/
@property (nonatomic, strong) NSArray             *calendarFilelist;
/*! App list.*/
@property (nonatomic, strong) NSMutableArray      *appFileList;

/*! Number of contact records.*/
@property (nonatomic, assign) NSInteger numberOfContacts;
/*! Number of photo files.*/
@property (nonatomic, assign) NSInteger numberOfPhotos;
/*! Number of video files.*/
@property (nonatomic, assign) NSInteger numberOfVideos;
/*! Number of reminder list.*/
@property (nonatomic, assign) NSInteger numberOfReminder;
/*! Number of calendar list.*/
@property (nonatomic, assign) NSInteger numberOfCalendar;
/*! Number of audio files.*/
@property (nonatomic, assign) NSInteger numberOfAudios;
/*! Number of apps.*/
@property (nonatomic, assign) NSInteger numberOfApps;

/*! Number of files need to be transferred.*/
@property (nonatomic, assign) NSInteger totalFileCount;

#pragma mark - Initializer
/*!
    @brief Initializer for content transfer file list object.
    @discussion This object should be created on the select what page and maintained throughout the transfer.
    @return CTFileList object.
 */
- (instancetype)initFileList;
/*!
    @brief Initializer for content transfer file list object with input data.
    @discussion This method will read data from data and translate it into proper file list that app can use for transfer.
    @param data File list data received.
    @return CTFileList object.
 */
- (instancetype)initFileListWithData:(NSData *)data;

#pragma mark - Item Operations
/*!
    @brief Create select item list for file list with default value.
    @discussion This list will contain all the data type supported by trasnfer, no matter you selected it or not. Each of the type will have "status", "totalCount" and "totalSize" information.
 
                The list is a global property.
    @param itemType String value reprensents the type of data.
    @param countOfData integer value represents the count of the files.
    @param size long long value represents the total size of the files.
 */
- (void)initItem:(NSString*)itemType withCount:(NSInteger)countOfData withSize:(long long)size;
/*!
    @brief Set status for picked data item.
    @param itemType selected item type
 */
- (void)selectItem:(NSString *)itemType;
/*!
    @brief Reset status for picked data item.
    @param itemType selected item type
 */
- (void)deselectItem:(NSString*)itemType;
/*!
    @brief Reset status for all items in item list.
    @see deselectItem
 */
- (void)resetAllItemList;
/*!
    @brief Get the file information for specific data type at specific index position.
    @dicussion This method simply read data using given key and idx. There is no idx over bound check. Given index should not beyond the maximum index of the array, otherwise system exception will be thrown.
    @warning Only support photo/video/calendar/audio type for this method. No file list needed for contacts and reminders. So should never call this method using those types.
    @param type NSString respresents the data type.
    @param indx NSUInteger indicate the position of the file list.
    @return NSDictionary including all the information needed for specific file. Or nil if certain file doesn't exist.
 */
- (NSDictionary *)getFileInformationForType:(NSString *)type andIndex:(NSUInteger)idx;

#pragma mark - File List Operations
/*!
    @brief Create the metadata for transfer. 
    @discussion Metadata contains item list and file list for each of the selected item. The complete file list will be stored in object parameter.
    
                Also this method will calculate the total size contained in file list and store it in local param.
    @param selectedRows Array of selected rows on select what page.
 */
- (void)creatCompleteFileList:(NSArray *)selectedRows;
/*!
    @brief Create file list data to send to receiver side.
    @return NSData object represents all the file list. Data with length 0 will be returned if something wrong with the process.
 */
- (NSData *)createFileListData;

#pragma mark - Parameter Access
/*!
    @brief Return the complete list of metadata.
    @return NSDicitonary contains the complete file list.
 */
- (NSDictionary *)listObject;
/*!
    @brief Get total size in file list.
    @return Long long value represents the size.
 */
- (long long)totalDataSize;
/*!
    @briefs Get the select item list section from complete file list.
    @return NSDictionary represents the select item list.
 */
- (NSDictionary *)selectItemList;

@end
