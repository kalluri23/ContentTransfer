//
//  CTPhotosExport.h
//  contenttransfer
//
//  Created by Guntupalli, Neelima on 9/9/16.
//  Copyright © 2016 Verizon Wireless. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <UIKit/UIKit.h>

#pragma mark - Callback block define
/*!
     @brief Completion call back block for media fetching.
     @param photoCount NSInteger represents the count saved in local device.
     @param streamCount NSInteger represents the count saved in cloud service. This amount of data we won't transfer, but will show the number for user.
     @param unavailableCount NSInteger represents the count of media cannot be read by app. For now, no use for this number.
 */
typedef void (^completionHandler)(NSInteger photoCount, NSInteger streamCount, NSInteger unavailableCount);
/*!
     @brief Completion call back block for photo data query.
     @param phototAsset Object represent the photo data. This is id type, since asset class are different in iOS 7 and iOS 9.
 */
typedef void (^photofetchsucess)(NSData *photoData, NSError *error);
/*! Deprecated. Photo fetch failure callback block for old logic.*/
typedef void (^photofetchfailure)(NSString * errorMsg, BOOL isPermissionErr);
/*! Deprecated. Video fetch failure callback block for old logic.*/
typedef void (^videofetchfailure)(NSString * errorMsg, BOOL isPermissionErr);
/*!
     @brief Completion call back block for video data query.
     @param phototAsset Object represent the video asset. This is id type, since asset class are different in iOS 7 and iOS 9.
 */
typedef void (^videofetchsucess)(id videoAsset);

#pragma mark - Delegate procotol define
/*! Delegate protocol for CTPhotosExport object.*/
@protocol PhotoUpdateUIDelegate <NSObject>
/*! Call this method when exporter class needs to update fetching number for photos.*/
- (void)shouldUpdatePhotoNumber:(NSInteger)number;
/*! Call this method when exporter class needs to update fetching number for videos.*/
- (void)shouldUpdateVideoNumber:(NSInteger)number;
@end

/*!
     @brief Exporter class for photo/video media fetch. This class contains all the logic related to photo/video media fetching.
 */
@interface CTPhotosExport : NSObject {
    /*! The path for saving photo log file.*/
    NSString *photoLogfilepath;
    /*! The path for saving video log file.*/
    NSString *videoLogfilepath;
    /*! Deprecated. Cannot remember what this parameter is.*/
    NSString *sentPhotolist;
}
#pragma mark - Parameters define
/*!
     @brief PhotoUpdateUIDelegate parameter.
     @see PhotoUpdateUIDelegate
 */
@property (nonatomic, weak) id<PhotoUpdateUIDelegate> delegate;
/*! Asset library using to fetch media in exporter.*/
@property (nonatomic, strong) ALAssetsLibrary *assetsLibrary;
/*! Deprecated. Not sure the original use.*/
@property(nonatomic,copy) completionHandler videocallBackHandler;
/*! Deprecated. Not sure the original use.*/
@property(nonatomic,copy) photofetchsucess fetchSucess;
/*! Deprecated. Not sure the original use.*/
@property(nonatomic,copy) photofetchfailure fetchfailure;
/*! Deprecated. Not sure the original use.*/
@property(nonatomic,copy) videofetchfailure videofetchfailure;
/*! Deprecated. Not sure the original use.*/
@property(nonatomic,copy) videofetchsucess fetchVideoSucess;

/*! Map asset URL with file name. When query data, program can easily get asset URL through the file name.*/
@property(atomic,strong) NSMutableDictionary *hashTableUrltofileName;
/*! Super data set for photo. This is the final data set will be trasnferred.*/
@property(atomic,strong) NSMutableArray *photoListSuperSet;
/*! Data set for photos saved in cloud stream.*/
@property(atomic,strong) NSMutableArray *photoStreamSet;
/*! Data set for videos saved in cloud stream.*/
@property(atomic,strong) NSMutableArray *videoStreamSet;
/*! Super data set for video. This is the final data set will be trasnferred.*/
@property(atomic,strong) NSMutableArray *videoListSuperSet;

#pragma mark - Methods define
/*!
     @brief Get file path saved photo file log.
     @return NSString value represents the file path for photo log.
 */
- (NSString *)getphotoLogfilepath;
/*!
     @brief Query real file data for photo. This method will be used during the transfer.
     @param imageName NSString value represents the name of the image.
     @param isLive BOOL value indicate the photo is live photo or not.
     @param fetchSuccess photofetchsucess call back block.
     @see photofetchsucess
 */
- (void)getPhotoData:(NSString *)imageName forLive:(BOOL)isLive Sucess:(photofetchsucess)fetchSucess;
/*!
 Query video resource data for live photo. This method will be used during the transfer.
 @param imageName NSString value represents the name of the image.
 @param handler photofetchsucess call back block.
 @see photofetchsucess
 */
- (void)getVideoResourceForLivePhoto:(NSString *)imageName completion:(photofetchsucess)handler;
/*!
 @brief Query size of video component for live photo.
 @param imageName NSString value represents the name of the image.
 @return Size of video part for live photo.
 */
- (long long)getVideoComponentSize:(NSString *)imageName;
/*!
     @brief Query real file data for video. This method will be used during the transfer.
     @param imageName NSString value represents the name of the image.
     @param fetchSuccess videofetchsucess call back block.
     @see videofetchsucess
 */
- (void)getVideoData:(NSString *)imagename Sucess:(videofetchsucess)fetchSucess;

/*!
     @brief Fetch photo using PHPhoto library.
     @param completionHandler Callback block when fetching is completed.
     @param failureHandler Callback block when fetching is failed.
     @note PHPhoto library only work on iOS version 8 and above, do not call this method on iOS version less than 8. Crash will be expected.
 */
- (void)fetchPhotosUsingNewPhotoLibrary:(void(^)(NSInteger photoCount, NSInteger streamCount, NSInteger unavailableCount, BOOL isAllPhotos))completionHandler onFailure:(void(^)(NSString * errorMsg))failureHandler;
/*!
     @brief Fetch photo using ALAssetsLibrary library.
     @param completionHandler Callback block when fetching is completed.
     @param failureHandler Callback block when fetching is failed.
     @note ALAssetsLibrary works for all iOS verison, but deprecated on iOS 8. So only call this method on iOS version less than 8.
 */
- (void)fetchPhotosUsingOldPhotoLibrary:(void(^)(NSInteger photoCount, NSInteger streamCount, NSInteger unavailableCount, BOOL isAllPhotos))completionHandler onFailure:(void(^)(NSString * errorMsg))failureHandler ;
/*!
     @brief Fetch video using PHPhoto library.
     @param completionHandler Callback block when fetching is completed.
     @param failureHandler Callback block when fetching is failed.
     @note PHPhoto library only work on iOS version 8 and above, do not call this method on iOS version less than 8. Crash will be expected.
 */
- (void)fetchVideosUsingNewPhotoLibrary:(void(^)(NSInteger videoCount, NSInteger streamCount, NSInteger unavailableCount, BOOL isAllPhotoVideo))completionHandler onFailure:(void(^)(NSString * errorMsg))failureHandler;
/*!
     @brief Fetch video using ALAssetsLibrary library.
     @param completionHandler Callback block when fetching is completed.
     @param failureHandler Callback block when fetching is failed.
     @note ALAssetsLibrary works for all iOS verison, but deprecated on iOS 8. So only call this method on iOS version less than 8.
 */
- (void)fetchVideosUsingALAssetPhotoLibrary:(void(^)(NSInteger videoCount, NSInteger streamCount, NSInteger unavailableCount, BOOL isAllPhotoVideo))completionHandler onFailure:(void(^)(NSString * errorMsg))failureHandler;
/*!
     @brief Persmission request alert for ALAssetLibrary.
     @param granted Void callback block for user granted permssion.
     @param deny Void callback block for user denied permission.
     @note ALAssetsLibrary works for all iOS verison, but deprecated on iOS 8. So only call this method on iOS version less than 8.
 */
- (void)requesForSecondTimePermissionAlert:(void(^)(void))granted andDenied:(void(^)(void))deny;
/*!
     @brief Get the count of photos in camera roll.
     @param completionHandler Completion callback block contains photo's count.
 */
- (void)getCameraRollPhotosCount:(void(^)(NSInteger photoCount,NSInteger streamCount,NSInteger unavailableCount, BOOL isAllPhotos))completionHandler;
/*!
     @brief Get the count of videos in camera roll.
     @param completionHandler Completion callback block contains video's count.
 */
- (void)getCameraRollVideoCount:(void(^)(NSInteger photoCount,NSInteger streamCount,NSInteger unavailableCount, BOOL isAllPhotos))completionHandler;

@end
