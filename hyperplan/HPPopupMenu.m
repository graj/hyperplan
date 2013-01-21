//
//  HPPopupMenu.m
//  hyper-plan-testfield
//
//  Created by Phil on 11/8/12.
//  Copyright (c) 2012 Sohu Inc.. All rights reserved.
//

#import "HPConstants.h"
#import "HPPopupMenu.h"
#import "QuartzCore/CALayer.h"

#define MENU_BG_COLOR (GREY_WHITE_COLOR)
#define MENU_SEPARATOR_COLOR (MEDIUM_GREY_COLOR)
#define MENU_CANCEL_AREA_FRAME CGRectMake(0, NAVIGATION_BAR_HEIGHT + STATUS_BAR_HEIGHT, MAIN_VIEW_WIDTH, MAIN_VIEW_HEIGHT)

/* whatever you like */
#define MENU_HEIGHT (260)
#define MENU_WIDTH (200)
#define MENU_X (120)
#define MENU_Y (26 + STATUS_BAR_HEIGHT)

/* decided by the png's shadow weight */
#define MENU_MARGIN_LEFT (9)
#define MENU_MARGIN_RIGHT (10)
#define MENU_MARGIN_TOP (21)
#define MENU_MARGIN_BOTTOM (10)
#define MENU_TABLE_RADIUS (8.)

/* calculated precisely to fit the table view into hollow photo-frame */
#define MENU_TABLE_WIDTH (MENU_WIDTH - MENU_MARGIN_LEFT - MENU_MARGIN_RIGHT)
#define MENU_TABLE_HEIGHT (MENU_HEIGHT - MENU_MARGIN_TOP - MENU_MARGIN_BOTTOM)
#define MENU_DEFAULT_FRAME CGRectMake(MENU_X, MENU_Y, MENU_WIDTH, MENU_HEIGHT) // 120, 26+20, 200, 260

/* coordinates relative to popupMenu itself */
#define MENU_PHOTOFRAME_FRAME CGRectMake(0, 0, MENU_WIDTH, MENU_HEIGHT) // 0, 0, 200, 260
#define MENU_TABLE_FRAME CGRectMake(MENU_MARGIN_LEFT, MENU_MARGIN_TOP,MENU_TABLE_WIDTH, MENU_TABLE_HEIGHT) //9, 9, 181, 181

#define MENU_PHOTOFRAME_IMG [UIImage imageNamed:@"popupmenu-hollow"]
#define MENU_TABLE_CELL_FONT [UIFont fontWithName:@"HiraginoSansGB-W3" size:16]
#define MENU_SPLIT_CELL_BTN_LEFT_IMG [UIImage imageNamed:@"splitCellButtonLeft"]
#define MENU_SPLIT_CELL_BTN_RIGHT_IMG [UIImage imageNamed:@"splitCellButtonRight"]
#define MENU_SPLIT_CELL_BTN_LEFT_PRESSED_IMG [UIImage imageNamed:@"splitCellButtonLeft-pressed"]
#define MENU_SPLIT_CELL_BTN_RIGHT_PRESSED_IMG [UIImage imageNamed:@"splitCellButtonRight-pressed"]

/* They are associated with splitCellButton*.png's size */
#define MENU_TABLE_CELL_HEIGHT (50)
#define MENU_SPLIT_CELL_BTN_LEFT_FRAME CGRectMake(0, 0, 91, MENU_TABLE_CELL_HEIGHT)
#define MENU_SPLIT_CELL_BTN_RIGHT_FRAME CGRectMake(91, 0, 90, MENU_TABLE_CELL_HEIGHT)

#define POPUP_MENU_FADING_TIME 0.25


@implementation HPPopupMenu
{
    UITableView * tableView;
    UIImageView * photoFrame;
    NSArray * itemTitles;
    UIButton * splitCellLeftBtn;
    UIButton * splitCellRightBtn;
    UIButton * bigHiddenButton;
}

#pragma mark Lifecycle

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = CLEAR_COLOR;
        
        /* set up a table view with solid background */
        tableView = [[UITableView alloc] initWithFrame:MENU_TABLE_FRAME style:UITableViewStylePlain];
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        tableView.separatorColor = MENU_SEPARATOR_COLOR;
        tableView.backgroundColor = MENU_BG_COLOR;
        [self addSubview:tableView];
        
        /* cover a rounded-rect frame with border and shadow and transparent filling on the table view */
        photoFrame = [[UIImageView alloc] initWithImage:[MENU_PHOTOFRAME_IMG resizableImageWithCapInsets:UIEdgeInsetsMake(60, 24, 24, 128) resizingMode:UIImageResizingModeTile]];
        photoFrame.frame = MENU_PHOTOFRAME_FRAME;
        [self addSubview:photoFrame];
        
        /* set up rounded corner, avoid the table cell separator overflow the rounded-rect frame */
        /* this value must match with the rounded-rect frame's radius, i.e. half of the radius in PS */
        tableView.layer.cornerRadius = MENU_TABLE_RADIUS;

        /* init button titles */
        itemTitles = [NSArray arrayWithObjects:@"全局视图", @"过期事件...", @"设置...", @"关于...", nil];
        
        /* set up bigHiddenButton */
        bigHiddenButton = [UIButton buttonWithType:UIButtonTypeCustom];
        bigHiddenButton.backgroundColor = CLEAR_COLOR;
        bigHiddenButton.frame = MENU_CANCEL_AREA_FRAME;
        [bigHiddenButton addTarget:self action:@selector(bigHiddenButtonPressed) forControlEvents:UIControlEventTouchDown];
    }
    return self;
}

+ (id)menu
{
    CGRect menuDefaultFrame = MENU_DEFAULT_FRAME;
    HPPopupMenu * menu = [[HPPopupMenu alloc] initWithFrame:menuDefaultFrame];
    return menu;
}


#pragma mark TableView data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [itemTitles count] + 1;
}

- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell;
    
    /* build split button cell */
    if (indexPath.row == 0) {
        cell = [theTableView dequeueReusableCellWithIdentifier:@"Split"];
        if (cell)
            return cell;
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Split"];
        
        /* init the two buttons */
        splitCellLeftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        splitCellRightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [splitCellLeftBtn setImage:MENU_SPLIT_CELL_BTN_LEFT_IMG forState:UIControlStateNormal];
        [splitCellRightBtn setImage:MENU_SPLIT_CELL_BTN_RIGHT_IMG forState:UIControlStateNormal];
        splitCellLeftBtn.frame = MENU_SPLIT_CELL_BTN_LEFT_FRAME;
        splitCellRightBtn.frame = MENU_SPLIT_CELL_BTN_RIGHT_FRAME;
        
        /* set the selected state for the cell */
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [splitCellLeftBtn setImage:MENU_SPLIT_CELL_BTN_LEFT_PRESSED_IMG forState:UIControlStateHighlighted];
        [splitCellRightBtn setImage:MENU_SPLIT_CELL_BTN_RIGHT_PRESSED_IMG forState:UIControlStateHighlighted];
        [splitCellLeftBtn addTarget:self action:@selector(splitCellBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
        [splitCellRightBtn addTarget:self action:@selector(splitCellBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
        
        [cell.contentView addSubview: splitCellLeftBtn];
        [cell.contentView addSubview: splitCellRightBtn];        
    }
    /* build default button cell */
    else {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Default"];
        cell.textLabel.text = [itemTitles objectAtIndex:indexPath.row - 1];
        cell.textLabel.font = MENU_TABLE_CELL_FONT;
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
    }
    
    /* Hide extra cell separators */
    [self setExtraCellLineHidden:theTableView];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return MENU_TABLE_CELL_HEIGHT;
}

/* self-defined method to hide extra cell lines */
- (void)setExtraCellLineHidden: (UITableView *)theTableView
{
    UIView * view = [UIView new];
    view.backgroundColor = CLEAR_COLOR;
    [theTableView setTableFooterView:view];
}

/* make sure that the table is scrolled to top everytime it shows */
- (void)willMoveToSuperview:(UIView *)newSuperview
{
    if (newSuperview)
        [tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
}

#pragma mark User interactive methods

- (void)tableView:(UITableView *)theTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0)
        return;     //splitCellBtnPressed will handle this.
    else {
        [theTableView deselectRowAtIndexPath:indexPath animated:NO];
        [self.delegate menuItemPressed:indexPath.row];
    }
}

- (void)splitCellBtnPressed:(id)sender
{
    NSInteger idx = -1;
    if (sender == splitCellLeftBtn)
        idx = 0;
    else if (sender == splitCellRightBtn)
        idx = 1;
    [self.delegate splitButtonPressed:idx];
}

- (void)bigHiddenButtonPressed
{
    [self.delegate bigHiddenButtonPressed];
}


#pragma mark Methos handling view show or hide

/* helper for delayed execution */
- (void)afterMenuFaded
{
    [self removeFromSuperview];
}


/*
 * Called by its owner 
 */

//TODO: fix animation bug when first-time appears (caused by lazy-constructing)
- (void)showInContext:(UIWindow *)context
{
    self.alpha = 0;
    [context addSubview:bigHiddenButton];
    [context addSubview:self];
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    
    [UIView beginAnimations:@"Fade in" context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:POPUP_MENU_FADING_TIME];
    self.alpha = 1;
    [UIView commitAnimations];
}

- (void)hideFromCurrentContext
{
    [self performSelector:@selector(afterMenuFaded) withObject:nil afterDelay:POPUP_MENU_FADING_TIME];
    [bigHiddenButton removeFromSuperview];
    
    [UIView beginAnimations:@"Fade out" context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:POPUP_MENU_FADING_TIME];
    self.alpha = 0;
    [UIView commitAnimations];
}


@end
