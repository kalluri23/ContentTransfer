//
//  NSNumber+CTHelper.h
//  contenttransfer
//
//  Created by Mehta, Snehal Natwar on 9/19/16.
//  Copyright © 2016 Verizon Wireless. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSNumber (CTHelper)
/*!
 This method will translate number in bytes into MB with measurement. Example: Input 2.5 return "2.5 MB".
 
 If input is less than 0.1, return 0.1 as minimum value.
 @note Result will be kept 2 digits after the decimal.
 @param amount Number represents size in byte, saved in NSNumber, should be double type.
 @return NSString value represents MB number in string format.
 */
+ (NSString *)formattedDataSizeText:(NSNumber *)amount;
/*!
    @brief      This method will translate number in bytes into MB.
    @discussion This method will get proper number in MB and translate into NSString
    @param amount number represents size in byte, saved in NSNumber, should be double type.
    @return     NSString value represents MB number in string format.
 */
+ (NSString *)toMBs:(NSNumber *)amount;
/*!
    @brief Convert long long byte value to Megabytes.
    @param amount Long long value represents the size in bytes.
    @return double Double value represents same size in MB.
 */
+ (double)toMB:(long long)amount;
/*!
 Get only 2 digit after decimal for double.
 
 This method will convert the double input into NSString as %.2f, and convert back to double to keep the 2 decimal digits.
 @param input: Double input value.
 @return Double value only contains 2 decimal digits.
 */
+ (double)getOnly2Decimal:(double)input;

@end
