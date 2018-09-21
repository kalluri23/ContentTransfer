//
//  VZPhotosExport.h
//  VZTransferSocket
//
//  Created by VVM-MAC02 on 12/2/15.
//  Copyright © 2015 Testing. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <UIKit/UIKit.h>

typedef void (^completionHandler)(NSInteger photoCount, NSInteger streamCount, NSInteger unavailableCount);
typedef void (^photofetchsucess)(id phototAsset);
typedef void (^photofetchfailure)(NSString * errorMsg, BOOL isPermissionErr);
typedef void (^videofetchfailure)(NSString * errorMsg, BOOL isPermissionErr);
typedef void (^videofetchsucess)(id videoAsset);

@protocol PhotoUpdateUIDelegate <NSObject>

- (void)shouldUpdatePhotoNumber:(NSInteger)number;
- (void)shouldUpdateVideoNumber:(NSInteger)number;

@end

@interface VZPhotosExport : NSObject {
    
    NSString *photoLogfilepath;
    NSString *videoLogfilepath;
    NSString *sentPhotolist;
}

@property (nonatomic, weak) id<PhotoUpdateUIDelegate> delegate;
@property (nonatomic, strong) ALAssetsLibrary *assetsLibrary;
//@property (nonatomic, strong) NSMutableArray *groups;
//@property (nonatomic, strong) NSMutableArray *videogroups;
//@property (nonatomic, strong) NSMutableArray *assets;
//@property (nonatomic, strong) ALAssetsGroup *assetsGroup;
@property(nonatomic,copy) completionHandler photocallBackHandler;
@property(nonatomic,copy) completionHandler videocallBackHandler;
@property(nonatomic,copy) photofetchsucess fetchSucess;
@property(nonatomic,copy) photofetchfailure fetchfailure;
@property(nonatomic,copy) videofetchfailure videofetchfailure;
@property(nonatomic,copy) videofetchsucess fetchVideoSucess;
@property(atomic,strong) NSMutableDictionary *hashTableUrltofileName;
@property(atomic,strong) NSArray *photoListSuperSet;
@property(atomic,strong) NSMutableArray *photoStreamSet;
@property(atomic,strong) NSMutableArray *videoStreamSet;
//@property(nonatomic,strong) NSMutableDictionary *photoListSuperSetDic;
//@property(nonatomic,strong) NSMutableArray *photoAlbumSharedList;
@property(atomic,strong) NSMutableArray *videoListSuperSet;
//@property(nonatomic,strong) NSMutableArray *videoAlbumSharedList;

- (NSString *)getphotoLogfilepath;
//-(NSData *)getPhotofileData;
-(void) createphotoLogfile;
-(void) createvideoLogfile;

- (void)getPhotoData:(NSString *)imageName Sucess:(photofetchsucess)fetchSucess;
- (void) getVideoData:(NSString*)imagename  Sucess:(videofetchsucess )fetchSucess;

@end
