//
//  CTCalendarExport.h
//  contenttransfer
//
//  Created by Guntupalli, Neelima on 8/31/16.
//  Copyright © 2016 Verizon. All rights reserved.
//

#import <Foundation/Foundation.h>

/*!Export helper class for calendar events.*/
@interface CTCalendarExport : NSObject

/*!
 Fetch the calendar events and create the ics file on local file system.
 @param completionBlock Callback when success; @b countOfEvents, integer number represents the total count of calendar events; @b lengthOfData shows the total size of ics file.
 @param failureBlock Callback when failure, NSError in detail included.
 @param updateBlock Callback during the collection to update the count on UI.
 */
- (void)fetchCalendars:(void(^)(NSInteger countOfEvents,float lengthOfData))completionBlock
          failureBlock:(void(^)(NSError *err))failureBlock
           updateBlock:(void(^)(NSInteger calendarCount))updateBlock;

/*!
 Singlton initializer.
 @return CTCalendarExport object.
 */
+ (instancetype)calendarsExport;

@end
