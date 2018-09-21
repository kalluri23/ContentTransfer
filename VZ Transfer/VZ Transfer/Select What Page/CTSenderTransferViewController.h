//
//  CTTransferSenderViewController.h
//  contenttransfer
//
//  Created by Development on 8/16/16.
//  Copyright © 2016 Verizon. All rights reserved.
//

#import "CTGenericTransferViewController.h"
#import "GCDAsyncSocket.h"
#import "CTSenderPinViewController.h"
#import "CTCommPortClientSocket.h"

/*!Protocol for select what page.*/
@protocol updateSenderStatDelegate <NSObject>
/*! Method to notify responder that they should ignore the coming disconnect callback after this method called.*/
- (void)ignoreSocketClosedSignal;

@end

/*!
 Select what page, this page allow user to select the datatype they want to start transfer.
 
 If receiver doesn't have enough storage, allow user to reselect items.
 
 Contact/Calendar/Reminders are fetching with UI blocked, but generally they are very fast. Photos/videos will be fetched in background, user doesn't have to wait for them to complete before start transfer.
 */
@interface CTSenderTransferViewController : CTGenericTransferViewController
/*!
 Delegate for select what page. Target should specified as @b updateSenderStatDelegate.
 @see updateSenderStatDelegate
 */
@property (nonatomic, weak) id<updateSenderStatDelegate> delegate;
/*! Commport socket for sender side; created after connection established. Only client socket will appear in sender side.*/
@property (nonatomic,strong) CTCommPortClientSocket *commAsyncSocket;
/*! Regular socket using for transfer.*/
@property (nonatomic, strong) GCDAsyncSocket *readSocket;

@property (nonatomic, weak) IBOutlet UIButton *selectionButton;
@property (nonatomic, weak) IBOutlet UITableView *transferItemsTableView;
@property (nonatomic, weak) IBOutlet CTCommonBlackButton *nextButton;
@property (nonatomic, weak) IBOutlet CTBlackBorderedButton *cancelButton;
@property (nonatomic, weak) IBOutlet CTRomanFontLabel *iCloudInfoLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *primaryLabelTopSpace;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *seperatorViewTopSpace;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *selectAllButtonTopSpace;

/*!
 The method will try to cancel all the on-going fetching process. Even call this, progress will not be promised that will stop immediately. System will decide the proper to stop the process.
 @see NSOperationQueue
 */
- (void)requestToCancelAllOperation;
/*!
    @brief Try to push view controller to cancel page.
    @discussion This method trying to avoid push view controller from other other view controller, and cause segment fault:11 error.
 
                This method will be called through block from upper level view controller.
 */
- (void)viewShouldGoToCancelPage;

@end
