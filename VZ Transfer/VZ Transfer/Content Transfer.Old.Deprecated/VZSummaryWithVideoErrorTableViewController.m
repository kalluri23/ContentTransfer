//
//  VZSummaryWithVideoErrorTableViewController.m
//  myverizon
//
//  Created by Sun, Xin on 3/28/16.
//  Copyright © 2016 Verizon Wireless. All rights reserved.
//

#import "VZSummaryWithVideoErrorTableViewController.h"
#import "VZVideoErrorTableViewCell.h"
#import "CTMVMAlertAction.h"
#import "VZContentTransferSingleton.h"
#import "CTNoInternetViewController.h"
#import "VZTransferFinishViewController.h"
#import "VZReceiveDetailTableViewCell.h"
#import "VZErrorTitleTableViewCell.h"

#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import "CTMVMFonts.h"


@interface VZSummaryWithVideoErrorTableViewController()

@property (assign, nonatomic) BOOL shouldAdd;

@property (assign, nonatomic) BOOL photosExpand;
@property (assign, nonatomic) BOOL videosExpand;

@property (assign, nonatomic) NSInteger numberOfRows;

@end

@implementation VZSummaryWithVideoErrorTableViewController 

- (NSMutableArray *)videoList{
    if (!_videoList) {
        _videoList = [[NSMutableArray alloc] init];
    }
    
    return _videoList;
}

- (NSMutableArray *)videoErrHeights {
    if (!_videoErrHeights) {
        _videoErrHeights = [[NSMutableArray alloc] init];
    }
    
    return _videoErrHeights;
}

- (NSMutableArray *)photoList {
    if (!_photoList) {
        _photoList = [[NSMutableArray alloc] init];
    }
    
    return _photoList;
}

- (NSMutableArray *)photoErrHeights {
    if (!_photoErrHeights) {
        _photoErrHeights = [[NSMutableArray alloc] init];
    }
    
    return _photoErrHeights;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(backButtonPressed)];
    [doneButton setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: [CTMVMFonts mvmBoldFontOfSize:17.0f], NSFontAttributeName, nil]
                              forState:UIControlStateNormal];
    
    self.navigationItem.title = @"Data Received";
    
    [self.navigationItem setRightBarButtonItem:doneButton animated:NO];
    [[self.navigationItem rightBarButtonItem] setTintColor:[CTMVMColor mvmPrimaryRedColor]];
    [self.navigationItem setHidesBackButton:YES animated:YES];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];

//    DebugLog(@"%@", self.videoErrList);
    
    [self.tableView setTableFooterView:[UIView new]];
    [self.tableView setBackgroundColor:[UIColor colorWithRed:250/255.0 green:250/255.0 blue:250/255.0 alpha:1.0f]];
    
    self.numberOfRows = 3;
}

- (void)backButtonPressed {
    
    // FIXME : This is not ideal implementation
    VZTransferFinishViewController *target = (VZTransferFinishViewController *)[self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count-2];
    target.videoList = self.videoList;
    target.videoErrHeights = self.videoErrHeights;
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.numberOfRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!self.photosExpand) { // non-expand
        if (indexPath.row < 3) {
            VZReceiveDetailTableViewCell *cell;
            
            if (indexPath.row == 0) {
                cell = (VZReceiveDetailTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"contact_detail_cell" forIndexPath:indexPath];
            } else if (indexPath.row == 1) {
                cell = (VZReceiveDetailTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"photo_detail_cell" forIndexPath:indexPath];
            } else {
                cell = (VZReceiveDetailTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"video_detail_cell" forIndexPath:indexPath];
            }
            
            [cell.titleLbl setFont:[CTMVMFonts mvmBookFontOfSize:15.0f]];
            [cell.numberLbl setFont:[CTMVMFonts mvmBookFontOfSize:15.0f]];
            
            cell.expand = NO;
            
            [cell setUserInteractionEnabled:NO];
            
            if (indexPath.row == 1 && self.photoErrList.count > 0) {
                [cell.arrowIcon setHidden:NO];
                [cell setUserInteractionEnabled:YES];
                [cell.numberLbl setText:[NSString stringWithFormat:@"%ld saved\n%lu failed\n%ld transferred", (long)self.numberOfPhotos-self.photoErrList.count, (unsigned long)self.photoErrList.count, (long)self.numberOfPhotos]];
                
                if (self.photosExpand) {
                    [cell.arrowIcon setImage:[ UIImage getImageFromBundleWithImageName:@"accordianArrow_contract" ]];
                } else {
                    [cell.arrowIcon setImage:[ UIImage getImageFromBundleWithImageName:@"accordianArrow_expand" ]];
                }
            } else if (indexPath.row == 2 && self.videoErrList.count > 0) {
                [cell.arrowIcon setHidden:NO];
                [cell setUserInteractionEnabled:YES];
                [cell.numberLbl setText:[NSString stringWithFormat:@"%ld saved\n%lu failed\n%ld transferred", (long)self.numberOfVideos-self.videoErrList.count, (unsigned long)self.videoErrList.count, (long)self.numberOfVideos]];
                
                
                if (self.videosExpand) {
                    [cell.arrowIcon setImage:[ UIImage getImageFromBundleWithImageName:@"accordianArrow_contract" ]];
                } else {
                    [cell.arrowIcon setImage:[ UIImage getImageFromBundleWithImageName:@"accordianArrow_expand" ]];
                }
            } else if (indexPath.row == 0 && self.hasVcardPermissionErr) {
                [cell.numberLbl setText:@"Permission Not Granted"];
            } else if (indexPath.row == 1 && self.hasAlbumPermissionErr) {
                [cell.numberLbl setText:@"Permission Not Granted"];
            } else if (indexPath.row == 2 && self.hasAlbumPermissionErr) {
                [cell.numberLbl setText:@"Permission Not Granted"];
            } else {
                indexPath.row == 0? [cell.numberLbl setText:[NSString stringWithFormat:@"%ld saved", (long)self.numberOfContacts]]: indexPath.row == 1? [cell.numberLbl setText:[NSString stringWithFormat:@"%ld saved", (long)self.numberOfPhotos]]:[cell.numberLbl setText:[NSString stringWithFormat:@"%ld saved", (long)self.numberOfVideos]];
            }
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.textLabel.backgroundColor = [UIColor clearColor];
            
            return cell;
        } else if (indexPath.row == 3) {
            VZErrorTitleTableViewCell *cell = (VZErrorTitleTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"title_cell" forIndexPath:indexPath];
            [cell.fileLbl setFont:[CTMVMFonts mvmBoldFontOfSize:14.0f]];
            [cell.DurationLbl setFont:[CTMVMFonts mvmBoldFontOfSize:14.0f]];
            [cell.failLbl setFont:[CTMVMFonts mvmBoldFontOfSize:14.0f]];
            
            [cell setUserInteractionEnabled:NO];
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.textLabel.backgroundColor = [UIColor clearColor];
            return cell;
        } else {
            VZVideoErrorTableViewCell *cell = (VZVideoErrorTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"video_err_cell" forIndexPath:indexPath];
            
            [cell setUserInteractionEnabled:NO];
            NSArray *info = (NSArray *)self.videoList[indexPath.row-4];
            
            NSString *videoName = (NSString *)info[0];
            NSString *videoTime = (NSString *)info[1];
            NSString *videoError = (NSString *)info[2];
            
            cell.iconImageView.image = [ UIImage getImageFromBundleWithImageName:@"icon_Videos"];
            
            [cell.videoNameLbl setFont:[CTMVMFonts mvmBookFontOfSize:10.0f]];
            [cell.videoTimeLbl setFont:[CTMVMFonts mvmBookFontOfSize:15.0f]];
            [cell.videoErrDescLbl setFont:[CTMVMFonts mvmBookFontOfSize:15.0f]];
            
            cell.videoNameLbl.text = videoName;
            cell.videoTimeLbl.text = videoTime;
            cell.videoErrDescLbl.text = videoError;
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.textLabel.backgroundColor = [UIColor clearColor];
            
            [cell.videoNameLbl layoutIfNeeded];
            [cell.videoTimeLbl layoutIfNeeded];
            
            [cell.videoErrDescLbl setNumberOfLines:0];
            [cell.videoErrDescLbl layoutIfNeeded];
            
            return cell;

        }
    } else { // photos expand
        if (indexPath.row < 2) {
            VZReceiveDetailTableViewCell *cell;
            
            if (indexPath.row == 0) {
                cell = (VZReceiveDetailTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"contact_detail_cell" forIndexPath:indexPath];
            } else if (indexPath.row == 1) {
                cell = (VZReceiveDetailTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"photo_detail_cell" forIndexPath:indexPath];
            }
            
            [cell.titleLbl setFont:[CTMVMFonts mvmBookFontOfSize:15.0f]];
            [cell.numberLbl setFont:[CTMVMFonts mvmBookFontOfSize:15.0f]];
            
            cell.expand = NO;
            
            [cell setUserInteractionEnabled:NO];
            
            if (indexPath.row == 1 && self.photoErrList.count > 0) {
                [cell.arrowIcon setHidden:NO];
                [cell setUserInteractionEnabled:YES];
                [cell.numberLbl setText:[NSString stringWithFormat:@"%ld saved\n%lu failed\n%ld transferred", (long)self.numberOfPhotos-self.photoErrList.count, (unsigned long)self.photoErrList.count, (long)self.numberOfPhotos]];
                
                if (self.photosExpand) {
                    [cell.arrowIcon setImage:[ UIImage getImageFromBundleWithImageName:@"accordianArrow_contract" ]];
                } else {
                    [cell.arrowIcon setImage:[ UIImage getImageFromBundleWithImageName:@"accordianArrow_expand" ]];
                }
            } else if (indexPath.row == 0 && self.hasVcardPermissionErr) {
                [cell.numberLbl setText:@"Permission Not Granted"];
            } else if (indexPath.row == 1 && self.hasAlbumPermissionErr) {
                [cell.numberLbl setText:@"Permission Not Granted"];
            } else {
                indexPath.row == 0? [cell.numberLbl setText:[NSString stringWithFormat:@"%ld saved", (long)self.numberOfContacts]]:[cell.numberLbl setText:[NSString stringWithFormat:@"%ld saved", (long)self.numberOfPhotos]];
            }
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.textLabel.backgroundColor = [UIColor clearColor];
            
            return cell;
        } else if (indexPath.row == 2) {
            VZErrorTitleTableViewCell *cell = (VZErrorTitleTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"title_cell" forIndexPath:indexPath];
            [cell.fileLbl setFont:[CTMVMFonts mvmBoldFontOfSize:14.0f]];
            [cell.DurationLbl setFont:[CTMVMFonts mvmBoldFontOfSize:14.0f]];
            [cell.failLbl setFont:[CTMVMFonts mvmBoldFontOfSize:14.0f]];
            [cell setUserInteractionEnabled:NO];
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.textLabel.backgroundColor = [UIColor clearColor];
            return cell;
        } else if (indexPath.row < self.photoErrList.count + 3) {
            VZVideoErrorTableViewCell *cell = (VZVideoErrorTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"video_err_cell" forIndexPath:indexPath];
            
            [cell setUserInteractionEnabled:NO];
            NSArray *info = (NSArray *)self.photoList[indexPath.row-3];
            
            NSString *videoName = (NSString *)info[0];
            NSString *videoTime = (NSString *)info[1];
            NSString *videoError = (NSString *)info[2];
            
            cell.iconImageView.image = [ UIImage getImageFromBundleWithImageName:@"sender_p2_net_btn_photo_1x"];
            
            [cell.videoNameLbl setFont:[CTMVMFonts mvmBookFontOfSize:10.0f]];
            [cell.videoTimeLbl setFont:[CTMVMFonts mvmBookFontOfSize:15.0f]];
            [cell.videoErrDescLbl setFont:[CTMVMFonts mvmBookFontOfSize:15.0f]];
            
            cell.videoNameLbl.text = videoName;
            cell.videoTimeLbl.text = videoTime;
            cell.videoErrDescLbl.text = videoError;
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.textLabel.backgroundColor = [UIColor clearColor];
            
            [cell.videoNameLbl layoutIfNeeded];
            [cell.videoTimeLbl layoutIfNeeded];
            
            [cell.videoErrDescLbl setNumberOfLines:0];
            [cell.videoErrDescLbl layoutIfNeeded];
            
            return cell;
            
        } else if (indexPath.row == self.photoErrList.count + 3) {
            VZReceiveDetailTableViewCell *cell = (VZReceiveDetailTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"video_detail_cell" forIndexPath:indexPath];
            
            [cell.titleLbl setFont:[CTMVMFonts mvmBookFontOfSize:15.0f]];
            [cell.numberLbl setFont:[CTMVMFonts mvmBookFontOfSize:15.0f]];
            
            cell.expand = NO;
            
            [cell setUserInteractionEnabled:NO];
            
            if (self.videoErrList.count > 0) {
                [cell.arrowIcon setHidden:NO];
                [cell setUserInteractionEnabled:YES];
                [cell.numberLbl setText:[NSString stringWithFormat:@"%ld saved\n%lu failed\n%ld transferred", (long)self.numberOfVideos-self.videoErrList.count, (unsigned long)self.videoErrList.count, (long)self.numberOfVideos]];
                
                if (self.videosExpand) {
                    [cell.arrowIcon setImage:[ UIImage getImageFromBundleWithImageName:@"accordianArrow_contract" ]];
                } else {
                    [cell.arrowIcon setImage:[ UIImage getImageFromBundleWithImageName:@"accordianArrow_expand" ]];
                }
            } else if (self.hasAlbumPermissionErr) {
                [cell.numberLbl setText:@"Permission Not Granted"];
            } else {
                [cell.numberLbl setText:[NSString stringWithFormat:@"%ld saved", (long)self.numberOfVideos]];
            }
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.textLabel.backgroundColor = [UIColor clearColor];
            
            return cell;
        } else if (indexPath.row == self.photoErrList.count + 4) {
            VZErrorTitleTableViewCell *cell = (VZErrorTitleTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"title_cell" forIndexPath:indexPath];
            [cell.fileLbl setFont:[CTMVMFonts mvmBoldFontOfSize:14.0f]];
            [cell.DurationLbl setFont:[CTMVMFonts mvmBoldFontOfSize:14.0f]];
            [cell.failLbl setFont:[CTMVMFonts mvmBoldFontOfSize:14.0f]];
            [cell setUserInteractionEnabled:NO];
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.textLabel.backgroundColor = [UIColor clearColor];
            return cell;
        } else {
            VZVideoErrorTableViewCell *cell = (VZVideoErrorTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"video_err_cell" forIndexPath:indexPath];
            
            [cell setUserInteractionEnabled:NO];
            NSArray *info = (NSArray *)self.videoList[indexPath.row-(5+self.photoErrList.count)];
            
            cell.iconImageView.image = [ UIImage getImageFromBundleWithImageName:@"icon_Videos"];
            
            NSString *videoName = (NSString *)info[0];
            NSString *videoTime = (NSString *)info[1];
            NSString *videoError = (NSString *)info[2];
            
            [cell.videoNameLbl setFont:[CTMVMFonts mvmBookFontOfSize:10.0f]];
            [cell.videoTimeLbl setFont:[CTMVMFonts mvmBookFontOfSize:15.0f]];
            [cell.videoErrDescLbl setFont:[CTMVMFonts mvmBookFontOfSize:15.0f]];
            
            cell.videoNameLbl.text = videoName;
            cell.videoTimeLbl.text = videoTime;
            cell.videoErrDescLbl.text = videoError;
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.textLabel.backgroundColor = [UIColor clearColor];
            
            [cell.videoNameLbl layoutIfNeeded];
            [cell.videoTimeLbl layoutIfNeeded];
            
            [cell.videoErrDescLbl setNumberOfLines:0];
            [cell.videoErrDescLbl layoutIfNeeded];
            
            return cell;
        }
    }
}

#define max(a, b) a>b?a:b
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!self.photosExpand) {
        if (indexPath.row < 3) {
            return 73.0f;
        } else if (indexPath.row == 3) {
            return 38.0f;
        } else {
            if (self.videoErrHeights.count <= indexPath.row-4) {
                NSDictionary *pdic = (NSDictionary *)[self.videoErrList objectAtIndex:indexPath.row-4];
                NSString *url = (NSString *)pdic[@"URL"];
                
                NSString *videoName = [self getFilenameForVideo:url];
                NSString *videoTime = [self getDurationForVideo:url];
                NSString *videoError = ((NSError *)pdic[@"Err"]).localizedDescription;
                
                NSArray *entry = [NSArray arrayWithObjects:videoName, videoTime, videoError, nil];
                [self.videoList addObject:entry];
                
                NSString *nameText = entry[0];
                NSString *errorText = entry[2];
                
                UIFont *cellFont = [CTMVMFonts mvmBookFontOfSize:15.0f];
                UIFont *nameFont = [CTMVMFonts mvmBookFontOfSize:10.0f];
                
                CGSize NameConstraintSize = CGSizeMake(75.0f, MAXFLOAT);
                CGSize ErrConstraintSize = CGSizeMake([[UIScreen mainScreen] bounds].size.width-168, MAXFLOAT);
                
                CGSize labelSizeName = [nameText boundingRectWithSize:NameConstraintSize
                                                              options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                                           attributes:@{NSFontAttributeName:nameFont}
                                                              context:nil].size;
                
                CGSize labelSizeErr = [errorText boundingRectWithSize:ErrConstraintSize
                                                              options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                                           attributes:@{NSFontAttributeName:cellFont}
                                                              context:nil].size;
                
                CGFloat heightName = max(labelSizeName.height, 21);
                heightName += 31 + 8 + 16;
                CGFloat heightMaxLbl = max(heightName, labelSizeErr.height);
//                CGFloat Finalheight = heightMaxLbl + 20;
                [self.videoErrHeights addObject:[NSNumber numberWithFloat:heightMaxLbl]];
//                DebugLog(@"%f", heightMaxLbl);
                
                [[NSFileManager defaultManager] removeItemAtPath:pdic[@"URL"] error:nil]; // remove file from disk
                
                return heightMaxLbl;
            } else {
                return [[self.videoErrHeights objectAtIndex:indexPath.row-4] floatValue];
            }
        }
    } else {
        if (indexPath.row < 2) {
            return 73.0f;
        } else if (indexPath.row == 2) {
            return 38.0f;
        } else if (indexPath.row < self.photoErrList.count + 3) {
            if (self.photoErrHeights.count <= indexPath.row-3) {
                NSDictionary *pdic = (NSDictionary *)[self.photoErrList objectAtIndex:indexPath.row-3];
                NSString *url = (NSString *)pdic[@"URL"];
                
                NSString *videoName = [self getFilenameForVideo:url];
                NSString *videoTime = @"--:--";
                NSString *videoError = ((NSError *)pdic[@"Err"]).localizedDescription;
                
                NSArray *entry = [NSArray arrayWithObjects:videoName, videoTime, videoError, nil];
                [self.photoList addObject:entry];
                
                NSString *nameText = entry[0];
                NSString *errorText = entry[2];
                
                UIFont *cellFont = [CTMVMFonts mvmBookFontOfSize:15.0f];
                UIFont *nameFont = [CTMVMFonts mvmBookFontOfSize:10.0f];
                
                CGSize NameConstraintSize = CGSizeMake(75.0f, MAXFLOAT);
                CGSize ErrConstraintSize = CGSizeMake([[UIScreen mainScreen] bounds].size.width-75-77-16, MAXFLOAT);
                
                CGSize labelSizeName = [nameText boundingRectWithSize:NameConstraintSize
                                                              options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                                           attributes:@{NSFontAttributeName:nameFont}
                                                              context:nil].size;
                
                CGSize labelSizeErr = [errorText boundingRectWithSize:ErrConstraintSize
                                                              options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                                           attributes:@{NSFontAttributeName:cellFont}
                                                              context:nil].size;
                
                CGFloat heightName = max(labelSizeName.height, 21);
                heightName += 31 + 8 + 16;
                CGFloat heightMaxLbl = max(heightName, labelSizeErr.height);
//                CGFloat Finalheight = heightMaxLbl + 20;
                [self.photoErrHeights addObject:[NSNumber numberWithFloat:heightMaxLbl]];
//                DebugLog(@"%f", heightMaxLbl);
                
                [[NSFileManager defaultManager] removeItemAtPath:pdic[@"URL"] error:nil]; // remove file from disk
                
                return heightMaxLbl;
            } else {
                return [[self.photoErrHeights objectAtIndex:indexPath.row-3] floatValue];
            }
        } else if (indexPath.row == self.photoErrList.count + 3) {
            return 73.0f;
        } else if (indexPath.row == self.photoErrList.count + 4) {
            return 38.0f;
        } else {
            if (self.videoErrHeights.count <= indexPath.row-(5+self.photoErrList.count)) {
                NSDictionary *pdic = (NSDictionary *)[self.videoErrList objectAtIndex:indexPath.row-(5+self.photoErrList.count)];
                NSString *url = (NSString *)pdic[@"URL"];
                
                NSString *videoName = [self getFilenameForVideo:url];
                NSString *videoTime = [self getDurationForVideo:url];
                NSString *videoError = ((NSError *)pdic[@"Err"]).localizedDescription;
                
                NSArray *entry = [NSArray arrayWithObjects:videoName, videoTime, videoError, nil];
                [self.videoList addObject:entry];
                
                NSString *nameText = entry[0];
                NSString *errorText = entry[2];
                
                UIFont *cellFont = [CTMVMFonts mvmBookFontOfSize:15.0f];
                UIFont *nameFont = [CTMVMFonts mvmBookFontOfSize:10.0f];
                
                CGSize NameConstraintSize = CGSizeMake(75.0f, MAXFLOAT);
                CGSize ErrConstraintSize = CGSizeMake([[UIScreen mainScreen] bounds].size.width-75-77-16, MAXFLOAT);
                
                CGSize labelSizeName = [nameText boundingRectWithSize:NameConstraintSize
                                                              options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                                           attributes:@{NSFontAttributeName:nameFont}
                                                              context:nil].size;
                
                CGSize labelSizeErr = [errorText boundingRectWithSize:ErrConstraintSize
                                                              options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                                           attributes:@{NSFontAttributeName:cellFont}
                                                              context:nil].size;
                
                CGFloat heightName = max(labelSizeName.height, 21);
                heightName += 31 + 8 + 16;
                CGFloat heightMaxLbl = max(heightName, labelSizeErr.height);
//                CGFloat Finalheight = heightMaxLbl + 20;
                [self.videoErrHeights addObject:[NSNumber numberWithFloat:heightMaxLbl]];
//                DebugLog(@"%f", heightMaxLbl);
                
                [[NSFileManager defaultManager] removeItemAtPath:pdic[@"URL"] error:nil]; // remove file from disk
                
                return heightMaxLbl;
            } else {
                return [[self.videoErrHeights objectAtIndex:indexPath.row-(5+self.photoErrList.count)] floatValue];
            }
        }
    }
}

#pragma mark - UITableViewDelegate
//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
//{
//    if (section == 0) {
//        return [[UIView alloc] initWithFrame:CGRectZero];
//    }
//    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, 42)];
//    
//    UILabel *nameLbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 88, 42)];
//    nameLbl.text = @"File";
//    nameLbl.font = [CTMVMFonts mvmBoldFontOfSize:16.0f];
//    [nameLbl setTextAlignment:NSTextAlignmentCenter];
//    [nameLbl setNumberOfLines:0];
//    [header addSubview:nameLbl];
//    [nameLbl setTextColor:[UIColor colorWithRed:205/255.0f green:4/255.0f blue:11/255.0f alpha:1.0f]];
//    
//    UIView * line1 = [[UIView alloc] initWithFrame:CGRectMake(88, 11, 1, 20)];
//    [line1 setBackgroundColor:[UIColor colorWithRed:210/255.0 green:210/255.0 blue:210/255.0 alpha:1.0f]];
//    [header addSubview:line1];
//    
//    UILabel *timeLbl = [[UILabel alloc] initWithFrame:CGRectMake(88, 0, 82, 42)];
//    timeLbl.text = @"Duration";
//    timeLbl.font = [CTMVMFonts mvmBoldFontOfSize:16.0f];
//    [timeLbl setTextAlignment:NSTextAlignmentCenter];
//    [timeLbl setNumberOfLines:0];
//    [header addSubview:timeLbl];
//    [timeLbl setTextColor:[UIColor colorWithRed:205/255.0f green:4/255.0f blue:11/255.0f alpha:1.0f]];
//    
//    UIView * line2 = [[UIView alloc] initWithFrame:CGRectMake(88+82, 11, 1, 20)];
//    [line2 setBackgroundColor:[UIColor colorWithRed:210/255.0 green:210/255.0 blue:210/255.0 alpha:1.0f]];
//    [header addSubview:line2];
//    
//    UILabel *reasonLbl = [[UILabel alloc] initWithFrame:CGRectMake(88+82, 0, [[UIScreen mainScreen] bounds].size.width-88-82, 42)];
//    reasonLbl.text = @"Fail Reason";
//    reasonLbl.font = [CTMVMFonts mvmBoldFontOfSize:16.0f];
//    [reasonLbl setTextAlignment:NSTextAlignmentCenter];
//    [reasonLbl setNumberOfLines:0];
//    [header addSubview:reasonLbl];
//    [reasonLbl setTextColor:[UIColor colorWithRed:205/255.0f green:4/255.0f blue:11/255.0f alpha:1.0f]];
//    
//    UIView * line3 = [[UIView alloc] initWithFrame:CGRectMake(0, 42, [[UIScreen mainScreen] bounds].size.width, 1)];
//    [line3 setBackgroundColor:[UIColor colorWithRed:210/255.0 green:210/255.0 blue:210/255.0 alpha:1.0f]];
//    [header addSubview:line3];
//    
//    [header setBackgroundColor:[UIColor colorWithRed:240/255.0 green:240/255.0 blue:240/255.0 alpha:1.0f]];
//    
//    return header;
//}

//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
//{
//    if (section == 0) {
//        return 0;
//    } else {
//        return 42.0f;
//    }
//}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 1) {
        VZReceiveDetailTableViewCell *cell = (VZReceiveDetailTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
        if (self.photosExpand) {
            [cell.arrowIcon setImage:[ UIImage getImageFromBundleWithImageName:@"accordianArrow_expand" ]];
            cell.expand = NO;
            self.photosExpand = NO;
            
            self.numberOfRows -= self.photoErrList.count + 1;
            NSMutableArray *indics = [[NSMutableArray alloc] initWithObjects:[NSIndexPath indexPathForRow:indexPath.row+1 inSection:0], nil];
            for (int i=0; i<self.photoErrList.count; i++) {
                NSIndexPath *path = [NSIndexPath indexPathForRow:indexPath.row+1+(i+1) inSection:0];
                [indics addObject:path];
            }
            [tableView beginUpdates];
            [tableView deleteRowsAtIndexPaths:indics withRowAnimation:UITableViewRowAnimationTop];
            
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            [tableView endUpdates];
        } else {
            if (self.videosExpand) {
                NSIndexPath *videoPath = [NSIndexPath indexPathForRow:2 inSection:0];
                VZReceiveDetailTableViewCell *videoCell = (VZReceiveDetailTableViewCell *)[tableView cellForRowAtIndexPath:videoPath];
                [videoCell.arrowIcon setImage:[ UIImage getImageFromBundleWithImageName:@"accordianArrow_expand" ]];
                videoCell.expand = NO;
                self.videosExpand = NO;
                
                self.numberOfRows -= self.videoErrList.count + 1;
                NSMutableArray *indics = [[NSMutableArray alloc] initWithObjects:[NSIndexPath indexPathForRow:videoPath.row+1 inSection:0], nil];
                for (int i=0; i<self.videoErrList.count; i++) {
                    NSIndexPath *path = [NSIndexPath indexPathForRow:videoPath.row+1+(i+1) inSection:0];
                    [indics addObject:path];
                }
                
                
                [CATransaction begin];
                
                [CATransaction setCompletionBlock:^{
                    // animation has finished
                    [cell.arrowIcon setImage:[ UIImage getImageFromBundleWithImageName:@"accordianArrow_contract" ]];
                    cell.expand = YES;
                    self.photosExpand = YES;
                    
                    self.numberOfRows += self.photoErrList.count + 1;
                    NSMutableArray *indics = [[NSMutableArray alloc] initWithObjects:[NSIndexPath indexPathForRow:indexPath.row+1 inSection:0], nil];
                    for (int i=0; i<self.photoErrList.count; i++) {
                        NSIndexPath *path = [NSIndexPath indexPathForRow:indexPath.row+1+(i+1) inSection:0];
                        [indics addObject:path];
                    }
                    [tableView beginUpdates];
                    [tableView insertRowsAtIndexPaths:indics withRowAnimation:UITableViewRowAnimationTop];
                    
                    [tableView deselectRowAtIndexPath:indexPath animated:YES];
                    [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
                    [tableView endUpdates];
                }];
                
                [tableView beginUpdates];
                [tableView deleteRowsAtIndexPaths:indics withRowAnimation:UITableViewRowAnimationTop];
                
                [tableView deselectRowAtIndexPath:videoPath animated:YES];
                [tableView reloadRowsAtIndexPaths:@[videoPath] withRowAnimation:UITableViewRowAnimationNone];
                [tableView endUpdates];
                
                [CATransaction commit];
            } else {
                [cell.arrowIcon setImage:[ UIImage getImageFromBundleWithImageName:@"accordianArrow_contract" ]];
                cell.expand = YES;
                self.photosExpand = YES;
                
                self.numberOfRows += self.photoErrList.count + 1;
                NSMutableArray *indics = [[NSMutableArray alloc] initWithObjects:[NSIndexPath indexPathForRow:indexPath.row+1 inSection:0], nil];
                for (int i=0; i<self.photoErrList.count; i++) {
                    NSIndexPath *path = [NSIndexPath indexPathForRow:indexPath.row+1+(i+1) inSection:0];
                    [indics addObject:path];
                }
                [tableView beginUpdates];
                [tableView insertRowsAtIndexPaths:indics withRowAnimation:UITableViewRowAnimationTop];
                
                [tableView deselectRowAtIndexPath:indexPath animated:YES];
                [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
                [tableView endUpdates];
            }
        }
    } else {
        VZReceiveDetailTableViewCell *cell = (VZReceiveDetailTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
        if (self.videosExpand) {
            [cell.arrowIcon setImage:[ UIImage getImageFromBundleWithImageName:@"accordianArrow_expand" ]];
            cell.expand = NO;
            self.videosExpand = NO;
            
            self.numberOfRows -= self.videoErrList.count + 1;
            NSMutableArray *indics = [[NSMutableArray alloc] initWithObjects:[NSIndexPath indexPathForRow:indexPath.row+1 inSection:0], nil];
            for (int i=0; i<self.videoErrList.count; i++) {
                NSIndexPath *path = [NSIndexPath indexPathForRow:indexPath.row+1+(i+1) inSection:0];
                [indics addObject:path];
            }
            [tableView beginUpdates];
            [tableView deleteRowsAtIndexPaths:indics withRowAnimation:UITableViewRowAnimationTop];
            
            NSIndexPath *reloadPath = [NSIndexPath indexPathForRow:2 inSection:0];
            [tableView deselectRowAtIndexPath:reloadPath animated:YES];
            [tableView reloadRowsAtIndexPaths:@[reloadPath] withRowAnimation:UITableViewRowAnimationNone];
            [tableView endUpdates];
        } else {
            if (self.photosExpand) {
                NSIndexPath *photoPath = [NSIndexPath indexPathForRow:1 inSection:0];
                VZReceiveDetailTableViewCell *photoCell = (VZReceiveDetailTableViewCell *)[tableView cellForRowAtIndexPath:photoPath];
                [photoCell.arrowIcon setImage:[ UIImage getImageFromBundleWithImageName:@"accordianArrow_expand" ]];
                photoCell.expand = NO;
                self.photosExpand = NO;
                
                self.numberOfRows -= self.photoErrList.count + 1;
                NSMutableArray *indics = [[NSMutableArray alloc] initWithObjects:[NSIndexPath indexPathForRow:photoPath.row+1 inSection:0], nil];
                for (int i=0; i<self.photoErrList.count; i++) {
                    NSIndexPath *path = [NSIndexPath indexPathForRow:photoPath.row+1+(i+1) inSection:0];
                    [indics addObject:path];
                }
                
                [CATransaction begin];
                
                [CATransaction setCompletionBlock:^{
                    // animation has finished
                    [cell.arrowIcon setImage:[ UIImage getImageFromBundleWithImageName:@"accordianArrow_contract" ]
];
                    cell.expand = YES;
                    self.videosExpand = YES;
                    
                    self.numberOfRows += self.videoErrList.count + 1;
                    NSMutableArray *indics = [[NSMutableArray alloc] initWithObjects:[NSIndexPath indexPathForRow:2+1 inSection:0], nil];
                    for (int i=0; i<self.videoErrList.count; i++) {
                        NSIndexPath *path = [NSIndexPath indexPathForRow:2+1+(i+1) inSection:0];
                        [indics addObject:path];
                    }
                    [tableView beginUpdates];
                    [tableView insertRowsAtIndexPaths:indics withRowAnimation:UITableViewRowAnimationTop];
                    
                    NSIndexPath *reloadPath = [NSIndexPath indexPathForRow:self.numberOfRows - (self.videoErrList.count + 1) - 1 inSection:0];
                    [tableView deselectRowAtIndexPath:reloadPath animated:YES];
                    [tableView reloadRowsAtIndexPaths:@[reloadPath] withRowAnimation:UITableViewRowAnimationNone];
                    [tableView endUpdates];
                }];
                
                [tableView beginUpdates];
                [tableView deleteRowsAtIndexPaths:indics withRowAnimation:UITableViewRowAnimationTop];
                
                [tableView deselectRowAtIndexPath:photoPath animated:YES];
                [tableView reloadRowsAtIndexPaths:@[photoPath] withRowAnimation:UITableViewRowAnimationNone];
                [tableView endUpdates];
                
                [CATransaction commit];
            } else {
                [cell.arrowIcon setImage:[ UIImage getImageFromBundleWithImageName:@"accordianArrow_contract" ]];
                cell.expand = YES;
                self.videosExpand = YES;
                
                self.numberOfRows += self.videoErrList.count + 1;
                NSMutableArray *indics = [[NSMutableArray alloc] initWithObjects:[NSIndexPath indexPathForRow:indexPath.row+1 inSection:0], nil];
                for (int i=0; i<self.videoErrList.count; i++) {
                    NSIndexPath *path = [NSIndexPath indexPathForRow:indexPath.row+1+(i+1) inSection:0];
                    [indics addObject:path];
                }
                [tableView beginUpdates];
                [tableView insertRowsAtIndexPaths:indics withRowAnimation:UITableViewRowAnimationTop];
                
                NSIndexPath *reloadPath = [NSIndexPath indexPathForRow:self.numberOfRows - (self.videoErrList.count + 1) - 1 inSection:0];
                [tableView deselectRowAtIndexPath:reloadPath animated:YES];
                [tableView reloadRowsAtIndexPaths:@[reloadPath] withRowAnimation:UITableViewRowAnimationNone];
                [tableView endUpdates];
            }
        }
    }
}

#pragma mark - Helper
- (NSString *)getFilenameForVideo:(NSString *)url
{
    if (url) {
        return [url lastPathComponent];
    } else {
        return @"unknown";
    }
}

- (NSString *)getDurationForVideo:(NSString *)url
{
    AVURLAsset* audioAsset = [AVURLAsset URLAssetWithURL:[NSURL fileURLWithPath:url] options:nil];
    CMTime audioDuration = audioAsset.duration;
    float durationSeconds = CMTimeGetSeconds(audioDuration);
    
    int minutes = (int)(durationSeconds/60);
    float seconds = durationSeconds - (minutes*60);
    
    if (seconds >= 10) {
        return [NSString stringWithFormat:@"%d:%1.f", minutes, seconds];
    } else {
        return [NSString stringWithFormat:@"%d:0%1.f", minutes, seconds];
    }
}

- (NSString *)getErrorMsgForVideo:(NSError *)err
{
    switch (err.code) {
        case -3300:
            return @"Write failed.";
            break;
        case -3302:
            return @"Invalid video.";
            break;
        case -3303:
            return @"Incompatible video.";
            break;
        case -3304:
            return @"Video data has invlid encoding.";
            break;
        case -3305:
            return @"Device is out of space.";
            break;
        case -3310:
            return @"Video data unavailable.";
            break;
        case -3306:
            return @"Device doesn't support video resolution, OR video file corrupt.";
            break;
        case -3311:
            return @"User denied access request.";
            break;
        case -3312:
            return @"Access denied for device";
            break;
        default:
            return @"Reason unknown.";
            break;
    }
}

- (NSString *)getErrorMsgForPhoto:(NSError *)err
{
    switch (err.code) {
        case -3300:
            return @"Write failed.";
            break;
        case -3302:
            return @"Invalid photo.";
            break;
        case -3303:
            return @"Incompatible photo.";
            break;
        case -3304:
            return @"Photo data has invalid encoding.";
            break;
        case -3305:
            return @"Device is out of space.";
            break;
        case -3310:
            return @"Photo data unavailable.";
            break;
        case -3306:
            return @"Device doesn't support photo resolution, OR photo file corrupt.";
            break;
        case -3311:
            return @"User denied access request.";
            break;
        case -3312:
            return @"Access denied for device";
            break;
        default:
            return @"Reason unknown.";
            break;
    }
}

@end
