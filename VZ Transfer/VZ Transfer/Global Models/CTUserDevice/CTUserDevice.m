//
//  CTUserDevice.m
//  contenttransfer
//
//  Created by Development on 8/11/16.
//  Copyright © 2016 Verizon. All rights reserved.
//

#import "CTUserDevice.h"

@interface CTUserDevice ()

@property (nonatomic, strong, readwrite) NSUserDefaults *userDefaults;

@end

@implementation CTUserDevice

+ (instancetype)userDevice {

    static CTUserDevice *userDevice = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        userDevice = [[CTUserDevice alloc] init];
    });

    return userDevice;
}

- (instancetype)init {
    self = [super init];

    if (self) {
        self.userDefaults = [NSUserDefaults standardUserDefaults];
    }

    return self;
}

// USER_DEFAULTS_RECEIVERIPADDRESS
- (void)setReceiverIPAddress:(NSString *)receiverIPAddress {
    [self.userDefaults setObject:receiverIPAddress forKey:USER_DEFAULTS_RECEIVERIPADDRESS];
}

- (NSString *)receiverIPAddress {
    return [self.userDefaults objectForKey:USER_DEFAULTS_RECEIVERIPADDRESS];
}

// USER_DEFAULTS_SOFTACCESSPOINT
- (void)setSoftAccessPoint:(NSString *)softAccessPoint {
    [self.userDefaults setObject:softAccessPoint forKey:USER_DEFAULTS_SOFTACCESSPOINT];
}

- (NSString *)softAccessPoint {
    return [self.userDefaults objectForKey:USER_DEFAULTS_SOFTACCESSPOINT];
}

// USER_DEFAULTS_isAndriodPlatform
- (void)setIsAndroidPlatform:(NSString *)isAndroidPlatform {
    [self.userDefaults setObject:isAndroidPlatform forKey:USER_DEFAULTS_isAndriodPlatform];
}

- (NSString *)isAndroidPlatform {
    return [self.userDefaults objectForKey:USER_DEFAULTS_isAndriodPlatform];
}


// USER_DEFAULTS_DeviceType
- (void)setDeviceType:(NSString *)deviceType {
    [self.userDefaults setObject:deviceType forKey:USER_DEFAULTS_DeviceType];
}

- (NSString *)deviceType {
    return [self.userDefaults objectForKey:USER_DEFAULTS_DeviceType];
}

// USER_DEFAULTS_isIamIOS
- (void)setIsIamIOS:(NSString *)isIamIOS {
    [self.userDefaults setObject:isIamIOS forKey:USER_DEFAULTS_isIamIOS];
}

- (NSString *)isIamIOS {
    return [self.userDefaults objectForKey:USER_DEFAULTS_isIamIOS];
}

// USER_DEFAULTS_DeviceUUID
- (void)setDeviceUDID:(NSString *)deviceUDID {
    [self.userDefaults setObject:deviceUDID forKey:USER_DEFAULTS_DeviceUUID];
}

- (NSString *)deviceUDID {
    return [self.userDefaults objectForKey:USER_DEFAULTS_DeviceUUID];
}

// USER_DEFAULTS_GLOBALUUID
- (void)setGlobalUDID:(NSString *)globalUDID {
    if (!self.globalUDID) { // If there is no global UUID, then save.
        [self.userDefaults setObject:globalUDID forKey:USER_DEFAULTS_GLOBALUUID];
    }
    // Otherwise, ignore.
}

- (NSString *)globalUDID {
    return [self.userDefaults objectForKey:USER_DEFAULTS_GLOBALUUID];
}

// USER_DEFAULTS_Phone_Combination
- (void)setPhoneCombination:(NSString *)phoneCombination {
    
    [self.userDefaults setObject:phoneCombination forKey:USER_DEFAULTS_PHONE_COMBINATION];
}

- (NSString *)phoneCombination {
    
    return [self.userDefaults objectForKey:USER_DEFAULTS_PHONE_COMBINATION];
}

- (void)setLastTransferSetting:(NSString *)lastTransferSetting {
    [self.userDefaults setObject:lastTransferSetting forKey:USER_DEFAULTS_LAST_TRANSFER_SETTING];
}

- (NSString *)lastTransferSetting {
    return [self.userDefaults objectForKey:USER_DEFAULTS_LAST_TRANSFER_SETTING];
}

- (void)setPairingType:(NSString *)pairingType {
    [self.userDefaults setObject:pairingType forKey:USER_DEFAULTS_PAIRING_TYPE];
}

-(NSString *)pairingType {
    return [self.userDefaults objectForKey:USER_DEFAULTS_PAIRING_TYPE];
}

- (void)setConnectedNetworkName:(NSString *)connectedNetworkName {
    [self.userDefaults setObject:connectedNetworkName forKey:USER_DEFAULTS_CONNECTED_NETWORK_NAME];
}

-(NSString *)connectedNetworkName {
    return [self.userDefaults objectForKey:USER_DEFAULTS_CONNECTED_NETWORK_NAME];
}


- (void)setFreeSpaceAvaiable:(NSString *)freeSpaceAvaiable {
    [self.userDefaults setObject:freeSpaceAvaiable forKey:TOTAL_FREE_SPACE_AVAILABLE];
}

-(NSString *)freeSpaceAvaiable {
    return [self.userDefaults objectForKey:TOTAL_FREE_SPACE_AVAILABLE];
}

- (void)setMaxSpaceAvaiableForTransfer:(NSString *)maxSpaceAvaiableForTransfer {
    [self.userDefaults setObject:maxSpaceAvaiableForTransfer forKey:MAX_SPACE_AVAILABLE_FOR_TRANSFER];
}

-(NSString *)maxSpaceAvaiableForTransfer {
    return [self.userDefaults objectForKey:MAX_SPACE_AVAILABLE_FOR_TRANSFER];
}

- (void)setTransferStatus:(NSInteger)transferStatus {
    [self.userDefaults setObject:[NSNumber numberWithInteger:transferStatus] forKey:USER_DEFAULTS_TRANSFER_STATUS];
}

-(NSInteger)transferStatus {
    return [[self.userDefaults objectForKey:USER_DEFAULTS_TRANSFER_STATUS] integerValue];
}

-(NSString*)userMDN{
    return [self.userDefaults objectForKey:USER_DEFAULTS_PHONE_NUMBER];
}

-(void) setUserMDN:(NSString *)userMDN{
    [self.userDefaults setObject:userMDN forKey:USER_DEFAULTS_PHONE_NUMBER];
}

- (void)setDeviceCount:(NSInteger)deviceCount {
    [self.userDefaults setObject:[NSString stringWithFormat:@"%ld", (long)deviceCount] forKey:USER_DEFAULTS_DEVICE_COUNT];
}

- (NSInteger)deviceCount {
    if (![self.userDefaults objectForKey:USER_DEFAULTS_DEVICE_COUNT]) {
        [self setDeviceCount:0]; // One to one will be the default value
    }
    
    return [[self.userDefaults objectForKey:USER_DEFAULTS_DEVICE_COUNT] integerValue];
}

@end
