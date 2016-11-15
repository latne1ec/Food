//
//  VenueTableCell.m
//  justforfun
//
//  Created by Evan Latner on 7/12/15.
//  Copyright (c) 2015 Bite. All rights reserved.
//

#import "VenueTableCell.h"
#import "SecondViewController.h"

@implementation VenueTableCell

- (void)awakeFromNib {
    // Initialization code
    
    self.directionsButton.alpha = 0;
    self.photosButton.alpha = 0;
    self.scrollView.alpha = 0;
    self.upArrow.alpha = 0;
    self.deployed = false;
    self.mapView.alpha = 0.0;
    self.likeScoreLabel.alpha = 0.0;
    
    self.photosButton.layer.cornerRadius = 4.4;
    self.directionsButton.layer.cornerRadius = 4.4;
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
