//
//  HPItemBubble.m
//  hyper-plan-testfield
//
//  Created by Phil on 11/6/12.
//  Copyright (c) 2012 Sohu Inc.. All rights reserved.
//

#import "HPConstants.h"
#import "HPItemBubble.h"

/* decided by the png's shadow width */
#define BUBBLE_BG_IMG [UIImage imageNamed:@"bubble"]
#define BUBBLE_MARGIN_TOP (10)
#define BUBBLE_MARGIN_BOTTOM (14)
#define BUBBLE_MARGIN_LEFT (18)
#define BUBBLE_MARGIN_RIGHT (14)

#define LABEL_TEXT_FRAME CGRectMake(BUBBLE_MARGIN_LEFT, BUBBLE_MARGIN_TOP, TEXT_WIDTH, TEXT_HEIGHT)
#define LABEL_TIME_FRAME CGRectMake(BUBBLE_MARGIN_LEFT, BUBBLE_MARGIN_TOP + TEXT_HEIGHT + 6, TEXT_WIDTH, TEXT_HEIGHT)
#define LABEL_TEXT_COLOR BLACK_COLOR
#define LABEL_TIME_COLOR DARK_GREY_COLOR
#define LABEL_TEXT_FONT [UIFont fontWithName:@"STHeitiSC-Light" size:LABEL_TEXT_FONT_SIZE]
#define LABEL_TIME_FONT [UIFont fontWithName:@"STHeitiSC-Light" size:LABEL_TIME_FONT_SIZE]
#define LABEL_TEXT_FONT_SIZE (14)
#define LABEL_TIME_FONT_SIZE (12)

/* used for calculating sizes */
#define TEXT_COUNT [content length]
#define TEXT_WIDTH (TEXT_COUNT * LABEL_TEXT_FONT_SIZE)
#define TEXT_HEIGHT (LABEL_TEXT_FONT_SIZE)
#define SHADOW_WIDTH (5)

#define BUBBLE_MAX_WIDTH (225)

@implementation HPItemBubble

UIImageView * backgroundImageView;
UIImage * backgroundImage;
UILabel * labelTitle;
UILabel * labelTime;

#pragma mark Lifecycle

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}

- (id)initWithContent:(NSString *)content andTime:(NSString *)time andFrame:(CGRect)frame
{
    /* self-adaptive frame set-up */
    bool max_width = NO;    //TODO: refactor this
    frame.size.width = TEXT_WIDTH + BUBBLE_MARGIN_LEFT + BUBBLE_MARGIN_RIGHT + SHADOW_WIDTH;
    frame.size.height = TEXT_HEIGHT * 2 + BUBBLE_MARGIN_TOP + BUBBLE_MARGIN_BOTTOM;
    if (frame.size.width > BUBBLE_MAX_WIDTH) {
        frame.size.width = BUBBLE_MAX_WIDTH;
        max_width = YES;
    }
    
    self = [super initWithFrame:frame];
    if (self) {
        self.content = content;
        self.time = time;
        
        self.backgroundColor = CLEAR_COLOR;
        // The cell image must be named "***@2x.png", otherwise will be regarded as half resolution.
        backgroundImage = [BUBBLE_BG_IMG resizableImageWithCapInsets:UIEdgeInsetsMake(20, 16, 12, 12) resizingMode:UIImageResizingModeTile];
        backgroundImageView = [[UIImageView alloc] initWithImage:backgroundImage];
        backgroundImageView.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
        [self addSubview:backgroundImageView];
        
        labelTitle = [[UILabel alloc] initWithFrame:LABEL_TEXT_FRAME];
        labelTitle.text = self.content;
        labelTitle.textColor = LABEL_TEXT_COLOR;
        labelTitle.font = LABEL_TEXT_FONT;
        labelTitle.backgroundColor = CLEAR_COLOR;
        // avoid running out of bound
        if (max_width) {
            CGRect labelFrame = labelTitle.frame;
            labelFrame.size.width = BUBBLE_MAX_WIDTH - BUBBLE_MARGIN_RIGHT - SHADOW_WIDTH;
            labelTitle.frame = labelFrame;
        }
        [self addSubview:labelTitle];
        
        labelTime = [[UILabel alloc] initWithFrame:LABEL_TIME_FRAME];
        labelTime.text = self.time;
        labelTime.textColor = LABEL_TIME_COLOR;
        labelTime.font = LABEL_TIME_FONT;
        labelTime.backgroundColor = CLEAR_COLOR;
        [self addSubview:labelTime];
    }
    return self;
}

/* Convenient constructor */
+ (id)bubble:(NSString *)content atTime:(NSDate *)time andFrame:(CGRect)frame
{
    HPItemBubble * bubble = [[HPItemBubble alloc] initWithContent:content andTime:[NSDate description] andFrame:frame];
    return bubble;
}

@end
