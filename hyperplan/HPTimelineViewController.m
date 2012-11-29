//
//  HPTimelineViewController.m
//  hyperplan
//
//  Created by wuhaotian on 12-11-15.
//  Copyright (c) 2012年 Sohu Inc. All rights reserved.
//

#import "HPTimelineViewController.h"
#import "HPItemBubble.h"
#import "HPItemBubbleStack.h"
#import "HPItemIndicator.h"
#import "HPConstants.h"
#import "Task.h"
#import "Task+Layout.h"

#define AXIS_IMG [UIImage imageNamed:@"axis-2"]
#define AXIS_FRAME CGRectMake(320/5, 0, 15, 474)

UIScrollView * scrollView;
UIImageView * axis;

@interface HPTimelineViewController ()

@end

@implementation HPTimelineViewController

- (void)initContents
{
    /* set up axis */
    axis = [[UIImageView alloc] initWithImage:AXIS_IMG];
    axis.frame = AXIS_FRAME;
    [self.view addSubview:axis];
    
    /* set up scroll view */
    scrollView = [[UIScrollView alloc] initWithFrame:[self.view bounds]];
//    scrollView.backgroundColor = MAIN_BG_COLOR;
    scrollView.contentSize = CGSizeMake(320, 640);
    [self.view addSubview:scrollView];
    
    /* add items */
    __block CGFloat maxHeight = 0;
    [[Task findAllSortedBy:@"time" ascending:YES] enumerateObjectsUsingBlock:
     ^(Task * task, NSUInteger idx, BOOL *stop) {
         HPItemBubble * bubble = [HPItemBubble bubbleWithTask:task];
//         HPItemBubbleStack * bubble = [HPItemBubbleStack bubbleStackWithTasks:@[task]];
         
         /* set up bubble's parent view reference */
         bubble.scrollViewRef = scrollView;
         
         /* set up bubble's frame */
         CGRect frame = bubble.frame;
         frame.origin.y = [task YOffsetForScale:HPItemBubbleScaleExponential];
         maxHeight = MAX(maxHeight, frame.origin.y);
         [bubble setFrame:frame];
         
         /* initializing the indicator requires bubble's frame */
         HPItemIndicator * indicator = [HPItemIndicator indicatorForBubble:bubble];
         
         /* dynamically set up scrollView's content size */
         scrollView.contentSize = CGSizeMake(scrollView.contentSize.width, maxHeight + 80);
         //TODO: should dynamically update scrollView's contentSize here.
         [scrollView addSubview:bubble];
         [scrollView addSubview:indicator];
    }];
}


@end
