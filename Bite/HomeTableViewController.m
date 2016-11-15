//
//  HomeTableViewController.m
//  Bite
//
//  Created by Evan Latner on 7/10/15.
//  Copyright (c) 2015 Bite. All rights reserved.
//

#import "HomeTableViewController.h"
#import "SDWebImageManager.h"
#import "UIImageView+WebCache.h"
#import "JTMaterialTransition.h"
#import "SecondViewController.h"
#import "prefix.pch"
#import "StretchViewTransition.h"
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
//#import <GoogleMaps/GoogleMaps.h>

#define kGOOGLE_API_KEY @"AIzaSyCJtSY62kZVP8VqRVPO0JbmwkeR7-IzM2I"

//#define kCLIENTID @"VPHBFYCGLAKRNZTCX2E2SUXQXQLZFVZ4JLWCRN5TCLFLW2CI"
//#define kCLIENTSECRET @"MAJMGKNWIUNYHIBUGHSS2GSMMTV0M2T5T3LCTBYI0ZGOF22D"

#define kCLIENTID @"VPHBFYCGLAKRNZTCX2E2SUXQXQLZFVZ4JLWCRN5TCLFLW2CI"
#define kCLIENTSECRET @"MAJMGKNWIUNYHIBUGHSS2GSMMTV0M2T5T3LCTBYI0ZGOF22D"

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface HomeTableViewController ()

@property (nonatomic, strong) NSMutableArray *images;
@property (nonatomic) JTMaterialTransition *transition;
@property (nonatomic) UIButton *presentControllerButton;
@property (nonatomic) StretchViewTransition *transitionTwo;
@property (nonatomic) UIButton *presentControllerButtonTwo;
@property (nonatomic, strong) UILongPressGestureRecognizer *longPress;
@property (nonatomic, strong) UITapGestureRecognizer *tapTap;
@property int selectedRowIndex;

@end

@implementation HomeTableViewController

bool didMove;

-(BOOL)prefersStatusBarHidden {
    return NO;
}

- (BOOL)touchesShouldCancelInContentView:(UIView *)view {
    return NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _selectedRowIndex = 120;
    
    if ([PFUser currentUser]) {
        
        [[PFUser currentUser] incrementKey:@"runCount"];
        [[PFUser currentUser] saveEventually];
        
    } else {
        
        [PFUser enableAutomaticUser];
        [[PFUser currentUser] incrementKey:@"runCount"];
        [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
            
            if (error) {
                //NSLog(@"Error: %@", error);
            } else {
                //NSLog(@"Successfully created user");
            }
        }];
    }
    
    didMove = NO;
    
    self.navigationController.navigationBarHidden = NO;
    
//    if ([PFUser currentUser]) {
//        [self queryForVenues];
//
//    }
//    else {
//        
//        WelcomeViewController *wvc = [self.storyboard instantiateViewControllerWithIdentifier:@"Welcome"];
//        [self.navigationController pushViewController:wvc animated:NO];
//    }
//    
    [self createPresentControllerButton];

    self.tableView.delaysContentTouches = NO;
    
    //[self createButton];
    
    self.tableView.delaysContentTouches = NO;
    
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(test) name:UIApplicationDidBecomeActiveNotification object:nil];
    
    self.topView =[[UIView alloc] initWithFrame:CGRectMake(0, -20,[UIScreen mainScreen].bounds.size.width, 20)];
    self.topView.backgroundColor=[UIColor whiteColor];
    
    UITapGestureRecognizer *taaap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scrollToTop)];
    [self.topView addGestureRecognizer:taaap];

//    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
//    UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
//    blurEffectView.frame = self.topView.bounds;
//    blurEffectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
//    
//    [self.topView addSubview:blurEffectView];
     [self.view addSubview:self.topView];
    
}


-(void)scrollToTop {
    
    NSLog(@"tapped");
    NSIndexPath *indexpath = [NSIndexPath indexPathWithIndex:0];
    
    [self.tableView scrollToRowAtIndexPath:indexpath atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

-(void)test {
    
    if ([PFUser currentUser]) {
        [PFGeoPoint geoPointForCurrentLocationInBackground:^(PFGeoPoint *geoPoint, NSError *error) {
            if (error) {
               
            }
            else {
                [self getAddressFromLatLon:geoPoint];
                self.currentLocation = geoPoint;
                NSLog(@"Geopoint: %@", geoPoint);
                [self queryForVenues];
            }
        }];
    }
}

-(void)viewWillAppear:(BOOL)animated {
    
    self.navigationController.navigationBarHidden = YES;
    self.navigationController.navigationBar.backgroundColor = [UIColor whiteColor];
    self.navigationController.navigationBar.translucent = NO;

    
    if ([PFUser currentUser]) {
        [PFGeoPoint geoPointForCurrentLocationInBackground:^(PFGeoPoint *geoPoint, NSError *error) {
            if (error) {
                NSLog(@"Error: %@", error.localizedDescription);
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Enable Location" message:@"Fungry needs access to your location while the app is open to find restaurants in your area. To re-enable, please go to Settings and enable Location \"While using app\"." delegate:nil cancelButtonTitle:nil otherButtonTitles: @"Open Settings", nil];
                alert.tag = 101;
                alert.delegate = self;
                [alert show];
            }
            else {
                [[PFUser currentUser] setObject:geoPoint forKey:@"currentLocation"];
                [[PFUser currentUser] saveInBackground];
                [self getAddressFromLatLon:geoPoint];
                self.currentLocation = geoPoint;
                NSLog(@"Geopoint: %@", geoPoint);
                [self queryForVenues];
            }
        }];
    }
    
    [self.tableView reloadData];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger) buttonIndex {
    
    if (alertView.tag == 101) {
        
        [alertView dismissWithClickedButtonIndex:0 animated:YES];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    }
}

-(void)viewWillDisappear:(BOOL)animated {
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];    

}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
   
    return self.venues.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CategoryTableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    PFObject *object = [self.venues objectAtIndex:indexPath.row];
    
    cell.categoryName.text = [object objectForKey:@"categoryName"];
    
    PFFile *homeImage = [object objectForKey:@"categoryIcon"];
    PFImageView *ImageView = (PFImageView*)cell.categoryIcon;
    ImageView.image = [UIImage imageNamed:@"sky"];
    ImageView.file = homeImage;
    [ImageView loadInBackground];
    
    cell.categoryIcon.layer.cornerRadius = 10;
    cell.categoryIcon.clipsToBounds = YES;
    
    NSString *dasString = [object objectForKey:@"categoryColor"];
    
    cell.bkgView.backgroundColor = [self colorWithHexString:dasString];
    cell.backgroundColor = [self colorWithHexString:dasString];
    
    self.longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressStarted:)];
    self.longPress.delegate = (id)self;
    self.longPress.minimumPressDuration = 0.08;
    self.longPress.delaysTouchesBegan = YES;
    
    [cell addGestureRecognizer:self.longPress];
    
//    self.tapTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userTapped:)];
//    self.tapTap.delegate = (id)self;
//    self.tapTap.numberOfTapsRequired = 1;
//    self.tapTap.delaysTouchesBegan = YES;
    //[cell addGestureRecognizer:self.tapTap];
    
    return cell;
}


-(void)userTapped: (UILongPressGestureRecognizer *)recognizer {
    
//    CGPoint tapLocation = [recognizer locationInView:self.tableView];
//    NSIndexPath *tappedIndexPath = [self.tableView indexPathForRowAtPoint:tapLocation];
//    PFObject *object = [self.venues objectAtIndex:tappedIndexPath.row];
//    SurpriseViewController *svc = [self.storyboard instantiateViewControllerWithIdentifier:@"Surprise"];
//    
//    CategoryTableCell *cell = (CategoryTableCell *)[self.tableView cellForRowAtIndexPath:tappedIndexPath];
//    self.transitionTwo.animatedView = cell.bkgView;
//    
//    svc.dasString = [object objectForKey:@"categoryColor"];
//    svc.category = [object objectForKey:@"categoryName"];
//    svc.phoneNumber = [object objectForKey:@"venuePhoneNumber"];
//    svc.modalPresentationStyle = UIModalPresentationCustom;
//    
//    svc.modalPresentationStyle = UIModalPresentationCustom;
//    svc.transitioningDelegate = self;
//    [self presentViewController:svc animated:YES completion:nil];

    
    CGPoint tapLocation = [recognizer locationInView:self.tableView];
    NSIndexPath *tappedIndexPath = [self.tableView indexPathForRowAtPoint:tapLocation];
    CategoryTableCell *cell = (CategoryTableCell *)[self.tableView cellForRowAtIndexPath:tappedIndexPath];
    
    PFObject *object = [self.venues objectAtIndex:tappedIndexPath.row];
    
//    [UIView animateWithDuration:0.11 animations:^{
//        
//        //cell.transform = CGAffineTransformMakeScale(1.28f, 1.28f);
//        cell.transform = CGAffineTransformMakeScale(1.80f, 1.0f);
//        
//    } completion:^(BOOL finished) {
//        
//        cell.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
//    }];
    
    cell.layer.zPosition = 0;
    
    self.transitionTwo.animatedView = cell.bkgView;
    
    SecondViewController *svc = [self.storyboard instantiateViewControllerWithIdentifier:@"Second"];
    
    svc.modalPresentationStyle = UIModalPresentationCustom;
    svc.transitioningDelegate = self;
    svc.dasString = [object objectForKey:@"categoryColor"];
    svc.category = [object objectForKey:@"categoryName"];
    svc.icon = cell.categoryIcon.image;
    [self presentViewController:svc animated:YES completion:nil];

}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (_selectedRowIndex == indexPath.row) {
        return 200;
    }
    
    return 100;
}

-(void)longPressStarted: (UILongPressGestureRecognizer *)recognizer {
    
//    CGPoint tapLocation = [recognizer locationInView:self.tableView];
//    NSIndexPath *tappedIndexPath = [self.tableView indexPathForRowAtPoint:tapLocation];
//    PFObject *object = [self.venues objectAtIndex:tappedIndexPath.row];
//    SurpriseViewController *svc = [self.storyboard instantiateViewControllerWithIdentifier:@"Surprise"];
//    
//    CategoryTableCell *cell = (CategoryTableCell *)[self.tableView cellForRowAtIndexPath:tappedIndexPath];
//    self.transitionTwo.animatedView = cell.bkgView;
//
//    
//    svc.dasString = [object objectForKey:@"categoryColor"];
//                    svc.category = [object objectForKey:@"categoryName"];
//                    svc.phoneNumber = [object objectForKey:@"venuePhoneNumber"];
//                    svc.modalPresentationStyle = UIModalPresentationCustom;
//    
//    svc.modalPresentationStyle = UIModalPresentationCustom;
//    svc.transitioningDelegate = self;
//    [self presentViewController:svc animated:YES completion:nil];
    
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        
        self.longPress = nil;
        
        CGPoint tapLocation = [recognizer locationInView:self.tableView];
        NSIndexPath *tappedIndexPath = [self.tableView indexPathForRowAtPoint:tapLocation];
        CategoryTableCell *cell = (CategoryTableCell *)[self.tableView cellForRowAtIndexPath:tappedIndexPath];
        
        cell.layer.zPosition = 10;
        
        
        
        [UIView animateWithDuration:0.1 delay:0.0 options:0 animations:^{
            
             //cell.transform = CGAffineTransformMakeScale(1.041f, 1.041f);
            cell.transform = CGAffineTransformMakeScale(1.0375f, 1.0375f);
            cell.backgroundView.alpha = 0.8;
            
        } completion:^(BOOL finished) {
            
            [UIView animateWithDuration:0.09 delay:0.0 options:0 animations:^{
                
                //cell.transform = CGAffineTransformMakeScale(1.03f, 1.03f);
            } completion:^(BOOL finished) {
                
            }];
        }];
    }

    if (recognizer.state == UIGestureRecognizerStateChanged) {
        
        CGPoint tapLocation = [recognizer locationInView:self.tableView];
        NSIndexPath *tappedIndexPath = [self.tableView indexPathForRowAtPoint:tapLocation];
        CategoryTableCell *cell = (CategoryTableCell *)[self.tableView cellForRowAtIndexPath:tappedIndexPath];
        
        cell.layer.zPosition = 0;
        
        [UIView animateWithDuration:0.11 delay:0.0 options:0 animations:^{
            
            cell.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
            cell.bkgView.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
        } completion:^(BOOL finished) {
            
            cell.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
            cell.bkgView.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
        }];

        recognizer.cancelsTouchesInView = YES;
        
        didMove = YES;
        
    }
        
    
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        
        if (didMove == YES) {
            
            didMove = NO;
            CGPoint tapLocation = [recognizer locationInView:self.tableView];
            NSIndexPath *tappedIndexPath = [self.tableView indexPathForRowAtPoint:tapLocation];
            CategoryTableCell *cell = (CategoryTableCell *)[self.tableView cellForRowAtIndexPath:tappedIndexPath];

            cell.layer.zPosition = 0;
            //[self.tableView reloadData];
        }
        
//        else {
//            
//            CGPoint tapLocation = [recognizer locationInView:self.tableView];
//            NSIndexPath *tappedIndexPath = [self.tableView indexPathForRowAtPoint:tapLocation];
//            CategoryTableCell *cell = (CategoryTableCell *)[self.tableView cellForRowAtIndexPath:tappedIndexPath];
//
//            self.transitionTwo.animatedView = cell.bkgView;
//            cell.layer.zPosition = 0;
//            PFObject *object = [self.venues objectAtIndex:tappedIndexPath.row];
//            SurpriseViewController *svc = [self.storyboard instantiateViewControllerWithIdentifier:@"Surprise"];
//            ListTableViewController *lvc = [self.storyboard instantiateViewControllerWithIdentifier:@"List"];
//            //MapViewController *mvc = [self.storyboard instantiateViewControllerWithIdentifier:@"Map"];
//            
//            
//            [UIView animateWithDuration:0.21 animations:^{
//                
//                cell.transform = CGAffineTransformMakeScale(1.1f, 1.1f);
//    
//                } completion:^(BOOL finished) {
//                    
//                    [UIView animateWithDuration:0.11 animations:^{
//                       cell.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
//                    } completion:^(BOOL finished) {
//                        
//                    }];
//                }];
//            
//            
////            lvc.currentLocation = self.currentLocation;
////            lvc.colorString = [object objectForKey:@"categoryColor"];
////            lvc.modalPresentationStyle = UIModalPresentationCustom;
////            lvc.transitioningDelegate = self;
////            [self presentViewController:lvc animated:YES completion:nil];
//
//                svc.dasString = [object objectForKey:@"categoryColor"];
//                svc.currentLocation = self.currentLocation;
//                svc.category = [object objectForKey:@"categoryName"];
//                svc.categoryId = [object objectForKey:@"categoryId"];
//                svc.phoneNumber = [object objectForKey:@"venuePhoneNumber"];
//                svc.modalPresentationStyle = UIModalPresentationCustom;
//                svc.transitioningDelegate = self;
//                [self presentViewController:svc animated:YES completion:nil];
        
            
            
           // }
            
            else {
            
        CGPoint tapLocation = [recognizer locationInView:self.tableView];
        NSIndexPath *tappedIndexPath = [self.tableView indexPathForRowAtPoint:tapLocation];
        CategoryTableCell *cell = (CategoryTableCell *)[self.tableView cellForRowAtIndexPath:tappedIndexPath];
        
        PFObject *object = [self.venues objectAtIndex:tappedIndexPath.row];
        
        [UIView animateWithDuration:0.12 animations:^{
            
            //cell.transform = CGAffineTransformMakeScale(1.28f, 1.28f);
            //cell.transform = CGAffineTransformMakeScale(1.80f, 1.0f);
            //cell.transform = CGAffineTransformMakeScale(1.038f, 1.038f);
            
        } completion:^(BOOL finished) {
            
            //cell.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
            
        //}];

        cell.layer.zPosition = 0;
                
            if ([cell.categoryName.text containsString:@"surprise!"]) {
                
                SurpriseViewController *svc = [self.storyboard instantiateViewControllerWithIdentifier:@"Surprise"];
                self.transitionTwo.animatedView = cell.bkgView;
                svc.dasString = [object objectForKey:@"categoryColor"];
                svc.category = [object objectForKey:@"categoryName"];
                svc.phoneNumber = [object objectForKey:@"venuePhoneNumber"];
                svc.userCity = self.userCity;
                svc.currentLocation = self.currentLocation;
                svc.modalPresentationStyle = UIModalPresentationCustom;
                svc.modalPresentationStyle = UIModalPresentationCustom;
                svc.transitioningDelegate = self;
                [self presentViewController:svc animated:YES completion:^{
                    cell.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
                    [self.tableView reloadData];
                }];
                
            } else {

        
        self.transitionTwo.animatedView = cell.bkgView;
        
        SecondViewController *svc = [self.storyboard instantiateViewControllerWithIdentifier:@"Second"];
        
        svc.modalPresentationStyle = UIModalPresentationCustom;
        svc.transitioningDelegate = self;
        svc.dasString = [object objectForKey:@"categoryColor"];
        svc.category = [object objectForKey:@"categoryName"];
        svc.icon = cell.categoryIcon.image;
        svc.currentLocation = self.currentLocation;
        svc.categoryId = [object objectForKey:@"categoryId"];
        svc.userCity = self.userCity;
        [self presentViewController:svc animated:YES completion:^{
            cell.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
            [self.tableView reloadData];
        }];
        
//                cell.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
//                cell.bkgView.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
            
            didMove = NO;
                    
            }
                }];
            }
         }
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
     CategoryTableCell *cell = (CategoryTableCell *)[self.tableView cellForRowAtIndexPath:indexPath];
//
//    _selectedRowIndex = (int)indexPath.row;
////    [UIView animateWithDuration:0.2 animations:^{
////    NSIndexPath* indexPath = [NSIndexPath indexPathForRow:_selectedRowIndex+1 inSection:0];
////    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
////        
////    }];
//    
//    NSLog(@"Text: %@", cell.categoryName.text);
//    
//    if ([cell.categoryName.text containsString:@"surprise!"]) {
//        
//        SurpriseViewController *svc = [self.storyboard instantiateViewControllerWithIdentifier:@"Surprise"];
//        PFObject *object = [self.venues objectAtIndex:indexPath.row];
//            self.transitionTwo.animatedView = cell.bkgView;
//            svc.dasString = [object objectForKey:@"categoryColor"];
//            svc.category = [object objectForKey:@"categoryName"];
//            svc.phoneNumber = [object objectForKey:@"venuePhoneNumber"];
//            svc.userCity = self.userCity;
//            svc.currentLocation = self.currentLocation;
//            svc.modalPresentationStyle = UIModalPresentationCustom;
//        
//            svc.modalPresentationStyle = UIModalPresentationCustom;
//            svc.transitioningDelegate = self;
//            [self presentViewController:svc animated:YES completion:nil];
//
//    } else {
//        [self showVenuesWithAnimation:indexPath];
//    }
   
    cell.layer.zPosition = 10;
        [UIView animateWithDuration:0.165 delay:0.0 options:0 animations:^{
    
            cell.transform = CGAffineTransformMakeScale(1.032f, 1.032f);
    
        } completion:^(BOOL finished) {
    
            [UIView animateWithDuration:0.1 delay:0.0 options:0 animations:^{
    
                //cell.transform = CGAffineTransformMakeScale(1.034f, 1.034f);
            } completion:^(BOOL finished) {
    
    PFObject *object = [self.venues objectAtIndex:indexPath.row];
    
    self.transitionTwo.animatedView = cell.bkgView;
    
    SecondViewController *svc = [self.storyboard instantiateViewControllerWithIdentifier:@"Second"];
    
    svc.modalPresentationStyle = UIModalPresentationCustom;
    svc.transitioningDelegate = self;
    svc.dasString = [object objectForKey:@"categoryColor"];
    svc.category = [object objectForKey:@"categoryName"];
    svc.icon = cell.categoryIcon.image;
    svc.currentLocation = self.currentLocation;
    svc.categoryId = [object objectForKey:@"categoryId"];
    svc.userCity = self.userCity;
    //cell.layer.zPosition = 0;
    [self presentViewController:svc animated:YES completion:^{
        //cell.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
        //[self.tableView reloadData];
        cell.layer.zPosition = 0;
    }];
            }];
            }];
        
}

-(void)showVenuesWithAnimation: (NSIndexPath *)indexPath {
    
    
    CategoryTableCell *cell = (CategoryTableCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    
    //cell.layer.zPosition = 10;
    
//    [UIView animateWithDuration:0.0987 delay:0.0 options:0 animations:^{
//        
//        cell.transform = CGAffineTransformMakeScale(1.04f, 1.04f);
//        
//    } completion:^(BOOL finished) {
//        
//        [UIView animateWithDuration:0.12 delay:0.0 options:0 animations:^{
//            
//            //cell.transform = CGAffineTransformMakeScale(1.034f, 1.034f);
//        } completion:^(BOOL finished) {
    
    PFObject *object = [self.venues objectAtIndex:indexPath.row];
    
    self.transitionTwo.animatedView = cell.bkgView;
    
    SecondViewController *svc = [self.storyboard instantiateViewControllerWithIdentifier:@"Second"];
    
    svc.modalPresentationStyle = UIModalPresentationCustom;
    svc.transitioningDelegate = self;
    svc.dasString = [object objectForKey:@"categoryColor"];
    svc.category = [object objectForKey:@"categoryName"];
    svc.icon = cell.categoryIcon.image;
    svc.currentLocation = self.currentLocation;
    svc.categoryId = [object objectForKey:@"categoryId"];
    svc.userCity = self.userCity;
    //cell.layer.zPosition = 0;
    [self presentViewController:svc animated:YES completion:^{
        //cell.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
        //[self.tableView reloadData];
    }];
//    
//        }];
//    }];
}


-(PFQuery *)queryForVenues {

    PFQuery *query = [PFQuery queryWithClassName:@"Categories"];
    //[query whereKey:@"venueLocation" nearGeoPoint:self.currentLocation];
    //[query whereKey:@"isActive" equalTo:@"YES"];
    [query orderByAscending:@"categoryName"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
       
        if (error) {
            NSLog(@"Error: %@", error);
        }
        else {
            //NSLog(@"Objects: %@", objects);
            self.venues = objects;
            [self.tableView reloadData];
            [self downloadImages];
        }
    }];
    return query;
}

-(void)downloadImages {
    
    for (PFObject *object in self.venues) {
        NSString *url = [object valueForKey:@"venueMainImage"];

            SDWebImageManager *manager = [SDWebImageManager sharedManager];
            [manager downloadImageWithURL:[NSURL URLWithString:url] options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize) {
            }
                                completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                                    
                                    [self.images addObject:image];
                                    
                                }];
                            }
}

- (void)createPresentControllerButton {
    
    self.presentControllerButton = [[UIButton alloc] init];
    [self createTransition];

}

-(void)createButton {
    
    CGFloat width = 50;
    
    //self.favButton = [[UIButton alloc] init];
    
    //self.favButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.view.frame)-64, CGRectGetHeight(self.view.frame)-276, 50, 50)];
    
    self.favButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.view.frame)-78, CGRectGetHeight(self.view.frame)-78, 56, 56)];
    
    self.favButton.layer.cornerRadius = width / 1.76;
    self.favButton.backgroundColor = [UIColor whiteColor];
    self.favButton.layer.shadowColor = [UIColor blackColor].CGColor;
    self.favButton.layer.shadowOpacity = 0.24;
    self.favButton.layer.shadowRadius = 1.95;
    self.favButton.layer.shadowOffset = CGSizeMake(1.95f, 1.95f);
    self.favButton.alpha = 1.0;
    
    [self.favButton setTitleColor:[UIColor colorWithWhite:0.0 alpha:0.0] forState:UIControlStateSelected];
    [self.favButton setImage:[UIImage imageNamed:@"pinkFav"] forState:UIControlStateNormal];
    [self.favButton setImage:[UIImage imageNamed:@"pinkFav"] forState:UIControlStateSelected];
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(expandButton:)];
    longPress.delegate = (id)self;
    longPress.minimumPressDuration = 0.01;
    [self.favButton addGestureRecognizer:longPress];
    [self.view addSubview:self.favButton];
    
}


-(void)expandButton: (UILongPressGestureRecognizer *)recognizer {
    
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        
        [UIView animateWithDuration:0.10 animations:^{
            self.favButton.transform = CGAffineTransformMakeScale(1.3, 1.3);
            
        } completion:^(BOOL finished) {
            self.favButton.transform = CGAffineTransformMakeScale(1.26, 1.26);
            
        }];
    }
    
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        
        [UIView animateWithDuration:0.9 animations:^{
            self.favButton.transform = CGAffineTransformMakeScale(1.26, 1.26);
            
        } completion:^(BOOL finished) {
            self.favButton.transform = CGAffineTransformMakeScale(1.0, 1.0);

            [self scrollToHomeView];
            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
            
        }];
    }
}

-(void)scrollToHomeView {
    
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    [appDelegate.swipeBetweenVC scrollToViewControllerAtIndex:1 animated:YES];
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    scrollView.delaysContentTouches = NO;
    
    CGRect frame = self.favButton.frame;
    //CGRect frame = CGRectMake(20, CGRectGetHeight(self.view.frame)-94, 50, 50);
    
    frame.origin.y = scrollView.contentOffset.y-24 + self.tableView.frame.size.height - self.favButton.frame.size.height;
    self.favButton.frame = frame;
    
    [self.view bringSubviewToFront:self.favButton];
    
    
    CGRect frame2 = self.topView.frame;
    //CGRect frame = CGRectMake(20, CGRectGetHeight(self.view.frame)-94, 50, 50);
    
    frame2.origin.y = scrollView.contentOffset.y+20 - self.topView.frame.size.height;
    self.topView.frame = frame2;
    
    [self.view bringSubviewToFront:self.topView];
    
}

- (void)createTransition {
    
    self.transitionTwo = [[StretchViewTransition alloc] initWithAnimatedView:self.presentControllerButton];
    
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented
                                                                  presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    self.transitionTwo.reverse = NO;
    return self.transitionTwo;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    
    self.transitionTwo.reverse = YES;
    return self.transitionTwo;
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

-(void)queryForRandomVenues {
    
    PFQuery *query = [PFQuery queryWithClassName:@""];
    [query whereKey:@"" equalTo:@""];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (error) {
            
        }
        else {
        }
    }];
}

-(void) queryForDasVenues {
    
    NSString *clientID = kCLIENTID;
    NSString *clientSecret = kCLIENTSECRET;
    
    NSString *url = [NSString stringWithFormat:@"https://api.foursquare.com/v2/venues/search?client_id=%@&client_secret=%@&v=20130815&ll=%f,%f&radius=2000&limit=7&categoryId=4bf58dd8d48988d14e941735", clientID, clientSecret, self.currentLocation.latitude, self.currentLocation.longitude];
    
    NSURL *googleRequestURL=[NSURL URLWithString:url];
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSData* data = [NSData dataWithContentsOfURL: googleRequestURL];
        [self performSelectorOnMainThread:@selector(fetchedData:) withObject:data waitUntilDone:YES];
    });
}

-(void)fetchedData:(NSData *)responseData {
    
    NSError* error;
    NSDictionary* json = [NSJSONSerialization
                          JSONObjectWithData:responseData
                          
                          options:kNilOptions
                          error:&error];
    
    
    NSArray *places = [[json objectForKey:@"response"] objectForKey:@"venues"];
    
    NSLog(@"Here: %lu", (unsigned long)places.count);
        
    
    NSObject *object = [[NSObject alloc] init];
    object = [places objectAtIndex:0];
    // NSLog(@"First Place: %@", object);
    
    NSMutableArray *americanRestaurants = [[NSMutableArray alloc] init];
    
    
    for (int i = 0; i < places.count; i++) {
        object = [places objectAtIndex:i];
        [americanRestaurants addObject:object];
        
    }
}

- (void) getAddressFromLatLon:(PFGeoPoint *)location {
    
    CLLocation *loca = [[CLLocation alloc] initWithLatitude:location.latitude longitude:location.longitude];
    
    CLGeocoder *geocoder = [[CLGeocoder alloc] init] ;
    [geocoder reverseGeocodeLocation:loca
                   completionHandler:^(NSArray *placemarks, NSError *error)
     {
         if (error){
             NSLog(@"Geocode failed with error: %@", error);
             return;
         }
         CLPlacemark *placemark = [placemarks objectAtIndex:0];
         self.userCity = placemark.locality;

         NSLog(@"Location: %@", self.userCity);
         
     }];
}

-(void) queryGooglePlaces: (NSString *) googleType {

    //NSString *url = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/search/json?location=%f,%f&radius=%@&types=%@&sensor=true&key=%@", self.currentLocation.latitude, self.currentLocation.longitude, [NSString stringWithFormat:@"%i", 10000], googleType, kGOOGLE_API_KEY];

   // NSString *url = @"https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=-33.8670522,151.1957362&radius=500&type=restaurant&name=cruise&key=YOUR_API_KEY";

    NSString *url = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=%f,%f&radius=1610&type=restaurant&key=%@",self.currentLocation.latitude, self.currentLocation.longitude, kGOOGLE_API_KEY];

    NSURL *googleRequestURL=[NSURL URLWithString:url];

    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

        NSData* data = [NSData dataWithContentsOfURL: googleRequestURL];
        [self performSelectorOnMainThread:@selector(fetchedData2:) withObject:data waitUntilDone:YES];
    });
}

-(void)fetchedData2:(NSData *)responseData {

    NSError* error;
    NSDictionary* json = [NSJSONSerialization
                          JSONObjectWithData:responseData

                          options:kNilOptions
                          error:&error];

    NSArray* places = [json objectForKey:@"results"];

    NSObject *object = [[NSObject alloc] init];
    object = [places objectAtIndex:0];
   // NSLog(@"First Place: %@", object);


    for (int i = 0; i < places.count; i++) {
        NSString *name = [places objectAtIndex:i];
        NSLog(@"Place %d: %@", i, name);
    }
}

@end
