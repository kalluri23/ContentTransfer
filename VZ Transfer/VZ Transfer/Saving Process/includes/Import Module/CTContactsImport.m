//
//  CTContactsImport.m
//  VZTransferSocket
//
//  Created by VVM-MAC02 on 11/18/15.
//  Copyright © 2015 Testing. All rights reserved.
//

#import "CTContactsImport.h"
#import "CTMVMAlertAction.h"
#import "CTMVMAlertObject.h"
#import "CTMVMAlertHandler.h"
#import "CTMVMAlertController.h"

// Add new contact library for iOS 10 and above
#import <Contacts/Contacts.h>
#import "CNContact+InformationCollector.h"

@interface CTContactsImport() {
    ABAddressBookRef addressBook;
    ABRecordRef personRecord;
    NSString *base64image;
}

@property (nonatomic, assign) NSInteger numberOfContacts;

@end

@implementation CTContactsImport

@synthesize completionHandler;
@synthesize numberOfContacts;

- (id) init {
    if (self = [super init]) {
        addressBook = ABAddressBookCreate();
    }
    
    return self;
}

- (void)emptyAddressBook {
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
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"9.0")) {
        // If iOS version is above 9, use new logic
        [self importContactFromVcardFileUsingNewLibrary:VcardData];
    } else {
        // If iOS version is below 9, use old logic
        [self importContactsUseAddressbook:VcardData];
    }
}

/*!
    @brief This method use ABAddressBook library to import contacts.
 
           This method contains old library logic for importing contacts.
    @note When large amount of contacts, iOS 10.3.x and above cause some parsing issue. So use new libarary method when iOS is above 10.
    @warning This is old logic for importing the contacts, since view duplicate logic checking for all types of columns, this method should be changed. But not much user use iOS old version device as receiver, so leave it for now. When get chance, complete it.
    @param VcardData NSData read from vcf file.
 */
- (void)importContactsUseAddressbook:(NSData *)VcardData {
#warning TODO: NEED TO COMPLETE DUPLICATE LOGIC FOR OLD LOGIC, NEW LOGIC ALREADY FINISHED. SINCE MOST CASES TRANSFER RECEIVED BY NEWLY DEVICE, THIS IS NOT VERY URGENT.
    ABAddressBookRef book = ABAddressBookCreate();
    
    // Get local address book data
    NSArray *localAllPeople = (NSArray *)CFBridgingRelease(ABAddressBookCopyArrayOfAllPeople(book));
    NSLog(@"local vcard count:%lu", (unsigned long)localAllPeople.count);
    
    // Read data from vcf file
    ABRecordRef defaultSource = ABAddressBookCopyDefaultSource(book);
    CFDataRef vCardData = CFDataCreate(NULL, VcardData.bytes, VcardData.length);
    CFArrayRef vCardPeople = ABPersonCreatePeopleInSourceWithVCardRepresentation(defaultSource, vCardData);
    
    CFRelease(vCardData);
    
    NSInteger updateCount = 0, needSavedCount = 0;
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%lu",(unsigned long)CFArrayGetCount(vCardPeople)] forKey:@"CONTACTTOTALCOUNT"];
    
    for (CFIndex index = 0; index < CFArrayGetCount(vCardPeople); index++) {
        @autoreleasepool {
            ABRecordRef person = CFArrayGetValueAtIndex(vCardPeople, index);
            
            // Get the name for record
            NSString *firstname = nil, *middlename = nil, *lastname = nil;
            [self getName:person asFirstname:&firstname andMiddleaname:&middlename andLastname:&lastname];
            
            // Get the phone numbers
            NSArray *phoneNumbers = [self getPhoneNumbers:person];
            
            // Get the emails
            NSArray *emails = [self getEmailAddresses:person];
            
            // Build a predicate that searches for contacts that match the name and phone number/email
            NSPredicate *predicate = [NSPredicate predicateWithBlock: ^(id record, NSDictionary *bindings) {
                // Record from local address book
                NSString *localFirstName = nil, *localMiddleName = nil, *localLastName = nil;
                [self getName:(__bridge ABRecordRef)record asFirstname:&localFirstName andMiddleaname:&localMiddleName andLastname:&localLastName]; // Get name for local record
                if (((!firstname && !localFirstName) || [firstname isEqualToString:localFirstName])
                    && ((!middlename && !localMiddleName) || [middlename isEqualToString:localMiddleName])
                    && ((!lastname && !localLastName) || [lastname isEqualToString:localLastName])) { // If name matches
                    
                    if (phoneNumbers.count > 0) { // Check the phone number if phone number exists
                        ABMultiValueRef localPhoneNumbers = ABRecordCopyValue((__bridge ABRecordRef)record, kABPersonPhoneProperty);
                        if (ABMultiValueGetCount(localPhoneNumbers) != phoneNumbers.count) {
                            return NO;
                        } else if (ABMultiValueGetCount(localPhoneNumbers) == phoneNumbers.count) {
                            for (CFIndex i = 0; i < ABMultiValueGetCount(localPhoneNumbers); i++) {
                                NSString *localPhoneNumber = (__bridge NSString *)ABMultiValueCopyValueAtIndex(localPhoneNumbers, i);
                                // Remove special characters
                                localPhoneNumber = [[localPhoneNumber componentsSeparatedByCharactersInSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]] componentsJoinedByString:@""];
                                if (![phoneNumbers containsObject:localPhoneNumber]) { // Phone number also match
                                    CFRelease(localPhoneNumbers);
                                    return NO;
                                }
                            }
                            
                            if (localPhoneNumbers) {
                                CFRelease(localPhoneNumbers);
                            }
                        }
                    }
                    
                    if (emails.count > 0) { // Check the email if phone number doesn't exist
                        ABMultiValueRef localEmails = ABRecordCopyValue((__bridge ABRecordRef)record, kABPersonEmailProperty);
                        if (ABMultiValueGetCount(localEmails) != emails.count) {
                            return NO;
                        } else if (ABMultiValueGetCount(localEmails) == emails.count) {
                            for (CFIndex i = 0; i < ABMultiValueGetCount(localEmails); i++) {
                                NSString *localEmail = (__bridge NSString *)ABMultiValueCopyValueAtIndex(localEmails, i);
                                if (![emails containsObject:localEmail]) {
                                    CFRelease(localEmails);
                                    return NO;
                                }
                            }
                        }
                        
                        if (localEmails)
                            CFRelease(localEmails);
                    }
                    
                    return YES;
                } else {
                    return NO;
                }
            }];
            
            // Search the users address book for contacts that contain the phone number
            NSArray *filteredContacts = [localAllPeople filteredArrayUsingPredicate:predicate];
            if (filteredContacts.count == 0) { // No duplicate contacts, then save them.
                ABAddressBookAddRecord(book, person, NULL);
                ++needSavedCount;
                NSLog(@"->save!");
            } else {
                updateCount += 1;
                numberOfContacts += 1;
                NSLog(@"->duplicate!");
            }
            
            if (updateCount == 50) { // For update the UI
                self.updateHandler(50);
                updateCount = 0;
            }
            
            if (needSavedCount == 50) {
                if (ABAddressBookSave(book, NULL)) {
                    numberOfContacts += 50;
                    self.updateHandler(50);
                }
                needSavedCount = 0; // reset the saved count
            }
        }
    }
    
    CFRelease(vCardPeople);
    CFRelease(defaultSource);
    
    if (needSavedCount > 0) { // Save rest of the contact record
        if (ABAddressBookSave(book, NULL)) {
            numberOfContacts += needSavedCount;
        }
    }
    
    CFRelease(book);
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%lu",(unsigned long)numberOfContacts] forKey:@"CONTACTSIMPORTED"];
    self.completionHandler(numberOfContacts);
}

/*!
    @brief This method will get the firstname/middlename/lastname from ABRecordRef.
    @discussion This method has no return value, the name get from record will be assign to specific NSString pointer.
    @param person ABRecrodRef represent contact information.
    @param firstname NSString pointer point to the memory save the firstname value.
    @param middlename NSString pointer point to the memory save the middlename value.
    @param lastname NSString pointer point to the memory save the lastname value.
 */
- (void)getName:(ABRecordRef)person asFirstname:(NSString **)firstname andMiddleaname:(NSString **)middlename andLastname:(NSString **)lastname {
    CFTypeRef firstNameRef = ABRecordCopyValue(person, kABPersonFirstNameProperty);
    CFTypeRef middleNameRef = ABRecordCopyValue(person, kABPersonMiddleNameProperty);
    CFTypeRef lastNameRef = ABRecordCopyValue(person, kABPersonLastNameProperty);
    
    *firstname = (__bridge NSString *)firstNameRef;
    *middlename = (__bridge NSString *)middleNameRef;
    *lastname = (__bridge NSString *)lastNameRef;
    
    if (firstNameRef)
        CFRelease(firstNameRef);
    
    if (middleNameRef)
        CFRelease(middleNameRef);
    
    if (lastNameRef)
        CFRelease(lastNameRef);
}

/*!
    @brief This method will get the phone numbers saved in contact record.
    @param person ABRecrodRef represent contact information.
    @return NSArray contains all the phone numbers saved.
 */
- (NSArray *)getPhoneNumbers:(ABRecordRef)person {
    ABMultiValueRef phones = ABRecordCopyValue(person, kABPersonPhoneProperty);
    NSMutableArray* phoneNumbers = [(__bridge NSArray*)ABMultiValueCopyArrayOfAllValues(phones) mutableCopy];
    for (int idx = 0; idx < phoneNumbers.count; idx++) {
        NSString *phoneNumber = [phoneNumbers stringAtIndex:idx];
        NSString *newPhoneNumber = [[phoneNumber componentsSeparatedByCharactersInSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]] componentsJoinedByString:@""];
        [phoneNumbers replaceObjectAtIndex:idx withObject:newPhoneNumber];
    }
    
    if (phones)
        CFRelease(phones);
    
    return phoneNumbers;
}

/*!
    @brief This method will get the emails saved in contact record.
    @param person ABRecrodRef represent contact information.
    @return NSArray contains all the emails saved.
 */
- (NSArray *)getEmailAddresses:(ABRecordRef)person {
    ABMultiValueRef emailsRef = ABRecordCopyValue(person, kABPersonEmailProperty);
    NSArray* emails = (__bridge NSArray*)ABMultiValueCopyArrayOfAllValues(emailsRef);
    
    if (emailsRef)
        CFRelease(emailsRef);
    
    return emails;
}

- (void)checkContactAccessRights {
    
    if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusDenied ||
        ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusRestricted){
        
        ABAddressBookRequestAccessWithCompletion(ABAddressBookCreateWithOptions(NULL, nil), ^(bool granted, CFErrorRef error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (!granted){
                    CTMVMAlertAction *cancelAction = [CTMVMAlertAction actionWithTitle:CTLocalizedString(CTAlertGeneralOKTitle, nil) style:UIAlertActionStyleCancel handler:nil];
                    
                    NSString *str = [NSString stringWithFormat:@"%@", CTLocalizedString(CT_GRANT_CONTACTS_PERM_ALERT_CONTEXT, nil)];
                    
                    CTMVMAlertObject* alertObject = [[CTMVMAlertObject alloc] initWithTitle:CTLocalizedString(CT_GRANT_CONTACTS_PERM_ALERT_TITLE, nil)
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
                    CTMVMAlertAction *cancelAction = [CTMVMAlertAction actionWithTitle:CTLocalizedString(CTAlertGeneralOKTitle, nil) style:UIAlertActionStyleCancel handler:nil];
                    
                    NSString *str = [NSString stringWithFormat:@"%@", CTLocalizedString(CT_GRANT_CONTACTS_PERM_ALERT_CONTEXT, nil)];
                    
                    CTMVMAlertObject* alertObject = [[CTMVMAlertObject alloc] initWithTitle:CTLocalizedString(CT_GRANT_CONTACTS_PERM_ALERT_TITLE, nil)
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

#pragma mark - CNContact Library
/*!
    @brief This method using new contact library to import contacts
    @discussion This method targeting to avoid the large number of contacts that causing sorting too long exception when using old Addressbook library.
    @warning This method will only be used when iOS device version is above 10.
    @param vcardData NSData read from vcf file.
 */
- (void)importContactFromVcardFileUsingNewLibrary:(NSData *)vcardData {
    
    NSError *error = nil;
    NSArray *contactsArray = [CNContactVCardSerialization contactsWithData:vcardData error:&error];
    
    if (!error) {
        
        // Global contact library params
        CNContactStore *store = [[CNContactStore alloc] init];
        CNSaveRequest *saveRequest = [[CNSaveRequest alloc] init];
        NSInteger updateCount = 0, needSaveCount = 0; // update count use for all records; needsavecount use for records which are not duplicate.
        
        // Get local contacts for duplicate logic
        NSError *fetchError = nil;
        NSArray *localContacts = [self fetchLocalContactsFromStore:store WithError:&fetchError];
        NSLog(@"Local contacts number:%lu", (unsigned long)localContacts.count);
        NSLog(@"=========================");
        
        if (contactsArray.count > 0) {
            NSArray *contactsInfoArray = [self parseContactInformationFromVcardFile:vcardData forContacts:contactsArray.count];
            
            // Try to add phonetic organization name into record manually due to Apple offical one doesn't do it.
            NSUInteger idx = 0;
            for (CNContact *contact in contactsArray) {
                
                @autoreleasepool {
                    
                    CNMutableContact* contactMutableCopy = [contact mutableCopy];
                    
                    NSString *phoneticOrganName = nil;
                    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"10.0") && [self contactWithInfomation:contactsInfoArray[idx++] hasPhoneticOrganName:&phoneticOrganName]) {
                        assert(phoneticOrganName != nil);
                        NSLog(@"Phonetic Organization Name Get: %@", phoneticOrganName);
                        contactMutableCopy.phoneticOrganizationName = phoneticOrganName;
                    }
                    
                    // Build a predicate that searches for contacts that contain the phone number
                    NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(CNContact * _Nullable record, NSDictionary<NSString *,id> * _Nullable bindings) {
                        // If all names and titles match each other
                        if ([contactMutableCopy contactHasSameNameAs:record]) {
                            // if record has phone numbers
                            if ([contactMutableCopy hasPhoneNumbers]) {
                                if (![contactMutableCopy contactHasSamePhoneRecordsAs:record]) {
                                    // if any phone number doesn't match, consider as new
                                    return NO;
                                }
                            }
                            // if record has emails
                            if ([contactMutableCopy hasEmails]) {
                                if (![contactMutableCopy contactHasSameEmailRecordsAs:record]) {
                                    // if any email doesn't match, consider as new
                                    return NO;
                                }
                            }
                            // if record has url addresses
                            if ([contactMutableCopy hasURLAddresses]) {
                                if (![contactMutableCopy contactHasSameURLAddressesRecordsAs:record]) {
                                    // if any url address doesn't match, consider as new
                                    return NO;
                                }
                            }
                            // if record has address
                            if ([contactMutableCopy hasAddresses]) {
                                if (![contactMutableCopy contactHasSamePostalAddressesRecordsAs:record]) {
                                    // if any postal address doesn't match, consider as new
                                    return NO;
                                }
                            }
                            // if record has birthday
                            if ([contactMutableCopy hasBirthday]) {
                                if (![contactMutableCopy contactHasSameBirthdayRecordsAs:record]) {
                                    // if any birthday doesn't match, consider as new
                                    return NO;
                                }
                            }
                            // if record has dates
                            if ([contactMutableCopy hasDates]) {
                                if (![contactMutableCopy contactHasSameDatesRecordsAs:record]) {
                                    // if any dates doesn't match, consider as new
                                    return NO;
                                }
                            }
                            // if record has relations
                            if ([contactMutableCopy hasRelatedNames]) {
                                if (![contactMutableCopy contactHasSameRelationsRecordsAs:record]) {
                                    // if any relations doesn't match, consider as new
                                    return NO;
                                }
                            }
                            // if record has social profile
                            if ([contactMutableCopy hasSocialProfile]) {
                                if (![contactMutableCopy contactHasSameSocialProfileRecordsAs:record]) {
                                    // if any social profile doesn't match, consider as new
                                    return NO;
                                }
                            }
                            // if record has instant message
                            if ([contactMutableCopy hasInstantMessage]) {
                                if (![contactMutableCopy contactHasSameInstantMessageRecordsAs:record]) {
                                    // if any instant message doesn't match, consider as new
                                    return NO;
                                }
                            }
                            
                            // if record has note
                            if ([contactMutableCopy hasNote]) {
                                if (![contactMutableCopy contactHasSameNoteRecordsAs:record]) {
                                    return NO;
                                }
                            }
                            
                            // No extra information except for same name, consider as duplicate
                            return YES;
                        } else { // if names and title don't match each other, then consider as new record.
                            return NO;
                        }
                    }];
                    
                    // Search the users contacts to match the predicate
                    NSArray *duplicatedContacts = [localContacts filteredArrayUsingPredicate:predicate];
                    if (duplicatedContacts.count == 0) {
                        NSLog(@"new!");
                        // Should add contacts into store
                        [saveRequest addContact:contactMutableCopy toContainerWithIdentifier:nil];
                        needSaveCount += 1;
                    } else {
                        updateCount += 1;
                        numberOfContacts += 1; // consider as saved successfully
                        NSLog(@"duplicate:%lu", (unsigned long)duplicatedContacts.count);
                    }
                    
                    if (needSaveCount == 50) { // save for every 50 contacts
                        if ([self saveContacts:saveRequest forStore:store]) {
                            numberOfContacts += 50;
                            self.updateHandler(50);
                        }
                        
                        needSaveCount = 0;
                        // Reset save request
                        saveRequest = nil;
                        saveRequest = [[CNSaveRequest alloc] init];
                    }
                    
                    if (updateCount == 50) { // For update the UI
                        self.updateHandler(updateCount);
                        updateCount = 0;
                    }
                }
            }
            
            if (needSaveCount > 0) { // Save rest of unsaved data
                if ([self saveContacts:saveRequest forStore:store]) {
                    numberOfContacts += needSaveCount;
                }
                
                needSaveCount = 0;
                // Reset save request
                saveRequest = nil;
            }
        } else {
            NSLog(@"Zero contact file exception.");
        }
    } else {
        NSLog(@"Error(%ld): %@", (long)error.code, error.localizedDescription);
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%lu",(unsigned long)numberOfContacts] forKey:@"CONTACTSIMPORTED"];
    [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%lu", (unsigned long)contactsArray.count] forKey:@"CONTACTTOTALCOUNT"];
    self.completionHandler(numberOfContacts);
}

/*!
    @brief This method will try to fetch the contacts on local device
    @discussion Method will only fetch given/middle/family names, phone numbers and email addresses for duplicate logic use.
                If error happen, error param will be assigned, and method will return empty array;
    @param error NSError pointer point to the memory that save the error message.
    @return NSArray represents all the contacts. Will be empty if there is no contacts saved locally or error happened during the fetching process.
 */
- (NSArray *)fetchLocalContactsFromStore:(CNContactStore *)store WithError:(NSError * __nullable * __nullable)error {
    
    NSMutableArray *contacts = [NSMutableArray array];
    
    CNContactFetchRequest *request = nil;
    if (SYSTEM_VERSION_LESS_THAN(@"10.0")) {
        request = [[CNContactFetchRequest alloc] initWithKeysToFetch:@[CNContactIdentifierKey, CNContactNamePrefixKey, CNContactGivenNameKey, CNContactMiddleNameKey, CNContactFamilyNameKey, CNContactPreviousFamilyNameKey, CNContactNameSuffixKey, CNContactNicknameKey, CNContactOrganizationNameKey, CNContactDepartmentNameKey, CNContactJobTitleKey, CNContactPhoneticGivenNameKey, CNContactPhoneticMiddleNameKey, CNContactPhoneticFamilyNameKey, CNContactBirthdayKey, CNContactNonGregorianBirthdayKey, CNContactNoteKey, CNContactPhoneNumbersKey, CNContactEmailAddressesKey, CNContactPostalAddressesKey, CNContactDatesKey, CNContactUrlAddressesKey, CNContactRelationsKey, CNContactSocialProfilesKey, CNContactInstantMessageAddressesKey]]; // Only get given/middle/family name, phone numbers and emails for duplicate use.
    } else {
        request = [[CNContactFetchRequest alloc] initWithKeysToFetch:@[CNContactIdentifierKey, CNContactNamePrefixKey, CNContactGivenNameKey, CNContactMiddleNameKey, CNContactFamilyNameKey, CNContactPreviousFamilyNameKey, CNContactNameSuffixKey, CNContactNicknameKey, CNContactOrganizationNameKey, CNContactDepartmentNameKey, CNContactJobTitleKey, CNContactPhoneticGivenNameKey, CNContactPhoneticMiddleNameKey, CNContactPhoneticFamilyNameKey, CNContactPhoneticOrganizationNameKey, CNContactBirthdayKey, CNContactNonGregorianBirthdayKey, CNContactNoteKey, CNContactPhoneNumbersKey, CNContactEmailAddressesKey, CNContactPostalAddressesKey, CNContactDatesKey, CNContactUrlAddressesKey, CNContactRelationsKey, CNContactSocialProfilesKey, CNContactInstantMessageAddressesKey]]; // Only get given/middle/family name, phone numbers and emails for duplicate use.
    }
    
    NSError *fetchError = nil;
    BOOL success = [store enumerateContactsWithFetchRequest:request error:&fetchError usingBlock:^(CNContact *contact, BOOL *stop) {
        [contacts addObject:contact];
    }];
    
    if (!success) {
        *error = fetchError;
        return @[];
    }
    
    return contacts;
}

/*!
    @brief This method will parse the vcf file to get vcard string for each of the CNCContact..
    @discussion Each valid section for contact saved in vcf file will start with "BEGIN:VCARD". This method use this header to seperate the vcard file into chunks.
    @warning Since first object will always be empty object, it should be removed before value returned.
    @param vcardData NSData object that read from vcf file.
    @param contactNumber NSInteger value represent the total number of contacts read from vcf file.
    @return Array represent the contact information in the same order as contact array. Number of the array should be same as contact array also.
 */
- (NSArray *)parseContactInformationFromVcardFile:(NSData *)vcardData forContacts:(NSInteger)contactNumber {
    
    NSString *fileString = [[NSString alloc] initWithData:vcardData encoding:NSUTF8StringEncoding];
    
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\n +" options:NSRegularExpressionCaseInsensitive error:&error];
    NSString *vcardStringWithoutNewLines = [regex stringByReplacingMatchesInString:fileString options:0 range:NSMakeRange(0, [fileString length]) withTemplate:@""];
    
    // Pull out each line from the vcard file
    NSMutableArray *vcards = [[vcardStringWithoutNewLines componentsSeparatedByString:@"BEGIN:VCARD"] mutableCopy];
    if (vcards.count > contactNumber) {
        [vcards removeObjectAtIndex:0]; // remove the necessary header
    }
    
    return vcards;
}

/*!
    @brief This method will check if contact vcard string contains Phonetic Organization Name section or not;
    @discussion Once this method found any secion called X-PHONETIC-ORG: and end with change line symbol, it will capture this information and return YES;
 
                Otherwise no value will return and method return NO.
 
    @param contactInfo NSString that represent the vcard string of current CNContact object.
    @param PONString NSString pointer that point to a NSString allocated memory to save the Phonetic Organization Name. If method cannot found any, this property will remain nil.
 
    @return Bool type represent Phonetic Organization Name is found or not.
 */
- (BOOL)contactWithInfomation:(NSString *)contactInfo hasPhoneticOrganName:(NSString *__nullable *__nullable)PONString {
    NSString *phoneticOrganString = nil;
    NSScanner *eventScanner = [NSScanner scannerWithString:contactInfo];
    [eventScanner scanUpToString:@"X-PHONETIC-ORG:" intoString:nil];
    [eventScanner scanUpToString:@"\n" intoString:&phoneticOrganString];
    
    if (phoneticOrganString.length > 0) {
        *PONString =
        phoneticOrganString = [[[[phoneticOrganString stringByReplacingOccurrencesOfString:@"\n" withString:@""] stringByReplacingOccurrencesOfString:@"\r" withString:@""] stringByReplacingOccurrencesOfString:@"X-PHONETIC-ORG:" withString:@""] stringByReplacingOccurrencesOfString:@" " withString:@""];;
        return YES;
    } else {
        return NO;
    }
}

/*!
    @brief This method will execute saveRequest for contact store.
    @discussion If something wrong happen during saving, error log will output to the console in Debug env. But in Prod env, process will continue without hold user back.
    @param saveRequest Request object need to be executed.
    @param store Contact store that need to save those contacts.
    @return YES if no issue; Otherwise return NO.
 */
- (BOOL)saveContacts:(CNSaveRequest *)saveRequest forStore:(CNContactStore *)store {
    NSError *saveError = nil;
    if (![store executeSaveRequest:saveRequest error:&saveError]) {
        NSLog(@"Error when saving:%@", saveError.localizedDescription);
        return NO;
    } else {
        NSLog(@"Success");
        return YES;
    }
}

@end
