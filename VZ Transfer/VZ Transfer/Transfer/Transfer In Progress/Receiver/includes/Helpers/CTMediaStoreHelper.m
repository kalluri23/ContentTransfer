//
//  CTMediaStoreHelper.m
//  contenttransfer
//
//  Created by Sun, Xin on 9/15/16.
//  Copyright © 2016 Verizon Wireless. All rights reserved.
//

#import "CTMediaStoreHelper.h"
#import "CTUserDefaults.h"
#import "CTDeviceMarco.h"
#import "CTConcurrentWritingHelper.h"

#define YICHUN_CHANGE_02232017

#define MAX_PHOTO_TASKS         1
#define MAX_VIDEO_TASKS         1

@interface CTMediaStoreHelper()

// Photo file list
#ifdef YICHUN_CHANGE_02232017
@property (strong, atomic) NSMutableArray *photoSavingTasks;
@property (strong, atomic) NSMutableArray *videoSavingTasks;
#else
@property (strong, atomic) NSMutableArray *photoSavingList;
@property (strong, atomic) NSMutableArray *photoSavingList2;
@property (strong, atomic) NSMutableArray *photoSavingList3;
@property (strong, atomic) NSMutableArray *photoSavingList4;
@property (strong, atomic) NSMutableArray *photoSavingList5;
@property (strong, atomic) NSMutableArray *photoSavingList6;
@property (strong, atomic) NSMutableArray *videoSavingList;
@property (strong, atomic) NSMutableArray *videoSavingList2;// video writing into the temp disk file concurrent task list
#endif
@property (atomic, strong) NSMutableDictionary *videoWrittingTaskList;
// track on how many bytes already be written into the disk for video
@property (atomic, strong) NSMutableDictionary *videoAlreadyWrittenList;

@property (assign, atomic) BOOL anotherThread;
// photo file list index
@property (assign, atomic) NSInteger photoSavingArrayIndex; // current list index
@property (assign, atomic) NSInteger videoSavingArrayIndex; // current list index

@property (assign, nonatomic) NSInteger tempVideoPackageSize; // max size for each of the temp video package saved in memory, avoid memory crash

@property (nonatomic, strong) NSMutableData *intermediateData;

@end

@implementation CTMediaStoreHelper
#ifdef YICHUN_CHANGE_02232017
@synthesize photoSavingTasks;
@synthesize videoSavingTasks;
#else
@synthesize photoSavingList;
@synthesize photoSavingList2;
@synthesize photoSavingList3;
@synthesize photoSavingList4;
@synthesize photoSavingList5;
@synthesize photoSavingList6;
@synthesize videoSavingList;
@synthesize videoSavingList2;
#endif
@synthesize photoSavingArrayIndex;
@synthesize videoSavingArrayIndex;
@synthesize tempPhotoCount;
@synthesize tempVideoCount;
@synthesize tempPhotoSavedCount;
@synthesize tempVideoSavedCount;
@synthesize videoWrittingTaskList;
@synthesize videoAlreadyWrittenList;
@synthesize anotherThread;

- (NSMutableData *)intermediateData {
    if (!_intermediateData) {
        _intermediateData = [[NSMutableData alloc] init];
    }
    
    return _intermediateData;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        videoWrittingTaskList = [[NSMutableDictionary alloc] init];
        videoAlreadyWrittenList = [[NSMutableDictionary alloc] init];
        
#ifdef YICHUN_CHANGE_02232017
        
        photoSavingTasks = [[NSMutableArray alloc] initWithCapacity:0];
        
        videoSavingTasks = [[NSMutableArray alloc] initWithCapacity:0];
        
        for(int i=0;i<MAX_PHOTO_TASKS;i++)
        {
            [photoSavingTasks addObject:[[NSMutableArray alloc] init]];
        }
        
        for(int i=0;i<MAX_VIDEO_TASKS;i++)
        {
            [videoSavingTasks addObject:[[NSMutableArray alloc] init]];
        }
#else
        photoSavingList = [[NSMutableArray alloc] init];
        photoSavingList2 = [[NSMutableArray alloc] init];
        photoSavingList3 = [[NSMutableArray alloc] init];
        photoSavingList4 = [[NSMutableArray alloc] init];
        photoSavingList5 = [[NSMutableArray alloc] init];
        photoSavingList6 = [[NSMutableArray alloc] init];
        videoSavingList = [[NSMutableArray alloc] init];
        videoSavingList2 = [[NSMutableArray alloc] init];
#endif
        
        if ([CTDeviceMarco isiPhone4AndBelow]) {
            self.tempVideoPackageSize = 50; // set for each of the package size for video receiving
        } else if ([CTDeviceMarco isiPhone5Serial]) {
            self.tempVideoPackageSize = 100;
        } else {
            self.tempVideoPackageSize = 150;
        }
    }
    
    return self;
}

- (void)storePhotoIntoTempDocumentFolder:(NSData*)photoData videoComponent:(NSData *)videoData isLivePhoto:(BOOL)isLivePhoto photoInfo:(NSDictionary *)photoInfo {
//    ++ tempPhotoCount;
    NSInteger localCount = tempPhotoCount; // For log use, no impact of functionality
//    DebugLog(@"photo received:%ld", (long)tempPhotoCount);
    
    NSString *fileURL = [NSString stringWithFormat:@"%@/%@", [CTUserDefaults sharedInstance].photoTempFolder, [[photoInfo valueForKey:@"Path"] stringByReplacingOccurrencesOfString:@"/" withString:@"_"]];
    NSLog(@"==> Image URL: %@, size: %lu", fileURL, (unsigned long)photoData.length);
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:fileURL]) {
        [[NSFileManager defaultManager] removeItemAtPath:fileURL error:nil];
    }
    
    // Check video
    NSString *videoURL = nil;
    if (isLivePhoto) {
        videoURL = [NSString stringWithFormat:@"%@/%@", [CTUserDefaults sharedInstance].livePhotoTempFolder, [photoInfo valueForKey:@"Resource"]];
        NSLog(@"==> Video component URL: %@, size: %lu", videoURL, (unsigned long)videoData.length);
        // Remove existing one
        if ([[NSFileManager defaultManager] fileExistsAtPath:videoURL]) {
            [[NSFileManager defaultManager] removeItemAtPath:videoURL error:nil];
        }
    }
    
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        // writing files into the disk in background, otherwise it will block the main thread and slow down the speed.
        
        @autoreleasepool {
            NSLog(@"PhotoData: %lu", (unsigned long)photoData.length);
            BOOL result = [photoData writeToFile:fileURL atomically:NO]; // take time
            NSLog(@"Writing result: %d", result);
            // Check if it's live photo
            if (isLivePhoto) { // iOS to iOS only
                // Save video also
                NSAssert(videoURL != nil, @"URL for video component must exist.");
                [videoData writeToFile:videoURL atomically:NO]; // take time
            }
            
            // save photo into proper list, wait for saving in the future
            @synchronized (weakSelf) {
                
#ifdef YICHUN_CHANGE_02232017
                NSMutableArray * photoTask = photoSavingTasks[photoSavingArrayIndex];
                
                [photoTask addObject:photoInfo];
                
                photoSavingArrayIndex ++;
                
                if(photoSavingArrayIndex == MAX_PHOTO_TASKS)
                {
                    photoSavingArrayIndex = 0;
                }
#else
                if (photoSavingArrayIndex == 0) {
                    photoSavingArrayIndex ++;
                    [photoSavingList addObject:photoInfo];
                } else if (photoSavingArrayIndex == 1) {
                    photoSavingArrayIndex ++;
                    [photoSavingList2 addObject:photoInfo];
                } else if (photoSavingArrayIndex == 2) {
                    photoSavingArrayIndex ++;
                    [photoSavingList3 addObject:photoInfo];
                } else if (photoSavingArrayIndex == 3) {
                    photoSavingArrayIndex ++;
                    [photoSavingList4 addObject:photoInfo];
                } else if (photoSavingArrayIndex == 4) {
                    photoSavingArrayIndex ++;
                    [photoSavingList5 addObject:photoInfo];
                } else if (photoSavingArrayIndex == 5) {
                    photoSavingArrayIndex = 0;
                    [photoSavingList6 addObject:photoInfo];
                }
#endif
                ++ tempPhotoCount;
            }
            
            DebugLog(@"Photo NO.%ld write properly.", (long)localCount);
            if (++ self.tempPhotoSavedCount == self.totalNumberOfPhotos) {
                // last photo saved, store the photo lists
                NSMutableArray *photoLists = [[NSMutableArray alloc] init];
#ifdef YICHUN_CHANGE_02232017
                for (int i=0;i<photoSavingTasks.count;i++)
                {
                    if(((NSArray *)photoSavingTasks[i]).count > 0)
                    {
                        [photoLists addObject:photoSavingTasks[i]];
                    }
                }
#else
                if (self.photoSavingList) {
                    [photoLists addObject:self.photoSavingList];
                }
                if (self.photoSavingList2) {
                    [photoLists addObject:self.photoSavingList2];
                }
                if (self.photoSavingList3) {
                    [photoLists addObject:self.photoSavingList3];
                }
                if (self.photoSavingList4) {
                    [photoLists addObject:self.photoSavingList4];
                }
                if (self.photoSavingList5) {
                    [photoLists addObject:self.photoSavingList5];
                }
                if (self.photoSavingList6) {
                    [photoLists addObject:self.photoSavingList6];
                }
#endif
                [CTUserDefaults sharedInstance].tempPhotoLists = photoLists;
                [CTUserDefaults sharedInstance].numberOfPhotosReceived = self.tempPhotoSavedCount;
                [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:tempPhotoCount] forKey:@"ACTUAL_SAVE_PHOTO"];
                [self.delegate transferShouldPassPhoto];
            }
        }
    });
}

- (void)storeVideoReceivedPacketToTempFile:(NSData *)receivedPacket
                                   forFile:(NSDictionary *)videoInfo
                           tillNowReceived:(long long)tillNowVideoReceived
                                 totalSize:(long long)videoFileSize
                                    remove:(BOOL)shouldRemoveOldFile {
    
    NSString *tempstr = [videoInfo valueForKey:@"Path"];
    NSString *theFileName = [tempstr lastPathComponent];
    
    NSString *key = @"";
    NSString *fileName = @"";
    if ([[CTUserDevice userDevice].phoneCombination isEqualToString:IOS_Andriod]) {
        fileName = [NSString stringWithFormat:@"%@/%@", [CTUserDefaults sharedInstance].videoTempFolder, [tempstr stringByReplacingOccurrencesOfString:@"/" withString:@"_"]];
        key = fileName;
    } else {
        fileName = [NSString stringWithFormat:@"%@/%@", [CTUserDefaults sharedInstance].videoTempFolder, theFileName];
        key = theFileName;
    }
    
    if (shouldRemoveOldFile) {
        if ([[NSFileManager defaultManager] fileExistsAtPath:fileName]) {
            [[NSFileManager defaultManager] removeItemAtPath:fileName error:nil];
        }
        
        [self.videoWrittingTaskList removeObjectForKey:key];
        [self.videoAlreadyWrittenList removeObjectForKey:key];
    }
    
    NSFileHandle *fileHandler = [NSFileHandle fileHandleForWritingAtPath:fileName];
    if (fileHandler) {
        if ((self.intermediateData.length + receivedPacket.length < self.tempVideoPackageSize * 1024 * 1024) && (tillNowVideoReceived != videoFileSize)) {
            // collecting the package, make write operation as less as possible to increase the speed
            [self.intermediateData appendData:receivedPacket];
            return;
        }
        
        [self.intermediateData appendData:receivedPacket];
        
        // Add data to be written to the list
        if (![self.videoWrittingTaskList objectForKey:key]) {
            CTConcurrentWritingHelper *videoPackage = [[CTConcurrentWritingHelper alloc] initWithID:key andSize:videoFileSize andInfo:videoInfo andPackage:self.intermediateData];
            [self.videoWrittingTaskList setObject:videoPackage forKey:key];
        } else {
            @synchronized (self) {
                [((CTConcurrentWritingHelper *)[self.videoWrittingTaskList objectForKey:key]).packagesWaitingForWriting addObject:self.intermediateData];
            }
        }
        
        __weak typeof(self) weakSelf = self;
        if (!((CTConcurrentWritingHelper *)[self.videoWrittingTaskList objectForKey:key]).currentLock) { // current file writting is not start
            DebugLog(@"->start saving video %@", key);
            @synchronized (self) {
                ((CTConcurrentWritingHelper *)[weakSelf.videoWrittingTaskList objectForKey:key]).currentLock = YES; // add lock
            }
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                @autoreleasepool {
                    while (((CTConcurrentWritingHelper *)[weakSelf.videoWrittingTaskList objectForKey:key]).packagesWaitingForWriting.count > 0) {
                        DebugLog(@"->%@ need to write", key);
                        @autoreleasepool {
                            [fileHandler seekToEndOfFile]; // find the end of the file
                            
                            NSData *videoPackage = (NSData *)[((CTConcurrentWritingHelper *)[weakSelf.videoWrittingTaskList objectForKey:key]).packagesWaitingForWriting objectAtIndex:0];
                            
                            [fileHandler writeData:videoPackage];
                            DebugLog(@"%@ write done<-", key);
                            @synchronized (weakSelf) {
                                [((CTConcurrentWritingHelper *)[weakSelf.videoWrittingTaskList objectForKey:key]).packagesWaitingForWriting removeObjectAtIndex:0];
                                
                                [weakSelf updateVideoWritingListFor:key
                                                      withVideoSize:((CTConcurrentWritingHelper *)[weakSelf.videoWrittingTaskList objectForKey:key]).videoSize
                                                     withDataLength:videoPackage.length
                                                      withVideoInfo:((CTConcurrentWritingHelper *)[weakSelf.videoWrittingTaskList objectForKey:key]).videoInfo];
                            }
                            
                            videoPackage = nil;
                        }
                    }
                    
                    ((CTConcurrentWritingHelper *)[weakSelf.videoWrittingTaskList objectForKey:key]).currentLock = NO; // remove lock
                }
            });
        }
    } else { // first package, new file
        DebugLog(@"%@ first package received", key);
//        ++ tempVideoCount;
        [receivedPacket writeToFile:fileName atomically:NO];
        [self updateVideoWritingListFor:key withVideoSize:videoFileSize withDataLength:receivedPacket.length withVideoInfo:videoInfo];
    }
    
    self.intermediateData = nil;
    self.intermediateData = [[NSMutableData alloc] init];
}

- (void)updateVideoWritingListFor:(NSString *)fileName
                    withVideoSize:(long long)videoSize
                   withDataLength:(NSUInteger)length
                    withVideoInfo:(NSDictionary *)localVideoInfo {
    DebugLog(@"written list:%@", self.videoAlreadyWrittenList);
    if ([self.videoAlreadyWrittenList objectForKey:fileName]) { // exist
        NSUInteger currentPackLength = [(NSNumber *)[self.videoAlreadyWrittenList objectForKey:fileName] unsignedIntegerValue];
        currentPackLength += length;
        DebugLog(@"->%@ saved:%lu/%lld", fileName, (unsigned long)currentPackLength, videoSize);
        if (currentPackLength == videoSize) {
            DebugLog(@"%@ saved done<-", fileName);
            @synchronized (self) {
                ++ tempVideoCount;
#ifdef YICHUN_CHANGE_02232017
                
                NSMutableArray * videoSavingList = videoSavingTasks[videoSavingArrayIndex];
                
                [videoSavingList addObject:localVideoInfo];
                
                videoSavingArrayIndex ++;
                
                if(videoSavingArrayIndex >= MAX_VIDEO_TASKS)
                {
                    videoSavingArrayIndex = 0;
                }
                
                
#else
                if (!self.anotherThread) {
                    if (!self.videoSavingList) {
                        self.videoSavingList = [[NSMutableArray alloc] init];
                    }
                    [self.videoSavingList addObject:localVideoInfo];
                    
                    self.anotherThread = YES;
                } else {
                    if (!self.videoSavingList2) {
                        self.videoSavingList2 = [[NSMutableArray alloc] init];
                    }
                    [self.videoSavingList2 addObject:localVideoInfo];
                    self.anotherThread = NO;
                }
#endif
            }

            
            // clear
            [self.videoAlreadyWrittenList removeObjectForKey:fileName];
            [self.videoWrittingTaskList removeObjectForKey:fileName];
            
            @synchronized (self) {
                self.tempVideoSavedCount ++;
                DebugLog(@"-->video saved1:%ld", (long)self.tempVideoSavedCount);
                if (self.tempVideoSavedCount == self.totalNumberOfVideos) {
                    NSMutableArray *videoLists = [[NSMutableArray alloc] init];
#ifdef YICHUN_CHANGE_02232017
                    for(int i=0;i<MAX_VIDEO_TASKS;i++)
                    {
                        [videoLists addObject:videoSavingTasks[i]];
                    }
#else
                    if (self.videoSavingList) {
                        [videoLists addObject:self.videoSavingList];
                    }
                    if (self.videoSavingList2) {
                        [videoLists addObject:self.videoSavingList2];
                    }
#endif
                    [CTUserDefaults sharedInstance].tempVideoLists = videoLists;
                    [CTUserDefaults sharedInstance].numberOfVideosReceived = self.tempVideoSavedCount;
                    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:tempVideoCount] forKey:@"ACTUAL_SAVE_VIDEO"];
                    [self.delegate transferShouldPassVideo];
                }
            }
        } else {
            @synchronized (self) {
                [self.videoAlreadyWrittenList setObject:[NSNumber numberWithUnsignedInteger:currentPackLength] forKey:fileName];
                DebugLog(@"%@ update in list<-", fileName);
            }
        }
    } else { // not exist
        if (length == videoSize) { // video size is equals to package size
            @synchronized (self) {
                ++ tempVideoCount;
#ifdef YICHUN_CHANGE_02232017
                
                NSMutableArray * videoTask = videoSavingTasks[videoSavingArrayIndex];
                [videoTask addObject:localVideoInfo];
                videoSavingArrayIndex ++;
                
                if(videoSavingArrayIndex >= MAX_VIDEO_TASKS)
                {
                    videoSavingArrayIndex = 0;
                }
                
#else
                
                if (!self.anotherThread) {
                    if (!self.videoSavingList) {
                        self.videoSavingList = [[NSMutableArray alloc] init];
                    }
                    [self.videoSavingList addObject:localVideoInfo];
                    
                    self.anotherThread = YES;
                } else {
                    //                    @synchronized (self) {
                    if (!self.videoSavingList2) {
                        self.videoSavingList2 = [[NSMutableArray alloc] init];
                    }
                    [self.videoSavingList2 addObject:localVideoInfo];
                    //                    }
                    self.anotherThread = NO;
                }
#endif
                
                tempVideoSavedCount ++; // add this one
                DebugLog(@"-->video saved2:%ld", (long)self.tempVideoSavedCount);
                if (self.tempVideoSavedCount == self.totalNumberOfVideos) {
                    NSMutableArray *videoLists = [[NSMutableArray alloc] init];
#ifdef YICHUN_CHANGE_02232017
                    for(int i=0;i<MAX_VIDEO_TASKS;i++)
                    {
                        [videoLists addObject:videoSavingTasks[i]];
                    }
#else
                    if (self.videoSavingList) {
                        [videoLists addObject:self.videoSavingList];
                    }
                    if (self.videoSavingList2) {
                        [videoLists addObject:self.videoSavingList2];
                    }
#endif
                    [CTUserDefaults sharedInstance].tempVideoLists = videoLists;
                    [CTUserDefaults sharedInstance].numberOfVideosReceived = self.tempVideoSavedCount;
                    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:tempVideoCount] forKey:@"ACTUAL_SAVE_VIDEO"];
                    [self.delegate transferShouldPassVideo];
                }
            }
        } else {
            @synchronized (self) {
                [self.videoAlreadyWrittenList setObject:[NSNumber numberWithUnsignedInteger:length] forKey:fileName];
                DebugLog(@"%@ add in list", fileName);
            }
        }
    }
}

- (void)transferDidCancelledPhoto {
    
    NSMutableArray *photoLists = [[NSMutableArray alloc] init];
#ifdef    YICHUN_CHANGE_02232017
    for(int i=0;i<photoSavingTasks.count;i++)
    {
        [photoLists addObject:photoSavingTasks[i]];
    }
#else
    if (self.photoSavingList) {
        [photoLists addObject:self.photoSavingList];
    }
    if (self.photoSavingList2) {
        [photoLists addObject:self.photoSavingList2];
    }
    if (self.photoSavingList3) {
        [photoLists addObject:self.photoSavingList3];
    }
    if (self.photoSavingList4) {
        [photoLists addObject:self.photoSavingList4];
    }
    if (self.photoSavingList5) {
        [photoLists addObject:self.photoSavingList5];
    }
    if (self.photoSavingList6) {
        [photoLists addObject:self.photoSavingList6];
    }
#endif
    [CTUserDefaults sharedInstance].tempPhotoLists = photoLists;
    [CTUserDefaults sharedInstance].numberOfPhotosReceived = self.tempPhotoSavedCount;
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:tempPhotoCount] forKey:@"ACTUAL_SAVE_PHOTO"];
    [self.delegate transferShouldPassPhoto];
}

- (void)transferDidCancelledVideo {
    
    NSMutableArray *videoLists = [[NSMutableArray alloc] init];
#ifdef YICHUN_CHANGE_02232017
    for(int i=0;i<MAX_VIDEO_TASKS;i++)
    {
        [videoLists addObject:videoSavingTasks[i]];
    }
#else
    if (self.videoSavingList) {
        [videoLists addObject:self.videoSavingList];
    }
    if (self.videoSavingList2) {
        [videoLists addObject:self.videoSavingList2];
    }
#endif
    [CTUserDefaults sharedInstance].tempVideoLists = videoLists;
    [CTUserDefaults sharedInstance].numberOfVideosReceived = self.tempVideoSavedCount;
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:tempVideoCount] forKey:@"ACTUAL_SAVE_VIDEO"];
    [self.delegate transferShouldPassVideo];
}

- (void)storePhotoList {
    
    // last photo saved, store the photo lists
    
    NSMutableArray *photoLists = [[NSMutableArray alloc] init];
#ifdef    YICHUN_CHANGE_02232017
    for(int i=0;i<photoSavingTasks.count;i++)
    {
        if(((NSArray *)photoSavingTasks[i]).count > 0)
        {
            [photoLists addObject:photoSavingTasks[i]];
        }
    }
#else
    if (self.photoSavingList.count > 0) {
        [photoLists addObject:self.photoSavingList];
    }
    if (self.photoSavingList2.count > 0) {
        [photoLists addObject:self.photoSavingList2];
    }
    if (self.photoSavingList3.count > 0) {
        [photoLists addObject:self.photoSavingList3];
    }
    if (self.photoSavingList4.count > 0) {
        [photoLists addObject:self.photoSavingList4];
    }
    if (self.photoSavingList5.count > 0) {
        [photoLists addObject:self.photoSavingList5];
    }
    if (self.photoSavingList6.count > 0) {
        [photoLists addObject:self.photoSavingList6];
    }
#endif
    [CTUserDefaults sharedInstance].tempPhotoLists = photoLists;
    [CTUserDefaults sharedInstance].numberOfPhotosReceived = self.tempPhotoSavedCount;
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:tempPhotoCount] forKey:@"ACTUAL_SAVE_PHOTO"];
}

- (void)storeVideoList {
    
    NSMutableArray *videoLists = [[NSMutableArray alloc] init];
#ifdef YICHUN_CHANGE_02232017
    for(int i=0;i<MAX_VIDEO_TASKS;i++)
    {
        NSArray * videoTask = videoSavingTasks[i];
        if(videoTask.count > 0)
        {
            [videoLists addObject:videoSavingTasks[i]];
        }
    }
#else
    if (self.videoSavingList.count > 0) {
        [videoLists addObject:self.videoSavingList];
    }
    if (self.videoSavingList2.count > 0) {
        [videoLists addObject:self.videoSavingList2];
    }
#endif
    [CTUserDefaults sharedInstance].tempVideoLists = videoLists;
    [CTUserDefaults sharedInstance].numberOfVideosReceived = self.tempVideoSavedCount;
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:tempVideoCount] forKey:@"ACTUAL_SAVE_VIDEO"];
}

@end
