//
//  CTAppReviewManager.h
//  contenttransfer
//
//  Created by Sun, Xin on 6/13/17.
//  Copyright © 2017 Verizon Wireless Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

/*!
    @brief Manager class to manage the app review logic.
    @discussion Method will control all the prompts that show to user related to app store review.
 
                Init the manager and call showReviewDialogIfUserNeedToReviewTheApp, that method will show the necessary step.
 */
@interface CTAppReviewManager : NSObject
/*!
    @brief Initalizer manager for app review.
    @param flow Current flow for transfer: sender or receiver.
    @param status Current result for transfer: success, interrupted and etc.
    @return CTAppReviceManager object.
 */
- (instancetype)initManagerFor:(enum CTTransferFlow)flow withResult:(enum CTTransferStatus)status;
/*!
    @brief show the review dialog if necessary.
    @discussion Only show review dialog when current transfer is sucessfull, and this device is receiver side. And only show dialog once per transfer until user select not showing anymore.
 */
- (void)showReviewDialogIfUserNeedToReviewTheAppForTarget:(UIViewController *)target;

@end
