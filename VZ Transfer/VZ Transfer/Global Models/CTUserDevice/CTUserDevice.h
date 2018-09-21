//
//  CTUserDevice.h
//  contenttransfer
//
//  Created by Development on 8/11/16.
//  Copyright © 2016 Verizon. All rights reserved.
//

#import "CTUserDefaults.h"
#import <Foundation/Foundation.h>
#import "CTContentTransferConstant.h"

/*!
    @brief      This class will collect all the necessary information about device and save them;
    @discussion This class is a singlton class.
    @code [CTUserDevice userDevice];@endcode
                Saving detail will last until manually remove or delete the app. So need to reset at proper place.
 */
@interface CTUserDevice : NSObject
/*! IP address on receiver side.*/
@property (nonatomic, strong) NSString *receiverIPAddress;
/*! Access point name.*/
@property (nonatomic, strong) NSString *softAccessPoint;
/*! Indicate that this is cross platform transfer or not. Valid value will be "TRUE" or "FALSE" as String.*/
@property (nonatomic, strong) NSString *isAndroidPlatform;
/*! DeviceType, available values: @"NewDevice" or @"OldDevice"*/
@property (nonatomic, strong) NSString *deviceType;
/*!@b Deprecated.*/
@property (nonatomic, strong) NSString *isIamIOS;
/*! Global UDID, only generate once per installation.*/
@property (nonatomic, strong) NSString *globalUDID;
/*! UUID of current device. Note: This value will be reset everytime user restart transfer.*/
@property (nonatomic, strong) NSString *deviceUDID;
/*! Combination of devices. Avaliable value: iOSToiOS or iOSToAndriod.*/
@property (nonatomic, strong) NSString *phoneCombination;
/*! Device Setting for last traction.*/
@property (nonatomic, strong) NSString *lastTransferSetting;
/*! Detect pairing type is P2P or Bonjour or one to many.*/
@property (nonatomic, strong) NSString *pairingType;
/*! Network name connected.*/
@property (nonatomic, strong) NSString *connectedNetworkName;
/*! Avaiable space left on device.*/
@property (nonatomic, strong) NSString *freeSpaceAvaiable;
/*! Max available space for transfer.*/
@property (nonatomic, strong) NSString *maxSpaceAvaiableForTransfer;
/*! Record the status of current transfer*/
@property (nonatomic, assign) NSInteger transferStatus;
/*! MDN for user's device.*/
@property (nonatomic, assign) NSString *userMDN;
/*! 
    @brief To identify this is one-to-one or one-to-many.
    @discussion Possbile values:
                0 - One to One logic
                
                x - One to Many logic. x represent how many devices connected to the sender side. Receivers inside one group will have same x value.
    @warning x will be greater than 0 and less or equal to 7
 */
@property (nonatomic, assign) NSInteger deviceCount;


/*!
 @brief  Singlton method for CTUserDevice;
 @return A singlton object that save current device information.
 */
+ (instancetype)userDevice;

@end
