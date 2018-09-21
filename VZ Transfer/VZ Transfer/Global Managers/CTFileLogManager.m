//
//  CTFileLogManager.m
//  VZTransferSocket
//
//  Created by Prakash Mac on 12/23/15.
//  Copyright © 2015 Testing. All rights reserved.
//

#import "CTFileLogManager.h"
#import <Photos/Photos.h>
#import "NSString+CTRootDocument.h"
#import "CTUserDevice.h"
#import "CTUserDefaults.h"

@interface CTFileLogManager()

@end

@implementation CTFileLogManager


- (void)storeFileList:(NSData *)data {
    
    self.fileList = [[CTFileList alloc] initFileListWithData:data]; // Create file list object.
    
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    // Get selected item list
    [userDefault setObject:self.fileList.selectItemList forKey:@"itemsList_MF"];
    
    // Get sender vendor ID
    if ([[CTUserDevice userDevice].phoneCombination isEqualToString:IOS_IOS]) {
        [CTUserDefaults sharedInstance].deviceVID = self.fileList.senderVID;
    }
    
    // Get device number if it's one to many
    [CTUserDevice userDevice].deviceCount = self.fileList.deviceCount;
    
    // Store flags
    [userDefault setBool:self.fileList.hasCloudPhotos forKey:@"hasCloudPhotos"];
    [userDefault setBool:self.fileList.hasCloudVideos forKey:@"hasCloudVideos"];
    
    // Save photo file list
    if (self.fileList.photoSelected) {
        [userDefault setValue:self.fileList.photoFileDic forKey:@"photoFileList"];
        [userDefault setValue:self.fileList.photoFileLog forKey:@"photoFilteredFileList"];
    }
    
    // Save video file list
    if (self.fileList.videoSelected) {
        [userDefault setValue:self.fileList.videoFileDic forKey:@"videoFileList"];
        [userDefault setValue:self.fileList.videoFileLog forKey:@"videoFilteredFileList"];
    }
    
    // Save calendar file list
    if (self.fileList.calendarSelected) {
        [userDefault setValue:self.fileList.calendarFilelist forKey:@"calFileList"];
    }
    
    // Save app list
    if (self.fileList.appListSelected) {
        [userDefault setValue:self.fileList.appFileList forKey:@"appsFileList"];
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        [self createAlbumFolderInPhotoApp];
    });
}

/*!
    @brief Try to create album folder inside system photo app based on the album information.
    @discussion This method running in seperate thread from transfer thread, and no need to wait for it to finish.
    @warning If error happened during folder creating, then no folder will created, and all the media belongs to that folder will go to camera roll/all photos.
 */
- (void)createAlbumFolderInPhotoApp {
    // Check target photo album
    PHFetchResult *localGroups = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    for (PHAssetCollection *album in localGroups) {
        if ([self.fileList.photoAlbumList containsObject:album.localizedTitle]) {
            [self.fileList.photoAlbumList removeObject:album.localizedTitle];
        }
    }
    
    // Create album for photos
    for (NSString *albumName in self.fileList.photoAlbumList) {
        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
            [PHAssetCollectionChangeRequest creationRequestForAssetCollectionWithTitle:albumName];
        } completionHandler:^(BOOL success, NSError *error) {
            if (!success) {
                DebugLog(@"Error creating album in file manager: %@", error);
            }
        }];
    }
}

- (NSInteger)packageSize {
    return self.fileList.videoPackageSize;
}

@end
