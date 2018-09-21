//
//  VZConcurrentWritingHelper.h
//  VZTransferSocket
//
//  Created by Sun, Xin on 3/6/16.
//  Copyright © 2016 Testing. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VZConcurrentWritingHelper : NSObject

@property (nonatomic, strong) NSString *concurrentID;
@property (atomic, assign) BOOL currentLock;

@property (nonatomic, strong) NSDictionary *videoInfo;
@property (nonatomic, assign) long long videoSize;
@property (nonatomic, assign) long long totalSaved;


@property (atomic, strong) NSMutableArray *packagesWaitingForWriting;

- (id)initWithID:(NSString *)concurrentID andSize:(long long)size andInfo:(NSDictionary *)info andPackage:(NSData *)data;

@end
