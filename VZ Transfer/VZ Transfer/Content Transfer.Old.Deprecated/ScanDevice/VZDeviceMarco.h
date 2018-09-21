//
//  VZDeviceMarco.h
//  VZTransferSocket
//
//  Created by Sun, Xin on 3/9/16.
//  Copyright © 2016 Testing. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VZDeviceMarco : NSObject

@property (nonatomic, strong) NSDictionary* models;

+ (BOOL)isiPhone4AndBelow;
+ (BOOL)isiPhone5Serial;
+ (BOOL)isiPhone6AndAbove;

- (NSString *)getDeviceModel;

@end
