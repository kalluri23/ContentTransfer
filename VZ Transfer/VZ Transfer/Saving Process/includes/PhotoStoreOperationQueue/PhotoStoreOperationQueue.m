//
//  PhotoStoreOperationQueue.m
//  storePhotosTest
//
//  Created by Sun, Xin on 6/14/16.
//  Copyright © 2016 Sun, Xin. All rights reserved.
//

#import "PhotoStoreOperationQueue.h"
#import "NSDate+CTMVMConvenience.h"
@interface PhotoStoreOperationQueue ()

@property (nonatomic, strong) NSArray *dataSet;

@end

@implementation PhotoStoreOperationQueue

- (instancetype)initWithDataSet:(NSArray *)dataSet {
    self = [super init];
    if (self) {
        _dataSet = [dataSet sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
            NSInteger order1 = [a[@"Order"] integerValue];
            NSInteger order2 = [b[@"Order"] integerValue];
            
            return order1 > order2;
        }];
    }
    
    return self;
}

/**
 * Add operations for each of the image in data set using specific target and selector
 */
- (void)addOperationWithTarget:(id)target selector:(SEL)selector {
    for (NSDictionary *info in _dataSet) {
        @autoreleasepool {
            NSInvocationOperation *newoperation = [[NSInvocationOperation alloc] initWithTarget:target selector:selector object:info];
            [super addOperation:newoperation];
        }
    }
}

@end

