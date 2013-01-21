//
//  HPConstants.h
//  hyper-plan-testfield
//
//  Created by Phil on 11/9/12.
//  Copyright (c) 2012 Sohu Inc. All rights reserved.
//

/*
 * Definitions for debugging.
 */

#define DEBUG_BG_COLOR [UIColor greenColor]

/*
 * iOS Hardcoded properties (use non-retina resolution when coding)
 */

#define SCREEN_WIDTH (320)
#define SCREEN_HEIGHT (480)
#define STATUS_BAR_HEIGHT (20)
#define NAVIGATION_BAR_HEIGHT (44)

/*
 * View properties
 */

#define MAIN_VIEW_WIDTH (SCREEN_WIDTH)
#define MAIN_VIEW_HEIGHT (SCREEN_HEIGHT - STATUS_BAR_HEIGHT - NAVIGATION_BAR_HEIGHT)

/*
 * Colors
 */

#define GREY_WHITE_COLOR [UIColor colorWithRed:246/255. green:246/255. blue:246/255. alpha:1]
#define MEDIUM_GREY_COLOR [UIColor colorWithRed:169/255. green:169/255. blue:169/255. alpha:1]
#define DARK_GREY_COLOR [UIColor colorWithRed:107/255. green:107/255. blue:107/255. alpha:1]

#define WHITE_COLOR [UIColor whiteColor]
#define BLACK_COLOR [UIColor blackColor]
#define CLEAR_COLOR [UIColor clearColor]

#define MAIN_VIEW_TEXTURE [UIColor underPageBackgroundColor]
#define LIGHT_MASK_COLOR [UIColor colorWithHue:69/360 saturation:0.03 brightness:0.97 alpha:0.5]

#define MAIN_BG_COLOR (LIGHT_MASK_COLOR)


/*
 * Enums
 */

/* associate with Task.h */
typedef enum HPTaskStateType : NSInteger {
    HPTaskStateDue,
    HPTaskStateFinished,
    HPTaskStateMissed
} HPTaskStateType;

/* The scale for calculating bubble y offsets */
typedef enum HPItemBubbleScaleType : NSUInteger {
    HPItemBubbleScaleExponential,
    HPItemBubbleScaleLinear
} HPItemBubbleScaleType;

/* The mode for representing time */
typedef enum HPTaskTimeRepMode : NSUInteger {
    HPTaskTimeRepDateOnly,
    HPTaskTimeRepDateAndTime,
    HPTaskTimeRepCompactDateOnly,
    HPTaskTimeRepCompactDateAndTime,
} HPTaskTimeRepMode;


/*h
 * Time related
 */

/* useful time interval in seconds */
#define HOUR (3600)
#define HDAY (43200)
#define DAY (86400)
#define WEEK (DAY * 7)
#define MONTH (DAY * 30)
#define YEAR (DAY * 365)

//appended by Tang Yuanchao
//build relations between screen pixels and time interval to display
#define DAYS_PER_SCREEN (4)
#define LEAST_PIXEL_INTERVAL (80)