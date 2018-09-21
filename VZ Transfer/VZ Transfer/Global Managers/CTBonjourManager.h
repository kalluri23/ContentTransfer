//
//  BonjourManager.h
//  VZTransferSocket
//
//  Created by Sun, Xin on 2/1/16.
//  Copyright © 2016 Testing. All rights reserved.
//
/*!
    @header CTBonjourManager.h
    @discussion This is the header of bonjour manager.
 */
#import <Foundation/Foundation.h>

#pragma mark - Callbacks
/*!Callback when open a stream for controller.*/
typedef void (^OpenStreamHandler)(void);
/*!
 Callback when searching for available services.
 @return Bool value: YES if found; otherwise NO.
 @return long means how many service has been found.
 @return __strong id is Result array.
 */
typedef void (^matchingHandler)(bool found, long count, id target);

/*!
    @brief This class contains all the public methods that related to stream transfer using Bonjour.
    @discussion This is a singlton class, including all the properties and methods related to Bonjour transfer. But no delegate call and real sending logic inside.
 
                Use 
    @code [CTBonjourManager sharedInstance] @endcode
                to init the singlton object.
 */
@interface CTBonjourManager : NSObject
#pragma mark - Properties
/*!BOOL indicate service already started or not.*/
@property (nonatomic, assign, readwrite) BOOL isServerStarted;
/*!Input stream parameter for reading.*/
@property (nonatomic, strong) NSInputStream *inputStream;
/*!Ouput stream parameter for writing.*/
@property (nonatomic, strong) NSOutputStream *outputStream;
/*!Count of stream opened. This number should be always 2, one for input, one for output.*/
@property (nonatomic, assign, readwrite) NSUInteger streamOpenCount;
/*!Service object that need to be connected with.*/
@property (nonatomic, strong, readwrite) NSNetService *targetServer;

#pragma mark - Initializer
/*!
    @brief singlton init method for CTBonjourManager.
    @return A singlton object that represent CTBonjourManager class.
 */
+ (instancetype)sharedInstance;

#pragma mark - Instance methods
/*!
 Create server for current device in normal process.
 @param controller controller that set as @b NSNetServiceDelegate to handle the callbacks from CTBonjourManager.
 @see NSNetServiceDelegate
 */
- (void)createServerForController:(id<NSNetServiceDelegate>)controller;
/*!
 Create server for current device for reconnect process. This method will only be called when transfer failed in between.
 @param controller controller that set as @b NSNetServiceDelegate to handle the callbacks from CTBonjourManager.
 @return YES if reconnect server established; otherwise NO.
 @see NSNetServiceDelegate
 */
- (BOOL)createReconnectServerForController:(id)controller;
/*!Stop the Bonjour server.*/
- (void)stopServer;
/*!
 Start browser nearby services.
 @param controller controller that set as @b NSNetServiceBrowserDelegate to handle the callbacks from CTBonjourManager.
 @see NSNetServiceBrowserDelegate
 */
- (void)startBrowserNetworkingForTarget:(id<NSNetServiceBrowserDelegate>)controller;

/*!
 Get the name of server published for current device.
 @return NSString represents the server name.
 */
- (NSString *)getServerName;
/*!
 Get the identifier of server published for current device.
 @return NSString represents the server ID.
 */
- (NSString *)getServerIdentifier;

/*!
 Check target service is local service or not.
 @param service Service want to be checked.
 @return YES if target service is the one published by current device; otherwise NO.
 */
- (BOOL)serviceIsLocalService:(NSNetService *)service;

/*!
 Add service into service list.
 @param server Target service.
 */
- (void)addService:(NSNetService *)server;
/*!Sort service within service list in alphabetical decend.*/
- (void)sortService;
/*!
 Remove serivce from service list.
 @param server Target service.
 */
- (void)removeService:(NSNetService *)server;
/*!Clear the service list.*/
- (void)clearServices;
/*!
 Get total count of servier has been found.
 @return NSIntger represents the count.
 */
- (NSInteger)serviceNumber;
/*!
 Get index of given server from list.
 @param server Target service want to search.
 @return NSInteger represents the index of that service. If service doesn't exist, NSNotFound will be returned.
 */
- (NSInteger)serviceIndex:(NSNetService *)server;
/*!
 Get Service at given index.
 @param idx Index of the service list.
 @return If idx exists, return service saved in list; otherwise return nil.
 */
- (NSNetService *)getServiceAt:(NSInteger)idx;
/*!
 Start server for current device.
 @param controller Controller that initialiate this call.
 */
- (void)startServerForController:(id)controller;
/*!
 Search target service name in service list
 @param target Service name want to find
 @param matchingHandler Callback handler for the result of searching.
 @see matchingHandler
 */
- (void)seachingForService:(NSString *)target InListWithHandler:(matchingHandler)matchingHandler;
/*!Setup stream.*/
- (void)setupStream;
/*!Close streams*/
- (void)closeStreams;
/*!
 Open streams for Bonjour.
 @param controller controller set as NSStreamDelegate to handle stream callback.
 @param OpenStreamHandler Callback when open the stream.
 @see OpenStreamHandler
 @see NSStreamDelegate
 */
- (void)openStreamsForController:(id<NSStreamDelegate>)controller withHandler:(OpenStreamHandler)handler; // Open stream
/*!
    @brief        Method to send short data into the stream.
    @disscussion  Only use this method to send some string request, not real file. Big data need to seperate it into chunks and send them in loop use delegate method.
    @param        message NSData object contains all the data that need to be sent.
    @return       BOOL type value represent the result the sending process. YES when everything is done; NO when error happened or streams are currently occupied.
 */
- (BOOL)sendStream:(NSData *)message;
/*!
 Close stream for Bonjour.
 @param controller controller set as NSStreamDelegate to handle stream callback.
 */
- (void)closeStreamForController:(id)controller;
/*!
 Check if browser is valid or not.
 @return Yes if browser is in use; otherwise return No.
 */
- (BOOL)isBrowserValid;
/*!
 Stop browser for Bonjour.
 @param sender Object which triggered this call.
 */
- (void)stopBrowserNetworking:(id)sender;

/*!
    @brief Try to send file data through Bonjour stream.
    @param message NSData value represents the data that needs to be sent.
 */
- (void)sendFileStream:(NSData *)message;
/*!
 Set server delegate. Target must set as @b NSStreamDelegate.
 @param controller Controller want to be set as delegate.
 */
- (void)setServerDelegate:(id)controller;
/*!
 Get human readable name for service.
 @param service Target service.
 @return NSString represents the service's name.
 */
- (NSString *)getDispalyNameForService:(NSNetService *)service;

#pragma mark - Class methods
/*!
 Close the stream if open. This method is for appdelegate to close uncessary stream from last controller.
 @note This method is MVM use only.
 @warning This method has been @b deprecated.
 */
+ (void)closeStreamIfOpen:(id)lastViewController;
/*!
 Start bonjour service for controller.
 @note This method is MVM use only.
 @warning This method has been @b deprecated.
 */
+ (void)startBonjourServerForController:(id)lastviewController;

@end
