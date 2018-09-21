//
//  NSData+CTVCFFileDataHelper.m
//  contenttransfer
//
//  Created by Sun, Xin on 10/5/17.
//  Copyright © 2017 Verizon Wireless Inc. All rights reserved.
//

#import "NSData+CTVCFFileDataHelper.h"
#import <AddressBook/AddressBook.h>

@implementation NSData (CTVCFFileDataHelper)

+ (NSData *)generateVcardDataFor:(CFArrayRef)contacts {
    // Get original data from contacts array(system generated)
    CFDataRef vCardsRef = ABPersonCreateVCardRepresentationWithPeople(contacts);
    NSData *vCards = (__bridge NSData *)vCardsRef;
    CFRelease(vCardsRef);
    // Get data from string
    NSString *vcfString = [[NSString alloc] initWithData:vCards encoding:NSUTF8StringEncoding];
    NSLog(@"Original vCard string:\n%@", vcfString);
    vCards = nil; // release
    // Get contact array in vcf file
    NSMutableArray *contactsStringArray = [[vcfString componentsSeparatedByString:@"END:VCARD"] mutableCopy]; // Will return contact total count + 1 sized array. Last object inside array is \r\n.
    for (CFIndex i = 0; i<CFArrayGetCount(contacts); i++) {
        ABRecordRef person = CFArrayGetValueAtIndex(contacts, i);
        // Find notes
        CFTypeRef noteRef = ABRecordCopyValue(person, kABPersonNoteProperty);
        NSString *contactString = [contactsStringArray objectAtIndex:i]; // Index of original array and vcf string array should be same.
        if (noteRef) {
            NSString *note = (__bridge NSString *)noteRef;
            NSLog(@"Note found:%@", note);
            CFRelease(noteRef);
            // Add notes into vcf string
            contactString = [contactString stringByAppendingString:[NSString stringWithFormat:@"NOTE:%@", note]];
            contactString = [contactString stringByAppendingString:@"\r\nEND:VCARD"];
            NSLog(@"Revised vcf string:\n%@", contactString);
            // Update existing string
            [contactsStringArray replaceObjectAtIndex:i withObject:contactString];
        } else {
            // Add END:VCARD back into vcf string
            contactString = [contactString stringByAppendingString:@"END:VCARD"];
            NSLog(@"Revised vcf string:\n%@", contactString);
            // Update existing string
            [contactsStringArray replaceObjectAtIndex:i withObject:contactString];
        }
    }
    
    NSString *newFormatedVCFString = [contactsStringArray componentsJoinedByString:@""];
    NSLog(@"New vcf file string:\n %@", newFormatedVCFString);
    
    return [newFormatedVCFString dataUsingEncoding:NSUTF8StringEncoding];
}

@end
