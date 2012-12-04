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

#define BUBBLE_PADDING (5)

@interface HPTimelineViewController ()

@end

@implementation HPTimelineViewController
{
    UIScrollView * scrollView;
    UIImageView * axis;
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
    
    /* create bubbles array */
    _bubbles = [NSMutableArray array];
    
    /* build bubbles */
    __block CGFloat maxHeight = 0;
    [[Task findAllSortedBy:@"time" ascending:YES] enumerateObjectsUsingBlock:
     ^(Task * task, NSUInteger idx, BOOL *stop) {
         HPItemBubble * bubble = [HPItemBubble bubbleWithTask:task];
         
         /* put reference into the bubbles array */
         [_bubbles addObject:bubble];
         
         /* set up bubble's parent view reference */
         bubble.scrollViewRef = scrollView;
         
         /* set up bubble's frame */
         CGRect frame = bubble.frame;
         frame.origin.y = [task YOffsetForScale:HPItemBubbleScaleLinear];
         maxHeight = MAX(maxHeight, frame.origin.y);
         [bubble setFrame:frame];
         
         /* dynamically set up scrollView's content size */
         scrollView.contentSize = CGSizeMake(scrollView.contentSize.width, maxHeight + 80);
         //TODO: should dynamically update scrollView's contentSize here.
    }];
    
    /* detect bubble overlap and replace with bubble stack */
    for (int i = 1; i < [_bubbles count]; i++) {
        UIView * previous = _bubbles[i - 1];
        UIView * bubble = _bubbles[i];
        
        if (bubble.frame.origin.y > previous.frame.origin.y + previous.frame.size.height + BUBBLE_PADDING) {
            continue;
        }

        if ([previous isKindOfClass:[HPItemBubble class]]) {
            /* remove both view and create a bubble stack */
            NSLog(@"overlap 1: %@", ((HPItemBubble *)bubble).task.title);
            HPItemBubbleStack * stack = [HPItemBubbleStack bubbleStackWithTasks:@[((HPItemBubble *)previous).task, ((HPItemBubble *)bubble).task]];
            [_bubbles replaceObjectAtIndex:[_bubbles indexOfObject:previous] withObject:stack];
            stack.scrollViewRef = scrollView;
            stack.frame = bubble.frame;
        }
        else if ([previous isKindOfClass:[HPItemBubbleStack class]]) {
            /* remove this bubble and insert its task into the bubble stack */
            NSLog(@"overlap 2: %@", ((HPItemBubble *)bubble).task.title);
            HPItemBubbleStack * stack = (HPItemBubbleStack *)previous;
            [stack addTask:((HPItemBubble *)bubble).task];
        }
        [_bubbles removeObject:bubble];
        i--;
    }
    
    /* create the indicators for the bubbles and insert them as subview */
    [_bubbles enumerateObjectsUsingBlock:^(UIView * bubble, NSUInteger idx, BOOL * stop) {
        /* initializing the indicator requires bubble's frame */
        HPItemIndicator * indicator = [HPItemIndicator indicatorForBubble:bubble];
        [scrollView addSubview:bubble];
        [scrollView addSubview:indicator];
    }];
}

@end
