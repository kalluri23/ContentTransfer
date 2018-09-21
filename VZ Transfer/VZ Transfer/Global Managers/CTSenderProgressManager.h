//
//  CTSenderProgressManager.h
//  contenttransfer
//
//  Created by Hadapad, Prakash on 9/8/16.
//  Copyright © 2016 Verizon Wireless. All rights reserved.
//
/*!
    @header CTSenderProgressManager.h
    @discussion This is the header of CTSenderProgressManager class.
 */
#import <Foundation/Foundation.h>
#import "CTSenderBonjourManager.h"
#import "GCDAsyncSocket.h"
#import "CTSenderP2PManager.h"
#import "CTProgressInfo.h"
#import "CTDeviceMarco.h"
#import "CTContentTransferConstant.h"
#import "CTPhotosManager.h"
#import "CTFileList.h"

/*!
 Delegate of progress manager on sender side. This protocol contains all the callback used during P2P sending process.
 @Note All the methods are optional.
 */
@protocol CTSenderProgressManagerDelegate <NSObject>

@optional
/*!
    @brief Delegate method to update UI. Information will be contained in CTProgressInfo class.
    @param progressInfo CTProgressInfo object contains all the information for updating the UI.
    @see CTProgressInfo
 */
- (void)updateUIWithProgressInfo:(CTProgressInfo *)progressInfo;
/*!Call this method when transfer finished.*/
- (void)transferDidFinished;
/*!Call this method when receiver side doesn't have enough storage.*/
- (void)transferShouldGoToNotEnoughStorage;
/*!Call this method when user clicked cancel button on receiver side.*/
- (void)transferDidCancelled;
/*!
 Call this method when transfer got total payload.
 @param totalPayload Total size of data saved in NSNumber as long long.
 */
- (void)transferShouldUpdatePayload:(NSUInteger)payload;
/*!
 Call this method when process should block request for reconnect.
 @param warningText NSString represents the waring text message.
 */
- (void)transferShouldBlockForReconnect:(NSString *)warningText;
/*!
 Call this method when process should accept reconnect and continue receiving.
 @param success YES if success; otherwise NO.
 */
- (void)transferShouldEnableForContinue:(BOOL)success;

@end

/*! @brief The enum type of all the possible transfer type.*/
enum state_machine {
    /*!@b Deprecated.*/
    TRANSFER_HAND_SHAKE,
    /*!@b Deprecated.*/
    TRANSFER_ALL_FILE,
    /*!Transfer vcard.*/
    TRANSFER_VCARD_FILE,
    /*!@b Deprecated.*/
    TRANSFER_PHOTO_LOG_FILE,
    /*!Transfer photo file.*/
    TRANSFER_PHOTO_FILE,
    /*!Transfer live photo file.*/
    TRANSFER_LIVEPHOTO_FILE,
    /*!Transfer live photo video file.*/
    TRANSFER_LIVEPHOTO_VIDEO_FILE,
    /*!@b Deprecated.*/
    TRANSFER_VIDEO_LOG_FILE,
    /*!Transfer video file.*/
    TRANSFER_VIDEO_FILE,
    /*!Transfer is completed.*/
    TRANSFER_COMPLETED,
    /*!Transfer next chunk of video.*/
    TRANSFER_NEXT_VIDEO_PART,
    /*!@b Deprecated.*/
    TRANSFER_CALENDER_LOG_FILE,
    /*!Transfer reminder file.*/
    TRANSFER_REMINDER_LOG_FILE,
    /*!@b Deprecated.*/
    TRANSFER_CALENDER_ICS_FILE,
    /*!@b Deprecated.*/
    TRASNFER_REMINDER_ICS_FILE,
    /*!Transfer duplicated files.*/
    TRASNFER_FILE_DUPLICATE,
    /*!Transfer first calendar file.*/
    TRANSFER_CALENDAR_FILE_START,
    /*!Transfer calendar files.*/
    TRANSFER_CALENDAR_FILE,
    /*!Transfer last calendar file.*/
    TRANSFER_CALENDAR_FILE_END,
    /*!Not enough storage.*/
    TRANSFER_NO_ENOUGH_STORAGE,
    /*!Transfer cancelled.*/
    TRANSFER_CANCEL,
    /*!Trnasfer reconnect for video.*/
    TRANSFER_RECONNECT_VIDEO,
    /*!Transfer reconnect for photo.*/
    TRANSFER_RECONNECT_PHOTO,
    /*!Transfer reconnect for live photo.*/
    TRANSFER_RECONNECT_LIVE_PHOTO,
    /*!Transfer reconnect for live photo video component.*/
    TRANSFER_RECONNECT_LIVE_PHOTO_VIDEO_COMPO,
    /*!Transfer reconnect for duplicate video*/
    TRANSFER_RECONNECT_DUPLICATE_VIDEO,
    /*!Transfer reconnect for duplicate photo.*/
    TRANSFER_RECONNECT_DUPLICATE_PHOTO,
    /*!Transfer audio files.*/
    TRANSFER_AUDIO_FILE
};

/*!
    @brief      This is a general manager class for sender side progress.
    @discussion This class will contain all the general sending logic used in both P2P and Bonjour connection type, such as real file sending logic, and request type detecting. 
 
                This is the upper level manager beyond P2P/Bonjour Manager. And will communicate with top level view controller directly using delegates.
 */
@interface CTSenderProgressManager : NSObject <CTSenderProgressManagerDelegate>
/*! The P2P manager that is using for sender side.*/
@property (nonatomic, strong) CTSenderP2PManager *p2pManager;
/*! The Bonjour manager that is using for sender side.*/
@property (nonatomic, strong) CTSenderBonjourManager *bonjourManager;
/*! Local param indicate the pairing type: P2P or Bonjour*/
@property (nonatomic, strong) NSString *pairing_Type;
/*! Current stage of transfer.*/
@property (nonatomic, assign) enum state_machine transfer_state;
/*! Current transfer status.*/
@property (nonatomic, assign) enum CTTransferStatus transferStatusAnalytics;
/*!The file detail list when transfer finished, no matter interrupted or finished.*/
@property (nonatomic, strong) NSArray *dataInterruptedList;
/*! Parameter to store the old transfer type before analysis new request.*/
@property (nonatomic, assign) enum state_machine oldState;
/*! Parameter to show current transfer type.*/
@property (nonatomic, assign) enum state_machine nextState;
/*! Delegate property for CTSenderProgressManagerDelegate.*/
@property (nonatomic, weak) id<CTSenderProgressManagerDelegate> receiverProgressManagerDelegate;

/*! Number of data type.*/
@property (nonatomic, assign) NSInteger numberOfContacts;
/*! Number of data type.*/
@property (nonatomic, assign) NSInteger numberOfCalendars;
/*! Number of data type.*/
@property (nonatomic, assign) NSInteger numberOfReminders;
/*! Number of data type.*/
@property (nonatomic, assign) NSInteger numberOfPhotos;
/*! Number of photo successfully transferred.*/
@property (nonatomic, assign) NSInteger numberOfPhotoSuccess;
/*! Number of data type.*/
@property (nonatomic, assign) NSInteger numberOfVideos;
/*! Number of data type.*/
@property (nonatomic, assign) NSInteger numberOfAudios;
/*! Number of audio successfully transferred.*/
@property (nonatomic, assign) NSInteger numberOfAudioSuccess;

/*! Size of audio failed to transferred.*/
@property (nonatomic, assign) long long totalFailureSize;

/*!
    @brief Sender prgress manager class initializer.
    @param fileList File list used for transfer.
    @param socket Regular socket used for P2P connection. Can be nil if it's Bonjour.
    @param commSocket Commport socket used for P2P connection. Can be nil if it's Bonjour.
    @param photoManager Manager class used to fetch photos.
    @param videoManager Manager class used to fetch videos.
    @param delegate Delegate class for CTSenderProgressManagerDelegate.
    @return Progress manager object.
    @see CTSenderProgressManagerDelegate
 */
- (instancetype)initWithFileList:(CTFileList *)fileList andSocket:(GCDAsyncSocket *)socket commSocket:(CTCommPortClientSocket *)commSocket andPhotoManager:(CTPhotosManager *)photoManager andVideoManager:(CTPhotosManager *)videoManager andDelegate:(id<CTSenderProgressManagerDelegate>)delegate;

/*!
    @brief Set P2P manager for sender side.
    @param socket Regular socket for P2P connection.
    @param commSocket Commport socket for P2P connection.
 */
- (void)setreadAsyncSocket:(GCDAsyncSocket *)socket andCommSocket:(CTCommPortClientSocket *)commSocket;
/*!
    @brief      Method to cancel the transfer on sender side.
    @discussion This Method will send "VZTRANSFER_CANCEL" to the other side to inform this side cancellation.
    @param cancelMode enum type represent the cancel type.
 */
- (void)cancelTransfer:(CTTransferCancelMode)cancelMode;
/*! 
    @brief Update the result of transfer on sender side for recap and analytics.
 */
- (void)updateDataInterruptedList;
/*!
    @brief      Method to send necessary inform message when use clicked MVM navigation bar button.
    @discussion Once user clicked button on MVM navigation bar, no matter what button they clicked, after user confirmed from prompt, this method will be called to inform other side that this side cancelled.
    
                This method will only get called in MVM framework build. When @code STORE_BUILD == 1 @endcode
                The way that sending message will based on the way that connection established.
 */
- (void)mvmCancelTransfer;

@end

