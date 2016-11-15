//
//  WelcomeViewController.h
//  Bite
//
//  Created by Evan Latner on 7/10/15.
//  Copyright (c) 2015 Bite. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import <CoreLocation/CoreLocation.h>
#import "HomeTableViewController.h"


@interface WelcomeViewController : UIViewController <CLLocationManagerDelegate>

@property (weak, nonatomic) IBOutlet UIButton *okButton;
@property (nonatomic, strong) PFUser *user;
@property (nonatomic, strong) PFGeoPoint *currentLocation;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CLGeocoder *geocoder;

- (IBAction)okButtonTapped:(id)sender;

@end
