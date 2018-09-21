//
//  VZAnalyticsConstants.h
//  contenttransfer
//
//  Created by Mehta, Snehal Natwar on 7/26/16.
//  Copyright © 2016 Hadapad, Prakash. All rights reserved.
//

#ifndef VZAnalyticsConstants_h
#define VZAnalyticsConstants_h

/***************Old constant values for Adobe analytics, which is now removed, so all the constants deprecated.******************/
#pragma mark - Adobe analytics states
static NSString *const ANALYTICS_TrackState_Key_Param_PageName                                    = @"vzwi.mvmapp.pageName";
static NSString *const ANALYTICS_TrackState_Value_PageName_PairingFailed                          = @"/ct/pop up pairing failed";
static NSString *const ANALYTICS_TrackState_Value_PageName_VersionMismatch                        = @"/ct/pop up version mismatch";
static NSString *const ANALYTICS_TrackState_Value_PageName_PhoneSelect                            = @"/ct/phone select";
static NSString *const ANALYTICS_TrackState_Value_PageName_PhoneCombination                       = @"/ct/phone combination";
static NSString *const ANALYTICS_TrackState_Value_PageName_PhoneWiDiSelect                        = @"/ct/phone widi select";
static NSString *const ANALYTICS_TrackState_Value_PageName_PhoneWiDiHotSpot                       = @"/ct/phone widi hotspot";
static NSString *const ANALYTICS_TrackState_Value_PageName_PhoneWiFiSelect                        = @"/ct/phone wifi select";
static NSString *const ANALYTICS_TrackState_Value_PageName_PhonePIN                               = @"/ct/phone pin";
static NSString *const ANALYTICS_TrackState_Value_PageName_PhoneTransfer                          = @"/ct/phone transfer";
static NSString *const ANALYTICS_TrackState_Value_PageName_PhoneProcessing                        = @"/ct/phone processing";
static NSString *const ANALYTICS_TrackState_Value_PageName_PhoneFinish                            = @"/ct/phone finish";
static NSString *const ANALYTICS_TrackState_Key_LinkName_PhoneCrash                               = @"/ct/phone crash";
#pragma mark - Adobe analytics actions
static NSString *const ANALYTICS_TrackAction_Value_LinkName_MetaDataFileRead                      = @"metadata file read";
static NSString *const ANALYTICS_TrackAction_Value_LinkName_SameWifi                              = @"/ct/same Wifi";
static NSString *const ANALYTICS_TrackAction_Value_LinkName_ConnectUsingPin                       = @"/ct/connect using pin";
static NSString *const ANALYTICS_TrackAction_Key_ErrorMessage                                     = @"vzwi.mvmapp.errorMessage";
static NSString *const ANALYTICS_TrackAction_Key_LinkName                                         = @"vzwi.mvmapp.LinkName";
static NSString *const ANALYTICS_TrackAction_Key_PageLink                                         = @"vzwi.mvmapp.pageLink";
static NSString *const ANALYTICS_TrackAction_Key_TransactionId                                    = @"vzwi.mvmapp.transactionId";
static NSString *const ANALYTICS_TrackAction_Key_SenderReceiver                                   = @"vzwi.mvmapp.senderReceiver";
static NSString *const ANALYTICS_TrackAction_Key_CancelTransfer                                   = @"vzwi.mvmapp.cancelTransfer";
static NSString *const ANALYTICS_TrackAction_Value_SenderReceiver_Sender                          = @"sender";
static NSString *const ANALYTICS_TrackAction_Value_SenderReceiver_Receiver                        = @"receiver";
static NSString *const ANALYTICS_TrackAction_Value_CancelTransfer                                 = @"cancel transfer";
static NSString *const ANALYTICS_TrackAction_Param_Key_FlowInitiated                              = @"vzwi.mvmapp.flowinitiated";
static NSString *const ANALYTICS_TrackAction_Param_Key_FlowName                                   = @"vzwi.mvmapp.flowName";
static NSString *const ANALYTICS_TrackAction_Param_Key_MDN                                        = @"vzwi.mvmapp.MDN";
static NSString *const ANALYTICS_TrackAction_Param_Value_FlowInitiated_1                          = @"1";
static NSString *const ANALYTICS_TrackAction_Param_Value_FlowInitiated_PairingOfSenderAndReceiver = @"pairing of sender and receiver";
static NSString *const ANALYTICS_TrackAction_Param_Value_FlowName_TransferToReceiver              = @"transfer to receiver";
static NSString *const ANALYTICS_TrackAction_Param_Value_LinkName_YesButtonHotspotWifi            = @"yes button phone wifi";
static NSString *const ANALYTICS_TrackAction_Name_Button_Old                                      = @"click button old on phone select screen";
static NSString *const ANALYTICS_TrackAction_Name_Button_New                                      = @"click button new on phone select screen";
static NSString *const ANALYTICS_TrackAction_Name_Select_Continue                                 = @"select continue";
static NSString *const ANALYTICS_TrackAction_Name_Phone_Selected                                  = @"phone selected";
static NSString *const ANALYTICS_TrackAction_Name_Use_Hostpot                                     = @"use hotspot";
static NSString *const ANALYTICS_TrackAction_Name_Yes_Phone_WiDi_Selected                         = @"yes phone widi selected";
static NSString *const ANALYTICS_TrackAction_Name_Yes_Phone_WiFi_Selected                         = @"yes phone wifi select";
static NSString *const ANALYTICS_TrackAction_Name_Connect                                         = @"connect";
static NSString *const ANALYTICS_TrackAction_Name_Pairing_Failed                                  = @"pairing failed";
static NSString *const ANALYTICS_TrackAction_Name_Transfer                                        = @"transfer";
static NSString *const ANALYTICS_TrackAction_Name_Cancel_Transfer                                 = @"cancel transfer";
static NSString *const ANALYTICS_TrackAction_Name_Close                                           = @"click on close button finished screen";
static NSString *const ANALYTICS_TrackAction_Name_Transfer_Failed                                 = @"transfer failed";
static NSString *const ANALYTICS_TrackAction_Param_Key_SiteSection                                = @"vzwi.mvmapp.Category";
static NSString *const ANALYTICS_TrackAction_Param_Key_LOB                                        = @"vzwi.mvmapp.LOB";
static NSString *const ANALYTICS_TrackAction_Param_Key_Language                                   = @"vzwi.mvmapp.language";
static NSString *const ANALYTICS_TrackAction_Param_Key_AppVersion                                 = @"vzwi.mvmapp.appVersion";
static NSString *const ANALYTICS_TrackAction_Param_Key_SDKVersion                                 = @"vzwi.mvmapp.sdkVersion";
static NSString *const ANALYTICS_TrackAction_Param_Value_LinkName_WifiDirectSelected              = @"wifi direct selected";
static NSString *const ANALYTICS_TrackAction_Param_Value_LinkName_HotspotSelected                 = @"use hotspot button selected";
static NSString *const ANALYTICS_TrackAction_Param_Value_LinkName_IOS_TO_IOS                      = @"select ios to ios";
static NSString *const ANALYTICS_TrackAction_Param_Value_LinkName_IOS_TO_ANDROID                  = @"select ios to android";
static NSString *const ANALYTICS_TrackAction_Param_Value_LinkName_ANDRIOD_TO_IOS                  = @"select android to ios";
static NSString *const ANALYTICS_TrackAction_Param_Value_LinkName_SameWifi                        = @"yes phone wifi select";
static NSString *const ANALYTICS_TrackAction_Param_Value_LinkName_CancelTransferBeforeBegin       = @"cancel transfer before beginning";
// Transfer what screen
static NSString *const ANALYTICS_TrackAction_Key_FlowCompleted                                    = @"vzwi.mvmapp.flowcompleted";
static NSString *const ANALYTICS_TrackAction_Key_MediaSelected                                    = @"vzwi.mvmapp.typesMediaSelected";
static NSString *const ANALYTICS_TrackAction_Key_NbOfContactsToTransfer                           = @"vzwi.mvmapp.nbContactsToTransfer";
static NSString *const ANALYTICS_TrackAction_Key_NbOfPhotosToTransfer                             = @"vzwi.mvmapp.nbPhotosToTransfer";
static NSString *const ANALYTICS_TrackAction_Key_NbOfVideosToTransfer                             = @"vzwi.mvmapp.nbVideosToTransfer";
static NSString *const ANALYTICS_TrackAction_Key_NbOfAudiosToTransfer                             = @"vzwi.mvmapp.nbAudiosToTransfer";
static NSString *const ANALYTICS_TrackAction_Key_NbOfCallLogsToTransfer                           = @"vzwi.mvmapp.nbCallLogsToTransfer";
static NSString *const ANALYTICS_TrackAction_Key_NbOfSmsToTransfer                                = @"vzwi.mvmapp.nbSmsToTransfer";
static NSString *const ANALYTICS_TrackAction_Key_NbOfCalendarsToTransfer                          = @"vzwi.mvmapp.nbCalendarsToTransfer";
// Finish screen
static NSString *const ANALYTICS_TrackAction_Key_NbContactsTransferred                            = @"vzwi.mvmapp.nbContactsTransferred";
static NSString *const ANALYTICS_TrackAction_Key_NbPhotosTransferred                              = @"vzwi.mvmapp.nbPhotosTransferred";
static NSString *const ANALYTICS_TrackAction_Key_NbVideosTransferred                              = @"vzwi.mvmapp.nbVideosTransferred";
static NSString *const ANALYTICS_TrackAction_Key_NbAudioTransferred                               = @"vzwi.mvmapp.nbAudioTransferred";
static NSString *const ANALYTICS_TrackAction_Key_NbCalllLogsTransferred                           = @"vzwi.mvmapp.nbCallLogsTransferred";
static NSString *const ANALYTICS_TrackAction_Key_NbSmsTransferred                                 = @"vzwi.mvmapp.nbSmsTransferred";
static NSString *const ANALYTICS_TrackAction_Key_NbCalendarsTransferred                           = @"vzwi.mvmapp.nbCalendarsTransferred";
static NSString *const ANALYTICS_TrackAction_Key_NbReminderTransferred                            = @"vzwi.mvmapp.nbRemindersTransferred";
static NSString *const ANALYTICS_TrackAction_Key_DataVolumeTransferred                            = @"vzwi.mvmapp.dataVolumeTransferred";
static NSString *const ANALYTICS_TrackAction_Key_TransferDuration                                 = @"vzwi.mvmapp.transferDuration";
static NSString *const ANALYTICS_TrackAction_Key_TransferSpeed                                    = @"vzwi.mvmapp.transferSpeed";
static NSString *const ANALYTICS_TrackAction_Key_NbContactsToTransfer                             = @"vzwi.mvmapp.nbContactsToTransfer";
static NSString *const ANALYTICS_TrackAction_Key_NbPhotosToTransfer                               = @"vzwi.mvmapp.nbPhotosToTransfer";
static NSString *const ANALYTICS_TrackAction_Key_NbVideosToTransfer                               = @"vzwi.mvmapp.nbVideosToTransfer";
static NSString *const ANALYTICS_TrackAction_Key_NbRemindersToTransfer                            = @"vzwi.mvmapp.nbRemindersToTransfer";
static NSString *const ANALYTICS_TrackAction_Key_NbCalendarsToTransfer                            = @"vzwi.mvmapp.nbCalendarsToTransfer";
// To report error
static NSString *const ANALYTICS_TrackAction_Key_ErrorCode                                        = @"vzwi.mvmapp.errorCode";
static NSString *const ANALYTICS_TrackAction_SenderReceiverTransactionId                          = @"vwwi.mvmapp.senderReceiverId";
// Action params values
static NSString *const ANALYTICS_TrackAction_Param_Value_SiteSection                              = @"/ct";
static NSString *const ANALYTICS_TrackAction_Param_Value_LOB                                      = @"consumer";
static NSString *const ANALYTICS_TrackAction_Param_Value_Language                                 = @"english";
#pragma mark - Adobe analytics error message
static NSString *const ANALYTICS_TrackState_Value_ErrorMessage_PhoneCrash                         = @"app crash";
/************************************Deprecated Adobe analytics constants end.****************************************/

#pragma mark - Analytics URLs
static NSString *const ANALYTICS_PROD_URL = @"https://mobile.vzw.com/CTAnalytics/CTAudit";
static NSString *const ANALYTICS_DEV_URL  = @"https://mvm-wdev1.vzw.com/CTAnalytics/CTAudit";

#endif /* VZAnalyticsConstants_h */
