//
//  CTContactsManager.h
//  contenttransfer
//
//  Created by Guntupalli, Neelima on 8/26/16.
//  Copyright © 2016 Verizon. All rights reserved.
//

#import <Foundation/Foundation.h>
/*!
 * @brief Manager to retrieve contacts from library. Also this library will be able to check the permission for contact.
 * @warning Since content transfer is supporting iOS 8 and above, for sender retrieveing, using ABAddressBook, not CNContact library.
 */
@interface CTContactsManager : NSObject
/*!
 * @brief Check user's permission to access contact library.
 * @returns CTAuthorizationStatus respresents the result.
 * @see CTAuthorizationStatus
 */
+ (CTAuthorizationStatus)contactsAuthorizationStatus;
/*!
 * @brief Request the authorization for accessing contact library.
 * @param completionBlock Block for result, contains user's decision for permission.
 * @see CTAuthorizationStatus
 */
+ (void)requestContactsAuthorisation:(void(^)(CTAuthorizationStatus status))completionBlock;
/*!
 * @brief Fetch contacts for current device. Vcf file will be generated after calling this method.
 * @discussion The directroy for saving vcf file in content transfer container is @b/Documents/Contacts/ContactsFile.vcf.
 * @param completionBlock Block for complete process. countOfContacts represents the total count of contacts in vcard; lengthOfData represents the size of file data.
 * @param failureBlock Block for failure process. Proper error message in NSError object will be returned with this block.
 */
+ (void)numberOfAddressBookContacts:(void(^)(NSInteger countOfContacts,float lengthOfData))completionBlock failureBlock:(void(^)(NSError *err))failureBlock;
@end
