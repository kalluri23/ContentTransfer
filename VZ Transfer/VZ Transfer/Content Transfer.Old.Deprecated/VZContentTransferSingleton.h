//
//  VZContentTransferSingleton.h
//  myverizon
//
//  Created by Tourani, Sanjay on 3/9/16.
//  Copyright © 2016 Verizon Wireless. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface VZContentTransferSingleton : NSObject



//To return shared instance

+ (instancetype)sharedGlobal;

//To Post Notification

-(void)registerWithMVM;

//Once Transfer is Done

-(void)deregisterWithMVM;



    
    

@end