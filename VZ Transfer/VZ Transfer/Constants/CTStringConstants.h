//
//  CTStringConstants.h
//  contenttransfer
//
//  Created by Hadapad, Prakash on 9/6/16.
//  Copyright © 2016 Hadapad, Prakash. All rights reserved.
//

#ifndef CTStringConstants_h
#define CTStringConstants_h

#pragma mark - Screen string constants
static NSString *const ALERT_TITLE_PLUG_IN_AND_CHARGE_UP = @"Plug in and charge up.";
static NSString *const ALERT_MESSAGE_BATTERY_WARNING_MESSAGE = @"Don’t run out of battery in the middle of your transfer. You’re better off charging up to be safe.";
static NSString *const BUTTON_TITLE_GOT_IT = @"Got it";
static NSString *const BUTTON_TITLE_RECAP = @"Recap";
static NSString *const BUTTON_TITLE_TRY_AGAIN = @"Try again";
static NSString *const ALERT_MESSAGE_PLEASE_TURN_OFF_BLUETOOTH_AND_ON_WIFI = @"Please turn off bluetooth & turn on Wifi";
static NSString *const ALERT_MESSAGE_PLEASE_TURN_ON_WIFI = @"\nPlease turn on Wifi";
static NSString *const ALERT_MESSAGE_PLEASE_TURN_OFF_BLUETOOTH = @"\nPlease turn off Bluetooth";
static NSString *const ALERT_MESSAGE_THIS_APP_REQUIRES_PERMISSION_TO_ACCESS = @"This app requires permission to access";

/*! Old device(sender).*/
static NSString *const OLD_DEVICE  = @"OldDevice";
/*! New device(receiver).*/
static NSString *const NEW_DEVICE  = @"NewDevice";
/*! iOS to iOS.*/
static NSString *const IOS_IOS     = @"iOSToiOS";
/*! Cross platform.*/
static NSString *const IOS_Andriod = @"iOSToAndriod";

// Scan type constants
static NSString *const CTScanQR     = @"QR";
static NSString *const CTScanManual = @"Manual";

// Enter Pin Receiver
static NSString *const ALERT_TITLE_VERSION_MISMATCH = @"Version Mismatch";
static NSString *const NOT_CONNECTED_WIFI_ACCESS_POINT = @"Not connected";

static NSString *const kAppStoreURL       = @"itms-apps://itunes.apple.com/us/app/content-transf/id1127930385?mt=8";
static NSString *const kCloudAppStoreURL  = @"itms-apps://itunes.apple.com/us/app/verizon-cloud/id645682444?mt=8";
static NSString *const kAppStoreReviewURL = @"itms-apps://itunes.apple.com/us/app/content-transf/id1127930385?mt=8&action=write-review";
static NSString *const kSurveyURL = @"https://www.surveymonkey.com/r/66W8HF7";

#pragma mark - Metadata string constants
/*! Metadata file list key value*/
static NSString *const METADATA_DICT_KEY_CALENDAR = @"calendarFileList";
/*! Metadata file list key value*/
static NSString *const METADATA_DICT_KEY_PHOTOS = @"photoFileList";
/*! Metadata file list key value*/
static NSString *const METADATA_DICT_KEY_VIDEOS = @"videoFileList";
/*! Metadata file list key value*/
static NSString *const METADATA_DICT_KEY_AUDIOS = @"musicFileList";

/*! Item list key value*/
static NSString *const METADATA_ITEMLIST_KEY_CONTACTS = @"contacts";
/*! Item list key value*/
static NSString *const METADATA_ITEMLIST_KEY_PHOTOS = @"photos";
/*! Item list key value*/
static NSString *const METADATA_ITEMLIST_KEY_VIDEOS = @"videos";
/*! Item list key value*/
static NSString *const METADATA_ITEMLIST_KEY_CALENDARS = @"calendar";
/*! Item list key value*/
static NSString *const METADATA_ITEMLIST_KEY_REMINDERS = @"reminder";
/*! Item list key value*/
static NSString *const METADATA_ITEMLIST_KEY_AUDIOS = @"musics";

#pragma mark - ALL THE SEND HEADER STATIC STRING
static NSString *const CT_SEND_FILE_HOST_HEADER        = @"VZCONTENTTRANSFERALLFLHOST";
/*! File list transfer start header.*/
static NSString *const CT_SEND_FILE_LIST_HEADER        = @"VZCONTENTTRANSFERALLFLSTART";
/*! Contact vcf file transfer start header.*/
static NSString *const CT_SEND_FILE_CONTACTS_HEADER        = @"VZCONTENTTRANSFERVCARDSTART";
static NSString *const CT_SEND_FILE_CALENDARS_HEADER       = @"VZCONTENTTRANSFERCALENSTART";
static NSString *const CT_SEND_FILE_REMINDERS_HEADER       = @"VZCONTENTTRANSFERREMINDERLO";
static NSString *const CT_SEND_FILE_PHOTO_HEADER           = @"VZCONTENTTRANSFERPHOTOSTART";
static NSString *const CT_SEND_FILE_LIVEPHOTO_IMAGE_HEADER = @"VZCONTENTTRANSFERLIVEPSTART";
static NSString *const CT_SEND_FILE_LIVEPHOTO_VIDEO_HEADER = @"VZCONTENTTRANSFERLIVEVSTART";
static NSString *const CT_SEND_FILE_VIDEO_HEADER           = @"VZCONTENTTRANSFERVIDEOSTART";
static NSString *const CT_SEND_FILE_APP_HEADER             = @"VZCONTENTTRANSFERAPPLSSTART";
static NSString *const CT_SEND_FILE_AUDIO_HEADER           = @"VZCONTENTTRANSFERMUSICSTART";
static NSString *const CT_SEND_FILE_DUPLICATE_RECEIVED     = @"VZTRANSFER_DUPLICATE_RECEIVED";

#pragma mark - ALL TRANSFER ERROR HEADER
// All error header will come with 10 digit size which need to be updated through progress bar.
/*! Transfer failure header key.*/
static NSString *const CT_SEND_FILE_FAILURE                             = @"VZCONTENTTRANSFERMEDIAERROR";

#pragma mark - ALL THE REQUEST HEADER STATIC STRING
static NSString *const CT_REQUEST_FILE_CONTACT_HEADER                   = @"VZCONTENTTRANSFER_REQUEST_FOR_VCARD";
static NSString *const CT_REQUEST_FILE_CALENDARS_HEADER                 = @"VZCONTENTTRANSFER_REQUEST_FOR_CALENDAR_";
static NSString *const CT_REQUEST_FILE_CALENDARS_FINAL_HEADER           = @"VZCONTENTTRANSFER_FINAL_REQUEST_FOR_CALENDAR_";
static NSString *const CT_REQUEST_FILE_CALENDARS_START_HEADER           = @"VZCONTENTTRANSFER_START_REQUEST_FOR_CALENDAR_";
static NSString *const CT_REQUEST_FILE_CALENDARS_ORIGIN_HEADER          = @"VZCONTENTTRANSFER_ORIGI_REQUEST_FOR_CALENDAR_";
static NSString *const CT_REQUEST_FILE_REMINDER_HEADER                  = @"VZCONTENTTRANSFER_REQUEST_FOR_REMIN";
static NSString *const CT_REQUEST_FILE_PHOTO_HEADER                     = @"VZCONTENTTRANSFER_REQUEST_FOR_PHOTO_";
static NSString *const CT_REQUEST_FILE_LIVEPHOTO_HEADER                 = @"VZCONTENTTRANSFER_REQUEST_FOR_LIVEPHOTO_";
static NSString *const CT_REQUEST_FILE_LIVEPHOTO_VIDEO_HEADER           = @"VZCONTENTTRANSFER_LIVEPHOTO_FOR_VIDEO_RESOURCE";
static NSString *const CT_REQUEST_FILE_RECONNECT_PHOTO_HEADER           = @"VZCONTENTTRANSFER_RECONNECT_FOR_PHOTO_";
static NSString *const CT_REQUEST_FILE_RECONNECT_LIVEPHOTO_PHEADER      = @"VZCONTENTTRANSFER_RECONNECT_FOR_LIVEPHOTO_";
static NSString *const CT_REQUEST_FILE_RECONNECT_LIVEPHOTO_VHEADER      = @"VZCONTENTTRANSFER_RECONNECT_LIVEPHOTO_FOR_VIDEO_RESOURCE";
static NSString *const CT_REQUEST_FILE_RECONNECT_PHOTO_DUPLICATE_HEADER = @"VZCONTENTTRANSFER_RECONNECT_FOR_PHOTODUPLICATE_";
static NSString *const CT_REQUEST_FILE_PHOTO_DUPLICATE_HEADER           = @"VZCONTENTTRANSFER_REQUEST_FOR_PHOTO_RFVQTElDQVRF";
static NSString *const CT_REQUEST_FILE_VIDEO_HEADER                     = @"VZCONTENTTRANSFER_REQUEST_FOR_VIDEO_";
static NSString *const CT_REQUEST_FILE_VIDEO_DUPLICATE_HEADER           = @"VZCONTENTTRANSFER_REQUEST_FOR_VIDEO_RFVQTElDQVRF";
static NSString *const CT_REQUEST_FILE_NEXT_VIDEO_PART_HEADER           = @"VZCONTENTTRANSFER_REQUEST_FOR_VPART_";
static NSString *const CT_REQUEST_FILE_RECONNECT_VIDEO_HEADER           = @"VZCONTENTTRANSFER_RECONNECT_FOR_VIDEO_";
static NSString *const CT_REQUEST_FILE_RECONNECT_VIDEO_DUPLICATE_HEADER = @"VZCONTENTTRANSFER_RECONNECT_FOR_VIDEODUPLICATE_";
static NSString *const CT_REQUEST_FILE_AUDIO_HEADER                     = @"VZCONTENTTRANSFER_REQUEST_FOR_MUSIC_";
static NSString *const CT_REQUEST_FILE_AUDIO_DUPLICATE_HEADER           = @"VZCONTENTTRANSFER_REQUEST_FOR_MUSIC_RFVQTElDQVRF";
static NSString *const CT_REQUEST_FILE_COMPLETED                        = @"VZCONTENTTRANSFER_FINISHED";
static NSString *const CT_REQUEST_FILE_NOT_ENOUGH_STORAGE               = @"VZTRANSFER_NOT_ENOUGH_STORAGE";
static NSString *const CT_REQUEST_FILE_DUPLICATE_END                    = @"VZCONTENTTRANSFER_REQUEST_DUPLICATE_END"; // Deprecated
static NSString *const CT_REQUEST_FILE_CANCEL                           = @"VZTRANSFER_CANCEL";
static NSString *const CT_REQUEST_FILE_CANCEL_PERMISSION                = @"VZTRANSFER_CANCEL_PERMISSION";
static NSString *const CT_REQUEST_FILE_CANCEL_CLICKED                   = @"Cancel Clicked";
static NSString *const CT_REQUEST_DUPLICATE_ENCODED                     = @"RFVQTElDQVRF";
static NSString *const CT_REQUEST_DUPLICATE_KEY                         = @"DUPLICATE_";

#pragma mark - Error Massages
static NSString *const CT_USER_INTERRUPTED_TITLE = @"Oops. Looks like your transfer was interrupted.";
static NSString *const CT_USER_INTERRUPTED_TEXT  = @"Your transfer didn't finish. Review the transfer recap or try again.";
static NSString *const CT_NO_STORAGE_TITLE       = @"Your new phone is crowded.";
static NSString *const CT_NO_STORAGE_TEXT        = @"Not enough free space on your new device. Select less files and try again.";

#pragma mark - Notifications
static NSString *const CT_NOTIFICATION_EXIT_CONTENT_TRANSFER = @"ExitCT";
static NSString *const APP_USERDEFAULT_ITUNE_REVIEW_KEY      = @"APP_USERDEFAULT_ITUNE_REVIEW_KEY";

#pragma mark - Review app
static NSString *const CT_APP_REVIEW_ALERT_TITLE     = @"Rate Content Transfer";
static NSString *const CT_APP_REVIEW_ALERT_CONTEXT   = @"If you enjoy using Content Transfer app, would you like to take a moment to rate it? It won't take more than a minute. Thanks for your support!";
static NSString *const CT_APP_REVIEW_ALERT_NO_THANKS = @"No, Thanks";
static NSString *const CT_APP_REVIEW_ALERT_NOT_NOW   = @"Not now";
static NSString *const CT_APP_REVIEW_ALERT_RATE_APP  = @"Rate App";

#pragma mark - Quit application
static NSString *const CT_APP_QUIT_ALERT_CONTEXT     = @"Are you sure you want to quit? Data will not be saved.";

#pragma mark - Alert & normal buttons string constants
static NSString *const CT_YES_ALERT_BUTTON_TITLE = @"Yes";
static NSString *const CT_NO_ALERT_BUTTON_TITLE = @"No";
static NSString *const CT_OK_ALERT_BUTTON_TITLE = @"Ok";
static NSString *const CT_DELETE_ALERT_BUTTON_TITLE = @"Delete";
static NSString *const CT_SAVE_ALERT_BUTTON_TITLE = @"Save";
static NSString *const CT_DECLINE_ALERT_BUTTON_TITLE = @"Decline";
static NSString *const CT_GRANT_ACCESS_ALERT_BUTTON_TITLE = @"Grant Access";
static NSString *const CT_CONFIRM_ALERT_BUTTON_TITLE = @"Confirm";
static NSString *const CT_SETTINGS_BUTTON_TITLE = @"Settings";
static NSString *const CT_WIFI_BUTTON_TITLE = @"Wi-Fi Settings";
static NSString *const CT_GO_TO_SETTING_BUTTON_TITLE = @"Go to setting";
static NSString *const CT_TURN_ON_BUTTON_TITLE = @"Turn on";
static NSString *const CT_TURN_OFF_BUTTON_TITLE = @"Turn off";
static NSString *const CT_BT_SETTINGS_BUTTON_TITLE = @"Bluetooth Settings";
static NSString *const CT_UPGRADE_BUTTON_TITLE = @"Upgrade";
static NSString *const CT_DISMISS_BUTTON_TITLE = @"Dismiss";
static NSString *const CT_NEXT_BUTTON_TITLE = @"Next";

#pragma mark - Alert title
static NSString *const kConnectingDialogContext = @"Connecting. Please wait..";

//Get started screen

static NSString *const CT_GET_STARTED_NAV_TITLE   = @"Phone-to-Phone Transfer";

static NSString *const CT_GET_STRATED_PRIMARY_MESSGE = @"Open Content Transfer and make sure both phones are on this screen. Follow the instructions in sync, so each device is on the same step.";

static NSString *const CT_GET_STARTED_INFO_ALERT_CONTEXT = @"Build Version: %@\n Date: %@";

static NSString *const CT_SAVING_DATA = @"Preparing to save unsaved data...";

static NSString *const CT_DELETE_DATA = @"Preparing to delete unsaved data...";

static NSString *const CT_DETECTED_UNSAVED_DATA_ALERT_CONTEXT = @"Detected unsaved contents from the last transaction. Do you want to save them?";

static NSString *const CT_CONTACTS = @"Contacts";

/*Photos count*/
static NSString *const CT_PHOTOS = @"Photos";

/*Videos count*/
static NSString *const CT_VIDEOS = @"Videos";

/*Remainders count*/
static NSString *const CT_REMINDERS = @"Reminders";

/*Calenders count*/
static NSString *const CT_CALENDERS = @"Calendars";

/*Apps List*/
static NSString *const CT_APPS_LIST = @"Apps List";

/*Deleted Contacts count*/
static NSString *const CT_DELETED_CONTACTS_MESSAGE = @"Deleted contacts";

/*Deleted reminders info message*/
static NSString *const CT_DELETED_REMINDERS_MESSAGE = @"Deleted reminders";

/*Deleted Calenders info message*/
static NSString *const CT_DELETED_CALANDERS_MESSAGE = @"Deleted calendars";

/*Deleted Photos info message*/
static NSString *const CT_DELETED_PHOTOS_MESSAGE = @"Deleted photos";

/*Delete videos question*/
static NSString *const CT_DELETE_VIDEOS = @"Delete videos";

/*Delete apps list*/
static NSString *const CT_DELETE_APPS_LIST = @"Delete apps list...";

/*Saving contacts*/
static NSString *const CT_SAVING_CONTACTS = @"Saving contacts";

/*Saving reminders*/
static NSString *const CT_SAVING_REMINDERS = @"Saving reminders";

/*Saving Calenders*/
static NSString *const CT_SAVING_CALENDERS = @"Saving calendars";

/*Saving Photos*/
static NSString *const CT_SAVING_PHOTOS = @"Saving photos";

/*Saving Videos*/
static NSString *const CT_SAVING_VIDEOS = @"Saving videos";

//Device selection screen
static NSString *const CT_DEVICES_STORYBOARD_NAV_TITLE = @"Setup";
static NSString *const CT_CONTACTS_STRING = @"contacts";
static NSString *const CT_FILE_LIST_STRING = @"file list";
static NSString *const CT_APPS_STRING = @"apps";
static NSString *const CT_PHOTOS_STRING = @"photos";
static NSString *const CT_VIDEOS_STRING = @"videos";
static NSString *const CT_CALANDERS_STRING = @"calendars";
static NSString *const CT_REMINDERS_STRING = @"reminders";
static NSString *const CT_MUSIC_STRING = @"music";
static NSString *const CT_CAMERA_STRING = @"camera";
static NSString *const CT_AND = @"and";
static NSString *const CT_APP_PERMISSION_ALERT_CONTEXT = @"This app requires permission to access %@. Grant access by modifying settings->Privacy";
static NSString *const CT_APP_ACCESS_ALERT_CONTEXT = @"This app requires permission to access %@. Click on Grant Access to turn on this permission";
static NSString *const CT_OLD_PHONE_PRIM_TEXT = @"This is my old phone";
static NSString *const CT_OLD_PHONE_SEC_TEXT = @"I'll be transferring things from this phone.";
static NSString *const CT_NEW_PHONE_PRIM_TEXT = @"This is my new phone";
static NSString *const CT_NEW_PHONE_SEC_TEXT = @"I'll be transferring things to this phone.";
static NSString *const CT_FEATURE_NOT_ALLOWED_ALERT_CONTEXT = @"This feature is not allowed for this device.";

//Phone combination screen
static NSString *const CT_IPHONE_TO_IPHONE = @"iPhone to iPhone";
static NSString *const CT_IPHONE_TO_OTHER = @"iPhone to Other";
static NSString *const CT_OTHER_TO_IPHONE = @"Other to iPhone";

//QR Code view controller
static NSString *const CT_BONJOUR_CONNECTTION_ALERT_TITLE = @"Do you want to start the transfer?";
static NSString *const CT_BONJOUR_CONNECTTION_ALERT_CONTEXT = @"Tap connect button within %d seconds to connect.";
static NSString *const CT_TURN_ON_WIFI_ALERT_CONTEXT = @"\nPlease turn on Wifi";
static NSString *const CT_WIFI_PATH = @"\n\nGo to Settings -> Wi-Fi and toggle On.";
static NSString *const CT_TURN_OFF_BT_ALERT_CONTEXT = @"\nPlease turn off bluetooth";
static NSString *const CT_BT_PATH = @"\n\nGo to Settings -> Bluetooth and toggle Off.";
static NSString *const CT_FORMATTED_TURN_OFF_BT_ALERT_CONTEXT = @"%@ and turn off bluetooth";
static NSString *const CT_WIFI_AND_BT_PATH = @"\n\nGo to Settings -> Wi-Fi and toggle On, then to Settings -> Bluetooth and toggle Off.";
static NSString *const CT_PUBLISH_SERVICE_STRING = @" to start publishing service.";
static NSString *const CT_VERSION_MISMATCH_SENDER_ALERT_CONTEXT = @"The Content Transfer app on the other device seems to be out of date. Please update the app on that device to v:%@";
static NSString *const CT_VERSION_MISMATCH_RECEIVER_ALERT_CONTEXT = @"The Content Transfer app on this device seems to be out of date. Please update the app to v:%@";
static NSString *const CT_INSTORE_AND_GUEST_WIFI_ALERT_CONTEXT = @"It appears you have connected to the Verizon Guest Wifi Network. For optimum performance, please select the MCT-Fast (preferred) or MCT Network. The network uses a password which has been copied to your clipboard. Please paste it in the password field when you join the network.\n\nPassword: vztransfer";
static NSString *const CT_NOT_SURE_IN_STORE_ALERT_CONTEXT = @"Are you using the Verizon store wifi? For optimum performance, please select the MCT-Fast (preferred) or MCT Network. The network uses a password which has been copied to your clipboard. Please paste it in the password field when you join the network.\n\nPassword: vztransfer";
static NSString *const CT_OPEN_WIFI_AND_CONNECT_TO_NW_CONTEXT = @"Please open Wi-Fi settings and select a network to connect to.";
static NSString *const CT_PAIRING_PROBLEM_CONTEXT = @"There was a problem while pairing on the current network. Please choose a different network or try Manual Setup.";
static NSString *const CT_MANUAL_PAIRING_ALERT_CONTEXT = @"Do you want to connect your devices manually?\n\nClicking OK will restart the app. Please choose Manual Setup on the other device also.\n";

//Sender scanner view controller
static NSString *const CT_TRY_ANOTHER_WAY_BUTTON_TITLE = @"Try another way";
static NSString *const CT_RESCAN_BUTTON_TITLE = @"Rescan";
static NSString *const CT_BACK_CAMERA_ERROR_MESSAGE_LABEL = @"Cannot open back camera.";
static NSString *const CT_BACK_CAMERA_ALERT_CONTEXT = @"We cannot use your back camera. Please make sure you're camera is functional. Also make sure you granted the camera permission.\n\n Or \n\n You can use \"Manual Setup\" to continue";
static NSString *const CT_MANUAL_SETUP_BUTTON_TITLE = @"Manual Setup";
static NSString *const CT_OPENING_CAMERA_LABEL = @"Opening camera...";
static NSString *const CT_INVALID_OPERATION_ALERT_TITLE = @"Invalid Operation";
static NSString *const CT_INVALID_OPERATION_ALERT_CONTEXT = @"Cannot connect two devices both have old phone setting.";
static NSString *const CT_START_SEARCHING_STRING = @" to start searching for devices.";
static NSString *const CT_INVITATION_REJECTED_ALERT_CONTEXT = @"The invitation is rejected by new device, please try again.";
static NSString *const CT_ERROR_READING_CODE_ALERT_CONTEXT = @"Error reading the code. Please make sure you have scanned the correct code or choose Manual Setup.";
static NSString *const CT_ERROR_READING_CODE_ALERT_CONTEXT_MULTIPEER = @"The code you scanned does not match the device setup: Multiple phone transfer. Please restart the transfer to select the correct setup.";
static NSString *const CT_ERROR_SCANNING_CODE_ALERT_CONTEXT_OTHER_TO_IPHONE = @"The code you scanned does not match the device setup: Other to iPhone. Please restart the transfer to select the correct setup.";
static NSString *const CT_ERROR_SCANNING_CODE_ALERT_CONTEXT_IPHONE_TO_OTHER = @"The code you scanned does not match the device setup: iPhone to Other. Please restart the transfer to select the correct setup.";
static NSString *const CT_ERROR_SCANNING_CODE_ALERT_CONTEXT_IPHONE_TO_IPHONE = @"The code you scanned does not match the device setup: iPhone to iPhone. Please restart the transfer to select the correct setup.";
static NSString *const CT_ERROR_SCANNING_CODE_ALERT_CONTEXT_ONE_TO_MANY = @"The code you scanned does not match the device setup: one to many. Please restart the transfer to select the correct setup.";
static NSString *const CT_ERROR_SCANNINED_CODE_ALERT_CONTEXT_IS_ONE_TO_MANY = @"The code you scanned is for one to many. It doesn't match your current setup. Please restart the transfer to select the correct setup.";
static NSString *const CT_RESCAN_ALERT_CONTEXT = @"Unable to connect to the other device. Please join a Wi-Fi network on the other device and rescan\n\nor\n\nSelect Manual Setup on both devices";
static NSString *const CT_RESCAN_AND_MANUAL_SETUP_ALERT_CONTEXT = @"Unable to connect to the other device. Please rescan or try Manual Setup.";
static NSString *const CT_CONNECT_TO_DEVICE_HOTSPOT_ALERT_TITLE = @"Connect to Device Hotspot";
static NSString *const CT_CONNECT_TO_DEVICE_HOTSPOT_ALERT_BODY_PART1 = @"\nGo to Settings > Wi-Fi to connect to the network: %@.";
static NSString *const CT_CONNECT_TO_DEVICE_HOTSPOT_ALERT_BODY_PART2 = @"\n\nThe password has been copied to your clipboard.";
static NSString *const CT_CONNECT_TO_DEVICE_HOTSPOT_ALERT_BODY_PART3 = @" Paste it into the Wi-Fi password field.";
static NSString *const CT_CONNECT_DEVICE_TO_NETWORK_ALERT_CONTEXT = @"Please connect this devices to the network shown below.\n\nNetwork name: %@.";
static NSString *const CT_CONNECT_TO_NETWORK_INFO_LABEL = @"Please connect to the network shown below.";
static NSString *const CT_CONNECT_TO_NETWORK_SEC_INFO_LABEL_PART1 = @"Please go to Wi-Fi Settings on your device setting app to connect to below network.\n\nPath on device: Settings -> Wi-Fi\n\n";
static NSString *const CT_CONNECT_TO_NETWORK_SEC_INFO_LABEL_PART2 = @"Network name: %@";
static NSString *const CT_CONNECT_TO_NETWORK_SEC_INFO_LABEL_PART3 = @"\n\nPassword: %@";
static NSString *const CT_PIN_ERROR_ALERT_CONTEXT = @"Please check the pin, verify both phones are still connected to same network and retry.";

//Wi-Fi setup view controller screen

static NSString *const CT_WIFI_SETUP_VC_NAV_TITLE = @"Pairing";
static NSString *const CT_WIFI_SETUP_VC_SEC_LABEL = @"Find a secure network and connect both phones";
static NSString *const CT_WIFI_NOT_CONNECTED_LABEL = @"WiFi is not connected";
static NSString *const CT_UNABLE_TO_ACCESS_HOTSPOT_ALERT_CONTEXT = @"Unable to acess hotspot network. Please check other device hotspot setting, and try again.";

//Bonjour Receiver View controller screen

static NSString *const CT_FORGET_NETWORKS_ALERT_CONTEXT = @"For best performance please turn on WiFi, but forget all your networks. Data charge will not apply. Go to Settings -> Wi-Fi.  Press \"i\" button and select \"Forget This Network\"  for all joined networks.";

//Bonjour sender view controller screen

static NSString *const CT_I_DONT_SEE_LABEL = @"I don't see my phone";

//Bonjour manager activity indicator alert

/*Bonjour reconnect alert title*/
static NSString *const CT_RECONNECT_ALERT_TITLE = @"Reconnecting...";

/*Bonjour reconnect localization alert context*/
static NSString *const CT_RECONNECT_ALERT_CONTEXT = @"Something wrong with your connection. Please wait...";

static NSString *const CT_RECONNECT_FAILED_ALERT_CONTEXT = @"Reconnect failed. Try again in %ds.";

//Receiver Pin View controller screen

static NSString *const CT_CHECK_WIFI_ALERT_CONTEXT = @"Please check your mobile wifi connection";

//Sender pin view controller

static NSString *const CT_CONNECT_DIALOG_CONTEXT = @"Connecting. Please wait..";

static NSString *const CT_INVALID_PIN_ALERT_CONTEXT = @"Invalid PIN, please try again.";

static NSString *const CT_CHECK_WIFI_CONFIG_ALERT_CONTEXT = @"Unable to connect due to other device. Please check the Wi-Fi configuration you connect.";

static NSString *const CT_VERSION_MISMATCH_SENDER_HIGHER_ALERT_CONTEXT = @"The Content Transfer app on the other device seems to be out of date. Please update the app on that device to v:%@ or higher";

static NSString *const CT_SENDER_CONNECTION_ERROR_ALERT_CONTEXT = @"Fail to connect due to reason:\"%@\". Please check the Wi-Fi configuration you connect.";

//Sender transfer view controller screen
static NSString *const CTSelectPromptFormat = @"Collecting %@ for you...\nPlease wait...";
static NSString *const CTZeroItemTextFormat = @"Some of the items selected for transfer have no content on your device. Please verify your selections once more before clicking on \"Transfer\".";
static NSString *const CTAudioFormatWarning = @"Audio from this device might not play in the default player on your new device.";
static NSString *const CTAudioOSSupportErr = @"Your current version of iOS does not support Audio transfer. Update your device to transfer Audio content.";
static NSString *const CTCloudContactsWarning = @"Contacts that you have saved in Cloud will not be transferred. Sign in to your Cloud account from your new device to retrieve these contacts.";
static NSString *const CT_COLLECTING_CELL_SEC_LABEL = @"Collecting...";
static NSString *const CT_PERMISSION_NOT_GRANTED_SEC_LABEL = @"Permission Not Granted";
static NSString *const CT_IN_ICLOUD_TER_LABEL = @"%ld in Cloud";
static NSString *const CT_AUDIO = @"Audio";
static NSString *const CT_NOT_SUPPORTED = @"Not supported";
static NSString *const CT_PERMISSION_NOT_GRANTED_ALERT_CONTEXT = @"Permission is not granted. Please go to settings and give permission";
static NSString *const CT_DESELECT_ALL_BTN_TITLE = @"Deselect All";
static NSString *const CT_SELECT_ALL_BTN_TITLE = @"Select All";
static NSString *const CT_STOP_TRANSFER_ALERT_TITLE = @"Are you sure you want to leave now?";
static NSString *const CT_STOP_TRANSFER_ALERT_CONTEXT = @"If you stop the transfer, you'll have to start over again.";
static NSString *const CT_FILES_OVER_LIMIT_SEC_LABEL = @"We can't fit %lld MB of things on your %lld MB new phone. Select less files and try again";
static NSString *const CT_PHOTO_STRING = @"photo";
static NSString *const CT_VIDEO_STRING = @"video";
static NSString *const CT_AUDIO_STRING = @"audio";

//Receiver ready view controller screen
static NSString *const CT_TRANSFER_FAILED_ALERT_CONTEXT = @"Your connection failed. Please try again.";

//Generic Transfer View Controller
static NSString *const CT_TRANSFER_NAV_TITLE = @"Transfer";


//Sender progress view controller
static NSString *const CT_SENT = @"Sent";
static NSString *const CT_SPEED = @"Speed";
static NSString *const CT_SENDING_AMOUNT = @"Sending %@";
static NSString *const CT_LAST_TRANSFER_FAILED_ALERT_CONTEXT = @"Your last transfer failed, we will save all contents already transferred. Please try again to continue the rest of the data.";

//Receiver progress view controller
static NSString *const CT_TIME_LEFT = @"Time left";
static NSString *const CT_RECEIVED = @"Received";
static NSString *const CT_TRANSFERRED_OF_TOTAL_LABEL_LONG = @"%ld of %ld";
static NSString *const CT_TRANSFERRED_OF_TOTAL_LABEL_STRING = @"%@ of %@";
static NSString *const CT_RECEIVING_AMOUNT = @"Receiving %@";

//Contacts import
static NSString *const CT_GRANT_CONTACTS_PERM_ALERT_CONTEXT = @"Please Grant permission and try again :Settings-->Privacy-->Contacts--> My Verizon";
static NSString *const CT_GRANT_CONTACTS_PERM_ALERT_TITLE = @"Cannot Add Contact";

//Data saving view controller screen
static NSString *const CT_DATA_SAVING_NAV_TITLE = @"Transfer Saving";
static NSString *const CT_ALMOST_DONE_LABEL = @"Almost done.";
static NSString *const CT_DATA_SAVING_VC_SEC_LABEL = @"Your things are being sorted and saved.";
static NSString *const CT_DATA_SAVING_KEY_LABEL = @"Preparing data to be saved";

//App list view controller
static NSString *const CT_APP_LIST_VC_NAV_TITLE = @"Install Apps";
static NSString *const CT_NO_INTERNET_CONTEXT = @"You need Internet connection to fetch the necessary information for your apps list. Please connect to avaliable network or press \"Done\" button to continue.";
static NSString *const CT_SAVE_LIST_ALERT_CONTEXT = @"Do you want to save the list? If you save the list, you can come back to content transfer to download your installed app at anytime in future.";

//Transfer Finish View Controller
static NSString *const CT_TRANSFER_FINISH_VC_NAV_TITLE = @"Transfer Complete";


//Error View controller screen
static NSString *const CT_ERROR_VC_NAV_TITLE = @"Error";

//Transfer Summary screen
static NSString *const CT_TRANSFER_SUMMARY_VC_NAV_TITLE = @"Transfer Summary";
static NSString *const CT_TRANSFER_SUMMARY_INFO_LABEL = @"* Some videos and pictures moved to your new device may not appear in the gallery (eg: .mov and .png). Please find the appropriate app(s) to view them.";
static NSString *const CT_TRANSFER_SUMMARY_DATA_STATUS_LABEL = @"No media was transferred.";
static NSString *const CT_TRANSFER_SUMMARY_TRANSFERRED_DATA_STATUS_LABEL = @"See how %@ MB of your %@ transferred.";
static NSString *const CT_TRANSFER_SUMMARY_SPEED_INFO_LABEL = @"Average Speed: %@";
static NSString *const CT_TRANSFER_SUMMARY_TOTAL_TIME_LABEL = @"Total Time: %@";
static NSString *const CT_LOCALIZED_HRS_FORMAT = @"%ld hrs";
static NSString *const CT_LOCALIZED_MIN_FORMAT = @"%ld min";
static NSString *const CT_LOCALIZED_SEC_FORMAT = @"%ld sec";
static NSString *const CT_LOCALIZED_1SEC_FORMAT = @"1 sec";
static NSString *const CT_TRANSFER_SUMMARY_LABEL = @"See how %@ of your %@ transferred.";

//Transfer Details
static NSString *const CT_TRANSFER_DETAILS_VC_NAV_TITLE = @"Transfer Summary Details";
static NSString *const CT_TRANSFER_DETAILS_ALL_SET_MESSAGE = @"All set. Your things transferred smoothly.";
static NSString *const CT_TRANSFER_DETAILS_ERROR_MESSAGE = @"Some of your things didn't transfer all the way.";
static NSString *const CT_TRANSFER_DETAILS_MANUAL_BACKUP_MESSAGE = @"You can manually back up your things to a computer to keep them safe.";
static NSString *const CT_TRANSFER_DETAILS_NO_PERM_FOR_CONTACTS = @"You have not granted permission for contacts";
static NSString *const CT_TRANSFER_DETAILS_GRANT_PERM_FOR_CONTACTS = @"You can give permission for contacts and try again.";
static NSString *const CT_TRANSFER_DETAILS_NO_PERM_FOR_PHOTOS = @"You have not granted permission for photos";
static NSString *const CT_TRANSFER_DETAILS_GRANT_PERM_FOR_PHOTOS = @"You can give permission for photos and try again.";
static NSString *const CT_TRANSFER_DETAILS_NO_PERM_FOR_VIDEOS = @"You have not granted permission for videos";
static NSString *const CT_TRANSFER_DETAILS_GRANT_PERM_FOR_VIDEOS = @"You can give permission for videos and try again.";
static NSString *const CT_TRANSFER_DETAILS_NO_PERM_FOR_CALANDERS = @"You have not granted permission for calendars.";
static NSString *const CT_TRANSFER_DETAILS_GRANT_PERM_FOR_CALANDERS = @"You can give permission for calendars and try again.";
static NSString *const CT_TRANSFER_DETAILS_NO_PERM_FOR_REMINDERS = @"You have not granted permission for reminders.";
static NSString *const CT_TRANSFER_DETAILS_GRANT_PERM_FOR_REMINDERS = @"You can give permission for reminders and try again.";
static NSString *const CT_TRANSFER_DETAILS_SIGN_IN_TO_ICLOUD_PHOTOS = @"Sign in to iCloud account on other device to download iCloud backed photos";
static NSString *const CT_TRANSFER_DETAILS_SIGN_IN_TO_ICLOUD_VIDEOS = @"Sign in to iCloud account on other device to download iCloud backed videos";
static NSString *const CT_TRANSFER_DETAILS_TRANSFER_FAIL_LABEL = @"%ld files fail to save due to reason: %@";
static NSString *const CT_TRANSFER_DETAILS_LIVE_PHOTO_BECOME_STATIC = @"Some of your live photos may become regular photos.";

//STM Option View Controller Screen
static NSString *const CT_MULTIPLE_PHONE_OPTION = @"Multiple Phone Transfer";
static NSString *const CT_COMBINATION_OPTION = @"Combination";
static NSString *const CT_IOS_DEVICES_ONLY_OPTION = @"iOS devices only";

//STM Recev View Controller
static NSString *const CT_AND_TURN_OFF_BT_STRING = @"and turn off bluetooth";
static NSString *const CT_START_PAIRING_DEVICES_STRING = @" to start pairing devices.";
static NSString *const CT_ERROR_READING_CODE_STM_ALERT_CONTEXT = @"Error reading the code. Please make sure you have scanned the correct code.";
static NSString *const CT_INVALID_QR_CODE_ALERT_CONTEXT = @"Invalid QR Code";

//STM Sender View Controller Screen
static NSString *const CT_SCAN_QR_CODE_TITLE_LABEL = @"Scan this QR code with the other device.";
static NSString *const CT_SCAN_QR_CODE_SUB_TITLE_LABEL = @"Scan this code on up to 7 devices.";
static NSString *const CT_WHAT_ARE_YOU_TRANSFERRING_TITLE_LABEL = @"What are you transferring?";
static NSString *const CT_WHAT_ARE_YOU_TRANSFERRING_SUB_TITLE_LABEL = @"Choose all the things you want on your new phone.";
static NSString *const CT_STM_SENDER_CLOUD_LABEL = @"* Sign in to your Cloud account on the new device to access Cloud content.";
static NSString *const CT_STM_SENDER_TRANSFER_PROGRESS_TITLE_LABEL = @"Your transfer is in progress";
static NSString *const CT_STM_SENDER_TRANSFER_PROGRESS_SUB_TITLE_LABEL = @"Keep the app open for a smooth transfer";
static NSString *const CT_STM_SENDER_FOOTER_TEXT = @"Scroll down to check more devices";
static NSString *const CT_STM_SENDER_HEADER_TEXT_PART1 = @"Total Transfer";
static NSString *const CT_STM_SENDER_HEADER_TEXT_PART2 = @"files with size of";
static NSString *const CT_STM_SENDER_DEVICE_LABEL = @"Device: ";
static NSString *const CT_STM_SENDER_DEVICE_DETAILED_LABEL = @"Total Connected:";
static NSString *const CT_STM_SENDER_FILES_PROGRESS_LABEL = @"Files";
static NSString *const CT_STM_SENDER_IN_CLOUD = @"in Cloud";
static NSString *const CT_STM_SENDER_NO_DEVICE_SPACE_ALERT_CONTEXT = @"don't have enough space for the size of selected contents, do you want to continue without transferring to those device";
static NSString *const CT_STM_SENDER_NO_DEVICES_SPACE_ALERT_CONTEXT = @"None of the devices has enough space for selected contents";
static NSString *const CT_STM_SENDER_LESS_THAN_1MB = @"Less than 1 MB";

//STM Receiver View Controller Screen
static NSString *const CT_STM_RECEIVER_RATE_FORMATTER = @"%.1f of %.1f MB";
static NSString *const CT_STM_RECEIVER_TOTAL_RATE_FORMATTER = @"0 of %.1f MB";
static NSString *const CT_STM_RECEIVER_FILE_LIST_LITERAL = @"Receiving file list";

//STM Sender Recap view controller screen
static NSString *const CT_STM_SENDER_RECAP_LABEL = @"Here’s your transfer recap.";
static NSString *const CT_STM_SENDER_RECAP_DONE_BUTTON = @"Done";

static NSString *const CT_CAMERA_ROLL_ALBUM = @"Camera Roll";
static NSString *const CT_RECENTLY_ADDED_ALBUM = @"Recently Added";
static NSString *const CT_ALL_PHOTOS_ALBUM = @"All Photos";
static NSString *const CT_TNC_LINK = @"Terms and Conditions";
static NSString *const CT_PRIVACY_POLICY_HYPERLINK = @"Privacy Policy";
static NSString *const CT_ABOUT_HPERLINK = @"About";

static NSString *const CT_SAVE_FINISHED = @"Save Finished!";
static NSString *const CT_DELETE_FINISHED = @"Delete Finished!";

#endif /* CTStringConstants_h */
