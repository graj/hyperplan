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
#import "HPItemBubble.h"

#define INDICATOR_DATE_FONT [UIFont fontWithName:@"HiraginoSansGB-W3" size:12]
#define INDICATOR_TIME_HOUR_FONT [UIFont fontWithName:@"HelveticaNeue-CondensedBold" size:30]
#define INDICATOR_TIME_MINUTE_FONT [UIFont fontWithName:@"HelveticaNeue-CondensedBold" size:15]
#define INDICATOR_TIME_AMPM_FONT [UIFont fontWithName:@"HelveticaNeue-CondensedBold" size:9]

#define INDICATOR_DATE_COLOR WHITE_COLOR
#define INDICATOR_TIME_COLOR [UIColor colorWithRed:58/255. green:61/255. blue:61/255. alpha:1]
#define INDICATOR_TIME_AMPM_COLOR [UIColor colorWithRed:126/255. green:131/255. blue:132/255. alpha:1]

#define INDICATOR_STICKY_FRAME CGRectMake(0, 0, 76, 19)
#define INDICATOR_DATE_FRAME CGRectMake(0, 0, 76, 19)
#define INDICATOR_TIME_HOUR_FRAME CGRectMake(0, 20, 29, 37) /* due to font line height */
#define INDICATOR_TIME_MINUTE_FRAME CGRectMake(30, 24, 15, 20)
#define INDICATOR_TIME_AMPM_FRAME CGRectMake(31, 40, 12, 12)

#define INDICATOR_IMAGE [UIImage imageNamed:@"indicator"]
#define INDICATOR_DEFAULT_FRAME CGRectMake(0, 0, 76, 51)
#define INDICATOR_IMAGE_FRAME CGRectMake(0, 0, 32, 32)
#define INDICATOR_LABEL_FRAME CGRectMake(9, 9, 14, 14)

#define INDICATOR_OFFSET_Y (14)
#define INDICATOR_X (8)

@implementation HPItemIndicator
{
    UIView * sticky;
    UILabel * dateLabel;
    UILabel * hourLabel;
    UILabel * minuteLabel;
    UILabel * ampmLabel;
}

- (id)initWithFrame:(CGRect)frame andDate:(NSDate *)date andColor:(UIColor *)color
{
    self = [super initWithFrame:frame];
    if (self) {
        self.number = 0;
        self.date = date;
        self.backgroundColor = CLEAR_COLOR;
        
        /* set up sticky */
        sticky = [[UIView alloc] initWithFrame:INDICATOR_STICKY_FRAME];
        sticky.backgroundColor = color;
//        sticky.layer.shadowColor = [BLACK_COLOR CGColor];
//        sticky.layer.shadowOffset = CGSizeMake(0, 0.5);
//        sticky.layer.shadowOpacity = 0.5;
//        sticky.layer.shadowRadius = 0.5;
//        sticky.layer.masksToBounds = NO;

        [self addSubview:sticky];
        
        dateLabel = [[UILabel alloc] initWithFrame:INDICATOR_DATE_FRAME];
        NSDateFormatter * df = [[NSDateFormatter alloc] init];
        [df setDateFormat:@"yyyy.MM.dd"];
        NSString * dateString = [df stringFromDate:self.date];
        dateLabel.text = dateString;
        dateLabel.textColor = INDICATOR_DATE_COLOR;
        dateLabel.backgroundColor = CLEAR_COLOR;
        dateLabel.font = INDICATOR_DATE_FONT;
        dateLabel.center = CGPointMake(sticky.center.x, sticky.center.y + 3);   /* due to font line height */
        dateLabel.textAlignment = NSTextAlignmentCenter;
        
        [self addSubview:dateLabel];
        
        /* set up time labels */
        hourLabel = [[UILabel alloc] initWithFrame:INDICATOR_TIME_HOUR_FRAME];
        [df setDateFormat:@"h"];    /* 12-hour issue */
        int hour = [[df stringFromDate:self.date] intValue];
        if (hour > 12) hour -= 12;
        hourLabel.text = [NSString stringWithFormat:@"%d", hour];
        hourLabel.textColor = INDICATOR_TIME_COLOR;
        hourLabel.backgroundColor = CLEAR_COLOR;
        hourLabel.font = INDICATOR_TIME_HOUR_FONT;
        hourLabel.textAlignment = NSTextAlignmentRight;
        hourLabel.shadowColor = WHITE_COLOR;
        hourLabel.shadowOffset = CGSizeMake(0, 1);

        [self addSubview:hourLabel];
        
        ampmLabel = [[UILabel alloc] initWithFrame:INDICATOR_TIME_AMPM_FRAME];
        ampmLabel.text = [[df stringFromDate:self.date] intValue] <= 12 ? @"AM" : @"PM";;
        ampmLabel.textColor = INDICATOR_TIME_AMPM_COLOR;
        ampmLabel.backgroundColor = CLEAR_COLOR;
        ampmLabel.font = INDICATOR_TIME_AMPM_FONT;
        ampmLabel.shadowColor = WHITE_COLOR;
        ampmLabel.shadowOffset = CGSizeMake(0, 1);

        [self addSubview:ampmLabel];
        
        minuteLabel = [[UILabel alloc] initWithFrame:INDICATOR_TIME_MINUTE_FRAME];
        [df setDateFormat:@"mm"];
        NSString * minuteString = [df stringFromDate:self.date];
        minuteLabel.text = minuteString;
        minuteLabel.textColor = INDICATOR_TIME_COLOR;
        minuteLabel.backgroundColor = CLEAR_COLOR;
        minuteLabel.font = INDICATOR_TIME_MINUTE_FONT;
        minuteLabel.shadowColor = WHITE_COLOR;
        minuteLabel.shadowOffset = CGSizeMake(0, 1);

        [self addSubview:minuteLabel];
    }
    return self;
}

+ (id)indicatorAt:(CGPoint)center
{
    HPItemIndicator * indicator = [[HPItemIndicator alloc] initWithFrame:INDICATOR_DEFAULT_FRAME];
    indicator.center = center;
    
    return indicator;
}

+ (id)indicatorForBubble:(HPItemBubble *)bubble
{
    NSInteger number = 1;
    if ([bubble respondsToSelector:@selector(tasks)]) {
        number = [((HPItemBubbleStack *)bubble).tasks count];
    }

    HPItemIndicator * indicator = [[HPItemIndicator alloc] initWithFrame:INDICATOR_DEFAULT_FRAME andDate:bubble.task.time andColor:bubble.color];
    [indicator layoutForBubble:bubble];
 
    if ([bubble respondsToSelector:@selector(setIndicatorRef:)]) {
        [bubble performSelector:@selector(setIndicatorRef:) withObject:indicator];
    }
    
    return indicator;
}

- (void)setNumber:(NSInteger)number
{
    _number = number;
    self.label.text = [NSString stringWithFormat:@"%d", self.number];
}

- (void)layoutForBubble:(UIView *)bubble
{
    CGRect frame = self.frame;
    frame.origin.x = INDICATOR_X;
    frame.origin.y = bubble.frame.origin.y + INDICATOR_OFFSET_Y;
    self.frame = frame;
}

- (void)enableEditMode
{
//    [UIView beginAnimations:@"cancel edit mode" context:nil];
//    [UIView setAnimationDuration:0.2];
//    self.transform = CGAffineTransformMakeScale(0.8, 0.8);
//    self.label.alpha = 0;
//    [UIView commitAnimations];    
}

- (void)cancelEditMode
{
//    [UIView beginAnimations:@"cancel edit mode" context:nil];
//    [UIView setAnimationDuration:0.2];
//    self.transform = CGAffineTransformIdentity;
//    self.label.alpha = 1;
//    [UIView commitAnimations];
}

@end
