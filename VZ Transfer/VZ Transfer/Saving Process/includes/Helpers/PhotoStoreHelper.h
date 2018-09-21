//
//  PhotoStoreHelper.h
//  storePhotosTest
//
//  Created by Sun, Xin on 6/14/16.
//  Copyright © 2016 Sun, Xin. All rights reserved.
//

#import <Foundation/Foundation.h>

/*!
 Protocol for photo store helper class.
 @note All methods are optional.
 */
@protocol PhotoStoreDelegate <NSObject>
@optional
/*!
 Call this method when photo saved into gallery and need to do further work.
 @param URL String of the URL for photo.
 @param photoInfo Dictionary contains all the information for photo.
 @param localIdentifier Local ID read from photo app.
 @param success Yes when save success; otherwise No.
 @param error Error when failed, only exists when success is YES; otherwise will be nil.
 */
- (void)updateDuplicatePhoto:(NSArray<NSString *> *)URL withPhotoInfo:(NSDictionary *)photoInfo withLocalIdentifier:(NSString *)localIdentifier success:(BOOL)success orError:(NSError *)error;
/*!
 Call this method when video saved into gallery and need to do further work.
 @param URL String of the URL for photo.
 @param videoInfo Dictionary contains all the information for video.
 @param localIdentifier Local ID read from photo app.
 @param success Yes when save success; otherwise No.
 @param error Error when failed, only exists when success is YES; otherwise will be nil.
 */
- (void)updateDuplicateVideo:(NSString *)URL withVideoInfo:(NSDictionary *)videoInfo withLocalIdentifier:(NSString *)localIdentifier success:(BOOL)success orError:(NSError *)error;

@end

/*! Helper class for saving photos and videos into system photo app.*/
@interface PhotoStoreHelper : NSObject
/*!
 Delegate for photo store helper. Target should be specified as @b PhotoStoreDelegate.
 @see PhotoStoreDelegate
 */
@property (weak, nonatomic) id<PhotoStoreDelegate> delegate;
/*! Bool value indicate this transfer is for cross platform or not.*/
@property (assign, nonatomic) BOOL isCrossPlatform;

/*!
 Initializer for helper.
 @param delegate Target object with @b PhotoStoreDelegate.
 @param path Root path of all the files stored on local device.
 @param dataSets Media data sets.
 */
- (instancetype)initWithOperationDelegate:(id<PhotoStoreDelegate>)delegate andRootPath:(NSString *)path andDataSets:(NSArray *)dataSets;
/*! Start saving photos, delegate will be called as callback.*/
- (void)startSavingPhotos;
/*! Start saving videos, delegate will be called as callback.*/
- (void)startSavingVideos;

@end
