//
//  VZSocketControllerViewController.m
//  VZTransferSocket
//
//  Created by VVM-MAC02 on 11/13/15.
//  Copyright © 2015 Testing. All rights reserved.
//

#import "VZSocketControllerViewController.h"
#import "NSString+CTContentTransferRootDocuments.h"

NSString *const GCD_ALWAYS_READ_QUEUE = @"com.cocoaasyncsocket.alwaysReadQueue";
#define TEXTTYPE 0
#define IMAGETYPE 10
#define VIDEOTYPE 20
#define CONTACTTYPE 30



@interface VZSocketControllerViewController ()

@end

@implementation VZSocketControllerViewController

@synthesize serverAddr;
@synthesize serverPort;
@synthesize bufOut;
@synthesize bufIn;
@synthesize tagType;
@synthesize receivedData;
@synthesize numOfPhotoReceived;
@synthesize file_size;
@synthesize Newdata;
@synthesize leftOverPacket;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    listenOnPort = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    NSError *error = nil;
    uint16_t port = 8988;
    
    if (![listenOnPort acceptOnPort:port error:&error]) {
        
        DebugLog(@"Yes i am able to listen on this port");
    } else {
        
        DebugLog(@"No i am not able to listen on this port");
    }
    
    socketEnable = FALSE;
    tagType = TEXTTYPE;
    startFlag = TRUE;
    endFlag = TRUE;
    file_size = -1;
    newImageFound = TRUE;
    leftOverPacket = [[NSData alloc] init];
    self.Newdata = [[NSMutableData alloc] init];
    
   asyncSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    // to export contacts
    
    VZContactsExport *vcardexport = [[VZContactsExport alloc] init];
    
//    [vcardexport exportContactsAsVcard];
    
    receivedData = [[NSMutableData alloc] init];
    
    numOfPhotoReceived = 0;
    
//    VZContactsImport *vCardImport = [[VZContactsImport alloc] init];
//    
//    [vCardImport importAllVcard];
//    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)performConnection:(id)sender {
//    DebugLog(@"PROVO...");
//    asyncSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    NSError *error = nil;
    uint16_t port = [[[self serverPort] text] intValue];
    
    if (![asyncSocket connectToHost:[serverAddr text] onPort:port error:&error])
    {
        DebugLog(@"Unable to connect to due to invalid configuration: %@", error);
        [self debugPrint:[NSString stringWithFormat:@"Unable to connect to due to invalid configuration: %@", error]];
    }
    else
    {
        DebugLog(@"Connecting...");
    }
    
    
    // To test
    
    [self readSocketRepeated];
    
    [self.view endEditing:YES];
    
    
}

- (void)readSocketRepeated {
    
    
//    dispatch_queue_t alwaysReadQueue = dispatch_queue_create([GCD_ALWAYS_READ_QUEUE UTF8String], NULL);
//    
//    dispatch_async(alwaysReadQueue, ^{
//        while(![asyncSocket isDisconnected]) {
//            [NSThread sleepForTimeInterval:5];
//            [asyncSocket readDataWithTimeout:-1 tag:tagType];
//        }
//    });
    
    socketEnable = TRUE;
}

- (IBAction)sendBuf:(id)sender {
    if ([[bufOut text] length] > 0) {
        NSString *requestStr = [bufOut text];
        
        NSData *requestData = [requestStr dataUsingEncoding:NSUTF8StringEncoding];
    
        NSMutableData *newdata = [[NSMutableData alloc] initWithData:requestData];
    
        [newdata appendData:[GCDAsyncSocket CRLFData]];
        
        [asyncSocket writeData:newdata withTimeout:-1 tag:0];
        
        [self debugPrint:[NSString stringWithFormat:@"Sent:  \n%@",requestStr]];
    }
    
    [self startRead];
    
    [self.view endEditing:YES];
}


- (IBAction)pickImagefromGallery:(id)sender {
    
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc]init];
    imagePickerController.delegate = self;
    imagePickerController.sourceType =  UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:imagePickerController animated:YES completion:nil];
}


- (void)imagePickerController:(UIImagePickerController *)picker
        didFinishPickingImage:(UIImage *)image
                  editingInfo:(NSDictionary *)editingInfo
{
    
    
    [picker dismissModalViewControllerAnimated:YES];
    
    tagType = IMAGETYPE;
    
    
    for (int i = 0; i < 1; i++) {
        
        NSData *imageData = UIImageJPEGRepresentation(image,0.0);
        
//        NSString *path = [[NSBundle mainBundle] pathForResource:@"decal_phone" ofType:@"png"];
//        NSData *imageData = [NSData dataWithContentsOfFile:path];
        
//        DebugLog(@"Sent Image size is %d",(int)imageData.length);
        
        
        NSString *requestStr = [[NSString alloc] initWithFormat:@"VZCONTENTTRANSFER_NEW_IMAGE_FILE_START"];
        
        
        NSMutableString *tempstr = [[NSMutableString alloc] initWithFormat:@"%d",(int)imageData.length];
        
//        DebugLog(@"file len %d", (int)tempstr.length);
        
        int gap = 10 - (int)tempstr.length;
        
        for (int i = 0; i < gap ; i++) {
            
            [tempstr insertString:@"0" atIndex:0];
        }
        
        [tempstr insertString:requestStr atIndex:0];
        
        NSData *requestData = [tempstr dataUsingEncoding:NSUTF8StringEncoding];
        
        NSMutableData *finaldata = [[NSMutableData alloc] init];
        
        [finaldata appendData:requestData];
        
        [finaldata appendData:imageData];
        
        [asyncSocket writeData:finaldata withTimeout: -1.0 tag:0];
    }
}

-(void)startRead {
    //[NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(startRead) userInfo:nil repeats:YES];
    [asyncSocket readDataWithTimeout:-1 tag:0];
    
}

- (void)debugPrint:(NSString *)text {
    [bufIn setText:text];
}

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port
{
    DebugLog(@"socket:didConnectToHost:%@ port:%hu", host, port);
    [self debugPrint:[NSString stringWithFormat:@"socket:didConnectToHost:%@ port:%hu", host, port]];
    
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag
{
    DebugLog(@"socket:didWriteDataWithTag: %d",tagType);
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    DebugLog(@"socket:didReadData:withTag:%ld",tag);
    
    if (data.length > 3) {
        
        self.Newdata = [[NSMutableData alloc] init];
        
        NSString *response = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        [self debugPrint:[NSString stringWithFormat:@"Read:  \n%@",response]];
//        DebugLog(@"NSdata to String3 : %@", response);
        
        if (leftOverPacket.length > 0) {
            
            [self.Newdata appendData:leftOverPacket];
            self.leftOverPacket = [[NSData alloc] init];
        }
        
        [self.Newdata appendData:data];
        
        if (newImageFound) {
            
            NSData *tempdata = [self.Newdata subdataWithRange:NSMakeRange(0, 48)];
            NSString *response1 = [[NSString alloc] initWithData:tempdata encoding:NSUTF8StringEncoding];
//            DebugLog(@"String from NSdata is %@",response1);
            
            if ([response1 containsString:@"VZCONTENTTRANSFER_NEW_IMAGE_FILE_START"]) {
                
                NSString *imageLen = [response1 substringFromIndex:38];
                
                file_size = imageLen.intValue;
                
                
                [receivedData appendData:[Newdata subdataWithRange:NSMakeRange(48, Newdata.length - 48)]];
                
                newImageFound = FALSE;
            }
            
        } else  {
            
            if ((receivedData.length + Newdata.length) < file_size){
                
                [receivedData appendData:Newdata];
            } else {
                
                NSData *lastpacketPortion  = [self.Newdata subdataWithRange:NSMakeRange(0, file_size - receivedData.length)];
                
                
                leftOverPacket = [self.Newdata subdataWithRange:NSMakeRange(file_size - receivedData.length, (Newdata.length - (file_size-receivedData.length)))];
                
                [receivedData appendData:lastpacketPortion];
                
                NSString *path = [[NSString appRootDocumentDirectory] stringByAppendingPathComponent:@"img.jpg"];
                
                [receivedData writeToFile:path atomically:YES];
                
                UIImage *newimage1 = [[UIImage alloc] initWithContentsOfFile:path];
                
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    
                    UIImageWriteToSavedPhotosAlbum(newimage1, nil, nil, nil);
                    
                });
                
                receivedData = [[NSMutableData alloc] init];
                
                newImageFound = TRUE;
            }
            
        }

    }
    
//    DebugLog(@"Data recevied from andriod %ld", data.length);
//    DebugLog(@"Total data received till now %ld",receivedData.length);
    
    [asyncSocket readDataWithTimeout:-1 tag:0];
}



- (void)socket:(GCDAsyncSocket *)sock didReadPartialDataOfLength:(NSUInteger)partialLength tag:(long)tag {
    
//    DebugLog(@"Partial data recevied is %ld", partialLength);
    
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
    DebugLog(@"socketDidDisconnect:withError: \"%@\"", err);
    [self debugPrint:[NSString stringWithFormat:@"socketDidDisconnect:withError: \"%@\"", err]];
}


-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.view endEditing:YES];
    return YES;
}

- (void)socket:(GCDAsyncSocket *)sock didAcceptNewSocket:(GCDAsyncSocket *)newSocket {

    asyncSocket = newSocket;
    asyncSocket.delegate = self;
    
    if (!socketEnable) {
        
        [self readSocketRepeated];
    }
    
    [self startRead];
}

- (IBAction)exportVcard:(id)sender {
    
    NSString *basePath = [NSString appRootDocumentDirectory];
    
    /*
     * We are assigning our filePath variable with our application's document path appended with our file's name.
     */
    NSData *data = [[NSFileManager defaultManager] contentsAtPath:[NSString stringWithFormat:@"%@/VZAllContactBackup.vcf",basePath]];
    
    [asyncSocket writeData:data withTimeout:-1.0 tag:20];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
