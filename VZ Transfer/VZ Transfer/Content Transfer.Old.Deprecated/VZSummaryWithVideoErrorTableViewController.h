//
//  VZSummaryWithVideoErrorTableViewController.h
//  myverizon
//
//  Created by Sun, Xin on 3/28/16.
//  Copyright © 2016 Verizon Wireless. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VZViewUtility.h"

@interface VZSummaryWithVideoErrorTableViewController : UITableViewController

@property (nonatomic, strong) NSMutableArray *videoList;
@property (nonatomic, strong) NSMutableArray *videoErrHeights;
@property (nonatomic, strong) NSMutableArray *photoList;
@property (nonatomic, strong) NSMutableArray *photoErrHeights;

@property (nonatomic, strong) NSArray *photoErrList;
@property (nonatomic, strong) NSArray *videoErrList;

@property (nonatomic, assign) NSInteger numberOfContacts;
@property (nonatomic, assign) NSInteger numberOfPhotos;
@property (nonatomic, assign) NSInteger numberOfVideos;

@property (nonatomic, assign) BOOL hasVcardPermissionErr;
@property (nonatomic, assign) BOOL hasAlbumPermissionErr;

@end
