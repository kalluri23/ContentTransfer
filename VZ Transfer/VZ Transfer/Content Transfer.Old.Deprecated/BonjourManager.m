//
//  BonjourManager.m
//  VZTransferSocket
//
//  Created by Sun, Xin on 2/1/16.
//  Copyright © 2016 Testing. All rights reserved.
//
//
//  Create a manager object to mamage the all the methods relate to Bonjour Service
//  Note: Manager is a singleton object
//

#import "BonjourManager.h"
#import "VZBumpActionReceiver.h"
#import "VZBumpActionSender.h"

#import "CTBonjourSenderViewController.h"
#import "CTBonjourReceiverViewController.h"

// Shared instance for boujour manager
static BonjourManager *managerSharedInstance = nil;

@interface BonjourManager()

@property (nonatomic, strong, readwrite) NSNetService *server;
@property (nonatomic, strong, readwrite) NSMutableArray *services; // connected devices array
@property (nonatomic, strong, readwrite) NSNetServiceBrowser *browser; // this device browser
@property (nonatomic, strong) NSString *serviceIdentifier;
@property (nonatomic, strong) NSString *serviceDisplayName;

@end

@implementation BonjourManager

#define LOCAL @"local." // service domain
#define kBonjourType @"_vztransfer._tcp." // service type


- (NSMutableArray *)services {
    if (_services == nil) {
        _services = [[NSMutableArray alloc] init];
    }
    
    return _services;
}

+ (instancetype)sharedInstance {
    
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        managerSharedInstance = [[BonjourManager alloc] init];
    });
    
    return managerSharedInstance;
}

#pragma mark - Service Helpers
// Create local server for Bonjour service
- (void)createServerForController:(nullable id)controller {
    if (self.isServerStarted) {
        [self stopServer];
        self.server = nil;
        self.serviceIdentifier = nil;
        self.serviceDisplayName = nil;
    }
    
    // create and advertise service our kBonjourType on "local network"
    self.serviceDisplayName = [UIDevice currentDevice].name;
    self.serviceIdentifier = [NSString stringWithFormat:@"%@/%@",self.serviceDisplayName,[[[[UIDevice currentDevice] identifierForVendor] UUIDString] substringToIndex:8]];
    self.server = [[NSNetService alloc] initWithDomain:LOCAL type:kBonjourType name:self.serviceIdentifier port:0];
    
    // support peer to peer connections
    self.server.includesPeerToPeer = YES;
    
    // act as delegate
    [self.server setDelegate:controller];
    
    // start listen for other devices
    [self.server publishWithOptions:NSNetServiceListenForConnections];
    self.isServerStarted = YES;
    
    // setup and display device browser
    [self setupStream];
}

// Publish server
- (void)_publish {
    // If our server is deregistered then reregister it
    if (!self.isServerStarted) {
        // Have net services establish the socket connection (it uses cfscocketcreate)
        [self.server publishWithOptions:NSNetServiceListenForConnections];
        self.isServerStarted = YES;
    }
}

// Create local server for Bonjour service reconnect
- (BOOL)createReconnectServerForController:(nullable id)controller {
    
    if ([[_serviceIdentifier substringFromIndex:_serviceIdentifier.length-3] isEqualToString:@"/RC"]) {
        [self _publish];
        
        return self.isServerStarted;
    }
    
    // create and advertise service our kBonjourType on "local network"
    _serviceIdentifier = [NSString stringWithFormat:@"%@/%@/RC",_serviceDisplayName,[[[[UIDevice currentDevice] identifierForVendor] UUIDString] substringToIndex:8]];
    
    self.server = [[NSNetService alloc] initWithDomain:LOCAL type:kBonjourType name:_serviceIdentifier port:0];
    
    // support peer to peer connections
    self.server.includesPeerToPeer = YES;
    
    // act as delegate
    [self.server setDelegate:controller];
    
    // start listen for other devices
    [self.server publishWithOptions:NSNetServiceListenForConnections];
    self.isServerStarted = YES;
    
    return self.isServerStarted;
}

- (void)setServerDelegate:(id)controller {
    
    // should either have both or neither
    @try {
        NSAssert((self.inputStream != nil) == (self.outputStream != nil), @"Error: One of the stream is empty."); // No catched exception, fail and app will crash
    } @catch (NSException *exception) {
        DebugLog(@"something wrong:%@", exception.description);
        return;
    }
    
    if (!self.inputStream) {
        // empty stream
        return;
    }
    
//    if (self.inputStream != nil) {
//        // Shut down input
//        [self.inputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
//        //[self.inputStream close];
//        
//        // Shut down output
//        [self.outputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
//        //[self.outputStream close];
//    }
    
    // open input
    [self.inputStream setDelegate:controller];
//    [self.inputStream  scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    
    // open output
    [self.outputStream setDelegate:controller];
//    [self.outputStream scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
}

// Start our server
- (void)startServerForController:(id)controller
{
    if (controller != nil) { // make sure service won't publish multiple times once app comes back from background
        // start server
        [self.server publishWithOptions:NSNetServiceListenForConnections];
        self.isServerStarted = YES;
    }
}

- (NSString *)getServerName {
    return self.serviceDisplayName;
}

- (BOOL)serviceIsLocalService:(NSNetService *)service
{
    if ((self.server == nil) || (![self.server isEqual:service] && ![service.name isEqualToString:self.serviceIdentifier])) {
        if ([[service.name substringFromIndex:service.name.length-3] isEqualToString:@"/RC"]) {
            return NO;
        }
        return YES;
    } else {
        return NO;
    }
}

- (void)addService:(NSNetService *)server
{
    [self.services addObject:server];
}

- (void)removeService:(NSNetService *)server
{
    [self.services removeObject:server];
}

- (void)clearServices {
    [self.services removeAllObjects];
}

- (NSInteger)serviceIndex:(NSNetService *)server
{
    return [self.services indexOfObject:server];
}

- (void)sortService {
    // Sort the services by name
    [self.services sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [[obj1 name] localizedCaseInsensitiveCompare:[obj2 name]];
    }];
}

- (NSInteger)serviceNumber {
    // Return number of service currently found
    return self.services.count;
}

- (NSNetService *)getServiceAt:(NSInteger)idx
{
    if (idx < self.services.count) {
        return [self.services objectAtIndex:idx];
    } else {
        return nil;
    }
}

- (void)stopServer {
    if (self.isServerStarted) {
        @try {
            [self.server stop];
        } @catch (NSException *exception) {
            DebugLog(@"error when stop server:%@", exception.description);
        }
    }
    
    self.isServerStarted = NO;
}

- (void)seachingForService:(NSString *)target InListWithHandler:(matchingHandler)matchingHandler
{
    //    DebugLog(@"Target NumberID:%@", target);
    
    NSMutableArray *resultArray = [[NSMutableArray alloc] init];
    for (NSNetService *service in self.services) {
        if ([self getNumberIDForPeer:service.name] == [target integerValue]) {
            [resultArray addObject:service];
        }
    }
    
    matchingHandler(resultArray.count > 0, resultArray.count, resultArray);
}

// Helper function: help turn the long string into numbers
- (int)getNumberIDForPeer:(NSString *)name
{
    int numberID = 0;
    for (int i=0; i<name.length; i++) {
        numberID += (int)[name characterAtIndex:i];
    }
    
    return numberID;
}

#pragma mark - Network stream

// Setup new stream connection
- (void)setupStream {
    // if there is a connection, shut it down
    [self closeStreams];
    
    // if our server is deregistered then reregister it
    if (!self.isServerStarted) {
        // have net services establish the socket connection (it uses cfscocketcreate)
        [self.server publishWithOptions:NSNetServiceListenForConnections];
        self.isServerStarted = YES;
    }
}

// Close streams
- (void)closeStreams {
    // Should either have both or neither
    @try {
        NSAssert((self.inputStream != nil) == (self.outputStream != nil), @"Error: One of the stream is empty."); // No catched exception, fail and app will crash
    } @catch (NSException *exception) {
        DebugLog(@"something wrong:%@", exception.description);
    }
    
    if (self.inputStream != nil) { // If input/output stream exists
        // Shut down input
        [self.inputStream close];
//        [self.inputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        self.inputStream = nil;
        
        // Shut down output
        [self.outputStream close];
//        [self.outputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        self.outputStream = nil;
    }
    
    // Clear stream count
    self.streamOpenCount = 0;
}

// Open streams
- (void)openStreamsForController:(id)controller withHandler:(nullable OpenStreamHandler)handler
{
    // streams must exist but aren't open
    @try {
        NSAssert(self.inputStream != nil, @"Error: Input stream is empty.");
        NSAssert(self.outputStream != nil, @"Error: Output stream is empty.");
    } @catch (NSException *exception) {
        DebugLog(@"something wrong:%@", exception.description);
        return;
    }
    
    if (self.streamOpenCount > 0) {
        self.streamOpenCount = 0; // Reset to 0 for further use
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        // open input
        [self.inputStream  setDelegate:controller];
        [self.inputStream  scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        [self.inputStream  open];
        
        // open output
        [self.outputStream setDelegate:controller];
        [self.outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        [self.outputStream open];
        
        // run block to create heart beat for connection
        if (handler != nil) {
            handler();
        }
    });
}

// Send message (NSData) on stream
- (BOOL)sendStream:(NSData *)message
{
    if (self.streamOpenCount != 2) {
        // Input and output streams do not exist, so cancel this send
        return NO;
    }
    
    // Get pointer to NSData bytes
    const uint8_t *bytes = (const uint8_t*)[message bytes];
    NSUInteger len = (NSUInteger)[message length];
    
    // Only write to the stream if it has space available, otherwise we might block UI
    // (in a real app you have to handle this case properly)
    if ([self.outputStream hasSpaceAvailable]) {
        NSInteger bytesWritten = [self.outputStream write:bytes maxLength:len];
        DebugLog(@"message sent:%ld", (long)bytesWritten);
        return YES;
    } else {
        return NO;
    }
}


- (void)sendFileStream:(NSData *)message {
    
    int startIndex = 0;
    
    int bufferSize = 1024;
    
    while (startIndex < (int)message.length) {
        
        if((startIndex + 1024)>(int)message.length) {
            bufferSize = (int)message.length - startIndex;
        } else {
            bufferSize = 1024;
        }
        
        if ([self.outputStream hasSpaceAvailable] ) {
            
            NSData *packet = [message subdataWithRange:NSMakeRange((NSUInteger)startIndex, (NSUInteger)bufferSize)];
            
            uint8_t *bytes1 = (uint8_t*)[packet bytes];
            NSInteger  bytesWritten;
            bytesWritten = [self.outputStream write:bytes1 maxLength:(NSUInteger)bufferSize];
            
            if (bytesWritten > 0) {
                startIndex +=bytesWritten;
            }
        }
    }
}

// Close stream connection
- (void)closeStreamForController:(id)controller
{
    // shut down stream
    if (self.inputStream) {
        [self setupStream];
    }
    
    // shut down server
    if (self.isServerStarted) {
        [self.server stop];
        self.isServerStarted = NO;
    }
    
    if ([controller isKindOfClass:[CTBonjourSenderViewController class]]) {
        CTBonjourSenderViewController *target = (CTBonjourSenderViewController *)controller;
        
        // Only refresh tableview in sender controller
        [self stopBrowserNetworking:target];
    }
}

#pragma mark - Networking browser
- (void)startBrowserNetworkingForTarget:(id)controller {
    if (self.services.count > 0) {
        [self.services removeAllObjects];
    }
    
    if (self.browser != nil) {
        [self stopBrowserNetworking:controller];
    }
    
    self.browser = [[NSNetServiceBrowser alloc] init];
    self.browser.includesPeerToPeer = YES;
    [self.browser setDelegate:controller];
    [self.browser searchForServicesOfType:kBonjourType inDomain:LOCAL];
}

- (void)stopBrowserNetworking:(id)sender
{
    [self.browser stop];
    self.browser = nil;
    
    if ([sender isKindOfClass:[CTBonjourSenderViewController class]] && ((CTBonjourSenderViewController *)sender).isViewLoaded) {
        
        UITableView *tableView = ((CTBonjourSenderViewController *)sender).devicesTableView;
        
        NSMutableArray *indics = [[NSMutableArray alloc] init];
        for(int i=0; i<self.services.count; i++)
        {
            [indics addObject:[NSIndexPath indexPathForRow:i inSection:0]];
        }
        [self.services removeAllObjects];
        
        @try {
            [tableView beginUpdates];
            [tableView deleteRowsAtIndexPaths:indics withRowAnimation:UITableViewRowAnimationTop];
            [tableView endUpdates];
        } @catch (NSException *exception) {
            [tableView reloadData];
        }
    } else {
        [self.services removeAllObjects];
    }
}

- (BOOL)isBrowserValid
{
    return self.browser != nil;
}

- (NSString *)getDispalyNameForService:(NSNetService *)service {
    NSArray *components = [service.name componentsSeparatedByString:@"/"];
    return (NSString *)[components objectAtIndex:0];
}

#pragma mark - FOR MVM BUILD DELEGATE
+ (void)closeStreamIfOpen:(id)lastViewController{
    
//    if ([lastViewController isKindOfClass:[VZBumpActionSender class]] || [lastViewController isKindOfClass:[VZBumpActionReceiver class]]) {
//        [[BonjourManager sharedInstance] closeStreamForController:lastViewController]; // close stream for sender or receiver only
//    }
    
    if ([lastViewController isKindOfClass:[CTBonjourSenderViewController class]] || [lastViewController isKindOfClass:[CTBonjourReceiverViewController class]]) {
        [[BonjourManager sharedInstance] closeStreamForController:lastViewController]; // close stream for sender or receiver only
    }
}

+ (void)startBonjourServerForController:(id)lastviewController {
    
    [[BonjourManager sharedInstance] startServerForController:lastviewController];
}

@end
