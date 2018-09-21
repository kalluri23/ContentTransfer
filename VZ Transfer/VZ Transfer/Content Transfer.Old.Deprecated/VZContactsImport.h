//
//  VZContactsImport.h
//  VZTransferSocket
//
//  Created by VVM-MAC02 on 11/18/15.
//  Copyright © 2015 Testing. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AddressBook/AddressBook.h>
#import <UIKit/UIKit.h>
#import "CTMVMAlertAction.h"
#import "CTMVMAlertObject.h"
#import "CTMVMAlertHandler.h"
#import "CTMVMAlertController.h"

typedef void (^importCompletionBlock)(NSInteger);

@interface VZContactsImport : NSObject{
    
    ABAddressBookRef addressBook;
    ABRecordRef personRecord;
    NSString *base64image;
    
}
@property(nonatomic,strong) NSData *VcardNSData;
@property (nonatomic, copy) importCompletionBlock completionHandler;
@property (nonatomic, copy) importCompletionBlock updateHandler;

- (void) emptyAddressBook;
- (void) importAllVcard:(NSData *)vCardData;
- (void) checkContactAccessRights;

@end
