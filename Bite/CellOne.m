//
//  CellOne.m
//  justforfun
//
//  Created by Evan Latner on 8/11/16.
//  Copyright © 2016 Bite. All rights reserved.
//

#import "CellOne.h"

@implementation CellOne

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.venueIconImageView.layer.cornerRadius = self.venueIconImageView.frame.size.width/2;
    self.venueIconImageView.clipsToBounds = true;
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
    
}

@end
