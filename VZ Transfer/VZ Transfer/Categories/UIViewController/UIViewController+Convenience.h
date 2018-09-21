//
//  UIViewController+Convenience.h
//  contenttransfer
//
//  Created by Development on 8/15/16.
//  Copyright © 2016 Verizon. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (Convenience)
/*!
 Initialize UIViewController from storyboard.
 
 When fetching the view controller, method will use controller class name as view identifier.
 @warning If want to use this method, please use class name as its identifier.
 @param storyboard with target view controller.
 @return View controller object get from storyboard.
 */
+ (instancetype)initialiseFromStoryboard:(UIStoryboard *)storyboard;
/*!
 Pop to given view controller. Method will try to find the controller matches given class type inside navigation stack.
 
 Nothing will happen if no given type of view controller had been pushed into stack before calling it.
 */
- (void)popToRootViewController:(Class)classname;

@end
