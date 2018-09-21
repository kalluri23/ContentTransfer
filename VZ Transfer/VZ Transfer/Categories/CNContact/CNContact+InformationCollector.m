//
//  CNContact+InformationCollector.m
//  test
//
//  Created by Sun, Xin on 5/24/17.
//  Copyright © 2017 Sun, Xin. All rights reserved.
//

#import "CNContact+InformationCollector.h"

@implementation CNContact (InformationCollector)

/*! Enum type indicate the value type of CNContact.*/
typedef NS_ENUM(NSInteger, CTContactInformationValueType)  {
    /*! Phone numbers of contact.*/
    CTContactInformationValueTypePhones = 0,
    /*! Emails of contact.*/
    CTContactInformationValueTypeEmails,
    /*! URL addresses of contact.*/
    CTContactInformationValueTypeUrlAddresses,
    /*! Postal addresses of contact.*/
    CTContactInformationValueTypePostalAddresses,
    /*! Birthday of contact.*/
    CTContactInformationValueTypeBirthday,
    /*! Dates of contact.*/
    CTContactInformationValueTypeDates,
    /*! Relations of contact.*/
    CTContactInformationValueTypeRelations,
    /*! Social profile of contact.*/
    CTContactInformationValueTypeSocialProfile,
    /*! Instant message of contact.*/
    CTContactInformationValueTypeInstantMessage,
    /*! Note of contact.*/
    CTContactInformationValueTypeNote
};

- (BOOL)contactHasSameNameAs:(CNContact *)targetContact {
    if (((!self.namePrefix && !targetContact.namePrefix) || [self.namePrefix isEqualToString:targetContact.namePrefix]) // name prefix
        &&
        ((!self.givenName && !targetContact.givenName) || [self.givenName isEqualToString:targetContact.givenName]) // first name
        &&
        ((!self.phoneticGivenName && !targetContact.phoneticGivenName) || [self.phoneticGivenName isEqualToString:targetContact.phoneticGivenName]) // phonetic first name
        &&
        ((!self.middleName && !targetContact.middleName) || [self.middleName isEqualToString:targetContact.middleName]) // middle name
        &&
        ((!self.phoneticMiddleName && !targetContact.phoneticMiddleName) || [self.phoneticMiddleName isEqualToString:targetContact.phoneticMiddleName]) // phonetic middle name
        &&
        ((!self.familyName && !targetContact.familyName) || [self.familyName isEqualToString:targetContact.familyName]) // last name
        &&
        ((!self.phoneticFamilyName && !targetContact.phoneticFamilyName) || [self.phoneticFamilyName isEqualToString:targetContact.phoneticFamilyName]) // phonetic last name
        &&
        ((!self.previousFamilyName && !targetContact.previousFamilyName) || [self.previousFamilyName isEqualToString:targetContact.previousFamilyName]) // maiden name
        &&
        ((!self.nameSuffix && !targetContact.nameSuffix) || [self.nameSuffix isEqualToString:targetContact.nameSuffix]) // name suffix
        &&
        ((!self.nickname && !targetContact.nickname) || [self.nickname isEqualToString:targetContact.nickname]) // nickname
        &&
        ((!self.jobTitle && !targetContact.jobTitle) || [self.jobTitle isEqualToString:targetContact.jobTitle]) // job title
        &&
        ((!self.departmentName && !targetContact.departmentName) || [self.departmentName isEqualToString:targetContact.departmentName]) // department name
        &&
        ((!self.organizationName && !targetContact.organizationName) || [self.organizationName isEqualToString:targetContact.organizationName]))  // company
    { // If name matches
        if (SYSTEM_VERSION_LESS_THAN(@"10.0")) {
            return YES;
        } else if ((!self.phoneticOrganizationName && !targetContact.phoneticOrganizationName) || [self.phoneticOrganizationName isEqualToString:targetContact.phoneticOrganizationName]) {
            return YES;
        } else {
            return NO;
        }
    } else {
        return NO;
    }
}

- (BOOL)hasPhoneNumbers {
    return self.phoneNumbers.count > 0;
}

- (BOOL)hasEmails {
    return self.emailAddresses.count > 0;
}

- (BOOL)hasURLAddresses {
    return self.urlAddresses.count > 0;
}

- (BOOL)hasAddresses {
    return self.postalAddresses.count > 0;
}

- (BOOL)hasDates {
    return self.dates > 0;
}

- (BOOL)hasBirthday {
    return self.birthday != nil || self.nonGregorianBirthday != nil;
}

- (BOOL)hasRelatedNames {
    return self.contactRelations.count > 0;
}

- (BOOL)hasSocialProfile {
    return self.socialProfiles.count > 0;
}

- (BOOL)hasInstantMessage {
    return self.instantMessageAddresses.count > 0;
}

- (BOOL)hasNote {
    return self.note.length > 0;
}

- (BOOL)contactHasSamePhoneRecordsAs:(CNContact *)targetContact {
    return [self abstractHasSameValue:CTContactInformationValueTypePhones asRecord:targetContact];
}

- (BOOL)contactHasSameEmailRecordsAs:(CNContact *)targetContact {
    return [self abstractHasSameValue:CTContactInformationValueTypeEmails asRecord:targetContact];
}

- (BOOL)contactHasSameURLAddressesRecordsAs:(CNContact *)targetContact {
    return [self abstractHasSameValue:CTContactInformationValueTypeUrlAddresses asRecord:targetContact];
}

- (BOOL)contactHasSamePostalAddressesRecordsAs:(CNContact *)targetContact {
    return [self abstractHasSameValue:CTContactInformationValueTypePostalAddresses asRecord:targetContact];
}

- (BOOL)contactHasSameBirthdayRecordsAs:(CNContact *)targetContact {
    return [self abstractHasSameValue:CTContactInformationValueTypeBirthday asRecord:targetContact];
}

- (BOOL)contactHasSameDatesRecordsAs:(CNContact *)targetContact {
    return [self abstractHasSameValue:CTContactInformationValueTypeDates asRecord:targetContact];
}

- (BOOL)contactHasSameRelationsRecordsAs:(CNContact *)targetContact {
    return [self abstractHasSameValue:CTContactInformationValueTypeRelations asRecord:targetContact];
}

- (BOOL)contactHasSameSocialProfileRecordsAs:(CNContact *)targetContact {
    return [self abstractHasSameValue:CTContactInformationValueTypeSocialProfile asRecord:targetContact];
}

- (BOOL)contactHasSameInstantMessageRecordsAs:(CNContact *)targetContact {
    return [self abstractHasSameValue:CTContactInformationValueTypeInstantMessage asRecord:targetContact];
}

- (BOOL)contactHasSameNoteRecordsAs:(CNContact *)targetContact {
    return [self abstractHasSameValue:CTContactInformationValueTypeNote asRecord:targetContact];
}
/*!
     @brief General method to check two record have same information for specific value type.
     @param value CTContactInformationValueType enum type represents the current type of value.
     @param targetConact CNContact object represents the contact that needs to be compared with current object.
     @return Bool value represents the result of comparsion.
 */
- (BOOL)abstractHasSameValue:(enum CTContactInformationValueType)value asRecord:(CNContact *)targetContact {
    NSArray *targetValueArray = [targetContact contactGetArrayForValue:value];
    NSArray *selfValueArray   = [self contactGetArrayForValue:value];
    if (selfValueArray.count != targetValueArray.count) {
        // if count doesn't match, consider as new record.
        return NO;
    }
    if (value == CTContactInformationValueTypeBirthday) { // if it's date components
        for (NSDateComponents *targetBirthday in targetValueArray) {
            @autoreleasepool {
                BOOL foundSame = NO;
                for (NSDateComponents *localBirthday in selfValueArray) {
                    if ([self compareDateComponents:targetBirthday with:localBirthday]) {
                        foundSame = YES;
                        break;
                    }
                }
                
                if (!foundSame) { // any date didnt found, failed
                    return NO;
                }
            }
        }
        
        return YES;
    } else if (value == CTContactInformationValueTypeNote) { // if it's string
        NSString *targetNote = targetValueArray[0];
        NSString *selfNote   = selfValueArray[0];
        
        if ([targetNote isEqualToString:selfNote]) {
            return YES;
        }
        
        return NO;
    }
    
    // check current record contains each of the record in target contacts or not.
    for (CNLabeledValue *labeledValue in targetValueArray) {
        @autoreleasepool {
            if (![self abstract:value containsValue:labeledValue inCurrentSet:selfValueArray]) {
                // Found any record doesn't match, failed
                return NO;
            }
        }
    }
    
    // All records match, success.
    return YES;
}
/*!
     @brief Check date components. If it's equal, return YES. Only check year, month, day and leapMonth section.
     @param local NSDateComponents for one.
     @param target NSDateComponents for another one.
     @return BOOL value for result.
 */
- (BOOL)compareDateComponents:(NSDateComponents *)local with:(NSDateComponents *)target {
    if (((!local.year && !target.year) || local.year == target.year)
        &&
        (local.leapMonth == target.leapMonth)
        &&
        ((!local.month && !target.month) || local.month == target.month)
        &&
        ((!local.day && !target.day) || local.day == target.day)
        &&
        ((!local.era && !target.era) || local.era == target.era)) {
        return YES;
    }
    
    return NO;
}
/*!
     @brief General method to check specific value exists in specific value sets or not.
     @param value CTContactInformationValueType enum type represents the current type of value.
     @param targetLabelValue CNLabeledValue object represents the value need to be searched.
     @param valueArray NSArray represents the current value set to run the check.
     @return Bool value represents the result of comparsion.
 */
- (BOOL)abstract:(enum CTContactInformationValueType)value containsValue:(CNLabeledValue *)targetLabelValue inCurrentSet:(NSArray *)valueArray {
    for (CNLabeledValue *labeledValue in valueArray) { // each of record in current set
        @autoreleasepool {
            if ([labeledValue.label isEqualToString:targetLabelValue.label]) { // label equals
                switch (value) {
                    case CTContactInformationValueTypePhones:
                        if ([[[((CNPhoneNumber *)labeledValue.value).stringValue componentsSeparatedByCharactersInSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]] componentsJoinedByString:@""] isEqualToString:[[((CNPhoneNumber *)targetLabelValue.value).stringValue componentsSeparatedByCharactersInSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]] componentsJoinedByString:@""]]) {
                            // when value and label both same, then pass
                            return YES;
                        }
                        break;
                        
                    case CTContactInformationValueTypePostalAddresses: {
                        CNPostalAddress *local  = (CNPostalAddress *)labeledValue.value;
                        CNPostalAddress *target = (CNPostalAddress *)targetLabelValue.value;
                        if (((!local.street && !target.street) || ([local.street isEqualToString:target.street]))
                            &&
                            (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"10.3") ? ((!local.subLocality && !target.subLocality) || ([local.subLocality isEqualToString:target.subLocality])) : NO)
                            &&
                            ((!local.city && !target.city) || ([local.city isEqualToString:target.city]))
                            &&
                            (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"10.3") ? ((!local.subAdministrativeArea && !target.subAdministrativeArea) || ([local.subAdministrativeArea isEqualToString:target.subAdministrativeArea])) : NO)
                            &&
                            ((!local.state && !target.state) || ([local.state isEqualToString:target.state]))
                            &&
                            ((!local.postalCode && !target.postalCode) || ([local.postalCode isEqualToString:target.postalCode]))
                            &&
                            ((!local.country && !target.country) || ([local.country isEqualToString:target.country]))
                            &&
                            ((!local.ISOCountryCode && !target.ISOCountryCode) || ([local.ISOCountryCode isEqualToString:target.ISOCountryCode]))) {
                            // when all the stree address same, then pass
                            return YES;
                        }
                    } break;
                        
                    case CTContactInformationValueTypeDates: {
                        NSDateComponents *local  = (NSDateComponents *)labeledValue.value;
                        NSDateComponents *target = (NSDateComponents *)targetLabelValue.value;
                        if ([self compareDateComponents:local with:target]) {
                            // if two dates equal, the pass
                            return YES;
                        }
                    } break;
                        
                    case CTContactInformationValueTypeRelations: {
                        CNContactRelation *local  = (CNContactRelation *)labeledValue.value;
                        CNContactRelation *target = (CNContactRelation *)targetLabelValue.value;
                        if ([local.name isEqualToString:target.name]) { // Name cannot be nil, if there is relation label exists
                            return YES;
                        }
                    } break;
                        
                    case CTContactInformationValueTypeSocialProfile: {
                        CNSocialProfile *local  = (CNSocialProfile *)labeledValue.value;
                        CNSocialProfile *target = (CNSocialProfile *)targetLabelValue.value;
                        if (((!local.urlString && !target.urlString) || ([local.urlString isEqualToString:target.urlString]))
                            &&
                            ((!local.username && !target.username) || ([local.username isEqualToString:target.username]))
                            &&
                            ((!local.userIdentifier && !target.userIdentifier) || ([local.userIdentifier isEqualToString:target.userIdentifier]))
                            &&
                            ((!local.service && !target.service) || ([[local.service lowercaseString] isEqualToString:[target.service lowercaseString]]))) {
                            // when all items matche, then pass
                            return YES;
                        }
                    } break;
                        
                    case CTContactInformationValueTypeInstantMessage: {
                        CNInstantMessageAddress *local  = (CNInstantMessageAddress *)labeledValue.value;
                        CNInstantMessageAddress *target = (CNInstantMessageAddress *)targetLabelValue.value;
                        if (((!local.username && !target.username) || ([local.username isEqualToString:target.username]))
                            &&
                            ((!local.service && !target.service) || ([local.service isEqualToString:target.service]))) {
                            // when all items matche, then pass
                            return YES;
                        }
                    } break;
                        
                    default:
                        if ([((NSString *)labeledValue.value) isEqualToString:((NSString *)targetLabelValue.value)]) {
                            // when value and label both same, then pass
                            return YES;
                        }
                        break;
                }
            }
        }
    }
    // didn't found any match, failed.
    return NO;
}
/*!
     @brief Get current value set for specific type
     @param value CTContactInformationValueType enum value represents the type.
     @return Object represents the data set.
 */
- (NSArray *)contactGetArrayForValue:(enum CTContactInformationValueType)value {
    switch (value) {
        case CTContactInformationValueTypePhones:
            return self.phoneNumbers;
            break;
        case CTContactInformationValueTypeEmails:
            return self.emailAddresses;
            break;
        case CTContactInformationValueTypeUrlAddresses:
            return self.urlAddresses;
            break;
        case CTContactInformationValueTypePostalAddresses:
            return self.postalAddresses;
            break;
        case CTContactInformationValueTypeBirthday: {
            NSMutableArray *dobArray = [[NSMutableArray alloc] init];
            if (self.birthday) {
                [dobArray addObject:self.birthday];
            }
            if (self.nonGregorianBirthday) {
                [dobArray addObject:self.nonGregorianBirthday];
            }
            return dobArray;
        } break;
        case CTContactInformationValueTypeDates:
            return self.dates;
            break;
        case CTContactInformationValueTypeRelations:
            return self.contactRelations;
            break;
        case CTContactInformationValueTypeSocialProfile:
            return self.socialProfiles;
            break;
        case CTContactInformationValueTypeInstantMessage:
            return self.instantMessageAddresses;
            break;
        case CTContactInformationValueTypeNote:
            return @[self.note];
            break;
    }
}

@end
