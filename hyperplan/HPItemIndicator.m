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
#import "HPItemBubbleStack.h"

#define INDICATOR_IMAGE [UIImage imageNamed:@"indicator"]
#define INDICATOR_DEFAULT_FRAME CGRectMake(0, 0, 32, 32)
#define INDICATOR_IMAGE_FRAME CGRectMake(0, 0, 32, 32)
#define INDICATOR_LABEL_FRAME CGRectMake(9, 9, 14, 14)

#define INDICATOR_OFFSET_Y (14)
#define INDICATOR_X (71.5) //axis.center.x

@implementation HPItemIndicator
{
}

/*
 * DO NOT USE CALayer or Quartz2D drawing, they will make scrolling laggy.
 */

- (id)initWithFrame:(CGRect)frame andNumber:(NSInteger)number
{
    self = [super initWithFrame:frame];
    if (self) {
        self.number = number;
        self.backgroundColor = CLEAR_COLOR;
        
        /* set up background */
        self.backgroundView = [[UIImageView alloc] initWithImage:INDICATOR_IMAGE];
        self.backgroundView.frame = INDICATOR_IMAGE_FRAME;
        [self addSubview:self.backgroundView];
        
        /* set up label */
        self.label = [[UILabel alloc] initWithFrame:INDICATOR_LABEL_FRAME];
        self.label.text = [NSString stringWithFormat:@"%d", self.number];
        self.label.font = [UIFont fontWithName:@"ArialRoundedMTBold" size:12];
        self.label.textAlignment = NSTextAlignmentCenter;
        self.label.lineBreakMode = NSLineBreakByClipping;
        self.label.backgroundColor = CLEAR_COLOR;
        self.label.textColor = WHITE_COLOR;
        [self addSubview:self.label];
    }
    return self;
}

+ (id)indicatorAt:(CGPoint)center
{
    HPItemIndicator * indicator = [[HPItemIndicator alloc] initWithFrame:INDICATOR_DEFAULT_FRAME];
    indicator.center = center;
    
    return indicator;
}

+ (id)indicatorForBubble:(UIView *)bubble
{
    NSInteger number = 1;
    if ([bubble respondsToSelector:@selector(tasks)]) {
        number = [((HPItemBubbleStack *)bubble).tasks count];
    }

    HPItemIndicator * indicator = [[HPItemIndicator alloc] initWithFrame:INDICATOR_DEFAULT_FRAME andNumber:number];
    [indicator layoutForBubble:bubble];
 
    if ([bubble respondsToSelector:@selector(setIndicatorRef:)]) {
        [bubble performSelector:@selector(setIndicatorRef:) withObject:indicator];
    }
    
    return indicator;
}

- (void)layoutForBubble:(UIView *)bubble
{
    self.center = CGPointMake(INDICATOR_X, bubble.frame.origin.y + INDICATOR_OFFSET_Y);
}

- (void)enableEditMode
{
    [UIView beginAnimations:@"cancel edit mode" context:nil];
    [UIView setAnimationDuration:0.2];
    self.transform = CGAffineTransformMakeScale(0.4, 0.4);
    self.label.alpha = 0;
    [UIView commitAnimations];    
}

- (void)cancelEditMode
{
    [UIView beginAnimations:@"cancel edit mode" context:nil];
    [UIView setAnimationDuration:0.2];
    self.transform = CGAffineTransformIdentity;
    self.label.alpha = 1;
    [UIView commitAnimations];
}

@end
