//
//  PhotoStoreHelper.m
//  storePhotosTest
//
//  Created by Sun, Xin on 6/14/16.
//  Copyright © 2016 Sun, Xin. All rights reserved.
//

#import "PhotoStoreHelper.h"
#import "PhotoStoreOperationQueue.h"
#import "NSDate+CTMVMConvenience.h"
#import "NSString+CTRootDocument.h"
#import <Photos/Photos.h>

@interface PhotoStoreHelper ()

@property (nonatomic, strong) NSString *rootPath;

@property (nonatomic, assign) NSInteger operationNumber;

@property (nonatomic, strong) NSArray<NSArray*> *dataSets;
@property (nonatomic, strong) NSMutableArray<NSOperationQueue *> *operationQueues;

@property (nonatomic, assign) BOOL isCancelled;

@end

@implementation PhotoStoreHelper

- (instancetype)initWithOperationDelegate:(id<PhotoStoreDelegate>)delegate andRootPath:(NSString *)path andDataSets:(NSArray *)dataSets
{
    self = [super init];
    if (self) {
        _dataSets = dataSets;
        _rootPath = path;
        _delegate = delegate;
        _operationNumber = _dataSets.count;
        
        _operationQueues = [[NSMutableArray alloc] initWithCapacity:_operationNumber];
        [self _createQueusForPhotoSaving];
    }
    
    return self;
}

/**
 * Create operation queue for each of the photo data set
 */
- (void)_createQueusForPhotoSaving
{
    int idx = 0;
    while (idx < _operationNumber) {
        PhotoStoreOperationQueue *queue = [[PhotoStoreOperationQueue alloc] initWithDataSet:(NSArray *)[_dataSets objectAtIndex:idx]];
        [queue setMaxConcurrentOperationCount:1];
        
        [_operationQueues addObject:queue];
        
        idx ++;
    }
}

- (void)_storePhotoToAblum:(NSDictionary *)photoDic {
    if (!photoDic) { // if videoDic is empty
        NSMutableDictionary *details = [[NSMutableDictionary alloc] init];
        [details setValue:@"Operation cannot be finished. Error happened when trying to get photo information." forKey:NSLocalizedDescriptionKey];
        NSError *error = [NSError errorWithDomain:@"VZVideoStoreError" code:404 userInfo:details];
        [self.delegate updateDuplicatePhoto:nil withPhotoInfo:nil withLocalIdentifier:nil success:NO orError:error];
        
        return;
    }
    
    NSString *fileName = (NSString *)[photoDic valueForKey:@"Path"];
    
    NSString *fileURL = [NSString stringWithFormat:@"%@/%@", _rootPath, [fileName stringByReplacingOccurrencesOfString:@"/" withString:@"_"]];
    if (!fileURL || ![[NSFileManager defaultManager] fileExistsAtPath:fileURL]) {
        NSMutableDictionary *details = [[NSMutableDictionary alloc] init];
        [details setValue:@"File cannot be found." forKey:NSLocalizedDescriptionKey];
        NSError *error = [NSError errorWithDomain:@"VZVideoStoreError" code:404 userInfo:details];
        [self.delegate updateDuplicatePhoto:nil withPhotoInfo:photoDic withLocalIdentifier:nil success:NO orError:error];
        
        return;
    }
    
    NSArray *folders = (NSArray *)[photoDic objectForKey:@"albumName"];
    
    NSString *videoComponentURL = nil;
    BOOL isLivePhoto = [self currentPhotoIsLivePhoto:photoDic];
    if (isLivePhoto) {
        videoComponentURL = [[[NSString appRootDocumentDirectory] stringByAppendingPathComponent:@"VZTransferLivePhoto"] stringByAppendingPathComponent:[photoDic valueForKey:@"Resource"]]; // Get live photo video component path, document folder path may vary.
        if (![[NSFileManager defaultManager] fileExistsAtPath:videoComponentURL] || SYSTEM_VERSION_LESS_THAN(@"9.1")) {
            isLivePhoto = NO; // No video component will be considered as static photo.
            [[CTUserDefaults sharedInstance] addErrorLivePhoto:fileName];
        }
    }
    
    // Add it to the photo library
    __block BOOL crashHappened = NO;
    __block NSString *_localID = nil;
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        @try {
            PHAssetChangeRequest *assetRequest = nil;
            if (isLivePhoto) {
                // Live photo
                PHAssetCreationRequest *creationRequest = [PHAssetCreationRequest creationRequestForAsset];
                
                // Create live photo resource options
                PHAssetResourceCreationOptions *photoOptions = [[PHAssetResourceCreationOptions alloc] init];
                photoOptions.uniformTypeIdentifier = @"public.jpeg";
                PHAssetResourceCreationOptions *videoOptions = [[PHAssetResourceCreationOptions alloc] init];
                videoOptions.uniformTypeIdentifier = @"com.apple.quicktime-movie";
                
                // Attach live photo resource
                [creationRequest addResourceWithType:PHAssetResourceTypePhoto fileURL:[NSURL fileURLWithPath:fileURL] options:nil];
                // Attach live photo video resource
                [creationRequest addResourceWithType:PHAssetResourceTypePairedVideo fileURL:[NSURL fileURLWithPath:videoComponentURL] options:nil];
                
                assetRequest = creationRequest;
            } else {
                // Static photo save
                assetRequest = [PHAssetChangeRequest creationRequestForAssetFromImageAtFileURL:[NSURL fileURLWithPath:fileURL]];
            }
            
            NSAssert(assetRequest, @"Asset request is null for some reason. Exception will be catched, no image will be stored.");
            // Insert property for image asset.
            if ([photoDic valueForKey:@"creationDate"]) {
                NSDate *photocreateDate = [NSDate dateFromString:[photoDic valueForKey:@"creationDate"]];
                [assetRequest setCreationDate:photocreateDate];
            }
            
            if ([[photoDic valueForKey:@"isFavorite"] boolValue]) {
                [assetRequest setFavorite:[[photoDic valueForKey:@"isFavorite"] boolValue]];
            }
            
            for (NSString *folderID in folders) {
                // if have custom albums
                PHFetchOptions *options = [PHFetchOptions new];
                options.predicate = [NSPredicate predicateWithFormat:@"title = %@", folderID];
                
                PHAssetCollection *collection = [[PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:options] firstObject];
                if (collection) {
                    // Save photo in album
                    PHAssetCollectionChangeRequest *assetCollectionChangeRequest = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:collection];
                    [assetCollectionChangeRequest addAssets:@[[assetRequest placeholderForCreatedAsset]]];
                }
            }
            
            if (assetRequest.placeholderForCreatedAsset) {
                _localID = assetRequest.placeholderForCreatedAsset.localIdentifier; // track the localID for duplicate logic
            }
        } @catch (NSException *exception) {
            DebugLog(@"Error:%@", exception.description);
            crashHappened = YES;
        }
        
    } completionHandler:^(BOOL success, NSError *error) {
        if (crashHappened) {
            NSMutableDictionary *details = [[NSMutableDictionary alloc] init];
            [details setValue:@"Operation cannot be finished. Error happened when trying to perform request." forKey:NSLocalizedDescriptionKey];
            NSError *error = [NSError errorWithDomain:@"VZVideoStoreError" code:404 userInfo:details];
            [self.delegate updateDuplicatePhoto:videoComponentURL ? @[fileURL, videoComponentURL] : @[fileURL] withPhotoInfo:photoDic withLocalIdentifier:_localID success:NO orError:error];
        } else if (success) {
            [self.delegate updateDuplicatePhoto:videoComponentURL ? @[fileURL, videoComponentURL] : @[fileURL] withPhotoInfo:photoDic withLocalIdentifier:_localID success:YES orError:nil];
        } else {
            DebugLog(@"Error:%@", error.localizedDescription);
            [self.delegate updateDuplicatePhoto:videoComponentURL ? @[fileURL, videoComponentURL] : @[fileURL] withPhotoInfo:photoDic withLocalIdentifier:_localID success:NO orError:error];
        }
    }];
}

- (void)_storeVideoToAblum:(NSDictionary *)videoDic
{
    if (!videoDic) { // if videoDic is empty
        NSMutableDictionary *details = [[NSMutableDictionary alloc] init];
        [details setValue:@"Operation cannot be finished. Error happened when trying to get video information." forKey:NSLocalizedDescriptionKey];
        NSError *error = [NSError errorWithDomain:@"VZVideoStoreError" code:404 userInfo:details];
        [self.delegate updateDuplicateVideo:nil withVideoInfo:nil withLocalIdentifier:nil success:NO orError:error];
        
        return;
    }
    
    NSString *tempstr = [videoDic valueForKey:@"Path"];
    NSString *theFileName = [tempstr lastPathComponent];
    
    NSString *fileURL = @"";
    if (self.isCrossPlatform) {
        fileURL = [NSString stringWithFormat:@"%@/%@", _rootPath, [tempstr stringByReplacingOccurrencesOfString:@"/" withString:@"_"]];
    } else {
        fileURL = [NSString stringWithFormat:@"%@/%@", _rootPath, theFileName];
    }
    
    if (!fileURL) {
        NSMutableDictionary *details = [[NSMutableDictionary alloc] init];
        [details setValue:@"File cannot be found." forKey:NSLocalizedDescriptionKey];
        NSError *error = [NSError errorWithDomain:@"VZVideoStoreError" code:404 userInfo:details];
        [self.delegate updateDuplicateVideo:nil withVideoInfo:videoDic withLocalIdentifier:nil success:NO orError:error];
        
        return;
    }
    
    // file size
    NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:fileURL error:nil];
    NSNumber *fileSizeNumber = [fileAttributes objectForKey:NSFileSize];
    long long fileSize = [fileSizeNumber longLongValue];
    
    NSArray *folders = (NSArray *)[videoDic objectForKey:@"albumName"];
    
    // Add it to the photo library
    __block BOOL crashHappened = NO;
    __block NSString *_localID = nil;
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        @try {
            PHAssetChangeRequest *assetChangeRequest = [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:[NSURL fileURLWithPath:fileURL]];
        
            if ([videoDic valueForKey:@"creationDate"]) {
                NSDate *photocreateDate = [NSDate dateFromString:[videoDic valueForKey:@"creationDate"]];
                [assetChangeRequest setCreationDate:photocreateDate];
            }
            
            if ([[videoDic valueForKey:@"isFavorite"] boolValue]) {
                [assetChangeRequest setFavorite:[[videoDic valueForKey:@"isFavorite"] boolValue]];
            }
            
            for (NSString *folderID in folders) {
                // if have custom albums
                PHFetchOptions *options = [PHFetchOptions new];
                options.predicate = [NSPredicate predicateWithFormat:@"title = %@", folderID];
                
                PHAssetCollection *collection = [[PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:options] firstObject];
                if (collection) {
                    // Save video in album
                    PHAssetCollectionChangeRequest *assetCollectionChangeRequest = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:collection];
                    [assetCollectionChangeRequest addAssets:@[[assetChangeRequest placeholderForCreatedAsset]]];
                    
                }
            }
            
            if (assetChangeRequest.placeholderForCreatedAsset) {
                _localID = assetChangeRequest.placeholderForCreatedAsset.localIdentifier; // track the localID for duplicate logic
            }
        } @catch (NSException *exception) {
            DebugLog(@"Error:%@", exception.description);
            crashHappened = YES;
        }
    } completionHandler:^(BOOL success, NSError *error) {
        if (crashHappened) {
            NSLog(@"video saving crashed:%@", [fileURL lastPathComponent]);
            NSMutableDictionary *details = [[NSMutableDictionary alloc] init];
            [details setValue:@"Operation cannot be finished. Error happened when trying to perform request." forKey:NSLocalizedDescriptionKey];
            NSError *error = [NSError errorWithDomain:@"VZVideoStoreError" code:404 userInfo:details];
            [self.delegate updateDuplicateVideo:fileURL withVideoInfo:videoDic withLocalIdentifier:_localID success:NO orError:error];
        } else if (success) {
            NSLog(@"video saving success:%@", [fileURL lastPathComponent]);
            [self.delegate updateDuplicateVideo:fileURL withVideoInfo:videoDic withLocalIdentifier:_localID success:YES orError:nil];
        } else {
            NSLog(@"video saving error happened:%@; error:%@", [fileURL lastPathComponent], error.localizedDescription);
            NSError *storeErr = nil;
            NSMutableDictionary* details = [NSMutableDictionary dictionary];
            if (![videoDic valueForKey:@"Size"]) { // Size
                [details setValue:@"Video file is not fully transferred." forKey:NSLocalizedDescriptionKey];
                storeErr = [NSError errorWithDomain:@"VZVideoStoreError" code:502 userInfo:details];
            } else if (fileSize < [[videoDic valueForKey:@"Size"] longLongValue]) {
                [details setValue:@"Video file is not fully transferred." forKey:NSLocalizedDescriptionKey];
                storeErr = [NSError errorWithDomain:@"VZVideoStoreError" code:502 userInfo:details];
            } else {
                [details setValue:@"Device doesn't support video resolution. Or video is broken." forKey:NSLocalizedDescriptionKey];
                storeErr = [NSError errorWithDomain:@"VZVideoStoreError" code:403 userInfo:details];
            }
            
            [self.delegate updateDuplicateVideo:fileURL withVideoInfo:videoDic withLocalIdentifier:_localID success:NO orError:storeErr];
        }
    }];
}

- (void)startSavingPhotos
{
    for (PhotoStoreOperationQueue *queue in _operationQueues) {
        @autoreleasepool {
            [queue addOperationWithTarget:self selector:@selector(_storePhotoToAblum:)];
        }
    }
}

- (void)startSavingVideos
{
    for (PhotoStoreOperationQueue *queue in _operationQueues) {
        @autoreleasepool {
            [queue addOperationWithTarget:self selector:@selector(_storeVideoToAblum:)];
        }
    }
}

#pragma mark - Convenients
- (BOOL)currentPhotoIsLivePhoto:(NSDictionary *)info {
    // Consider target image is live photo when live photo flog is set to true and resouce is attach for saving, and current receiver deivce iOS version is at least 9.1; Otherwise will saved as plain photo.
    return [[info valueForKey:@"isLivePhoto"] boolValue] && [info valueForKey:@"Resource"];
}

@end
