//
//  CTStartupViewController.h
//  contenttransfer
//
//  Created by Development on 8/11/16.
//  Copyright © 2016 Verizon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

/*!First controller for content transfer without UI. This controller will setup beacon and other necessary service and push the first UI page.*/
@interface CTStartupViewController : UIViewController
/*!Beacon region for store beacon use.*/
@property (strong, nonatomic) CLBeaconRegion *myBeaconRegion;
/*!Location service to detect whether user is using content transfer in store and which store they are in.*/
@property (strong, nonatomic) CLLocationManager *locationManager;

@end
