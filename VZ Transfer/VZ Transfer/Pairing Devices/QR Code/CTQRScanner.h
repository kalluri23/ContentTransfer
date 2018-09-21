//
//  CTQRScanner.h
//  contenttransfer
//
//  Created by Sun, Xin on 9/29/17.
//  Copyright © 2017 Verizon Wireless Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
/*!
 @brief Scanner object for content transfer to scan the QR Code. This object contains all the logic to reading the image, but not parse the information inside the code.
 
 This object init the library and camera that using to capture the image, and use delegate method to communicate the host view controller.
 @note This object only contains logic to identify the QR code. If wants to support extra bar code. Need modification.
 */
@class CTQRScanner;

#pragma mark - Protocol
/*!
 @brief Protocol to return the result of capturing bar code trough CTQRScanner.
 
 If information are successfully read, QRScanner:didSuccessfullyScannedQRCode: will be revoked; Otherwise QRScanner:didFailedScannedQRCode:handler will be revorked.
 
 @warning All methods are required if delegate is specified. Any view controller with delegate specified and missing any methods should expect app crash.
 */
@protocol CTQRScannerDelegate <NSObject>
/*!
 @brief QRScanner will call this method if it successfully read the information from QR code.
 @note This method will only return whatever string read from code. Any Decrytion or parsing should be host view controller's responsibility.
 @param scanner QRScanner object represents the current working object.
 @param qrCodeString NSString contained inside QR code.
 */
- (void)QRScanner:(CTQRScanner *)scanner didSuccessfullyScannedQRCode:(NSString *)qrCodeString;
/*!
 @brief QRScanner will call this method if it fail to read the information from QR code.
 @param scanner QRScanner object represents the current working object.
 @param reason Error reason for the failure. Use to show to users.
 @param handler Handler to run any futhure code after host view controller revoke the delegate method. Like change flags after user's tap.
 */
- (void)QRScanner:(CTQRScanner *)scanner didFailedScannedQRCode:(NSString *)reason handler:(void (^)(void))handler;

@end

@interface CTQRScanner : NSObject
#pragma mark - Public properties
/*!
 @brief Delegate for CTQRScanner. This is mandentory property for this object. Any class are using this object without delegate should expect crash.
 */
@property (nonatomic, weak) id<CTQRScannerDelegate> delegate;
/*!
 @brief Error message for scanner. If device cannot init the scanner, proper error will be assigned.
 @note Read this error when isScannerEnabled is YES, will get misleading information, since this error message is not clear for sure. But it's for sure provide updated error message if isScannerEnabled is NO.
 */
@property (nonatomic, strong) NSError *scannerError;
/*!
 @brief BOOL value indicate that CTQRScanner is init properly or not.
 @discussion Always check this value before using scanner. If this value is YES, then run attach and start scanner will start reading bar codes; Otherwise calling attach and start scanner will do nothing.
 */
@property (nonatomic, assign) BOOL isScannerEnabled;
/*!
 @brief BOOL value indicate that scanner is started; When the session is init properly and running, this value will return YES; Otherwise will return NO.
 */
@property (nonatomic, assign) BOOL scannerStarted;

#pragma mark - Initializer
/*!
 @brief Singlton initializer for CTQRScanner.
 */
+ (instancetype)shared;
/*!
 @brief Method to enable the scanner for specfic view in view controller. This method is require before using scanner. But only need to run on time. Next time running this will only update UI property.
 @param view UIView object that contains the camera view.
 */
- (void)enableScannerforTarget:(UIView *)view;


#pragma mark - Scanner operations
/*!
 @brief Start scanning the QR code.
 */
- (void)startScanner;
/*!
 @brief Stop scanning the QR code.
 */
- (void)stopScanner;
/*!
 @brief Attach the camera view to the target view.
 */
- (void)attachScanner;
/*!
 @brief Detach the camera view to the target view.
 */
- (void)detachScanner;
/*!
 @brief Call this method, scanner will ignore all the incoming bar code processes, even it's valid one.
 */
- (void)scannerShouldIgnoreFutherReadForAlert;
/*!
 @brief Call this method, scanner will resume reading the bar code process. No scannerShouldIgnoreFutherReadForAlert called, then no need to intentionally call this method.
 */
- (void)scannerShouldstartReading;

@end
