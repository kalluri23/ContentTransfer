//
//  CTReceiveManagerHelper.h
//  contenttransfer
//
//  Created by Sun, Xin on 9/14/16.
//  Copyright © 2016 Verizon Wireless. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CTMediaStoreHelper.h"
#import "CTFileLogManager.h"

/*! Enum type for transfer status.*/
enum ReceiveState {
    /*! Hand shake status. This is default value.*/
    RECEIVE_HAND_SHAKE,
    /*! File list status.*/
    RECEIVE_ALL_FILE_LOG,
    /*! Vcard status.*/
    RECEIVE_VCARD_FILE,
    /*! Photo log status. Deprecated.*/
    RECEIVE_PHOTO_LOG_FILE,
    /*! Photo file status.*/
    RECEIVE_PHOTO_FILE,
    /*! Video log status. Deprecated.*/
    RECEIVE_VIDEO_LOG_FILE,
    /*! Video file status.*/
    RECEIVE_VIDEO_FILE,
    /*! Calendar file status.*/
    RECEIVE_CALENDAR_FILE,
    /*! Reminder file status.*/
    RECEVIE_REMINDER_FILE,
    /*! App list file status.*/
    RECEIVE_APP_LIST_FILE
    
};

/*! Receiver helper manager delegate. This delegate contains all the methods that related to receiving file logic. All methods are optional.*/
@protocol ReceiveHelperManager <NSObject>
@optional
/*!
    @brief Call this method when transfer finished receiving data package and need to move to next stage.
    @param lastIsDuplicate Deprecated. BOOL value indicate last package received is duplicate file.
 */
- (void)transferDidFinished:(BOOL)lastIsDuplicate;
/*!
    @brief Call this method when there is data need to be sent using socket.
    @param dataPacket NSData value represents the value that needs to be sent.
 */
- (void)writeDataToTheSocket:(NSData *)dataPacket;
/*!
    @brief Call this method when total payload get and need to store for further use.
    @param totalPayload NSNumber object represents the total payload for this transfer. Value will be long long value as bytes.
 */
- (void)totalPayLoadRecevied:(NSNumber *)totalPayload;
/*!
    @brief Call this method when there are not enough storage for saving contents.
    @param availableSpace NSNumber object represents the available space for current device. Value will be long long value as bytes.
 */
- (void)inSufficentStorageAvailalbe:(NSNumber *)availalbeSpace;
/*!
 Call this the received one package of data.
 @param packetSize Size of data for this packet.
 */
- (void)dataPacketRecevied:(long)packetSize;
/*! 
    @brief Call this method when should send signal to move transfer to saving stage.
 */
- (void)transferShouldAllowSaving;
/*!
    @brief Call this method when receiver side should update UI for process.
    @param isDuplicate BOOL value indicate this UI update package is for duplicate file or not.
 */
- (void)receiverShouldUpdateInfo:(BOOL)isDuplicate packageSize:(long long)pkgSize;

@end

/*!
    @brief Manager helper class for receiving files. 
           This helper contains all the general receving logic irrelevent to the connection type.
 */
@interface CTReceiveManagerHelper : NSObject
/*! File log manager object.*/
@property (nonatomic, strong) CTFileLogManager *fileListManager;
/*! 
    @brief Receiver helper manager delegate parameter.
    @see ReceiveHelperManager
 */
@property (nonatomic, weak) id<ReceiveHelperManager> delegate;
/*! Number of file received during this transfer. Seems like only add on, but never use it.*/
@property (nonatomic, assign) NSInteger numberOfFileReceived;
/*! 
    @brief Current transfer status indicator.
    @see ReceiveState
 */
@property (nonatomic,assign) enum ReceiveState currentStat;
/*!
    @brief CTMediaStoreHelper parameter.
    @see CTMediaStoreHelper
 */
@property (nonatomic, strong) CTMediaStoreHelper *storeHelper;
//@property (nonatomic, assign) NSInteger appsReceivedNumber;
/*! Number of calendar file in file list.*/
@property (atomic, assign) NSInteger numberOfCalendar;
/*! Number of apps in file list.*/
@property (atomic, assign) NSInteger numberOfApps;

/*! Total size of file list.*/
@property (nonatomic, assign) long long totalSizeOfFileList;
/*! Total size of contacts.*/
@property (nonatomic, assign) long long totalSizeOfVcard;
/*! Total size of photos.*/
@property (nonatomic, assign) long long totalSizeOfPhoto;
/*! Total size of videos.*/
@property (nonatomic, assign) long long totalSizeOfVideo;
/*! Total size of calendars.*/
@property (nonatomic, assign) long long totalSizeOfCalendar;
/*! Total size of app list.*/
@property (nonatomic, assign) long long totalSizeOfApps;
/*! Total size of reminders.*/
@property (nonatomic, assign) long long totalSizeOfReminder;

/*! Total data size in specific section.*/
@property (nonatomic, assign) long long dataSizeSection;
/*! Total data size for whole transfer.*/
@property (nonatomic, assign) long long totalSizeReceived;

/*! Number of photos start receiving.*/
@property (nonatomic, assign) NSInteger numberOfPhotosStartReceiving;
/*! Number of videos start receiving.*/
@property (nonatomic, assign) NSInteger numberOfVideosStartReceiving;
/*! Number of calendars start receiving.*/
@property (nonatomic, assign) NSInteger numberOfCalStartReceiving;
/*! Number of app list start receiving.*/
@property (nonatomic, assign) NSInteger numberOfAppsStartReceiving;

/*! Total number of photos.*/
@property (nonatomic, assign) NSInteger totalNumberOfPhotos;
/*! Total number of videos.*/
@property (nonatomic, assign) NSInteger totalNumberOfVideos;

/*! Array of total number of file failed for each of the type. Order is fixed:contacts/calendar/reminders/photos/videos/apps */
@property (nonatomic, strong) NSMutableArray *transferFailureCounts;
/*! Array of total size of file failed for each of the type. Order is fixed:contacts/calendar/reminders/photos/videos/apps */
@property (nonatomic, strong) NSMutableArray *transferFailureSize;

/*!
 Initializer for receiver manager helper.
 @param delegate Object to handle helper callback. Target should be defined as ReceiveHelperManager.
 @return CTReceiveManagerHelper object
 */
- (instancetype)initWithDelegate:(id<ReceiveHelperManager>)delegate;
/*!
 Get current type of data receiving.
 @return ReceiveState value represents the type.
 */
- (enum ReceiveState)type;

/*!
    @brief After received package, this method will try to parse the data and save proper file based on current trasnfer type.
 
           This method is a global method that working for both P2P and Bonjour. This method will be called from P2P/Bonjour manager, finish parsing data task, and return necessary value to P2P/Bonjour manager using delegate.
 
           No return value for this method itself.
    @param data NSData represents the data that received from sender side.
    @see ReceiveHelperManager
 */
- (void)receiverDidRecvDataPackage:(NSData *)data;
/*!Notify helper that receiving cancelled.*/
- (void)notifyProcessCancelled;
/*!Create reconnect request for sender.*/
- (void)createReconnectRequestHeader;
/*!Notify helper that photo receiving is done.*/
- (void)didFinishReceivedPhotoFile;
/*!Notify helper that video receiving is done.*/
- (void)didFinishReceivedVideoFile;

@end
