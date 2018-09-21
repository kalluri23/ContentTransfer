//
//  UIViewController+Convenience.m
//  contenttransfer
//
//  Created by Development on 8/15/16.
//  Copyright © 2016 Verizon. All rights reserved.
//

#import "UIViewController+Convenience.h"

@implementation UIViewController (Convenience)

+ (instancetype)initialiseFromStoryboard:(UIStoryboard *)storyboard {
    
    
    id viewController = [storyboard instantiateViewControllerWithIdentifier:NSStringFromClass([self class])];
    
    NSAssert(viewController, @"Please check implementation, viewController should have identifier exactly matching class name");
    
    return viewController;
}

- (void)popToRootViewController:(Class)classname{
    
    NSArray *viewStacks = self.navigationController.viewControllers;
    
    for (int i=0; i<viewStacks.count; i++) { // find to root view controller in the view stack, in case of adding more views in stack and change the index of the view
        UIViewController *controller = (UIViewController *)[viewStacks objectAtIndex:i];
        
        if ([controller isKindOfClass:classname]) { 
            [self.navigationController popToViewController:controller animated:YES];
            break;
        }
    }
}


@end
