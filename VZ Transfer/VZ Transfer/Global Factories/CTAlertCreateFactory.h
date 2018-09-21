//
//  CTAlertCreateFactory.h
//  contenttransfer
//
//  Created by Sun, Xin on 9/7/16.
//  Copyright © 2016 Verizon Wireless. All rights reserved.
//

#import <Foundation/Foundation.h>

/*!
    @brief Factory class for UIAlertViewController
    @discussion This class provide three ways to generate common used alert view controller. The alert this class using is CTMVMAlertObject.
 
    @see CTMVMAlertObject.
 */
@interface CTAlertCreateFactory : NSObject
/*!
    @brief Create alert with two buttons. Method will create a alert and show on the current presenting view controller. No alert object will be returned.
    @param title title text for alert.
    @param context body text for alert.
    @param cancelText title text for button with cancel style(bold font).
    @param confirmText title text for button with default style.
    @param confirmHandler handler block to define the operation after user click confirm button.
    @param cancelHandler handler block to define the operation after user click cancel button.
    @param isGreedy Bool value represents the way of showing the alert. YES means no matter there is an alert showing or not. Always try to show current alert on top of the view structure. NO means current alert will go into a queue and wait for other alert to dimiss.
 */
+ (void)showTwoButtonsAlertWithTitle:(NSString *)title
                             context:(NSString *)context
                       cancelBtnText:(NSString *)cancelText
                      confirmBtnText:(NSString *)confirmText
                      confirmHandler:(void (^)(UIAlertAction *action))confirmHandler
                       cancelHandler:(void (^)(UIAlertAction *action))cancelHandler
                            isGreedy:(BOOL)isGreedy;
/*!
    @brief Create alert with two buttons. Method will create a alert and show on the current presenting view controller. The alert object will also be returned through block.
    @param title title text for alert.
    @param context body text for alert.
    @param cancelText title text for button with cancel style(bold font).
    @param confirmText title text for button with default style.
    @param confirmHandler handler block to define the operation after user click confirm button.
    @param cancelHandler handler block to define the operation after user click cancel button.
    @param isGreedy Bool value represents the way of showing the alert. YES means no matter there is an alert showing or not. Always try to show current alert on top of the view structure. NO means current alert will go into a queue and wait for other alert to dimiss.
    @param alertHandler block that will return the alert object created by method.
 */
+ (void)showTwoButtonsAlertWithTitle:(NSString *)title
                             context:(NSString *)context
                       cancelBtnText:(NSString *)cancelText
                      confirmBtnText:(NSString *)confirmText
                      confirmHandler:(void (^)(UIAlertAction *action))confirmHandler
                       cancelHandler:(void (^)(UIAlertAction *action))cancelHandler
                            isGreedy:(BOOL)isGreedy
                           withAlert:(void (^)(id alert))alertHandler;
/*!
    @brief Create alert with single button. Method will create a alert and show on the current presenting view controller.
    @param title title text for alert.
    @param context body text for alert.
    @param btnText title text for button.
    @param handler block to define the operation after user click button.
    @param isGreedy Bool value represents the way of showing the alert. YES means no matter there is an alert showing or not. Always try to show current alert on top of the view structure. NO means current alert will go into a queue and wait for other alert to dimiss.
 */
+ (void)showSingleButtonsAlertWithTitle:(NSString *)title
                                context:(NSString *)context
                                btnText:(NSString *)btnText
                                handler:(void (^)(UIAlertAction *action))handler
                               isGreedy:(BOOL)isGreedy;

@end
