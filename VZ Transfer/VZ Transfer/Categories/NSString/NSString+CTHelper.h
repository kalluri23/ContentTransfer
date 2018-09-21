//
//  NSString+CTHelper.h
//  contenttransfer
//
//  Created by Mehta, Snehal Natwar on 9/13/16.
//  Copyright © 2016 Verizon Wireless. All rights reserved.
//

@interface NSString (CTHelper)
#pragma mark -  Instance methods
/*!
    @brief Compare target string with current string with case insensitive.
    @return BOOL value indicate two strings are same or not.
 */
- (BOOL)isEqualToCaseInsensitiveString:(NSString *)aString;
/*!
    @brief Get data type in display format based on current format.
    @return NSString value represents the data type.
 */
- (NSString *)pluralMediaType;
/*!
    @brief Re-format the UDID string. XXXX-XXXX will be changed to xxxxxxxx, by removing the - and make characters into lower case.
    @warning Current string value should represent the UDID string, otherwise result will be incorrect.
    @return NSString value represents the UDID string.
 */
- (NSString*)lowerUDIDString;
/*!
    @brief Format the timestamp string to "xxx hrs xxx mins xxx sec".
    @warning Current string should represent the format string.
    @return Formatted time string.
 */
- (NSString *)formatTime;
/*!
    @brief Edit all the device model string by replacing , to _.
    @return NString value represent device model in new format.
 */
- (NSString *)editDeviceModel;
/*!
    @brief Try to print the target mask in human readable way.
    @return NSString value represents the readable mask.
 */
- (NSString *)printMask:(int)mask;
/*!
    @brief This method will encode the NSString using base64 algorithm.
    @return NSString represent encoded the string.
 */
- (NSString*)encodeStringTo64;
/*!
    @brief Decode the string useing base64 algorithm.
    @return Decoded NSString value.
 */
- (NSString*)decodeStringTo64;
/*!
    @brief Generate UDID.
    @return NSString value represents the UDID.
    @see NSUUID
 */

#pragma mark -  Class methods
/*!
    @brief Generate device UDID.
    @return NSString represents UDID for current device.
 */
+ (NSString *)generateUDID;
/*!
    @brief Get device vendor ID.
    @return NSString represents vendor ID for current device.
    @see identifierForVendor
 */
+ (NSString *)deviceVID;

@end
