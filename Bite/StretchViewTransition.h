//
//  StretchViewTransition.h
//  justforfun
//
//  Created by Evan Latner on 7/12/15.
//  Copyright (c) 2015 Bite. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@interface StretchViewTransition : NSObject <UIViewControllerAnimatedTransitioning>

@property (weak, nonatomic) UIView *animatedView;

@property (nonatomic) CGRect startFrame;
@property (nonatomic) UIColor *startBackgroundColor;

@property (getter=isReverse) BOOL reverse;

- (instancetype)initWithAnimatedView:(UIView *)animatedView;


@end
