//
//  CTPhotosExport.m
//  contenttransfer
//
//  Created by Guntupalli, Neelima on 9/9/16.
//  Copyright © 2016 Verizon Wireless. All rights reserved.
//

#import "CTUserDevice.h"
#import "CTPhotosExport.h"
#import "CTDataCollectionManager.h"
#import "CTContentTransferConstant.h"

#import "NSString+CTHelper.h"
#import "NSDate+CTMVMConvenience.h"
#import "NSString+CTRootDocument.h"

#import <Photos/Photos.h>

#if STANDALONE == 0
#import <contentTransferFramework/contenttransfer-Swift.h>
#endif

@interface CTPhotosExport()
@property (atomic, strong) NSMutableDictionary *photoDic;
@property (atomic, strong) NSMutableDictionary *videoDic;

@property (nonatomic, assign) BOOL cloudPhotoFetchFinished;
@property (nonatomic, assign) BOOL localPhotoFetchFinished;

@property (nonatomic, assign) BOOL cloudVideoFetchFinished;
@property (nonatomic, assign) BOOL localVideoFetchFinished;

@property (atomic, assign) NSInteger unavaliableCloudcount;
@property (atomic, assign) NSInteger unavaliableVideoCloudcount;
@property (atomic, strong) NSMutableSet *unavailableCloudList;

@property (nonatomic, assign) dispatch_once_t once; // make sure merge photos only called once for each of the photoExport instance
@property (nonatomic, assign) dispatch_once_t once_v;

@property (atomic, assign) NSInteger photoCollectingCount;
@property (atomic, assign) NSInteger videoCollectionCount;
@property (atomic, assign) NSUInteger orderNumber;
@property (nonatomic,strong) NSMutableDictionary *duplicateDict;

@property (nonatomic, assign) BOOL allPhotos;
@property (nonatomic, assign) BOOL isAllPhotoVideo;
@end

@implementation CTPhotosExport
@synthesize orderNumber;
@synthesize hashTableUrltofileName;
@synthesize photoListSuperSet;
@synthesize photoStreamSet;
@synthesize videoStreamSet;
@synthesize videoListSuperSet;
@synthesize unavaliableCloudcount;
@synthesize unavaliableVideoCloudcount;
@synthesize photoCollectingCount;
@synthesize videoCollectionCount;
@synthesize unavailableCloudList;

- (id)init {
    
    if (self = [super init]) {
        
        NSString *basePath = [NSString appRootDocumentDirectory];
        
        photoLogfilepath  = [NSString stringWithFormat:@"%@/VZPhotoLogfile.txt",basePath];
        videoLogfilepath  = [NSString stringWithFormat:@"%@/VZVideoLogfile.txt",basePath];
        
        hashTableUrltofileName = [[NSMutableDictionary alloc] init];
        
        [[NSFileManager defaultManager] removeItemAtPath:photoLogfilepath error:nil];
        [[NSFileManager defaultManager] removeItemAtPath:videoLogfilepath error:nil];
        
        photoCollectingCount = 0;
        orderNumber = 0;
        
        self.photoListSuperSet = [[NSMutableArray alloc] init];
        self.photoStreamSet = [[NSMutableArray alloc] init];
        
        self.videoListSuperSet = [[NSMutableArray alloc] init];
        self.videoStreamSet = [[NSMutableArray alloc] init];
        
        self.videoDic = [[NSMutableDictionary alloc] init];
        self.photoDic = [[NSMutableDictionary alloc] init];
        
        self.duplicateDict = [[NSMutableDictionary alloc] init];
        self.unavailableCloudList = [[NSMutableSet alloc] init];
        
        // ALAssetsLibrary is deprecated, only use in device with old iOS version (7 & below)
        if (SYSTEM_VERSION_LESS_THAN(@"8.0")) {
            self.assetsLibrary = [[ALAssetsLibrary alloc] init];
        }
    }
    
    return self;
}


- (NSString *)getphotoLogfilepath {
    return photoLogfilepath;
}

- (NSString *)getvideoLogfilepath {
    return videoLogfilepath;
}

#pragma mark - Photo Fetching

- (void)mergeAllPhotos {
    
    //    NSLog(@"->photo hash count:%d(%d)", self.hashTableUrltofileName.count, self.photoDic.count + self.videoDic.count);
    [self.photoListSuperSet addObjectsFromArray:[self.photoDic allValues]];
    if (([self.photoStreamSet count] > 0) && ([[CTUserDevice userDevice].phoneCombination isEqualToString:IOS_Andriod])) {
        [self.photoListSuperSet addObjectsFromArray:self.photoStreamSet];
    }
}

#pragma mark - NEW PHOTO LIBRARY (__IPHONE_8_0)
- (void)fetchPhotosUsingNewPhotoLibrary:(void(^)(NSInteger photoCount, NSInteger streamCount, NSInteger unavailableCount, BOOL isAllPhotos))completionHandler onFailure:(void(^)(NSString * errorMsg))failureHandler{
    DebugLog(@"photo start:%@", self.hashTableUrltofileName);
    orderNumber = 0;
    // Globle pram
    // Group image filter Option
    PHFetchOptions *onlyImagesOptions = [PHFetchOptions new];
    onlyImagesOptions.predicate = [NSPredicate predicateWithFormat:@"mediaType = %i", PHAssetMediaTypeImage];
    onlyImagesOptions.includeAllBurstAssets = YES;// Transfer burst photos as seperate images
    
    // Image request option
    PHImageRequestOptions * imageRequestOptions = [[PHImageRequestOptions alloc] init];
    imageRequestOptions.synchronous = YES;
    
    // Read iCloud Photos
    [self fetchImageInMyPhotoStream:onlyImagesOptions and:imageRequestOptions finish:^{
        DebugLog(@"fetching my photo stream finish");
        [self finishFetchingPhotos:completionHandler onFailure:failureHandler];
    }];
    
    // Read All photos from custom ablums
    [self fetchImageInCustomAblum:onlyImagesOptions and:imageRequestOptions finish:^{
        DebugLog(@"fetching ablum image done!");
        [self finishFetchingPhotos:completionHandler onFailure:failureHandler];
    }];
}

- (void)finishFetchingPhotos:(void(^)(NSInteger photoCount, NSInteger streamCount, NSInteger unavailableCount, BOOL isAllPhotos))completionHandler onFailure:(void(^)(NSString * errorMsg))failureHandler
{
    if (_cloudPhotoFetchFinished && _localPhotoFetchFinished) {
        dispatch_once(&_once, ^{
            [self mergeAllPhotos];
            //           DebugLog(@"photo end:%@", self.hashTableUrltofileName);
            if ([NSJSONSerialization isValidJSONObject:self.photoListSuperSet]) {
                // photo list is a valid Json object, transfer list to data.
                
                NSData *photoData = [NSJSONSerialization dataWithJSONObject:self.photoListSuperSet options:NSJSONWritingPrettyPrinted error:nil];
                
                NSFileManager *fileManager = [NSFileManager defaultManager];
                [fileManager createFileAtPath:photoLogfilepath contents:photoData attributes: nil];
                
                //photocallBackHandler([self.photoListSuperSet count], [self.photoStreamSet count], self.unavaliableCloudcount);
                completionHandler([self.photoListSuperSet count], [self.photoStreamSet count], self.unavaliableCloudcount, self.allPhotos);
            } else {
                // photo list is not a valid object
                failureHandler(@"Error happened when fetching photos using new library.");
                //_fetchfailure(@"Error happened when fetching photos using new library.", NO);
            }
        });
    }
}

- (void)fetchImageInMyPhotoStream:(PHFetchOptions *)fetchSetting and:(PHImageRequestOptions *)imageRequesSetting finish:(void (^)(void))_finished
{
    PHFetchResult *cloudGroups = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum
                                                                          subtype:PHAssetCollectionSubtypeAlbumMyPhotoStream
                                                                          options:nil];
    if (cloudGroups.count > 0) {
        [cloudGroups enumerateObjectsUsingBlock:^(PHAssetCollection *cloudGroup, NSUInteger idx, BOOL *stop) {
            // Fetch all the images from My Photo Stream
            *stop = [[CTDataCollectionManager sharedManager] isPhotosFetchingOperationCancelled];
            
            PHFetchResult *myPhotoStreamPhotos = [PHAsset fetchAssetsInAssetCollection:cloudGroup options:fetchSetting];
            if (myPhotoStreamPhotos.count > 0) {
                __block int streamPhotoCount = 0;
                [myPhotoStreamPhotos enumerateObjectsUsingBlock:^(PHAsset *asset, NSUInteger idx, BOOL *stop) {
                    
                    *stop = [[CTDataCollectionManager sharedManager] isPhotosFetchingOperationCancelled];
                    
                    @autoreleasepool {
                        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"9.1") && [[CTUserDevice userDevice].phoneCombination isEqualToString:IOS_IOS] && asset.mediaSubtypes == PHAssetMediaSubtypePhotoLive) {
                            // It's a live photo, need to add extra information into file list. (Only work for iOS 9.1)
                            CTLivePhoto *livePhoto = [[CTLivePhoto alloc] initWith:asset];
                            if ([livePhoto isValidLivePhoto]) { // If it's invalid, then keep the old file list; otherwise make change of file list.
                                [livePhoto generateDict];
                                // Recalulate the size of image.
                                [livePhoto getImageDataWithCompletion:^(NSData * _Nullable data) {
                                    if (data && data.length > 0) {
                                        NSInteger imageSize = [self caulateInsertImageMetaData:data withDate:asset.creationDate];
                                        [livePhoto updateFileSizeWithNewImageSize:imageSize];
                                        @synchronized (self) {
                                            // Add info into file list
                                            [self.photoStreamSet addObject:livePhoto.info];
                                            // Add hash for transfer file retrieve
                                            [self.hashTableUrltofileName setObject:livePhoto forKey:livePhoto.encryptName];
                                        }
                                    } else {
                                        NSLog(@"Error happened when fetching image data for live photo. Should not add into file list, because it's not able to fetch the actual data to transfer.");
                                        @synchronized (self) {
                                            [self.unavailableCloudList addObject:[asset.localIdentifier componentsSeparatedByString:@"/"].firstObject];
                                            self.unavaliableCloudcount++;
                                        }
                                    }
                                }];
                                
                                // Update for 1 image
                                @synchronized (self) {
                                    if (++photoCollectingCount % 50 == 0) {
                                        [self.delegate shouldUpdatePhotoNumber:photoCollectingCount];
                                    }
                                    
                                    if (++streamPhotoCount == myPhotoStreamPhotos.count) { // last image
                                        _cloudPhotoFetchFinished = YES;
                                        _finished();
                                    }
                                }
                            } else { // is not valid live photo, use old way to fetch plain photos.
                                livePhoto = nil; // Reset live photo object
                                [[PHImageManager defaultManager] requestImageDataForAsset:asset options:imageRequesSetting resultHandler:^(NSData *imageData, NSString *dataUTI, UIImageOrientation orientation, NSDictionary *info) {
                                    
                                    if (imageData.length > 0 && info && asset) {
                                        
                                        NSString *fileName = nil;
                                        // Create info list for photo
                                        NSMutableDictionary *photoDetails = [[NSMutableDictionary alloc] init];
                                        
                                        NSString *imageExtension = nil;
                                        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"9.0")) {
                                            NSArray *resources = [PHAssetResource assetResourcesForAsset:asset];
                                            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.type == %d", PHAssetResourceTypePhoto];
                                            NSArray *filteredArray = [resources filteredArrayUsingPredicate:predicate];
                                            
                                            if (filteredArray.count > 0) {
                                                imageExtension = ((PHAssetResource *)[filteredArray objectAtIndex:0]).originalFilename;
                                            }
                                        }
                                        
                                        if (!imageExtension) {
                                            imageExtension = [self getFileName:(NSURL *)[info objectForKey:@"PHImageFileURLKey"]];
                                        }
                                        
                                        if (imageExtension) {
                                            imageExtension = [imageExtension pathExtension];
                                        }
                                        
                                        if (asset.localIdentifier && imageExtension && imageExtension.length > 0) {
                                            fileName = [[NSString stringWithFormat:@"%@.%@", [asset.localIdentifier componentsSeparatedByString:@"/"].firstObject, imageExtension] encodeStringTo64];
                                        }
                                        
                                        if (fileName) {
                                            
                                            [photoDetails setObject:fileName forKey:@"Path"];
                                            
                                            NSInteger imageSize = [self caulateInsertImageMetaData:imageData withDate:asset.creationDate];
                                            
                                            [photoDetails setObject:[NSString stringWithFormat:@"%lu", (unsigned long)imageSize] forKey:@"Size"];
                                            
                                            NSArray *arr = [[NSArray alloc] initWithObjects:[cloudGroup.localizedTitle encodeStringTo64], nil];
                                            [photoDetails setObject:arr forKey:@"AlbumName"];
                                            
                                            if (asset.creationDate) {
                                                NSString *createDateStr = [NSDate stringFromDate:asset.creationDate];
                                                if (createDateStr.length > 0) {
                                                    [photoDetails setValue:createDateStr forKey:@"creationDate"];
                                                }
                                            }
                                            
                                            if (asset.isFavorite) {
                                                [photoDetails setValue:[NSNumber numberWithBool:asset.isFavorite] forKey:@"isFavorite"];
                                            }
                                            
                                            @synchronized (self) {
                                                [self.photoStreamSet addObject:photoDetails];
                                                [self.hashTableUrltofileName setObject:asset forKey:fileName];
                                            }
                                        }
                                        
                                    } else {
                                        @synchronized (self) {
                                            [self.unavailableCloudList addObject:[asset.localIdentifier componentsSeparatedByString:@"/"].firstObject];
                                            self.unavaliableCloudcount++;
                                        }
                                    }
                                    
                                    @synchronized (self) {
                                        if (++photoCollectingCount % 50 == 0) {
                                            [self.delegate shouldUpdatePhotoNumber:photoCollectingCount];
                                        }
                                        
                                        if (++streamPhotoCount == myPhotoStreamPhotos.count) { // last image
                                            _cloudPhotoFetchFinished = YES;
                                            _finished();
                                        }
                                    }
                                }];
                            }
                        } else {
                            // If it is not a live photo, do the plain fetch.
                            [[PHImageManager defaultManager] requestImageDataForAsset:asset options:imageRequesSetting resultHandler:^(NSData *imageData, NSString *dataUTI, UIImageOrientation orientation, NSDictionary *info) {
                                
                                if (imageData.length > 0 && info && asset) {
                                    
                                    NSString *fileName = nil;
                                    // Create info list for photo
                                    NSMutableDictionary *photoDetails = [[NSMutableDictionary alloc] init];
                                    
                                    NSString *imageExtension = nil;
                                    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"9.0")) {
                                        NSArray *resources = [PHAssetResource assetResourcesForAsset:asset];
                                        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.type == %d", PHAssetResourceTypePhoto];
                                        NSArray *filteredArray = [resources filteredArrayUsingPredicate:predicate];
                                        
                                        if (filteredArray.count > 0) {
                                            imageExtension = ((PHAssetResource *)[filteredArray objectAtIndex:0]).originalFilename;
                                        }
                                    }
                                    
                                    if (!imageExtension) {
                                        imageExtension = [self getFileName:(NSURL *)[info objectForKey:@"PHImageFileURLKey"]];
                                    }
                                    
                                    if (imageExtension) {
                                        imageExtension = [imageExtension pathExtension];
                                    }
                                    
                                    if (asset.localIdentifier && imageExtension && imageExtension.length > 0) {
                                        fileName = [[NSString stringWithFormat:@"%@.%@", [asset.localIdentifier componentsSeparatedByString:@"/"].firstObject, imageExtension] encodeStringTo64];
                                    }
                                    
                                    if (fileName) {
                                        
                                        [photoDetails setObject:fileName forKey:@"Path"];
                                        
                                        NSInteger imageSize = [self caulateInsertImageMetaData:imageData withDate:asset.creationDate];
                                        
                                        [photoDetails setObject:[NSString stringWithFormat:@"%lu", (unsigned long)imageSize] forKey:@"Size"];
                                        
                                        NSArray *arr = [[NSArray alloc] initWithObjects:[cloudGroup.localizedTitle encodeStringTo64], nil];
                                        [photoDetails setObject:arr forKey:@"AlbumName"];
                                        
                                        if (asset.creationDate) {
                                            NSString *createDateStr = [NSDate stringFromDate:asset.creationDate];
                                            if (createDateStr.length > 0) {
                                                [photoDetails setValue:createDateStr forKey:@"creationDate"];
                                            }
                                        }
                                        
                                        if (asset.isFavorite) {
                                            [photoDetails setValue:[NSNumber numberWithBool:asset.isFavorite] forKey:@"isFavorite"];
                                        }
                                        
                                        @synchronized (self) {
                                            [self.photoStreamSet addObject:photoDetails];
                                            [self.hashTableUrltofileName setObject:asset forKey:fileName];
                                        }
                                    }
                                    
                                } else {
                                    @synchronized (self) {
                                        [self.unavailableCloudList addObject:[asset.localIdentifier componentsSeparatedByString:@"/"].firstObject];
                                        self.unavaliableCloudcount++;
                                    }
                                }
                                
                                @synchronized (self) {
                                    if (++photoCollectingCount % 50 == 0) {
                                        [self.delegate shouldUpdatePhotoNumber:photoCollectingCount];
                                    }
                                    
                                    if (++streamPhotoCount == myPhotoStreamPhotos.count) { // last image
                                        _cloudPhotoFetchFinished = YES;
                                        _finished();
                                    }
                                }
                            }];
                        }
                    }
                }];
            } else { // No photos in My Photo Stream
                _cloudPhotoFetchFinished = YES;
                _finished();
            }
        }];
    } else { // Cloud not avaliable
        _cloudPhotoFetchFinished = YES;
        _finished();
    }
}

- (void)fetchImageInCustomAblum:(PHFetchOptions *)fetchSetting and:(PHImageRequestOptions *)imageRequesSetting finish:(void (^)(void))_finished
{
    PHFetchResult *customGroups = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum
                                                                           subtype:PHAssetCollectionSubtypeAlbumRegular
                                                                           options:nil];
    if (customGroups.count > 0) {
        __block int groupCount = 0;
        [customGroups enumerateObjectsUsingBlock:^(PHAssetCollection *customGroup, NSUInteger idx, BOOL *stop) {
            groupCount++;
            DebugLog(@"custom group:%@", customGroup.localizedTitle);
            
            *stop = [[CTDataCollectionManager sharedManager] isPhotosFetchingOperationCancelled];
            
            // Fetch all the images from My Photo Stream
            PHFetchResult *albumPhotos = [PHAsset fetchAssetsInAssetCollection:customGroup options:fetchSetting];
            if (albumPhotos.count > 0) {
                DebugLog(@"->reading %lu photos in this album", (unsigned long)albumPhotos.count);
                __block int assetCount = 0;
                __block int avalibleCount = 0;
                
                __block NSString *modifiedAlbumName;
                
                [albumPhotos enumerateObjectsUsingBlock:^(PHAsset *asset, NSUInteger index, BOOL *stop) {
                    
                    *stop = [[CTDataCollectionManager sharedManager] isPhotosFetchingOperationCancelled];
                    
                    @autoreleasepool {
                        
                        [[PHImageManager defaultManager] requestImageDataForAsset:asset options:imageRequesSetting resultHandler:^(NSData *imageData, NSString *dataUTI, UIImageOrientation orientation, NSDictionary *info) {
                            
                            if (imageData.length > 0 && info) {
                                // Create info list for photo
                                NSString *fileName = [[self getFileName:(NSURL *)[info objectForKey:@"PHImageFileURLKey"]] encodeStringTo64];
                                
                                if (fileName) {
                                    
                                    NSMutableDictionary *photoDetails = nil;
                                    @synchronized (self) {
                                        if ([[self.duplicateDict allKeys] containsObject:[customGroup.localizedTitle encodeStringTo64]] && (avalibleCount == 0)) {
                                            
                                            int value = [[self.duplicateDict valueForKey:[customGroup.localizedTitle encodeStringTo64]] intValue];
                                            
                                            value++;
                                            
                                            modifiedAlbumName = [NSString stringWithFormat:@"%@_VZ_%d",customGroup.localizedTitle,value];
                                            
                                            [self.duplicateDict setValue:[NSString stringWithFormat:@"%d",value] forKey:[modifiedAlbumName encodeStringTo64]];
                                            
                                        } else if (avalibleCount == 0) {
                                            
                                            [self.duplicateDict setValue:@"0" forKey:[customGroup.localizedTitle encodeStringTo64]];
                                            
                                            modifiedAlbumName = [NSString stringWithString:customGroup.localizedTitle];
                                        }
                                        
                                        
                                        if (![self.photoDic valueForKey:[asset.localIdentifier componentsSeparatedByString:@"/"].firstObject]) { // not exist
                                            photoDetails = [[NSMutableDictionary alloc] init];
                                            // Encode to to base64
                                            [photoDetails setObject:fileName forKey:@"Path"];
                                            NSInteger imageSize = [self caulateInsertImageMetaData:imageData withDate:asset.creationDate];
                                            
                                            [photoDetails setObject:[NSString stringWithFormat:@"%lu", (unsigned long)imageSize] forKey:@"Size"];
                                            
                                            NSArray *arr = [[NSArray alloc] initWithObjects:[modifiedAlbumName encodeStringTo64], nil];
                                            [photoDetails setObject:arr forKey:@"AlbumName"];
                                            
                                            if (asset.creationDate) {
                                                NSString *createDateStr = [NSDate stringFromDate:asset.creationDate];
                                                if (createDateStr.length > 0) {
                                                    [photoDetails setValue:createDateStr forKey:@"creationDate"];
                                                }
                                            }
                                            
                                            if (asset.isFavorite) {
                                                [photoDetails setValue:[NSNumber numberWithBool:asset.isFavorite] forKey:@"isFavorite"];
                                            }
                                            
                                            [self.photoDic setObject:photoDetails forKey:[asset.localIdentifier componentsSeparatedByString:@"/"].firstObject];
                                            //                                            [self.hashTableUrltofileName setObject:asset forKey:fileName];
                                        } else { // exist, only add new album
                                            photoDetails = [[self.photoDic objectForKey:[asset.localIdentifier componentsSeparatedByString:@"/"].firstObject] mutableCopy];
                                            
                                            NSMutableArray *arr = [[photoDetails objectForKey:@"AlbumName"] mutableCopy];
                                            
                                            [arr addObject:[modifiedAlbumName encodeStringTo64]];
                                            [photoDetails setObject:arr forKey:@"AlbumName"];
                                            [self.photoDic setObject:photoDetails forKey:[asset.localIdentifier componentsSeparatedByString:@"/"].firstObject];
                                        }
                                        
                                        avalibleCount++;
                                    }
                                }
                                
                            } else {
                                @synchronized (self) {
                                    [self.unavailableCloudList addObject:[asset.localIdentifier componentsSeparatedByString:@"/"].firstObject];
                                    self.unavaliableCloudcount ++;
                                }
                            }
                            
                            @synchronized (self) {
                                if (++photoCollectingCount % 50 == 0) {
                                    [self.delegate shouldUpdatePhotoNumber:photoCollectingCount];
                                }
                                
                                if (++assetCount == albumPhotos.count && groupCount == customGroups.count) {
                                    [self fetchImageInCameraRoll:fetchSetting and:imageRequesSetting finish:^{
                                        _localPhotoFetchFinished = YES;
                                        _finished();
                                    }];
                                }
                            }
                        }];
                    }
                }];
            } else if (groupCount == customGroups.count) { // last album
                [self fetchImageInCameraRoll:fetchSetting and:imageRequesSetting finish:^{
                    _localPhotoFetchFinished = YES;
                    _finished();
                }];
            }
        }];
    } else {
        [self fetchImageInCameraRoll:fetchSetting and:imageRequesSetting finish:^{
            _localPhotoFetchFinished = YES;
            _finished();
        }];
    }
}

- (void)fetchImageInCameraRoll:(PHFetchOptions *)fetchSetting and:(PHImageRequestOptions *)imageRequesSetting finish:(void (^)(void))_finished {
    __block BOOL smartFolderFound = NO;
    PHFetchResult *smartGroups = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum
                                                                          subtype:PHAssetCollectionSubtypeAny
                                                                          options:nil];
    [smartGroups enumerateObjectsUsingBlock:^(PHAssetCollection *smartGroup, NSUInteger idx, BOOL *stop) {
        
        *stop = [[CTDataCollectionManager sharedManager] isPhotosFetchingOperationCancelled];
        
        DebugLog(@"->Group localized title: %@", smartGroup.localizedTitle);
        
        if ([smartGroup.localizedTitle isEqualToString:CTLocalizedString(CT_CAMERA_ROLL_ALBUM, nil)] || ([smartGroup.localizedTitle isEqualToString:CTLocalizedString(CT_RECENTLY_ADDED_ALBUM, nil)] && SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(@"8.0"))) {
            smartFolderFound = YES;
            DebugLog(@"smart group:%@", smartGroup.localizedTitle);
            // Fetch all the images from Camera Roll
            PHFetchResult *smartPhotos = [PHAsset fetchAssetsInAssetCollection:smartGroup options:fetchSetting];
            if (smartPhotos.count > 0) {
                NSInteger totalPhotoCount = 0;
                for (PHAsset *asset in smartPhotos) {
                    if (asset.representsBurst) {
                        totalPhotoCount = totalPhotoCount + [PHAsset fetchAssetsWithBurstIdentifier:asset.burstIdentifier options:fetchSetting].count;
                    }else {
                        ++totalPhotoCount;
                    }
                }
                DebugLog(@"->reading %lu photos in this album", (unsigned long)smartPhotos.count);
                __block NSInteger assetCount = 0;
                [smartPhotos enumerateObjectsUsingBlock:^(PHAsset *asset, NSUInteger idx, BOOL *stop) {
                    
                    *stop = [[CTDataCollectionManager sharedManager] isPhotosFetchingOperationCancelled];
                    
                    @autoreleasepool {
                        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"9.1") && [[CTUserDevice userDevice].phoneCombination isEqualToString:IOS_IOS] && asset.mediaSubtypes == PHAssetMediaSubtypePhotoLive) {
                            // It's a live photo, need to add extra information into file list. (Only work for iOS 9.1)
                            CTLivePhoto *livePhoto = [[CTLivePhoto alloc] initWith:asset];
                            if ([livePhoto isValidLivePhoto]) { // If it's invalid, then keep the old file list; otherwise make change of file list.
                                @synchronized (self) {
                                    if (![self.photoDic valueForKey:livePhoto.identifier]) { // not exist
                                        [livePhoto generateDict];
                                        // Recalulate the size of image.
                                        [livePhoto getImageDataWithCompletion:^(NSData * _Nullable data) {
                                            if (data && data.length > 0) {
                                                NSInteger imageSize = [self caulateInsertImageMetaData:data withDate:asset.creationDate];
                                                [livePhoto updateFileSizeWithNewImageSize:imageSize];
                                                // Add info into file list
                                                NSMutableDictionary *info = [livePhoto.info mutableCopy];
                                                if ([[CTUserDevice userDevice].phoneCombination isEqualToString:IOS_IOS]) { // Only for iOS to iOS
                                                    [info setObject:[NSString stringWithFormat:@"%lu", (unsigned long)orderNumber++] forKey:@"Order"];
                                                }
                                                [self.photoDic setObject:info forKey:livePhoto.identifier];
                                                info = nil; // Release
                                                // Add hash for transfer file retrieve
                                                [self.hashTableUrltofileName setObject:livePhoto forKey:livePhoto.encryptName];
                                            } else {
                                                NSLog(@"Error happened when fetching image data for live photo. Should not add into file list, because it's not able to fetch the actual data to transfer.");
                                            }
                                            
                                            // Update for 1 image
                                            [self updateCountForSmartFolder:++assetCount andTotalCount:totalPhotoCount withSynchronized:YES finish:_finished];
                                        }];
                                    } else { // exist already, update key-value
                                        NSMutableDictionary *photoInfo = [(NSDictionary *)[self.photoDic objectForKey:livePhoto.identifier] mutableCopy];
                                        if ([[CTUserDevice userDevice].phoneCombination isEqualToString:IOS_IOS]) { // Only for iOS to iOS
                                            [photoInfo setObject:[NSString stringWithFormat:@"%lu", (unsigned long)orderNumber++] forKey:@"Order"];
                                        }
//                                        NSString *photoFileName = [photoInfo valueForKey:@"Path"];
                                        
                                        [livePhoto updateDictFor:photoInfo];
                                        [self.photoDic setObject:livePhoto.info forKey:livePhoto.identifier];
                                        // Update hash table for retrieve data
//                                        [self.hashTableUrltofileName removeObjectForKey:photoFileName];
                                        [self.hashTableUrltofileName setObject:livePhoto forKey:livePhoto.encryptName];
                                        
                                        // Update for 1 image
                                        [self updateCountForSmartFolder:++assetCount andTotalCount:totalPhotoCount withSynchronized:YES finish:_finished];
                                    }
                                }
                            } else { // is not valid live photo, use old way to fetch plain photos.
                                livePhoto = nil; // Reset live photo object
                                [self plainPhotoFetchForSmartFolder:asset
                                                            options:imageRequesSetting
                                                       isCameraRoll:YES
                                                         assetCount:&assetCount
                                                         totalCount:totalPhotoCount
                                                             finish:_finished];
                            }
                        } else {
                            // If it is not a live photo, do the plain fetch.
                            if (asset.representsBurst) {// If it is burst photo fetch all assets inside it and treat them as plain photos
                                PHFetchResult *burstAssets = [PHAsset fetchAssetsWithBurstIdentifier:asset.burstIdentifier options:fetchSetting];
                                for (PHAsset *burstAsset in burstAssets) {
                                    [self plainPhotoFetchForSmartFolder:burstAsset
                                                                options:imageRequesSetting
                                                           isCameraRoll:YES
                                                             assetCount:&assetCount
                                                             totalCount:totalPhotoCount
                                                                 finish:_finished];
                                }

                            }else {
                                [self plainPhotoFetchForSmartFolder:asset
                                                            options:imageRequesSetting
                                                       isCameraRoll:YES
                                                         assetCount:&assetCount
                                                         totalCount:totalPhotoCount
                                                             finish:_finished];
                            }
                        }
                    }
                }];
            } else { // No Photos
                _finished ();
            }
            
            *stop = YES;
        } else if ([smartGroup.localizedTitle isEqualToString:CTLocalizedString(CT_ALL_PHOTOS_ALBUM, nil)]) {
            smartFolderFound = YES;
            self.allPhotos = YES;
            // Fetch all the images from "All Photo" folder
            PHFetchResult *smartPhotos = [PHAsset fetchAssetsInAssetCollection:smartGroup options:fetchSetting];
            if (smartPhotos.count > 0) {
                __block NSInteger assetCount = 0;
                [smartPhotos enumerateObjectsUsingBlock:^(PHAsset *asset, NSUInteger idx, BOOL *stop) {
                    
                    *stop = [[CTDataCollectionManager sharedManager] isPhotosFetchingOperationCancelled];
                    
                    @autoreleasepool {
                        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"9.1") && [[CTUserDevice userDevice].phoneCombination isEqualToString:IOS_IOS] && asset.mediaSubtypes == PHAssetMediaSubtypePhotoLive) {
                            // It's a live photo, need to add extra information into file list. (Only work for iOS 9.1)
                            CTLivePhoto *livePhoto = [[CTLivePhoto alloc] initWith:asset];
                            if ([livePhoto isValidLivePhoto]) { // If it's invalid, then keep the old file list; otherwise make change of file list.
                                @synchronized (self) {
                                    if (![self.photoDic valueForKey:livePhoto.identifier]) { // not exist
                                        [livePhoto generateDict];
                                        // Recalulate the size of image.
                                        [livePhoto getImageDataWithCompletion:^(NSData * _Nullable data) {
                                            if (data && data.length > 0) {
                                                NSInteger imageSize = [self caulateInsertImageMetaData:data withDate:asset.creationDate];
                                                [livePhoto updateFileSizeWithNewImageSize:imageSize];
                                                // Add info into file list
                                                NSMutableDictionary *info = [livePhoto.info mutableCopy];
                                                if ([[CTUserDevice userDevice].phoneCombination isEqualToString:IOS_IOS]) { // Only for iOS to iOS
                                                    [info setObject:[NSString stringWithFormat:@"%lu", (unsigned long)orderNumber++] forKey:@"Order"];
                                                }
                                                [self.photoDic setObject:info forKey:livePhoto.identifier];
                                                info = nil;
                                                // Add hash for transfer file retrieve
                                                [self.hashTableUrltofileName setObject:livePhoto forKey:livePhoto.encryptName];
                                            } else {
                                                if (![self.unavailableCloudList containsObject:[asset.localIdentifier componentsSeparatedByString:@"/"].firstObject]) { // Only add count that is not showing in any custom folders.
                                                    self.unavaliableCloudcount++;
                                                }
                                                NSLog(@"Error happened when fetching image data for live photo. Should not add into file list, because it's not able to fetch the actual data to transfer.");
                                            }
                                            
                                            // Update for 1 image
                                            [self updateCountForSmartFolder:++assetCount andTotalCount:smartPhotos.count withSynchronized:YES finish:_finished];
                                        }];
                                    } else { // exist already, update key-value
                                        NSMutableDictionary *photoInfo = [(NSDictionary *)[self.photoDic objectForKey:livePhoto.identifier] mutableCopy];
//                                        NSString *photoFileName = [photoInfo valueForKey:@"Path"];
                                        if ([[CTUserDevice userDevice].phoneCombination isEqualToString:IOS_IOS]) { // Only for iOS to iOS
                                            [photoInfo setObject:[NSString stringWithFormat:@"%lu", (unsigned long)orderNumber++] forKey:@"Order"];
                                        }
                                        [livePhoto updateDictFor:photoInfo];
                                        [self.photoDic setObject:livePhoto.info forKey:livePhoto.identifier];
                                        // Update hash table for retrieve data
//                                        [self.hashTableUrltofileName removeObjectForKey:photoFileName];
                                        [self.hashTableUrltofileName setObject:livePhoto forKey:livePhoto.encryptName];
                                        
                                        // Update for 1 image
                                        [self updateCountForSmartFolder:++assetCount andTotalCount:smartPhotos.count withSynchronized:YES finish:_finished];
                                    }
                                }
                            } else { // is not valid live photo, use old way to fetch plain photos.
                                livePhoto = nil; // Reset live photo object
                                [self plainPhotoFetchForSmartFolder:asset
                                                            options:imageRequesSetting
                                                       isCameraRoll:NO
                                                         assetCount:&assetCount
                                                         totalCount:smartPhotos.count
                                                             finish:_finished];
                            }
                        } else {
                            [self plainPhotoFetchForSmartFolder:asset
                                                        options:imageRequesSetting
                                                   isCameraRoll:NO
                                                     assetCount:&assetCount
                                                     totalCount:smartPhotos.count
                                                         finish:_finished];
                        }
                    }
                }];
            } else { // No Photos
                _finished ();
            }
            
            *stop = YES;
        }
    }];
    
    if (!smartFolderFound) {
        // None of target folders are found, return return 0 instead of blocking the user
        NSLog(@"No target smart folder found for photo on current device.");
        [self.photoDic removeAllObjects];
        _finished();
    }
}

- (void)plainPhotoFetchForSmartFolder:(PHAsset *)asset
                              options:(PHImageRequestOptions *)options
                         isCameraRoll:(BOOL)isCameraRoll
                           assetCount:(NSInteger *)assetCount
                           totalCount:(NSInteger)totalCount
                               finish:(void (^)(void))_finished {
    [[PHImageManager defaultManager] requestImageDataForAsset:asset options:options resultHandler:^(NSData *imageData, NSString *dataUTI, UIImageOrientation orientation, NSDictionary *info) {
        if (imageData.length > 0 && info) {
            // Create info list for photo
            NSString *imageExtension = nil;
            if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"9.0")) {
                NSArray *resources = [PHAssetResource assetResourcesForAsset:asset];
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.type == %d", PHAssetResourceTypePhoto];
                NSArray *filteredArray = [resources filteredArrayUsingPredicate:predicate];
                
                if (filteredArray.count > 0) {
                    imageExtension = ((PHAssetResource *)[filteredArray objectAtIndex:0]).originalFilename;
                }
            }
            
            if (!imageExtension) {
                imageExtension = [self getFileName:(NSURL *)[info objectForKey:@"PHImageFileURLKey"]];
            }
            
            if (imageExtension) {
                imageExtension = [imageExtension pathExtension];
            }
            
            if (asset.localIdentifier && imageExtension && imageExtension.length > 0) {
                NSString *fileName = [[NSString stringWithFormat:@"%@.%@", [asset.localIdentifier componentsSeparatedByString:@"/"].firstObject, imageExtension] encodeStringTo64];
//                NSLog(@"->File name: %@", fileName);
//                NSLog(@"->File identifier: %@", asset.localIdentifier);
                NSMutableDictionary *photoDetails = nil;
                @synchronized (self) {
                    if (![self.photoDic valueForKey:asset.localIdentifier]) { // not exist
                        photoDetails = [[NSMutableDictionary alloc] init];
                        [photoDetails setObject:fileName forKey:@"Path"];
                        NSInteger imageSize = [self caulateInsertImageMetaData:imageData withDate:asset.creationDate];
                        
                        [photoDetails setObject:[NSString stringWithFormat:@"%lu", (unsigned long)imageSize] forKey:@"Size"];
                        
                        if ([[CTUserDevice userDevice].phoneCombination isEqualToString:IOS_Andriod]) {
                            [photoDetails setObject:@[[@"Camera Roll" encodeStringTo64]] forKey:@"AlbumName"];
                        } else if ([[CTUserDevice userDevice].phoneCombination isEqualToString:IOS_IOS]) { // Only for iOS to iOS
                            [photoDetails setObject:[NSString stringWithFormat:@"%lu", (unsigned long)orderNumber++] forKey:@"Order"];
                        }
                        
                        if (asset.creationDate) {
                            NSString *createDateStr = [NSDate stringFromDate:asset.creationDate];
                            if (createDateStr.length > 0) {
                                [photoDetails setValue:createDateStr forKey:@"creationDate"];
                            }
                        }
                        
                        if (asset.isFavorite) {
                            [photoDetails setValue:[NSNumber numberWithBool:asset.isFavorite] forKey:@"isFavorite"];
                        }
                        
                        
                        [self.photoDic setObject:photoDetails forKey:[asset.localIdentifier componentsSeparatedByString:@"/"].firstObject];
                        [self.hashTableUrltofileName setObject:asset forKey:fileName];
                    } else {
                        photoDetails = [[self.photoDic objectForKey:[asset.localIdentifier componentsSeparatedByString:@"/"].firstObject] mutableCopy];
//                        [self.hashTableUrltofileName removeObjectForKey:[photoDetails objectForKey:@"Path"]];
                        [photoDetails setObject:fileName forKey:@"Path"];
                        if ([[CTUserDevice userDevice].phoneCombination isEqualToString:IOS_IOS]) { // Only for iOS to iOS
                            [photoDetails setObject:[NSString stringWithFormat:@"%lu", (unsigned long)orderNumber++] forKey:@"Order"];
                        }
                        [self.photoDic setObject:photoDetails forKey:[asset.localIdentifier componentsSeparatedByString:@"/"].firstObject];
                        [self.hashTableUrltofileName setObject:asset forKey:fileName];
                        
                    }
                }
            }
        } else if (!isCameraRoll) { // It's not camera roll
            @synchronized (self) {
                if (![self.unavailableCloudList containsObject:[asset.localIdentifier componentsSeparatedByString:@"/"].firstObject]) { // Only add count that is not showing in any custom folders.
                    self.unavaliableCloudcount++;
                }
            }
        }
        
        [self updateCountForSmartFolder:++*assetCount andTotalCount:totalCount withSynchronized:NO finish:_finished];
        
//        NSLog(@"================");
    }];
}

- (void)updateCountForSmartFolder:(NSInteger)assetCount andTotalCount:(NSInteger)totalCount withSynchronized:(BOOL)isSynchronized finish:(void (^)(void))_finished {
    if (isSynchronized) {
        if (++photoCollectingCount % 50 == 0) {
            [self.delegate shouldUpdatePhotoNumber:photoCollectingCount];
        }
        
        if (assetCount == totalCount) { // last photo
            _finished();
        }
    } else {
        @synchronized (self) {
            if (++photoCollectingCount % 50 == 0) {
                [self.delegate shouldUpdatePhotoNumber:photoCollectingCount];
            }
            
            if (assetCount == totalCount) { // last photo
                _finished();
            }
        }
    }
}

- (NSString *)getFileName:(NSURL *)url
{
    return [url lastPathComponent];
}

#pragma mark - OLD PHOTO LIBRARY
- (void)fetchPhotosUsingOldPhotoLibrary:(void(^)(NSInteger photoCount, NSInteger streamCount, NSInteger unavailableCount, BOOL isAllPhotos))completionHandler onFailure:(void(^)(NSString * errorMsg))failureHandler {
    
    if (!self.assetsLibrary) {
        self.assetsLibrary = [[ALAssetsLibrary alloc] init];
    }
    
    __weak typeof(self) weakSelf = self;
    [self fetchALAssetCloudPhotosSuccess:^{
        
        [weakSelf mergeAllPhotos];
        
        if ([NSJSONSerialization isValidJSONObject:weakSelf.photoListSuperSet]) {
            // photo list is a valid Json object, transfer list to data.
            
            NSData *photoData = [NSJSONSerialization dataWithJSONObject:weakSelf.photoListSuperSet options:NSJSONWritingPrettyPrinted error:nil];
            
            NSFileManager *fileManager = [NSFileManager defaultManager];
            [fileManager createFileAtPath:photoLogfilepath contents:photoData attributes: nil];
            
            completionHandler(weakSelf.photoListSuperSet.count, weakSelf.photoStreamSet.count, 0, NO);
        } else {
            // photo list is not a valid object
            failureHandler(@"Error happened when fetching photos using old library.");
        }
    } andFailure:^(NSError *error) {
        NSString *errMsg = [weakSelf createErrMsg:error];
        failureHandler(errMsg);
        
    }];
}

- (NSString*)createErrMsg:(NSError *)error
{
    NSString *errorMessage = nil;
    switch ([error code]) {
        case ALAssetsLibraryAccessUserDeniedError: {
            errorMessage = @"The user has declined access to it.";
            return errorMessage;
            //self.fetchfailure(errorMessage, YES);
        }
            break;
        case ALAssetsLibraryAccessGloballyDeniedError: {
            errorMessage = @"The app setting without photo permission.";
            //self.fetchfailure(errorMessage, YES);
            return errorMessage;
            
        }
            break;
        default:
            errorMessage = @"Reason unknown.";
            //self.fetchfailure(errorMessage, NO);
            return errorMessage;
            
            break;
    }
}

- (void)fetchALAssetCloudPhotosSuccess:(void (^)(void))success andFailure:(void (^)(NSError *))failure
{
    // enumerate only photos in cloud
    __weak typeof(self) weakSelf = self;
    [self.assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupPhotoStream usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        
        *stop = [[CTDataCollectionManager sharedManager] isPhotosFetchingOperationCancelled];
        
        if (group == nil) { // when fetch ends, return a group = nil
            [weakSelf fetchALAssetLocalPhotoInCustomAlbumSuccess:success andFailure:failure];
            return;
        }
        
        [group setAssetsFilter:[ALAssetsFilter allPhotos]];
        if ([group numberOfAssets] > 0) {
            
            // enumerate photo assets
            [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                
                *stop = [[CTDataCollectionManager sharedManager] isPhotosFetchingOperationCancelled];
                
                if (result) {
                    NSString * fileName = [result.defaultRepresentation.filename encodeStringTo64];
                    NSMutableDictionary *photoDetails = [[NSMutableDictionary alloc] init];
                    
                    [photoDetails setObject:fileName forKey:@"Path"];
                    [photoDetails setObject:[NSString stringWithFormat:@"%lld",result.defaultRepresentation.size] forKey:@"Size"];
                    
                    NSArray *arr = [[NSArray alloc] initWithObjects:[[group valueForProperty:ALAssetsGroupPropertyName] encodeStringTo64], nil];
                    [photoDetails setObject:arr forKey:@"AlbumName"];
                    
                    //                    NSDictionary *metada = result.defaultRepresentation.metadata;
                    
                    //                    if (![metada valueForKey:@"{GPS}"]) {
                    if ([result valueForProperty:ALAssetPropertyDate]) {
                        NSString *createDateStr = [NSDate stringFromDate:[result valueForProperty:ALAssetPropertyDate]];
                        if (createDateStr.length > 0) {
                            [photoDetails setValue:createDateStr forKey:@"creationDate"];
                        }
                    }
                    //                   }
                    
                    [weakSelf.photoStreamSet addObject:photoDetails];
                    [weakSelf.hashTableUrltofileName setObject:result forKey:fileName];
                    
                    if (++photoCollectingCount % 50 == 0) {
                        [weakSelf.delegate shouldUpdatePhotoNumber:photoCollectingCount];
                    }
                } else {
                    DebugLog(@"Done ..got all photo from assets in the assets group ...:%@", [group valueForProperty:ALAssetsGroupPropertyName]);
                }
            }];
        }
        
    } failureBlock:^(NSError *error) {
        failure(error);
    }];
}

- (void)fetchALAssetLocalPhotoInCustomAlbumSuccess:(void (^)(void))success andFailure:(void (^)(NSError *))failure
{
    // enumerate only photos in album
    __weak typeof(self) weakSelf = self;
    __block NSString *modifiedAlbumName;
    [self.assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAlbum | ALAssetsGroupLibrary usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        
        *stop = [[CTDataCollectionManager sharedManager] isPhotosFetchingOperationCancelled];
        
        if (group == nil) { // when fetch ends, return a group = nil
            [weakSelf fetchALAssetLocalPhotoInCameraRoll:success andFailure:failure];
            return;
        }
        
        [group setAssetsFilter:[ALAssetsFilter allPhotos]];
        if ([group numberOfAssets] > 0) {
            
            // enumerate photo assets
            [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                
                *stop = [[CTDataCollectionManager sharedManager] isPhotosFetchingOperationCancelled];
                
                if (result) {
                    NSString * fileName = [result.defaultRepresentation.filename encodeStringTo64];
                    
                    if ([[self.duplicateDict allKeys] containsObject:[[group valueForProperty:ALAssetsGroupPropertyName] encodeStringTo64]] && (index == 0)) {
                        
                        int value = [[self.duplicateDict valueForKey:[[group valueForProperty:ALAssetsGroupPropertyName] encodeStringTo64]] intValue];
                        
                        value++;
                        
                        modifiedAlbumName = [NSString stringWithFormat:@"%@_VZ_%d",[group valueForProperty:ALAssetsGroupPropertyName],value];
                        
                        [self.duplicateDict setValue:[NSString stringWithFormat:@"%d",value] forKey:[modifiedAlbumName encodeStringTo64]];
                        
                    } else if (index == 0){
                        
                        [self.duplicateDict setValue:@"0" forKey:[[group valueForProperty:ALAssetsGroupPropertyName] encodeStringTo64]];
                        
                        modifiedAlbumName = [NSString stringWithString:[group valueForProperty:ALAssetsGroupPropertyName]];
                    }
                    
                    
                    if (![weakSelf.photoDic objectForKey:fileName]) {
                        NSMutableDictionary *photoDetails = [[NSMutableDictionary alloc] init];
                        
                        [photoDetails setObject:fileName forKey:@"Path"];
                        [photoDetails setObject:[NSString stringWithFormat:@"%lld",result.defaultRepresentation.size] forKey:@"Size"];
                        
                        NSArray *arr = [[NSArray alloc] initWithObjects:[[group valueForProperty:ALAssetsGroupPropertyName] encodeStringTo64], nil];
                        [photoDetails setObject:arr forKey:@"AlbumName"];
                        
                        //                        NSDictionary *metada = result.defaultRepresentation.metadata;
                        
                        //                        if (![metada valueForKey:@"{GPS}"]) {
                        if ([result valueForProperty:ALAssetPropertyDate]) {
                            NSString *createDateStr = [NSDate stringFromDate:[result valueForProperty:ALAssetPropertyDate]];
                            if (createDateStr.length > 0) {
                                [photoDetails setValue:createDateStr forKey:@"creationDate"];
                            }
                        }
                        //                        }
                        
                        [weakSelf.photoDic setObject:photoDetails forKey:fileName];
                        [weakSelf.hashTableUrltofileName setObject:result forKey:fileName];
                        
                        if (++photoCollectingCount % 50 == 0) {
                            [self.delegate shouldUpdatePhotoNumber:photoCollectingCount];
                        }
                    } else { // exist, update photo folder info
                        NSMutableDictionary *photoDetails = [[self.photoDic objectForKey:fileName] mutableCopy];
                        
                        NSMutableArray *arr = [[photoDetails objectForKey:@"AlbumName"] mutableCopy];
                        
                        //                        [arr addObject:[self encodeStringTo64:[group valueForProperty:ALAssetsGroupPropertyName]]];
                        [arr addObject:[modifiedAlbumName encodeStringTo64]];
                        
                        [photoDetails setObject:arr forKey:@"AlbumName"];
                        [weakSelf.photoDic setObject:photoDetails forKey:fileName];
                    }
                } else {
                    DebugLog(@"Done ..got all photo from assets in the assets group ...:%@", [group valueForProperty:ALAssetsGroupPropertyName]);
                }
            }];
        }
        
    } failureBlock:^(NSError *error) {
        failure(error);
    }];
}

- (void)fetchALAssetLocalPhotoInCameraRoll:(void (^)(void))success andFailure:(void (^)(NSError *))failure
{
    // enumerate only photos in camera roll
    __weak typeof(self) weakSelf = self;
    [self.assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        
        *stop = [[CTDataCollectionManager sharedManager] isPhotosFetchingOperationCancelled];
        
        if (group == nil) { // when fetch ends, return a group = nil
            success();
            return;
        }
        
        [group setAssetsFilter:[ALAssetsFilter allPhotos]];
        if ([group numberOfAssets] > 0) {
            
            // enumerate photo assets
            [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                
                *stop = [[CTDataCollectionManager sharedManager] isPhotosFetchingOperationCancelled];
                
                if (result) {
                    NSString * fileName = [result.defaultRepresentation.filename encodeStringTo64];
                    if (![weakSelf.photoDic objectForKey:fileName]) {
                        NSMutableDictionary *photoDetails = [[NSMutableDictionary alloc] init];
                        
                        [photoDetails setObject:fileName forKey:@"Path"];
                        [photoDetails setObject:[NSString stringWithFormat:@"%lld",result.defaultRepresentation.size] forKey:@"Size"];
                        
                        if ([[CTUserDevice userDevice].phoneCombination isEqualToString:IOS_Andriod]) {
                            [photoDetails setObject:@[[@"Camera Roll" encodeStringTo64]] forKey:@"AlbumName"];
                        }
                        
                        //                        NSDictionary *metada = result.defaultRepresentation.metadata;
                        
                        //                        if (![metada valueForKey:@"{GPS}"]) {
                        if ([result valueForProperty:ALAssetPropertyDate]) {
                            NSString *createDateStr = [NSDate stringFromDate:[result valueForProperty:ALAssetPropertyDate]];
                            if (createDateStr.length > 0) {
                                [photoDetails setValue:createDateStr forKey:@"creationDate"];
                            }
                        }
                        //                        }
                        
                        // photo doesnt support favorite feature
                        
                        [weakSelf.photoDic setObject:photoDetails forKey:fileName];
                        [weakSelf.hashTableUrltofileName setObject:result forKey:fileName];
                        
                        if (++photoCollectingCount % 50 == 0) {
                            [weakSelf.delegate shouldUpdatePhotoNumber:photoCollectingCount];
                        }
                    }
                } else {
                    DebugLog(@"Done ..got all photo from assets in the assets group ...:%@", [group valueForProperty:ALAssetsGroupPropertyName]);
                }
            }];
        }
        
    } failureBlock:^(NSError *error) {
        failure(error);
    }];
}

#pragma mark - Video Fetching

- (void)mergeAllVideos {
    
    //    NSLog(@"->video hash count:%d(%d)", self.hashTableUrltofileName.count, self.photoDic.count + self.videoDic.count);
    [self.videoListSuperSet addObjectsFromArray:[self.videoDic allValues]];
    
    if (([self.videoStreamSet count] > 0) && ([[CTUserDevice userDevice].phoneCombination isEqualToString:IOS_Andriod])) {
        [self.videoListSuperSet addObjectsFromArray:self.videoStreamSet];
    }
}

#pragma mark - NEW PHOTO LIBRARY FETCH VIDEO (__IPHONE_8_0)
- (void)fetchVideosUsingNewPhotoLibrary:(void(^)(NSInteger videoCount, NSInteger streamCount, NSInteger unavailableCount, BOOL isAllPhotoVideo))completionHandler onFailure:(void(^)(NSString * errorMsg))failureHandler
{
    DebugLog(@"video start:%@", self.hashTableUrltofileName);
    
    // Globle pram
    // Group image filter Option
    PHFetchOptions *onlyVideosOptions = [PHFetchOptions new];
    onlyVideosOptions.predicate = [NSPredicate predicateWithFormat:@"mediaType = %i", PHAssetMediaTypeVideo];
    
    // Image request option
    PHVideoRequestOptions * VideoRequestOptions = [[PHVideoRequestOptions alloc] init];
    VideoRequestOptions.version = PHVideoRequestOptionsVersionOriginal;
    
    // Read iCloud Photos
    [self fetchVideoInMyPhotoStream:onlyVideosOptions and:VideoRequestOptions finish:^{
        DebugLog(@"fetching my photo stream video finish");
        
        [self finishFetchingVideos:completionHandler onFailure:failureHandler];
    }];
    
    // Read All photos from custom ablums
    [self fetchVideoInCustomAblum:onlyVideosOptions and:VideoRequestOptions finish:^{
        DebugLog(@"fetching ablum video done!");
        
        [self finishFetchingVideos:completionHandler onFailure:failureHandler];
    }];
}

- (void)fetchVideoInMyPhotoStream:(PHFetchOptions *)fetchSetting and:(PHVideoRequestOptions *)videoRequesSetting finish:(void (^)(void))_finished
{
    PHFetchResult *cloudGroups = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum
                                                                          subtype:PHAssetCollectionSubtypeAlbumMyPhotoStream
                                                                          options:nil];
    if (cloudGroups.count > 0) {
        [cloudGroups enumerateObjectsUsingBlock:^(PHAssetCollection *cloudGroup, NSUInteger idx, BOOL *stop) {
            
            *stop = [[CTDataCollectionManager sharedManager] isVideosFetchingOperationCancelled];
            
            //            DebugLog(@"cloud group:%@", cloudGroup.localizedTitle);
            // Fetch all the images from My Photo Stream
            PHFetchResult *myPhotoStreamVideos = [PHAsset fetchAssetsInAssetCollection:cloudGroup options:fetchSetting];
            
            if (myPhotoStreamVideos.count > 0) {
                //                    DebugLog(@"->reading %lu videos in this album", (unsigned long)myPhotoStreamVideos.count);
                
                __block int videoCount = 0;
                [myPhotoStreamVideos enumerateObjectsUsingBlock:^(PHAsset *assetPh, NSUInteger idx, BOOL *stop) {
                    
                    *stop = [[CTDataCollectionManager sharedManager] isVideosFetchingOperationCancelled];
                    
                    [[PHImageManager defaultManager] requestAVAssetForVideo:assetPh options:videoRequesSetting resultHandler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
                        
                        if (asset && info) { // not cloud data
                            if ([asset isKindOfClass:[AVURLAsset class]]) {
                                AVURLAsset* urlAsset = (AVURLAsset*)asset;
                                
                                if([self isVideoCreateTimeMissing:urlAsset])
                                {
                                    [self insertCreateTime:urlAsset withTime:urlAsset.creationDate];
                                }
                                
                                // Create info list for photo
                                NSString *fileName = [[self getFileName:urlAsset.URL] encodeStringTo64];
                                
                                // Get the videoSize
                                NSNumber *size;
                                
                                
                                [urlAsset.URL getResourceValue:&size forKey:NSURLFileSizeKey error:nil];
                                //                                    DebugLog(@"size is %f",[size floatValue]);
                                
                                NSMutableDictionary *videoDetails = [[NSMutableDictionary alloc] init];
                                [videoDetails setObject:fileName forKey:@"Path"];
                                [videoDetails setObject:[NSString stringWithFormat:@"%lld", [size longLongValue]] forKey:@"Size"];
                                
                                if (asset.creationDate.dateValue && !assetPh.location) {
                                    NSString *createDateStr = [NSDate stringFromDate:asset.creationDate.dateValue];
                                    if (createDateStr.length > 0) {
                                        [videoDetails setValue:createDateStr forKey:@"creationDate"];
                                    }
                                }
                                
                                if (assetPh.isFavorite) {
                                    [videoDetails setValue:[NSNumber numberWithBool:assetPh.isFavorite] forKey:@"isFavorite"];
                                }
                                
                                NSArray *arr = [[NSArray alloc] initWithObjects:[cloudGroup.localizedTitle encodeStringTo64], nil];
                                [videoDetails setObject:arr forKey:@"AlbumName"];
                                
                                @synchronized (self) {
                                    [self.videoStreamSet addObject:videoDetails];
                                    [self.hashTableUrltofileName setObject:urlAsset forKey:fileName];
                                    
                                    if (++videoCollectionCount % 50 == 0) {
                                        [self.delegate shouldUpdateVideoNumber:videoCollectionCount];
                                    }
                                }
                            }
                        } else {
                            @synchronized (self) {
                                self.unavaliableVideoCloudcount++;
                                [self.unavailableCloudList addObject:[assetPh.localIdentifier componentsSeparatedByString:@"/"].firstObject];
                                
                                if (++videoCollectionCount % 50 == 0) {
                                    [self.delegate shouldUpdateVideoNumber:videoCollectionCount];
                                }
                            }
                        }
                        
                        @synchronized (self) {
                            if (++videoCount == myPhotoStreamVideos.count) { // last image
                                _cloudVideoFetchFinished = YES;
                                _finished();
                            }
                        }
                        
                    }];
                }];
            } else { // No videos in My Photo Stream
                _cloudVideoFetchFinished = YES;
                _finished();
            }
        }];
    } else { // Cloud not avaliable
        _cloudVideoFetchFinished = YES;
        _finished();
    }
}

- (void)fetchVideoInCustomAblum:(PHFetchOptions *)fetchSetting and:(PHVideoRequestOptions *)videoRequesSetting finish:(void (^)(void))_finished
{
    PHFetchResult *customGroups = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum
                                                                           subtype:PHAssetCollectionSubtypeAlbumRegular
                                                                           options:nil];
    if (customGroups.count > 0) {
        __block int groupsCount = 0;
        [customGroups enumerateObjectsUsingBlock:^(PHAssetCollection *customGroup, NSUInteger idx, BOOL *stop) {
            
            *stop = [[CTDataCollectionManager sharedManager] isVideosFetchingOperationCancelled];
            
            DebugLog(@"custom group:%@", customGroup.localizedTitle);
            // Fetch all the images from My Photo Stream
            PHFetchResult *albumVideos = [PHAsset fetchAssetsInAssetCollection:customGroup options:fetchSetting];
            if (albumVideos.count > 0) {
                DebugLog(@"->reading %lu videos in this album", (unsigned long)albumVideos.count);
                __block int videoCount = 0;
                __block int availableVideoCount = 0;
                __block NSString *modifiedAlbumName;
                
                [albumVideos enumerateObjectsUsingBlock:^(PHAsset *assetPh, NSUInteger index, BOOL *stop) {
                    
                    *stop = [[CTDataCollectionManager sharedManager] isVideosFetchingOperationCancelled];
                    
                    [[PHImageManager defaultManager] requestAVAssetForVideo:assetPh options:videoRequesSetting resultHandler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
                        
                        if (asset && info) { // not cloud data
                            if ([asset isKindOfClass:[AVURLAsset class]]) {
                                AVURLAsset* urlAsset = (AVURLAsset*)asset;
                                if([self isVideoCreateTimeMissing:urlAsset])
                                {
                                    [self insertCreateTime:urlAsset withTime:urlAsset.creationDate];
                                }
                                
                                // Create info list for photo
                                NSString *fileName = [[self getFileName:urlAsset.URL] encodeStringTo64];
                                
                                // Get the videoSize
                                NSNumber *size;
                                [urlAsset.URL getResourceValue:&size forKey:NSURLFileSizeKey error:nil];
                                //                                    DebugLog(@"size is %lld",[size longLongValue]);
                                
                                NSMutableDictionary *videoDetails = nil;
                                @synchronized (self) {
                                    
                                    if ([[self.duplicateDict allKeys] containsObject:[customGroup.localizedTitle encodeStringTo64]] && (availableVideoCount == 0)) {
                                        
                                        int value = [[self.duplicateDict valueForKey:[customGroup.localizedTitle encodeStringTo64]] intValue];
                                        
                                        value++;
                                        
                                        modifiedAlbumName = [NSString stringWithFormat:@"%@_VZ_%d",customGroup.localizedTitle,value];
                                        
                                        [self.duplicateDict setValue:[NSString stringWithFormat:@"%d",value] forKey:[modifiedAlbumName encodeStringTo64]];
                                        
                                    } else if (availableVideoCount == 0){
                                        
                                        [self.duplicateDict setValue:@"0" forKey:[customGroup.localizedTitle encodeStringTo64]];
                                        
                                        modifiedAlbumName = [NSString stringWithString:customGroup.localizedTitle];
                                    }
                                    
                                    
                                    if (![self.videoDic valueForKey:fileName]) { // not exist
                                        //                                            DebugLog(@"add into dic");
                                        videoDetails = [[NSMutableDictionary alloc] init];
                                        [videoDetails setObject:fileName forKey:@"Path"];
                                        [videoDetails setObject:[NSString stringWithFormat:@"%lld", [size longLongValue]] forKey:@"Size"];
                                        
                                        NSArray *arr = [[NSArray alloc] initWithObjects:[customGroup.localizedTitle encodeStringTo64], nil];
                                        [videoDetails setObject:arr forKey:@"AlbumName"];
                                        
                                        if (!assetPh.location && asset.creationDate.dateValue) {
                                            NSString *createDateStr = [NSDate stringFromDate:asset.creationDate.dateValue];;
                                            if (createDateStr.length > 0) {
                                                [videoDetails setValue:createDateStr forKey:@"creationDate"];
                                            }
                                        }
                                        
                                        if (assetPh.isFavorite) {
                                            
                                            [videoDetails setValue:[NSNumber numberWithBool:assetPh.isFavorite] forKey:@"isFavorite"];
                                        }
                                        
                                        [self.videoDic setObject:videoDetails forKey:fileName];
                                        
                                        [self.hashTableUrltofileName setObject:urlAsset forKey:fileName];
                                    } else { // exist, only add new album
                                        //                                            DebugLog(@"exist, update album info");
                                        videoDetails = [[self.videoDic objectForKey:fileName] mutableCopy];
                                        
                                        NSMutableArray *arr = [[videoDetails objectForKey:@"AlbumName"] mutableCopy];
                                        
                                        [arr addObject:[modifiedAlbumName encodeStringTo64]];
                                        [videoDetails setObject:arr forKey:@"AlbumName"];
                                        [self.videoDic setObject:videoDetails forKey:fileName];
                                    }
                                    
                                    if (++videoCollectionCount % 50 == 0) {
                                        [self.delegate shouldUpdateVideoNumber:videoCollectionCount];
                                    }
                                }
                            }
                        } else {
                            @synchronized (self) {
                                self.unavaliableVideoCloudcount++;
                                [self.unavailableCloudList addObject:[assetPh.localIdentifier componentsSeparatedByString:@"/"].firstObject];
                                
                                if (++videoCollectionCount % 50 == 0) {
                                    [self.delegate shouldUpdateVideoNumber:videoCollectionCount];
                                }
                            }
                        }
                        
                        @synchronized (self) {
                            if (++videoCount == albumVideos.count) { // last videos
                                if (++groupsCount == customGroups.count) { // last album
                                    [self fetchVideoInCameraRoll:fetchSetting and:videoRequesSetting finish:^{
                                        _localVideoFetchFinished = YES;
                                        _finished();
                                    }];
                                }
                            }
                        }
                    }];
                }];
            } else if (++groupsCount == customGroups.count) { // last album
                [self fetchVideoInCameraRoll:fetchSetting and:videoRequesSetting finish:^{
                    _localVideoFetchFinished = YES;
                    _finished();
                }];
            }
        }];
    } else {
        NSLog(@"No custom group");
        [self fetchVideoInCameraRoll:fetchSetting and:videoRequesSetting finish:^{
            _localVideoFetchFinished = YES;
            _finished();
        }];
    }
}

- (void)fetchVideoInCameraRoll:(PHFetchOptions *)fetchSetting and:(PHVideoRequestOptions *)videoRequesSetting finish:(void (^)(void))_finished {
    __block BOOL smartFolderFound = NO;
    PHFetchResult *smartGroups = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum
                                                                          subtype:PHAssetCollectionSubtypeAny
                                                                          options:nil];
    [smartGroups enumerateObjectsUsingBlock:^(PHAssetCollection *smartGroup, NSUInteger idx, BOOL *stop) {
        
        *stop = [[CTDataCollectionManager sharedManager] isVideosFetchingOperationCancelled];
        NSLog(@"Group title: %@", smartGroup.localizedTitle);
        if ([smartGroup.localizedTitle isEqualToString:CTLocalizedString(CT_CAMERA_ROLL_ALBUM, nil)] || ([smartGroup.localizedTitle isEqualToString:CTLocalizedString(CT_RECENTLY_ADDED_ALBUM, nil)] && SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(@"8.0"))) {
            smartFolderFound = YES;
            NSLog(@"smart group:%@", smartGroup.localizedTitle);
            // Fetch all the images from Camera Roll
            PHFetchResult *smartVideos = [PHAsset fetchAssetsInAssetCollection:smartGroup options:fetchSetting];
            if (smartVideos.count > 0) {
                __block int videoCount = 0;
                [smartVideos enumerateObjectsUsingBlock:^(PHAsset *assetPh, NSUInteger index, BOOL *stop) {
                    
                    *stop = [[CTDataCollectionManager sharedManager] isVideosFetchingOperationCancelled];
                    
                    [[PHImageManager defaultManager] requestAVAssetForVideo:assetPh options:videoRequesSetting resultHandler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
                        if ([asset isKindOfClass:[AVURLAsset class]]) {
                            AVURLAsset* urlAsset = (AVURLAsset*)asset;
                            if([self isVideoCreateTimeMissing:urlAsset])
                            {
                                [self insertCreateTime:urlAsset withTime:urlAsset.creationDate];
                            }
                            
                            // Create info list for photo
                            NSString *fileName = [[self getFileName:urlAsset.URL] encodeStringTo64];
                            //                                    DebugLog(@"index:%lu, file:%@", (unsigned long)index, fileName);
                            
                            // Get the videoSize
                            NSNumber *size;
                            [urlAsset.URL getResourceValue:&size forKey:NSURLFileSizeKey error:nil];
                            //                                    DebugLog(@"size is %f",[size floatValue]);
                            
                            NSMutableDictionary *videoDetails = nil;
                            @synchronized (self) {
                                if (![self.videoDic valueForKey:fileName]) { // not exist
                                    //                                            DebugLog(@"add into dic");
                                    videoDetails = [[NSMutableDictionary alloc] init];
                                    [videoDetails setObject:fileName forKey:@"Path"];
                                    [videoDetails setObject:[NSString stringWithFormat:@"%lld", [size longLongValue]] forKey:@"Size"];
                                    
                                    if ([[CTUserDevice userDevice].phoneCombination isEqualToString:IOS_Andriod]) {
                                        [videoDetails setObject:@[[@"Camera Roll" encodeStringTo64]] forKey:@"AlbumName"];
                                    }
                                    
                                    if (asset.creationDate.dataValue && !assetPh.location) {
                                        NSString *createDateStr = [NSDate stringFromDate:asset.creationDate.dateValue];;
                                        if (createDateStr.length > 0) {
                                            [videoDetails setValue:createDateStr forKey:@"creationDate"];
                                        }
                                    }
                                    
                                    if (assetPh.isFavorite) {
                                        [videoDetails setValue:[NSNumber numberWithBool:assetPh.isFavorite] forKey:@"isFavorite"];
                                    }
                                    
                                    [self.videoDic setObject:videoDetails forKey:fileName];
                                    
                                    [self.hashTableUrltofileName setObject:urlAsset forKey:fileName];
                                }
                                
                                if (++videoCollectionCount % 50 == 0) {
                                    [self.delegate shouldUpdateVideoNumber:videoCollectionCount];
                                }
                            }
                        }
                        
                        @synchronized (self) {
                            if (++videoCount == smartVideos.count) { // last photo
                                _finished();
                            }
                        }
                    }];
                }];
            } else { // No Photos
                _finished ();
            }
            
            *stop = YES;
        } else if ([smartGroup.localizedTitle isEqualToString:CTLocalizedString(CT_ALL_PHOTOS_ALBUM, nil)]) {
            smartFolderFound = YES;
            self.isAllPhotoVideo = YES;
            // Fetch all the images from Camera Roll
            PHFetchResult *smartVideos = [PHAsset fetchAssetsInAssetCollection:smartGroup options:fetchSetting];
            if (smartVideos.count > 0) {
                
                __block int videoCount = 0;
                [smartVideos enumerateObjectsUsingBlock:^(PHAsset *assetPh, NSUInteger index, BOOL *stop) {
                    
                    *stop = [[CTDataCollectionManager sharedManager] isVideosFetchingOperationCancelled];
                    
                    [[PHImageManager defaultManager] requestAVAssetForVideo:assetPh options:videoRequesSetting resultHandler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
                        if (asset && info) { // not cloud data
                            // Create info list for video
                            if ([asset isKindOfClass:[AVURLAsset class]]) {
                                AVURLAsset* urlAsset = (AVURLAsset*)asset;
                                if([self isVideoCreateTimeMissing:urlAsset])
                                {
                                    [self insertCreateTime:urlAsset withTime:urlAsset.creationDate];
                                }
                                
                                // Create info list for photo
                                NSString *fileName = [[self getFileName:urlAsset.URL] encodeStringTo64];
                                
                                // Get the videoSize
                                NSNumber *size;
                                [urlAsset.URL getResourceValue:&size forKey:NSURLFileSizeKey error:nil];
                                //                                        DebugLog(@"size is %f",[size floatValue]);
                                
                                NSMutableDictionary *videoDetails = nil;
                                @synchronized (self) {
                                    if (![self.videoDic valueForKey:fileName]) { // not exist
                                        videoDetails = [[NSMutableDictionary alloc] init];
                                        [videoDetails setObject:fileName forKey:@"Path"];
                                        [videoDetails setObject:[NSString stringWithFormat:@"%lld", [size longLongValue]] forKey:@"Size"];
                                        
                                        if ([[CTUserDevice userDevice].phoneCombination isEqualToString:IOS_Andriod]) {
                                            [videoDetails setObject:@[[@"Camera Roll" encodeStringTo64]] forKey:@"AlbumName"];
                                        } else {
                                            [videoDetails setObject:@[] forKey:@"AlbumName"];
                                        }
                                        
                                        if (asset.creationDate.dateValue && !assetPh.location) {
                                            NSString *createDateStr = [NSDate stringFromDate:asset.creationDate.dateValue];
                                            if (createDateStr.length > 0) {
                                                [videoDetails setValue:createDateStr forKey:@"creationDate"];
                                            }
                                        }
                                        
                                        if (assetPh.isFavorite) {
                                            [videoDetails setValue:[NSNumber numberWithBool:assetPh.isFavorite] forKey:@"isFavorite"];
                                        }
                                        
                                        [self.videoDic setObject:videoDetails forKey:fileName];
                                        
                                        [self.hashTableUrltofileName setObject:urlAsset forKey:fileName];
                                    }
                                }
                            }
                        } else {
                            @synchronized (self) {
                                if (![self.unavailableCloudList containsObject:[assetPh.localIdentifier componentsSeparatedByString:@"/"].firstObject]) {
                                    self.unavaliableVideoCloudcount ++;
                                }
                            }
                        }
                        
                        @synchronized (self) {
                            if (++videoCollectionCount % 50 == 0) {
                                [self.delegate shouldUpdateVideoNumber:videoCollectionCount];
                            }
                            
                            if (++videoCount == smartVideos.count) { // last video
                                _finished();
                            }
                        }
                    }];
                }];
            } else { // No Photos
                _finished ();
            }
            
            *stop = YES;
        }
    }];
    
    if (!smartFolderFound) {
        // None of target folders are found, return return 0 instead of blocking the user
        NSLog(@"No target smart folder found for video on current device.");
        [self.videoDic removeAllObjects];
        _finished();
    }
}

- (void)finishFetchingVideos:(void(^)(NSInteger videoCount, NSInteger streamCount, NSInteger unavailableCount, BOOL isAllPhotoVideo))completionHandler onFailure:(void(^)(NSString * errorMsg))failureHandler
{
    if (_cloudVideoFetchFinished && _localVideoFetchFinished) {
        dispatch_once(&_once_v, ^{
            [self mergeAllVideos];
            
            if ([NSJSONSerialization isValidJSONObject:self.videoListSuperSet]) {
                NSData *photoData = [NSJSONSerialization dataWithJSONObject:self.videoListSuperSet options:NSJSONWritingPrettyPrinted error:nil];
                NSFileManager *fileManager = [NSFileManager defaultManager];
                [fileManager createFileAtPath:videoLogfilepath contents:photoData attributes: nil];
                
                //videocallBackHandler([self.videoListSuperSet count], [self.videoStreamSet count], self.unavaliableVideoCloudcount);
                completionHandler([self.videoListSuperSet count], [self.videoStreamSet count], self.unavaliableVideoCloudcount, self.isAllPhotoVideo);
            } else {
                failureHandler(@"Error happened when fetching videos using new library.");
            }
        });
    }
}

#pragma mark - FETCH VIDEOS USING ALASSET
- (void)fetchVideosUsingALAssetPhotoLibrary:(void(^)(NSInteger videoCount, NSInteger streamCount, NSInteger unavailableCount, BOOL isAllPhotoVideo))completionHandler onFailure:(void(^)(NSString * errorMsg))failureHandler
{
    if (!self.assetsLibrary) {
        self.assetsLibrary = [[ALAssetsLibrary alloc] init];
    }
    
    __weak typeof(self) weakSelf = self;
    [self fetchALAssetVideosInCloud:^{
        [weakSelf mergeAllVideos];
        
        if ([NSJSONSerialization isValidJSONObject:weakSelf.videoListSuperSet]) {
            NSData *photoData = [NSJSONSerialization dataWithJSONObject:weakSelf.videoListSuperSet options:NSJSONWritingPrettyPrinted error:nil];
            NSFileManager *fileManager = [NSFileManager defaultManager];
            [fileManager createFileAtPath:videoLogfilepath contents:photoData attributes: nil];
            
            //videocallBackHandler([weakSelf.videoListSuperSet count], [weakSelf.videoStreamSet count], 0);
            completionHandler([self.videoListSuperSet count], [self.videoStreamSet count], self.unavaliableVideoCloudcount, NO);
            
        } else {
            failureHandler(@"Error happened when fetching videos using old library.");
        }
        
    } andFailure:^(NSError *error) {
        failureHandler(@"Permission Error when fetching videos");
    }];
}

- (void)fetchALAssetVideosInCloud:(void (^)(void))success andFailure:(void (^)(NSError *))failure
{
    // enumerate only photos
    __weak typeof(self) weakSelf = self;
    [self.assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupPhotoStream usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        
        *stop = [[CTDataCollectionManager sharedManager] isVideosFetchingOperationCancelled];
        
        if (group == nil) {
            [weakSelf fetchALAssetVideosInCustomAlbums:success andFailure:failure];
        }
        DebugLog(@"current group: %@", [group valueForProperty:ALAssetsGroupPropertyName]);
        [group setAssetsFilter:[ALAssetsFilter allVideos]];
        if ([group numberOfAssets] > 0) {
            
            [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                
                *stop = [[CTDataCollectionManager sharedManager] isVideosFetchingOperationCancelled];
                
                if (result) {
                    NSMutableDictionary *photoDetails = [[NSMutableDictionary alloc] init];
                    
                    [photoDetails setObject:[result.defaultRepresentation.filename encodeStringTo64] forKey:@"Path"];
                    [photoDetails setObject:[NSString stringWithFormat:@"%lld",result.defaultRepresentation.size] forKey:@"Size"];
                    
                    NSDictionary *metada = result.defaultRepresentation.metadata;
                    
                    if (![metada valueForKey:@"{GPS}"]) {
                        if ([result valueForProperty:ALAssetPropertyDate]) {
                            NSString *createDateStr = [NSDate stringFromDate:[result valueForProperty:ALAssetPropertyDate]];
                            if (createDateStr.length > 0) {
                                [photoDetails setValue:createDateStr forKey:@"creationDate"];
                            }
                        }
                    }
                    
                    NSArray *arr = [[NSArray alloc] initWithObjects:[[group valueForProperty:ALAssetsGroupPropertyName] encodeStringTo64], nil];
                    [photoDetails setObject:arr forKey:@"AlbumName"];
                    
                    [weakSelf.videoStreamSet addObject:photoDetails];
                    [weakSelf.hashTableUrltofileName setObject:result forKey:[result.defaultRepresentation.filename encodeStringTo64]];
                    
                    if (++videoCollectionCount % 5 == 0) {
                        [weakSelf.delegate shouldUpdateVideoNumber:videoCollectionCount];
                    }
                    
                }
            }];
        }
    } failureBlock:^(NSError *error) {
        failure(error);
    }];
    
}

- (void)fetchALAssetVideosInCustomAlbums:(void (^)(void))success andFailure:(void (^)(NSError *))failure
{
    // enumerate only photos
    __weak typeof(self) weakSelf = self;
    
    __block NSString *modifiedAlbumName;
    
    [self.assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAlbum | ALAssetsGroupLibrary usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        
        *stop = [[CTDataCollectionManager sharedManager] isVideosFetchingOperationCancelled];
        
        if (group == nil) {
            [weakSelf fetchALAssetVideosInCameraRolls:success andFailure:failure];
        }
        
        [group setAssetsFilter:[ALAssetsFilter allVideos]];
        if ([group numberOfAssets] > 0) {
            
            [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                
                *stop = [[CTDataCollectionManager sharedManager] isVideosFetchingOperationCancelled];
                
                if (result) {
                    NSString *fileName = [result.defaultRepresentation.filename encodeStringTo64];
                    
                    
                    if ([[self.duplicateDict allKeys] containsObject:[[group valueForProperty:ALAssetsGroupPropertyName] encodeStringTo64]] && (index == 0)) {
                        
                        int value = [[self.duplicateDict valueForKey:[[group valueForProperty:ALAssetsGroupPropertyName] encodeStringTo64]] intValue];
                        
                        value++;
                        
                        modifiedAlbumName = [NSString stringWithFormat:@"%@_VZ_%d",[group valueForProperty:ALAssetsGroupPropertyName],value];
                        
                        [self.duplicateDict setValue:[NSString stringWithFormat:@"%d",value] forKey:[modifiedAlbumName encodeStringTo64]];
                        
                    } else if (index == 0){
                        
                        [self.duplicateDict setValue:@"0" forKey:[[group valueForProperty:ALAssetsGroupPropertyName] encodeStringTo64]];
                        
                        modifiedAlbumName = [NSString stringWithString:[group valueForProperty:ALAssetsGroupPropertyName]];
                    }
                    
                    
                    if (![weakSelf.videoDic objectForKey:fileName]) {
                        NSMutableDictionary *photoDetails = [[NSMutableDictionary alloc] init];
                        
                        [photoDetails setObject:fileName forKey:@"Path"];
                        [photoDetails setObject:[NSString stringWithFormat:@"%lld",result.defaultRepresentation.size] forKey:@"Size"];
                        
                        NSDictionary *metada = result.defaultRepresentation.metadata;
                        
                        if (![metada valueForKey:@"{GPS}"]) {
                            if ([result valueForProperty:ALAssetPropertyDate]) {
                                NSString *createDateStr = [NSDate stringFromDate:[result valueForProperty:ALAssetPropertyDate]];
                                if (createDateStr.length > 0) {
                                    [photoDetails setValue:createDateStr forKey:@"creationDate"];
                                }
                            }
                        }
                        
                        NSArray *arr = [[NSArray alloc] initWithObjects:[[group valueForProperty:ALAssetsGroupPropertyName] encodeStringTo64], nil];
                        [photoDetails setObject:arr forKey:@"AlbumName"];
                        
                        [weakSelf.videoDic setObject:photoDetails forKey:fileName];
                        [weakSelf.hashTableUrltofileName setObject:result forKey:fileName];
                        
                        if (++videoCollectionCount % 5 == 0) {
                            [weakSelf.delegate shouldUpdateVideoNumber:videoCollectionCount];
                        }
                    } else {
                        NSMutableDictionary *photoDetails = [[self.videoDic objectForKey:fileName] mutableCopy];
                        
                        NSMutableArray *arr = [[photoDetails objectForKey:@"AlbumName"] mutableCopy];
                        
                        
                        [arr addObject:[modifiedAlbumName encodeStringTo64]];
                        
                        [photoDetails setObject:arr forKey:@"AlbumName"];
                        [weakSelf.videoDic setObject:photoDetails forKey:fileName];
                    }
                }
            }];
        }
    } failureBlock:^(NSError *error) {
        failure(error);
    }];
    
}

- (void)fetchALAssetVideosInCameraRolls:(void (^)(void))success andFailure:(void (^)(NSError *))failure
{
    // enumerate only photos
    __weak typeof(self) weakSelf = self;
    [self.assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        
        *stop = [[CTDataCollectionManager sharedManager] isVideosFetchingOperationCancelled];
        
        if (group == nil) {
            success();
        }
        
        [group setAssetsFilter:[ALAssetsFilter allVideos]];
        if ([group numberOfAssets] > 0) {
            
            [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                
                *stop = [[CTDataCollectionManager sharedManager] isVideosFetchingOperationCancelled];
                
                if (result) {
                    NSString *fileName = [result.defaultRepresentation.filename encodeStringTo64];
                    if (![weakSelf.videoDic objectForKey:fileName]) {
                        NSMutableDictionary *photoDetails = [[NSMutableDictionary alloc] init];
                        
                        [photoDetails setObject:fileName forKey:@"Path"];
                        [photoDetails setObject:[NSString stringWithFormat:@"%lld",result.defaultRepresentation.size] forKey:@"Size"];
                        
                        if ([[CTUserDevice userDevice].phoneCombination isEqualToString:IOS_Andriod]) {
                            [photoDetails setObject:@[[@"Camera Roll" encodeStringTo64]] forKey:@"AlbumName"];
                        }
                        
                        NSDictionary *metada = result.defaultRepresentation.metadata;
                        
                        if (![metada valueForKey:@"{GPS}"]) {
                            if ([result valueForProperty:ALAssetPropertyDate]) {
                                NSString *createDateStr = [NSDate stringFromDate:[result valueForProperty:ALAssetPropertyDate]];
                                if (createDateStr.length > 0) {
                                    [photoDetails setValue:createDateStr forKey:@"creationDate"];
                                }
                            }
                        }
                        
                        [weakSelf.videoDic setObject:photoDetails forKey:fileName];
                        [weakSelf.hashTableUrltofileName setObject:result forKey:fileName];
                        
                        if (++videoCollectionCount % 5 == 0) {
                            [weakSelf.delegate shouldUpdateVideoNumber:videoCollectionCount];
                        }
                    }
                }
            }];
        }
    } failureBlock:^(NSError *error) {
        failure(error);
    }];
    
}

#pragma mark - Query files
- (void)getPhotoData:(NSString *)imageName forLive:(BOOL)isLive Sucess:(photofetchsucess)fetchSucess {
    NSRange replaceRange = [imageName rangeOfString:@"\r\n"];
    if (replaceRange.location != NSNotFound){
        imageName = [imageName stringByReplacingCharactersInRange:replaceRange withString:@""];
    }
    
    id storedObj = [self.hashTableUrltofileName objectForKey:[imageName encodeStringTo64]]; // O(1)
    if (isLive) {
        // Live photo image part
        NSAssert(([storedObj isKindOfClass:[CTLivePhoto class]]), @"When request live photo, stored object must be CTLivePhoto object.");
        CTLivePhoto *photo = (CTLivePhoto *)storedObj;
        [photo getImageDataWithCompletion:^(NSData * _Nullable imageData) {
            @autoreleasepool {
                if (imageData) {
                    NSData *refinedData = [self insertImageMetaData:imageData withDate:photo.creationDate];
                    fetchSucess(refinedData, nil);
                } else {
                    NSError *error = [NSError errorWithDomain:NSURLErrorDomain code:500 userInfo:@{NSLocalizedDescriptionKey : @"Error when reading data from live image object."}];
                    fetchSucess(nil, error);
                }
            }
        }];
    } else {
        // Static photo process
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
            NSAssert([storedObj isKindOfClass:[PHAsset class]], @"Should be PHAsset for photo >= 8.0.");
            PHAsset *myasset = (PHAsset *)storedObj;
            storedObj = nil;
            // Configuration
            PHImageRequestOptions * imageRequestOptions = [[PHImageRequestOptions alloc] init];
            imageRequestOptions.synchronous = YES;
            // Fetch image data
            [[PHImageManager defaultManager] requestImageDataForAsset:myasset options:imageRequestOptions resultHandler:^(NSData *imageData, NSString *dataUTI, UIImageOrientation orientation, NSDictionary *info) {
                @autoreleasepool {
                    if (imageData) {
                        NSData *refinedData = [self insertImageMetaData:imageData withDate:myasset.creationDate];
                        fetchSucess(refinedData, nil);
                    } else {
                        fetchSucess(nil, (NSError *)[info objectForKey:PHImageErrorKey]);
                    }
                }
            }];
        } else {
            NSAssert([storedObj isKindOfClass:[ALAsset class]], @"Should be ALAsset for photo < 8.0.");
            ALAsset *myasset = (ALAsset *)storedObj;
            ALAssetRepresentation *rep = [myasset defaultRepresentation];
            long long sentDataSize = rep.size;
            // Get image data
            Byte *bufferInit = (Byte*)malloc((unsigned long)sentDataSize);
            NSUInteger buffered = [rep getBytes:bufferInit fromOffset:0 length:(unsigned long)sentDataSize error:nil];
            NSData *photoData = [NSData dataWithBytesNoCopy:bufferInit length:buffered freeWhenDone:YES];
            // Insert creation date.
            NSData *refinedData = [self insertImageMetaData:photoData withDate:[myasset valueForProperty:ALAssetPropertyDate]];
            if (refinedData.length > 0) {
                fetchSucess(refinedData, nil);
            } else {
                NSError *error = [NSError errorWithDomain:NSURLErrorDomain code:500 userInfo:@{NSLocalizedDescriptionKey : @"Error when reading data from ALAsset image object."}];
                fetchSucess(nil, error);
            }
        }
    }
}

- (void)getVideoResourceForLivePhoto:(NSString *)imageName completion:(photofetchsucess)handler {
    NSRange replaceRange = [imageName rangeOfString:@"\r\n"];
    if (replaceRange.location != NSNotFound){
        imageName = [[imageName stringByReplacingCharactersInRange:replaceRange withString:@""] encodeStringTo64];
    }
    
    // Live photo video part
    id storedObj = [self.hashTableUrltofileName objectForKey:[imageName encodeStringTo64]]; // O(1)
    NSAssert(([storedObj isKindOfClass:[CTLivePhoto class]]), @"When request live photo, stored object must be CTLivePhoto object.");
    CTLivePhoto *photo = (CTLivePhoto *)storedObj;
    [photo getVideoDataWithCompletion:^(NSData * _Nullable videoData) {
        @autoreleasepool {
            if (videoData) {
                handler(videoData, nil);
            } else {
                NSError *error = [NSError errorWithDomain:NSURLErrorDomain code:500 userInfo:@{NSLocalizedDescriptionKey : @"Error when reading video data from live image object."}];
                handler(nil, error);
            }
        }
    }];
}

- (long long)getVideoComponentSize:(NSString *)imageName {
    NSRange replaceRange = [imageName rangeOfString:@"\r\n"];
    if (replaceRange.location != NSNotFound){
        imageName = [[imageName stringByReplacingCharactersInRange:replaceRange withString:@""] encodeStringTo64];
    }
    
    // Live photo video part
    id storedObj = [self.hashTableUrltofileName objectForKey:[imageName encodeStringTo64]]; // O(1)
    NSAssert(([storedObj isKindOfClass:[CTLivePhoto class]]), @"When request live photo, stored object must be CTLivePhoto object.");
    CTLivePhoto *photo = (CTLivePhoto *)storedObj;
    return photo.videoConponentSize;
}

- (void)getVideoData:(NSString *)videoName Sucess:(videofetchsucess)fetchSucess{
    
    NSRange replaceRange = [videoName rangeOfString:@"\r\n"];
    if (replaceRange.location != NSNotFound){
        videoName = [videoName stringByReplacingCharactersInRange:replaceRange withString:@""];
    }
    
    id videoObject = [self.hashTableUrltofileName valueForKey:[videoName encodeStringTo64]]; // O(1)
    // Return video object saved in hash table
    fetchSucess(videoObject);
}

- (void)requesForSecondTimePermissionAlert:(void(^)(void))granted andDenied:(void(^)(void))deny {
    [self.assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupLibrary usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        granted();
    } failureBlock:^(NSError *error) {
        deny();
    }];
}

#pragma mark - To get camera roll photo and video count
-(void)getCameraRollPhotosCount:(void (^)(NSInteger photoCount, NSInteger streamPhotoCount, NSInteger unavialablePhotoCount, BOOL isAllPhotos))completionHandler{
    
    __block NSInteger tempCameraRollPhotoCount = 0;
    __block NSInteger tempStreamPhotoCount = 0;
    __block NSInteger tempunavialablePhotoCount = 0;
    __block BOOL isAllPhotos = NO;
    
    if (NSFoundationVersionNumber >= NSFoundationVersionNumber_iOS_8_0) {
        
        // Group image filter Option
        PHFetchOptions *onlyImagesOptions = [PHFetchOptions new];
        onlyImagesOptions.predicate = [NSPredicate predicateWithFormat:@"mediaType = %i", PHAssetMediaTypeImage];
        onlyImagesOptions.includeAllBurstAssets = YES;
        
        // Image request option
        PHImageRequestOptions * imageRequestOptions = [[PHImageRequestOptions alloc] init];
        imageRequestOptions.synchronous = YES;
        
        __block BOOL smartGroupFinish = NO; // Set to YES when find the group "camera roll" or "All Photos"
        PHFetchResult *smartGroups = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAny options:nil];
        [smartGroups enumerateObjectsUsingBlock:^(PHAssetCollection *smartGroup, NSUInteger idx, BOOL *stop) {
            
            *stop = [[CTDataCollectionManager sharedManager] isPhotosFetchingOperationCancelled];
            
            if ([smartGroup.localizedTitle isEqualToString:CTLocalizedString(CT_CAMERA_ROLL_ALBUM, nil)] || ([smartGroup.localizedTitle isEqualToString:CTLocalizedString(CT_RECENTLY_ADDED_ALBUM, nil)] && SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(@"8.0"))) {
                DebugLog(@"smart group:%@", smartGroup.localizedTitle);
                // Fetch all the images from Camera Roll
                PHFetchResult *smartPhotos = [PHAsset fetchAssetsInAssetCollection:smartGroup options:onlyImagesOptions];
                if (smartPhotos.count > 0) {
                    for (PHAsset *asset in smartPhotos) {
                        if (asset.representsBurst) {
                            tempCameraRollPhotoCount = tempCameraRollPhotoCount +[PHAsset fetchAssetsWithBurstIdentifier:asset.burstIdentifier options:onlyImagesOptions].count;
                        }else {
                            ++tempCameraRollPhotoCount;
                        }
                    }
                }
                
                smartGroupFinish = YES;
            } else if ([smartGroup.localizedTitle isEqualToString:CTLocalizedString(CT_ALL_PHOTOS_ALBUM, nil)]) { // If user switch on "All Photo" Cloud option, camera roll will be replaced by all photos folder
                isAllPhotos = YES;
                PHFetchResult *smartPhotos = [PHAsset fetchAssetsInAssetCollection:smartGroup options:onlyImagesOptions];
                if (smartPhotos.count > 0) {
                    tempunavialablePhotoCount = smartPhotos.count;
                }
                
                smartGroupFinish = YES;
            }
            
            if (smartGroupFinish) {
                PHFetchResult *cloudGroups = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumMyPhotoStream options:nil];
                if (cloudGroups.count > 0) {
                    [cloudGroups enumerateObjectsUsingBlock:^(PHAssetCollection *cloudGroup, NSUInteger idx, BOOL *stop) {
                        
                        *stop = [[CTDataCollectionManager sharedManager] isPhotosFetchingOperationCancelled];
                        
                        PHFetchResult *myPhotoStreamPhotos = [PHAsset fetchAssetsInAssetCollection:cloudGroup options:onlyImagesOptions];
                        
                        if (myPhotoStreamPhotos.count > 0) {
                            tempStreamPhotoCount = myPhotoStreamPhotos.count;
                        }
                    }];
                }
                
                *stop = YES;
            }
        }];
        
        completionHandler(tempCameraRollPhotoCount,tempStreamPhotoCount,tempunavialablePhotoCount,isAllPhotos);
        
    } else {
        [self.assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
            
            *stop = [[CTDataCollectionManager sharedManager] isPhotosFetchingOperationCancelled];
            
            if (!group) {
                // Cloud, NO All Photos for iOS 7 and blew
                [self.assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupPhotoStream usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
                    
                    *stop = [[CTDataCollectionManager sharedManager] isPhotosFetchingOperationCancelled];
                    
                    if (!group) {
                        completionHandler(tempCameraRollPhotoCount,tempStreamPhotoCount,tempunavialablePhotoCount,isAllPhotos);
                    }
                    [group setAssetsFilter:[ALAssetsFilter allPhotos]];
                    if ([group numberOfAssets] > 0) {
                        tempStreamPhotoCount = [group numberOfAssets];
                    }
                } failureBlock:nil];
            }
            
            [group setAssetsFilter:[ALAssetsFilter allPhotos]];
            if ([group numberOfAssets] > 0) {
                tempCameraRollPhotoCount = [group numberOfAssets];
            }
        } failureBlock:nil];
    }
}

- (void)getCameraRollVideoCount:(void (^)(NSInteger videoCount, NSInteger streamVideoCount, NSInteger unavialableVideoCount, BOOL isAllPhotos))completionHandler {
    
    __block NSInteger tempCameraRollVideoCount = 0;
    __block NSInteger tempStreamVideoCount = 0;
    __block NSInteger tempunavialableVideoCount = 0;
    __block BOOL isAllPhotos = NO;
    
    if (NSFoundationVersionNumber >= NSFoundationVersionNumber_iOS_8_0) {
        
        PHFetchOptions *onlyVideosOptions = [PHFetchOptions new];
        onlyVideosOptions.predicate = [NSPredicate predicateWithFormat:@"mediaType = %i", PHAssetMediaTypeVideo];
        
        // Image request option
        PHVideoRequestOptions * VideoRequestOptions = [[PHVideoRequestOptions alloc] init];
        VideoRequestOptions.version = PHVideoRequestOptionsVersionOriginal;
        
        __block BOOL smartGroupFinish = NO; // Set to YES when find the group "camera roll" or "All Photos"
        PHFetchResult *smartGroups = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAny options:nil];
        [smartGroups enumerateObjectsUsingBlock:^(PHAssetCollection *smartGroup, NSUInteger idx, BOOL *stop) {
            
            *stop = [[CTDataCollectionManager sharedManager] isVideosFetchingOperationCancelled];
            
            if ([smartGroup.localizedTitle isEqualToString:CTLocalizedString(CT_CAMERA_ROLL_ALBUM, nil)]) {
                PHFetchResult *smartVideos = [PHAsset fetchAssetsInAssetCollection:smartGroup options:onlyVideosOptions];
                if (smartVideos.count > 0) {
                    tempCameraRollVideoCount = smartVideos.count;
                }
                
                smartGroupFinish = YES;
            } else if ([smartGroup.localizedTitle isEqualToString:CTLocalizedString(CT_ALL_PHOTOS_ALBUM, nil)]) {
                isAllPhotos = YES;
                PHFetchResult *smartVideos = [PHAsset fetchAssetsInAssetCollection:smartGroup options:onlyVideosOptions];
                if (smartVideos.count > 0) {
                    tempunavialableVideoCount = smartVideos.count;
                }
                
                smartGroupFinish = YES;
            } else if ([smartGroup.localizedTitle isEqualToString:CTLocalizedString(CT_RECENTLY_ADDED_ALBUM, nil)] && SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(@"8.0")) {
                PHFetchResult *smartVideos = [PHAsset fetchAssetsInAssetCollection:smartGroup options:onlyVideosOptions];
                if (smartVideos.count > 0) {
                    tempCameraRollVideoCount = smartVideos.count;
                }
                
                smartGroupFinish = YES;
            }
            
            if (smartGroupFinish) {
                PHFetchResult *cloudGroups = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumMyPhotoStream options:nil];
                if (cloudGroups.count > 0) {
                    [cloudGroups enumerateObjectsUsingBlock:^(PHAssetCollection *cloudGroup, NSUInteger idx, BOOL *stop) {
                        
                        *stop = [[CTDataCollectionManager sharedManager] isVideosFetchingOperationCancelled];
                        
                        PHFetchResult *myPhotoStreamVideos = [PHAsset fetchAssetsInAssetCollection:cloudGroup options:onlyVideosOptions];
                        if (myPhotoStreamVideos.count > 0) {
                            tempStreamVideoCount = myPhotoStreamVideos.count;
                        }
                    }];
                }
                *stop = YES;
            }
        }];
        
        completionHandler(tempCameraRollVideoCount,tempStreamVideoCount,tempunavialableVideoCount,isAllPhotos);
    } else {
        
        [self.assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
            
            *stop = [[CTDataCollectionManager sharedManager] isVideosFetchingOperationCancelled];
            
            if (!group) {
                // Cloud, NO All Photos for iOS 7 and blew
                [self.assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupPhotoStream usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
                    
                    *stop = [[CTDataCollectionManager sharedManager] isVideosFetchingOperationCancelled];
                    
                    if (!group) {
                        completionHandler(tempCameraRollVideoCount,tempStreamVideoCount,tempunavialableVideoCount,isAllPhotos);
                    }
                    
                    [group setAssetsFilter:[ALAssetsFilter allVideos]];
                    if ([group numberOfAssets] > 0) {
                        tempStreamVideoCount = [group numberOfAssets];
                    }
                } failureBlock:nil];
            }
            
            [group setAssetsFilter:[ALAssetsFilter allVideos]];
            if ([group numberOfAssets] > 0) {
                tempCameraRollVideoCount = [group numberOfAssets];
            }
        } failureBlock:nil];
    }
}

#pragma mark - Time metadata helpers
- (NSData *)insertImageMetaData:(NSData *)imageData withDate:(NSDate *)date {
    CGImageSourceRef imageSource = CGImageSourceCreateWithData((__bridge CFDataRef)(imageData), NULL);
    
    if (imageSource && date) {
        NSDictionary *options = @{(NSString *)kCGImageSourceShouldCache : [NSNumber numberWithBool:NO]};
        
        CFDictionaryRef imageProperties = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, (__bridge CFDictionaryRef)options);
        if (imageProperties) {
            
            NSDictionary *metadata = (__bridge NSDictionary *)imageProperties;
            
            NSMutableDictionary *metadataAsMutable = [metadata mutableCopy];
            
            if(metadataAsMutable == nil)
            {
                metadataAsMutable = [[NSMutableDictionary alloc] initWithCapacity:0];
            }
            
            
            NSMutableDictionary * TiffDictionary = [metadataAsMutable[(NSString *)kCGImagePropertyTIFFDictionary] mutableCopy];
            
            
            if(TiffDictionary == nil)
            {
                TiffDictionary = [[NSMutableDictionary alloc] initWithCapacity:0];
            }
            
            NSMutableDictionary * ExitDictionary = [metadataAsMutable[(NSString *)kCGImagePropertyExifDictionary] mutableCopy];
            
            if(ExitDictionary == nil)
            {
                ExitDictionary = [[NSMutableDictionary alloc] initWithCapacity:0];
            }
            else
            {
                NSString * tempStr = [ExitDictionary objectForKey:(NSString *)kCGImagePropertyExifDateTimeOriginal];
                
                if(tempStr != nil)
                {
                    
                    CFRelease(imageProperties);
                    
                    CFRelease(imageSource);
                    
                    return imageData;
                }
            }
            
            NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
            
            [dateFormatter setDateFormat:@"yyyy:MM:dd HH:mm:ss"];
            
            NSTimeZone *gmt = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
            
            [dateFormatter setTimeZone:gmt];
            
            NSDate * newDate = [NSDate dateWithTimeIntervalSince1970:[date timeIntervalSince1970] - 0];
            
            NSString *dateString = [dateFormatter stringFromDate:newDate];
            
            [TiffDictionary setObject:dateString forKey:(NSString *)kCGImagePropertyTIFFDateTime];
            [ExitDictionary setObject:dateString forKey:(NSString *)kCGImagePropertyExifDateTimeOriginal];
            [ExitDictionary setObject:dateString forKey:(NSString *)kCGImagePropertyExifDateTimeDigitized];
            
            [metadataAsMutable setObject:TiffDictionary forKey:(NSString *)kCGImagePropertyTIFFDictionary];
            [metadataAsMutable setObject:ExitDictionary forKey:(NSString *)kCGImagePropertyExifDictionary];
            
            CFStringRef UTI = CGImageSourceGetType(imageSource); //this is the type of image (e.g., public.jpeg)
            
            //this will be the data CGImageDestinationRef will write into
            NSMutableData *dest_data = [NSMutableData data];
            
            CGImageDestinationRef destination = CGImageDestinationCreateWithData((CFMutableDataRef)dest_data,UTI,1,NULL);
            
            CFRelease(UTI);
            
            if(!destination) {
                NSLog(@"***Could not create image destination ***");
                
                CFRelease(imageProperties);
                CFRelease(imageSource);
                
                return imageData;
            }
            
            CGImageDestinationAddImageFromSource(destination,imageSource,0, (CFDictionaryRef) metadataAsMutable);
            
            //tell the destination to write the image data and metadata into our data object.
            //It will return false if something goes wrong
            BOOL success = NO;
            
            success = CGImageDestinationFinalize(destination);
            
            if(!success) {
                NSLog(@"***Could not create data from image destination ***");
                
                CFRelease(destination);
                CFRelease(imageProperties);
                CFRelease(imageSource);
                
                return imageData;
            }
            
            CFRelease(destination);
            CFRelease(imageProperties);
            CFRelease(imageSource);
            
            return dest_data;
            
        }
    }
    
    return imageData;
}

- (NSInteger)caulateInsertImageMetaData:(NSData *)imageData withDate:(NSDate *)date {
    NSData *refinedData = [self insertImageMetaData:imageData withDate:date];
    return refinedData.length;
}

- (AVURLAsset *)insertCreateTime:(AVURLAsset *) asset withTime:(AVMetadataItem *)dateItem
{
    AVMutableMetadataItem * commonDate = [[AVMutableMetadataItem alloc] init];   // Creation Date
    commonDate.keySpace = AVMetadataKeySpaceCommon;
    commonDate.key = AVMetadataCommonKeyCreationDate;
    NSDate * date = dateItem.dateValue;
    
    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setDateFormat:@"yyyy-MM-ddTHH:mm:ss"];
    
    NSTimeZone *gmt = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    
    [dateFormatter setTimeZone:gmt];
    
    NSString *dateString = [dateFormatter stringFromDate:date];
    
    commonDate.value = dateString;
    
    NSError *error;
    AVAssetWriter *assetWriter = [[AVAssetWriter alloc] initWithURL:asset.URL fileType:AVFileTypeAppleM4A  error:&error];
    NSLog(@"%@",error);
    
    if(assetWriter)
    {
        NSArray *existingMetadataArray = assetWriter.metadata;
        NSMutableArray *newMetadataArray = nil;
        if (existingMetadataArray)
        {
            newMetadataArray = [existingMetadataArray mutableCopy]; // To prevent overriding of existing metadata
        }
        else
        {
            newMetadataArray = [[NSMutableArray alloc] init];
        }
        
        [newMetadataArray addObject:commonDate];
        assetWriter.metadata = newMetadataArray;
        
        [assetWriter startWriting];
        [assetWriter startSessionAtSourceTime:kCMTimeZero];
        
    }
    return asset;
}

- (BOOL) isVideoCreateTimeMissing:(AVAsset *) asset
{
    NSArray *metadata = [asset commonMetadata];
    
    for (AVMetadataItem *item in metadata) {
        
        if([[item commonKey] isEqualToString:AVMetadataCommonKeyCreationDate])
        {
            return NO;
        }
    }
    
    return YES;
}

@end

