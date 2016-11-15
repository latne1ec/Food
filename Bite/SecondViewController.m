//
//  SecondViewController.m
//  Example
//
//  Created by Jonathan Tribouharet
//

#import "SecondViewController.h"
#import "SDWebImageManager.h"
#import "UIImageView+WebCache.h"
#import "YPAPISample.h"
#import "UIImage+FiltrrCompositions.h"
#import "VenueView.h"

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#define kCLIENTID @"VPHBFYCGLAKRNZTCX2E2SUXQXQLZFVZ4JLWCRN5TCLFLW2CI"
#define kCLIENTSECRET @"MAJMGKNWIUNYHIBUGHSS2GSMMTV0M2T5T3LCTBYI0ZGOF22D"
#define kGOOGLE_API_KEY @"AIzaSyCJtSY62kZVP8VqRVPO0JbmwkeR7-IzM2I"

@interface SecondViewController () 

@property (nonatomic, strong) NSArray *venues;
@property int previousDeployedCellIndex;
@property int selectedIndex;
@property int deployedCellIndex;
@property(nonatomic) float w, h;
@property (nonatomic) int imageIndex;
@property (nonatomic) BOOL deployed;
@property (nonatomic) BOOL mapShowing;
@property (nonatomic, strong) UITapGestureRecognizer *tap;
@property (nonatomic, strong) UIActivityIndicatorView *indicator;

@property (nonatomic, strong) MKMapView *map;
@property (nonatomic, strong) VenueView *venueView;

@end

@implementation SecondViewController

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _deployed = false;
    _mapShowing = false;
    
    _deployedCellIndex = -1234;
    _selectedIndex = 0;
    _previousDeployedCellIndex = -12212;

    self.tableview.delaysContentTouches = false;
    
    [[self navigationController] setNavigationBarHidden:NO animated:YES];
    
    self.topView =[[UIView alloc] initWithFrame:CGRectMake(0, 0,[UIScreen mainScreen].bounds.size.width, 76)];
    self.topView.backgroundColor= [self colorWithHexString:self.dasString];
    self.topView.layer.shadowOpacity = 0.0;
    [UIView animateWithDuration:0.9 animations:^{
        self.topView.layer.shadowColor = [UIColor blackColor].CGColor;
        self.topView.layer.shadowOpacity = 0.34;
        self.topView.layer.shadowRadius = 0.15;
        self.topView.layer.shadowOffset = CGSizeMake(0.0f, 0.54f);
        
        self.categoryLabel.layer.shadowColor = [UIColor blackColor].CGColor;
        self.categoryLabel.layer.shadowOpacity = 0.2;
        self.categoryLabel.layer.shadowRadius = 0.15;
        self.categoryLabel.layer.shadowOffset = CGSizeMake(0.00f, 0.44f);
        
    } completion:^(BOOL finished) {
        
    }];
    
    self.categoryLabel.text = self.category;
    
    if ([UIScreen mainScreen].bounds.size.height <= 568.0) {
        self.categoryLabel.font = [UIFont fontWithName:@"Montserrat-Regular" size:24];
    } else {
    }

    [self.categoryLabel layoutIfNeeded];
    
    self.longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressBegan:)];
    self.longPress.delegate = (id)self;
    self.longPress.minimumPressDuration = 0.01;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scrollToTop)];
    tap.numberOfTapsRequired = 1;
    
    [self.topView addGestureRecognizer:tap];
    
    self.categoryIcon.image = self.icon;
    
    self.tableview.clipsToBounds = YES;
    
    [self.view addSubview:self.topView];
    [self.view addSubview:self.categoryLabel];
    [self.view addSubview:self.categoryIcon];
    
//    self.tableview.delegate = self;
//    self.tableview.dataSource = self;
//    self.tableview.tableFooterView = [UIView new];
//    
//    self.tableview.emptyDataSetSource = self;
//    self.tableview.emptyDataSetDelegate = self;
//    [self setNeedsStatusBarAppearanceUpdate];
//    self.tableview.backgroundColor = [UIColor whiteColor];
    
    [self.view setBackgroundColor: [self colorWithHexString:self.dasString]];
    
    [self createCloseButton];
    
    UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(didCloseButtonTouch)];
    swipe.direction = UISwipeGestureRecognizerDirectionDown;
    
    //[self.view addGestureRecognizer:swipe];
    //[self queryForVenues:self.category];
    
    //[self queryForVenues:self.category];
    
    //[self queryForDasVenues];
    [self queryUsingYelpYuck];
    //[self queryForGooglePlaceVenues];
    
    self.indicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    self.indicator.frame = CGRectMake(0.0, 0.0, 40.0, 40.0);
    self.indicator.center = self.view.center;
    [self.view addSubview:self.indicator];
    [self.indicator setHidden:NO];
    [self.indicator startAnimating];
    
    self.tableview.alpha = 0.0;
    

}

-(void)addMapAnnotations {
    
    NSMutableArray *array = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < self.venues.count; i++) {
        
        PFObject *object = [self.venues objectAtIndex:i];
        CLLocationDegrees lat = [[[[object objectForKey:@"location"] valueForKey:@"coordinate"] valueForKey:@"latitude"] doubleValue];
        CLLocationDegrees lon = [[[[object objectForKey:@"location"] valueForKey:@"coordinate"] valueForKey:@"longitude"] doubleValue];
        CLLocationCoordinate2D coordinates;
        coordinates.latitude = lat;
        coordinates.longitude = lon;
        
        CLLocationCoordinate2D userCoordinates;
        userCoordinates.latitude = self.currentLocation.latitude;
        userCoordinates.longitude = self.currentLocation.longitude;
        
        //NSString *venueName = [object objectForKey:@"name"];
        MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
        annotation.title = [object objectForKey:@"name"];
        annotation.subtitle = @"Directions - double tap 👆🏽👆🏽";
        [annotation setCoordinate:coordinates];
        [array addObject:annotation];
    }
    
    [self.map showAnnotations:array animated:YES];
    //[self.map selectAnnotation:[array objectAtIndex:0] animated:YES];
    PFObject *object = [self.venues objectAtIndex:0];
    [_venueView updateViewDetails:object];
}

-(void)scrollToTop {

    [self.tableview scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
}

-(void)viewWillAppear:(BOOL)animated {
    
    //[self performSelector:@selector(this) withObject:nil afterDelay:.2];

    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
//    self.tableview.alpha = 0.0f;
//    [UIView animateWithDuration:0.11 delay:0.25 options:0 animations:^{
//        self.tableview.alpha = 1.0;
//    } completion:^(BOOL finished) {
//        
//    }];
    
    self.map = [[MKMapView alloc] initWithFrame:CGRectMake(0, 76, self.view.frame.size.width, self.view.frame.size.height)];
    CLLocationCoordinate2D coordinates;
    coordinates.latitude = self.currentLocation.latitude;
    coordinates.longitude = self.currentLocation.longitude;
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(coordinates, 5*100, 5*100);
    region.span.longitudeDelta = 0.06f;
    region.span.latitudeDelta = 0.06f;
    [self.map setRegion:region animated:NO];
    self.map.showsUserLocation = YES;
    self.map.opaque = true;
    self.map.alpha = 0.0;
    self.map.delegate = self;
    self.map.showsPointsOfInterest = false;
    self.map.showsBuildings = false;
    self.map.userInteractionEnabled = true;
    [self.view addSubview:self.map];
    [UIView animateWithDuration:0.12 delay:0.22 options:0 animations:^{
        self.map.alpha = 1.0;
    } completion:^(BOOL finished) {
        [self.view addSubview:self.map];
    //}];
    
    self.map.showsUserLocation = YES;

    
//    if (!_venueView){
//        
//            _venueView = [[VenueView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height-78, self.view.frame.size.width, self.view.frame.size.height-100)];
//            _venueView.colorString = self.dasString;
//        [_venueView layoutSubviews];
//            _venueView.frame = CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height-100);
//            [UIView animateWithDuration:0.165 delay:1.12 options:0 animations:^{
//                _venueView.frame = CGRectMake(0, self.view.frame.size.height-80.5, self.view.frame.size.width, self.view.frame.size.height-200);
//            } completion:^(BOOL finished) {
//                [UIView animateWithDuration:0.171 delay:0 options:0 animations:^{
//                    
//                    if([UIScreen mainScreen].bounds.size.height == 736) {
//                        NSLog(@"6 plus!!!");
//                        _venueView.frame = CGRectMake(0, self.view.frame.size.height-78, self.view.frame.size.width, self.view.frame.size.height-250);
//                    } else {
//                        _venueView.frame = CGRectMake(0, self.view.frame.size.height-78, self.view.frame.size.width, self.view.frame.size.height-200);
//                    }
//                    
//                } completion:^(BOOL finished) {
//                    
//                }];
//            }];
//        
//            [self.view addSubview:_venueView];
//        }
    }];
}

//-(void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
//    
//    MKPointAnnotation *annotation = (MKPointAnnotation *)view.annotation;
//    NSLog(@"%@", annotation.title);
//    NSString *tappedVenueName = annotation.title;
//    
//    PFObject *tappedVenue;
//    
//    for (PFObject *object in self.venues) {
//        NSString *venueName = [object objectForKey:@"name"];
//        if ([venueName isEqualToString:tappedVenueName]) {
//            tappedVenue = object;
//            _venueView.venue = nil;
//            _venueView.currentLocation = self.currentLocation;
//            _venueView.colorString = self.dasString;
//            [_venueView updateViewDetails:tappedVenue];        
//        }
//    }
//}

-(void)this {
    
    self.tableview.frame = CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height-40);
    self.tableview.alpha = 1.0;
    
    [[self.tableview superview] addSubview:self.tableview];
    
    [UIView animateWithDuration:0.4 animations:^{
        NSLog(@"Started");
        self.tableview.alpha = 1.0;
        self.tableview.frame = CGRectMake(0, 40, self.view.frame.size.width, self.view.frame.size.height-500);
        
    } completion:^(BOOL finished) {
        NSLog(@"FINISHED");
    }];
}

-(void)viewDidAppear:(BOOL)animated {
    
}

-(void)longPressBegan: (UILongPressGestureRecognizer *)recognizer {
    
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        
        [UIView animateWithDuration:0.11 delay:0.0 options:0 animations:^{
            
            self.topView.transform = CGAffineTransformMakeScale(1.058f, 1.058f);
            self.categoryIcon.transform = CGAffineTransformMakeScale(1.048f, 1.048f);
            self.categoryLabel.transform = CGAffineTransformMakeScale(1.038f, 1.038f);
            self.closeButton.transform = CGAffineTransformMakeScale(1.048f, 1.048f);
            
        } completion:^(BOOL finished) {
        }];
    }
    
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        
        [UIView animateWithDuration:0.12 delay:0.0 options:0 animations:^{
        } completion:^(BOOL finished) {
           [self didCloseButtonTouch];
        }];
    }
}

-(void)queryForVenues:(NSString *)category {
    
    PFQuery *query = [PFQuery queryWithClassName:@"Venues"];
    [query whereKey:@"venueCategory" equalTo:category];
    [query orderByAscending:@"venueName"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        if (error) {
         
            NSLog(@"Error: %@", error);
        }
        else {
            self.venues = objects;
            [self.tableview reloadData];
            NSLog(@"Objects: %lu", (unsigned long)objects.count);
        }
        
        if (objects.count == 0) {
        }
    }];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    VenueTableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    if (self.venues.count == 0) {
        self.tableview.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    else {
        
        self.tableview.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    }

    //cell.bkgView.layer.cornerRadius = 6;
    
    if ([UIScreen mainScreen].bounds.size.height <= 568.0) {
        cell.venueName.font = [UIFont fontWithName:@"Montserrat-Regular" size:16];
    } else {
        cell.venueName.font = [UIFont fontWithName:@"Montserrat-Regular" size:17];
    }
    
    if (_deployedCellIndex == indexPath.row) {
        cell.directionsButton.alpha = 0.880;
        //cell.likeScoreLabel.alpha = 1.0;
        cell.photosButton.alpha = 0.880;
        cell.scrollView.alpha = 1.0;
        cell.upArrow.alpha = 0.154;
    
    } else {
        cell.directionsButton.alpha = 0.0;
        cell.photosButton.alpha = 0.0;
        cell.scrollView.alpha = 0.0;
        cell.upArrow.alpha = 0.0;
        //cell.likeScoreLabel.alpha = 0.0;
    }
    
    cell.photosButton.backgroundColor= [self colorWithHexString:self.dasString];
    cell.directionsButton.backgroundColor= [self colorWithHexString:self.dasString];
    
    PFObject *object = [self.venues objectAtIndex:indexPath.row];
    cell.venueName.text = [object objectForKey:@"name"];
    cell.venueImage.layer.cornerRadius = cell.venueImage.frame.size.width/2;
    cell.venueImage.clipsToBounds = YES;
    NSString *ratingString = [object valueForKey:@"rating"];
    float score = [ratingString floatValue];
    float rating = score/5;
    float finalRating = rating*100;
    //cell.likeScoreLabel.text = [NSString stringWithFormat:@"%.f%% 👍🏼", finalRating];

    
    CLLocationDegrees lat = [[[[object objectForKey:@"location"] valueForKey:@"coordinate"] valueForKey:@"latitude"] doubleValue];
    CLLocationDegrees lon = [[[[object objectForKey:@"location"] valueForKey:@"coordinate"] valueForKey:@"longitude"] doubleValue];
    CLLocation *venueLocation = [[CLLocation alloc] initWithLatitude:lat longitude:lon];
    CLLocation *userLoca = [[CLLocation alloc] initWithLatitude:self.currentLocation.latitude longitude:self.currentLocation.longitude];
    
    CLLocationDistance distance = [userLoca distanceFromLocation:venueLocation];
    
    cell.venueTeaser.text = [NSString stringWithFormat:@"%.1f miles",(distance/1609.344)];
    
    
    if (self.venueIconArray.count == 0) {
    } else {
     
        if (self.venueIconArray.count-1 < indexPath.row) {
        } else {
            NSURL *url = [NSURL URLWithString:[self.venueIconArray objectAtIndex:indexPath.row]];
            //[cell.venueImage sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@""]];

            
            SDWebImageManager *manager = [SDWebImageManager sharedManager];
            [manager downloadImageWithURL:url
                                  options:0
                                 progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                                     // progression tracking code
                                 }
                                completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                                    if (image) {
                                        // do something with image
                                        image = [image e5];
                                        cell.venueImage.image = image;
                                    }
                                }];
        }
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    VenueTableCell *cell = (VenueTableCell *)[self.tableview cellForRowAtIndexPath:indexPath];
    _selectedIndex = (int)indexPath.row;
    
    if (_deployedCellIndex == indexPath.row) {
        self.tableview.scrollEnabled = true;
        _deployedCellIndex = -1;
        //_selectedIndex = -1;
        _deployed = false;
        [UIView animateWithDuration:0.165 animations:^{
            NSIndexPath* indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
            [self.tableview reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
            [self.tableview scrollToNearestSelectedRowAtScrollPosition:UITableViewScrollPositionMiddle animated:YES];
        }];
        
    } else {
        //self.tableview.scrollEnabled = false;
        _deployed = true;
        _deployedCellIndex = (int)indexPath.row;
        if (_deployedCellIndex == 0) {
            [UIView animateWithDuration:0.165 animations:^{
            
                NSIndexPath* indexPath = [NSIndexPath indexPathForRow:_previousDeployedCellIndex inSection:0];
                [self.tableview reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
                
                [self.tableview scrollToNearestSelectedRowAtScrollPosition:UITableViewScrollPositionTop animated:YES];
            }];
            
        } else {

            [UIView animateWithDuration:0.165 animations:^{
                
                NSIndexPath* indexPath = [NSIndexPath indexPathForRow:_previousDeployedCellIndex inSection:0];
                [self.tableview reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
                
                [self.tableview scrollToNearestSelectedRowAtScrollPosition:UITableViewScrollPositionTop animated:YES];
            }];
        }
        [self getVenuePhotos];
    }
    
    _previousDeployedCellIndex = _deployedCellIndex;
    
    if (_deployedCellIndex == indexPath.row) {
        [UIView animateWithDuration:0.14 delay:0.1 options:0 animations:^{
            cell.directionsButton.alpha = 0.880;
            cell.photosButton.alpha = 0.880;
            cell.scrollView.alpha = 1.0;
            cell.upArrow.alpha = 0.154;
            //cell.likeScoreLabel.alpha = 1.0;
            //cell.venueName.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:17.65];
            //cell.venueTeaser.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:11.65];
            
            if (cell.directionsButton.gestureRecognizers.count == 0) {
                UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(mapButtonPressed:)];
                longPress.minimumPressDuration = 0.05;
                [cell.directionsButton addGestureRecognizer:longPress];
            }
            if (cell.photosButton.gestureRecognizers.count == 0) {
                UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(photosButtonPressed:)];
                longPress.minimumPressDuration = 0.05;
                [cell.photosButton addGestureRecognizer:longPress];
            }


        } completion:^(BOOL finished) {
        }];

    } else {
        [UIView animateWithDuration:0.1 delay:0 options:0 animations:^{
            cell.directionsButton.alpha = 0.0;
            cell.photosButton.alpha = 0.0;
            cell.scrollView.alpha = 0.0;
            cell.upArrow.alpha = 0.0;
            //cell.likeScoreLabel.alpha = 0.0;
            
        } completion:^(BOOL finished) {
        }];
    }
    _mapShowing = false;
}

-(void)photosButtonPressed: (UIGestureRecognizer *)recognizer {
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:_deployedCellIndex inSection:0];
    VenueTableCell *cell = (VenueTableCell *)[self.tableview cellForRowAtIndexPath:indexPath];
    
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        
        [UIView animateWithDuration:0.10 animations:^{
            cell.photosButton.transform = CGAffineTransformMakeScale(.924, .924);
        } completion:^(BOOL finished) {
            
        }];
    }
    
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        
        [UIView animateWithDuration:0.1 animations:^{
            cell.photosButton.transform = CGAffineTransformMakeScale(1.0, 1.0);
        } completion:^(BOOL finished) {
            [self showPhotos];
        }];
    }
}

-(void)showPhotos {
    
    _mapShowing = false;
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:_deployedCellIndex inSection:0];
    VenueTableCell *cell = (VenueTableCell *)[self.tableview cellForRowAtIndexPath:indexPath];
    UIImageView *imageView = (UIImageView *)[cell.contentView viewWithTag:101];
    MKMapView *map = (MKMapView *)[cell.contentView viewWithTag:202];
    map.hidden = true;
    [map removeFromSuperview];
    [cell.scrollView addSubview:imageView];
    if (!_mapShowing) {
        [cell.scrollView bringSubviewToFront:imageView];
        [cell.scrollView bringSubviewToFront:cell.imageFade];
        [cell.scrollView bringSubviewToFront:cell.pageControl];
    }
    if (self.tap) {
        [cell.scrollView addGestureRecognizer:self.tap];
    }
}

-(void)getVenuePhotos {
    
    _imageIndex = 0;
    if (self.venueImagesArray.count > 0) {
        [self.venueImagesArray removeAllObjects];
    }
    self.venueImagesArray = nil;
    [self showSingleImage];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:_deployedCellIndex inSection:0];
    VenueTableCell *cell = (VenueTableCell *)[self.tableview cellForRowAtIndexPath:indexPath];
    
    NSDictionary *dic = [self.venues objectAtIndex:indexPath.row];
    
    float lat = [[[[dic objectForKey:@"location"] valueForKey:@"coordinate"] valueForKey:@"latitude"] floatValue];
    float lon = [[[[dic objectForKey:@"location"] valueForKey:@"coordinate"] valueForKey:@"longitude"] floatValue];
    
    NSString *firstWordOfVenue = [[cell.venueName.text componentsSeparatedByString:@" "] objectAtIndex:0];
    
    NSCharacterSet *invalidCharSet = [[NSCharacterSet characterSetWithCharactersInString:@"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"] invertedSet];
    NSString *filtered = [[firstWordOfVenue componentsSeparatedByCharactersInSet:invalidCharSet] componentsJoinedByString:@""];
    
    //NSLog(@"Filtered String: %@", filtered);
    
    // NSString *strippedString = [firstWordOfVenue stringByReplacingOccurrencesOfString:@"é" withString:@""];
    
    
    if (!lat || !lon || !firstWordOfVenue) {
        return;
    }
    
    NSString *googleUrl = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=%f,%f&radius=30&type=restaurant&keyword=%@&key=%@",lat, lon,filtered, kGOOGLE_API_KEY];
    
    NSURL *googleRequestURL=[NSURL URLWithString:googleUrl];
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSData* data = [NSData dataWithContentsOfURL: googleRequestURL];
        [self performSelectorOnMainThread:@selector(fetchedVenue:) withObject:data waitUntilDone:YES];
        
    });
}

-(void)fetchedVenue: (NSData *)responseData {
    
    NSError* error;
    NSDictionary* json = [NSJSONSerialization
                          JSONObjectWithData:responseData
                          
                          options:kNilOptions
                          error:&error];

    
    NSArray *array = [json valueForKey:@"results"];
    //NSLog(@"Status: %@", [json valueForKey:@"status"]);
    
    if (array.count > 0) {
        
        NSArray *placeIdArray = [array valueForKey:@"place_id"];
        NSArray *placeNameArray = [array valueForKey:@"name"];
        NSString *placeName = [placeNameArray objectAtIndex:0];
        NSString *placeId = [placeIdArray objectAtIndex:0];
        NSLog(@"%@ Id: %@", placeName, placeId);
        
//        BOOL open = [[[[array valueForKey:@"opening_hours"] valueForKey:@"open_now"] objectAtIndex:0] boolValue];
//        if (open) {
//            NSLog(@"open");
//        } else {
//            NSLog(@"closed");
//        }
        
        NSString *googleUrl = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/details/json?placeid=%@&key=%@",placeId, kGOOGLE_API_KEY];
        
        NSURL *googleRequestURL=[NSURL URLWithString:googleUrl];
        
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            NSData* data = [NSData dataWithContentsOfURL: googleRequestURL];
            [self performSelectorOnMainThread:@selector(fetchedPhotos:) withObject:data waitUntilDone:YES];
        });
    } else {
        //NSLog(@"Couldn't find a place :( %@", error.localizedDescription);
    }
}

-(void)showSingleImage {
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:_deployedCellIndex inSection:0];
    VenueTableCell *cell = (VenueTableCell *)[self.tableview cellForRowAtIndexPath:indexPath];
    
    _w = cell.scrollView.frame.size.width;
    _h = cell.scrollView.frame.size.height;
    
    cell.scrollView.contentSize = CGSizeMake(cell.scrollView.frame.size.width, cell.scrollView.frame.size.height);
    cell.scrollView.pagingEnabled = true;
    cell.scrollView.delegate = self;
    cell.scrollView.tag = 10;
    cell.scrollView.scrollEnabled = false;
    
    cell.scrollView.layer.cornerRadius = 6;
    
    cell.pageControl.numberOfPages = 1;
    //cell.pageControl.currentPage = 1;
    
    UIImageView *currentImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, _w, _h)];
    currentImageView.contentMode = UIViewContentModeScaleAspectFill;
    currentImageView.tag = 101;
    currentImageView.clipsToBounds = true;
    NSString *imageUrl = [self.venueIconArray objectAtIndex:indexPath.row];
    NSString *finalString = [imageUrl stringByReplacingOccurrencesOfString:@"ms" withString:@"o"];
    NSURL *finalUrl = [NSURL URLWithString:finalString];
    NSLog(@"final url: %@", finalUrl);
    
    currentImageView.image = cell.venueImage.image;
    
    SDWebImageManager *managerOne = [SDWebImageManager sharedManager];
    [managerOne downloadImageWithURL:finalUrl options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize) {
        
    }
                           completed:^(UIImage *images, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                               
                               if (finished) {
                                   [UIView animateWithDuration:1.2 animations:^{
                                       currentImageView.image = images;
                                       //currentImageView.image = [images e5];
                                   } completion:^(BOOL finished) {
                                       
                                   }];
                               }
                           }];
    //[currentImageView sd_setImageWithURL:finalUrl placeholderImage:[UIImage imageNamed:@""]];
    [cell.scrollView addSubview:currentImageView];
    [cell.scrollView bringSubviewToFront:cell.imageFade];
    cell.pageControl.alpha = 1.0;
    [cell.scrollView bringSubviewToFront:cell.pageControl];
}

-(void)fetchedPhotos: (NSData *)responseData {
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:_deployedCellIndex inSection:0];
    //VenueTableCell *cell = (VenueTableCell *)[self.tableview cellForRowAtIndexPath:indexPath];
    //NSLog(@"Index Path: %ld", (long)indexPath.row);
    
    self.venueImagesArray = [[NSMutableArray alloc] init];
    
    NSError* error;
    NSDictionary* json = [NSJSONSerialization
                          JSONObjectWithData:responseData
                          
                          options:kNilOptions
                          error:&error];
    NSArray *results = [json valueForKey:@"result"];
    NSArray *photos = [results valueForKey:@"photos"];
    NSArray *photoRefs = [photos valueForKey:@"photo_reference"];
    //NSLog(@"Hi: %ld", (long)indexPath.row);
    
    if (_deployedCellIndex == -1) {
        
    }
    
    //NSLog(@"made it tho: %@", [self.venueIconArray objectAtIndex:_selectedIndex]);
    NSString *imageUrl = [self.venueIconArray objectAtIndex:_selectedIndex];
    NSString *finalString = [imageUrl stringByReplacingOccurrencesOfString:@"ms" withString:@"o"];
    [self.venueImagesArray addObject:finalString];
    //NSLog(@"made it here");
    
    for (int i = 1; i < photoRefs.count; i++) {
        NSString *photoref = [photoRefs objectAtIndex:i];
        NSString *photoRefUrl = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/photo?maxwidth=640&photoreference=%@&key=%@", photoref,kGOOGLE_API_KEY];
        [self.venueImagesArray addObject:photoRefUrl];
    }
    
    [self addImagesToScroller];
}

-(void)addImagesToScroller {
    
    [self downloadAllPics];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:_deployedCellIndex inSection:0];
    VenueTableCell *cell = (VenueTableCell *)[self.tableview cellForRowAtIndexPath:indexPath];
    
    _w = cell.scrollView.frame.size.width;
    _h = cell.scrollView.frame.size.height;
    
    cell.scrollView.contentSize = CGSizeMake(cell.scrollView.frame.size.width*self.venueImagesArray.count, cell.scrollView.frame.size.height);
    cell.scrollView.pagingEnabled = true;
    cell.scrollView.layer.cornerRadius = 6;
    if (self.venueImagesArray.count > 1) {
        cell.pageControl.numberOfPages = self.venueImagesArray.count;
    }
    
    self.tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(advanceToNextImage)];
    self.tap.numberOfTapsRequired = 1;
    
    [cell.scrollView addGestureRecognizer:self.tap];
//    if (self.venueImagesArray.count > 1) {
//        //        UIImageView *imageview = (UIImageView *)[self.view viewWithTag:101];
//        //        [cell.scrollView addSubview:imageview];
//        //        [cell.scrollView bringSubviewToFront:imageview];
//        [cell.scrollView bringSubviewToFront:cell.imageFade];
//        [cell.scrollView bringSubviewToFront:cell.pageControl];
//        cell.pageControl.alpha = 1.0;
//        
//    }
//    
//    [cell.scrollView bringSubviewToFront:cell.imageFade];
//    [cell.scrollView bringSubviewToFront:cell.pageControl];
}

-(void)advanceToNextImage {
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:_deployedCellIndex inSection:0];
    VenueTableCell *cell = (VenueTableCell *)[self.tableview cellForRowAtIndexPath:indexPath];
    
    _w = cell.scrollView.frame.size.width;
    _h = cell.scrollView.frame.size.height;
    
    _imageIndex++;
    if (_imageIndex == self.venueImagesArray.count) {
        _imageIndex = 0;
    }
    if (self.venueImagesArray.count == 0) {
        return;
    }

    cell.pageControl.currentPage = _imageIndex;
    
    UIImageView *imageview = (UIImageView *)[cell.contentView viewWithTag:101];
    NSString *urlString = [self.venueImagesArray objectAtIndex:_imageIndex];
    NSURL *url = [NSURL URLWithString:urlString];
    
    imageview.image = [UIImage imageNamed:@""];
    
    
        SDWebImageManager *managerOne = [SDWebImageManager sharedManager];
        [managerOne downloadImageWithURL:url options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize) {
            
        }
                               completed:^(UIImage *images, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                                   
                                   //images = [images e5];
                                   imageview.image = images;
                                   
                               }];
    
    [cell.scrollView bringSubviewToFront:imageview];
    [cell.scrollView bringSubviewToFront:cell.imageFade];
    [cell.scrollView bringSubviewToFront:cell.pageControl];
    
}

-(void)downloadAllPics {
    
    for (int i = 0; i < self.venueImagesArray.count; i++) {
        NSString *urlString = [self.venueImagesArray objectAtIndex:i];
        NSURL *url = [NSURL URLWithString:urlString];
        SDWebImageManager *managerTwo = [SDWebImageManager sharedManager];
        
        if ([managerTwo cachedImageExistsForURL:url]) {
            //NSLog(@"already got em champ");
        } else {
            
            [managerTwo downloadImageWithURL:url options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize) {
            }
                                   completed:^(UIImage *images, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                                       //NSLog(@"Image: %@", images);
                                       
                                   }];
        }
    }
}


-(void)mapButtonPressed: (UIGestureRecognizer *)recognizer {
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:_deployedCellIndex inSection:0];
    VenueTableCell *cell = (VenueTableCell *)[self.tableview cellForRowAtIndexPath:indexPath];
    
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        
        [UIView animateWithDuration:0.10 animations:^{
            cell.directionsButton.transform = CGAffineTransformMakeScale(.914, .914);
        } completion:^(BOOL finished) {
            
        }];
    }
    
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        
        [UIView animateWithDuration:0.1 animations:^{
            cell.directionsButton.transform = CGAffineTransformMakeScale(1.0, 1.0);
        } completion:^(BOOL finished) {
            [self showMapForDeployedCell];
        }];
    }
}

-(void)showMapForDeployedCell {
    
    _mapShowing = true;
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:_deployedCellIndex inSection:0];
    VenueTableCell *cell = (VenueTableCell *)[self.tableview cellForRowAtIndexPath:indexPath];
    
    
    [cell.scrollView sendSubviewToBack:cell.imageFade];
    [cell.scrollView sendSubviewToBack:cell.pageControl];
    
    MKMapView *map1 = (MKMapView *)[cell.contentView viewWithTag:202];
    if (map1) {
        //[cell.scrollView removeGestureRecognizer:self.tap];
        return;
    }
    
    PFObject *object = [self.venues objectAtIndex:indexPath.row];
    CLLocationDegrees lat = [[[[object objectForKey:@"location"] valueForKey:@"coordinate"] valueForKey:@"latitude"] doubleValue];
    CLLocationDegrees lon = [[[[object objectForKey:@"location"] valueForKey:@"coordinate"] valueForKey:@"longitude"] doubleValue];
    CLLocationCoordinate2D coordinates;
    coordinates.latitude = lat;
    coordinates.longitude = lon;
    
    MKMapView *map = [[MKMapView alloc] initWithFrame:cell.scrollView.bounds];
    map.delegate = self;
    //MKCoordinateRegion region = { {0.0, 0.0 }, { 0.0, 0.0 } };
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(coordinates, 5*100, 5*100);
    
    map.tag = 202;
    map.hidden = false;
    region.center.latitude = self.currentLocation.latitude;
    region.center.longitude = self.currentLocation.longitude;
    region.span.longitudeDelta = 0.022f;
    region.span.latitudeDelta = 0.022f;
    [map setRegion:region animated:YES];
    [cell.scrollView addSubview:map];
    [cell.scrollView bringSubviewToFront:map];
    [cell.scrollView removeGestureRecognizer:self.tap];
    
    [self createAndAddAnnotationForCoordinate];
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (_deployedCellIndex == indexPath.row) {
        return 450;
    }
    
    return 98;
}

-(void)viewWillDisappear:(BOOL)animated {

    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
    self.map = nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    
    return self.venues.count;
}


-(UIColor*)colorWithHexString:(NSString*)hex {
    
    NSString *cString = [[hex stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    if ([cString length] < 6) return [UIColor grayColor];
    if ([cString hasPrefix:@"0X"]) cString = [cString substringFromIndex:2];
    if ([cString length] != 6) return  [UIColor grayColor];
    NSRange range;
    range.location = 0;
    range.length = 2;
    NSString *rString = [cString substringWithRange:range];
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    return [UIColor colorWithRed:((float) r / 255.0f)
                           green:((float) g / 255.0f)
                            blue:((float) b / 255.0f)
                           alpha:1.0f];
}

- (void)createCloseButton
{
    
    self.closeButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.view.frame)-58, 25.50, 46, 46)];
    
    [self.closeButton setImage:[UIImage imageNamed:@"downArrow"] forState:UIControlStateNormal];
    [self.closeButton addTarget:self action:@selector(didCloseButtonTouch) forControlEvents:UIControlEventTouchUpInside];
    [self.closeButton addGestureRecognizer:self.longPress];
    [self.view addSubview:self.closeButton];
}

- (void)didCloseButtonTouch
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

////Empty Table View Properties
- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView {
    
    NSString *text = @"";
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont fontWithName:@"AvenirNext-Regular" size:28],
                                 NSForegroundColorAttributeName: [UIColor colorWithWhite:1.0 alpha:0.9]};
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}

- (BOOL)emptyDataSetShouldDisplay:(UIScrollView *)scrollView {
    
    if (self.venues.count == 0) {
        self.tableview.separatorStyle = UITableViewCellSeparatorStyleNone;

        return YES;
    }
    return NO;
}

- (CGPoint)offsetForEmptyDataSet:(UIScrollView *)scrollView {
    return CGPointZero;
}

- (BOOL)emptyDataSetShouldAllowScroll:(UIScrollView *)scrollView {
    return NO;
}

-(void)queryUsingYelpYuck {
 
    NSString *term = @"food";
    NSString *location = self.userCity;
    NSString *category = self.categoryId;

    
    CLLocationDegrees lat = self.currentLocation.latitude;
    CLLocationDegrees lon = self.currentLocation.longitude;
    CLLocationCoordinate2D coordinates;
    
    
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(coordinates, 1000, 1000);
    CLLocationCoordinate2D northWestCorner = CLLocationCoordinate2DMake(
                                                     self.currentLocation.latitude + (region.span.latitudeDelta),
                                                     self.currentLocation.longitude - (region.span.longitudeDelta)
                                                                        );
    CLLocationCoordinate2D southEastCorner = CLLocationCoordinate2DMake(
                                                     self.currentLocation.latitude - (region.span.latitudeDelta),
                                                     self.currentLocation.longitude + (region.span.longitudeDelta)
                                                                        );
    
    
    self.venueIconArray = [[NSMutableArray alloc] init];
    
    __block NSMutableArray *newArray = [[NSMutableArray alloc] init];
    
    NSString *userLocation = [NSString stringWithFormat:@"%f,%f", self.currentLocation.latitude, self.currentLocation.longitude];
    
    self.venues = [[NSMutableArray alloc] init];
    
    YPAPISample *APISample = [[YPAPISample alloc] init];
    [APISample queryVenues:term location:location coordinates:userLocation category:category completionHandler:^(NSMutableArray *venues, NSError *error) {
        if (error) {
        } else {
            
            // Surprise!
            if ([category isEqualToString:@"restaurants"]) {
                self.venues = venues;
                for (int i = 0; i < self.venues.count; i++) {
                    NSDictionary *dic = [self.venues objectAtIndex:i];
                    NSString *imageUrl = [dic valueForKey:@"image_url"];
                    if (imageUrl != nil) {
                        
                        [self.venueIconArray addObject:imageUrl];
                    }
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.tableview reloadData];
                    [self.indicator setHidden:YES];
                    [self.indicator stopAnimating];
                    
                });
                return;
            }
            
            for (int i = 0; i < venues.count; i++) {
                NSMutableDictionary *object = [[venues objectAtIndex:i] mutableCopy];
                CLLocationDegrees lat = [[[[object objectForKey:@"location"] valueForKey:@"coordinate"] valueForKey:@"latitude"] doubleValue];
                CLLocationDegrees lon = [[[[object objectForKey:@"location"] valueForKey:@"coordinate"] valueForKey:@"longitude"] doubleValue];
                CLLocation *venueLocation = [[CLLocation alloc] initWithLatitude:lat longitude:lon];
                CLLocation *userLoca = [[CLLocation alloc] initWithLatitude:self.currentLocation.latitude longitude:self.currentLocation.longitude];
                
                CLLocationDistance distance = [userLoca distanceFromLocation:venueLocation];
                NSString *dis = [NSString stringWithFormat:@"%f", distance];
                CGFloat disFloat = [dis floatValue];
                NSNumber *yourFloatNumber = [NSNumber numberWithFloat:disFloat];
                [object setValue:yourFloatNumber forKey:@"distanceFromMe"];
                [newArray addObject:object];
                NSSortDescriptor *sortDescriptor;
                sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"distanceFromMe"
                                                              ascending:YES];
                NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
                NSArray *sortedArray;
                sortedArray = [newArray sortedArrayUsingDescriptors:sortDescriptors];
                NSLog(@"First Distance: %@", [sortedArray valueForKey:@"distanceFromMe"]);
                
                newArray = [[NSArray arrayWithArray:sortedArray] mutableCopy];
                
        
            }
            
            //self.venues = venues;
            
            self.venues = newArray;
            
            [self addMapAnnotations];
            
            for (int i = 0; i < self.venues.count; i++) {
                NSDictionary *dic = [self.venues objectAtIndex:i];
                NSString *imageUrl = [dic valueForKey:@"image_url"];
                if (imageUrl != nil) {
                   
                    [self.venueIconArray addObject:imageUrl];
                } else {
                    NSString *blankUrl = @"http://gemcalifornia.com/venueImage@2x.png";
                    [self.venueIconArray addObject:blankUrl];
                }
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableview reloadData];
                [self.indicator setHidden:YES];
                [self.indicator stopAnimating];

            });
        }
    }];
}

-(void)createAndAddAnnotationForCoordinate {
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:_deployedCellIndex inSection:0];
    VenueTableCell *cell = (VenueTableCell *)[self.tableview cellForRowAtIndexPath:indexPath];
    
    PFObject *object = [self.venues objectAtIndex:indexPath.row];
    
    CLLocationDegrees lat = [[[[object objectForKey:@"location"] valueForKey:@"coordinate"] valueForKey:@"latitude"] doubleValue];
    CLLocationDegrees lon = [[[[object objectForKey:@"location"] valueForKey:@"coordinate"] valueForKey:@"longitude"] doubleValue];
    CLLocationCoordinate2D coordinates;
    coordinates.latitude = lat;
    coordinates.longitude = lon;

    CLLocationCoordinate2D userCoordinates;
    userCoordinates.latitude = self.currentLocation.latitude;
    userCoordinates.longitude = self.currentLocation.longitude;

    
    //NSString *venueName = [object objectForKey:@"name"];
    MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
    annotation.title = @"Tap For Directions";
    [annotation setCoordinate:coordinates];
    
    
    
    MKPointAnnotation *annotation2 = [[MKPointAnnotation alloc] init];
    [annotation2 setCoordinate:userCoordinates];

    MKMapView *map = (MKMapView *)[cell.contentView viewWithTag:202];
    map.delegate = self;
    map.showsUserLocation = true;
    [map addAnnotation:annotation];
    
    NSMutableArray *array = [[NSMutableArray alloc] init];
    [array addObject:annotation];
    [array addObject:annotation2];
    
    [map showAnnotations:array animated:YES];
    [map removeAnnotation:annotation2];
    
    //[map selectAnnotation:annotation animated:YES];
    
    [self performSelector:@selector(setCamera:) withObject:map afterDelay:0.30];
}


-(void)calloutTapped: (UIGestureRecognizer *)sender {
    
    PFObject *object = [self.venues objectAtIndex:_selectedIndex];
    CLLocationDegrees lat = [[[[object objectForKey:@"location"] valueForKey:@"coordinate"] valueForKey:@"latitude"] doubleValue];
    CLLocationDegrees lon = [[[[object objectForKey:@"location"] valueForKey:@"coordinate"] valueForKey:@"longitude"] doubleValue];
    CLLocationDegrees userlat = self.currentLocation.latitude;
    CLLocationDegrees userlon = self.currentLocation.longitude;
    
    NSString* url = [NSString stringWithFormat:@"http://maps.apple.com/maps?saddr=%f,%f&daddr=%f,%f",userlat, userlon, lat,lon];
    [[UIApplication sharedApplication] openURL: [NSURL URLWithString: url]];

}

-(void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    
    view.gestureRecognizers = nil;
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self  action:@selector(calloutTapped:)];
    tapGesture.numberOfTapsRequired = 2;
    [view addGestureRecognizer:tapGesture];
}

-(void)setCamera: (MKMapView *)map {
    
    MKMapCamera *newCamera = [[map camera] copy];
    [newCamera setPitch:45.0];
    //[newCamera setHeading:27.0];
    //[newCamera setAltitude:500.0];
    [map setCamera:newCamera animated:YES];
}

@end
