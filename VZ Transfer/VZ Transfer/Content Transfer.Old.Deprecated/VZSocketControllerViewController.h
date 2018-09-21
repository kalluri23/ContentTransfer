//
//  VZSocketControllerViewController.h
//  VZTransferSocket
//
//  Created by VVM-MAC02 on 11/13/15.
//  Copyright © 2015 Testing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GCDAsyncSocket.h"
#import "VZContactsExport.h"
#import "VZContactsImport.h"

extern NSString *const GCD_ALWAYS_READ_QUEUE;

@interface VZSocketControllerViewController : UIViewController <UITextFieldDelegate, UIImagePickerControllerDelegate,UINavigationControllerDelegate> {
    
    GCDAsyncSocket *asyncSocket;
    GCDAsyncSocket *listenOnPort;
    BOOL socketEnable;
    BOOL startFlag;
    BOOL endFlag;
    BOOL newImageFound;
   
}

@property (nonatomic, strong) IBOutlet UITextField *serverAddr;
@property (nonatomic, strong) IBOutlet UITextField *serverPort;
@property (nonatomic, strong) IBOutlet UITextField *bufOut;
@property (nonatomic, strong) IBOutlet UITextView *bufIn;
@property(nonatomic,assign) int tagType;
@property(nonatomic,strong) NSMutableData *receivedData;
@property(nonatomic,assign) int numOfPhotoReceived;
@property(nonatomic,assign) int file_size;
@property(nonatomic,strong) NSData *leftOverPacket;
@property(nonatomic,strong) NSMutableData *Newdata;

- (IBAction)performConnection:(id)sender;
- (IBAction)sendBuf:(id)sender;
- (IBAction)pickImagefromGallery:(id)sender;
- (void)debugPrint:(NSString *)text;
-(void)startRead;

@end
