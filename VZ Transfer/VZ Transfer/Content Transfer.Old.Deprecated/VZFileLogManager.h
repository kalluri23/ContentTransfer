//
//  VZFileLogManager.h
//  VZTransferSocket
//
//  Created by Prakash Mac on 12/23/15.
//  Copyright © 2015 Testing. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VZPhotosExport.h"

@interface VZFileLogManager : NSObject


@property(nonatomic,strong) NSMutableArray *itemListReceived;
@property(nonatomic,strong) NSMutableArray *photoFileListReceived;
@property(nonatomic,strong) NSMutableArray *videoFileListReceived;
@property(nonatomic,strong) NSMutableArray *itemListFiltered;
@property(nonatomic,strong) NSMutableArray *photoFileListFiltered;
@property(nonatomic,strong) NSMutableArray *videoFileListFiltered;
@property(nonatomic,strong) NSArray *albumPhotoList;
@property(nonatomic,strong) NSArray *albumVideoList;
@property(nonatomic,strong) NSMutableArray *calenderFileList;
@property(nonatomic,strong) NSMutableArray *reminderFileList;

@property (nonatomic, assign) NSInteger model;
@property (nonatomic, strong) NSMutableString *selectedDataTypesString;
@property (nonatomic, strong) NSDictionary *allMediaInfo;

- (void)storeFileList:(NSData *)data;

@end
