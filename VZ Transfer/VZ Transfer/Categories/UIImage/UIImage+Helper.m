//
//  UIImage+Helper.m
//  contenttransfer
//
//  Created by Hadapad, Prakash on 8/26/16.
//  Copyright © 2016 Hadapad, Prakash. All rights reserved.
//

#import "UIImage+Helper.h"
#import "VZViewUtility.h"

@implementation UIImage (Helper)

+ (UIImage *)getImageFromBundleWithImageName:(NSString *)imageName {
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
        return [UIImage imageNamed:imageName inBundle:[VZViewUtility bundleForFramework] compatibleWithTraitCollection:nil];
    } else {
        return [UIImage imageNamed:imageName];
    }
}

@end
