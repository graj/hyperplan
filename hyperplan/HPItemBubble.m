//
//  HPItemBubble.m
//  hyper-plan-testfield
//
//  Created by Phil on 11/6/12.
//  Copyright (c) 2012 Sohu Inc.. All rights reserved.
//

#import "HPConstants.h"
#import "HPItemBubble.h"
#import "Task.h"    

/* decided by the png's shadow width */
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
#define TITLE_SIZE TEXT_SIZE(self.title, LABEL_TITLE_FONT)
#define TIME_SIZE TEXT_SIZE([self.time description], LABEL_TIME_FONT)

#define SHADOW_WIDTH (5)

@implementation HPItemBubble
{
    UIImageView * backgroundImageView;
    UIImage * backgroundImage;
    UILabel * labelTitle;
    UILabel * labelTime;
    NSString * dateString;

    UIPanGestureRecognizer * panGestureRecognizer;
    UILongPressGestureRecognizer * longPressRecognizer;
    UITapGestureRecognizer * tapGestureRecognizer;
}

#pragma mark Lifecycle

- (id)initWithTask:(Task *)task
{
    if (self = [super init]) {
        self.title = task.title;
        self.content = task.content;
        self.time = task.time;
        self.state = [task.state integerValue];
        _editMode = NO;
        
        longPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressed:)];
        [self addGestureRecognizer:longPressRecognizer];
        
        tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(outerTapped:)];
        tapGestureRecognizer.numberOfTapsRequired = 1;
        
        panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(dragged:)];
        
        [self initLayout];
        
        return self;
    }
    return nil;
}

+ (id)bubbleWithTask:(Task *)task
{
    return [[HPItemBubble alloc] initWithTask:task];
}


#pragma mark - View Layout

- (void)initLayout
{
    CGRect frame;
    
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
    labelTitle.text = self.title;
    labelTitle.textColor = LABEL_TITLE_COLOR;
    labelTitle.font = LABEL_TITLE_FONT;
    labelTitle.backgroundColor = CLEAR_COLOR;
    [self addSubview:labelTitle];
    
    /* set up time label */
    dateString = [self timeRepWithMode:HPTaskTimeRepDateAndTime];
    labelTime = [[UILabel alloc] initWithFrame:LABEL_TIME_FRAME];
    labelTime.text = dateString;
    labelTime.textColor = LABEL_TIME_COLOR;
    labelTime.font = LABEL_TIME_FONT;
    labelTime.backgroundColor = CLEAR_COLOR;
    [self addSubview:labelTime];
}

- (NSString *)timeRepWithMode:(HPTaskTimeRepMode)mode
{
    NSDateFormatter * df = [[NSDateFormatter alloc] init];
    
    //FIXME: need to correct the formats
    if (mode == HPTaskTimeRepDateOnly) {
        [df setDateStyle:NSDateFormatterMediumStyle];
        return [df stringFromDate:self.time];
    }
    else if (mode == HPTaskTimeRepDateAndTime) {
        [df setDateStyle:NSDateFormatterLongStyle];
        return [df stringFromDate:self.time];
    }
    else if (mode == HPTaskTimeRepCompactDateAndTime) {
        [df setDateStyle:NSDateFormatterShortStyle];
        return [df stringFromDate:self.time];
    }

    return @"";
}

#pragma mark - Controls

- (void)longPressed:(id)sender
{
    if (((UIGestureRecognizer *)sender).state != UIGestureRecognizerStateBegan)
        return;
    
    NSLog(@"Long-pressed");
    /* cancel edit mode for any previous pressed bubble */
    [self.superview.subviews enumerateObjectsUsingBlock:^(id item, NSUInteger idx, BOOL * stop) {
        if (![item isEqual:self] && [item isKindOfClass:[HPItemBubble class]] && [item editMode]) {
            NSLog(@"canceling previous edit mode...");
            [item cancelEditMode];
            *stop = YES;
        }
    }];
    
    [self enableEditMode];
}

- (void)outerTapped:(id)sender
{
    NSLog(@"Cancel-area touched");
    [self cancelEditMode];
}

- (void)dragged:(id)sender
{
    NSLog(@"@@");
}

#pragma mark - Edit Mode

- (void)enableEditMode
{
    NSLog(@"Enabling edit mode");
    
    _editMode = YES;
    [self.indicatorRef enableEditMode];
    [UIView beginAnimations:@"Enter edit mode" context:nil];
    [UIView setAnimationDuration:0.2];
    self.alpha = 0.75;
    self.transform = CGAffineTransformMakeScale(1.05, 1.05);
    [UIView commitAnimations];
    
    /* register dragging gesture recognizer */
    [self addGestureRecognizer:panGestureRecognizer];
    
    /* register tap recognizer for superview to detact canceling edit mode */
    if (self.superview) {
        [self.superview addGestureRecognizer:tapGestureRecognizer];
    }
}

- (void)cancelEditMode
{
    NSLog(@"Canceling edit mode");
    _editMode = NO;
    [self.indicatorRef cancelEditMode];
    [UIView beginAnimations:@"Exit edit mode" context:nil];
    [UIView setAnimationDuration:0.2];
    self.alpha = 1;
    self.transform = CGAffineTransformIdentity;
    [UIView commitAnimations];
    
    /* remove dragging gesture recognizer */
    if ([self.gestureRecognizers containsObject:panGestureRecognizer]) {
        [self removeGestureRecognizer:panGestureRecognizer];
    }
    
    /* remove tap recognizer from superview */
    if (self.superview && self.superview.gestureRecognizers) {
        [self.superview removeGestureRecognizer:tapGestureRecognizer];
    }
}


@end
