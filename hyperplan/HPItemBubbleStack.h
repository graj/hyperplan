//
//  HPItemBubbleStack.h
//  hyperplan
//
//  Created by Phil on 11/29/12.
//  Copyright (c) 2012 Sohu Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Task.h"

@interface HPItemBubbleStack : UIView <UIGestureRecognizerDelegate>
{
    NSArray * _tasks;
    BOOL _editMode;
    id _indicatorRef;
    UIScrollView * _scrollViewRef;
    
    UILabel * _labelTitle;
    UILabel * _labelTime;
}

@property (nonatomic, retain) NSArray * tasks;
@property (nonatomic, readonly) BOOL editMode;
@property (nonatomic, retain) id indicatorRef;
@property (nonatomic, retain) UIScrollView * scrollViewRef;
@property (atomic, assign) CGFloat scrollSpeed;

@property (nonatomic, retain) UILabel * labelTitle;
@property (nonatomic, retain) UILabel * labelTime;

/* Preferred constructors: in consist with the data model */
- (id)initWithTasks:(NSArray *)tasks;
+ (id)bubbleStackWithTasks:(NSArray *)tasks;
- (void)addTask:(Task *)task;

@end
