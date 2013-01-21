//
//  HPBubbleGroupViewController.m
//  hyperplan
//
//  Created by wuhaotian on 11/29/12.
//  Copyright (c) 2012 Sohu Inc. All rights reserved.
//

#import "HPBubbleGroupViewController.h"
#import "HPConstants.h"
#import "Task+Layout.h"

#define BUBBLE_BG_IMG [UIImage imageNamed:@"bubble"]
#define BUBBLE_MARGIN_TOP (10)
#define BUBBLE_MARGIN_BOTTOM (14)
#define BUBBLE_MARGIN_LEFT (18)
#define BUBBLE_MARGIN_RIGHT (14)

#define BUBBLE_MAX_WIDTH (225)
#define BUBBLE_MIN_WIDTH (180)
#define BUBBLE_OFFSET_X (90)

#define LABEL_TITLE_COLOR BLACK_COLOR
#define LABEL_TIME_COLOR DARK_GREY_COLOR
#define LABEL_TITLE_FONT_SIZE (14)
#define LABEL_TIME_FONT_SIZE (12)
#define LABEL_TITLE_FONT [UIFont fontWithName:@"HiraginoSansGB-W3" size:LABEL_TITLE_FONT_SIZE]
#define LABEL_TIME_FONT [UIFont fontWithName:@"HiraginoSansGB-W3" size:LABEL_TIME_FONT_SIZE]
#define FONT [UIFont systemFontOfSize: 14]
#define TEXT_SIZE(string, font) [(string) sizeWithFont:(font)]


#define SHADOW_WIDTH (5)


@interface HPBubbleGroupViewController ()

@property (nonatomic, strong) NSMutableArray * array_tasks;

@end

@implementation HPBubbleGroupViewController

#pragma mark - life cycle
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (id)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

#pragma mark - Computing Metrics For Multiple Tasks

- (CGSize)sizeWithTasks:(NSArray *)aArray
{
    self.array_tasks = [NSMutableArray arrayWithArray:aArray];
    BOOL max_width = NO;
    CGRect frame;
    
    /* self-adaptive frame set-up */
    Task * t = [self.array_tasks objectAtIndex:0];
    
    CGSize size_title = [t.title sizeWithFont:FONT];
    CGSize size_time = [[t timeRepWithMode:HPTaskTimeRepDateAndTime] sizeWithFont:FONT];
    
    frame.size.width = TEXT_SIZE(t.title, LABEL_TITLE_FONT).width + BUBBLE_MARGIN_LEFT + BUBBLE_MARGIN_RIGHT + SHADOW_WIDTH;
    frame.size.height = size_time.height + size_title.height + BUBBLE_MARGIN_TOP + BUBBLE_MARGIN_BOTTOM;
    
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
    self.view.frame = frame;
    
    /* set up background */
    self.view.backgroundColor = CLEAR_COLOR;
    // The cell image must be named "***@2x.png", otherwise will be regarded as half resolution.
    UIImage * backgroundImage = [BUBBLE_BG_IMG resizableImageWithCapInsets:UIEdgeInsetsMake(20, 16, 12, 12) resizingMode:UIImageResizingModeTile];
    UIImageView * backgroundImageView = [[UIImageView alloc] initWithImage:backgroundImage];
    backgroundImageView.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
    [self.view addSubview:backgroundImageView];
    
    /* set up title label */
    UILabel * labelTitle = [[UILabel alloc] initWithFrame:CGRectMake(BUBBLE_MARGIN_LEFT, BUBBLE_MARGIN_TOP, TEXT_SIZE(t.title, LABEL_TITLE_FONT).width, TEXT_SIZE(t.title, LABEL_TIME_FONT).height)];
    labelTitle.text = t.title;
    labelTitle.textColor = LABEL_TITLE_COLOR;
    labelTitle.font = LABEL_TITLE_FONT;
    labelTitle.backgroundColor = CLEAR_COLOR;
    [self.view addSubview:labelTitle];
    
    /* set up time label */
//    NSString * dateString = [t timeRepWithMode:HPTaskTimeRepDateAndTime];
//    UILabel * labelTime = [[UILabel alloc] initWithFrame:LABEL_TIME_FRAME];
//    labelTime.text = dateString;
//    labelTime.textColor = LABEL_TIME_COLOR;
//    labelTime.font = LABEL_TIME_FONT;
//    labelTime.backgroundColor = CLEAR_COLOR;
    return frame.size;
}

- (CGSize)resizeWithAppendingTask:(Task *)task
{
    if (!self.array_tasks) {
        return [self sizeWithTasks:@[task]];
    }
    return self.view.frame.size;
}

@end
