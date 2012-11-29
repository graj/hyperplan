//
//  HPNavigationBar.m
//  hyper-plan-testfield
//
//  Created by Phil on 11/6/12.
//  Copyright (c) 2012 Sohu Inc.. All rights reserved.
//

#import "HPConstants.h"
#import "HPNavigationBar.h"
#import "HPAppDelegate.h"
#import "Task.h"

#define NAV_BG_COLOR (WHITE_COLOR)
#define NAV_BG_IMG [UIImage imageNamed:@"navbar-background-2"]
#define NAV_BTN_MENU_IMG [UIImage imageNamed:@"menu-btn"]
#define NAV_BTN_MENU_PRESSED_IMG [UIImage imageNamed:@"menu-btn-pressed"]
#define NAV_BTN_ADD_IMG [UIImage imageNamed:@"navbar-btn-add"]

#define NAV_BG_FRAME CGRectMake(0, 0, SCREEN_WIDTH, 47)  /* According to the exported png */
#define NAV_BTN_MENU_FRAME CGRectMake(253, 8, 30, 30)  /* Obtained by tweaking */
#define NAV_BTN_ADD_FRAME CGRectMake(294, 16, 15, 15)

#define NAV_HINT_FONT_SIZE (14)
#define NAV_HINT_NUM_CHARS (11)
#define NAV_HINT_UPPER_FRAME CGRectMake(88, 8, NAV_HINT_FONT_SIZE*NAV_HINT_NUM_CHARS, NAV_HINT_FONT_SIZE)
#define NAV_HINT_LOWER_FRAME CGRectMake(88, 8+NAV_HINT_FONT_SIZE+4, NAV_HINT_FONT_SIZE*NAV_HINT_NUM_CHARS, NAV_HINT_FONT_SIZE)
#define NAV_HINT_FONT [UIFont fontWithName:@"STHeitiSC-Light" size:NAV_HINT_FONT_SIZE]
#define NAV_HINT_COLOR (DARK_GREY_COLOR)
#define NAV_HINT_SHADOW_COLOR (WHITE_COLOR)
#define NAV_HINT_SHADOW_OFFSET CGSizeMake(0, 1)


@implementation HPNavigationBar

UIImageView * backgroundImage;
UILabel * title;
UILabel * hintUpper;
UILabel * hintLower;
UIButton * btnMenu;
UIButton * btnAdd;
HPPopupMenu * popupMenu;
bool toggleMenu;

#pragma mark Lifecycle

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        /* initializing navigation bar itself */
        backgroundImage = [[UIImageView alloc] initWithImage:NAV_BG_IMG];
        backgroundImage.frame = NAV_BG_FRAME;
        [self addSubview:backgroundImage];
        
        /* set up navigation bar buttons */
        btnMenu = [UIButton buttonWithType:UIButtonTypeCustom];
        [btnMenu setImage:NAV_BTN_MENU_IMG forState:UIControlStateNormal];
        [btnMenu setImage:NAV_BTN_MENU_PRESSED_IMG forState:UIControlStateHighlighted];
        btnMenu.frame = NAV_BTN_MENU_FRAME;
        toggleMenu = NO;
        
        /* set up the popup menu */
        popupMenu = [HPPopupMenu menu];
        popupMenu.delegate = self;
        
        /* avoid it dimming automatically when highlighted */
        btnMenu.adjustsImageWhenHighlighted = NO;
        [self addSubview:btnMenu];
        
        btnAdd = [UIButton buttonWithType:UIButtonTypeCustom];
        [btnAdd setImage:NAV_BTN_ADD_IMG forState:UIControlStateNormal];
        btnAdd.frame = NAV_BTN_ADD_FRAME;
        [self addSubview:btnAdd];
        
        [btnMenu addTarget:self action:@selector(btnMenuPressed:) forControlEvents:UIControlEventTouchUpInside];
        [btnAdd addTarget:self action:@selector(btnAddPressed:) forControlEvents:UIControlEventTouchUpInside];

        /* could be used instead of using background image text */
        title = [[UILabel alloc] initWithFrame:CGRectZero];
        title.frame = CGRectMake(0, 0, 60, 20);
        title.text = @"截止日";
        title.font = [UIFont fontWithName:@"Heiti SC" size:16];

        //TODO: do this on database update
        /* set up hint labels */
        [self updateNavigationBarHints];
    }
    return self;
}

#pragma mark Bar button actions

/* helper handling popup menu show or hide */
- (void)toggleMenuShowOrHide
{
    if ((toggleMenu = !toggleMenu)) {
        [btnMenu setImage:NAV_BTN_MENU_PRESSED_IMG forState:UIControlStateNormal];
        [popupMenu showInContext:[self getContext]];
    }
    else {
        [btnMenu setImage:NAV_BTN_MENU_IMG forState:UIControlStateNormal];
        [popupMenu hideFromCurrentContext];
    }
}

- (void)btnMenuPressed:(id)sender
{
    [self toggleMenuShowOrHide];
    [self.delegate navbarMenuButtonPressed:sender];
}

- (void)btnAddPressed:(id)sender
{
    [self.delegate navbarAddButtonPressed:sender];
}

#pragma mark Delegate methods of popup menu button actions implementing HPPopupMenuDelegate

- (void)menuItemPressed:(NSInteger)index
{
    [self toggleMenuShowOrHide];
    [self.delegate menuItemPressed:index];
}

- (void)splitButtonPressed:(NSInteger)index
{
    [self toggleMenuShowOrHide];
    [self.delegate splitButtonPressed:index];
}

- (void)bigHiddenButtonPressed
{
    [self toggleMenuShowOrHide];
}

/* get current active window */
- (UIWindow *)getContext
{
    return ((HPAppDelegate *)([UIApplication sharedApplication].delegate)).window;
}

#pragma mark - Dynamically update navigation bar hints

- (void)updateNavigationBarHints
{
    Task * nearestTask = [Task findFirstWithPredicate:[NSPredicate predicateWithFormat:@"state == %d", HPTaskStateDue] sortedBy:@"time" ascending:YES];
    NSString * timePart;
    NSString * hintUpperText;
    
    if (nearestTask) {
        CGFloat days = [nearestTask.time timeIntervalSinceNow] / 3600 / 24;
        if (days < 1) {
            timePart = [NSString stringWithFormat:@"%.0f小时后", days * 24];
        }
        else {
            timePart = [NSString stringWithFormat:@"%d天后",  (int)days];
        }
        hintUpperText = [NSString stringWithFormat:@"%@：%@", timePart, nearestTask.title];
    }
    else {
        hintUpperText = @"没有未完成的任务";
    }
    
    hintUpper = [[UILabel alloc] initWithFrame:NAV_HINT_UPPER_FRAME];
    hintUpper.text = hintUpperText;
    hintUpper.font = NAV_HINT_FONT;
    hintUpper.textColor = NAV_HINT_COLOR;
    hintUpper.shadowColor = NAV_HINT_SHADOW_COLOR;
    hintUpper.shadowOffset = NAV_HINT_SHADOW_OFFSET;
    hintUpper.backgroundColor = CLEAR_COLOR;
    [self addSubview:hintUpper];
    
    NSArray * allTasks = [Task findAllWithPredicate:[NSPredicate predicateWithFormat:@"state == %d", HPTaskStateDue]];
    int weekCount = [[allTasks filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(Task * task, NSDictionary * bindings) {
        return [task.time timeIntervalSinceNow] < 86400 * 7;
    }]] count];
    int monthCount = [[allTasks filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(Task * task, NSDictionary * bindings) {
        return [task.time timeIntervalSinceNow] < 86400 * 30;
    }]] count];
    
    hintLower = [[UILabel alloc] initWithFrame:NAV_HINT_LOWER_FRAME];
    hintLower.text = [NSString stringWithFormat:@"本周：%d  | 本月：%d", weekCount, monthCount];
    hintLower.font = NAV_HINT_FONT;
    hintLower.textColor = NAV_HINT_COLOR;
    hintLower.shadowColor = NAV_HINT_SHADOW_COLOR;
    hintLower.shadowOffset = NAV_HINT_SHADOW_OFFSET;
    hintLower.backgroundColor = CLEAR_COLOR;
    [self addSubview:hintLower];
}

@end
