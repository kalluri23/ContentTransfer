//
//  CTFrameworkClipboardStatus.h
//  contenttransfer
//
//  Created by Sun, Xin on 3/28/17.
//  Copyright © 2017 Verizon Wireless Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

/*!
 Object to refresh the clipboard in MVM.
 MVM will check method from this object to decide the action they are doing for their clipboard.
 */
@interface CTFrameworkClipboardStatus : NSObject
/*!
 Singlton initializer for CTFrameworkClipboardStatus object.
 @return CTFrameworkClipboardStatus object for use.
 */
+ (instancetype)sharedInstance;
/*!
 Call it when content transfer use clipboard (which is copy the password of Hotspot), update the password.
 @param password Password string got from Android hotspot and to be updated.
 */
- (void)pasteBoardDidPastePassword:(NSString *)password;
/*!
 Check pasteboard contains password from content transfer or not.
 
 Method will read string currently stored in clipboard and compare it with last password read from content transfer.
 
 If they match, means content transfer just update the clipboard, and user put the app into background to paste the password to Wi-Fi field. MVM should not clear the clipboard, method return YES.
 
 If they don't match, means content transfer is not using clipboard, MVM can handle.
 @returns Yes when content transfer needs clipboard; NO when doesn't.
 */
- (BOOL)pasteBoardHasContentTransferPassword;

@end
