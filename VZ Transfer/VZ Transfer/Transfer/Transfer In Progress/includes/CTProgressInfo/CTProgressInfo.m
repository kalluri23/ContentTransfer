//
//  CTProgressInfo.m
//  contenttransfer
//
//  Created by Mehta, Snehal Natwar on 9/12/16.
//  Copyright © 2016 Verizon Wireless. All rights reserved.
//

#import "CTProgressInfo.h"
@interface CTProgressInfo()<NSCopying>

@end

@implementation CTProgressInfo

- (instancetype)initWithMediaType:(NSString *)mediaType {
    self = [super init];
    
    if (self) {
        self.transferredAmount = @0;
        self.transferredCount = @0;
        self.timeLeft = @"00:00:00";
        self.speed = @0;
        self.mediaType = mediaType;
        self.totalFileCount = @0;
        self.totalDataAmount = @0;
        self.isDuplicate = NO;
    }
    
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    CTProgressInfo *anotherObject = [[CTProgressInfo alloc] init];
    anotherObject.transferredAmount = self.transferredAmount;
    anotherObject.transferredCount = self.transferredCount;
    anotherObject.timeLeft = self.timeLeft;
    anotherObject.speed = self.speed;
    anotherObject.mediaType = self.mediaType;
    anotherObject.totalFileCount = self.totalFileCount;
    anotherObject.totalDataAmount = self.totalDataAmount;
    anotherObject.isDuplicate = self.isDuplicate;
    anotherObject.acutalTransferredAmount = self.acutalTransferredAmount;
    anotherObject.generalAvgSpeed = self.generalAvgSpeed;
    anotherObject.totalSectionSize = self.totalSectionSize;
    anotherObject.totalSectionSizeTransferred = self.totalSectionSizeTransferred;
    
    return anotherObject;
}

@end
