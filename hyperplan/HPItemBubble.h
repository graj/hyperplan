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
    NSString * _title;
    NSString * _content;
    NSDate * _time;
    HPTaskStateType _state;
    BOOL _editMode;
    id _indicatorRef;
}

@property (nonatomic, retain) NSString * title;
@property (nonatomic, strong) NSString * content;
@property (nonatomic, strong) NSDate * time;
@property (nonatomic, assign) HPTaskStateType state;
@property (nonatomic, readonly) BOOL editMode;
@property (nonatomic, retain) id indicatorRef;

/* Preferred constructors: in consist with the data model */
- (id)initWithTask:(Task *)task;
+ (id)bubbleWithTask:(Task *)task;

@end
