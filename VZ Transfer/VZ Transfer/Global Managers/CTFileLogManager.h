//
//  CTFileLogManager.h
//  VZTransferSocket
//
//  Created by Prakash Mac on 12/23/15.
//  Copyright © 2015 Testing. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CTFileList.h"
/*! 
    @brief Manager object for file list.
    @discussion This object contains all the logic to maintain the file list object using during the transfer.
    @see CTFileList
 */
@interface CTFileLogManager : NSObject
/*! File list obejct for manager class.*/
@property (nonatomic, strong) CTFileList *fileList;

/*! BOOL type indicate that has contact started trasnfer or not. Default value is false.*/
@property (nonatomic, assign) BOOL contactStarted;
/*! BOOL type indicate that has photo started trasnfer or not. Default value is false.*/
@property (nonatomic, assign) BOOL photoStarted;
/*! BOOL type indicate that has video started trasnfer or not. Default value is false.*/
@property (nonatomic, assign) BOOL videoStarted;
/*! BOOL type indicate that has calendar started trasnfer or not. Default value is false.*/
@property (nonatomic, assign) BOOL calendarStarted;
/*! BOOL type indicate that has reminder started trasnfer or not. Default value is false.*/
@property (nonatomic, assign) BOOL reminderStarted;
/*! BOOL type indicate that has app list started trasnfer or not. Default value is false.*/
@property (nonatomic, assign) BOOL appListStarted;

/*!
    @brief Strore file list from data.
    @discussion This method will create a CTFileList object and store necessary list into storage for transfer use.
    @param data NSData for file list.
    @see CTFileList
 */
- (void)storeFileList:(NSData *)data;
/*!
    @brief Get video package size for P2P large video transfer.
    @return Video package size.
 */
- (NSInteger)packageSize;

@end
