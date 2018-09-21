//
//  VZContentTrasnferConstant.h
//  myverizon
//
//  Created by Tourani, Sanjay on 3/9/16.
//  Copyright © 2016 Verizon Wireless. All rights reserved.
//

#ifndef VZContentTrasnferConstant_h
#define VZContentTrasnferConstant_h


#define CONTENT_TRANSFER_APP_NAME @"ContentTransferApp"
#define CONTENT_TRANSFER_OS_VERSION @"OSVersion"
#define CONTENT_TRANSFER_PHONE_MODEL @"DeviceModel"
#define CONTENT_TRANSFER_DEVICE_UUID @"DeviceUUID"
#define CONTENT_TRANSFER_BEANCON_SCAN_START    @"ContentTransferBeaconScanStart"
#define CONTENT_TRANSFER_BEANCON_SCAN_STOP    @"ContentTransferBeaconScanStop"
#define CONTENT_TRANSFER_BEANCON_SCAN_INPROGRESS    @"ContentTransferBeaconScanInProgress"
#define CONTENT_TRANSFER_CLICKED_SETTING    @"ContentTransferClickedOnSettingButton"
#define CONTENT_TRANSFER_CLICKED_BATTERY    @"ContentTransferClickedOnBatteryButton"
#define CONTENT_TRANSFER_CLICKED_YES    @"ContentTransferClickedOnYesButton"
#define CONTENT_TRANSFER_PHONE_HOME_SCREEN    @"PhoneStartupScreen"
#define CONTENT_TRANSFER_SELECTED_FROM_MENU    @"ContentTransferLunchedFromMenuEvent"
#define CONTENT_TRANSFER_PHONESETUP_SCREEN    @"ContentTransferPhoneSetupScreen"
#define CONTENT_TRANSFER_PHONESELECTION    @"ContentTransferPhoneSelectionScreen"
#define CONTENT_TRANSFER_OLDDDEVICE    @"ContentTransferOldDeviceSelectedEvent"
#define CONTENT_TRANSFER_NEWDDEVICE    @"ContentTransferOldDeviceSelectedEvent"
#define CONTENT_TRANSFER_BONJOUR_LIST    @"ContentTransferBonjourListSelectedEvent"
#define CONTENT_TRANSFER_BONJOUR_SHAKE    @"ContentTransferBonjourShakefeature"
#define CONTENT_TRANSFER_NOTFOUND    @"ContentTransferNotFoundEvent"
#define CONTENT_TRANSFER_WIFISETUP_SCREEN_SENDER    @"ContentTransferWifiSetupScreenSenderPhone"
#define CONTENT_TRANSFER_WIFISETUP_NO_SENDER    @"ContentTransferWifiSetupScreenNoEventPhone"
#define CONTENT_TRANSFER_WIFISETUP_YES_SENDER    @"ContentTransferWifiSetupScreenYesEventPhone"
#define CONTENT_TRANSFER_WIFISETUP_SCREEN_RECEVIER    @"ContentTransferWifiSetupScreenReceiver"
#define CONTENT_TRANSFER_WIFISETUP_NO_RECEVIER    @"ContentTransferWifiSetupScreenNoEventReceiver"
#define CONTENT_TRANSFER_WIFISETUP_YES_RECEVIER    @"ContentTransferWifiSetupScreenYesEventRecevier"
#define CONTENT_TRANSFER_PIN_EVENT    @"ContentTransferPINEnterEvent"
#define CONTENT_TRANSFER_P2P_CONNECT    @"ContentTransferP2PConnectEvent"
#define CONTENT_TRANSFER_CLICKED_CANCEL    @"ContentTransferClcikedOnCancelButton"
#define CONTENT_TRANSFER_CONNECTION_IS_SUCCESSFUL_RECEIVER    @"ContentTransferConnectionIsSuccessfulOnRecevierSide"
#define CONTENT_TRANSFER_ITEMS_SELECTED    @"ContentTransferSelectedItems"
#define CONTENT_TRANSFER_ITEMS_BONJOUR_TRANSFERRED @"ContentTransferItemsTransferredBonjour"
#define CONTENT_TRANSFER_ITEMS_BONJOUR_RECEIVED @"ContentTransferItemsReceivedBonjour"
#define CONTENT_TRANSFER_ITEMS_P2P_TRANSFERRED @"ContentTransferItemsTransferredP2P"
#define CONTENT_TRANSFER_TRANSFER_SCREEN_P2P @"TransferScreenP2P"
#define CONTENT_TRANSFER_TRANSFER_SCREEN_BONJOUR @"TransferScreenBonjour"
#define CONTENT_TRANSFER_ITEMS_P2P_RECEIVED @"ContentTransferItemsReceivedP2P"
#define CONTENT_TRANSFER_FINISH_SCREEN @"ContentTransferFinished"
#define CONTENT_TRANSFER_RECEVIED @"ContentTransfer_all_file_Received"
#define CONTENT_TRANSFER_TRASNFERED @"ContentTransferFinished_all_file_transfer"
#define CONTENT_TRANSFER_EXITAPP @"ExitApplication"
#define CONTENT_TRANSFER_EULA_AGREEMENT @"EulaAgreed"

#define COMM_PORT_NUMBER 8999
#define  REGULAR_PORT 8955

//#define DB_PARING_DEVICE_INFO @"DB_PARING_DEVICE_INFO"
//#define PAIRING_DEVICE_ID @"PAIRING_DEVICE_ID"
//#define PAIRING_MODEL @"PAIRING_MODEL"
//#define PAIRING_OS_VERSION @"PAIRING_OS_VERSION"
//#define PAIRING_DEVICE_TYPE @"PAIRING_DEVICE_TYPE"
//#define PAIRING_TYPE @"PairingType"
//#define VERSION_CHECK @"version_check"



//#define STANDALONE 0 //  1 for standalone and 0 for MVM/MF build


// STORE_BUILD == 1 , all URL will point to PROD
// STORE_BUILD == 0 , all URL will point to DEV

#define PINCODE 255

//#if STANDALONE == 1
//
//#define BUILD_VERSION (NSString *)[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]
//
//#else
//
//#define BUILD_VERSION @"3.2.0"
//
//#endif

// 3(Major).0(Minor).0(Build)
//#define BUILD_VERSION @"2.0.0"
//#define BUILD_CROSS_PLATFROM_MIN_VERSION @"3.2.0" // 3(Major).0(Minor).0(Build)
//#define BUILD_CROSS_PLATFROM_MAX_VERSION @"3.1.0" // 3(Major).0(Minor).0(Build)

// Local Analytics defination
#define TRANSFER_SUCCESS 0
#define TRANSFER_CANCELLED 1
#define TRANSFER_INTERRUPTED 2
#define INSUFFICIENT_STORAGE 3
#define CONNECTION_FAILED 4
#define USER_FORCE_CLOSE 5

//#define DEV_ENV

#endif /* VZContentTrasnferConstant_h */

typedef NS_ENUM(NSInteger,CTAuthorizationStatus){
    
    CTAuthorizationStatusDenied ,
    CTAuthorizationStatusAuthorized,
    CTAuthorizationNotDetermined
};

typedef NS_ENUM(NSInteger,CTTransferStatus){
    
    CTTransferStatus_Success ,
    CTTransferStatus_Cancelled,
    CTTransferStatus_Interrupted,
    CTTransferStatus_Failed,
    CTTransferStatus_Insufficient_Storage,
    CTTransferStatus_Force_Close,
    CTTransferStatus_Battery_Check
};


#ifdef DEBUG
#	define DebugLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#	define DebugLog(...)
#endif


