//
//  NSData+CTVCFFileDataHelper.h
//  contenttransfer
//
//  Created by Sun, Xin on 10/5/17.
//  Copyright © 2017 Verizon Wireless Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (CTVCFFileDataHelper)
/*!
 * @brief Generate the vcard data of vcf file for given contacts. This is NSData class method, will revise the system generated vcard data.
 * @discussion Because ABAddressBook library will not get notes from contact record, so this method will manually added notes section into vcf file.
 * @note Based on vcf file standard, "NOTE:XXXX" will be the readable format for contact note.
 * @param contacts CFArrayRef represents the contacts, outside method owns the contacts, so inside method no need to release it.
 * @returns NSData represents the new vcf file data contains notes.
 */
+ (NSData *)generateVcardDataFor:(CFArrayRef)contacts;

@end
