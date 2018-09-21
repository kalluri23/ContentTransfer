//
//  CTDataCollectionManager.h
//  contenttransfer
//
//  Created by Hadapad, Prakash on 12/6/16.
//  Copyright © 2016 Verizon Wireless Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CTPhotosManager.h"
#import "CTAudiosManager.h"

/*! 
    @brief Delegate for data collection manager object to update the status of selection.
    @discussion Every methods in this delegate are mandentory.
 */
@protocol updatePhotoAndVideoNumbersDelegate <NSObject>

-(void)updatePhotoCountFromDataCollectionManager:(NSInteger)count;
-(void)updateVideosCountFromDataCollectionManager:(NSInteger)count;
-(void)updateCalendarCountFromDataCollectionManager:(NSInteger)count;
/*! Delegate method called after photo selection completed.*/
-(void)photoFetchingIsCompleted;
/*! Delegate method called after video selection completed.*/
-(void)videoFetchingIsCompleted;
/*! Delegate method called after contact selection completed.*/
-(void)contactFetchingIsCompleted;
/*! Delegate method called after reminder selection completed.*/
-(void)remindersFetchingIsCompleted;
/*! Delegate method called after calendar selection completed.*/
-(void)calendarsFetchingIsCompleted;
/*! Delegate method called after audio selection completed.*/
-(void)audioFetchingIsCompleted;

@end

/*!
    @brief Object to manage the data collection process. Every collect logic should be called through this class. 
    @discussion This is a singlton class.
 */
@interface CTDataCollectionManager : NSObject
/*!
    @brief Singlton initializer.
 */
+ (CTDataCollectionManager *)sharedManager;

/*! Get number of contacts saved in device.*/
-(NSInteger)getNumberOfContacts;
/*! Get number of calendar events saved in device.*/
-(NSInteger)getNumberOfCalendars;
/*! Get number of reminder lists saved in device.*/
-(NSInteger)getNumberOfReminders;
/*! Get number of photos saved in device.*/
-(NSInteger)getNumbersOfPhotos;
/*! Get number of videos saved in device.*/
-(NSInteger)getNumbersOfVideos;
/*! Get number of photos saved in cloud.*/
-(NSInteger)getNumberOfStreamPhotosCount;
/*! Get number of photos have error during the collection.*/
-(NSInteger)getNumberOfUnavailableCountPhotosCount;
/*! Get number of videos saved in cloud.*/
-(NSInteger)getNumberOfStreamVideosCount;
/*! Get number of videos have error during the collection.*/
-(NSInteger)getNumberOfUnavailableCountVideosCount;
/*! Get number of audios saved in device. Only use this when process finished.*/
-(NSInteger)getNumberOfAudios;

/*! Get the size of contact vcf file*/
-(NSInteger)getSizeOfContacts;
/*! Get the size of calendar ics files*/
-(NSInteger)getSizeOfCalendars;
/*! Get the size of reminder files*/
-(NSInteger)getSizeOfReminders;
/*! Get the size of photos*/
-(long long)getSizeOfPhotos;
/*! Get the size of videos*/
-(long long)getSizeOfVideos;
/*! Get the size of audios. Only use this when process finished.*/
-(long long)getSizeOfAudio;

/*! Check if contact operation is cancelled. */
-(BOOL)isContactFetchingOperationCancelled;
/*! Check if calendar operation is cancelled. */
-(BOOL)isCalendarsFetchingOperationCancelled;
/*! Check if reminder operation is cancelled. */
-(BOOL)isRemindersFetchingOperationCancelled;
/*! Check if photo operation is cancelled. */
-(BOOL)isPhotosFetchingOperationCancelled;
/*! Check if video operation is cancelled. */
-(BOOL)isVideosFetchingOperationCancelled;
/*! Check if audio operation is cancelled. */
-(BOOL)isAudioFetchingOperationCancelled;

/*! Indicate photo process is done.*/
@property(nonatomic,assign) BOOL isCollectingPhotoCompleted;
/*! Indicate video process is done.*/
@property(nonatomic,assign) BOOL isCollectingVideoCompleted;
/*! Indicate reminder process is done.*/
@property(nonatomic,assign) BOOL isCollectingReminderCompleted;
/*! Indicate calendar process is done.*/
@property(nonatomic,assign) BOOL isCollectingCalendarsCompleted;
/*! Indicate audio process is done.*/
@property(nonatomic,assign) BOOL isCollectingAudiosCompleted;
/*! Indicate contact process is done.*/
@property(nonatomic,assign) BOOL isCollectingContactsCompleted;
/*! 
    @brief updatePhotoAndVideoNumbersDelegate property
    @see updatePhotoAndVideoNumbersDelegate
 */
@property(nonatomic,weak) id<updatePhotoAndVideoNumbersDelegate> delegate;
/*!List of item that selected by user.*/
@property(nonatomic,strong) NSMutableDictionary *selectedItems;
/*! Manager class for fetching photos and videos. */
@property(nonatomic,strong) CTPhotosManager *photoManager;
/*! Manager class for fetching audios.*/
@property(nonatomic,strong) CTAudiosManager *audioManager;
/*!Bool value indicate is there any undownloadable media data in "All Photo" or not.*/
@property(nonatomic,assign) BOOL isAllPhotos;
/*!Bool value indicate is there any undownloadable media data in "All Photo" or not.*/
@property(nonatomic,assign) BOOL isAllPhotoVideo;

/*!
 Initialize photo manager for collection manager to collecting media.
 */
-(void)initPhotoManagerToCollectData;
/*!
    @brief Start collect all the data type that user can transfer to other device;
    @discussion This method will start fetch process in the background thread. Every type of data will run asynchronisly.
 */
-(void)startCollectAllData;
/*!
    @brief Stop all the collection process.
    @disscussion This method will set operation for each of the type of data to cancel process.
                 Fetch logic should capture this cancel process and cancel flag, and cancel the pandding fetching process.
 */
- (void)stopCollectAllData;
/*!
    @brief Try to stop all the collection process.
    @see - (void)stopCollectAllData
 */
- (void)stopCollectDataForExit;
/*! Stop cotact data collection process.*/
- (void)stopContactDataCollectionTask;
/*! Stop calendar data collection process.*/
- (void)stopCalendarDataCollectionTask;
/*! Stop reminder data collection process.*/
- (void)stopReminderDataCollectionTask;
/*! Stop photo data collection process.*/
- (void)stopPhotoDataCollectionTask;
/*! Stop video data collection process.*/
- (void)stopVideoDataCollectionTask;
/*! Stop audio data collection process.*/
- (void)stopAudioDataCollectionTask;

@end
