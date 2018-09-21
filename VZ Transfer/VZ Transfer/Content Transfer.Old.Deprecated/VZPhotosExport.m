//
//  VZPhotosExport.m
//  VZTransferSocket
//
//  Created by VVM-MAC02 on 12/2/15.
//  Copyright © 2015 Testing. All rights reserved.
//

#import "VZPhotosExport.h"
#import "VZContentTrasnferConstant.h"
#import "NSString+CTContentTransferRootDocuments.h"

#import <Photos/Photos.h>

@interface VZPhotosExport()
@property (atomic, strong) NSMutableDictionary *photoDic;
@property (atomic, strong) NSMutableDictionary *videoDic;

@property (nonatomic, assign) BOOL cloudPhotoFetchFinished;
@property (nonatomic, assign) BOOL localPhotoFetchFinished;

@property (nonatomic, assign) BOOL cloudVideoFetchFinished;
@property (nonatomic, assign) BOOL localVideoFetchFinished;

@property (atomic, assign) NSInteger unavaliableCloudcount;
@property (atomic, assign) NSInteger unavaliableVideoCloudcount;

@property (nonatomic, assign) dispatch_once_t once; // make sure merge photos only called once for each of the photoExport instance
@property (nonatomic, assign) dispatch_once_t once_v;

@property (atomic, assign) NSInteger photoCollectingCount;
@property (atomic, assign) NSInteger videoCollectionCount;
@property (nonatomic,strong) NSMutableDictionary *duplicateDict;
@end

@implementation VZPhotosExport

@synthesize photocallBackHandler;
@synthesize videocallBackHandler;
@synthesize hashTableUrltofileName;
@synthesize photoListSuperSet;
@synthesize photoStreamSet;
@synthesize videoStreamSet;
@synthesize videoListSuperSet;
@synthesize unavaliableCloudcount;
@synthesize unavaliableVideoCloudcount;
@synthesize photoCollectingCount;
@synthesize videoCollectionCount;

- (id)init {
    
    if (self = [super init]) {
        
        NSString *basePath = [NSString appRootDocumentDirectory];
        
        photoLogfilepath  = [NSString stringWithFormat:@"%@/VZPhotoLogfile.txt",basePath];
        videoLogfilepath  = [NSString stringWithFormat:@"%@/VZVideoLogfile.txt",basePath];
        
        hashTableUrltofileName = [[NSMutableDictionary alloc] init];
        
        [[NSFileManager defaultManager] removeItemAtPath:photoLogfilepath error:nil];
        [[NSFileManager defaultManager] removeItemAtPath:videoLogfilepath error:nil];
        
        photoCollectingCount = 0;
        
        self.photoListSuperSet = [[NSMutableArray alloc] init];
        self.photoStreamSet = [[NSMutableArray alloc] init];
        
        self.videoListSuperSet = [[NSMutableArray alloc] init];
        self.videoStreamSet = [[NSMutableArray alloc] init];
        
        self.videoDic = [[NSMutableDictionary alloc] init];
        self.photoDic = [[NSMutableDictionary alloc] init];
        
        self.duplicateDict = [[NSMutableDictionary alloc] init];
        
        // ALAssetsLibrary is deprecated, only use in device with old iOS version (7 & below)
        if(NSFoundationVersionNumber < NSFoundationVersionNumber_iOS_8_0) {
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
    self.photoListSuperSet = [self.photoDic allValues];
}

- (void)createphotoLogfile {
    
    // New photo library support iOS 8 & above
    if(NSFoundationVersionNumber >= NSFoundationVersionNumber_iOS_8_0) {
        PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
        if (status == PHAuthorizationStatusAuthorized) { // granted
            [self fetchPhotosUsingNewPhotoLibrary];
        } else if (status == PHAuthorizationStatusNotDetermined) { // Access has not been determined.
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                if (status == PHAuthorizationStatusAuthorized) {
                    [self fetchPhotosUsingNewPhotoLibrary];
                } else {
                    _fetchfailure(@"Photo Access Not Granted.", YES);
                }
            }];
        } else {
            _fetchfailure(@"Photo Access Not Granted.", YES);
        }
    } else {
        [self fetchPhotosUsingOldPhotoLibrary];
    }
    
}

#pragma mark - NEW PHOTO LIBRARY (__IPHONE_8_0)
- (void)fetchPhotosUsingNewPhotoLibrary
{
    // Globle pram
    // Group image filter Option
    PHFetchOptions *onlyImagesOptions = [PHFetchOptions new];
    onlyImagesOptions.predicate = [NSPredicate predicateWithFormat:@"mediaType = %i", PHAssetMediaTypeImage];
    
    // Image request option
    PHImageRequestOptions * imageRequestOptions = [[PHImageRequestOptions alloc] init];
    imageRequestOptions.synchronous = YES;
    
    // Read iCloud Photos
    [self fetchImageInMyPhotoStream:onlyImagesOptions and:imageRequestOptions finish:^{
        DebugLog(@"fetching my photo stream finish");
        
        [self finishFetchingPhotos];
    }];
    
    // Read All photos from custom ablums
    [self fetchImageInCustomAblum:onlyImagesOptions and:imageRequestOptions finish:^{
        DebugLog(@"fetching ablum image done!");
        
        [self finishFetchingPhotos];
    }];
}

- (void)finishFetchingPhotos
{
    if (_cloudPhotoFetchFinished && _localPhotoFetchFinished) {
        dispatch_once(&_once, ^{
            [self mergeAllPhotos];
            
            if ([NSJSONSerialization isValidJSONObject:self.photoListSuperSet]) {
                // photo list is a valid Json object, transfer list to data.
                
                NSData *photoData = [NSJSONSerialization dataWithJSONObject:self.photoListSuperSet options:NSJSONWritingPrettyPrinted error:nil];
                
                NSFileManager *fileManager = [NSFileManager defaultManager];
                [fileManager createFileAtPath:photoLogfilepath contents:photoData attributes: nil];
                
                photocallBackHandler([self.photoListSuperSet count], [self.photoStreamSet count], self.unavaliableCloudcount);
            } else {
                // photo list is not a valid object
                _fetchfailure(@"Error happened when fetching photos using new library.", NO);
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
            @autoreleasepool {
                //            DebugLog(@"cloud group:%@", cloudGroup.localizedTitle);
                // Fetch all the images from My Photo Stream
                PHFetchResult *myPhotoStreamPhotos = [PHAsset fetchAssetsInAssetCollection:cloudGroup options:fetchSetting];
                
                if (myPhotoStreamPhotos.count > 0) {
                    //                    DebugLog(@"->reading %lu photos in this album", (unsigned long)myPhotoStreamPhotos.count);
                    __block int streamPhotoCount = 0;
                    [myPhotoStreamPhotos enumerateObjectsUsingBlock:^(PHAsset *asset, NSUInteger idx, BOOL *stop) {
                        [[PHImageManager defaultManager] requestImageDataForAsset:asset options:imageRequesSetting resultHandler:^(NSData *imageData, NSString *dataUTI, UIImageOrientation orientation, NSDictionary *info) {
                            
                            if (imageData.length > 0 && info) {
                                // Create info list for photo
                                NSMutableDictionary *photoDetails = [[NSMutableDictionary alloc] init];
                                
                                NSString *fileName = [self encodeStringTo64:[self getFileName:(NSURL *)[info objectForKey:@"PHImageFileURLKey"]]];
                                
                                if (fileName) {
                                    
                                    [photoDetails setObject:fileName forKey:@"Path"];
                                    
                                    [photoDetails setObject:[NSString stringWithFormat:@"%lu", (unsigned long)imageData.length] forKey:@"Size"];
                                    
                                    NSArray *arr = [[NSArray alloc] initWithObjects:[self encodeStringTo64:cloudGroup.localizedTitle], nil];
                                    [photoDetails setObject:arr forKey:@"AlbumName"];
                                    
                                    @synchronized (self) {
                                        [self.photoStreamSet addObject:photoDetails];
                                        [self.hashTableUrltofileName setObject:asset forKey:fileName];
                                    }
                                }
                                
                            } else {
                                @synchronized (self) {
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
                    }];
                } else { // No photos in My Photo Stream
                    _cloudPhotoFetchFinished = YES;
                    _finished();
                }
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
            @autoreleasepool {
                //            DebugLog(@"custom group:%@", customGroup.localizedTitle);
                // Fetch all the images from My Photo Stream
                PHFetchResult *albumPhotos = [PHAsset fetchAssetsInAssetCollection:customGroup options:fetchSetting];
                if (albumPhotos.count > 0) {
                    //                    DebugLog(@"->reading %lu photos in this album", (unsigned long)albumPhotos.count);
                    
                    __block int assetCount = 0;
                    __block int avalibleCount = 0;
                    
                    __block NSString *modifiedAlbumName;
                    
                    [albumPhotos enumerateObjectsUsingBlock:^(PHAsset *asset, NSUInteger index, BOOL *stop) {
                        
                        [[PHImageManager defaultManager] requestImageDataForAsset:asset options:imageRequesSetting resultHandler:^(NSData *imageData, NSString *dataUTI, UIImageOrientation orientation, NSDictionary *info) {
                            
                            if (imageData.length > 0 && info) {
                                // Create info list for photo
                                NSString *fileName = [self encodeStringTo64:[self getFileName:(NSURL *)[info objectForKey:@"PHImageFileURLKey"]]];
                                
                                if (fileName) {
                                    
                                    NSMutableDictionary *photoDetails = nil;
                                    @synchronized (self) {
                                        if ([[self.duplicateDict allKeys] containsObject:[self encodeStringTo64:customGroup.localizedTitle]] && (avalibleCount == 0)) {
                                            
                                            int value = [[self.duplicateDict valueForKey:[self encodeStringTo64:customGroup.localizedTitle]] intValue];
                                            
                                            value++;
                                            
                                            modifiedAlbumName = [NSString stringWithFormat:@"%@_VZ_%d",customGroup.localizedTitle,value];
                                            
                                            [self.duplicateDict setValue:[NSString stringWithFormat:@"%d",value] forKey:[self encodeStringTo64:modifiedAlbumName]];
                                            
                                        } else if (avalibleCount == 0) {
                                            
                                            [self.duplicateDict setValue:@"0" forKey:[self encodeStringTo64:customGroup.localizedTitle]];
                                            
                                            modifiedAlbumName = [NSString stringWithString:customGroup.localizedTitle];
                                        }
                                        
                                        
                                        if (![self.photoDic valueForKey:fileName]) { // not exist
                                            
                                            photoDetails = [[NSMutableDictionary alloc] init];
                                            
                                            // Encode to to base64
                                            [photoDetails setObject:fileName forKey:@"Path"];
                                            [photoDetails setObject:[NSString stringWithFormat:@"%lu", (unsigned long)imageData.length] forKey:@"Size"];
                                            
                                            NSArray *arr = [[NSArray alloc] initWithObjects:[self encodeStringTo64:modifiedAlbumName], nil];
                                            [photoDetails setObject:arr forKey:@"AlbumName"];
                                            [self.photoDic setObject:photoDetails forKey:fileName];
                                            
                                            [self.hashTableUrltofileName setObject:asset forKey:fileName];
                                        } else { // exist, only add new album
                                            photoDetails = [[self.photoDic objectForKey:fileName] mutableCopy];
                                            
                                            NSMutableArray *arr = [[photoDetails objectForKey:@"AlbumName"] mutableCopy];
                                            
                                            [arr addObject:[self encodeStringTo64:modifiedAlbumName]];
                                            [photoDetails setObject:arr forKey:@"AlbumName"];
                                            [self.photoDic setObject:photoDetails forKey:fileName];
                                        }
                                        
                                        avalibleCount++;
                                    }

                                }
                                
                            } else {
                                @synchronized (self) {
                                    self.unavaliableCloudcount++;
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
                    }];
                } else if (groupCount == customGroups.count) { // last album
                    [self fetchImageInCameraRoll:fetchSetting and:imageRequesSetting finish:^{
                        _localPhotoFetchFinished = YES;
                        _finished();
                    }];
                }
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
    
    PHFetchResult *smartGroups = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum
                                                                          subtype:PHAssetCollectionSubtypeAny
                                                                          options:nil];
    [smartGroups enumerateObjectsUsingBlock:^(PHAssetCollection *smartGroup, NSUInteger idx, BOOL *stop) {
        @autoreleasepool {
            if ([smartGroup.localizedTitle isEqualToString:@"Camera Roll"]) {
                //            DebugLog(@"smart group:%@", smartGroup.localizedTitle);
                // Fetch all the images from Camera Roll
                PHFetchResult *smartPhotos = [PHAsset fetchAssetsInAssetCollection:smartGroup options:fetchSetting];
                if (smartPhotos.count > 0) {
                    //                    DebugLog(@"->reading %lu photos in this album", (unsigned long)smartPhotos.count);
                    
                    __block int assetCount = 0;
                    [smartPhotos enumerateObjectsUsingBlock:^(PHAsset *asset, NSUInteger idx, BOOL *stop) {
                        [[PHImageManager defaultManager] requestImageDataForAsset:asset options:imageRequesSetting resultHandler:^(NSData *imageData, NSString *dataUTI, UIImageOrientation orientation, NSDictionary *info) {
                            // Create info list for photo
                            NSString *fileName = [self encodeStringTo64:[self getFileName:(NSURL *)[info objectForKey:@"PHImageFileURLKey"]]];
                            
                            if (fileName) {
                                
                                NSMutableDictionary *photoDetails = nil;
                                
                                @synchronized (self) {
                                    if (![self.photoDic valueForKey:fileName]) { // not exist
                                        
                                        photoDetails = [[NSMutableDictionary alloc] init];
                                        [photoDetails setObject:fileName forKey:@"Path"];
                                        [photoDetails setObject:[NSString stringWithFormat:@"%lu", (unsigned long)imageData.length] forKey:@"Size"];
                                        
                                        if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"isAndriodPlatform"] isEqualToString:@"TRUE"]) {
                                            
                                            [photoDetails setObject:@[[self encodeStringTo64:@"Camera Roll"]] forKey:@"AlbumName"];
                                            
                                        } else {
                                            //                                        [photoDetails setObject:@[] forKey:@"AlbumName"];
                                        }
                                        [self.photoDic setObject:photoDetails forKey:fileName];
                                        
                                        [self.hashTableUrltofileName setObject:asset forKey:fileName];
                                    }
                                }
                            }
                            @synchronized (self) {
                                
                                if (++photoCollectingCount % 50 == 0) {
                                    [self.delegate shouldUpdatePhotoNumber:photoCollectingCount];
                                }
                                
                                if (++assetCount == smartPhotos.count) { // last photo
                                    _finished();
                                }
                            }

                        }];
                    }];
                } else { // No Photos
                    _finished ();
                }
                
                *stop = YES;
            } else if ([smartGroup.localizedTitle isEqualToString:@"All Photos"]) {
                //            DebugLog(@"smart group:%@", smartGroup.localizedTitle);
                // Fetch all the images from Camera Roll
                PHFetchResult *smartPhotos = [PHAsset fetchAssetsInAssetCollection:smartGroup options:fetchSetting];
                if (smartPhotos.count > 0) {
                    //                    DebugLog(@"->reading %lu photos in this album", (unsigned long)smartPhotos.count);
                    __block int assetCount = 0;
                    [smartPhotos enumerateObjectsUsingBlock:^(PHAsset *asset, NSUInteger idx, BOOL *stop) {
                        [[PHImageManager defaultManager] requestImageDataForAsset:asset options:imageRequesSetting resultHandler:^(NSData *imageData, NSString *dataUTI, UIImageOrientation orientation, NSDictionary *info) {
                            if (imageData.length > 0 && info) {
                                // Create info list for photo
                                NSString *fileName = [self encodeStringTo64:[self getFileName:(NSURL *)[info objectForKey:@"PHImageFileURLKey"]]];
                                
                                if (fileName) {
                                    
                                    NSMutableDictionary *photoDetails = nil;
                                    
                                    @synchronized (self) {
                                        if (![self.photoDic valueForKey:fileName]) { // not exist
                                            
                                            photoDetails = [[NSMutableDictionary alloc] init];
                                            [photoDetails setObject:fileName forKey:@"Path"];
                                            [photoDetails setObject:[NSString stringWithFormat:@"%lu", (unsigned long)imageData.length] forKey:@"Size"];
                                            if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"isAndriodPlatform"] isEqualToString:@"TRUE"]) {
                                                [photoDetails setObject:@[[self encodeStringTo64:@"Camera Roll"]] forKey:@"AlbumName"];
                                            } else {
                                                [photoDetails setObject:@[] forKey:@"AlbumName"];
                                            }
                                            
                                            [self.photoDic setObject:photoDetails forKey:fileName];
                                            
                                            [self.hashTableUrltofileName setObject:asset forKey:fileName];
                                        }
                                    }
                                }
                                
                            } else {
                                @synchronized (self) {
                                    self.unavaliableCloudcount++;
                                }
                            }
                            
                            @synchronized (self) {
                                if (++photoCollectingCount % 50 == 0) {
                                    [self.delegate shouldUpdatePhotoNumber:photoCollectingCount];
                                }
                                
                                if (++assetCount == smartPhotos.count) { // last photo
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
        }
    }];
}

- (NSString *)getFileName:(NSURL *)url
{
    return [url lastPathComponent];
}

#pragma mark - OLD PHOTO LIBRARY
- (void)fetchPhotosUsingOldPhotoLibrary {
    
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
            
            photocallBackHandler(weakSelf.photoListSuperSet.count, weakSelf.photoStreamSet.count, 0);
        } else {
            // photo list is not a valid object
            _fetchfailure(@"Error happened when fetching photos using old library.", NO);
        }
    } andFailure:^(NSError *error) {
        [weakSelf createErrMsg:error];
    }];
}

- (void)createErrMsg:(NSError *)error
{
    NSString *errorMessage = nil;
    switch ([error code]) {
        case ALAssetsLibraryAccessUserDeniedError: {
            errorMessage = @"The user has declined access to it.";
            self.fetchfailure(errorMessage, YES);
        }
            break;
        case ALAssetsLibraryAccessGloballyDeniedError: {
            errorMessage = @"The app setting without photo permission.";
            self.fetchfailure(errorMessage, YES);
        }
            break;
        default:
            errorMessage = @"Reason unknown.";
            self.fetchfailure(errorMessage, NO);
            break;
    }
}

- (void)fetchALAssetCloudPhotosSuccess:(void (^)(void))success andFailure:(void (^)(NSError *))failure
{
    // enumerate only photos in cloud
    __weak typeof(self) weakSelf = self;
    [self.assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupPhotoStream usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        
        if (group == nil) { // when fetch ends, return a group = nil
            [weakSelf fetchALAssetLocalPhotoInCustomAlbumSuccess:success andFailure:failure];
            return;
        }
        
        [group setAssetsFilter:[ALAssetsFilter allPhotos]];
        if ([group numberOfAssets] > 0) {
            
            // enumerate photo assets
            [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                
                if (result) {
                    NSString * fileName = [self encodeStringTo64:result.defaultRepresentation.filename];
                    NSMutableDictionary *photoDetails = [[NSMutableDictionary alloc] init];
                    
                    [photoDetails setObject:fileName forKey:@"Path"];
                    [photoDetails setObject:[NSString stringWithFormat:@"%lld",result.defaultRepresentation.size] forKey:@"Size"];
                    
                    NSArray *arr = [[NSArray alloc] initWithObjects:[self encodeStringTo64:[group valueForProperty:ALAssetsGroupPropertyName]], nil];
                    [photoDetails setObject:arr forKey:@"AlbumName"];
                    
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
        
        if (group == nil) { // when fetch ends, return a group = nil
            [weakSelf fetchALAssetLocalPhotoInCameraRoll:success andFailure:failure];
            return;
        }
        
        [group setAssetsFilter:[ALAssetsFilter allPhotos]];
        if ([group numberOfAssets] > 0) {
            
            // enumerate photo assets
            [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                
                if (result) {
                    NSString * fileName = [self encodeStringTo64:result.defaultRepresentation.filename];
                    
                    if ([[self.duplicateDict allKeys] containsObject:[self encodeStringTo64:[group valueForProperty:ALAssetsGroupPropertyName]]] && (index == 0)) {
                        
                        int value = [[self.duplicateDict valueForKey:[self encodeStringTo64:[group valueForProperty:ALAssetsGroupPropertyName]]] intValue];
                        
                        value++;
                        
                        modifiedAlbumName = [NSString stringWithFormat:@"%@_VZ_%d",[group valueForProperty:ALAssetsGroupPropertyName],value];
                        
                        [self.duplicateDict setValue:[NSString stringWithFormat:@"%d",value] forKey:[self encodeStringTo64:modifiedAlbumName]];
                        
                    } else if (index == 0){
                        
                        [self.duplicateDict setValue:@"0" forKey:[self encodeStringTo64:[group valueForProperty:ALAssetsGroupPropertyName]]];
                        
                        modifiedAlbumName = [NSString stringWithString:[group valueForProperty:ALAssetsGroupPropertyName]];
                    }
                    
                    
                    if (![weakSelf.photoDic objectForKey:fileName]) {
                        NSMutableDictionary *photoDetails = [[NSMutableDictionary alloc] init];
                        
                        [photoDetails setObject:fileName forKey:@"Path"];
                        [photoDetails setObject:[NSString stringWithFormat:@"%lld",result.defaultRepresentation.size] forKey:@"Size"];
                        
                        NSArray *arr = [[NSArray alloc] initWithObjects:[self encodeStringTo64:[group valueForProperty:ALAssetsGroupPropertyName]], nil];
                        [photoDetails setObject:arr forKey:@"AlbumName"];
                        
                        [weakSelf.photoDic setObject:photoDetails forKey:fileName];
                        [weakSelf.hashTableUrltofileName setObject:result forKey:fileName];
                        
                        if (++photoCollectingCount % 50 == 0) {
                            [self.delegate shouldUpdatePhotoNumber:photoCollectingCount];
                        }
                    } else { // exist, update photo folder info
                        NSMutableDictionary *photoDetails = [[self.photoDic objectForKey:fileName] mutableCopy];
                        
                        NSMutableArray *arr = [[photoDetails objectForKey:@"AlbumName"] mutableCopy];
                        
                        //                        [arr addObject:[self encodeStringTo64:[group valueForProperty:ALAssetsGroupPropertyName]]];
                        [arr addObject:[self encodeStringTo64:modifiedAlbumName]];
                        
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
        
        if (group == nil) { // when fetch ends, return a group = nil
            success();
            return;
        }
        
        [group setAssetsFilter:[ALAssetsFilter allPhotos]];
        if ([group numberOfAssets] > 0) {
            
            // enumerate photo assets
            [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                
                if (result) {
                    NSString * fileName = [self encodeStringTo64:result.defaultRepresentation.filename];
                    if (![weakSelf.photoDic objectForKey:fileName]) {
                        NSMutableDictionary *photoDetails = [[NSMutableDictionary alloc] init];
                        
                        [photoDetails setObject:fileName forKey:@"Path"];
                        [photoDetails setObject:[NSString stringWithFormat:@"%lld",result.defaultRepresentation.size] forKey:@"Size"];
                        
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
    self.videoListSuperSet = [self.videoDic allValues];
}

- (void)createvideoLogfile {
    
    // New photo library support iOS 8 & above
    if(NSFoundationVersionNumber >= NSFoundationVersionNumber_iOS_8_0) {
        PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
        if (status == PHAuthorizationStatusAuthorized) { // granted
            [self fetchVideosUsingNewPhotoLibrary];
        } else if (status == PHAuthorizationStatusNotDetermined) { // Access has not been determined.
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                if (status == PHAuthorizationStatusAuthorized) {
                    [self fetchVideosUsingNewPhotoLibrary];
                } else {
                    _videofetchfailure(@"Video Access Not Granted.", YES);
                }
            }];
        } else {
            _videofetchfailure(@"Video Access Not Granted.", YES);
        }
    } else {
        [self fetchVideosUsingALAssetPhotoLibrary];
    }
}

#pragma mark - NEW PHOTO LIBRARY FETCH VIDEO (__IPHONE_8_0)
- (void)fetchVideosUsingNewPhotoLibrary
{
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
        
        [self finishFetchingVideos];
    }];
    
    // Read All photos from custom ablums
    [self fetchVideoInCustomAblum:onlyVideosOptions and:VideoRequestOptions finish:^{
        DebugLog(@"fetching ablum video done!");
        
        [self finishFetchingVideos];
    }];
}

- (void)fetchVideoInMyPhotoStream:(PHFetchOptions *)fetchSetting and:(PHVideoRequestOptions *)videoRequesSetting finish:(void (^)(void))_finished
{
    PHFetchResult *cloudGroups = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum
                                                                          subtype:PHAssetCollectionSubtypeAlbumMyPhotoStream
                                                                          options:nil];
    if (cloudGroups.count > 0) {
        [cloudGroups enumerateObjectsUsingBlock:^(PHAssetCollection *cloudGroup, NSUInteger idx, BOOL *stop) {
            //            DebugLog(@"cloud group:%@", cloudGroup.localizedTitle);
            // Fetch all the images from My Photo Stream
            PHFetchResult *myPhotoStreamVideos = [PHAsset fetchAssetsInAssetCollection:cloudGroup options:fetchSetting];
            
            if (myPhotoStreamVideos.count > 0) {
                //                    DebugLog(@"->reading %lu videos in this album", (unsigned long)myPhotoStreamVideos.count);
                
                __block int videoCount = 0;
                [myPhotoStreamVideos enumerateObjectsUsingBlock:^(PHAsset *asset, NSUInteger idx, BOOL *stop) {
                    [[PHImageManager defaultManager] requestAVAssetForVideo:asset options:videoRequesSetting resultHandler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
                        
                        if (asset && info) { // not cloud data
                            if ([asset isKindOfClass:[AVURLAsset class]]) {
                                AVURLAsset* urlAsset = (AVURLAsset*)asset;
                                
                                // Create info list for photo
                                NSString *fileName = [self encodeStringTo64:[self getFileName:urlAsset.URL]];
                                
                                // Get the videoSize
                                NSNumber *size;
                                [urlAsset.URL getResourceValue:&size forKey:NSURLFileSizeKey error:nil];
                                //                                    DebugLog(@"size is %f",[size floatValue]);
                                
                                NSMutableDictionary *videoDetails = [[NSMutableDictionary alloc] init];
                                [videoDetails setObject:fileName forKey:@"Path"];
                                [videoDetails setObject:[NSString stringWithFormat:@"%lld", [size longLongValue]] forKey:@"Size"];
                                
                                NSArray *arr = [[NSArray alloc] initWithObjects:[self encodeStringTo64:cloudGroup.localizedTitle], nil];
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
            //            DebugLog(@"custom group:%@", customGroup.localizedTitle);
            // Fetch all the images from My Photo Stream
            PHFetchResult *albumVideos = [PHAsset fetchAssetsInAssetCollection:customGroup options:fetchSetting];
            if (albumVideos.count > 0) {
                //                    DebugLog(@"->reading %lu videos in this album", (unsigned long)albumVideos.count);
                __block int videoCount = 0;
                __block int availableVideoCount = 0;
                __block NSString *modifiedAlbumName;
                
                [albumVideos enumerateObjectsUsingBlock:^(PHAsset *asset, NSUInteger index, BOOL *stop) {
                    [[PHImageManager defaultManager] requestAVAssetForVideo:asset options:videoRequesSetting resultHandler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
                        
                        if (asset && info) { // not cloud data
                            if ([asset isKindOfClass:[AVURLAsset class]]) {
                                AVURLAsset* urlAsset = (AVURLAsset*)asset;
                                
                                // Create info list for photo
                                NSString *fileName = [self encodeStringTo64:[self getFileName:urlAsset.URL]];
                                
                                // Get the videoSize
                                NSNumber *size;
                                [urlAsset.URL getResourceValue:&size forKey:NSURLFileSizeKey error:nil];
                                //                                    DebugLog(@"size is %lld",[size longLongValue]);
                                
                                NSMutableDictionary *videoDetails = nil;
                                @synchronized (self) {
                                    
                                    if ([[self.duplicateDict allKeys] containsObject:[self encodeStringTo64:customGroup.localizedTitle]] && (availableVideoCount == 0)) {
                                        
                                        int value = [[self.duplicateDict valueForKey:[self encodeStringTo64:customGroup.localizedTitle]] intValue];
                                        
                                        value++;
                                        
                                        modifiedAlbumName = [NSString stringWithFormat:@"%@_VZ_%d",customGroup.localizedTitle,value];
                                        
                                        [self.duplicateDict setValue:[NSString stringWithFormat:@"%d",value] forKey:[self encodeStringTo64:modifiedAlbumName]];
                                        
                                    } else if (availableVideoCount == 0){
                                        
                                        [self.duplicateDict setValue:@"0" forKey:[self encodeStringTo64:customGroup.localizedTitle]];
                                        
                                        modifiedAlbumName = [NSString stringWithString:customGroup.localizedTitle];
                                    }
                                    
                                    
                                    if (![self.videoDic valueForKey:fileName]) { // not exist
                                        //                                            DebugLog(@"add into dic");
                                        videoDetails = [[NSMutableDictionary alloc] init];
                                        [videoDetails setObject:fileName forKey:@"Path"];
                                        [videoDetails setObject:[NSString stringWithFormat:@"%lld", [size longLongValue]] forKey:@"Size"];
                                        
                                        NSArray *arr = [[NSArray alloc] initWithObjects:[self encodeStringTo64:customGroup.localizedTitle], nil];
                                        [videoDetails setObject:arr forKey:@"AlbumName"];
                                        [self.videoDic setObject:videoDetails forKey:fileName];
                                        
                                        [self.hashTableUrltofileName setObject:urlAsset forKey:fileName];
                                    } else { // exist, only add new album
                                        //                                            DebugLog(@"exist, update album info");
                                        videoDetails = [[self.videoDic objectForKey:fileName] mutableCopy];
                                        
                                        NSMutableArray *arr = [[videoDetails objectForKey:@"AlbumName"] mutableCopy];
                                        
                                        [arr addObject:[self encodeStringTo64:modifiedAlbumName]];
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
        [self fetchVideoInCameraRoll:fetchSetting and:videoRequesSetting finish:^{
            _localVideoFetchFinished = YES;
            _finished();
        }];
    }
}

- (void)fetchVideoInCameraRoll:(PHFetchOptions *)fetchSetting and:(PHVideoRequestOptions *)videoRequesSetting finish:(void (^)(void))_finished {
    
    PHFetchResult *smartGroups = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum
                                                                          subtype:PHAssetCollectionSubtypeAny
                                                                          options:nil];
    [smartGroups enumerateObjectsUsingBlock:^(PHAssetCollection *smartGroup, NSUInteger idx, BOOL *stop) {
        if ([smartGroup.localizedTitle isEqualToString:@"Camera Roll"]) {
            //            DebugLog(@"smart group:%@", smartGroup.localizedTitle);
            // Fetch all the images from Camera Roll
            PHFetchResult *smartVideos = [PHAsset fetchAssetsInAssetCollection:smartGroup options:fetchSetting];
            if (smartVideos.count > 0) {
                //                    DebugLog(@"->reading %lu photos in this album", (unsigned long)smartVideos.count);
                
                __block int videoCount = 0;
                [smartVideos enumerateObjectsUsingBlock:^(PHAsset *asset, NSUInteger index, BOOL *stop) {
                    [[PHImageManager defaultManager] requestAVAssetForVideo:asset options:videoRequesSetting resultHandler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
                        if ([asset isKindOfClass:[AVURLAsset class]]) {
                            AVURLAsset* urlAsset = (AVURLAsset*)asset;
                            
                            // Create info list for photo
                            NSString *fileName = [self encodeStringTo64:[self getFileName:urlAsset.URL]];
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
                                    
                                    //                                            [videoDetails setObject:@[] forKey:@"AlbumName"];
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
        } else if ([smartGroup.localizedTitle isEqualToString:@"All Photos"]) {
            //            DebugLog(@"smart group:%@", smartGroup.localizedTitle);
            // Fetch all the images from Camera Roll
            PHFetchResult *smartVideos = [PHAsset fetchAssetsInAssetCollection:smartGroup options:fetchSetting];
            if (smartVideos.count > 0) {
                //                    DebugLog(@"->reading %lu photos in this album", (unsigned long)smartVideos.count);
                
                __block int videoCount = 0;
                [smartVideos enumerateObjectsUsingBlock:^(PHAsset *asset, NSUInteger index, BOOL *stop) {
                    [[PHImageManager defaultManager] requestAVAssetForVideo:asset options:videoRequesSetting resultHandler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
                        if (asset && info) { // not cloud data
                            // Create info list for video
                            if ([asset isKindOfClass:[AVURLAsset class]]) {
                                AVURLAsset* urlAsset = (AVURLAsset*)asset;
                                
                                // Create info list for photo
                                NSString *fileName = [self encodeStringTo64:[self getFileName:urlAsset.URL]];
                                
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
                                        
                                        //                                                [videoDetails setObject:@[] forKey:@"AlbumName"];
                                        [self.videoDic setObject:videoDetails forKey:fileName];
                                        
                                        [self.hashTableUrltofileName setObject:urlAsset forKey:fileName];
                                    }
                                }
                            }
                        } else {
                            @synchronized (self) {
                                self.unavaliableVideoCloudcount++;
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
}

- (void)finishFetchingVideos
{
    if (_cloudVideoFetchFinished && _localVideoFetchFinished) {
        dispatch_once(&_once_v, ^{
            [self mergeAllVideos];
            
            if ([NSJSONSerialization isValidJSONObject:self.videoListSuperSet]) {
                NSData *photoData = [NSJSONSerialization dataWithJSONObject:self.videoListSuperSet options:NSJSONWritingPrettyPrinted error:nil];
                NSFileManager *fileManager = [NSFileManager defaultManager];
                [fileManager createFileAtPath:videoLogfilepath contents:photoData attributes: nil];
                
                videocallBackHandler([self.videoListSuperSet count], [self.videoStreamSet count], self.unavaliableVideoCloudcount);
            } else {
                _videofetchfailure(@"Error happened when fetching videos using new library.", NO);
            }
        });
    }
}

#pragma mark - FETCH VIDEOS USING ALASSET
- (void)fetchVideosUsingALAssetPhotoLibrary
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
            
            videocallBackHandler([weakSelf.videoListSuperSet count], [weakSelf.videoStreamSet count], 0);
        } else {
            weakSelf.videofetchfailure(@"Error happened when fetching videos using old library.", NO);
        }
        
    } andFailure:^(NSError *error) {
        weakSelf.videofetchfailure(@"Permission Error when fetching videos", NO);
    }];
}

- (void)fetchALAssetVideosInCloud:(void (^)(void))success andFailure:(void (^)(NSError *))failure
{
    // enumerate only photos
    __weak typeof(self) weakSelf = self;
    [self.assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupPhotoStream usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        if (group == nil) {
            [weakSelf fetchALAssetVideosInCustomAlbums:success andFailure:failure];
        }
        
        DebugLog(@"current group: %@", [group valueForProperty:ALAssetsGroupPropertyName]);
        
        [group setAssetsFilter:[ALAssetsFilter allVideos]];
        if ([group numberOfAssets] > 0) {
            
            [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                if (result) {
                    NSMutableDictionary *photoDetails = [[NSMutableDictionary alloc] init];
                    
                    [photoDetails setObject:[self encodeStringTo64:result.defaultRepresentation.filename] forKey:@"Path"];
                    [photoDetails setObject:[NSString stringWithFormat:@"%lld",result.defaultRepresentation.size] forKey:@"Size"];
                    
                    NSArray *arr = [[NSArray alloc] initWithObjects:[self encodeStringTo64:[group valueForProperty:ALAssetsGroupPropertyName]], nil];
                    [photoDetails setObject:arr forKey:@"AlbumName"];
                    
                    [weakSelf.videoStreamSet addObject:photoDetails];
                    [weakSelf.hashTableUrltofileName setObject:result forKey:[self encodeStringTo64:result.defaultRepresentation.filename]];
                    
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
        if (group == nil) {
            [weakSelf fetchALAssetVideosInCameraRolls:success andFailure:failure];
        }
        
        [group setAssetsFilter:[ALAssetsFilter allVideos]];
        if ([group numberOfAssets] > 0) {
            
            [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                if (result) {
                    NSString *fileName = [self encodeStringTo64:result.defaultRepresentation.filename];
                    
                    
                    if ([[self.duplicateDict allKeys] containsObject:[self encodeStringTo64:[group valueForProperty:ALAssetsGroupPropertyName]]] && (index == 0)) {
                        
                        int value = [[self.duplicateDict valueForKey:[self encodeStringTo64:[group valueForProperty:ALAssetsGroupPropertyName]]] intValue];
                        
                        value++;
                        
                        modifiedAlbumName = [NSString stringWithFormat:@"%@_VZ_%d",[group valueForProperty:ALAssetsGroupPropertyName],value];
                        
                        [self.duplicateDict setValue:[NSString stringWithFormat:@"%d",value] forKey:[self encodeStringTo64:modifiedAlbumName]];
                        
                    } else if (index == 0){
                        
                        [self.duplicateDict setValue:@"0" forKey:[self encodeStringTo64:[group valueForProperty:ALAssetsGroupPropertyName]]];
                        
                        modifiedAlbumName = [NSString stringWithString:[group valueForProperty:ALAssetsGroupPropertyName]];
                    }
                    
                    
                    if (![weakSelf.videoDic objectForKey:fileName]) {
                        NSMutableDictionary *photoDetails = [[NSMutableDictionary alloc] init];
                        
                        [photoDetails setObject:fileName forKey:@"Path"];
                        [photoDetails setObject:[NSString stringWithFormat:@"%lld",result.defaultRepresentation.size] forKey:@"Size"];
                        
                        NSArray *arr = [[NSArray alloc] initWithObjects:[self encodeStringTo64:[group valueForProperty:ALAssetsGroupPropertyName]], nil];
                        [photoDetails setObject:arr forKey:@"AlbumName"];
                        
                        [weakSelf.videoDic setObject:photoDetails forKey:fileName];
                        [weakSelf.hashTableUrltofileName setObject:result forKey:fileName];
                        
                        if (++videoCollectionCount % 5 == 0) {
                            [weakSelf.delegate shouldUpdateVideoNumber:videoCollectionCount];
                        }
                    } else {
                        NSMutableDictionary *photoDetails = [[self.videoDic objectForKey:fileName] mutableCopy];
                        
                        NSMutableArray *arr = [[photoDetails objectForKey:@"AlbumName"] mutableCopy];
                        
                        
                        [arr addObject:[self encodeStringTo64:modifiedAlbumName]];
                        
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
        if (group == nil) {
            success();
        }
        
        [group setAssetsFilter:[ALAssetsFilter allVideos]];
        if ([group numberOfAssets] > 0) {
            
            [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                if (result) {
                    NSString *fileName = [self encodeStringTo64:result.defaultRepresentation.filename];
                    if (![weakSelf.videoDic objectForKey:fileName]) {
                        NSMutableDictionary *photoDetails = [[NSMutableDictionary alloc] init];
                        
                        [photoDetails setObject:fileName forKey:@"Path"];
                        [photoDetails setObject:[NSString stringWithFormat:@"%lld",result.defaultRepresentation.size] forKey:@"Size"];
                        
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

- (void)getPhotoData:(NSString *)imageName Sucess:(photofetchsucess)fetchSucess{
    
    NSRange replaceRange = [imageName rangeOfString:@"\r\n"];
    if (replaceRange.location != NSNotFound){
        imageName = [imageName stringByReplacingCharactersInRange:replaceRange withString:@""];
    }
    
    if(NSFoundationVersionNumber >= NSFoundationVersionNumber_iOS_8_0) {
        PHAsset *myasset = (PHAsset *)[self.hashTableUrltofileName valueForKey:[self encodeStringTo64:imageName]]; // O(1)
        fetchSucess(myasset);
    } else {
        ALAsset *myasset = (ALAsset *)[self.hashTableUrltofileName valueForKey:[self encodeStringTo64:imageName]]; // O(1)
        fetchSucess(myasset);
    }
}


- (void)getVideoData:(NSString *)videoName Sucess:(videofetchsucess)fetchSucess{
    
    NSRange replaceRange = [videoName rangeOfString:@"\r\n"];
    if (replaceRange.location != NSNotFound){
        videoName = [videoName stringByReplacingCharactersInRange:replaceRange withString:@""];
    }
    
    if(NSFoundationVersionNumber >= NSFoundationVersionNumber_iOS_8_0) {
        id videoURL = [self.hashTableUrltofileName valueForKey:[self encodeStringTo64:videoName]]; // O(1)
        fetchSucess(videoURL);
    } else {
        ALAsset *myasset = (ALAsset *)[self.hashTableUrltofileName valueForKey:[self encodeStringTo64:videoName]];
        fetchSucess(myasset);
    }
}

- (NSString*)encodeStringTo64:(NSString*)fromString
{
    NSData *plainData = [fromString dataUsingEncoding:NSUTF8StringEncoding];
    NSString *base64String;
    if ([plainData respondsToSelector:@selector(base64EncodedStringWithOptions:)]) {
        base64String = [plainData base64EncodedStringWithOptions:kNilOptions];
    } else {
        base64String = [plainData base64Encoding]; // For ios 7 pre
    }
    
    return base64String;
}

@end
