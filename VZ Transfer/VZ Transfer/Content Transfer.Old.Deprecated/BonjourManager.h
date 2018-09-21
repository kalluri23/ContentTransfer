//
//  BonjourManager.h
//  VZTransferSocket
//
//  Created by Sun, Xin on 2/1/16.
//  Copyright © 2016 Testing. All rights reserved.
//

#import <Foundation/Foundation.h>

// Block definitions
typedef void (^OpenStreamHandler)(void);
typedef void (^matchingHandler)(bool found, long count, id target);


@interface BonjourManager : NSObject

@property (nonatomic, assign, readwrite) BOOL isServerStarted;
@property (nonatomic, strong) NSInputStream *inputStream; // Input stream for Bonjour
@property (nonatomic, strong) NSOutputStream *outputStream; // Output stream for Bonjour
@property (nonatomic, assign, readwrite) NSUInteger streamOpenCount;

@property (nonatomic, strong, readwrite) NSNetService *targetServer;

// Init method for object
+ (instancetype)sharedInstance;

// Create our server for Bonjour service
- (void)createServerForController:(id)controller;
- (BOOL)createReconnectServerForController:(id)controller;
- (void)stopServer; // stop server

// Start Browser
- (void)startBrowserNetworkingForTarget:(id)controller;

// Get the server name
- (NSString *)getServerName;

// Detect if given service is local service
- (BOOL)serviceIsLocalService:(NSNetService *)service;

// Service Array Contol
- (void)addService:(NSNetService *)server; // Add service
- (void)sortService; // Sort service by name
- (void)removeService:(NSNetService *)server; // Remove service
- (void)clearServices; // clear all the service stored previously
- (NSInteger)serviceNumber; // Get number of service currently found
- (NSInteger)serviceIndex:(NSNetService *)server; // Return index of service
- (NSNetService *)getServiceAt:(NSInteger)idx; // Get specified service based on index
- (void)startServerForController:(id)controller; // Start server for controller
- (void)seachingForService:(NSString *)target InListWithHandler:(matchingHandler)matchingHandler; // Search specific service

- (void)setupStream; // Setup stream
- (void)closeStreams;
- (void)openStreamsForController:(id)controller withHandler:(OpenStreamHandler)handler; // Open stream
- (BOOL)sendStream:(NSData *)message; // send data to stream
- (void)closeStreamForController:(id)controller; // close stream for controller

- (BOOL)isBrowserValid; // Check if browser is valid
- (void)stopBrowserNetworking:(id)sender; // Stop browser

// Added by Prakash
- (void)sendFileStream:(NSData *)message; // To transfer All kind of files
- (void)setServerDelegate:(id)controller;

- (NSString *)getDispalyNameForService:(NSNetService *)service;

// For MVM build
+ (void)closeStreamIfOpen:(id)lastViewController;
+ (void)startBonjourServerForController:(id)lastviewController;

@end
