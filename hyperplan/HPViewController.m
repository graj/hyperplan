//
//  ViewController.m
//  hyper-plan-testfield
//
//  Created by Phil on 11/1/12.
//  Copyright (c) 2012 Sohu Inc.. All rights reserved.
//

#import "HPConstants.h"
#import "HPViewController.h"
#import "HPNavigationBar.h"
#import "HPItemBubble.h"
#import "HPItemIndicator.h"
#import "QuartzCore/CALayer.h"

#define MAIN_BG_COLOR (LIGHT_MASK_COLOR)
#define NAV_FRAME CGRectMake(0, 0, 320, 44)
#define MAIN_FRAME CGRectMake(0, 44, 320, 416)
#define AXIS_IMG [UIImage imageNamed:@"axis-2"]
#define AXIS_FRAME CGRectMake(320/5, 44, 15, 430)

#define BUBBLE_OFFSET_X (90)

#define SAMPLE_BUBBLE1_FRAME CGRectMake(BUBBLE_OFFSET_X, 20 + 60, 0, 0)
#define SAMPLE_BUBBLE2_FRAME CGRectMake(BUBBLE_OFFSET_X, 20, 0, 0)
#define SAMPLE_BUBBLE3_FRAME CGRectMake(BUBBLE_OFFSET_X, 20 + 60 + 120, 0, 0)
#define SAMPLE_BUBBLE4_FRAME CGRectMake(BUBBLE_OFFSET_X, 520, 0, 0)

#define INDICATOR_OFFSET_Y (14)
#define INDICATOR_X (axis.center.x)


@implementation ViewController

HPNavigationBar * navigationBar;
UIScrollView * scrollView;
UIImageView * axis;

HPItemBubble * bubble1, * bubble2, * bubble3, * bubble4;
HPItemIndicator * indicator1, * indicator2, * indicator3, * indicator4;

#pragma mark Lifecycle

- (void)viewDidLoad
{

    [super viewDidLoad];
    self.view.backgroundColor = MAIN_VIEW_TEXTURE;
    
    /* set up axis */
    axis = [[UIImageView alloc] initWithImage:AXIS_IMG];
    axis.frame = AXIS_FRAME;
    [self.view addSubview:axis];
    
    /* set up navigation bar */
    navigationBar = [[HPNavigationBar alloc] initWithFrame:NAV_FRAME];
    navigationBar.delegate = self;
    [self.view addSubview:navigationBar];
    
    /* set up scroll view */
    scrollView = [[UIScrollView alloc] initWithFrame:MAIN_FRAME];
    scrollView.backgroundColor = MAIN_BG_COLOR;
    scrollView.contentSize = CGSizeMake(320, 640);
    [self.view addSubview:scrollView];

    /* add some sample items */
    bubble1 = [[HPItemBubble alloc] initWithContent:@"概率统计期中考试" andTime:@"11月15日" andFrame:SAMPLE_BUBBLE1_FRAME];
    bubble2 = [[HPItemBubble alloc] initWithContent:@"数理逻辑" andTime:@"11月14日" andFrame:SAMPLE_BUBBLE2_FRAME];
    bubble3 = [[HPItemBubble alloc] initWithContent:@"某些人要过生日啦" andTime:@"11月22日" andFrame:SAMPLE_BUBBLE3_FRAME];
    bubble4 = [[HPItemBubble alloc] initWithContent:@"体系结构考试" andTime:@"11月27日" andFrame:SAMPLE_BUBBLE4_FRAME];
    [scrollView addSubview:bubble1];
    [scrollView addSubview:bubble2];
    [scrollView addSubview:bubble3];
    [scrollView addSubview:bubble4];
    
    /* add indicators for the above items */
    indicator1 = [HPItemIndicator indicatorAt:CGPointMake(INDICATOR_X, 20+60+INDICATOR_OFFSET_Y)];
    indicator2 = [HPItemIndicator indicatorAt:CGPointMake(INDICATOR_X, 20+INDICATOR_OFFSET_Y)];
    indicator3 = [HPItemIndicator indicatorAt:CGPointMake(INDICATOR_X, 20+60+120+INDICATOR_OFFSET_Y)];
    indicator4 = [HPItemIndicator indicatorAt:CGPointMake(INDICATOR_X, 520+INDICATOR_OFFSET_Y)];
    [scrollView addSubview:indicator1];
    [scrollView addSubview:indicator2];
    [scrollView addSubview:indicator3];
    [scrollView addSubview:indicator4];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


#pragma mark - Navigation Bar button actions from HPNavigationBarDeletage

- (void)navbarMenuButtonPressed:(id)sender
{
    NSLog(@"menu pressed FROM viewController");
}

- (void)navbarAddButtonPressed:(id)sender
{
    NSLog(@"add pressed FROM viewController");
}

- (void)menuItemPressed:(NSInteger)index
{
    NSLog(@"menu item %d pressed FROM viewController", index);
}

- (void)splitButtonPressed:(NSInteger)index
{
    NSLog(@"split button %d pressed FROM viewController", index);
}

@end
