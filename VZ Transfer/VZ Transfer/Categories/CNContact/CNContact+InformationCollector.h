//
//  CNContact+InformationCollector.h
//  test
//
//  Created by Sun, Xin on 5/24/17.
//  Copyright © 2017 Sun, Xin. All rights reserved.
//

#import <Contacts/Contacts.h>

@interface CNContact (InformationCollector)

/*!
    @brief This method will compare the names for two contacts
    @discussion This method will compare two records given, middle and family name(in most case, three of these names are enough to identify a person).
                Method will return Yes if name matches; If two record both don't have given/middle/family name or if have both equal, they will be considered as same record.
                otherwise return NO.
    @param targetContact CNContact object use to compare with.
    @return Bool value represent the comparsion result.
 */
- (BOOL)contactHasSameNameAs:(CNContact *)targetContact;
/*!
    @brief This method will check if contact record has photo numbers;
    @return Bool value for result
 */
- (BOOL)hasPhoneNumbers;
/*!
    @brief This method will check if contact record has emails;
    @return Bool value for result
 */
- (BOOL)hasEmails;
/*!
     @brief This method will check if contact record has URL addresses
     @return Bool value for result
 */
- (BOOL)hasURLAddresses;
/*!
     @brief This method will check if contact record has postal addresses
     @return Bool value for result
 */
- (BOOL)hasAddresses;
/*!
     @brief This method will check if contact record has birthday
     @return Bool value for result
 */
- (BOOL)hasBirthday;
/*!
     @brief This method will check if contact record has dates
     @return Bool value for result
 */
- (BOOL)hasDates;
/*!
     @brief This method will check if contact record has related names
     @return Bool value for result
 */
- (BOOL)hasRelatedNames;
/*!
     @brief This method will check if contact record has social profile
     @return Bool value for result
 */
- (BOOL)hasSocialProfile;
/*!
     @brief This method will check if contact record has instant message
     @return Bool value for result
 */
- (BOOL)hasInstantMessage;
/*!
     @brief This method will check if contact record has note
     @return Bool value for result
 */
- (BOOL)hasNote;
/*!
    @brief This method will check if two contact records have same phone number record;
    @discussion This method will go through all the phone numbers saved in targetContact and try to check each number existence in calling contact record.
    @param targetContact CNContact object to compare
    @return BOOL type for result. If all phone numbers in targetContacts exist in record, consider as YES; otherwise is NO.
 */
- (BOOL)contactHasSamePhoneRecordsAs:(CNContact *)targetContact;
/*!
    @brief This method will check if two contact records have same email record;
    @discussion This method will go through all the emails saved in targetContact and try to check each email existence in calling contact record.
    @param targetContact CNContact object to compare
    @return BOOL type for result. If all emails in targetContacts exist in record, consider as YES; otherwise is NO.
 */
- (BOOL)contactHasSameEmailRecordsAs:(CNContact *)targetContact;
/*!
     @brief This method will check if two contact records have same url addresses record;
     @discussion This method will go through all the url addresses saved in targetContact and try to check each url addresses existence in calling contact record.
     @param targetContact CNContact object to compare
     @return BOOL type for result. If all url addresses in targetContacts exist in record, consider as YES; otherwise is NO.
 */
- (BOOL)contactHasSameURLAddressesRecordsAs:(CNContact *)targetContact;
/*!
     @brief This method will check if two contact records have same postal addresses record;
     @discussion This method will go through all the postal address saved in targetContact and try to check each postal address existence in calling contact record.
     @param targetContact CNContact object to compare
     @return BOOL type for result. If all postal addresses in targetContacts exist in record, consider as YES; otherwise is NO.
 */
- (BOOL)contactHasSamePostalAddressesRecordsAs:(CNContact *)targetContact;
/*!
     @brief This method will check if two contact records have same birthday record;
     @discussion This method will go through all the birthday saved in targetContact and try to check each birthday existence in calling contact record.
     @param targetContact CNContact object to compare
     @return BOOL type for result. If all birthday in targetContacts exist in record, consider as YES; otherwise is NO.
 */
- (BOOL)contactHasSameBirthdayRecordsAs:(CNContact *)targetContact;
/*!
     @brief This method will check if two contact records have same dates record;
     @discussion This method will go through all the dates saved in targetContact and try to check each dates existence in calling contact record.
     @param targetContact CNContact object to compare
     @return BOOL type for result. If all dates in targetContacts exist in record, consider as YES; otherwise is NO.
 */
- (BOOL)contactHasSameDatesRecordsAs:(CNContact *)targetContact;
/*!
     @brief This method will check if two contact records have same relations record;
     @discussion This method will go through all the relations saved in targetContact and try to check each dates existence in calling contact record.
     @param targetContact CNContact object to compare
     @return BOOL type for result. If all relations in targetContacts exist in record, consider as YES; otherwise is NO.
 */
- (BOOL)contactHasSameRelationsRecordsAs:(CNContact *)targetContact;
/*!
     @brief This method will check if two contact records have same social profile record;
     @discussion This method will go through all the social profile saved in targetContact and try to check each dates existence in calling contact record.
     @param targetContact CNContact object to compare
     @return BOOL type for result. If all social profile in targetContacts exist in record, consider as YES; otherwise is NO.
 */
- (BOOL)contactHasSameSocialProfileRecordsAs:(CNContact *)targetContact;
/*!
     @brief This method will check if two contact records have same instant message record;
     @discussion This method will go through all the instant message saved in targetContact and try to check each dates existence in calling contact record.
     @param targetContact CNContact object to compare
     @return BOOL type for result. If all instant message in targetContacts exist in record, consider as YES; otherwise is NO.
 */
- (BOOL)contactHasSameInstantMessageRecordsAs:(CNContact *)targetContact;
/*!
     @brief This method will check if two contact records have same note record;
     @discussion This method will go through all the note saved in targetContact and try to check each dates existence in calling contact record.
     @param targetContact CNContact object to compare
     @return BOOL type for result. If all note in targetContacts exist in record, consider as YES; otherwise is NO.
 */
- (BOOL)contactHasSameNoteRecordsAs:(CNContact *)targetContact;

@end
