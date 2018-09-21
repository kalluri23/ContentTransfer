//
//  CTAlertCreateFactory.m
//  contenttransfer
//
//  Created by Sun, Xin on 9/7/16.
//  Copyright © 2016 Verizon Wireless. All rights reserved.
//

#import "CTAlertCreateFactory.h"

#import "CTMVMAlertObject.h"
#import "CTMVMAlertAction.h"
#import "CTMVMAlertHandler.h"

@implementation CTAlertCreateFactory

+ (void)showTwoButtonsAlertWithTitle:(nonnull NSString *)title
                             context:(nonnull NSString *)context
                       cancelBtnText:(nonnull NSString *)cancelText
                      confirmBtnText:(nonnull NSString *)confirmText
                      confirmHandler:(void (^)(UIAlertAction *action))confirmHandler
                       cancelHandler:(void (^)(UIAlertAction *action))cancelHandler
                            isGreedy:(BOOL)isGreedy
{
    dispatch_async(dispatch_get_main_queue(), ^{
        CTMVMAlertAction *okAction = [CTMVMAlertAction actionWithTitle:confirmText style:UIAlertActionStyleDefault handler:confirmHandler];
        CTMVMAlertAction *cancelAction = [CTMVMAlertAction actionWithTitle:cancelText style:UIAlertActionStyleCancel handler:cancelHandler];
        CTMVMAlertObject *alertObject = [[CTMVMAlertObject alloc] initWithTitle:title
                                                                        message:context
                                                                   cancelAction:okAction
                                                                   otherActions:@[cancelAction]
                                                                       isGreedy:isGreedy];
        
        [[CTMVMAlertHandler sharedAlertHandler] showAlertWithAlertObject:alertObject];
    });
}

+ (void)showTwoButtonsAlertWithTitle:(nonnull NSString *)title
                             context:(nonnull NSString *)context
                       cancelBtnText:(nonnull NSString *)cancelText
                      confirmBtnText:(nonnull NSString *)confirmText
                      confirmHandler:(void (^)(UIAlertAction *action))confirmHandler
                       cancelHandler:(void (^)(UIAlertAction *action))cancelHandler
                            isGreedy:(BOOL)isGreedy
                           withAlert:(void (^)(id alert))alertHandler
{
    dispatch_async(dispatch_get_main_queue(), ^{
        CTMVMAlertAction *okAction = [CTMVMAlertAction actionWithTitle:confirmText style:UIAlertActionStyleDefault handler:confirmHandler];
        CTMVMAlertAction *cancelAction = [CTMVMAlertAction actionWithTitle:cancelText style:UIAlertActionStyleCancel handler:cancelHandler];
        CTMVMAlertObject *alertObject = [[CTMVMAlertObject alloc] initWithTitle:title
                                                                        message:context
                                                                   cancelAction:okAction
                                                                   otherActions:@[cancelAction]
                                                                       isGreedy:isGreedy];
        
        alertHandler([[CTMVMAlertHandler sharedAlertHandler] showAlertWithAlertObject:alertObject]);
    });
}

+ (void)showSingleButtonsAlertWithTitle:(nonnull NSString *)title
                                context:(nonnull NSString *)context
                                btnText:(nonnull NSString *)btnText
                                handler:(void (^)(UIAlertAction *action))handler
                               isGreedy:(BOOL)isGreedy
{
    dispatch_async(dispatch_get_main_queue(), ^{
        CTMVMAlertAction *cancelAction = [CTMVMAlertAction actionWithTitle:btnText style:UIAlertActionStyleCancel handler:handler];
        CTMVMAlertObject *alertObject = [[CTMVMAlertObject alloc] initWithTitle:title
                                                                        message:context
                                                                   cancelAction:cancelAction
                                                                   otherActions:nil
                                                                       isGreedy:isGreedy];
        
        [[CTMVMAlertHandler sharedAlertHandler] showAlertWithAlertObject:alertObject];
    });
}

@end
