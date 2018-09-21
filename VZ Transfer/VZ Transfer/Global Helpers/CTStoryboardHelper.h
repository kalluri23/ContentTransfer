//
//  CTStoryboardHelper.h
//  contenttransfer
//
//  Created by Development on 8/11/16.
//  Copyright © 2016 Verizon. All rights reserved.
//

#import <Foundation/Foundation.h>

/*!
    @brief Helper class for storyboard operations
 */
@interface CTStoryboardHelper : NSObject
/*!
 Get device storyboard.
 @return Target storyboard object.
 */
+ (nonnull UIStoryboard *)devicesStoryboard;
/*!
 Get Wi-Fi and P2P storyboard.
 @return Target storyboard object.
 */
+ (nonnull UIStoryboard *)wifiAndP2PStoryboard;
/*!
 Get bonjour storyboard.
 @return Target storyboard object.
 */
+ (nonnull UIStoryboard *)bonjourStoryboard;
/*!
 Get transfer storyboard.
 @return Target storyboard object.
 */
+ (nonnull UIStoryboard *)transferStoryboard;
/*!
 Get common storyboard.
 @return Target storyboard object.
 */
+ (nonnull UIStoryboard *)commonStoryboard;
/*!
 Get sender scanner and QR code storyboard.
 @return UIStoryboard object contains specific view controller.
 */
+ (nonnull UIStoryboard *)qrCodeAndScannerStoryboard;

@end
