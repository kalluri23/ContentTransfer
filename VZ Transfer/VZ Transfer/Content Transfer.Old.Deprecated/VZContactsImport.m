//
//  VZContactsImport.m
//  VZTransferSocket
//
//  Created by VVM-MAC02 on 11/18/15.
//  Copyright © 2015 Testing. All rights reserved.
//

#import "VZContactsImport.h"

@interface VZContactsImport()

@property (nonatomic, assign) NSInteger numberOfContacts;

@end

@implementation VZContactsImport

@synthesize completionHandler;
@synthesize numberOfContacts;

- (id) init {
    if (self = [super init]) {
        addressBook = ABAddressBookCreate();
    }
    
    return self;
}


- (void) emptyAddressBook {
    CFArrayRef people = ABAddressBookCopyArrayOfAllPeople(addressBook);
    int arrayCount = (int)CFArrayGetCount(people);
    ABRecordRef abrecord;
    
    for (int i = 0; i < arrayCount; i++) {
        abrecord = CFArrayGetValueAtIndex(people, i);
        ABAddressBookRemoveRecord(addressBook,abrecord, NULL);
    }
    CFRelease(people);
    ABAddressBookSave(addressBook, nil);
}

- (void)importAllVcard:(NSData *)VcardData {
    
    ABAddressBookRef book = ABAddressBookCreate();
    ABRecordRef defaultSource = ABAddressBookCopyDefaultSource(book);
    CFArrayRef vCardPeople = ABPersonCreatePeopleInSourceWithVCardRepresentation(defaultSource, (__bridge CFDataRef)(VcardData));
    
    NSInteger updateCount = 0;
    @try {
        numberOfContacts = CFArrayGetCount(vCardPeople);
        
        NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
        
        [userDefault setObject:[NSString stringWithFormat:@"%lu",(unsigned long)numberOfContacts] forKey:@"CONTACTSIMPORTED"];
        
        for (CFIndex index = 0; index < CFArrayGetCount(vCardPeople); index++) {
            @autoreleasepool {
                if (++updateCount <= 50) {
                    ABRecordRef person = CFArrayGetValueAtIndex(vCardPeople, index);
                    ABAddressBookAddRecord(book, person, NULL);
                    
                    if (updateCount == 50) {
                        ABAddressBookSave(book, NULL);
                        self.updateHandler(50);
                        updateCount = 0;
                    }
                }
            }
            
        }
        CFRelease(vCardPeople);
    } @catch (NSException *exception) {
        DebugLog(@"Error:%@", exception.description);
        numberOfContacts = 0;
    }
    
    CFRelease(defaultSource);
    if (updateCount > 0) {
        ABAddressBookSave(book, NULL);
        self.updateHandler(updateCount);
    }
    CFRelease(book);
    
    self.completionHandler(numberOfContacts);
    
}

- (void) checkContactAccessRights {
    
    if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusDenied ||
        ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusRestricted){
        //    UIAlertView *cantAddContactAlert = [[UIAlertView alloc] initWithTitle: @"Cannot Add Contact" message: @"You must give the app permission to add the contact first." delegate:nil cancelButtonTitle: @"OK" otherButtonTitles: nil];
        //    [cantAddContactAlert show];
        
        ABAddressBookRequestAccessWithCompletion(ABAddressBookCreateWithOptions(NULL, nil), ^(bool granted, CFErrorRef error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (!granted){
                    CTMVMAlertAction *cancelAction = [CTMVMAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
                    
                    NSString *str = [NSString stringWithFormat:@"Please Grant permission and try again :Settings-->Privacy-->Contacts--> My Verizon"];
                    
                    CTMVMAlertObject* alertObject = [[CTMVMAlertObject alloc] initWithTitle:@"Cannot Add Contact"
                                                                                message:str
                                                                           cancelAction:cancelAction otherActions:nil isGreedy:NO];
                    
                    
                    [[CTMVMAlertHandler sharedAlertHandler] showAlertWithAlertObject:alertObject];
                    
                    return;
                }
            });
        });
        
    } else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized){
        
    } else{ //ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined
        ABAddressBookRequestAccessWithCompletion(ABAddressBookCreateWithOptions(NULL, nil), ^(bool granted, CFErrorRef error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (!granted){
                    CTMVMAlertAction *cancelAction = [CTMVMAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
                    
                    NSString *str = [NSString stringWithFormat:@"Please Grant permission and try again :Settings-->Privacy-->Contacts--> My Verizon"];
                    
                    CTMVMAlertObject* alertObject = [[CTMVMAlertObject alloc] initWithTitle:@"Cannot Add Contact"
                                                                                message:str
                                                                           cancelAction:cancelAction otherActions:nil isGreedy:NO];
                    
                    
                    [[CTMVMAlertHandler sharedAlertHandler] showAlertWithAlertObject:alertObject];                    return;
                }
            });
        });
    }
}

- (void)dealloc
{
    if (addressBook != nil) {
        CFRelease(addressBook);
    }
}

@end
