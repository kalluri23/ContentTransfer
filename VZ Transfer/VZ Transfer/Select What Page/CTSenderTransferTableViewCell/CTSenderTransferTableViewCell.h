//
//  CTSenderTransferTableViewCell.h
//  contenttransfer
//
//  Created by Sun, Xin on 9/28/17.
//  Copyright © 2017 Verizon Wireless Inc. All rights reserved.
//
/*!
 @header CTSenderTransferTableViewCell.h
 @discussion This is the header file of CTSenderTransferTableViewCell. This is the replacement for doublecheck tableview cell.
 */
#import <UIKit/UIKit.h>
#import "CTCustomLabel.h"
/*!
 @brief This is the table view cell with two main labels in it. Labels' position may vary based on xib designed, but they will share same cell type.
 @discussion This is a kind of Check box cell. Will have check box on the left center.
 */
@interface CTSenderTransferTableViewCell : UITableViewCell

/*! @brief Primary label for table view cell.*/
@property (weak, nonatomic) IBOutlet CTBoldFontLabel *primaryLabel;
/*! @breif Second label for table view cell.*/
@property (weak, nonatomic) IBOutlet CTRomanFontLabel *secondaryLabel;
/*! @breif Third label for table view cell.*/
@property (weak, nonatomic) IBOutlet CTRomanFontLabel *thirdLabel;
@property (weak, nonatomic) IBOutlet UIImageView *checkboxImageView;

/*! @brief Button for more information, popup dialog for user.*/
@property (nonatomic, strong) UIButton *moreInfoButton;

/*!
 @brief Try to simulate the appearance of button on third label of the cell. Button will share the same frame of third label and change the text style.
 
 No clickable logic related inside this method. Gesture recognizer needs to be implemented seperately. This method only contains UI related change.
 */
- (void)simulateThirdLabelAsAButton;
/*!
 @brief Change hightlight status for tableview cell.
 @param highlight BOOL value indicate the cell's hightlight status.
 */
- (void)highlightCell:(BOOL)highlight;
/*!
 @brief Enable/diable the user interaction for cell.
 @param shoudlEnable BOOL value indicate that this cell should accept user interaction or not.
 */
- (void)enableUserInteraction:(BOOL)shouldEnable;

@end
