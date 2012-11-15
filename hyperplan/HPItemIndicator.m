//
//  HPItemIndicator.m
//  hyper-plan-testfield
//
//  Created by Phil on 11/9/12.
//  Copyright (c) 2012 Sohu Inc. All rights reserved.
//

#import "HPConstants.h"
#import "HPItemIndicator.h"
#import "QuartzCore/CALayer.h"

#define INDICATOR_IMAGE [UIImage imageNamed:@"indicator"]
#define INDICATOR_DEFAULT_FRAME CGRectMake(0, 0, 32, 32)
#define INDICATOR_IMAGE_FRAME CGRectMake(0, 0, 32, 32)
#define INDICATOR_LABEL_FRAME CGRectMake(9, 9, 14, 14)


@implementation HPItemIndicator

UIImageView * backgroundView;
UILabel * label;

/*
 * DO NOT USE CALayer or Quartz2D drawing, they will make scrolling laggy.
 */

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.number = 1;
        self.backgroundColor = CLEAR_COLOR;
        
        /* set up background */
        backgroundView = [[UIImageView alloc] initWithImage:INDICATOR_IMAGE];
        backgroundView.frame = INDICATOR_IMAGE_FRAME;
        [self addSubview:backgroundView];
        
        /* set up label */
        label = [[UILabel alloc] initWithFrame:INDICATOR_LABEL_FRAME];
        label.text = [NSString stringWithFormat:@"%d", self.number];
        label.font = [UIFont fontWithName:@"ArialRoundedMTBold" size:12];
        label.textAlignment = NSTextAlignmentCenter;
        label.lineBreakMode = NSLineBreakByClipping;
        label.backgroundColor = CLEAR_COLOR;
        label.textColor = WHITE_COLOR;
        [self addSubview:label];
    }
    return self;
}

+ (id)indicatorAt:(CGPoint)center
{
    HPItemIndicator * indicator = [[HPItemIndicator alloc] initWithFrame:INDICATOR_DEFAULT_FRAME];
    indicator.center = center;
    
    return indicator;
}



@end
