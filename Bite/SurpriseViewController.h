//
//  SurpriseViewController.h
//  justforfun
//
//  Created by Evan Latner on 7/13/15.
//  Copyright (c) 2015 Bite. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>
#import "YPAPISample.h"
#import <MapKit/MapKit.h>

@interface SurpriseViewController : UIViewController <MKMapViewDelegate, UIScrollViewDelegate, UIGestureRecognizerDelegate>


@property (nonatomic, strong) NSString *dasString;
@property (nonatomic, strong) NSString *category;
@property (strong, nonatomic)  UILabel *categoryLabel;
@property (strong, nonatomic) UIImageView *categoryIcon;
@property (weak, nonatomic) IBOutlet UIImageView *venueImage;

@property (weak, nonatomic) IBOutlet UILabel *venueName;

@property (weak, nonatomic) IBOutlet UILabel *venueTeaser;
@property (weak, nonatomic) IBOutlet UILabel *venueDescription;

@property (nonatomic, strong) NSString *userCity;

@property (weak, nonatomic) IBOutlet UIView *bkgView;
@property (nonatomic, strong) NSString *phoneNumber;

@property (weak, nonatomic) IBOutlet UILabel *phoneNumberLabel;
@property (nonatomic, strong) UIButton *favButton;

@property (nonatomic, strong) UIButton *closeButton;

@property (weak, nonatomic) IBOutlet UIButton *nextButton;

@property (nonatomic, strong) PFObject *venue;
@property (weak, nonatomic) IBOutlet UIImageView *topFade;

@property (weak, nonatomic) IBOutlet UIImageView *bottomFade;
@property (nonatomic, strong) PFGeoPoint *currentLocation;
@property (nonatomic, strong) NSMutableArray *venues;
@property (nonatomic, strong) NSString *categoryId;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (weak, nonatomic) IBOutlet UIView *bottomView;

@property (weak, nonatomic) IBOutlet UIView *cardView;

@property (weak, nonatomic) IBOutlet UILabel *venueNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *venueDistanceLabel;
@property (weak, nonatomic) IBOutlet UIImageView *venueIconImage;
@property (nonatomic, strong) NSMutableArray *venueIconArray;

@property (nonatomic, strong) UIView *topView;

@property (weak, nonatomic) IBOutlet UIImageView *detailImageView;

@end
