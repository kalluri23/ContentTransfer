//
//  VZConstants.h
//  contenttransfer
//
//  Created by Mehta, Snehal Natwar on 7/13/16.
//  Copyright © 2016 Hadapad, Prakash. All rights reserved.
//

#ifndef VZConstants_h
#define VZConstants_h

#pragma mark - Framework constants
static NSString *const FRAMEWORK_BUNDLE_IDENTIFIER = @"com.vzw.contentTransfer.framework.bundle";

#pragma mark - Notification constants
static NSString *const NOTIFICATION_NAME_CURRENT_VIEW_CONTROLLER   = @"CurrentViewController";
static NSString *const NOTIFICATION_NAME_ALLPHOTODOWNLOADCOMPLETED = @"ALLPHOTODOWNLOADCOMPLETED";

#pragma mark - Storyboard identifiers
static NSString *const STORYBOARD_WiFiAndP2PStoryboard             = @"WiFiAndP2PStoryboard";
static NSString *const STORYBOARD_BonjourStoryboard                = @"BonjourStoryboard";
static NSString *const STORYBOARD_TransferStoryboard               = @"TransferStoryboard";
static NSString *const STORYBOARD_DevicesStoryboard                = @"DevicesStoryboard";
static NSString *const STORYBOARD_CommonStoryboard                 = @"CommonStoryboard";
static NSString *const STORYBOARD_QRCodeAndScannerStoryboard       = @"QRCodeAndScannerStoryboard";

#pragma mark - Segue identifiers
static NSString *const SEGUE_unwindAndShowLowBatteryScreen         = @"SEGUE_unwindAndShowLowBatteryScreen";
static NSString *const SEGUE_CTPhoneCombinationViewController      = @"CTPhoneCombinationViewController";
static NSString *const SEGUE_UnwindEulaViewController              = @"UnwindEulaViewController";
static NSString *const SEGUE_EulaViewController                    = @"EulaViewController";
static NSString *const SEGUE_CTDeviceSelectionViewController       = @"CTDeviceSelectionViewController";
static NSString *const SEGUE_VZReceiveSegueAnD                     = @"VZReceiveSegueAnD";
static NSString *const SEGUE_showTransfersegueAnD                  = @"showTransfersegueAnD";
static NSString *const SEGUE_receiver_yes_segue_Hotspot            = @"receiver_yes_segue_Hotspot";
static NSString *const SEGUE_sender_yes_segue                      = @"sender_yes_segue";
static NSString *const SEGUE_sender_yes_segue_Hotspot              = @"sender_yes_segue_Hotspot";
static NSString *const SEGUE_ReceiverBonJourCompleted              = @"ReceiverBonJourCompleted";
static NSString *const SEGUE_SenderTransferCompletedBonJour        = @"SenderTransferCompletedBonJour";
static NSString *const SEGUE_receiver_go_to_p2p_segue              = @"receiver_go_to_p2p_segue";
static NSString *const SEGUE_GoToBonjourReceive                    = @"GoToBonjourReceive";
static NSString *const SEGUE_GoToBonjourTransfer                   = @"GoToBonjourTransfer";
static NSString *const SEGUE_goto_next_segue                       = @"goto_next_segue";
static NSString *const SEGUE_wifiSetupRecevier                     = @"wifiSetupRecevier";
static NSString *const SEGUE_wifiSetupSender                       = @"wifiSetupSender";
static NSString *const SEGUE_ReceiverCompleted                     = @"ReceiverCompleted";
static NSString *const SEGUE_receiver_yes_segue                    = @"receiver_yes_segue";
static NSString *const SEGUE_showTransfersegue                     = @"showTransfersegue";
static NSString *const SEGUE_SenderTransferCompleted               = @"SenderTransferCompleted";
static NSString *const SEGUE_VZReceiveSegue                        = @"VZReceiveSegue";
static NSString *const SEGUE_video_err_segue                       = @"video_err_segue";
static NSString *const SEGUE_unwindEverything                      = @"SEGUE_unwindEverything";
static NSString *const SEGUE_unwindWaitingViewController           = @"SEGUE_unwindWaitingViewController";
static NSString *const SEGUE_unwindBonjourFlow                     = @"SEGUE_unwindBonjourFlow";

#pragma mark - UserDefault keys
static NSString *const USER_DEFAULTS_RECEIVERIPADDRESS        = @"RECEIVERIPADDRESS";
static NSString *const USER_DEFAULTS_SOFTACCESSPOINT          = @"SOFTACCESSPOINT";
static NSString *const USER_DEFAULTS_isAndriodPlatform        = @"isAndriodPlatform";
static NSString *const USER_DEFAULTS_PHOTODUPLICATELIST       = @"PHOTODUPLICATELIST";
static NSString *const USER_DEFAULTS_VIDEODUPLICATELIST       = @"VIDEODUPLICATELIST";
static NSString *const USER_DEFAULTS_VCARDDUPLICATELIST       = @"VCARDDUPLICATELIST";
static NSString *const USER_DEFAULTS_CALENDARDUPLICATELIST    = @"CALENDARDUPLICATELIST";
static NSString *const USER_DEFAULTS_TOTALFILESRECEIVED       = @"TOTALFILESRECEIVED";
static NSString *const USER_DEFAULTS_photoFilteredFileList    = @"photoFilteredFileList";
static NSString *const USER_DEFAULTS_videoFilteredFileList    = @"videoFilteredFileList";
static NSString *const USER_DEFAULTS_itemList                 = @"itemList";
static NSString *const USER_DEFAULTS_TOTALFILETRANSFERED      = @"TOTALFILETRANSFERED";
static NSString *const USER_DEFAULTS_REMINDERDUPLICATELIST    = @"REMINDERDUPLICATELIST";
static NSString *const USER_DEFAULTS_VIDEOALBUMLIST           = @"VIDEOALBUMLIST";
static NSString *const USER_DEFAULTS_PHOTOALBUMLIST           = @"PHOTOALBUMLIST";
static NSString *const USER_DEFAULTS_photoFileList            = @"photoFileList";
static NSString *const USER_DEFAULTS_videoFileList            = @"videoFileList";
static NSString *const USER_DEFAULTS_STARTTIME                = @"STARTTIME";
static NSString *const USER_DEFAULTS_ENDTIME                  = @"ENDTIME";
static NSString *const USER_DEFAULTS_TOTALDOWNLOADEDDATA      = @"TOTALDOWNLOADEDDATA";
static NSString *const USER_DEFAULTS_TOTALNUMBEROFCONTACT     = @"TOTALNUMBEROFCONTACT";
static NSString *const USER_DEFAULTS_CONTACTTOTALSIZE         = @"CONTACTTOTALSIZE";
static NSString *const USER_DEFAULTS_REMINDERLOGSIZE          = @"REMINDERLOGSIZE";
static NSString *const USER_DEFAULTS_isAndriodPlatfclearxvorm = @"isAndriodPlatfclearxvorm";
static NSString *const USER_DEFAULTS_calFileList              = @"calFileList";
static NSString *const USER_DEFAULTS_batteryAlertSent         = @"batteryAlertSent";
static NSString *const USER_DEFAULTS_CONTACTSIMPORTED         = @"CONTACTSIMPORTED";
static NSString *const USER_DEFAULTS_GLOBALUUID               = @"globalUUID";
static NSString *const USER_DEFAULTS_DeviceUUID               = @"DeviceUUID";
static NSString *const USER_DEFAULTS_LOCALANALYTICS           = @"LOCALANALYTICS";
static NSString *const USER_DEFAULTS_DeviceType               = @"DeviceType";
static NSString *const USER_DEFAULTS_isIamIOS                 = @"isIamIOS";
static NSString *const USER_DEFAULTS_EULA_AGREEMENT           = @"EulaAgreed";
static NSString *const USER_DEFAULTS_PAIRING_DEVICE_ID        = @"PAIRING_DEVICE_ID";
static NSString *const USER_DEFAULTS_PAIRING_MODEL            = @"PAIRING_MODEL";
static NSString *const USER_DEFAULTS_PAIRING_OS_VERSION       = @"PAIRING_OS_VERSION";
static NSString *const USER_DEFAULTS_PAIRING_DEVICE_TYPE      = @"PAIRING_DEVICE_TYPE";
static NSString *const USER_DEFAULTS_PAIRING_TYPE             = @"PairingType";
static NSString *const USER_DEFAULTS_DEVICE_COUNT             = @"DeviceCount";
static NSString *const USER_DEFAULTS_VERSION_CHECK            = @"version_check";
static NSString *const USER_DEFAULTS_DB_PARING_DEVICE_INFO    = @"DB_PARING_DEVICE_INFO";
static NSString *const USER_DEFAULTS_CALENDAR_HASH_KEY        = @"CalendarHashKey";
static NSString *const USER_DEFAULTS_SIZE_OF_DATA_TO_TRANSFER = @"SIZE_OF_DATA_TO_TRANSFER";
static NSString *const USER_DEFAULTS_PHONE_COMBINATION        = @"PHONE_COMBINATION";
static NSString *const USER_DEFAULTS_LAST_TRANSFER_SETTING    = @"LAST_TRANSFER_SETTING";
static NSString *const USER_DEFAULTS_TEMP_PHOTO_FOLDER        = @"USER_DEFAULTS_TEMP_PHOTO_FOLDER";
static NSString *const USER_DEFAULTS_TEMP_LIVEPHOTO_FOLDER    = @"USER_DEFAULTS_TEMP_LIVEPHOTO_FOLDER";
static NSString *const USER_DEFAULTS_TEMP_VIDEO_FOLDER        = @"USER_DEFAULTS_TEMP_VIDEO_FOLDER";
static NSString *const USER_DEFAULTS_TEMP_PHOTO_LIST          = @"TEMP_PHOTO_LIST";
static NSString *const USER_DEFAULTS_TEMP_VIDEO_LIST          = @"TEMP_VIDEO_LIST";
static NSString *const USER_DEFAULTS_RECEIVE_FLAGS            = @"RECEIVE_FLAGS";
static NSString *const USER_DEFAULTS_NUMBER_OF_PHOTOS         = @"NUMBER_OF_PHOTOS";
static NSString *const USER_DEFAULTS_NUMBER_OF_VIDEOS         = @"NUMBER_OF_VIDEOS";
static NSString *const USER_DEFAULTS_IS_CANCEL                = @"IS_CANCEL";
static NSString *const USER_DEFAULTS_CONNECTED_NETWORK_NAME   = @"CONNECTED_NETWORK_NAME";
static NSString *const USER_DEFAULTS_TRANSFER_STATUS          = @"USER_DEFAULTS_TRANSFER_STATUS";
static NSString *const USER_DEFAULTS_PHONE_NUMBER             = @"phoneNumber";
static NSString *const USER_DEFAULTS_DEVICE_VID               = @"USER_DEFAULTS_DEVICE_VID";
static NSString *const USER_DEFAULTS_SCAN_TYPE                = @"USER_DEFAULTS_SCAN_TYPE";
static NSString *const USER_DEFAULTS_TRANSFER_FINISHED        = @"USER_DEFAULTS_TRANSFER_FINISHED";
static NSString *const USER_DEFAULTS_VCARD_PERMISSION_ERR     = @"VCARD_PERMISSION_ERR";
static NSString *const USER_DEFAULTS_PHOTO_PERMISSION_ERR     = @"PHOTO_PERMISSION_ERR ";
static NSString *const USER_DEFAULTS_CALENDAR_PERMISSION_ERR  = @"CALENDAR_PERMISSION_ERR";
static NSString *const USER_DEFAULTS_REMINDER_PERMISSION_ERR  = @"REMINDER_PERMISSION_ERR";
static NSString *const USER_DEFAULTS_AUDIO_PERMISSION_ERR     = @"AUDIO_PERMISSION_ERR";
static NSString *const USER_DEFAULTS_CAMERA_PERMISSION_ERR    = @"CAMERA_PERMISSION_ERR";
static NSString *const USER_DEFAULTS_TOTAL_PAYLOAD            = @"USER_DEFAULTS_TOTAL_PAYLOAD";
static NSString *const USER_DEFAULTS_ERROR_LIVE_PHOTO         = @"USER_DEFAULTS_ERROR_LIVE_PHOTO";

static NSString *const TOTAL_FREE_SPACE_AVAILABLE             = @"Total_Space_Avaialbe";
static NSString *const MAX_SPACE_AVAILABLE_FOR_TRANSFER       = @"max_space_available_for_transfer";
static NSString *const TRANSFER_STATUS                        = @"TRANSFER_STATUS";

#pragma mark - Other constants
static NSString *const kGenericString_TRUE                    = @"TRUE";
static NSString *const kGenericString_NO                      = @"NO";
static NSString *const kGenericString_YES                     = @"YES";
static NSString *const kDefaultAppTitle                       = @"Content Transfer";
static NSString *const kBatteryAlertSent                      = @"batteryAlertSent";

/*! Transfer use GCDSocket. This can be used either in iOS to iOS or cross platform.*/
static NSString *const kP2P                                   = @"P2P";
/*! One to many transfer.*/
static NSString *const kP2M                                   = @"P2M";
/*! Transfer use Bonjour service for iOS to iOS.*/
static NSString *const kBonjour                               = @"Bonjour";
/*! Transfer type not decided yet. Empty string value will be returned.*/
static NSString *const kNotDecided                            = @"";

static NSString *const kOneToMany                             = @"many";
static NSString *const kOneToOne                              = @"one";

/*! Content transfer app global alert header.*/
static NSString *const CTAlertGeneralTitle                    = @"Content Transfer";
/*! Content transfer app global alert OK button title.*/
static NSString *const CTAlertGeneralOKTitle                  = @"OK";
/*! Content transfer app global alert cancel button title.*/
static NSString *const CTAlertGeneralCancelTitle              = @"Cancel";
/*! Content transfer app global alert continue button title.*/
static NSString *const CTAlertGeneralContinueTitle            = @"Continue";
/*! Content transfer app global alert ignore button title.*/
static NSString *const CTAlertGeneralIgnoreTitle              = @"Ignore";

/*! Title for information button on select what page.*/
static NSString *const kMoreInfoButtonTitle                   = @"More Info";

#pragma mark - Adobe config constant (Deprecated)
static NSString *const PATH_ADB_MOBILE_CONFIG                      = @"ADBMobileConfig_Test";

#endif /* VZConstants_h */
