//
//  VZContactsExport.m
//  VZTransferSocket
//
//  Created by VVM-MAC02 on 11/18/15.
//  Copyright © 2015 Testing. All rights reserved.
//

#import "VZContactsExport.h"
#import "NSString+CTContentTransferRootDocuments.h"

@implementation VZContactsExport

- (BOOL)isABAddressBookCreateWithOptionsAvailable {
    return &ABAddressBookCreateWithOptions != NULL;
}


- (void)exportContactsAsVcard:(void(^)(int))handler andFailure:(void(^)(NSError *error))failureHandler
{
    
    success = FALSE;
    
    CFErrorRef err = nil;
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, &err);
    
    if (err) {
        // handle error
        failureHandler((__bridge NSError *)(err));
        CFRelease(err);
        return;
    }
    
    ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
        // ABAddressBook doesn't gaurantee execution of this block on main thread, but we want our callbacks to be
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!granted) {
                failureHandler((__bridge NSError *)(error));
            } else {
                readAddressBookContacts(addressBook);
                CFRelease(addressBook);
                
                handler(numberOfContacts);
            }
        });
    });
}


static void readAddressBookContacts(ABAddressBookRef addressBook) {
    // do stuff with addressBook
    
    NSFileManager *fileManager;
    NSString * filePath;
    NSData * vCards;
    
    fileManager = [NSFileManager defaultManager];
    
    /*
     * We are getting all contact's references as array.
     * And using that array we are creating our vCard
     * representaion of our contacts.
     */
    CFArrayRef contacts = ABAddressBookCopyArrayOfAllPeople(addressBook);
    vCards = (__bridge NSData *)(ABPersonCreateVCardRepresentationWithPeople(contacts));
    
    NSArray *array = (__bridge NSArray*)contacts;
    
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault setObject:[NSString stringWithFormat:@"%lu",(unsigned long)[array count]] forKey:@"TOTALNUMBEROFCONTACT"];
    if ([array count] > 0) {
        [userDefault setObject:[NSString stringWithFormat:@"%lu",(unsigned long)vCards.length] forKey:@"CONTACTTOTALSIZE"];
        
    }
    
     numberOfContacts = (int)[array count];
    
    /*
     * I used current date for backup file's names.
     * For this reason I prefered to  use "yyyy_MM_dd_HH_mm_ss" format for date
     * which is year_month_day_hour(in 24-hour clock)_minute_seconds.
     * (For 12-hour clock format you can you "hh" instead of "HH".)
     */
    
    NSString *basePath = [NSString appRootDocumentDirectory];
    
    /*
     * We are assigning our filePath variable with our application's document path appended with our file's name.
     */
    filePath = [NSString stringWithFormat:@"%@/VZAllContactBackup.vcf",basePath];
    
    /*
     * Finally, we create our backup file which contains our contact's information.
     */
    [fileManager createFileAtPath:filePath contents:vCards attributes:nil];
    
    CFRelease(contacts);
}


//- (void)doSomethingWithCompletionHandler:(void(^)(int))handler andFailure:(void(^)(NSError *error))failureHandler
//{
//    // NOTE: copying is very important if you'll call the callback asynchronously,
//    // even with garbage collection!
//    _completionHandler = [handler copy];
//    _failureHandler = [failureHandler copy];
//    
//    // Do stuff, possibly asynchronously...
//    
//    [self exportContactsAsVcard];
//    
//    // Call completion handler.
//    //    _completionHandler(numberOfContacts);
//    
//    // Clean up.
//    // [_completionHandler release];
//    //    _completionHandler = nil;
//}

//- (BOOL)checkContactAccessRights {
//    
//    if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusDenied ||
//        ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusRestricted){
////        DebugLog(@"Denied");
//        //    UIAlertView *cantAddContactAlert = [[UIAlertView alloc] initWithTitle: @"Cannot Add Contact" message: @"You must give the app permission to add the contact first." delegate:nil cancelButtonTitle: @"OK" otherButtonTitles: nil];
//        //    [cantAddContactAlert show];
//        
//        ABAddressBookRequestAccessWithCompletion(ABAddressBookCreateWithOptions(NULL, nil), ^(bool granted, CFErrorRef error) {
//            dispatch_async(dispatch_get_main_queue(), ^{
//                if (!granted){
//                    
//                    
//                    CTMVMAlertAction *cancelAction = [CTMVMAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
//                    
//                    NSString *str = [NSString stringWithFormat:@"Please Grant permission and try again :Settings-->Privacy-->Contacts--> My Verizon"];
//                    
//                    MVMAlertObject* alertObject = [[MVMAlertObject alloc] initWithTitle:@"Cannot Add Contact"
//                                                                                message:str
//                                                                           cancelAction:cancelAction otherActions:nil isGreedy:NO];
//                    
//                    
//                    [[CTMVMAlertHandler sharedAlertHandler] showAlertWithAlertObject:alertObject];
//                    
//                    
////                    return ;
//                }
//            });
//        });
//        
//    } else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized){
////        DebugLog(@"Authorized");
//        
//        return true;
//        
//    } else{ //ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined
////        DebugLog(@"Not determined");
//        ABAddressBookRequestAccessWithCompletion(ABAddressBookCreateWithOptions(NULL, nil), ^(bool granted, CFErrorRef error) {
//            dispatch_async(dispatch_get_main_queue(), ^{
//                if (!granted){
//                    CTMVMAlertAction *cancelAction = [CTMVMAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
//                    
//                   NSString *str = [NSString stringWithFormat:@"Please Grant permission and try again :Settings-->Privacy-->Contacts--> My Verizon"];
//                    
//                    MVMAlertObject* alertObject = [[MVMAlertObject alloc] initWithTitle:@"Cannot Add Contact"
//                                                                                message:str
//                                                                           cancelAction:cancelAction otherActions:nil isGreedy:NO];
//                    
//                    
//                    [[CTMVMAlertHandler sharedAlertHandler] showAlertWithAlertObject:alertObject];
////                    return;
//                }
//            });
//        });
//    }
//    
//    return false;
//}

@end
