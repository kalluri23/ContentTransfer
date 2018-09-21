//
//  CTUserDefaults.h
//  contenttransfer
//
//  Created by Development on 8/11/16.
//  Copyright © 2016 Verizon. All rights reserved.
//

#import <Foundation/Foundation.h>

/*!
    @brief NSUserDefault manager class for content transfer. This is a singlton class.
    @see +(instancetype)sharedInstance
 */
@interface CTUserDefaults : NSObject
/*! Content transfer showed Eula page.*/
@property (nonatomic, assign, getter=isContentTransferEulaAgreement) BOOL contentTransferEulaAgreement;
/*! Photo duplicate list.*/
@property (nonatomic, strong) NSMutableArray *photoDuplicateList;
/*! Video duplicate list.*/
@property (nonatomic, strong) NSMutableArray *videoDuplicateList;
/*! Duplicate list for vcard.*/
@property (nonatomic, assign, getter=isVCardDuplicateList) BOOL vCardDuplicateList;
/*! Duplicate list for calendar.*/
@property (nonatomic, assign, getter=isCalenderDuplicateList) BOOL calenderDuplicateList;
/*! Total file count received.*/
@property (nonatomic, strong) NSString *totalFilesReceived;
/*! Photo filtered file list.*/
@property (nonatomic, strong) NSMutableArray *photoFilteredFileList;
/*! Video filtered file list.*/
@property (nonatomic, strong) NSMutableArray *videoFilteredFileList;
/*! Item list selected.*/
@property (nonatomic, strong) NSMutableDictionary *itemList;
/*! Total file transfered.*/
@property (nonatomic, strong) NSString *totalFilesTransferred;
/*! Reminder duplicate list.*/
@property (nonatomic, assign, getter=isReminderDuplicateList) BOOL reminderDuplicateList;
/*! Album list for videos.*/
@property (nonatomic, strong) NSMutableArray *videoAlbumList;
/*! Ablum list for photos.*/
@property (nonatomic, strong) NSMutableArray *photoAlbumList;
/*! Start time of transfer.*/
@property (nonatomic, strong) NSDate *startTime;
/*! End time of transfer.*/
@property (nonatomic, strong) NSDate *endTime;
/*! Total size of downloaded data.*/
@property (nonatomic, strong) NSString *totalDownloadedData;
/*! Total number of contacts.*/
@property (nonatomic, strong) NSString *totalNumberOfContacts;
/*! Total size of contact vcf file.*/
@property (nonatomic, strong) NSString *contactTotalSize;
/*! Total size of reminder size.*/
@property (nonatomic, strong) NSString *reminderLogSize;
/*! Calendar file list.*/
@property (nonatomic, strong) NSMutableArray *calFileList;
/*! Content transfer showed battery alert.*/
@property (nonatomic, strong) NSNumber *batteryAlertSent;
/*! Contacts imported or not.*/
@property (nonatomic, strong) NSString *contactsImported;
/*! Local analytics detail.*/
@property (nonatomic, strong) NSMutableArray *localAnalytics;
/*! File list for videos.*/
@property (nonatomic, strong) NSMutableArray *videoFileList;
/*! File list for photos.*/
@property (nonatomic, strong) NSMutableArray *photoFileList;
/*! Information for pairing devices.*/
@property (nonatomic, strong) NSDictionary *pairingInfo;
/*! List for calendar files.*/
@property (nonatomic, strong) NSDictionary *calendarList;
/*! Total size of data to be transferred.*/
@property (nonatomic, strong) NSNumber *sizeOfAllDataToTransfer;// long number
/*! Temp file folder path for photos.*/
@property (nonatomic, strong) NSString *photoTempFolder;
/*! Temp file folder path for live photo video components.*/
@property (nonatomic, strong) NSString *livePhotoTempFolder;
/*! Temp file folder path for videos.*/
@property (nonatomic, strong) NSString *videoTempFolder;
/*! Photo file list.*/
@property (nonatomic, strong) NSArray *tempPhotoLists;
/*! Video file list.*/
@property (nonatomic, strong) NSArray *tempVideoLists;
/*! Array of received status for the trasnfer.*/
@property (nonatomic, strong) NSArray *receiveFlags;
/*! Number of photo file received.*/
@property (nonatomic, assign) NSInteger numberOfPhotosReceived;
/*! Number of video file received.*/
@property (nonatomic, assign) NSInteger numberOfVideosReceived;
/*! Content transfer app review status.*/
@property (nonatomic, assign) NSInteger itunesReviewStatus;
/*! Beacon UUID*/
@property (nonatomic, strong) NSString *beaconUUID;
/*! Beacon major ID indicate the store ID.*/
@property (nonatomic, strong) NSString *beaconMajor;
/*! Beacon minor iD indicate the store floor.*/
@property (nonatomic, strong) NSString *beaconMinor;
/*! BOOL value indicate it's cancelled or not.*/
@property (nonatomic, assign) BOOL isCancel;
/*! BOOL value indicate device has contact permission error or not.*/
@property (nonatomic, assign) BOOL hasVcardPermissionError;
/*! BOOL value indicate device has photo permission error or not.*/
@property (nonatomic, assign) BOOL hasPhotoPermissionError;
/*! BOOL value indicate device has calendar permission error or not.*/
@property (nonatomic, assign) BOOL hasCalendarPermissionError;
/*! BOOL value indicate device has reminder permission error or not.*/
@property (nonatomic, assign) BOOL hasReminderPermissionError;
/*! BOOL value indicate device has audio permission error or not.*/
@property (nonatomic, assign) BOOL hasAudioPermissionError;
/*! BOOL value indicate device has camera permission error or not.*/
@property (nonatomic, assign) BOOL hasCameraPermissionError;
/*! Content transfer showed MDN alert.*/
@property (nonatomic, assign) BOOL hasShownMDNAlert;
/*! Transfer started or not.*/
@property (nonatomic, assign) BOOL transferStarted;
/*! Timestamp when user launching content transfer.*/
@property (nonatomic, strong) NSString *launchTimeStamp;
/*! Current device ID.*/
@property (nonatomic, strong) NSString *deviceVID;
/*! Type of scan user choose to pair the device.*/
@property (nonatomic, strong) NSString *scanType;
/*! Trnasfer finished or not.*/
@property (nonatomic, strong) NSString *transferFinished;
/*! Error list for live photo saved as static photo. Use for UI purpose.*/
@property (nonatomic, strong) NSArray *errorLivePhotoList;

/*!
 @brief Singlton initializer for CTUserDefaults class. Method will init system NSUserDefault one time.
 */
+ (instancetype)sharedInstance;

/*!
 Add live photo name to the error list if live photo will be saved as static plain photo.
 @param photoName NSString value represents the name of photo file.
 */
- (void)addErrorLivePhoto:(NSString *)photoName;

@end
