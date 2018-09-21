//
//  CTContactsImport.h
//  VZTransferSocket
//
//  Created by VVM-MAC02 on 11/18/15.
//  Copyright © 2015 Testing. All rights reserved.
//
/*!
    @header CTContactsImport.h
    @discussion This is the header of CTContactsImport class.
 */
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <AddressBook/AddressBook.h>

/*! 
    @brief This is the block for contact import object.
    @param NSIntger represents the contact number.
 */
typedef void (^importCompletionBlock)(NSInteger);

/*!
    @brief This class will contains all the contact import logic.
 */
@interface CTContactsImport : NSObject
/*! vcard data needs to be import.*/
@property (nonatomic,strong) NSData *VcardNSData;
/*! @brief Completion handler when import contact finished.*/
@property (nonatomic, copy) importCompletionBlock completionHandler;
/*! @brief Update handler when import contact is in process.*/
@property (nonatomic, copy) importCompletionBlock updateHandler;

- (void)emptyAddressBook;
/*!
    @brief This method will do contact import.
    @discussion The library using for contact import based on device iOS version.
                
                If device run in iOS 10 and above, method will use CNCContact library.
                
                Otherwise method will use ABAddressBook library.
 
    @param vCardData NSData read from vcf file.
    @see ABAddressBook
    @see CNContact
 */
- (void)importAllVcard:(NSData *)vCardData;
/*! @b Deprecated.*/
- (void)checkContactAccessRights;

@end
