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
#import <QuartzCore/QuartzCore.h>

#define BUBBLE_BG_IMG [UIImage imageNamed:@"paper_bg"]
#define BUBBLE_EDIT_BG_IMG [UIImage imageNamed:@"paper_multi_bg"]
#define PAPER_FRAME CGRectMake(0, 0, 230, 79)
#define PAPER_EDIT_FRAME CGRectMake(0, 0, 230, 82)

#define BUBBLE_MARGIN_TOP (14)
#define BUBBLE_MARGIN_BOTTOM (14)
#define BUBBLE_MARGIN_LEFT (22)
#define BUBBLE_MARGIN_RIGHT (14)

#define BUBBLE_OFFSET_X (70)

#define LABEL_TITLE_FRAME CGRectMake(BUBBLE_MARGIN_LEFT, BUBBLE_MARGIN_TOP, TITLE_SIZE.width, TITLE_SIZE.height)
#define LABEL_CONTENT_FRAME CGRectMake(BUBBLE_MARGIN_LEFT, BUBBLE_MARGIN_TOP + TITLE_SIZE.height, TIME_SIZE.width, TIME_SIZE.height)

#define LABEL_TITLE_COLOR [UIColor colorWithRed:58/255. green:61/255. blue:61/255. alpha:1]
#define LABEL_CONTENT_COLOR [UIColor colorWithRed:126/255. green:131/255. blue:132/255. alpha:1]
#define LABEL_TITLE_FONT_SIZE (18)
#define LABEL_CONTENT_FONT_SIZE (12)
#define LABEL_TITLE_FONT [UIFont fontWithName:@"HiraginoSansGB-W3" size:LABEL_TITLE_FONT_SIZE]
#define LABEL_CONTENT_FONT [UIFont fontWithName:@"HiraginoSansGB-W3" size:LABEL_CONTENT_FONT_SIZE]
//#define LABEL_TITLE_FONT [UIFont fontWithName:@"HelveticaNeue" size:LABEL_TITLE_FONT_SIZE]
//#define LABEL_CONTENT_FONT [UIFont fontWithName:@"HelveticaNeue" size:LABEL_CONTENT_FONT_SIZE]

#define TEXT_SIZE(string, font) [(string) sizeWithFont:(font)]
#define TITLE_SIZE TEXT_SIZE(self.task.title, LABEL_TITLE_FONT)
#define TIME_SIZE TEXT_SIZE([self.task.time description], LABEL_CONTENT_FONT)

#define INDICATOR_COLOR_GREEN [UIColor colorWithRed:39/255. green:151/255. blue:0 alpha:0.8]
#define INDICATOR_COLOR_RED [UIColor colorWithRed:151/255. green:0 blue:28/255. alpha:0.8]
#define INDICATOR_COLOR_YELLOW [UIColor colorWithRed:151/255. green:110/255. blue:0 alpha:0.8]
#define INDICATOR_COLOR_BLUE [UIColor colorWithRed:0 green:124/255. blue:151/255. alpha:0.8]

#define LIGHTBAR_FRAME CGRectMake(223, 0.5, 5, 73)

@implementation HPItemBubble
{
    UIImageView * backgroundImageView;
//    UIImage * backgroundImage;
    UILabel * labelTitle;
    UILabel * labelContent;
    
    UIView * lightBar;

    UIPanGestureRecognizer * panGestureRecognizer;
    UILongPressGestureRecognizer * longPressRecognizer;
    
    NSThread * scrollThread;
    BOOL scrollThreadShouldScroll;
}

#pragma mark - Lifecycle

- (id)initWithTask:(Task *)theTask
{
    if (self = [super init]) {
        self.task = theTask;
        _editMode = NO;
        
        self.color = @[INDICATOR_COLOR_GREEN, INDICATOR_COLOR_RED, INDICATOR_COLOR_BLUE, INDICATOR_COLOR_YELLOW][arc4random() % 4];
        
        longPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressed:)];
        longPressRecognizer.delegate = self;
        longPressRecognizer.minimumPressDuration = 0.3;
        [self addGestureRecognizer:longPressRecognizer];
        
        panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(dragged:)];
        panGestureRecognizer.delegate = self;
        [self addGestureRecognizer:panGestureRecognizer];
        
        [self initLayout];
        self.standardRect = self.frame;
        
        /* set up KVO for scrolling speed */
        [self addObserver:self forKeyPath:@"scrollSpeed" options:(NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld) context:NULL];
        scrollThreadShouldScroll = NO;
        
        return self;
    }
    return nil;
}

- (void)dealloc
{
    [self removeGestureRecognizer:panGestureRecognizer];
    [self removeGestureRecognizer:longPressRecognizer];
    [self removeObserver:self forKeyPath:@"scrollSpeed"];
}

+ (id)bubbleWithTask:(Task *)task
{
    return [[HPItemBubble alloc] initWithTask:task];
}


#pragma mark - View Layout

- (void)initLayout
{
    CGRect frame = PAPER_FRAME;
    
    /* set up position */
    frame.origin.x = BUBBLE_OFFSET_X;
    frame.origin.y = 0;
    self.frame = frame;

    /* set up background */
    self.backgroundColor = CLEAR_COLOR;
    backgroundImageView = [[UIImageView alloc] initWithImage:BUBBLE_BG_IMG];
    backgroundImageView.frame = PAPER_FRAME;
    [self addSubview:backgroundImageView];
    
    /* set up title label */
    labelTitle = [[UILabel alloc] initWithFrame:LABEL_TITLE_FRAME];
    labelTitle.text = self.task.title;
    labelTitle.textColor = LABEL_TITLE_COLOR;
    labelTitle.font = LABEL_TITLE_FONT;
    labelTitle.backgroundColor = CLEAR_COLOR;
    [self addSubview:labelTitle];
    
    /* set up content label */
    labelContent = [[UILabel alloc] initWithFrame:LABEL_CONTENT_FRAME];
    labelContent.text = self.task.content;
    labelContent.textColor = LABEL_CONTENT_COLOR;
    labelContent.font = LABEL_CONTENT_FONT;
    labelContent.backgroundColor = CLEAR_COLOR;
    [self addSubview:labelContent];
    
    /* set up light bar */
    lightBar = [[UIView alloc] initWithFrame:LIGHTBAR_FRAME];
    lightBar.backgroundColor = self.color;
    lightBar.alpha = 0;
    [self addSubview:lightBar];
}


#pragma mark - Control Callbacks

- (void)longPressed:(id)sender
{
    if (((UIGestureRecognizer *)sender).state == UIGestureRecognizerStateEnded) {
        [self cancelEditMode];
        [self.delegate bubbleDidMove:self];
        self.standardRect = self.frame;
        // should update database time
    }
    else if (((UIGestureRecognizer *)sender).state == UIGestureRecognizerStateBegan) {
        [self enableEditMode];
    }
}

- (void)outerTapped:(id)sender
{
    [self cancelEditMode];
}

#define SCROLLING_DOWN_THRESHOLD (380)
#define SCROLLING_UP_THRESHOLD (120)
#define INDICATOR_OFFSET_Y (14)

- (void)dragged:(id)sender
{
    UIPanGestureRecognizer * pgr = (UIPanGestureRecognizer *)sender;
    
    if (pgr.state == UIGestureRecognizerStateBegan) {
        return;
    }
    if (pgr.state == UIGestureRecognizerStateEnded) {
        self.scrollSpeed = 0;
        return;
    }
    
    CGPoint tp = [pgr locationInView:self.superview.superview];
    
    if (tp.y > SCROLLING_DOWN_THRESHOLD) {
        self.scrollSpeed = (tp.y - SCROLLING_DOWN_THRESHOLD) / 10;
    }
    else if (tp.y < SCROLLING_UP_THRESHOLD && self.scrollViewRef.contentOffset.y > 0) {
        self.scrollSpeed = (tp.y - SCROLLING_UP_THRESHOLD) / 10;
    }
    else {
        self.scrollSpeed = 0;
    }
    
    // FIXME: should dynamically expand / shrink the content size
    /* Move the bubble and indicator along with the finger */
    CGFloat newY = self.scrollViewRef.contentOffset.y + tp.y;
    
    self.center = CGPointMake(self.center.x, newY);
    [self.indicatorRef layoutForBubble:self];
}

#pragma mark - Edit Mode Related

- (void)enableEditMode
{
    NSLog(@"Enabling edit mode");
    [self.scrollViewRef setScrollEnabled:NO];

    self.editMode = YES;
    [self.indicatorRef enableEditMode];
    
    /* change the look */
    [UIView beginAnimations:@"Enter edit mode" context:nil];
    [UIView setAnimationDuration:0.1];
//    self.transform = CGAffineTransformMakeScale(1.05, 1.05);
    lightBar.alpha = 1;
    [UIView commitAnimations];
    
    /* bring to front */
    [self.scrollViewRef bringSubviewToFront:self];
    [self.scrollViewRef bringSubviewToFront:self.indicatorRef];
}

- (void)cancelEditMode
{
    NSLog(@"Canceling edit mode");
    [self.scrollViewRef setScrollEnabled:YES];
        
    self.editMode = NO;
    [self.indicatorRef cancelEditMode];
    
    /* change the look */
    [UIView beginAnimations:@"Exit edit mode" context:nil];
    [UIView setAnimationDuration:0.1];
//    self.transform = CGAffineTransformIdentity;
    lightBar.alpha = 0;
    [UIView commitAnimations];
}

#pragma mark Drag-and-move automatic scroll

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (![keyPath isEqualToString:@"scrollSpeed"])
        return;
    
    CGFloat old = [change[NSKeyValueChangeOldKey] floatValue];
    CGFloat new = [change[NSKeyValueChangeNewKey] floatValue];
    
    if (old == 0 && new != 0) {
        NSLog(@"Detaching scrolling thread...");
        scrollThreadShouldScroll = YES;
        scrollThread = [[NSThread alloc] initWithTarget:self selector:@selector(scrollThreadRoutine) object:nil];
        [scrollThread start];
    }
    else if (old != 0 && new == 0) {
        NSLog(@"Exiting scrolling thread...");
        scrollThreadShouldScroll = NO;
    }
}

- (void)scrollThreadRoutine
{
    CGFloat fps = 60;
    while (scrollThreadShouldScroll) {
        [self performSelectorOnMainThread:@selector(scroll) withObject:nil waitUntilDone:YES];
        [NSThread sleepForTimeInterval:1/fps];
    }
    [NSThread exit];
}

- (void)scroll
{
    CGFloat dy = 3 * self.scrollSpeed;;
    CGPoint bubbleCenter = self.center;
    CGPoint indicatorCenter = self.indicatorRef.center;
    CGPoint contentOffset = self.scrollViewRef.contentOffset;
    CGSize contentSize = self.scrollViewRef.contentSize;
    
    self.center = CGPointMake(bubbleCenter.x, bubbleCenter.y + dy);
    self.indicatorRef.center = CGPointMake(indicatorCenter.x, indicatorCenter.y + dy);
    self.scrollViewRef.contentOffset = CGPointMake(contentOffset.x, contentOffset.y + dy);
    self.scrollViewRef.contentSize = CGSizeMake(contentSize.width, contentSize.height + dy);
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


- (void)mergeToBubble:(HPItemBubble *)bubble
{
    self.frame = bubble.frame;
    [self.indicatorRef layoutForBubble:self];
    self.merged = YES;
//    bubble.merged = YES;
    
    self.nextStackBubble = bubble;
    self.indicatorRef.number += bubble.indicatorRef.number;
    bubble.indicatorRef.alpha = 0;
}

- (void)resumeStandardPositionFrom:(HPItemBubble *)bubble
{
    self.frame = self.standardRect;
    [self.indicatorRef layoutForBubble:self];
    self.merged = NO;
    NSLog(@"bubbleNum: %d, selfNum: %d", bubble.indicatorRef.number, self.indicatorRef.number);
    self.indicatorRef.number -= bubble.indicatorRef.number;
    self.nextStackBubble = nil;
    bubble.indicatorRef.alpha = 1;
}

- (void)setMerged:(BOOL)merged
{
    _merged = merged;
    if (merged) {
        backgroundImageView.image = BUBBLE_EDIT_BG_IMG;
        backgroundImageView.frame = PAPER_EDIT_FRAME;
    }
    else {
        backgroundImageView.image = BUBBLE_BG_IMG;
        backgroundImageView.frame = PAPER_FRAME;
    }
}

@end
