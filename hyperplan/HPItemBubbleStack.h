//
//  HPItemBubbleStack.h
//  hyperplan
//
//  Created by Phil on 11/29/12.
//  Copyright (c) 2012 Sohu Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HPItemBubbleStack : UIView <UIGestureRecognizerDelegate>
{
    NSArray * _tasks;
    BOOL _editMode;
    id _indicatorRef;
}

@property (nonatomic, retain) NSArray * tasks;
@property (nonatomic, readonly) BOOL editMode;
@property (nonatomic, retain) id indicatorRef;

/* Preferred constructors: in consist with the data model */
- (id)initWithTasks:(NSArray *)tasks;
+ (id)bubbleStackWithTasks:(NSArray *)tasks;

@end
