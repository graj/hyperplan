//
//  HPItemBubble.m
//  hyper-plan-testfield
//
//  Created by Phil on 11/6/12.
//  Copyright (c) 2012 Sohu Inc.. All rights reserved.
//

#import "HPConstants.h"
#import "HPItemBubble.h"
#import "HPItemIndicator.h"
#import "Task.h"    
#import "Task+Layout.h"

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
#define TITLE_SIZE TEXT_SIZE(self.task.title, LABEL_TITLE_FONT)
#define TIME_SIZE TEXT_SIZE([self.task.time description], LABEL_TIME_FONT)

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
    
    NSThread * scrollThread;
}

#pragma mark Lifecycle

- (id)initWithTask:(Task *)theTask
{
    if (self = [super init]) {
        self.task = theTask;
        _editMode = NO;
        
        longPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressed:)];
        longPressRecognizer.delegate = self;
        longPressRecognizer.minimumPressDuration = 0.1;
        [self addGestureRecognizer:longPressRecognizer];
        
        panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(dragged:)];
        panGestureRecognizer.delegate = self;
        [self addGestureRecognizer:panGestureRecognizer];
        
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
    labelTitle.text = self.task.title;
    labelTitle.textColor = LABEL_TITLE_COLOR;
    labelTitle.font = LABEL_TITLE_FONT;
    labelTitle.backgroundColor = CLEAR_COLOR;
    [self addSubview:labelTitle];
    
    /* set up time label */
    dateString = [self.task timeRepWithMode:HPTaskTimeRepDateAndTime];
    labelTime = [[UILabel alloc] initWithFrame:LABEL_TIME_FRAME];
    labelTime.text = dateString;
    labelTime.textColor = LABEL_TIME_COLOR;
    labelTime.font = LABEL_TIME_FONT;
    labelTime.backgroundColor = CLEAR_COLOR;
    [self addSubview:labelTime];
    
    /* set up KVO for scrolling speed */
    [self addObserver:self forKeyPath:@"scrollSpeed" options:(NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld) context:NULL];
}



#pragma mark - Control Callbacks

- (void)longPressed:(id)sender
{
    if (((UIGestureRecognizer *)sender).state == UIGestureRecognizerStateEnded) {
        [self cancelEditMode];
        return;
    }
    else if (((UIGestureRecognizer *)sender).state == UIGestureRecognizerStateBegan) {
        [self enableEditMode];
    }
}

- (void)outerTapped:(id)sender
{
    [self cancelEditMode];
}

static int bubbleLastYOffset;
static int indicatorLastYOffset;
static int contentLastYOffset;

#define SCROLLING_DOWN_THRESHOLD 360
#define SCROLLING_UP_THRESHOLD 40

- (void)dragged:(id)sender
{
    UIPanGestureRecognizer * pgr = (UIPanGestureRecognizer *)sender;
    
    /* Lock scrollView */
    if (pgr.state == UIGestureRecognizerStateBegan) {
        bubbleLastYOffset = self.center.y;
        indicatorLastYOffset = self.indicatorRef.center.y;
    }

    CGPoint dp = [pgr translationInView:self.scrollViewRef];
    
    /* move the bubble and indicator */
    self.center = CGPointMake(self.center.x, bubbleLastYOffset + dp.y);
    self.indicatorRef.center = CGPointMake(self.indicatorRef.center.x, indicatorLastYOffset + dp.y);
    
    /* TODO: dragging policy */
    if (pgr.state == UIGestureRecognizerStateChanged) {
        // FIXME: corret the condition below - dynamically expand content size
        if (self.center.y - self.scrollViewRef.contentOffset.y > SCROLLING_DOWN_THRESHOLD) {
            self.scrollSpeed = 1.;
        }
        else {
            self.scrollSpeed = 0;
        }
    }
    if (pgr.state == UIGestureRecognizerStateEnded) {
        self.scrollSpeed = 0;
    }
}

#pragma mark - Edit Mode Related

- (void)enableEditMode
{
    NSLog(@"Enabling edit mode");
    [self.scrollViewRef setScrollEnabled:NO];
        
    _editMode = YES;
    [self.indicatorRef enableEditMode];
    [UIView beginAnimations:@"Enter edit mode" context:nil];
    [UIView setAnimationDuration:0.2];
    self.alpha = 0.75;
    self.transform = CGAffineTransformMakeScale(1.05, 1.05);
    [UIView commitAnimations];
    
    /* bring to front */
    [self.scrollViewRef bringSubviewToFront:self];
    [self.scrollViewRef bringSubviewToFront:self.indicatorRef];
}

- (void)cancelEditMode
{
    NSLog(@"Canceling edit mode");
    [self.scrollViewRef setScrollEnabled:YES];
        
    _editMode = NO;
    [self.indicatorRef cancelEditMode];
    [UIView beginAnimations:@"Exit edit mode" context:nil];
    [UIView setAnimationDuration:0.2];
    self.alpha = 1;
    self.transform = CGAffineTransformIdentity;
    [UIView commitAnimations];
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (![keyPath isEqualToString:@"scrollSpeed"])
        return;
    CGFloat old = [change[NSKeyValueChangeOldKey] floatValue];
    CGFloat new = [change[NSKeyValueChangeNewKey] floatValue];
    if (old == 0 && new != 0) {
        NSLog(@"running scrolling thread...");
        /* create thread for scrolling */
        scrollThread = [[NSThread alloc] initWithTarget:self selector:@selector(scrollThreadRoutine) object:nil];
        [scrollThread start];
    }
    else if (old != 0 && new == 0) {
        NSLog(@"pausing scrolling thread...");
        [scrollThread cancel];
    }
}

- (void)scrollThreadRoutine
{
    while (1) {
        CGFloat speed = self.scrollSpeed;
        NSTimeInterval delay = 0.03 / speed;
        [NSThread sleepForTimeInterval:delay];
        
        [self performSelectorOnMainThread:@selector(scroll) withObject:nil waitUntilDone:NO];
    }
}

- (void)scroll
{
    NSLog(@"contentOffset: %f, %f", self.scrollViewRef.contentOffset.x, self.scrollViewRef.contentOffset.y);
    self.scrollViewRef.contentOffset = CGPointMake(self.scrollViewRef.contentOffset.x, self.scrollViewRef.contentOffset.y + 3);
    self.center = CGPointMake(self.center.x, self.center.y + 3);
}

#pragma mark - UIGestureRecognizerDelegate methods

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
        shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer == panGestureRecognizer)
        return self.editMode;
    else if (gestureRecognizer == longPressRecognizer)
        return !self.editMode;
    return YES;
}

@end
