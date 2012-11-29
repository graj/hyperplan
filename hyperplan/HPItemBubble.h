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

@interface HPItemBubble : UIView <UIGestureRecognizerDelegate>
{
    Task * _task;
    BOOL _editMode;
    id _indicatorRef;
}

@property (nonatomic, retain) Task * task;
@property (nonatomic, readonly) BOOL editMode;
@property (nonatomic, retain) id indicatorRef;

/* Preferred constructors: in consist with the data model */
- (id)initWithTask:(Task *)task;
+ (id)bubbleWithTask:(Task *)task;

@end
