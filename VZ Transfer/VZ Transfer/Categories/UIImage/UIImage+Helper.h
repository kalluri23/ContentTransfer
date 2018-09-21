//
//  UIImage+Helper.h
//  contenttransfer
//
//  Created by Hadapad, Prakash on 8/26/16.
//  Copyright © 2016 Hadapad, Prakash. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Helper)

/*!
    @brief Try to get image from project bundle using specific name. This is UIImage class method.
    @param imageName String value represents the name of the image.
    @return UIImage object saved in bundle and with specific name.
 */
+ (UIImage *)getImageFromBundleWithImageName:(NSString *)imageName;

@end
