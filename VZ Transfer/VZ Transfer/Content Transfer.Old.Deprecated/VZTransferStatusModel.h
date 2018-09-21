//
//  VZTransferStatusModel.h
//  VZTransferSocket
//
//  Created by Prakash Mac on 12/8/15.
//  Copyright © 2015 Testing. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GCDAsyncSocket.h"

typedef void (^updateTransferStatus)(NSString * transferStatus);

@interface VZTransferStatusModel : NSObject

@property(nonatomic,copy) updateTransferStatus callBackHandler;
@property(nonatomic,strong)GCDAsyncSocket *globalAsyncSocket;
@property(nonatomic,strong)GCDAsyncSocket *globallistenrSocket;

-(void)updateSenderViewController:(NSString *)statusMsg;
+(id) SharedSingletonInstance;

@end
