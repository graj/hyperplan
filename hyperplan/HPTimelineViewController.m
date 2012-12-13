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
         bubble.scrollViewRef = scrollView;
         [_bubbles addObject:bubble];
     }];    
         
    [self layoutBubbles];
    
    /* create the indicators for the bubbles and insert them as subview */
    [_bubbles enumerateObjectsUsingBlock:^(UIView * bubble, NSUInteger idx, BOOL * stop) {
        /* initializing the indicator requires bubble's frame */
        HPItemIndicator * indicator = [HPItemIndicator indicatorForBubble:bubble];
        [scrollView addSubview:bubble];
        [scrollView addSubview:indicator];
        maxHeight = MAX(maxHeight, bubble.frame.origin.y);
    }];
    
    /* dynamically set up scrollView's content size */
    scrollView.contentSize = CGSizeMake(scrollView.contentSize.width, maxHeight + 80);
    
    [self rearrangeBubbles];
}

- (void)layoutBubbles
{
    [_bubbles enumerateObjectsUsingBlock:^(HPItemBubble * bubble, NSUInteger idx, BOOL * stop) {
        CGRect bubbleFrame = bubble.frame;
        CGFloat y = [bubble.task YOffsetForScale:scale inType:HPItemBubbleScaleLinear];
        bubbleFrame.origin.y = y;
        bubble.frame = bubbleFrame;
        bubble.standardRect = bubbleFrame;
        [bubble.indicatorRef layoutForBubble:bubble];
    }];
}

- (void)scaleBubbles
{
    [_bubbles enumerateObjectsUsingBlock:^(HPItemBubble * bubble, NSUInteger idx, BOOL * stop) {
        CGFloat y = bubble.frame.origin.y / lastScale * scale;
        CGRect bubbleFrame = bubble.frame;
        bubbleFrame.origin.y = y;
        bubble.frame = bubbleFrame;
        bubbleFrame.origin.y = [bubble.task YOffsetForScale:scale inType:HPItemBubbleScaleLinear];
        bubble.standardRect = bubbleFrame;
        [bubble.indicatorRef layoutForBubble:bubble];
    }];
}

- (void)rearrangeBubbles
{
    if ([_bubbles count] < 2) {
        return;
    }
    NSLog(@"Rearranging...");

    HPItemBubble * pivotBubble, * bubble;
    
    [UIView beginAnimations:@"Move bubbles" context:nil];
    [UIView setAnimationDuration:0.3];

    // detect overlay and animate to merge
    pivotBubble = _bubbles[0];
    for (int i = 1; i < [_bubbles count]; i++) {
        bubble = _bubbles[i];
        if (!CGRectEqualToRect(bubble.frame, pivotBubble.frame) &&
            CGRectIntersectsRect(bubble.standardRect, pivotBubble.frame)) {
            NSLog(@"Merging %@ & %@", pivotBubble.task.title, bubble.task.title);
            NSLog(@"bubble frame: %f %f %f %f, bubble standardRect: %f %f %f %f, pivotBubble frame: %f %f %f %f", bubble.frame.origin.x, bubble.frame.origin.y, bubble.frame.size.width, bubble.frame.size.height, bubble.standardRect.origin.x, bubble.standardRect.origin.y, bubble.standardRect.size.width, bubble.standardRect.size.height, pivotBubble.frame.origin.x, pivotBubble.frame.origin.y, pivotBubble.frame.size.width, pivotBubble.frame.size.height);
            [bubble mergeToBubble:pivotBubble];
        }
        else {
            pivotBubble = bubble;
        }
    }
    
    // NEED to verify algorithm carefully
    pivotBubble = _bubbles[0];
    for (int i = 1; i < [_bubbles count]; i++) {
        bubble = _bubbles[i];
        if (bubble.merged && !CGRectIntersectsRect(bubble.standardRect, pivotBubble.frame)) {
            NSLog(@"Resuming %@ from %@", bubble.task.title, pivotBubble.task.title);
            NSLog(@"bubble frame: %f %f %f %f, bubble standardRect: %f %f %f %f, pivotBubble frame: %f %f %f %f", bubble.frame.origin.x, bubble.frame.origin.y, bubble.frame.size.width, bubble.frame.size.height, bubble.standardRect.origin.x, bubble.standardRect.origin.y, bubble.standardRect.size.width, bubble.standardRect.size.height, pivotBubble.frame.origin.x, pivotBubble.frame.origin.y, pivotBubble.frame.size.width, pivotBubble.frame.size.height);
            [bubble resumeStandardPositionFrom:pivotBubble];
        }
        pivotBubble = bubble;
    }
    
    [UIView commitAnimations];
}

static CGFloat lastTouch0y;
static CGFloat lastTouch1y;
#define TIMELINE_SCALE_MIN 0.2
#define TIMELINE_SCALE_MAX 5

- (void)pinched:(UIPinchGestureRecognizer *)sender
{
    /////////////////////////////////////////////////////////////////////////
    if (sender.state == UIGestureRecognizerStateEnded) {
        [self rearrangeBubbles];
        return;
    }
    
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
    
    if (scale < TIMELINE_SCALE_MIN) scale = TIMELINE_SCALE_MIN;
    if (scale > TIMELINE_SCALE_MAX) scale = TIMELINE_SCALE_MAX;
    
    CGFloat lastTouchesCenter = (lastTouch0y + lastTouch1y) / 2;
    CGFloat touchesCenter = (touch0y + touch1y) / 2;
    
    /* TangYuanchao's equation */
    CGFloat contentOffsetY = (lastTouchesCenter + scrollView.contentOffset.y) * scale / lastScale - touchesCenter;
    
    /* modify scrollview's size and position */
    scrollView.contentOffset = CGPointMake(scrollView.contentOffset.x, contentOffsetY);
    scrollView.contentSize = CGSizeMake(scrollView.contentSize.width, scrollView.contentSize.height / lastScale * scale);
    
    /* move bubbles to their position */
    [self scaleBubbles];

    /* update static variables */
    lastScale = scale;
    lastTouch0y = touch0y;
    lastTouch1y = touch1y;
}

@end
