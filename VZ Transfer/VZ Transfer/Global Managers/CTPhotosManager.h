//
//  PhotosAccessManager.h
//  contenttransfer
//
//  Created by Guntupalli, Neelima on 8/19/16.
//  Copyright © 2016 Verizon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CTPhotosExport.h"
#if STANDALONE == 0
    #import "CTContentTransferConstant.h"
#endif

/*! Delegate protocol for CTPhotoManager class. All method in this protocol will be optional.*/
@protocol PhotoManagerDelegate <NSObject>
@optional
/*!
     @brief Call this method when view should update the photo's count.
     @param count NSInteger value represents the count of photos.
 */
- (void)viewShouldUpdatePhotoCount:(NSInteger)count;
/*!
     @brief Call this method when view should update the video's count.
     @param count NSInteger value represents the count of videos.
 */
- (void)viewShouldUpdateVideoCount:(NSInteger)count;
@end

/*!
     @brief Manager class for photos API. This class contains all the methods related to photo libarary API.
 */
@interface CTPhotosManager : NSObject
/*!
     @brief Media exporter using in this manager class. Because fetching process for photos & videos are async, and both of tasks will share this exporter, so this exporter will be atomic to make sure it's thread safe.
     @see CTPhotosExport
 */
@property (atomic, strong) CTPhotosExport *photoExport;
/*! PhotoManagerDelegate parameter.*/
@property (nonatomic, weak) id<PhotoManagerDelegate> delegate;

/*!
    @brief Initializer for CTPhotoManager.
    @return An object represents the photo manager class.
 */
- (instancetype)initPhotoManager;
/*!
     @brief Get current permission status for photo library.
     @return CTAuthorizationStatus represents the media permission.
 */
+ (CTAuthorizationStatus)photoLibraryAuthorizationStatus;
/*!
     @brief Request photo library permission. This method will try to ask for user's permission on proper media library based on user's device OS version.
     @param completionBlock Completion block contains the result of user's decision.
 */
+ (void)requestPhotoLibraryAuthorisation:(void(^)(CTAuthorizationStatus status))completionBlock;
/*!
     @brief Fetch photos for user.
     @param completionHandler Callback block when fetching is completed.
     @param failureHandler Callback block when fetching is failed with error message.
 */
- (void)fetchPhotos:(void(^)(NSInteger photoCount, NSInteger streamCount, NSInteger unavailableCount, BOOL isAllPhotos))completionHandler onFailure:(void(^)(NSString * errorMsg))failureHandler;
/*!
     @brief Query photo file data using given file name 
     @param imageName NSString value represents the name of the image.
     @param isLivePhoto Bool value indicate it's for live photo or not.
     @param fetchSuccess photofetchsucess call back block.
     @see photofetchsucess
 */
- (void)requestPhotoDataForName:(NSString *)photoName forLive:(BOOL)isLivePhoto handler:(photofetchsucess)handler;
/*!
 Query video component for live photo file data using given file name
 @param imageName NSString value represents the name of the image.
 @param handler Photofetchsucess call back block.
 @see photofetchsucess
 */
- (void)requestVideoComponentForLivePhoto:(NSString *)photoName handler:(photofetchsucess)handler;
/*!
 Query size of video component for live photo file data using given file name
 @param imageName NSString value represents the name of the image.
 @return Size of video resource in live photo.
 */
- (long long)requestVideoComponentSizeForLivePhoto:(NSString *)photoName;
/*!
     @brief Fetch the data size for specific file name.
     @param fileName NSString value represents the name of the file, this will identify the file.
 */
+ (long long)dataSizeFromFile:(NSString*)fileName;
/*!
     @brief Fetch videos for user.
     @param completionHandler Callback block when fetching is completed.
     @param failureHandler Callback block when fetching is failed with error message.
 */
- (void)fetchVideos:(void(^)(NSInteger videoCount, NSInteger streamCount, NSInteger unavailableCount, BOOL isAllPhotoVideo))completionHandler onFailure:(void(^)(NSString * errorMsg))failureHandler;
/*!
     @brief Request video file data with specific filename. Result will be returned through handler callback.
     @param photoName NSString value represents the name of file.
     @param handler Callback block for result, asset of file will be included.
 */
- (void)requestVideoDataForName:(NSString *)photoName handler:(void(^)(id))handler;
/*!
     @brief Get total count of photo in camera roll.
     @param completionHandler Completion callback block contains photo's count.
 */
- (void)getCameraRollPhotosCount:(void(^)(NSInteger photoCount,NSInteger streamCount,NSInteger unavailableCount, BOOL isAllPhotos))completionHandler;
/*!
     @brief Get total count of video in camera roll.
     @param completionHandler Completion callback block contains video's count.
 */
- (void)getCameraRollVideoCount:(void(^)(NSInteger photoCount,NSInteger streamCount,NSInteger unavailableCount, BOOL isAllPhotos))completionHandler;
/*!
    @brief Check photo with specific local ID exists in photo library or not.
    @param localIdentifier NSString value represents the localID using in photo library.
    @return BOOL value indicate that photo file exist or not.
 */
+ (BOOL)checkPhotoWithID:(NSString *)localIdentifier;
/*!
    @brief Check video with specific local ID exists in photo library or not.
    @param localIdentifier NSString value represents the localID using in photo library.
    @return BOOL value indicate that video file exist or not.
 */
+ (BOOL)checkVideoWithID:(NSString *)localIdentifier;

@end
