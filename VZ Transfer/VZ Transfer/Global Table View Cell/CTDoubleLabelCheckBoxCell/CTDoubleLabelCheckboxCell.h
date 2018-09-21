//
//  CTDoubleLabelCheckboxCell.h
//  contenttransfer
//
//  Created by Sun, Xin on 4/21/17.
//  Copyright © 2017 Verizon Wireless Inc. All rights reserved.
//
/*!
    @header CTSingleLabelCheckboxCell.h
    @discussion This is the header file of CTSingleLabelCheckboxCell.
 */
#import "CTSingleLabelCheckboxCell.h"

/*!
    @brief This is the table view cell with two main labels in it. Labels' position may vary based on xib designed, but they will share same cell type.
    @discussion This is a kind of Check box cell. Will have check box on the left center.
 */
@interface CTDoubleLabelCheckboxCell : CTSingleLabelCheckboxCell

/*! @brief Primary label for table view cell.*/
@property (nonatomic, weak) IBOutlet CTSubheadThreeLabel *primaryLabel;
/*! @breif Second label for table view cell.*/
@property (nonatomic, weak) IBOutlet CTRomanFontLabel *secondaryLabel;
/*! @breif Third label for table view cell.*/
@property (nonatomic, weak) IBOutlet CTRomanFontLabel *thirdLabel;
/*! @brief Button for more information, popup dialog for user.*/
@property (nonatomic, strong) UIButton *moreInfoButton;

/*!
     @brief Try to simulate the appearance of button on third label of the cell. Button will share the same frame of third label and change the text style.
 
            No clickable logic related inside this method. Gesture recognizer needs to be implemented seperately. This method only contains UI related change.
 */
- (void)simulateThirdLabelAsAButton;

@end
