//
//  CTContactsManager.m
//  contenttransfer
//
//  Created by Guntupalli, Neelima on 8/26/16.
//  Copyright © 2016 Verizon. All rights reserved.
//

#import "CTContactsManager.h"
#import "CTFileManager.h"
#import "NSData+CTVCFFileDataHelper.h"

#import <AddressBook/AddressBook.h>

@implementation CTContactsManager
#pragma mark - Public class API
+ (CTAuthorizationStatus)contactsAuthorizationStatus{
    
    if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized) {
        return CTAuthorizationStatusAuthorized;
    } else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusDenied || ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusRestricted) {
        return CTAuthorizationStatusDenied;
    } else {
        return CTAuthorizationNotDetermined;
    }
}

+ (void)requestContactsAuthorisation:(void(^)(CTAuthorizationStatus status))completionBlock{
    
    ABAddressBookRequestAccessWithCompletion([self createAddressBook], ^(bool granted, CFErrorRef error) {
        
        if (granted) {
            completionBlock(CTAuthorizationStatusAuthorized);
        }else{
            completionBlock(CTAuthorizationStatusDenied);
        }
    });
}

+ (void)numberOfAddressBookContacts:(void(^)(NSInteger countOfContacts,float lengthOfData))completionBlock failureBlock:(void(^)(NSError *err))failureBlock {
    ABAddressBookRef addressBook = [self createAddressBook];
    if (addressBook) {
        CFArrayRef contacts = ABAddressBookCopyArrayOfAllPeople(addressBook);
        NSData *vCards = [NSData generateVcardDataFor:contacts];
        
        [CTFileManager createDirectory:@"Contacts" withFileName:@"ContactsFile.vcf" withContents:vCards completionBlock:^(NSString *filePath, NSError *error) {
            if (!error) {
                completionBlock(CFArrayGetCount(contacts), vCards.length);
                CFRelease(contacts);
            } else {
                DebugLog(@"Error creating vcf %@",[error localizedDescription]);
                failureBlock(error);
            }
        }];
    }
}

#pragma mark - Convenients
+ (ABAddressBookRef)createAddressBook{
    CFErrorRef err = nil;
    static ABAddressBookRef addressBook;
    if (addressBook) {
        return addressBook;
    }
    addressBook = ABAddressBookCreateWithOptions(NULL, &err);
    
    if (err) {
        CFRelease(err);
        return nil;
    }
    
    return addressBook;
    
}

@end
