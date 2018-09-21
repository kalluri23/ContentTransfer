//
//  UIView+CTMVMConvenience.m
//  contenttransfer
//
//  Created by Hadapad, Prakash on 8/31/16.
//  Copyright © 2016 Hadapad, Prakash. All rights reserved.
//

#import "UIView+CTMVMConvenience.h"

@implementation UIView (CTMVMConvenience)

- (UIView *) directSubviewWithTag:(NSInteger)tag {
    for(UIView *view in self.subviews) {
        if(view.tag == tag) {
            return view;
        }
    }
    return nil;
}


@end
