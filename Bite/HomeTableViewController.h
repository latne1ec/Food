//
//  HomeTableViewController.h
//  Bite
//
//  Created by Evan Latner on 7/10/15.
//  Copyright (c) 2015 Bite. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>
#import "CategoryTableCell.h"
#import "WelcomeViewController.h"
#import "SDWebImageManager.h"
#import "SurpriseViewController.h"
#import "AppDelegate.h"
#import "ListTableViewController.h"
#import "MapViewController.h"
#import "Venue.h"


@interface HomeTableViewController : UITableViewController <UIViewControllerTransitioningDelegate, UIAlertViewDelegate>

@property (nonatomic, strong) NSArray *venues;
@property (nonatomic, strong) PFGeoPoint *currentLocation;
@property (nonatomic, strong) NSString *userCity;
@property (nonatomic, strong) UIButton *favButton;
@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, strong) UIView *topView;

@end
