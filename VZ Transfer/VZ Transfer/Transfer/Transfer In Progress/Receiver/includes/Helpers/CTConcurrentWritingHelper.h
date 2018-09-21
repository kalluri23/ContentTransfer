//
//  CTConcurrentWritingHelper.h
//  VZTransferSocket
//
//  Created by Sun, Xin on 3/6/16.
//  Copyright © 2016 Testing. All rights reserved.
//

#import <Foundation/Foundation.h>

/*! Helper object for writing video file chunk into local file system asynchronisly. This object will contain a thread lock to make sure chunks is writtren in correct order to generate a playable video file.*/
@interface CTConcurrentWritingHelper : NSObject
/*! Identifier to this helper object*/
@property (nonatomic, strong) NSString *concurrentID;
/*! Thread lock. This is thread safe parameter.*/
@property (atomic, assign) BOOL currentLock;
/*! Infomation dictionary for video.*/
@property (nonatomic, strong) NSDictionary *videoInfo;
/*! Size of the video.*/
@property (nonatomic, assign) long long videoSize;
/*! Total size already be written into disk.*/
@property (nonatomic, assign) long long totalSaved;
/*! Waiting list for chunk to be written.*/
@property (atomic, strong) NSMutableArray *packagesWaitingForWriting;

/*!
 Initializer for CTConcurrentWritingHelper.
 @param concurrentID Identifier of object.
 @param size Size of the file.
 @param info Information dictionary of the file.
 @param data First chunck data needs to be write into disk.
 @return CTConcurrentWritingHelper object.
 */
- (instancetype)initWithID:(NSString *)concurrentID andSize:(long long)size andInfo:(NSDictionary *)info andPackage:(NSData *)data;

@end
