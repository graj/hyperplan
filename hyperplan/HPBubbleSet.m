//
//  HPBubbleSet.m
//  hyperplan
//
//  Created by cowww on 12-12-29.
//  Copyright (c) 2012年 Sohu Inc. All rights reserved.
//

#import "HPBubbleSet.h"
#import "HPItemBubble.h"
#import "HPItemIndicator.h"
#import "HPConstants.h"
#import "Task+Layout.h"
#import "Task.h"

@implementation HPBubbleSet
{
}

//initialization
- (void)initWithBubble:(HPItemBubble *)x
{
    //  variables that do not need memory allocation
    self.bubble = x;
    self.count = 1;
    self.startTime = x.task.time;
    self.endTime = x.task.time;
    
    //  variables that need memory allocation
    self.setArray = [NSMutableArray array];//   need autorelease or not?
    
    self.setHead = self;
    x.mySet = self;
}

//  self is merged into targetSet. do all the UI Operations.
- (void)UIOperationWhenMergeTo:(HPBubbleSet *)targetSet
{
    //  start animation
    [UIView beginAnimations:@"union" context:nil];
    
    //  change position
    self.bubble.frame = targetSet.bubble.standardRect;
    [self.bubble.indicatorRef layoutForBubble:self.bubble];
    //  hide reference
    self.bubble.indicatorRef.alpha = 0;
    //  bring to front
    [targetSet.bubble.scrollViewRef bringSubviewToFront:targetSet.bubble];
    //  indicator number change
    targetSet.bubble.indicatorRef.number = targetSet.count;
    
    //  end animation
    [UIView commitAnimations];
}

//  self is splited from sourceSet. do all the UI Operations.
- (void)UIOperationWhenSplitFrom:(HPBubbleSet *)sourceSet
{
    //  start animation
    [UIView beginAnimations:@"union" context:nil];
    
    //  resume the position
    self.bubble.frame = self.bubble.standardRect;
    [self.bubble.indicatorRef layoutForBubble:self.bubble];
    //  show the reference
    self.bubble.indicatorRef.alpha = 1;
    //  indicator number change
    sourceSet.bubble.indicatorRef.number = sourceSet.count;
    self.bubble.indicatorRef.number = self.count;
    
    //  end animation
    [UIView commitAnimations];
}


@end
