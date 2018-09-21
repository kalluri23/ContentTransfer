//
//  CTFrameworkEntryPoint.h
//  contenttransfer
//
//  Created by Hadapad, Prakash on 07/13/18.
//  Copyright © 2016 Verizon Wireless. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CTStartupViewController;

/*!
 Enty point for content transfer.
 
 This object only working for framework in MVM. It provides one method to let MVM app delegate call it and push the app into content transfer.*/
@interface CTFrameworkEntryPoint : NSObject
/*!
 Method to launch content transfer from parent app.
 @return CTStartupViewController that represent the very first page of content transfer.
 */
- (CTStartupViewController *)launchContentTransferApp;

@end
