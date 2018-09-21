//
//  CTSingleLabelCheckboxCell.h
//  contenttransfer
//
//  Created by Sun, Xin on 4/21/17.
//  Copyright © 2017 Verizon Wireless Inc. All rights reserved.
//

#import "CTCustomTableViewCell.h"

/*!
 @brief This is the table view cell with one main labels in it. Labels' position may vary based on xib designed, but they will share same cell type.
 @discussion This is a kind of Check box cell. Will have check box on the left center.
 */
@interface CTSingleLabelCheckboxCell : CTCustomTableViewCell
@property (nonatomic, weak) IBOutlet UIImageView *checkboxImageView;
@property (nonatomic, weak) IBOutlet CTRomanFontLabel *cellLabel;
/*!Bool value indicate that user interaction is enabled or not.*/
@property (nonatomic, assign) BOOL isUserInteractionEnabled;

/*!
 Highlight the cell.
 @param highlight YES if highted, NO if normal.
 */
- (void)highlightCell:(BOOL)highlight;
/*!
 Enable user interaction for cell.
 @param shouldEnable YES if enable; NO if disable.
 */
- (void)enableUserInteraction:(BOOL)shouldEnable;

@end
