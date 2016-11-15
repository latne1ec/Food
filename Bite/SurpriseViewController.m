//
//  SurpriseViewController.m
//  justforfun
//
//  Created by Evan Latner on 7/13/15.
//  Copyright (c) 2015 Bite. All rights reserved.
//

#import "SurpriseViewController.h"
#import "SDWebImageManager.h"
#import "UIImageView+WebCache.h"

@interface SurpriseViewController ()

#define kCLIENTID @"VPHBFYCGLAKRNZTCX2E2SUXQXQLZFVZ4JLWCRN5TCLFLW2CI"
#define kCLIENTSECRET @"MAJMGKNWIUNYHIBUGHSS2GSMMTV0M2T5T3LCTBYI0ZGOF22D"

@property int currentIndex;
@property(nonatomic) float w, h;

@end

@implementation SurpriseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _currentIndex = 0;
    
    self.topView =[[UIView alloc] initWithFrame:CGRectMake(0, 0,[UIScreen mainScreen].bounds.size.width, 76)];
    self.topView.backgroundColor= [self colorWithHexString:self.dasString];
    self.topView.layer.shadowOpacity = 0.0;
    
    self.categoryLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 6, self.view.frame.size.width, 76)];
    self.categoryLabel.text = @"surprise!";
    [self.categoryLabel setFont:[UIFont fontWithName:@"Montserrat-Regular" size:24.4]];
    self.categoryLabel.textColor = [UIColor whiteColor];
    self.categoryLabel.textAlignment = NSTextAlignmentCenter;
    
    self.categoryIcon = [[UIImageView alloc] initWithFrame:CGRectMake(12, 24, 42, 42)];
    self.categoryIcon.image = [UIImage imageNamed:@"giftNew"];
    self.bottomView.layer.cornerRadius = 12;
    self.bottomView.alpha = 0.0;
    
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
    
    //[self craziness];

    //self.view.backgroundColor = [UIColor colorWithRed:54./256. green:70./256. blue:93./256. alpha:1.];
    
    ///[self.view setBackgroundColor: [self colorWithHexString:self.dasString]];
    //self.bottomView.layer.cornerRadius = 10;
    [self.bottomView setBackgroundColor: [self colorWithHexString:self.dasString]];
    
    self.venueName.text = [self.venue objectForKey:@"venueName"];
    //NSLog(@"YO: %@", self.venueName.text);
    
    //self.venueImage.layer.cornerRadius = 12;
    self.venueImage.clipsToBounds = YES;
    //NSLog(@"#: %@", self.phoneNumber);
    
    self.phoneNumberLabel.text = @"(989) 774-3224";
    
    self.bkgView.backgroundColor = [UIColor whiteColor];
    self.bkgView.layer.cornerRadius = 7;
    //self.bkgView.clipsToBounds = YES;
    
    [self createCloseButton];
    
    self.nextButton.layer.cornerRadius = 4;
    [self.nextButton setTitleColor:[self colorWithHexString:self.dasString] forState:UIControlStateNormal];
    self.nextButton.backgroundColor = [UIColor whiteColor];
    self.nextButton.layer.shadowColor = [UIColor blackColor].CGColor;
    self.nextButton.layer.shadowOpacity = 0.34;
    self.nextButton.layer.shadowRadius = 1.35;
    self.nextButton.layer.shadowOffset = CGSizeMake(1.35f, 1.35f);
    self.nextButton.alpha = 1.0;
    self.venueName.alpha = 0.0;
    
    [self queryForRandomVenues];
    
    MKMapView *map = [[MKMapView alloc] initWithFrame:self.venueImage.frame];
    
    if ([UIScreen mainScreen].bounds.size.height > 568.0) {
        map.frame = CGRectMake(0, 76, self.view.frame.size.width, self.view.frame.size.height-170);
    }
    
    NSLog(@"Math: %f",  self.venueImage.frame.origin.y);
    
    
    map.delegate = self;
    map.tag = 202;
    map.alpha = 1.0;
    [self.view addSubview:map];
    [self.view bringSubviewToFront:self.topFade];
    [self.view bringSubviewToFront:self.bottomFade];
    [self.view bringSubviewToFront:self.favButton];
    [self.view bringSubviewToFront:self.closeButton];
    
    [UIView animateWithDuration:1.5 animations:^{
        
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:1.0 animations:^{
            
        } completion:^(BOOL finished) {
            //map.alpha = 1.0;
        }];
    }];
    
    _w = self.view.frame.size.width;
    _h = self.view.frame.size.height;self.venueNameLabel.text = @"";
    
    self.cardView.layer.cornerRadius = 10;
    self.venueIconImage.layer.cornerRadius = self.venueIconImage.frame.size.width / 2;
    self.venueIconImage.clipsToBounds = true;
    
    //self.bottomView.backgroundColor = [UIColor clearColor];
    
    self.venueNameLabel.text = @"";
    self.venueDistanceLabel.text = @"";
    
    [self.view addSubview:self.topView];
    [self.topView addSubview:self.categoryLabel];
    [self.topView addSubview:self.categoryIcon];
    
}

-(void)viewWillAppear:(BOOL)animated {
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:NO];

    self.venueImage.alpha = 0.0;
    self.bkgView.alpha = 0.0;
    self.topFade.alpha = 0.0;
    self.bottomFade.alpha = 0.0;
    self.venueName.alpha = 0.0;
    self.venueTeaser.alpha = 0.0;
    
    
    //self.venueImage.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    [UIView animateWithDuration:0.21 delay:0.35 options:0 animations:^{
        //self.venueImage.frame = CGRectMake(0, 300, self.view.frame.size.width, self.view.frame.size.height);
        
        self.venueImage.alpha = 1.0;
        self.bkgView.alpha = 1.0;
        //self.topFade.alpha = 0.445;
        self.bottomFade.alpha = 0.08;
        self.venueName.alpha = 1.0;
        self.venueTeaser.alpha = 1.0;
        
    } completion:^(BOOL finished) {
        
    }];
    
    //[self performSelector:@selector(this) withObject:nil afterDelay:0.2];
    [self createButton];
    
}

-(void)viewWillDisappear:(BOOL)animated {
    
     [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
}

-(void)this {
    
    self.venueImage.frame = CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height-40);
    
    [[self.view superview] addSubview:self.venueImage];
    
    [UIView animateWithDuration:0.4 animations:^{
        //NSLog(@"Started");
        self.venueImage.frame = CGRectMake(0, 40, self.view.frame.size.width, self.view.frame.size.height-500);
        
    } completion:^(BOOL finished) {
        //NSLog(@"FINISHED");
        
    }];
}

-(void)createButton {
    
    CGFloat width = 50;

    //self.favButton = [[UIButton alloc] init];
    
    self.favButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.view.frame)-78, CGRectGetHeight(self.view.frame)-178, 56, 56)];
    
    self.favButton.layer.cornerRadius = width / 1.76;
    self.favButton.backgroundColor = [UIColor whiteColor];
    self.favButton.layer.shadowColor = [UIColor blackColor].CGColor;
    self.favButton.layer.shadowOpacity = 0.120;
    self.favButton.layer.shadowRadius = 0.15;
    self.favButton.layer.shadowOffset = CGSizeMake(1.15f, 1.15f);
    self.favButton.alpha = 1.0;

    [self.favButton setTitleColor:[UIColor colorWithWhite:0.0 alpha:0.0] forState:UIControlStateSelected];
    [self.favButton setImage:[UIImage imageNamed:@"refresh"] forState:UIControlStateNormal];
    [self.favButton setImage:[UIImage imageNamed:@"refresh"] forState:UIControlStateSelected];
    
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(expandButton:)];
    longPress.delegate = (id)self;
    longPress.minimumPressDuration = 0.01;
    [self.favButton addGestureRecognizer:longPress];
    [self.view addSubview:self.favButton];
    
}

-(void)expandButton:(UILongPressGestureRecognizer *)recognizer {
    
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        
        [UIView animateWithDuration:0.13 animations:^{
            self.favButton.transform = CGAffineTransformMakeScale(1.1, 1.1);
            
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.12 animations:^{
                
                self.favButton.transform = CGAffineTransformMakeScale(1.08, 1.08);
            } completion:^(BOOL finished) {
                
            }];
        }];
    }
    
    if (recognizer.state == UIGestureRecognizerStateChanged) {
        [UIView animateWithDuration:0.1 animations:^{
            self.favButton.transform = CGAffineTransformMakeScale(1.0, 1.0);
            
        } completion:^(BOOL finished) {
            self.favButton.transform = CGAffineTransformMakeScale(1.0, 1.0);
            _currentIndex++;
        }];
    }
    
    if (recognizer.state == UIGestureRecognizerStateEnded) {
     
        [UIView animateWithDuration:0.1 animations:^{
            self.favButton.transform = CGAffineTransformMakeScale(1.0, 1.0);

        } completion:^(BOOL finished) {
            //self.favButton.transform = CGAffineTransformMakeScale(1.0, 1.0);
            _currentIndex++;
            [self showMap];
        }];
    }
}


-(void)viewDidAppear:(BOOL)animated {
    
    self.bkgView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.bkgView.layer.shadowOpacity = 1.0;
    self.bkgView.layer.shadowRadius = .35;
    self.bkgView.layer.shadowOffset = CGSizeMake(1.35f, 1.35f);
    self.bkgView.layer.masksToBounds = NO;
    
}
- (void)createCloseButton {
    
    
//    self.closeButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.view.frame)-70, 14.0, 74, 74)];
//    
//    [self.closeButton setImage:[UIImage imageNamed:@"close"] forState:UIControlStateNormal];
//    
//    //[closeButton addTarget:self action:@selector(didCloseButtonTouch) forControlEvents:UIControlEventTouchUpInside];
//    
//    [self.view addSubview:self.closeButton];
//    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressBegan:)];
    longPress.delegate = (id)self;
    longPress.minimumPressDuration = 0.01;
    [self.closeButton addGestureRecognizer:longPress];
    
    self.closeButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.view.frame)-58, 25.50, 46, 46)];
    
    [self.closeButton setImage:[UIImage imageNamed:@"downArrow"] forState:UIControlStateNormal];
    [self.closeButton addTarget:self action:@selector(didCloseButtonTouch) forControlEvents:UIControlEventTouchUpInside];
    [self.closeButton addGestureRecognizer:longPress];
    [self.topView addSubview:self.closeButton];
}


-(void)longPressBegan: (UILongPressGestureRecognizer *)recognizer {
    
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        [UIView animateWithDuration:0.11 delay:0.0 options:0 animations:^{
            
            self.topView.transform = CGAffineTransformMakeScale(1.018f, 1.018f);
            self.categoryIcon.transform = CGAffineTransformMakeScale(1.048f, 1.048f);
            self.categoryLabel.transform = CGAffineTransformMakeScale(1.048f, 1.048f);
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

-(void)doThis: (UILongPressGestureRecognizer *)recognizer {
    
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        
        [UIView animateWithDuration:0.085 animations:^{
            //NSLog(@"Started");
            self.closeButton.transform = CGAffineTransformMakeScale(1.5, 1.5);
            
        } completion:^(BOOL finished) {
            //NSLog(@"FINISHED");
             [UIView animateWithDuration:0.07 animations:^{
                self.closeButton.transform = CGAffineTransformMakeScale(1.40, 1.40);
             } completion:^(BOOL finished) {
                 
             }];
        }];
    }
    
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        
        [UIView animateWithDuration:0.1 animations:^{
            //NSLog(@"Started");
            self.closeButton.transform = CGAffineTransformMakeScale(1.0, 1.0);
            
        } completion:^(BOOL finished) {
            //NSLog(@"FINISHED");
            [self didCloseButtonTouch];
        }];
    }
}


- (void)didCloseButtonTouch {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(UIColor*)colorWithHexString:(NSString*)hex {
    
    NSString *cString = [[hex stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    
    // String should be 6 or 8 characters
    if ([cString length] < 6) return [UIColor grayColor];
    
    // strip 0X if it appears
    if ([cString hasPrefix:@"0X"]) cString = [cString substringFromIndex:2];
    
    if ([cString length] != 6) return  [UIColor grayColor];
    
    // Separate into r, g, b substrings
    NSRange range;
    range.location = 0;
    range.length = 2;
    NSString *rString = [cString substringWithRange:range];
    
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    
    // Scan values
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    
    return [UIColor colorWithRed:((float) r / 255.0f)
                           green:((float) g / 255.0f)
                            blue:((float) b / 255.0f)
                           alpha:1.0f];
}

-(void)craziness {
    
    PFQuery *countQuery = [PFQuery queryWithClassName:@"Venues"];
    //[countQuery whereKey:@"venueCategory" equalTo:@"american"];
    [countQuery countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
        int randomIndex = arc4random() % number;
//        NSLog(@"Number: %d", number);
//        NSLog(@"Random number: %d", randomIndex);
        
        if (randomIndex == number) {
            randomIndex = randomIndex / 2;
        }
        
    
        PFQuery *query = [PFQuery queryWithClassName:@"Venues"];
        //[query whereKey:@"venueCategory" equalTo:@"american"];
        //[query whereKey:@"index" equalTo:[NSNumber numberWithInt:randomIndex]];
        [query setSkip:randomIndex];
        [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
            
            if (error) {
            }
            else {
                //NSLog(@"Object: %@", object);
                self.venue = object;
                [self addPic];
                
            }
        }];
    }];
}

-(void)addPic {
    
    self.venueName.text = [self.venue objectForKey:@"venueName"];
    self.venueTeaser.text = [self.venue objectForKey:@"venueTeaser"];
    
    self.venueDescription.text = [self.venue objectForKey:@"venueDescription"];
    self.venueDescription.text = @"Lorem Ipsum is simply dummy text of the printing industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s.";
    

    PFFile *profilePicture = [self.venue objectForKey:@"venueImage"];
    PFImageView *ImageView = (PFImageView*)self.venueImage;
    ImageView.image = [UIImage imageNamed:@"YapHolder"];
    ImageView.file = profilePicture;
    [ImageView loadInBackground];
}

-(void)queryForRandomVenues {
    
    self.venues = [[NSMutableArray alloc] init];
    
    NSString *term = @"food";
    NSString *category = @"restaurants";
    NSString *location = self.userCity;
    NSString *userLocation = [NSString stringWithFormat:@"%f,%f", self.currentLocation.latitude, self.currentLocation.longitude];
    
    self.venueIconArray = [[NSMutableArray alloc] init];
    
    YPAPISample *APISample = [[YPAPISample alloc] init];
    [APISample queryVenues:term location:location coordinates:userLocation category:category completionHandler:^(NSMutableArray *venues, NSError *error) {
        if (error) {
        } else {
            
            // Surprise!
                self.venues = venues;
            
                for (int i = 0; i < self.venues.count; i++) {
                    NSDictionary *dic = [self.venues objectAtIndex:i];
                    NSString *imageUrl = [dic valueForKey:@"image_url"];
                    if (imageUrl != nil) {
                        NSLog(@"Venues: %lu", (unsigned long)self.venues.count);
                        [self.venueIconArray addObject:imageUrl];
                    }
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self showMap];
                });
                return;
            }
        }];
}

-(void)showMap {

    PFObject *object = [self.venues objectAtIndex:_currentIndex];
    CLLocationDegrees lat = [[[[object objectForKey:@"location"] valueForKey:@"coordinate"] valueForKey:@"latitude"] doubleValue];
    CLLocationDegrees lon = [[[[object objectForKey:@"location"] valueForKey:@"coordinate"] valueForKey:@"longitude"] doubleValue];
    CLLocationCoordinate2D coordinates;
    coordinates.latitude = lat;
    coordinates.longitude = lon;
    

    MKMapView *map = (MKMapView *)[self.view viewWithTag:202];
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(coordinates, 5*100, 5*100);
    
    map.tag = 202;
    map.hidden = false;
    region.center.latitude = self.currentLocation.latitude;
    region.center.longitude = self.currentLocation.longitude;
    region.span.longitudeDelta = 0.01f;
    region.span.latitudeDelta = 0.01f;
    [map setRegion:region animated:false];
    
    [map removeAnnotations:map.annotations];
    
    MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
    annotation.title = @"Tap For Directions";
//    NSString *string = [NSString stringWithFormat:@"%@", [object objectForKey:@"name"]];
//    annotation.title = string;
    [annotation setCoordinate:coordinates];
    
    CLLocationCoordinate2D userCoordinates;
    userCoordinates.latitude = self.currentLocation.latitude;
    userCoordinates.longitude = self.currentLocation.longitude;
    
    MKPointAnnotation *annotation2 = [[MKPointAnnotation alloc] init];
    [annotation2 setCoordinate:userCoordinates];
    
    map.showsUserLocation = true;
    [map addAnnotation:annotation];
    
    NSMutableArray *array = [[NSMutableArray alloc] init];
    [array addObject:annotation];
    [array addObject:annotation2];
    
    [map showAnnotations:array animated:YES];
    [map removeAnnotation:annotation2];
    
   // [map selectAnnotation:annotation animated:YES];
    
    MKMapCamera *newCamera = [[map camera] copy];
    [newCamera setPitch:45.0];
    
    map.alpha = 1.0;
    
    [self.view bringSubviewToFront:self.bottomView];
    self.detailImageView.clipsToBounds = true;
    self.detailImageView.layer.cornerRadius = 6;
    
    
    self.venueNameLabel.alpha = 0.0;
    self.venueDistanceLabel.alpha = 0.0;
    self.venueIconImage.alpha = 0.0;
    
    [UIView animateWithDuration:0.11 delay:0.0 options:0 animations:^{
         self.bottomView.alpha = 0.95;
         self.venueNameLabel.alpha = 0.88;
         self.venueDistanceLabel.alpha = 0.88;
         //self.venueIconImage.alpha = 1.0;
//         self.venueNameLabel.transform = CGAffineTransformMakeScale(0.96, 0.96);
//         self.venueDistanceLabel.transform = CGAffineTransformMakeScale(0.96, 0.96);
//         self.venueIconImage.transform = CGAffineTransformMakeScale(0.96, 0.96);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.09 delay:0.0 options:0 animations:^{
//            self.venueNameLabel.transform = CGAffineTransformMakeScale(1.0, 1.0);
//            self.venueDistanceLabel.transform = CGAffineTransformMakeScale(1.0, 1.0);
//            self.venueIconImage.transform = CGAffineTransformMakeScale(1.0, 1.0);
        } completion:^(BOOL finished) {
            
        }];
    }];
    
    
    self.venueNameLabel.text = [object objectForKey:@"name"];
    CLLocationDegrees lat2 = [[[[object objectForKey:@"location"] valueForKey:@"coordinate"] valueForKey:@"latitude"] doubleValue];
    CLLocationDegrees lon2 = [[[[object objectForKey:@"location"] valueForKey:@"coordinate"] valueForKey:@"longitude"] doubleValue];
    CLLocation *venueLocation = [[CLLocation alloc] initWithLatitude:lat2 longitude:lon2];
    CLLocation *userLoca = [[CLLocation alloc] initWithLatitude:self.currentLocation.latitude longitude:self.currentLocation.longitude];
    
    CLLocationDistance distance = [userLoca distanceFromLocation:venueLocation];
    
    self.venueDistanceLabel.text = [NSString stringWithFormat:@"%.1f miles away",(distance/1609.344)];
    
    if (self.venueIconArray.count-1 < _currentIndex) {
    } else {
       
        NSURL *url = [NSURL URLWithString:[self.venueIconArray objectAtIndex:_currentIndex]];
        [self.venueIconImage sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@""]];
        [self.venueIconImage sd_setImageWithURL:url completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            if (image) {
                [UIView animateWithDuration:0.15 animations:^{
                    self.venueIconImage.alpha = 1.0;
                }];
            }
        }];
    }
    
    UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [panRecognizer setMinimumNumberOfTouches:1];
    [panRecognizer setMaximumNumberOfTouches:1];
    panRecognizer.delegate = self;
    [self.bottomView addGestureRecognizer:panRecognizer];
}

- (void)handlePan:(UIPanGestureRecognizer *)recognizer {
    
    float yPosition = self.bottomView.frame.origin.y;
    float height = self.view.bounds.size.height;
    
    NSLog(@"Here: %f", yPosition/height);
    
    if (yPosition/height < .42f) {
        
        
        CGPoint translation = [recognizer translationInView:self.view];
        recognizer.view.center = CGPointMake(_w/2,
                                             recognizer.view.center.y + translation.y*.4);
        [recognizer setTranslation:CGPointMake(0, 0) inView:self.view];
        
        //return;
    }
    
    CGPoint translation = [recognizer translationInView:self.view];
    recognizer.view.center = CGPointMake(_w/2,
                                         recognizer.view.center.y + translation.y);
    [recognizer setTranslation:CGPointMake(0, 0) inView:self.view];
    
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        
        if (yPosition/height > 0.7f) {
            NSLog(@"hi");
            [UIView animateWithDuration:0.25 animations:^{
                self.bottomView.frame = CGRectMake(0, self.view.frame.size.height-102, self.bottomView.frame.size.width, self.bottomView.frame.size.height);
            } completion:^(BOOL finished) {
                
            }];
        } else {
            NSLog(@"hi 2");
            [UIView animateWithDuration:0.25 animations:^{
                self.bottomView.frame = CGRectMake(0, self.view.frame.size.height-360, self.bottomView.frame.size.width, self.bottomView.frame.size.height);
            } completion:^(BOOL finished) {
                
            }];
        }
        
//        CGPoint velocity = [recognizer velocityInView:self.view];
//        CGFloat magnitude = sqrtf((velocity.x * velocity.x) + (velocity.y * velocity.y));
//        CGFloat slideMult = magnitude / 200;
//        
//        float slideFactor = 0.01 * slideMult; // Increase for more of a slide
//        CGPoint finalPoint = CGPointMake(_w/2,
//                                         recognizer.view.center.y + (velocity.y * slideFactor));
//        finalPoint.x = MIN(MAX(finalPoint.x, 0), self.view.bounds.size.width);
//        finalPoint.y = MIN(MAX(finalPoint.y, 0), self.view.bounds.size.height);
//        
//        [UIView animateWithDuration:slideFactor*2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
//            recognizer.view.center = finalPoint;
//        } completion:nil];
        
    }
}


-(void)calloutTapped: (UIGestureRecognizer *)sender {
    
    PFObject *object = [self.venues objectAtIndex:_currentIndex];
    
    CLLocationDegrees lat = [[[[object objectForKey:@"location"] valueForKey:@"coordinate"] valueForKey:@"latitude"] doubleValue];
    CLLocationDegrees lon = [[[[object objectForKey:@"location"] valueForKey:@"coordinate"] valueForKey:@"longitude"] doubleValue];
    CLLocationDegrees userlat = self.currentLocation.latitude;
    CLLocationDegrees userlon = self.currentLocation.longitude;
    
    NSString* url = [NSString stringWithFormat:@"http://maps.apple.com/maps?saddr=%f,%f&daddr=%f,%f",userlat, userlon, lat,lon];
    [[UIApplication sharedApplication] openURL: [NSURL URLWithString: url]];
    
}

-(void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self  action:@selector(calloutTapped:)];
    [view addGestureRecognizer:tapGesture];
}

@end
