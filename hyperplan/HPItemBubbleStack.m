//
//  HPItemBubbleStack.m
//  hyperplan
//
//  Created by Phil on 11/29/12.
//  Copyright (c) 2012 Sohu Inc. All rights reserved.
//

#import "HPConstants.h"
#import "HPItemBubbleStack.h"
#import "Task.h"
#import "Task+Layout.h"

#define BUBBLE_BG_IMG [UIImage imageNamed:@"bubble"]
#define BUBBLE_MARGIN_TOP (10)
#define BUBBLE_MARGIN_BOTTOM (14)
#define BUBBLE_MARGIN_LEFT (18)
#define BUBBLE_MARGIN_RIGHT (14)

#define BUBBLE_MAX_WIDTH (225)
#define BUBBLE_MIN_WIDTH (180)
#define BUBBLE_OFFSET_X (90)


#define LABEL_TITLE_FRAME CGRectMake(BUBBLE_MARGIN_LEFT, BUBBLE_MARGIN_TOP, TITLE_SIZE.width, TITLE_SIZE.height)
#define LABEL_TIME_FRAME CGRectMake(BUBBLE_MARGIN_LEFT, BUBBLE_MARGIN_TOP + TITLE_SIZE.height + 6,     \
                                    TIME_SIZE.width, TIME_SIZE.height)

#define LABEL_TITLE_COLOR BLACK_COLOR
#define LABEL_TIME_COLOR DARK_GREY_COLOR
#define LABEL_TITLE_FONT_SIZE (14)
#define LABEL_TIME_FONT_SIZE (12)
#define LABEL_TITLE_FONT [UIFont fontWithName:@"STHeitiSC-Light" size:LABEL_TITLE_FONT_SIZE]
#define LABEL_TIME_FONT [UIFont fontWithName:@"STHeitiSC-Light" size:LABEL_TIME_FONT_SIZE]

#define TEXT_SIZE(string, font) [(string) sizeWithFont:(font)]
#define TITLE_SIZE TEXT_SIZE(titleString, LABEL_TITLE_FONT)
#define TIME_SIZE TEXT_SIZE(dateString, LABEL_TIME_FONT)

#define SHADOW_WIDTH (5)

#define FIRST_TASK ((Task *)self.tasks[0])

@implementation HPItemBubbleStack
{
    UIImageView * backgroundImageView;
    UIImage * backgroundImage;

    /* One bubble stack may have multiple instances of such subviews */
    UILabel * labelTitle;
    UILabel * labelTime;
    NSString * dateString;
    NSString * titleString;
}

#pragma mark Lifecycle

- (id)initWithTasks:(NSArray *)tasks
{
    if (self = [super init]) {
        self.tasks = tasks;
        _editMode = NO;
        
        [self initLayout];
        
        return self;
    }
    return nil;
}

+ (id)bubbleStackWithTasks:(NSArray *)tasks
{
    return [[HPItemBubbleStack alloc] initWithTasks:tasks];
}


#pragma mark - View Layout

- (void)initLayout
{
    CGRect frame;
    titleString = [FIRST_TASK.title stringByAppendingString:@" ..."];
    
    /* self-adaptive frame set-up */
    bool max_width = NO;    //REFACTOR:
    frame.size.width = TITLE_SIZE.width + BUBBLE_MARGIN_LEFT + BUBBLE_MARGIN_RIGHT + SHADOW_WIDTH;
    frame.size.height = TITLE_SIZE.height * 2 + BUBBLE_MARGIN_TOP + BUBBLE_MARGIN_BOTTOM;
    
    if (frame.size.width > BUBBLE_MAX_WIDTH) {
        frame.size.width = BUBBLE_MAX_WIDTH;
        max_width = YES;
    }
    if (frame.size.width < BUBBLE_MIN_WIDTH) {
        frame.size.width = BUBBLE_MIN_WIDTH;
    }
    
    /* set up position */
    frame.origin.x = BUBBLE_OFFSET_X;
    frame.origin.y = 0;
    self.frame = frame;
    
    /* set up background */
    self.backgroundColor = CLEAR_COLOR;
    // The cell image must be named "***@2x.png", otherwise will be regarded as half resolution.
    backgroundImage = [BUBBLE_BG_IMG resizableImageWithCapInsets:UIEdgeInsetsMake(20, 16, 12, 12) resizingMode:UIImageResizingModeTile];
    backgroundImageView = [[UIImageView alloc] initWithImage:backgroundImage];
    backgroundImageView.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
    [self addSubview:backgroundImageView];
    
    /* set up title label */
    labelTitle = [[UILabel alloc] initWithFrame:LABEL_TITLE_FRAME];
    labelTitle.text = titleString;
    labelTitle.textColor = LABEL_TITLE_COLOR;
    labelTitle.font = LABEL_TITLE_FONT;
    labelTitle.backgroundColor = CLEAR_COLOR;
    [self addSubview:labelTitle];
    
    /* set up time label */
    dateString = [FIRST_TASK timeRepWithMode:HPTaskTimeRepDateAndTime];
    labelTime = [[UILabel alloc] initWithFrame:LABEL_TIME_FRAME];
    labelTime.text = dateString;
    labelTime.textColor = LABEL_TIME_COLOR;
    labelTime.font = LABEL_TIME_FONT;
    labelTime.backgroundColor = CLEAR_COLOR;
    [self addSubview:labelTime];
}

- (void)longPressed:(id)sender
{
    
}

- (void)outerTouched:(id)sender
{
    
}

- (void)dragged:(id)sender
{
    
}

@end
