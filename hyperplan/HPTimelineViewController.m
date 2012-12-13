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
#define BACKGROUND_VIEW_FRAME CGRectMake(0, 0, 320, 474)

#define BUBBLE_PADDING (5)

@interface HPTimelineViewController ()

@end

@implementation HPTimelineViewController
{
    UIScrollView * scrollView;
    UIImageView * axis;
    UIView * backgroundView;
    UIPinchGestureRecognizer * pinchRecognizer;
    CGFloat lastScale;
    CGFloat scale;
}

- (void)initContents
{
    /* set up axis */
    axis = [[UIImageView alloc] initWithImage:AXIS_IMG];
    axis.frame = AXIS_FRAME;
    [self.view addSubview:axis];
    
    pinchRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinched:)];
    scale = lastScale = 1.;
    
    /* set up scroll view */
    scrollView = [[UIScrollView alloc] initWithFrame:[self.view bounds]];
    scrollView.backgroundColor = MAIN_BG_COLOR;
    scrollView.contentSize = CGSizeMake(320, 640);
    [scrollView addGestureRecognizer:pinchRecognizer];

    [self.view addSubview:scrollView];
    
    /* background view */
    backgroundView = [[UIView alloc] initWithFrame:BACKGROUND_VIEW_FRAME];
    [scrollView addSubview:backgroundView];
    backgroundView.alpha = 0.75;
    
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
         frame.origin.y = [task YOffsetForScale:scale inType:HPItemBubbleScaleLinear];
         maxHeight = MAX(maxHeight, frame.origin.y);
         [bubble setFrame:frame];
         
         /* dynamically set up scrollView's content size */
         scrollView.contentSize = CGSizeMake(scrollView.contentSize.width, maxHeight + 80);
         //TODO: should dynamically update scrollView's contentSize here.
    }];
    
    /* detect bubble overlap and replace with bubble stack */
    for (int i = 1; i < [_bubbles count]; i++) {
        break;
        
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

- (void)layoutBubbles
{
    // 1. re-calculate the y offset for bubbles, then apply them
    // 2. update scrollview's content offset
    // 3. covering detect
    // 4. animate
    // 5. update scrollview's content size and/or offset
    
    [_bubbles enumerateObjectsUsingBlock:^(HPItemBubble * bubble, NSUInteger idx, BOOL * stop) {
        CGRect bubbleFrame = bubble.frame;
        CGFloat y = [bubble.task YOffsetForScale:scale inType:HPItemBubbleScaleLinear];
        bubbleFrame.origin.y = y;
        bubble.frame = bubbleFrame;
        [bubble.indicatorRef layoutForBubble:bubble];
    }];
}

static CGFloat lastTouch0y;
static CGFloat lastTouch1y;

- (void)pinched:(UIPinchGestureRecognizer *)sender
{
    /////////////////////////////////////////////////////////////////////////
    
    /* filter if only one touch */
    if (sender.numberOfTouches < 2) {
        return;
    }
    
    /* get touches location */
    CGFloat touch0y = [sender locationOfTouch:0 inView:self.view].y;
    CGFloat touch1y = [sender locationOfTouch:1 inView:self.view].y;
    
    /* assign the static variables for the first time */
    if (sender.state == UIGestureRecognizerStateBegan) {
        lastTouch0y = touch0y;
        lastTouch1y = touch1y;
        return;
    }
    
    /* calculate scale and center-of-touches */
    scale = lastScale * (touch1y - touch0y) / (lastTouch1y - lastTouch0y);
    
    if (scale > 5) scale = 5;
    if (scale < 0.2) scale = 0.2;
    
    CGFloat lastTouchesCenter = (lastTouch0y + lastTouch1y) / 2;
    CGFloat touchesCenter = (touch0y + touch1y) / 2;
    
    /* TangYuanchao's equation */
    CGFloat contentOffsetY = (lastTouchesCenter + scrollView.contentOffset.y) * scale / lastScale - touchesCenter;
    
    /* modify scrollview's size and position */
    scrollView.contentOffset = CGPointMake(scrollView.contentOffset.x, contentOffsetY);
    scrollView.contentSize = CGSizeMake(scrollView.contentSize.width, scrollView.contentSize.height / lastScale * scale);
    
    /* move bubbles to their position */
    [self layoutBubbles];

    /* update static variables */
    lastScale = scale;
    lastTouch0y = touch0y;
    lastTouch1y = touch1y;
}

@end
