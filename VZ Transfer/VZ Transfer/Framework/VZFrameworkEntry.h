//
//  VZFrameworkEntry.h
//  contenttransfer
//
//  Created by Hadapad, Prakash on 8/16/16.
//  Copyright © 2016 Hadapad, Prakash. All rights reserved.
//  Validation String : 1234

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class VZDeviceSelectionVC;

/*!
 Old framework entry point. Deprecated. Use @b CTFrameworkEntryPoint
 @see CTFrameworkEntryPoint.h
 */
@interface VZFrameworkEntry : NSObject

- (VZDeviceSelectionVC *) LaunchContentTransfer;

@end
