//
//  VZExtendNSLogFunctionality.h
//  VZTransferSocket
//
//  Created by Prakash Mac on 12/22/15.
//  Copyright © 2015 Testing. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VZExtendNSLogFunctionality : NSObject

@end

#ifdef DEBUG
#define NSLog(args...) ExtendNSLog(__FILE__,__LINE__,__PRETTY_FUNCTION__,args);
#else
#define NSLog(x...)
#endif

void ExtendNSLog(const char *file, int lineNumber, const char *functionName, NSString *format, ...);