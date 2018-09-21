//
//  CTQRCode.h
//  contenttransfer
//
//  Created by Pena, Ricardo on 1/31/17.
//  Copyright © 2017 Verizon Wireless Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

/*!Object for QR code to pair the devices. */
@interface CTQRCode : NSObject
#pragma mark - Enums
/*! Enum value for QR information type. QRCode show these information in order.*/
typedef NS_ENUM (NSUInteger, CTQRInfo) {
    /*! App verison number.*/
    CTQRInfoVersionNumber,
    /*! Security type.*/
    CTQRInfoSecurityType,
    /*! Phone combination type.*/
    CTQRInfoCombinationType,
    /*! SSID.*/
    CTQRInfoSSID,
    /*! IP address.*/
    CTQRInfoIpAddress,
    /*! Password.*/
    CTQRInfoPasscode,
    /*! Connection type.*/
    CTQRInfoConnectionType,
    /*! Setup type.*/
    CTQRInfoSetupType,
    /*! Bonjour service name.*/
    CTQRInfoService,
};
/*! Enum value for QR code type. It represents how many section for QR code.*/
typedef enum : NSUInteger {
    /*! QR code contains 9 sections of information.*/
    CTQRCodeTypeNormal = 9,
    /*! QR code contains 8 sections of information.*/
    CTQRCodeTypeCross  = 8
} CTQRCodeType;

#pragma mark - Properties
/*! Verison of app. Use for version check.*/
@property (nonatomic, strong) NSString *appVersion;
/*! Verison of OS. Only available for iOS to iOS.*/
@property (nonatomic, strong) NSString *osVersion;
/*! Security type for Wi-Fi passcode. Unavailable on iPhone device, hard coded as "WPA"*/
@property (nonatomic, strong) NSString *securityType;
/*! Type of connection, value will be WifiDirect / Hotspot page / SSID.*/
@property (nonatomic, strong) NSString *connectionType;
/*! Type of setup, value will be Receiver/Sender.*/
@property (nonatomic, strong) NSString *setUpType;
/*! Platform value. Cross or same platform.*/
@property (nonatomic, strong) NSString *platform;
/*! SSID for current Wi-Fi.*/
@property (nonatomic, strong) NSString *ssid;
/*! IP address for current Wi-Fi.*/
@property (nonatomic, strong) NSString *ipAddress;
/*! Password for current Wi-Fi if available. Otherwise nil.*/
@property (nonatomic, strong) NSString *passcode;
/*! Bonjour service name, only work for iOS to iOS.*/
@property (nonatomic, strong) NSString *service;
/*! Port number string using for current Wi-Fi.*/
@property (nonatomic, strong) NSString *port;

#pragma mark - Instance methods
/*!
    @brief Initializer for CTQRCode object.
    @param platform NSString value represents the platform.
    @param ssid NSString value represents the SSID.
    @param ipAddress NSString value represents the IP.
    @param port NSString value represents the port number that Wi-Fi currently connecting.
    @param passcode NSString value represents the passcode using for current Wi-Fi, if it's available.
    @param service NSString value represents the service name use for Bonjour.
    @param setupType NSString value represents this device is sender or receiver.
    @return CTQRCode object.
 */
- (instancetype)initWithPlattform:(NSString *)platform
                          andSSID:(NSString *)ssid
                    andIPAddreess:(NSString *)ipAddress
                          andPort:(NSString *)port
                      andPasscode:(NSString *)passcode
                       andService:(NSString *)service
                     andSetupType:(NSString *)setupType;
/*!
    @brief Initializer for CTQRCode object.
    @param platform NSString value represents the platform.
    @param ssid NSString value represents the SSID.
    @param ipAddress NSString value represents the IP.
    @param setupType NSString value represents this device is sender or receiver.
    @param passcode NSString value represents the passcode using for current Wi-Fi, if it's available.
    @param service NSString value represents the service name use for Bonjour.
    @param connectionType NSString value represents the type of connection(Bonjour, router, hotspot, etc).
    @return CTQRCode object.
 */
- (instancetype)initWithPlattform:(NSString *)platform
                          andSSID:(NSString *)ssid
                    andIPAddreess:(NSString *)ipAddress
                     andSetupType:(NSString *)setupType
                      andPasscode:(NSString *)passcode
                       andService:(NSString *)service
                andConnectionType:(NSString *)connectionType;
/*!
    @brief Create information string for QR code.
    @note QR code information will follow the below order:
 
          @b For @b Cross @b platform: app version#WPA(hard coded)#platform#ssid#IP#passcode#connection type(router, bonjour, etc)#setup type(sender/receiver).
 
          @b For @b iOS @b to @b iOS: app verison#os verison#platform#ssid#IP#passcode#connection type#setup type#service name.
    @return NSString value represents the qrcode information.
 */
- (NSString *)toString;
/*!
    @brief Add QR code in layer. QR code information will use in CTQRCode object.
    @note QR code information will follow the below order:
 
          @b For @b Cross @b platform: app version#WPA(hard coded)#platform#ssid#IP#passcode#connection type(router, bonjour, etc)#setup type(sender/receiver).
 
          @b For @b iOS @b to @b iOS: app verison#os verison#platform#ssid#IP#passcode#connection type#setup type#service name.
    @param layer CALayer to contain the image.
    @return UIImage represents the QRCode.
 */
- (UIImage *)toUIImageFromLayer:(CALayer *)layer;

#pragma mark - Class methods
/*!
    @brief Parse the string read from QRCode.
    @note QR code information will follow the below order:
 
          @b For @b Cross @b platform: app version#WPA#platform#ssid#IP#passcode#connection type#setup type.
 
          @b For @b iOS @b to @b iOS: app verison#os verison#platform#ssid#IP#passcode#connection type#setup type#service name.
    @return NSArray represents all the information read from QR code.
 */
+ (NSArray *)parseQRCodeString:(NSString *)qrString;

@end
