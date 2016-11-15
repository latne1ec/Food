//
//  VenueTableCell.h
//  justforfun
//
//  Created by Evan Latner on 7/12/15.
//  Copyright (c) 2015 Bite. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface VenueTableCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *venueName;
@property (weak, nonatomic) IBOutlet UIImageView *venueImage;
@property (weak, nonatomic) IBOutlet UILabel *venueTeaser;
@property (weak, nonatomic) IBOutlet UIView *venueBkg;
@property (weak, nonatomic) IBOutlet UIView *bkgView;
@property BOOL deployed;
@property (weak, nonatomic) IBOutlet UIButton *directionsButton;
@property (weak, nonatomic) IBOutlet UILabel *likeScoreLabel;

@property (weak, nonatomic) IBOutlet UIButton *photosButton;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
@property (weak, nonatomic) IBOutlet UIImageView *upArrow;
@property (weak, nonatomic) IBOutlet UILabel *imageCountLabel;
@property (weak, nonatomic) IBOutlet UIImageView *imageFade;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@end
