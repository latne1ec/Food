//
//  WelcomeViewController.m
//  Bite
//
//  Created by Evan Latner on 7/10/15.
//  Copyright (c) 2015 Bite. All rights reserved.
//

#import "WelcomeViewController.h"

@interface WelcomeViewController ()

@end

@implementation WelcomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.locationManager = [[CLLocationManager alloc] init];
    
}

- (IBAction)okButtonTapped:(id)sender {
    
    [PFUser enableAutomaticUser];
    [[PFUser currentUser] incrementKey:@"RunCount"];
    [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (error) {
            
        }
        else {
            [self setupLocationRetrieval];
        }
    }];

}

-(void)setupLocationRetrieval {
    
    self.locationManager.delegate = self;
    [self.locationManager requestWhenInUseAuthorization];
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [self.locationManager startUpdatingLocation];
    [self getUserLocation];
}

-(void)getUserLocation {
    
    [PFGeoPoint geoPointForCurrentLocationInBackground:^(PFGeoPoint *geoPoint, NSError *error) {
        
        if (error) {
            NSLog(@"Error: %@", error);
        }
        else {
            
            [self.user setObject:geoPoint forKey:@"currentLocation"];
            [self.user saveInBackground];
            self.currentLocation = geoPoint;
            
            
            HomeTableViewController *hvc = [self.storyboard instantiateViewControllerWithIdentifier:@"Home"];
            hvc.currentLocation = self.currentLocation;
            
            [self.navigationController pushViewController:hvc animated:NO];
            
        }
    }];
}
@end
