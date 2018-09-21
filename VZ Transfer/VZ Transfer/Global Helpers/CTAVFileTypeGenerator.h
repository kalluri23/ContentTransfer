//
//  CTAVFileTypeGenerator.h
//  contenttransfer
//
//  Created by Sun, Xin on 9/26/17.
//  Copyright © 2017 Verizon Wireless Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

/*!Generator the AVFoundation file for audio transfer.*/
@interface CTAVFileTypeGenerator : NSObject
/*!
 @brief Convenient function to get property AVFileType based on file path extension.
 @discussion All types of media(photos/videos) supported by device will be checking. If any file given which is not supported by device, will return nil.
 @param url NSURL related to file.
 @return AVFileType based on file type.
 */
+ (AVFileType)getProperAVFileTypeForFile:(NSURL *)url;

@end
