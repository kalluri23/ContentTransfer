//
//  CTTransferInProgressViewController.h
//  contenttransfer
//
//  Created by Mehta, Snehal Natwar on 8/17/16.
//  Copyright © 2016 Verizon. All rights reserved.
//

#import "CTViewController.h"

/*!Enumerations for items need to be showed on progres view.*/
typedef NS_ENUM(NSInteger, CTTransferInProgressTableBreakDown) {
    /*!Type of transfer.*/
    CTTransferInProgressTableBreakDown_CurrentTransferringContent,
    /*!Time left for transfer.*/
    CTTransferInProgressTableBreakDown_TimeLeft,
    /*!Total amount of data transfered.*/
    CTTransferInProgressTableBreakDown_TransferredAmount,
    /*!Avg. speed for transfer.*/
    CTTransferInProgressTableBreakDown_Speed,
    /*!Total Number of the transfer items. This one always be the last item of this enumeration.*/
    CTTransferInProgressTableBreakDown_Total
};

/*!
    @brief Abstact view controller for all the transfer in progress view. Subclass of this class for sender and receiver side.
    @warning XIB file will build on this abstact view controller.
 */
@interface CTTransferInProgressViewController : CTViewController

@property (nonatomic, weak) IBOutlet CTBlackBorderedButton *cancelButton;
@property (nonatomic, strong) IBOutlet CTRomanFontLabel *secondaryLabel;
@property (nonatomic, weak) IBOutlet UITableView *transferInProgressTableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topSpaceConstraint;

@end
