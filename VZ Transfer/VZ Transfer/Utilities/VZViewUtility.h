//
//  VZViewUtility.h
//  contenttransfer
//
//  Created by Hadapad, Prakash on 8/19/16.
//  Copyright © 2016 Hadapad, Prakash. All rights reserved.
//

#import <Foundation/Foundation.h>
/*!
    @brief This is a Utility class for View related method.
 */
@interface VZViewUtility : NSObject
/*!
    @brief Try to get the bundle for framework. This is a class method.
    @return NSBundle represent the current bundle for project/framework.
 */
+ (nonnull NSBundle *)bundleForFramework;

@end
