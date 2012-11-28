//
//  HPTimelineViewController.m
//  hyperplan
//
//  Created by wuhaotian on 12-11-15.
//  Copyright (c) 2012年 Sohu Inc. All rights reserved.
//

#import "HPTimelineViewController.h"
#import "HPItemBubble.h"
#import "HPItemIndicator.h"
#import "HPConstants.h"
#import "Task.h"

#define AXIS_IMG [UIImage imageNamed:@"axis-2"]
#define AXIS_FRAME CGRectMake(320/5, 0, 15, 474)

#define BUBBLE_OFFSET_X (90)

#define SAMPLE_BUBBLE1_FRAME CGRectMake(BUBBLE_OFFSET_X, 20 + 60, 0, 0)
#define SAMPLE_BUBBLE2_FRAME CGRectMake(BUBBLE_OFFSET_X, 20, 0, 0)
#define SAMPLE_BUBBLE3_FRAME CGRectMake(BUBBLE_OFFSET_X, 20 + 60 + 120, 0, 0)
#define SAMPLE_BUBBLE4_FRAME CGRectMake(BUBBLE_OFFSET_X, 520, 0, 0)

#define INDICATOR_OFFSET_Y (14)
#define INDICATOR_X axis.center.x

UIScrollView * scrollView;
UIImageView * axis;

HPItemBubble * bubble1, * bubble2, * bubble3, * bubble4;
HPItemIndicator * indicator1, * indicator2, * indicator3, * indicator4;


@interface HPTimelineViewController ()

@end

@implementation HPTimelineViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)initContents
{
    /* set up axis */
    axis = [[UIImageView alloc] initWithImage:AXIS_IMG];
    axis.frame = AXIS_FRAME;
    [self.view addSubview:axis];
    
    /* set up scroll view */
    scrollView = [[UIScrollView alloc] initWithFrame:[self.view bounds]];
    scrollView.backgroundColor = MAIN_BG_COLOR;
    scrollView.contentSize = CGSizeMake(320, 640);
    [self.view addSubview:scrollView];
    
    /* add some sample items */
    NSDate * date1 = [NSDate date];
    bubble1 = [[HPItemBubble alloc] initWithContent:@"概率统计期中考试" andTime:date1 andFrame:SAMPLE_BUBBLE1_FRAME];
    [scrollView addSubview:bubble1];
    
    /* add indicators for the above items */
    indicator1 = [HPItemIndicator indicatorAt:CGPointMake(INDICATOR_X, 20+60+INDICATOR_OFFSET_Y)];
    [scrollView addSubview:indicator1];
    
    NSLog(@"%@",[[Task findAll] objectAtIndex:0]);
    
}

@end
