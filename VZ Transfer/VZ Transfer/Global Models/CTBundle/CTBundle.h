//
//  CTBundle.h
//  CTTransfer
//
//  Created by Development on 8/9/16.
//  Copyright © 2016 Verizon. All rights reserved.
//

#import <Foundation/Foundation.h>
/*! 
    @brief Bundle manager class for content transfer app. All the operations related to NSBundle go into this class.
 */
@interface CTBundle : NSObject

/*!
    @brief Get the resouce bundle for app.
    @return NSBundle object represent for content transfer app.
 */
+ (nullable NSBundle *)resourceBundle;

@end
