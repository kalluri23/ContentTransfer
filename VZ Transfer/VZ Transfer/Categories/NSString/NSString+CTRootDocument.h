//
//  NSString+CTRootDocument.h
//  contenttransfer
//
//  Created by Sun, Xin on 9/12/16.
//  Copyright © 2016 Verizon Wireless. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (CTRootDocument)

/*!
    @brief Get the root document directory from local storage of app(inside the sandbox).
    @return NSString value represents the full path of the document folder.
 */
+ (NSString *)appRootDocumentDirectory;

@end
