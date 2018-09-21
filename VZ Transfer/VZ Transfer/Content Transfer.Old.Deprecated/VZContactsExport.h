//
//  VZContactsExport.h
//  VZTransferSocket
//
//  Created by VVM-MAC02 on 11/18/15.
//  Copyright © 2015 Testing. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AddressBook/AddressBook.h>
#import <UIKit/UIKit.h>
#import "CTMVMAlertAction.h"
#import "CTMVMAlertController.h"
#import "CTMVMAlertObject.h"
#import "CTMVMAlertHandler.h"

static int numberOfContacts;

@interface VZContactsExport : NSObject
{
    
    BOOL success;
//    void (^_completionHandler)(int someParameter);
//    void (^_failureHandler)(NSError * error);
}



- (void)exportContactsAsVcard:(void(^)(int))handler andFailure:(void(^)(NSError *error))failureHandler;

//- (void) doSomethingWithCompletionHandler:(void(^)(int))handler andFailure:(void(^)(NSError *error))failureHandler;
@end
