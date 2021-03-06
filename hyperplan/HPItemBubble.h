//
//  HPItemBubble.h
//  hyper-plan-testfield
//
//  Created by Phil on 11/6/12.
//  Copyright (c) 2012 Sohu Inc.. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Task.h"
#import "HPConstants.h"

@class HPItemIndicator;
@class HPItemBubble;
@class HPBubbleSet;

@protocol HPItemBubbleDelegate <NSObject>

- (void)bubbleDidMove:(HPItemBubble *)bubble;
- (void)bubbleDidDoubleTapped:(HPItemBubble *)bubble;

@end

@interface HPItemBubble : UIView <UIGestureRecognizerDelegate>
{
    Task * _task;
    BOOL _editMode;
    HPItemIndicator * _indicatorRef;
    UIScrollView * _scrollViewRef;
    CGRect _standardRect;
    BOOL _merged;
    HPItemBubble * _nextStackBubble;
    HPBubbleSet * _mySet;
}

@property (nonatomic, retain) Task * task;
@property (nonatomic, readonly) BOOL editMode;
@property (nonatomic, retain) HPItemIndicator * indicatorRef;
@property (nonatomic, retain) UIScrollView * scrollViewRef;
@property (atomic, assign) CGFloat scrollSpeed;
@property (nonatomic, assign) CGRect standardRect;
@property (nonatomic, assign) BOOL merged;
@property (nonatomic, retain) HPItemBubble * nextStackBubble;
@property (nonatomic, retain) HPBubbleSet * mySet;
@property (nonatomic, retain) id <HPItemBubbleDelegate> delegate;

/* Preferred constructors: in consist with the data model */
- (id)initWithTask:(Task *)task;
+ (id)bubbleWithTask:(Task *)task;
- (void)resumeStandardPosition;

@end
