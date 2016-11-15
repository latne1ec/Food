//
//  VenueView.m
//  
//
//  Created by Evan Latner on 8/11/16.
//
//

#import "VenueView.h"
#import "CellOne.h"
#import "CellTwo.h"
#import "SDWebImageManager.h"
#import "UIImageView+WebCache.h"

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#define kCLIENTID @"VPHBFYCGLAKRNZTCX2E2SUXQXQLZFVZ4JLWCRN5TCLFLW2CI"
#define kCLIENTSECRET @"MAJMGKNWIUNYHIBUGHSS2GSMMTV0M2T5T3LCTBYI0ZGOF22D"
#define kGOOGLE_API_KEY @"AIzaSyCJtSY62kZVP8VqRVPO0JbmwkeR7-IzM2I"

@implementation VenueView

- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        _appDelegate = [[UIApplication sharedApplication] delegate];

        self.backgroundColor = [UIColor colorWithWhite:0.5 alpha:0.80];
        UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
        [panRecognizer setMinimumNumberOfTouches:1];
        [panRecognizer setMaximumNumberOfTouches:1];
        panRecognizer.delegate = self;
        [self addGestureRecognizer:panRecognizer];
        
        _initialPosition = self.frame.origin;
        
        _tableView=[[UITableView alloc]init];
        _tableView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
        _tableView.dataSource=self;
        _tableView.delegate=self;
        _tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        _tableView.separatorColor = [UIColor clearColor];
        
        _tableView.layer.shadowColor = [UIColor blackColor].CGColor;
        _tableView.layer.shadowOpacity = 1.34;
        _tableView.layer.shadowRadius = 1.15;
        _tableView.layer.shadowOffset = CGSizeMake(-10.0f, 0.54f);
    
        [_tableView reloadData];
        [self addSubview:_tableView];
        
        UINib *nib = [UINib nibWithNibName:@"CellOne" bundle:nil];
        [[self tableView] registerNib:nib forCellReuseIdentifier:@"CellOne"];
        
        UINib *nib2 = [UINib nibWithNibName:@"CellTwo" bundle:nil];
        [[self tableView] registerNib:nib2 forCellReuseIdentifier:@"CellTwo"];

        
        UIBezierPath *maskPath;
        maskPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds
                                         byRoundingCorners:(UIRectCornerTopLeft|UIRectCornerTopRight)
                                               cornerRadii:CGSizeMake(16.0, 16.0)];
        
        CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
        maskLayer.frame = self.bounds;
        maskLayer.path = maskPath.CGPath;
        self.layer.mask = maskLayer;
        
//        self.clipsToBounds = true;
//        self.layer.cornerRadius = 16;
        
        self.layer.borderColor = [UIColor colorWithWhite:1.97 alpha:1.0].CGColor;
        //self.layer.borderColor = [self colorWithHexString:self.colorString].CGColor;
        self.layer.borderWidth = 6.2;

        _isUp = false;
        
        _tableView.scrollEnabled = false;
        
        [_tableView setContentInset:UIEdgeInsetsMake(0, 0, 54, 0)];
    }
    
    return self;
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

-(BOOL) gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    if (_isUp && _tableView.contentOffset.y <= 0){
        return YES;
    }
    return NO;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    if (indexPath.row == 0) {
        return 78;
    }
    
    if (indexPath.row == 1) {
        return 280;
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.row == 0) {
        CellOne *cell = (CellOne *)[tableView dequeueReusableCellWithIdentifier:@"CellOne" forIndexPath:indexPath];
        PFObject *object = self.venue;
        
        cell.venueNameLabel.text = [object objectForKey:@"name"];
        CLLocationDegrees lat = [[[[object objectForKey:@"location"] valueForKey:@"coordinate"] valueForKey:@"latitude"] doubleValue];
        CLLocationDegrees lon = [[[[object objectForKey:@"location"] valueForKey:@"coordinate"] valueForKey:@"longitude"] doubleValue];
        CLLocation *venueLocation = [[CLLocation alloc] initWithLatitude:lat longitude:lon];
        CLLocation *userLoca = [[CLLocation alloc] initWithLatitude:self.currentLocation.latitude longitude:self.currentLocation.longitude];
        
        CLLocationDistance distance = [userLoca distanceFromLocation:venueLocation];
        cell.venueDistanceLabel.text = [NSString stringWithFormat:@"%.1f miles",(distance/1609.344)];
        
        NSString *imageUrlString = [object objectForKey:@"image_url"];
        cell.venueIconImageView.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:imageUrlString]]];
        
        return cell;

    }
    
     if (indexPath.row == 1) {
         CellTwo *cell = (CellTwo *)[tableView dequeueReusableCellWithIdentifier:@"CellTwo" forIndexPath:indexPath];
         cell.venueImageView.layer.cornerRadius = 8;
         cell.venueImageView.clipsToBounds = true;
         return cell;
     }

    UITableViewCell *cell = [[UITableViewCell alloc] init];
    return cell;
}


-(void)updateViewDetails: (PFObject *)venue {
    
    self.venue = venue;
    [self getVenuePhotos];
    [self.tableView reloadData];
}

-(void)getVenuePhotos {
    
    _imageIndex = 0;
    if (self.venueImagesArray.count > 0) {
        [self.venueImagesArray removeAllObjects];
    }
    self.venueImagesArray = nil;
    [self showSingleImage];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    CellOne *cell = (CellOne *)[_tableView cellForRowAtIndexPath:indexPath];
    
    
    float lat = [[[[self.venue objectForKey:@"location"] valueForKey:@"coordinate"] valueForKey:@"latitude"] floatValue];
    float lon = [[[[self.venue objectForKey:@"location"] valueForKey:@"coordinate"] valueForKey:@"longitude"] floatValue];
    
    NSString *firstWordOfVenue = [[cell.venueNameLabel.text componentsSeparatedByString:@" "] objectAtIndex:0];
    
    NSCharacterSet *invalidCharSet = [[NSCharacterSet characterSetWithCharactersInString:@"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"] invertedSet];
    NSString *filtered = [[firstWordOfVenue componentsSeparatedByCharactersInSet:invalidCharSet] componentsJoinedByString:@""];
    
    
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
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:1 inSection:0];
    CellTwo *cell = (CellTwo *)[_tableView cellForRowAtIndexPath:indexPath];
    
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
    NSString *imageUrl = [self.venue objectForKey:@"image_url"];
    NSString *finalString = [imageUrl stringByReplacingOccurrencesOfString:@"ms" withString:@"o"];
    NSURL *finalUrl = [NSURL URLWithString:finalString];
    NSLog(@"final url: %@", finalUrl);
    
    currentImageView.image = cell.venueImageView.image;
    
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
    [cell.scrollView addSubview:cell.imageFade];
    [cell.scrollView bringSubviewToFront:cell.imageFade];
    cell.pageControl.alpha = 1.0;
    [cell.scrollView bringSubviewToFront:cell.pageControl];
}

-(void)fetchedPhotos: (NSData *)responseData {
    
    self.venueImagesArray = [[NSMutableArray alloc] init];
    
    NSError* error;
    NSDictionary* json = [NSJSONSerialization
                          JSONObjectWithData:responseData
                          
                          options:kNilOptions
                          error:&error];
    NSArray *results = [json valueForKey:@"result"];
    NSArray *photos = [results valueForKey:@"photos"];
    NSArray *photoRefs = [photos valueForKey:@"photo_reference"];
    
    //NSString *imageUrl = [self.venueIconArray objectAtIndex:_selectedIndex];
    NSString *imageUrl = [self.venue objectForKey:@"image_url"];
    NSString *finalString = [imageUrl stringByReplacingOccurrencesOfString:@"ms" withString:@"o"];
    [self.venueImagesArray addObject:finalString];
    
    for (int i = 1; i < photoRefs.count; i++) {
        NSString *photoref = [photoRefs objectAtIndex:i];
        NSString *photoRefUrl = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/photo?maxwidth=640&photoreference=%@&key=%@", photoref,kGOOGLE_API_KEY];
        [self.venueImagesArray addObject:photoRefUrl];
        NSLog(@"Venue Images Count: %lu", (unsigned long)self.venueImagesArray.count);
    }
    
    [self addImagesToScroller];
}

-(void)addImagesToScroller {
    
    [self downloadAllPics];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:1 inSection:0];
    CellTwo *cell = (CellTwo *)[_tableView cellForRowAtIndexPath:indexPath];
    
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
        if (self.venueImagesArray.count > 1) {
            //        UIImageView *imageview = (UIImageView *)[self.view viewWithTag:101];
            //        [cell.scrollView addSubview:imageview];
            //        [cell.scrollView bringSubviewToFront:imageview];
            [cell.scrollView bringSubviewToFront:cell.imageFade];
            [cell.scrollView bringSubviewToFront:cell.pageControl];
            cell.pageControl.alpha = 1.0;
    
        }
    
        [cell.scrollView bringSubviewToFront:cell.imageFade];
        [cell.scrollView bringSubviewToFront:cell.pageControl];
}

-(void)advanceToNextImage {
    
    NSLog(@"tap tap");
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:1 inSection:0];
    CellTwo *cell = (CellTwo *)[_tableView cellForRowAtIndexPath:indexPath];
    
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







- (void)handlePan:(UIPanGestureRecognizer *)recognizer {
    
    CGPoint vel = [recognizer velocityInView:self];
    if (vel.y > 0) {
        _tableView.scrollEnabled = false;
    }
    
    float yPosition = self.frame.origin.y;
    float height = self.bounds.size.height;
    
    if (yPosition/height < .3f) {
        
        CGPoint translation = [recognizer translationInView:self];
        if (!(_isUp && translation.y < 0)){
            recognizer.view.center = CGPointMake(self.frame.size.width/2,
                                                 recognizer.view.center.y + translation.y*.4);
        }
        [recognizer setTranslation:CGPointMake(0, 0) inView:self];
    }
    
    CGPoint translation = [recognizer translationInView:self];
    
    recognizer.view.center = CGPointMake(self.frame.size.width/2,
                                         recognizer.view.center.y + translation.y);
    
    [recognizer setTranslation:CGPointMake(0, 0) inView:self];
    
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        
        if ((_isUp && yPosition/height > 0.3f) || (!_isUp && yPosition/height >= 0.9f)) {
            [UIView animateWithDuration:0.25 animations:^{
                self.frame = CGRectMake(0, _initialPosition.y+7, self.frame.size.width, self.frame.size.height);
                _tableView.scrollEnabled = false;
            } completion:^(BOOL finished) {
                _isUp = false;
                [UIView animateWithDuration:0.2 animations:^{
                    self.frame = CGRectMake(0, _initialPosition.y, self.frame.size.width, self.frame.size.height);
                } completion:^(BOOL finished) {
                }];
            }];
        } else if ((!_isUp && yPosition/height < 0.9f)){
            [UIView animateWithDuration:0.25 animations:^{
                
                self.frame = CGRectMake(0, self.superview.frame.size.height - self.frame.size.height-6, self.frame.size.width, self.frame.size.height);
                _tableView.scrollEnabled = true;
            } completion:^(BOOL finished) {
                _isUp = true;
                [UIView animateWithDuration:0.2 animations:^{
                    self.frame = CGRectMake(0, self.superview.frame.size.height - self.frame.size.height, self.frame.size.width, self.frame.size.height);
                } completion:^(BOOL finished) {
                }];
            }];
        }
    }
}

@end
