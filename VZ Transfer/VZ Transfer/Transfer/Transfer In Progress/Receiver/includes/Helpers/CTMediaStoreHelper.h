//
//  CTMediaStoreHelper.h
//  contenttransfer
//
//  Created by Sun, Xin on 9/15/16.
//  Copyright © 2016 Verizon Wireless. All rights reserved.
//

#import <Foundation/Foundation.h>

/*! Delegate for media store helper class. All the operations are optional.*/
@protocol MediaStoreHelperDelegate <NSObject>
@optional
/*! Call this method when all the photo files stored in local memory and allow process to start photo saving.*/
- (void)transferShouldPassPhoto;
/*! Call this method when all the video files stored in local memory and allow process to start video saving.*/
- (void)transferShouldPassVideo;
@end

/*!
    @brief This is helper class that help receiver side store media into app's local storage for further use.
    @note This class will not handle any real saving logic.
 */
@interface CTMediaStoreHelper : NSObject
/*! 
    @brief Delegate parameter for CTMediaStoreHelper object.
    @see MediaStoreHelperDelegate
 */
@property (nonatomic, weak) id<MediaStoreHelperDelegate> delegate;
/*! Total number of photos.*/
@property (nonatomic, assign) NSInteger totalNumberOfPhotos;
/*! Total number of videos.*/
@property (nonatomic, assign) NSInteger totalNumberOfVideos;
/*! Number of photo received before saving into local.*/
@property (assign, atomic) NSInteger tempPhotoCount;
/*! Number of video received before saving into local.*/
@property (assign, atomic) NSInteger tempVideoCount;

/*! Number of temp photo file saved.(Received)*/
@property (assign, atomic) NSInteger tempPhotoSavedCount;
/*! Number of temp video file saved.(Received)*/
@property (assign, atomic) NSInteger tempVideoSavedCount;

/*! Holder for image resource for live photo.*/
@property (strong, nonatomic) NSData *imageResourceHolder;

/*!
    @brief Try to save photo data into app's local storage as temp file.
    @dicussion Saving process will be executed in seperate thread. After file saved properly, photo information will be added into list. 
 
               Once every file saved properly, method will send signal allow process to save photos.
    @param photoData NSData value represents the photo data.
    @param videoData NSData value represents the video data.
    @param photoInfo NSDictionary object represents the information for photo. This list is read from file list.
    @param photoData NSData value represents the photo data.
 */
- (void)storePhotoIntoTempDocumentFolder:(NSData*)photoData
                          videoComponent:(NSData *)videoData
                             isLivePhoto:(BOOL)isLivePhoto
                               photoInfo:(NSDictionary *)photoInfo;
/*!
    @brief Try to save video data into app's local storage as temp file.
    @dicussion Saving process will be executed in seperate thread. After file saved properly, video information will be added into list.
 
               Once every file saved properly, method will send signal allow process to save videos.
    @param receivedPacket NSData value represents the video data.
    @param videoInfo NSDictionary object represents the information for video. This list is read from file list.
    @param tillNowVideoReceived Long long value represents the size of video received till current package.
    @param videoFileSize Long long value represents the total size of video file.
    @param shouldRemoveOldFile BOOL value indicate that should remove old file or not.
 */
- (void)storeVideoReceivedPacketToTempFile:(NSData *)receivedPacket
                                   forFile:(NSDictionary *)videoInfo
                           tillNowReceived:(long long)tillNowVideoReceived
                                 totalSize:(long long)videoFileSize
                                    remove:(BOOL)shouldRemoveOldFile;
/*! Call this method when transfer did canceled photo transfer.*/
- (void)transferDidCancelledPhoto;
/*! Call this method when transfer did canceled video transfer.*/
- (void)transferDidCancelledVideo;

/*!
    @brief Store the list for video trasfer based on the saving status when this method called.
 */
- (void)storeVideoList;
/*!
    @brief Store the list for photo trasfer based on the saving status when this method called.
 */
- (void)storePhotoList;

@end
