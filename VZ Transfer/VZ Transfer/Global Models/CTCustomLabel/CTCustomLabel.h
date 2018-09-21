//
//  CTCustomLabel.h
//  contenttransfer
//
//  Created by Snehal on 8/11/16.
//  Copyright © 2016 Verizon. All rights reserved.
//

#import <UIKit/UIKit.h>
/*!Base class of all custom UILabel.*/
@interface CTCustomLabel : UILabel

@end

/*!UILabel with Verizon bold font.*/
@interface CTBoldFontLabel : CTCustomLabel

@end

/*!UILabel with Verizon header font style font.*/
@interface CTPrimaryMessageLabel : CTBoldFontLabel

@end

/*!UILabel with Verizon instruction font style font.*/
@interface CTSecondaryInstructionLabel : CTCustomLabel

@end

/*!UILabel with Verizon subheader font style font.*/
@interface CTSubheadThreeLabel : CTCustomLabel

@end

/*!UILabel with Roman font that use in gloable Verizon Wireless design. Font size will be the size set by user in storyboard.*/
@interface CTRomanFontLabel : CTCustomLabel

@end

/*!UILabel with font @b NHaasGroteskDSStd65Md that use in gloable Verizon Wireless design. Font size will be the size set by user in storyboard.*/
@interface CTNHaasGroteskDSStd65MdLabel : CTCustomLabel

@end
