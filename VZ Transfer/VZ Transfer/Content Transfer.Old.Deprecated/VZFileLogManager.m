//
//  VZFileLogManager.m
//  VZTransferSocket
//
//  Created by Prakash Mac on 12/23/15.
//  Copyright © 2015 Testing. All rights reserved.
//

#import "VZFileLogManager.h"
#import <Photos/Photos.h>
#import "NSString+CTContentTransferRootDocuments.h"
#import "CTUserDevice.h"

@interface VZFileLogManager()

@property (nonatomic, strong) NSMutableArray *photoalbumList;

@end

@implementation VZFileLogManager
@synthesize itemListReceived;
@synthesize photoFileListReceived;
@synthesize videoFileListReceived;
@synthesize albumPhotoList;
@synthesize albumVideoList;
@synthesize calenderFileList;
@synthesize reminderFileList;

- (NSMutableArray *)photoalbumList
{
    if (!_photoalbumList) {
        _photoalbumList = [[NSMutableArray alloc] init];
    }
    
    return _photoalbumList;
}

- (void)storeFileList:(NSData *)data {
    
//    // Init duplicate list for photo and video
//    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"PHOTODUPLICATELIST"]) {
////        NSMutableArray *duplicatePhotoList  = [[NSMutableArray alloc] init];
////        [[NSUserDefaults standardUserDefaults] setObject:duplicatePhotoList forKey:@"PHOTODUPLICATELIST"];
//        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"PHOTODUPLICATELIST"];
//    }
//    
//    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"VIDEODUPLICATELIST"]) {
////        NSMutableArray *duplicateVideoList  = [[NSMutableArray alloc] init];
////        [[NSUserDefaults standardUserDefaults] setObject:duplicateVideoList forKey:@"VIDEODUPLICATELIST"];
//        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"VIDEODUPLICATELIST"];
//    }
    
    NSError* error = nil;
    NSDictionary* dict = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    
    NSMutableDictionary *itemList = [[dict valueForKey:@"itemList"] mutableCopy];
    
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    
    if ([[itemList valueForKey:@"contacts"] isKindOfClass:[NSDictionary class]] || [[itemList valueForKey:@"photos"] isKindOfClass:[NSDictionary class]] || [[itemList valueForKey:@"videos"] isKindOfClass:[NSDictionary class]]) {
        
        NSMutableDictionary *tempdict  = [[NSMutableDictionary alloc] init];
        
        [tempdict setValue:[[itemList valueForKey:@"contacts"] valueForKey:@"status"] forKey:@"contacts"];
        [tempdict setValue:[[itemList valueForKey:@"photos"] valueForKey:@"status"] forKey:@"photos"];
        [tempdict setValue:[[itemList valueForKey:@"videos"] valueForKey:@"status"] forKey:@"videos"];
        [tempdict setValue:[[itemList valueForKey:@"reminder"] valueForKey:@"status"] forKey:@"reminder"];
        [tempdict setValue:[[itemList valueForKey:@"calendar"] valueForKey:@"status"] forKey:@"calendar"];
    
        self.itemListReceived = [tempdict mutableCopy];
    }
    
    [userDefault setObject:itemList forKey:@"itemsList_MF"];
    [userDefault synchronize];
   
    self.photoFileListReceived = [dict valueForKey:@"photoFileList"];
    self.videoFileListReceived = [dict valueForKey:@"videoFileList"];
    self.calenderFileList = [dict valueForKey:@"calendarFileList"];

    self.model = [[dict valueForKey:@"videoPkgSize"] integerValue];
    
    BOOL hasCloudPhotos = [dict boolForKey:@"hasCloudPhotos"];
    BOOL hasCloudVideos = [dict boolForKey:@"hasCloudVideos"];
    [userDefault setBool:hasCloudPhotos forKey:@"hasCloudPhotos"];
    [userDefault setBool:hasCloudVideos forKey:@"hasCloudVideos"];
    
    [userDefault setObject:self.itemListReceived forKey:@"itemList"];
    
    if ([[self.itemListReceived valueForKey:@"photos"] isEqualToString:@"true"]) {
        [self createNewPhotoLogFile];
    }
    
    if ([[self.itemListReceived valueForKey:@"videos"] isEqualToString:@"true"]) {
        [self createNewVideoLogFile];
    }
    
    if ([[self.itemListReceived valueForKey:@"calendar"] isEqualToString:@"true"]) {
        [self createCalenderLogFile];
    }
}

- (void) getListFromAblum {
    
    NSString *basePath = [NSString appRootDocumentDirectory];
    
    NSData *data = [[NSFileManager defaultManager] contentsAtPath:[NSString stringWithFormat:@"%@/VZPhotoLogfile.txt",basePath]];
    
//    NSString *response = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSArray *jsonObject = nil;
    if (data) {
        jsonObject = [NSJSONSerialization JSONObjectWithData:data
                                                     options:0 error:NULL];
    }
    
    self.albumPhotoList = jsonObject;
    
    data = [[NSFileManager defaultManager] contentsAtPath:[NSString stringWithFormat:@"%@/VZVideoLogfile.txt",basePath]];
    
    jsonObject = nil;
    if (data) {
        jsonObject = [NSJSONSerialization JSONObjectWithData:data
                                                     options:0 error:NULL];
    }

    
    self.albumVideoList = jsonObject;
}


- (void)clearAllLogFile {
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"items"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"photoFileList"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"videoFileList"];
}

-(void) filterExistingPhotoLogFile {
    
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    
    NSMutableArray *oldPhotoFileList = [[userDefault valueForKey:@"photoFileList"] mutableCopy];
    
    NSMutableArray *newPhotoFileList = [[NSMutableArray alloc] init];
    
    NSString *path = @"Path";
    
    for (NSDictionary *dict in self.photoFileListReceived) {
        
        NSPredicate *filter = [NSPredicate predicateWithFormat:@"%K == %@",path,[dict valueForKey:@"Path"]];
        
        NSArray *filteredContacts = [oldPhotoFileList filteredArrayUsingPredicate:filter];
        
        BOOL flag = YES;
        
        if ([filteredContacts count] > 0) {
            
            NSMutableDictionary *newdict = [[NSMutableDictionary alloc] initWithDictionary:[filteredContacts objectAtIndex:0]];
            
            
            if ([[newdict valueForKey:@"status"] isEqualToString:@"YES"]) {
                
                // Check in the Album if not available then set status to NO
                
              
                NSPredicate *filter1 = [NSPredicate predicateWithFormat:@"%K == %@",path,[newdict valueForKey:@"albumPath"]];
                
                NSArray *filteredContacts1 = [albumPhotoList filteredArrayUsingPredicate:filter1];
                
                
                if ([filteredContacts1 count] > 0) {
                    // It means it is already in album dont download again
                    flag = NO;
                }
            }
            
        }
        
        if (flag == YES ) {
            
            NSMutableDictionary *newdict = [[NSMutableDictionary alloc] init];
            
            [newdict setValue:[dict valueForKey:@"Path"] forKey:@"Path"];
            
            [newdict setValue:[dict valueForKey:@"Size"] forKey:@"Size"];
            
            [newdict setValue:@"NO" forKey:@"status"];
            
            [newdict setValue:@"NO" forKey:@"albumPath"];
            
            [newPhotoFileList addObject:newdict];
            
            [oldPhotoFileList addObject:newdict];
            
        }
    }
    
    [userDefault setValue:newPhotoFileList forKey:@"photoFilteredFileList"];
    
    [userDefault setValue:oldPhotoFileList forKey:@"photoFileList"];
    
}

- (void) filterExistingVideoLogFile {
    
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    
    NSMutableArray *oldPhotoFileList = [[userDefault valueForKey:@"videoFileList"] mutableCopy];
    
    NSMutableArray *newPhotoFileList = [[NSMutableArray alloc] init];
    
    NSString *path = @"Path";
    
    for (NSDictionary *dict in self.videoFileListReceived) {
        
//        NSString *imageName = [NSString stringWithFormat:@"%K = %@",path,[dict valueForKey:@"Path"]];
        
        NSPredicate *filter = [NSPredicate predicateWithFormat:@"%K == %@",path,[dict valueForKey:@"Path"]];
        
//        NSPredicate *filter = [NSPredicate predicateWithFormat:imageName];
        
        NSArray *filteredContacts = [oldPhotoFileList filteredArrayUsingPredicate:filter];
        
        BOOL flag = YES;
        
        if ([filteredContacts count] > 0) {
            
            NSMutableDictionary *newdict = [[NSMutableDictionary alloc] initWithDictionary:[filteredContacts objectAtIndex:0]];
            
            
            if ([[newdict valueForKey:@"status"] isEqualToString:@"YES"]) {
                
                // Check in the Album if not available then set status to NO
                
//                NSString *imageName1 = [NSString stringWithFormat:@"albumPath = %@",[newdict valueForKey:@"Path"]];
                
//                NSPredicate *filter1 = [NSPredicate predicateWithFormat:imageName1];
                
                 NSPredicate *filter1 = [NSPredicate predicateWithFormat:@"%K == %@",path,[newdict valueForKey:@"albumPath"]];
                
                NSArray *filteredContacts = [albumVideoList filteredArrayUsingPredicate:filter1];
                
                
                if ([filteredContacts count] > 0) {
                    // It means it is already in album dont download again
                    flag = NO;
                }
            }
            
        }
        
        if (flag == YES ) {
            
            NSMutableDictionary *newdict = [[NSMutableDictionary alloc] init];
            
            [newdict setValue:[dict valueForKey:@"Path"] forKey:@"Path"];
            
            [newdict setValue:[dict valueForKey:@"Size"] forKey:@"Size"];
            
            [newdict setValue:@"NO" forKey:@"status"];
            
            [newdict setValue:@"NO" forKey:@"albumPath"];
            
            [newPhotoFileList addObject:newdict];
            
            [oldPhotoFileList addObject:newdict];
            
        }
    }
    
    [userDefault setValue:newPhotoFileList forKey:@"videoFilteredFileList"];
    
    [userDefault setValue:oldPhotoFileList forKey:@"videoFileList"];
    
}


- (void)createNewPhotoLogFile {
    
    NSMutableArray *newPhotoLog = [[NSMutableArray alloc] init];
    NSMutableDictionary *newPhotoDic = [[NSMutableDictionary alloc] init];
    
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
//    NSArray *duplicateList = (NSArray *)[[NSUserDefaults standardUserDefaults] valueForKey:@"PHOTODUPLICATELIST"];
    
    NSArray *tempArr = [[NSArray alloc] init];
    
    for (NSDictionary *dict in self.photoFileListReceived) {
        @autoreleasepool {
            NSMutableDictionary *newdict = [[NSMutableDictionary alloc] init];
            
            [newdict setValue:[self decodeStringTo64:[dict valueForKey:@"Path"]] forKey:@"Path"];
            
            [newdict setValue:[dict valueForKey:@"Size"] forKey:@"Size"];
            
            [newdict setValue:@"NO" forKey:@"status"];
            
            [newdict setValue:@"NO" forKey:@"albumPath"];
            
            if ([dict valueForKey:@"creationDate"]) {
                [newdict setValue:[dict valueForKey:@"creationDate"] forKey:@"creationDate"];
            }
            
            if ([dict valueForKey:@"isFavorite"]) {
                
                [newdict setValue:[dict valueForKey:@"isFavorite"] forKey:@"isFavorite"];
            }
            
            if ([[CTUserDevice userDevice].phoneCombination isEqualToString:IOS_Andriod]) {
                [newdict setValue:[self getAlbumNameForAndroid:[dict valueForKey:@"AlbumName"]] forKey:@"albumName"];
            } else {
                if ([dict valueForKey:@"AlbumName"]) { // AlbumName is exist
                    [newdict setValue:[self AlbumdecodeStringTo64:[dict valueForKey:@"AlbumName"]] forKey:@"albumName"];
                } else {
                    [newdict setValue:@[] forKey:@"albumName"]; // set empty
                }
            }
            
//            if (![duplicateList containsObject:newdict]) {
                [newPhotoLog addObject:newdict];
                if ([[CTUserDevice userDevice].phoneCombination isEqualToString:IOS_Andriod]) {
                    [newPhotoDic setObject:newdict forKey:[[self decodeStringTo64:[dict valueForKey:@"Path"]] stringByReplacingOccurrencesOfString:@"/" withString:@"_"]];
                } else {
                    [newPhotoDic setObject:newdict forKey:[[self decodeStringTo64:[dict valueForKey:@"Path"]] lastPathComponent]];
                }
//            }
            
            // Find the ablum list
            tempArr = [newdict valueForKey:@"albumName"];
            
            for (NSString *albumName in tempArr) {
                
                if (![self.photoalbumList containsObject:albumName]) {
                    [self.photoalbumList addObject:albumName];
                }
            }
        }
    }
    
    NSUserDefaults *userdefault = [NSUserDefaults standardUserDefaults];
    
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"PHOTOALBUMLIST"];
    
    [userdefault setObject:self.photoalbumList forKey:@"PHOTOALBUMLIST"];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        [self creatAllPhotoAlbum];
    });
    
    [userDefault setValue:newPhotoDic forKey:@"photoFileList"];
    [userDefault setValue:newPhotoLog forKey:@"photoFilteredFileList"];
    [userDefault synchronize];
}

- (void)createCalenderLogFile {
    
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault setValue:self.calenderFileList forKey:@"calFileList"];
    
    DebugLog(@"%@", self.calenderFileList);
}

- (NSArray *)getAlbumNameForAndroid:(NSArray *)albums
{
    DebugLog(@"Album Name received : %@",albums);
    
    NSMutableArray *iphoneAlbumName = [[NSMutableArray alloc] init];
    for (NSString *androidAlbum in albums) {
        
        NSString *androidAlbumdecoded = [self decodeStringTo64:androidAlbum];
        
        if (androidAlbumdecoded.length > 0 && [[androidAlbumdecoded lastPathComponent] rangeOfString:@"DCIM"].location == NSNotFound) {
            [iphoneAlbumName addObject:[androidAlbumdecoded lastPathComponent]];
        }
    }
    
    return iphoneAlbumName;
}

- (void)createNewVideoLogFile {
    
    NSMutableArray *newVideoLog = [[NSMutableArray alloc] init];
    NSMutableDictionary *newVideoDic = [[NSMutableDictionary alloc] init];
    
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];

//    NSArray *duplicateList = [[NSUserDefaults standardUserDefaults] valueForKey:@"VIDEODUPLICATELIST"];
    
    NSMutableArray *videoalbumList = [[NSMutableArray alloc] init];
    
    NSArray *tempArr = [[NSArray alloc] init];

    if ([[CTUserDevice userDevice].phoneCombination isEqualToString:IOS_Andriod]) {
        for (NSDictionary *dict in self.videoFileListReceived) {
            
            NSString *encodedPath = [dict stringForKey:@"Path"];
            if (encodedPath.length == 0) {
                continue;
            }
            
            NSString *path = [self decodeStringTo64:encodedPath];
            NSArray *components = [path componentsSeparatedByString:@"."];
            NSString *type = [components lastObject]; // last component should be extension
            
            if (type && ([[type lowercaseString] isEqualToString:@"m4v"] || [[type lowercaseString] isEqualToString:@"mp4"] || [[type lowercaseString] isEqualToString:@"mov"])) {
                NSMutableDictionary *newdict = [[NSMutableDictionary alloc] init];
                
                [newdict setValue:[self decodeStringTo64:[dict valueForKey:@"Path"]] forKey:@"Path"];
                
                [newdict setValue:[dict valueForKey:@"Size"] forKey:@"Size"];
                
                [newdict setValue:@"NO" forKey:@"status"];
                
                [newdict setValue:@"NO" forKey:@"albumPath"];
                
                [newdict setValue:[self getAlbumNameForAndroid:[dict valueForKey:@"AlbumName"]] forKey:@"albumName"];
                
//                if (![duplicateList containsObject:newdict]) {
                    [newVideoLog addObject:newdict];
                    [newVideoDic setObject:newdict forKey:[[self decodeStringTo64:[dict valueForKey:@"Path"]] stringByReplacingOccurrencesOfString:@"/" withString:@"_"]];
//                }
                
                // Find the ablum list
                tempArr = [newdict valueForKey:@"albumName"];
                
                for (NSString *albumName in tempArr) {
                    
                    if (![self.photoalbumList containsObject:albumName]) {
                        
                        [videoalbumList addObject:albumName];
                        [self.photoalbumList addObject:albumName];
                    }
                }
            }
        }
    } else {
        for (NSDictionary *dict in self.videoFileListReceived) {
            
            NSMutableDictionary *newdict = [[NSMutableDictionary alloc] init];
            
            [newdict setValue:[self decodeStringTo64:[dict valueForKey:@"Path"]] forKey:@"Path"];
            
            [newdict setValue:[dict valueForKey:@"Size"] forKey:@"Size"];
            
            [newdict setValue:@"NO" forKey:@"status"];
            
            [newdict setValue:@"NO" forKey:@"albumPath"];
            
            if ([dict valueForKey:@"creationDate"]) {
                [newdict setValue:[dict valueForKey:@"creationDate"] forKey:@"creationDate"];
            }
            
            if ([dict valueForKey:@"isFavorite"]) {
                
                [newdict setValue:[dict valueForKey:@"isFavorite"] forKey:@"isFavorite"];
            }
            
            if ([dict valueForKey:@"AlbumName"]) {
                [newdict setValue:[self AlbumdecodeStringTo64:[dict valueForKey:@"AlbumName"]] forKey:@"albumName"];
            }
            
//            if (![duplicateList containsObject:newdict]) {
                [newVideoLog addObject:newdict];
                [newVideoDic setObject:newdict forKey:[[self decodeStringTo64:[dict valueForKey:@"Path"]] lastPathComponent]];
//            }
            
            // Find the ablum list
            tempArr = [newdict valueForKey:@"albumName"];
            
            for (NSString *albumName in tempArr) {
                
                if (![self.photoalbumList containsObject:albumName] && ![videoalbumList containsObject:albumName]) {
                    
                    [videoalbumList addObject:albumName];
                    [self.photoalbumList addObject:albumName];
                }
            }
            
        }
    }
    
    NSUserDefaults *userdefault = [NSUserDefaults standardUserDefaults];
    
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"VIDEOALBUMLIST"];
    
    [userdefault setObject:videoalbumList forKey:@"VIDEOALBUMLIST"];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        [self createAllVideoAlbum];
    });

    
//    DebugLog(@"Video Album list : %@",videoalbumList);
    
    [userDefault setValue:newVideoDic forKey:@"videoFileList"];
    [userDefault setValue:newVideoLog forKey:@"videoFilteredFileList"];
    [userDefault synchronize];
}


- (void)creatAllPhotoAlbum
{
    NSMutableArray *photoAlbumList = [[[NSUserDefaults standardUserDefaults] valueForKey:@"PHOTOALBUMLIST"] mutableCopy];
    
    // REPLACE ALL OF THE OLD PHOTO LIBARAY INTO NEW LIBARAY FOR RECEIVER SIDE LOGIC
    
    // Check target photo album
    PHFetchResult *localGroups = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    for (PHAssetCollection *test in localGroups) {
        if ([photoAlbumList containsObject:test.localizedTitle]) {
            [photoAlbumList removeObject:test.localizedTitle];
        }
    }
    
    // Create album for photos
    for (NSString *albumName in photoAlbumList) {
        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
            [PHAssetCollectionChangeRequest creationRequestForAssetCollectionWithTitle:albumName];
        } completionHandler:^(BOOL success, NSError *error) {
            if (!success) {
                DebugLog(@"Error creating album: %@", error);
            }
        }];
    }
}

- (void) createAllVideoAlbum {
    
    NSMutableArray *videoAlbumList = [[[NSUserDefaults standardUserDefaults] valueForKey:@"VIDEOALBUMLIST"] mutableCopy];
    
    // REPLACE ALL OF THE OLD PHOTO LIBARAY INTO NEW LIBARAY FOR RECEIVER SIDE LOGIC
    
    // Check target photo album
    PHFetchResult *localGroups = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum
                                                                          subtype:PHAssetCollectionSubtypeAlbumRegular
                                                                          options:nil];
    for (PHAssetCollection *test in localGroups) {
        if ([videoAlbumList containsObject:test.localizedTitle]) {
            [videoAlbumList removeObject:test.localizedTitle];
        }
    }
    
    // Create album for photos
    for (NSString *albumName in videoAlbumList) {
        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
            [PHAssetCollectionChangeRequest creationRequestForAssetCollectionWithTitle:albumName];
        } completionHandler:^(BOOL success, NSError *error) {
            if (!success) {
                DebugLog(@"Error creating album: %@", error);
            }
        }];
    }
}


- (NSString*)decodeStringTo64:(NSString*)fromString{
    
    if (fromString.length > 0) {
        NSData *decodedData = [[NSData alloc] initWithBase64EncodedString:fromString options:0];
        NSString *decodedString = [[NSString alloc] initWithData:decodedData encoding:NSUTF8StringEncoding];
        
        return decodedString;
    }
    
    return @"";
}

- (NSArray*)AlbumdecodeStringTo64:(NSArray*)fromString{
    
    
    NSMutableArray *albumList = [[NSMutableArray alloc] init];
    
    for (NSString *tempAlbumName in fromString) {
        
        NSData *decodedData = [[NSData alloc] initWithBase64EncodedString:tempAlbumName options:0];
        NSString *decodedString = [[NSString alloc] initWithData:decodedData encoding:NSUTF8StringEncoding];
        
        [albumList addObject:decodedString];

    }
    
    return albumList;
    
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
