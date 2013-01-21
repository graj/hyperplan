//
//  HPTimelineViewController.m
//  hyperplan
//
//  Created by wuhaotian on 12-11-15.
//  Copyright (c) 2012年 Sohu Inc. All rights reserved.
//

#import "HPTimelineViewController.h"
#import "HPItemBubble.h"
#import "HPBubbleSetList.h"
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
    CGFloat oldestScale;//  appended by Tang Yuanchao
    CGFloat justScale;  //  appended by Tang Yuanchao
    CGFloat justOffsetY;//  appended by Tang Yuanchao
    HPBubbleSetList * mySetList;//  appended by Tang Yuanchao
    Boolean isDoubleTapped; //  appended by Tang Yuanchao
}

- (void)initContents
{
    /* set up axis */
    axis = [[UIImageView alloc] initWithImage:AXIS_IMG];
    axis.frame = AXIS_FRAME;
    [self.view addSubview:axis];
    
    pinchRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinched:)];
    scale = lastScale = oldestScale = 1.;
    
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
         bubble.delegate = self;
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
    
    //  appended by Tangyuanchao
    //  setList init
    mySetList = [[HPBubbleSetList alloc] init];
    [self rearrangeBubbles:1];
    
    //  double tap flag init
    isDoubleTapped = false;
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
        bubbleFrame.origin.y = bubble.standardRect.origin.y / lastScale * scale;//[bubble.task YOffsetForScale:scale inType:HPItemBubbleScaleLinear];
        bubble.standardRect = bubbleFrame;
        [bubble.indicatorRef layoutForBubble:bubble];
    }];
}

//  new implementation by Tang Yuanchao
//  2013.1.1

- (void)rearrangeBubbles:(NSInteger)cases
{    
    if ([_bubbles count] < 2) {
        return;
    }
    NSLog(@"Rearranging...");
    NSInteger i;

    //  judge the cases and process.
    //  case 1: method called by [init]
    if (cases == 1) {
        //  step 1: make sets with _bubbles[], add them into setList. _bubbles[] are already sorted.
        HPBubbleSet * tempSet;
        HPItemBubble * tempBubble;
        for ( i = 0 ; i < [_bubbles count]; i++) {
            tempBubble = _bubbles[i];
            tempSet = [mySetList makeSet:tempBubble];
            [mySetList.setList addObject:tempSet];
            //  modify the pointers
//            if (i != 0) {
//                tempSet2.next = tempSet;
//                tempSet2 = tempSet;
//            }
//            else
//                tempSet2 = tempSet;
        }
        
        //  step 2: check and process the union needs.        
        HPBubbleSet * pivotSet = mySetList.setList[0];
        for (i = 1; i < [mySetList.setList count]; i++) {
            tempSet = (HPBubbleSet *)mySetList.setList[i];
            //  union
            if ([pivotSet.bubble.task tooClose:tempSet.bubble.task.time scale:scale]) {
                [mySetList unionSet:pivotSet secondSet:tempSet];
            }
            else
                pivotSet = tempSet;
        }        
    }
    
    //  case 2: method called by pinched.
    if (cases == 2) {
        //  if zoom in, that means only splitSet will be called
        if (oldestScale < scale)
        {
            //  scan the setList to find the split point.
            for (i=0; i<[mySetList.setList count]; i++) {
                HPBubbleSet * tempSet = (HPBubbleSet *)(mySetList.setList[i]);
                if (tempSet.count > 1) {//  need to check
                    [mySetList splitSet:tempSet firstSetIndex:i scale:scale];
                }
            }
        }
        
        //  if zoom out, that means only unionSet will be called
        if (oldestScale > scale)
        {
            HPBubbleSet * pivotSet = mySetList.setList[0];
            for (i = 1; i < [mySetList.setList count]; i++) {
                HPBubbleSet * tempSet = (HPBubbleSet *)mySetList.setList[i];
                //  union
                if ([pivotSet.bubble.task tooClose:tempSet.bubble.task.time scale:scale]) {
                    //NSLog(@"union~");
                    [mySetList unionSet:pivotSet secondSet:tempSet];
                    i--;
                }
                else
                    pivotSet = tempSet;
            }
        }
    }
    
//    for (i = 0; i < [mySetList.setList count]; i++) {
//        HPBubbleSet * tempSet = (HPBubbleSet *)(mySetList.setList[i]);
//        NSLog(@"setList: %@\n", tempSet.bubble.task.title);
//        if (tempSet.count > 1) {
//            for (int j=0; j<tempSet.count; j++) {
//                HPBubbleSet * tempSet2 = (HPBubbleSet *)(tempSet.setArray[j]);
//                NSLog(@"--setArray: %@\n", tempSet2.bubble.task.title);
//            }
//        }
//    }
    
}

static CGFloat lastTouch0y;
static CGFloat lastTouch1y;
#define TIMELINE_SCALE_MIN 0.2
#define TIMELINE_SCALE_MAX 5

- (void)pinched:(UIPinchGestureRecognizer *)sender
{
    /////////////////////////////////////////////////////////////////////////
    if (sender.state == UIGestureRecognizerStateEnded) {
        [self rearrangeBubbles:2];
        oldestScale = scale;
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
        oldestScale = scale;
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
//    NSLog(@"bounds: %f, %f", scrollView.bounds.origin.x, scrollView.bounds.origin.y);
    /* move bubbles to their position */
    [self scaleBubbles];

    /* update static variables */
    lastScale = scale;
    lastTouch0y = touch0y;
    lastTouch1y = touch1y;
}


- (void)bubbleDidMove:(HPItemBubble *)bubble
{
    /* sort _bubbles array by their frame */
    [_bubbles sortUsingComparator:^NSComparisonResult(HPItemBubble * obj1, HPItemBubble * obj2) {
        return [[NSNumber numberWithFloat:obj1.frame.origin.y] compare:[NSNumber numberWithFloat:obj2.frame.origin.y]];
    }];
    /* detect overlay and rearrange */
    [self rearrangeBubbles:3];
}

- (void)bubbleDidDoubleTapped:(HPItemBubble *)bubble
{
    //  now zoom in
    if (isDoubleTapped == false) {
        isDoubleTapped = true;
        justScale = scale;
        justOffsetY = scrollView.contentOffset.y;
        
        HPBubbleSet * tempSet = bubble.mySet.setHead;
        if (tempSet.count < 2) {
            return;
        }
        //  calculate new scale
        [self getNewScale:bubble];
        
        //  modify scrollview's size and position
        CGFloat contentOffsetY = bubble.standardRect.origin.y * scale / lastScale - bubble.standardRect.origin.y + scrollView.contentOffset.y;

        scrollView.contentOffset = CGPointMake(scrollView.contentOffset.x, contentOffsetY);
        scrollView.contentSize = CGSizeMake(scrollView.contentSize.width, scrollView.contentSize.height / lastScale * scale);
        
        //  scale the bubbles, remember lastScale
        [self scaleBubbles];
        lastScale = scale;
        
        [scrollView scrollRectToVisible:bubble.standardRect animated:YES];
        
        //  split the set
        NSInteger i;
        for (i=0; i<[mySetList.setList count]; i++) {
            HPBubbleSet * tempSet = (HPBubbleSet *)(mySetList.setList[i]);
            if (tempSet.count > 1) {//  need to check
                [mySetList splitSet:tempSet firstSetIndex:i scale:scale];
            }
        }
        
    }
    //  now resume
    else{
        isDoubleTapped = false;
        //  get back to the old scale
        scale = justScale;
        
        
        //  modify scrollview's size and position        
        scrollView.contentOffset = CGPointMake(scrollView.contentOffset.x, justOffsetY);
        scrollView.contentSize = CGSizeMake(scrollView.contentSize.width, scrollView.contentSize.height / lastScale * scale);

        //  scale the bubbles, remember lastScale
        [self scaleBubbles];
        lastScale = scale;
        
        [scrollView scrollRectToVisible:bubble.standardRect animated:YES];


        //  union the sets
        NSInteger i;
        HPBubbleSet * pivotSet = mySetList.setList[0];
        for (i = 1; i < [mySetList.setList count]; i++) {
            HPBubbleSet * tempSet = (HPBubbleSet *)mySetList.setList[i];
            //  union
            if ([pivotSet.bubble.task tooClose:tempSet.bubble.task.time scale:scale]) {
                //NSLog(@"union~");
                [mySetList unionSet:pivotSet secondSet:tempSet];
                i--;
            }
            else
                pivotSet = tempSet;
        }
    }
}

- (void)getNewScale:(HPItemBubble *)bubble
{
    HPBubbleSet * tempSet = bubble.mySet.setHead;
    if (tempSet.count < 2) {
        return;
    }
    CGFloat minInterval = 1000.;
    NSInteger i;
    for (i=0;i<tempSet.count-1;i++){
        HPBubbleSet * tempSet1 = (HPBubbleSet *)(tempSet.setArray[i]);
        HPBubbleSet * tempSet2 = (HPBubbleSet *)(tempSet.setArray[i+1]);
        CGFloat tempInterval = fabsf(tempSet1.bubble.standardRect.origin.y - tempSet2.bubble.standardRect.origin.y);
        if (tempInterval < minInterval)
            minInterval = tempInterval;
    }
    scale = scale * LEAST_PIXEL_INTERVAL / minInterval;
    if (scale < TIMELINE_SCALE_MIN) scale = TIMELINE_SCALE_MIN;
    if (scale > TIMELINE_SCALE_MAX) scale = TIMELINE_SCALE_MAX;

}

@end
