//
//  HPBubbleSet.h
//  hyperplan
//
//  Created by cowww on 12-12-29.
//  Copyright (c) 2012年 Sohu Inc. All rights reserved.
//
//  This class is created mainly for realizing bubble merge and split. Each HPBubbleSet contains one bubble or several HPBubbleSets. If one HPBubbleSet contains only one bubble, then the member pointer *bubble points to that bubble. Else, this pointer points to the delegate bubble. In this way, we do not have seperate bubble variable, we only have bubbleSet. When we merge two bubbles, in fact we merge two sets. This saves us the cost of new and delete.

#import <UIKit/UIKit.h>
#import "Task.h"
#import "HPConstants.h"
#import <Foundation/Foundation.h>

@class HPItemBubble;
@class HPItemIndicator;
@class HPBubbleSet;

@interface HPBubbleSet : NSObject
{
    NSDate * _startTime;
    NSDate * _endTime;
    HPItemBubble * _bubble;  //  the delegate bubble of the set
    NSMutableArray * _setArray;//    a set can contain many sets
    HPBubbleSet * _setHead;  //  the delegate set of the set
    NSInteger _count;
    HPBubbleSet * _next;
}

@property (nonatomic, retain) NSDate * startTime;
@property (nonatomic, retain) NSDate * endTime;
@property (nonatomic, retain) HPItemBubble * bubble;
@property (nonatomic, retain) NSMutableArray * setArray;
@property (nonatomic, retain) HPBubbleSet * setHead;
@property (nonatomic, assign) NSInteger count;
@property (nonatomic, retain) HPBubbleSet * next;

//methods
- (void)initWithBubble:(HPItemBubble *)x;
- (void)UIOperationWhenMergeTo:(HPBubbleSet *)targetSet;
- (void)UIOperationWhenSplitFrom:(HPBubbleSet *)sourceSet;

@end
