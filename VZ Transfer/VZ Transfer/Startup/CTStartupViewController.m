//
//  CTStartupViewController.m
//  contenttransfer
//
//  Created by Development on 8/11/16.
//  Copyright © 2016 Verizon. All rights reserved.
//

#import "CTStartupViewController.h"
#import "CTStartedViewController.h"
#import "UIViewController+Convenience.h"
#import "CTStoryboardHelper.h"
#import "CTDeviceStatusUtility.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import "CTContentTransferSetting.h"
#import "CTBundle.h"
#import "AppDelegate.h"

#if STANDALONE == 0
#import <contentTransferFramework/contenttransfer-Swift.h>
#endif

@interface CTStartupViewController () <CLLocationManagerDelegate,CBCentralManagerDelegate>

@property(strong,nonatomic) CBCentralManager *bluetoothManager;

@end

static NSString *kUUIDToSearch = @"27BBB38E-3059-4396-8CAA-44FD175F5C06";

@implementation CTStartupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    NSTimeInterval timestamp = [[NSDate date] timeIntervalSince1970] * 1000;
    [CTUserDefaults sharedInstance].launchTimeStamp = [NSString stringWithFormat:@"%.0f",timestamp];
    
    [self showGetStartedScreen];
    
    // init blueooth manager, set power alert to NO so we do not ask user to enable bluetooth
    self.bluetoothManager = [[CBCentralManager alloc] initWithDelegate:self queue:dispatch_get_main_queue() options:@{CBCentralManagerOptionShowPowerAlertKey: @(NO)}];
    
    // Clear saved beacon information
    [CTUserDefaults sharedInstance].beaconUUID = @"";
    [CTUserDefaults sharedInstance].beaconMinor = @"";
    [CTUserDefaults sharedInstance].beaconMajor = @"";
    
    DebugLog(@"Testing DebugLog");
}

- (void)startListening {
    
    if (SYSTEM_VERSION_GREATER_THAN(@"8.0")) {
        
        self.locationManager = [[CLLocationManager alloc] init];
        
#if STANDALONE == 1
        
        if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
            [self.locationManager requestWhenInUseAuthorization];
        }
#endif
        
        NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:kUUIDToSearch];
        self.myBeaconRegion =
        [[CLBeaconRegion alloc] initWithProximityUUID:uuid identifier:@"VZWStore"];
        self.myBeaconRegion.notifyOnEntry = YES;
        self.myBeaconRegion.notifyOnExit = YES;
        self.myBeaconRegion.notifyEntryStateOnDisplay = YES;
        
        self.locationManager.delegate = self;
        
//        [self.locationManager startMonitoringForRegion:self.myBeaconRegion];
        [self.locationManager startRangingBeaconsInRegion:self.myBeaconRegion];
        [self.locationManager requestStateForRegion:self.myBeaconRegion];
        [self.locationManager startUpdatingLocation];
       
        if (![CLLocationManager isMonitoringAvailableForClass:[CLBeaconRegion class]]) {
            DebugLog(@"Unable to monitor beacon");
        }
    }
}

- (void)showGetStartedScreen {
    
    if (SYSTEM_VERSION_LESS_THAN(@"8.0")) {
        
        CTStartedViewController *getStartedViewController = [CTStartedViewController initialiseFromStoryboard:[CTStoryboardHelper devicesStoryboard]];
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:getStartedViewController];
        AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        appDelegate.window.rootViewController = navController;
    }else {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self performSegueWithIdentifier:NSStringFromClass([CTStartedViewController class]) sender:nil];
        });
    }
}

#pragma mark - CBCentralManagerDelegate
- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    
    if (central.state == CBCentralManagerStatePoweredOn) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            [self startListening];
        });
    }
}

#pragma CLLocationManager delegate
- (void)locationManager:(CLLocationManager *)manager
didStartMonitoringForRegion:(CLRegion *)region {
    DebugLog(@"didStartMonitoringForRegion");
    //debugAlert(@"didStartMonitoringForRegion");
    [self.locationManager requestStateForRegion:self.myBeaconRegion];
    
}

- (void)locationManager:(CLLocationManager *)manager
      didDetermineState:(CLRegionState)state
              forRegion:(CLRegion *)region {
    if (state == CLRegionStateInside){
        DebugLog(@"in region");
        //debugAlert(@"in region")
        [manager startRangingBeaconsInRegion:self.myBeaconRegion];
    }
}
- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region {
    //debugAlert(@"Entered Beacon Region");
    DebugLog(@"Entered Beacon Region");
    [self.locationManager startRangingBeaconsInRegion:(CLBeaconRegion *)region];
    
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region {
    [self.locationManager stopRangingBeaconsInRegion:self.myBeaconRegion];
    //debugAlert(@"Exited Beacon Region");
    DebugLog(@"Exited Beacon Region");
}

- (void)locationManager:(CLLocationManager *)manager
        didRangeBeacons:(NSArray *)beacons
               inRegion:(CLBeaconRegion *)region {
    CLBeacon *foundBeacon = [beacons firstObject];
    
    if (foundBeacon) {
        
        [CTUserDefaults sharedInstance].beaconUUID = kUUIDToSearch;
        [CTUserDefaults sharedInstance].beaconMinor = [NSString stringWithFormat:@"%@",foundBeacon.minor];
        [CTUserDefaults sharedInstance].beaconMajor = [NSString stringWithFormat:@"%@",foundBeacon.major];
        DebugLog(@"Beacon Found %@ %@ %@",[CTUserDefaults sharedInstance].beaconUUID,[CTUserDefaults sharedInstance].beaconMinor,[CTUserDefaults sharedInstance].beaconMajor);
//        debugAlert(@"Hiii");
        
        [self.locationManager stopRangingBeaconsInRegion:self.myBeaconRegion];
        [self.locationManager stopUpdatingLocation];
        
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
