//
//  CTProgressInfo.h
//  contenttransfer
//
//  Created by Mehta, Snehal Natwar on 9/12/16.
//  Copyright © 2016 Verizon Wireless. All rights reserved.
//
/*!
    @header CTProgressInfo.h
    @discussion This is the header of CTProgressInfo class.
 */
#import <Foundation/Foundation.h>

/*!
    @brief This is the class to update information during transfer. This class will contains all the information needed for progress view controller.
 */
@interface CTProgressInfo : NSObject
/*! Time left. NSString value with proper format.*/
@property (nonatomic, strong) NSString *timeLeft;
/*! Total data that already transferred. Data saved in NSNumber with long long value.*/
@property (nonatomic, strong) NSNumber *transferredAmount;
/*! Total data size without dupicate file size. Long long value in NSNumber.*/
@property (nonatomic, strong) NSNumber *acutalTransferredAmount;
/*! Speed value. NSNumber object with double value.*/
@property (nonatomic, strong) NSNumber *speed;
/*! Speed for average.*/
@property (nonatomic, strong) NSNumber *generalAvgSpeed;
/*! Media type for this information.*/
@property (nonatomic, strong) NSString *mediaType;
/*! Count that indicate how many file transferred. NSNumber with NSIntger value.*/
@property (nonatomic, strong) NSNumber *transferredCount;
/*! Total file count that need to be transferred.*/
@property (nonatomic, strong) NSNumber *totalFileCount;
/*! Total data that should be transferred. Data saved in NSNumber with long long value.*/
@property (nonatomic, strong) NSNumber *totalDataAmount;
/*! Total size of file need to be transferred for section. Only use on receiver side.*/
@property (nonatomic, strong) NSNumber *totalSectionSize;
/*! Total size of file transferred for section. Only use on receiver side.*/
@property (nonatomic, strong) NSNumber *totalSectionSizeTransferred;
/*! Bool value indicate this information is for duplicate transfer or not. Default value is NO unless assign value to it.*/
@property (nonatomic, assign) BOOL isDuplicate;
/*! Count of file failure for each of data type.*/
@property (nonatomic, strong) NSArray *transferFailureCounts;
/*! Size of file failure for each of data type.*/
@property (nonatomic, strong) NSArray *transferFailureSize;
/*! 
    @brief Prgress info initializer
    @param mediaType NSString value represents the type of the media.
    @return CTProgress object
 */
- (instancetype)initWithMediaType:(NSString *)mediaType;

@end
