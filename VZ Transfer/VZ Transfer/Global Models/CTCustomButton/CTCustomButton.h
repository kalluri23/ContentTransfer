//
//  CTCustomButton.h
//  contenttransfer
//
//  Created by Development on 8/12/16.
//  Copyright © 2016 Verizon. All rights reserved.
//

#import <UIKit/UIKit.h>

/*!Base class for all custom button in content transfer.*/
@interface CTCustomButton : UIButton

@end

/*!Common verion styled button.*/
@interface CTCommonRedButton : CTCustomButton
/*!Config the button.*/
- (void)configure;

@end

/*!Common verion styled black button.*/
@interface CTCommonBlackButton : CTCustomButton
/*!Config the button.*/
- (void)configure;

@end

/*!Common verion styled button with border.*/
@interface CTRedBorderedButton : CTCustomButton
/*!Config the button.*/
- (void) configure;
/*!Try to simulate the common red button using red boardered button.*/
- (void)simulateCommonRedButton;

@end

/*!Common verion styled Black button with border.*/
@interface CTBlackBorderedButton : CTCustomButton
/*!Config the button.*/
- (void) configure;
/*!Try to simulate the common Black button using Black boardered button.*/
- (void)simulateCommonBlackButton;

@end
