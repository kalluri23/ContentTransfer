//
//  CTAudiosManager.h
//  contenttransfer
//
//  Created by Sun, Xin on 5/26/17.
//  Copyright © 2017 Verizon Wireless Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>

/*!
    @brief Manager object for Audio files.
    @discussion This class will contain all the logic related to audio collection.
 */
@interface CTAudiosManager : NSObject
/*!
    @brief File list use for saving audio files.
    @discussion It's a array of dictionary, each dicionary contains file name and size for each audio file.
 */
@property (nonatomic, strong) NSMutableArray *audioFileList;
/*! Audio file count properties, represents total audio files, no matter can get the file or in the cloud.*/
@property (nonatomic, assign) NSInteger totalAudioFileCount;
/*! Audio file count properties, represents successfully fetched audio file number.*/
@property (nonatomic, assign) NSInteger localAudioFileCount;
/*! Audio file count properties, represents audio data restored in cloud and not yet saved in local device.*/
@property (nonatomic, assign) NSInteger cloudAudioFileCount;
/*! Audio file count properties, represents number of file the has error during the fetch process.*/
@property (nonatomic, assign) NSInteger unavailableFileCount;
/*! Audio file count properties, represents number of file that is duplicate.*/
@property (nonatomic, assign) NSInteger duplicateFileCount;
/*! Total size of all audio file size saved in local machine.*/
@property (nonatomic, assign) long long totalAudioFilesSize;

/*!
    @brief Check audio library authorization status.
    @discussion MPMediaLibraryAuthorizationStatusNotDetermined will request for new permission,
                MPMediaLibraryAuthorizationStatusDenied,MPMediaLibraryAuthorizationStatusRestricted will be considered as deny.
                MPMediaLibraryAuthorizationStatusAuthorized will be considered as approve.
    @return enum CTAuthorizationStatus type represent the result of status.
    @see CTAuthorizationStatus
 */
+ (CTAuthorizationStatus)audioLibraryAuthorizationStatus;
/*!
    @brief Request audio library permission.
    @discussion Completion block contains CTAuthorizationStatus of the request will be returned after user make their choice for the permission prompt.
    @see CTAuthorizationStatus
 */
+ (void)requestAudioLibraryAuthorisation:(void(^)(CTAuthorizationStatus status))completionBlock;

/*! @brief Initializer of audio manager.*/
- (instancetype)initAudioManager;
/*!
    @brief This method will go through all the audio files saved in device and get the file list for transfer.
    @discussion The mail target of this method is to create the file list that contains audio size and file name. No need to convert all the file into audio data, can do it during the transfer.

                When complete, completion block will called, return the total count and total size of the audio files.
    @param completionBlock finish block contains the count and file size of audio
 */
- (void)fetchAudioListWithCompletionHandler:(void(^)(NSInteger audioCount, long long audioSize))completionBlock;
/*! @brief Cancel all the ongoing audio collection process.*/
- (void)cancelCollectionProcess;

/*!
    @brief Get audio file during transfer based on file name.
    @discussion Method will try to find the file with same audio name in local storage, if file exist and read properly then directly return the data and start sending;
 
                Otherwise, method will try to fetch the file from libraray using the audio name given.
    @param audioName name of the audio to identify the music.
    @param completionHandler Complete block for fetching process.
 */
- (void)audioFile:(NSString *)audioName getDataWithCompletionHandler:(void(^)(NSString * localPath, BOOL success))completionHandler;

@end
