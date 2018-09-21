//
//  PhotosAccessManager.m
//  contenttransfer
//
//  Created by Guntupalli, Neelima on 8/19/16.
//  Copyright © 2016 Verizon. All rights reserved.
//

#import "CTPhotosManager.h"
#import <Photos/Photos.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "CTFileManager.h"

@interface CTPhotosManager() <PhotoUpdateUIDelegate>

@end

@implementation CTPhotosManager

@synthesize photoExport;

#pragma mark - Initializer
- (instancetype)initPhotoManager {
    self = [super init];
    if (self) {
        photoExport = [[CTPhotosExport alloc] init];
    }
    
    return self;
}

#pragma mark - PERMISSION CHECK, CLASS METHODS
+ (void)requestPhotoLibraryAuthorisation:(void(^)(CTAuthorizationStatus status1))completionBlock {
    if (NSFoundationVersionNumber >= NSFoundationVersionNumber_iOS_8_0) { // iOS 8 and above
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            if (status == PHAuthorizationStatusAuthorized) {
                completionBlock(CTAuthorizationStatusAuthorized);
            }else{
                completionBlock(CTAuthorizationStatusDenied);
            }
        }];
    } else { // iOS less than 8, ALAssetLibrary
        CTPhotosExport *photoexport = [[CTPhotosExport alloc] init];
        [photoexport requesForSecondTimePermissionAlert:^{
            completionBlock(CTAuthorizationStatusAuthorized);
        } andDenied:^{
            completionBlock(CTAuthorizationStatusDenied);
        }];
    }
}

+ (CTAuthorizationStatus)photoLibraryAuthorizationStatus{
    
    if (NSFoundationVersionNumber >= NSFoundationVersionNumber_iOS_8_0) {
        PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
        if (status==PHAuthorizationStatusAuthorized) {
            return CTAuthorizationStatusAuthorized;
        }else if (status == PHAuthorizationStatusNotDetermined){
            
            return CTAuthorizationNotDetermined;
        }else{
            return CTAuthorizationStatusDenied;
        }
    } else{
        ALAuthorizationStatus status = [ALAssetsLibrary authorizationStatus];
        if (status==ALAuthorizationStatusAuthorized) {
            return CTAuthorizationStatusAuthorized;
        }else if (status == ALAuthorizationStatusNotDetermined){
            return CTAuthorizationNotDetermined;
        }else{
            return CTAuthorizationStatusDenied;
        }
    }    
}

#pragma mark - FETCH PHOTO METHODS
- (void)fetchPhotos:(void(^)(NSInteger photoCount, NSInteger streamCount, NSInteger unavailableCount, BOOL isAllPhotos))completionHandler onFailure:(void(^)(NSString * errorMsg))failureHandler {
    
    // New photo library support iOS 8 & above
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
        [self.photoExport fetchPhotosUsingNewPhotoLibrary:completionHandler onFailure:failureHandler];
    } else {
        [self.photoExport fetchPhotosUsingOldPhotoLibrary:completionHandler onFailure:failureHandler];
    }
    
}

- (void)requestPhotoDataForName:(NSString *)photoName forLive:(BOOL)isLivePhoto handler:(photofetchsucess)handler {
    [self.photoExport getPhotoData:photoName forLive:isLivePhoto Sucess:handler];
}

- (void)requestVideoComponentForLivePhoto:(NSString *)photoName handler:(photofetchsucess)handler {
    [self.photoExport getVideoResourceForLivePhoto:photoName completion:handler];
}

- (long long)requestVideoComponentSizeForLivePhoto:(NSString *)photoName {
    return [self.photoExport getVideoComponentSize:photoName];
}

#pragma mark - FETCH VIDEO METHODS
- (void)fetchVideos:(void(^)(NSInteger videoCount, NSInteger streamCount, NSInteger unavailableCount,BOOL isAllPhotosVideo))completionHandler onFailure:(void(^)(NSString * errorMsg))failureHandler {
    
    // New photo library support iOS 8 & above
    if(NSFoundationVersionNumber >= NSFoundationVersionNumber_iOS_8_0) {
        [self.photoExport fetchVideosUsingNewPhotoLibrary:completionHandler onFailure:failureHandler];
    } else {
        [self.photoExport fetchVideosUsingALAssetPhotoLibrary:completionHandler onFailure:failureHandler];
    }
}

- (void)requestVideoDataForName:(NSString *)photoName handler:(void(^)(id))handler {
    [self.photoExport getVideoData:photoName Sucess:^(id videoAsset) {
        handler(videoAsset);
    }];
}

+ (long long)dataSizeFromFile:(NSString*)fileName {
    
    NSError *error;
    NSData *rawData = [CTFileManager dataFromFile:fileName];
    NSArray *mediafileList;
    long long totalSize = 0;
    if (rawData) {
        mediafileList = [NSJSONSerialization JSONObjectWithData:rawData options:0 error:&error];
    }
    for (NSDictionary *eachItem in mediafileList) {
        // NSInteger *eachSize = [[eachItem valueForKey:@"Size"] intValue];
        long long eachSize = [[eachItem objectForKey:@"Size"] longLongValue];
        totalSize += eachSize;
    }
    return totalSize;
}

- (void)shouldUpdatePhotoNumber:(NSInteger)number {
    [self.delegate viewShouldUpdatePhotoCount:number];
}

- (void)shouldUpdateVideoNumber:(NSInteger)number {
    [self.delegate viewShouldUpdateVideoCount:number];
}

- (void)getCameraRollPhotosCount:(void(^)(NSInteger photoCount,NSInteger streamCount,NSInteger unavailableCount, BOOL isAllPhotos))completionHandler {
    
    [self.photoExport getCameraRollPhotosCount:^(NSInteger tempPhotoCount, NSInteger tempStreamCount, NSInteger tempUnavailableCount, BOOL isAllPhotos) {
        completionHandler(tempPhotoCount,tempStreamCount,tempUnavailableCount,isAllPhotos);
    }];
    
}

-(void)getCameraRollVideoCount:(void(^)(NSInteger videoCount,NSInteger streamVideoCount,NSInteger unavailableVideoCount, BOOL isAllPhotos))completionHandler {
 
    [self.photoExport getCameraRollVideoCount:^(NSInteger tempVideoCount, NSInteger tempStreamVideoCount, NSInteger tempUnavailableVideoCount, BOOL isAllPhotos) {
        completionHandler(tempVideoCount,tempStreamVideoCount,tempUnavailableVideoCount,isAllPhotos);
    }];
}

#pragma mark - Class Methods
+ (BOOL)checkPhotoWithID:(NSString *)localIdentifier {
    return [CTPhotosManager _checkFileWithID:localIdentifier forType:PHAssetMediaTypeImage];
}

+ (BOOL)checkVideoWithID:(NSString *)localIdentifier {
    return [CTPhotosManager _checkFileWithID:localIdentifier forType:PHAssetMediaTypeVideo];
}

/*!
    @brief Private class method to check file existence with ID.
    @param localIdentifier NSString value represents the local ID for file using in photo library.
    @type type Enum PHAssetMediaType indicate the type of photo library query.
    @return BOOL value indicate that specific file is exist or not.
 */
+ (BOOL)_checkFileWithID:(NSString *)localIdentifier forType:(enum PHAssetMediaType)type {
    PHFetchOptions *fetchOptions = [[PHFetchOptions alloc] init];
    [fetchOptions setPredicate:[NSPredicate predicateWithFormat:@"mediaType == %i", type]];
    
    PHFetchResult *fetchResults = [PHAsset fetchAssetsWithLocalIdentifiers:@[localIdentifier] options:fetchOptions];
    
    return fetchResults.count > 0; // return if local device can find target photo with ID or not
}

@end
