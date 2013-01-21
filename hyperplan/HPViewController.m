//
//  ViewController.m
//  hyper-plan-testfield
//
//  Created by Phil on 11/1/12.
//  Copyright (c) 2012 Sohu Inc.. All rights reserved.
//

#import "HPConstants.h"
#import "HPViewController.h"
#import "HPNavigationBar.h"
#import "HPTimelineViewController.h"
#import "HPDrawerViewController.h"
#import "Task.h"
#import "CoreData+MagicalRecord.h"

#define NAV_FRAME CGRectMake(0, 0, 320, 44)
#define MAIN_FRAME CGRectMake(0, 0, 320, 460)

@implementation HPViewController
{
    HPNavigationBar * navigationBar;
    HPDrawerViewController * drawerViewController;
}

#pragma mark Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initTestData];
    
    self.view.backgroundColor = MAIN_VIEW_TEXTURE;

    /* add HPTimelineViewController */
    drawerViewController = [[HPDrawerViewController alloc] init];
    [drawerViewController.view setFrame:MAIN_FRAME];
    [self.view addSubview:drawerViewController.view];
    
    [drawerViewController initContents];
    
    /* set up navigation bar */
    navigationBar = [[HPNavigationBar alloc] initWithFrame:NAV_FRAME];
    navigationBar.delegate = self;
    [self.view addSubview:navigationBar];
}


#pragma mark - Navigation Bar button actions from HPNavigationBarDeletage

- (void)navbarMenuButtonPressed:(id)sender
{
    NSLog(@"menu pressed FROM viewController");
}

- (void)navbarAddButtonPressed:(id)sender
{
    NSLog(@"add pressed FROM viewController");
}

- (void)menuItemPressed:(NSInteger)index
{
    NSLog(@"menu item %d pressed FROM viewController", index);
    if (index == 1) {
        [drawerViewController hidePastTasks];
    }
    if (index == 2) {
        [drawerViewController showPastTasks];
    }
}

- (void)splitButtonPressed:(NSInteger)index
{
    NSLog(@"split button %d pressed FROM viewController", index);
}

#pragma mark - Model methods

- (void) addTaskTitled:(NSString *)title withContent:(NSString *)content atTime:(NSDate *)time andState:(HPTaskStateType)state
{
    Task * t = [Task createEntity];
    t.title = title;
    t.content = content;
    t.time = time;
    t.state = @(state);
    [[NSManagedObjectContext defaultContext] save];
}

- (void)initTestData
{
    NSDate * today = [NSDate date];
    
    [self addTaskTitled:@"数理考试" withContent:@"提前刷题" atTime:[today dateByAddingTimeInterval:-DAY*1-HOUR*16] andState:HPTaskStateDue];
    [self addTaskTitled:@"体系考试" withContent:@"只考讲过的，有少量期中前内容" atTime:[today dateByAddingTimeInterval:-HOUR*22] andState:HPTaskStateDue];
    [self addTaskTitled:@"毛概考试" withContent:@"二教101，刘志光" atTime:[today dateByAddingTimeInterval:-HOUR*2]  andState:HPTaskStateDue];
    [self addTaskTitled:@"操统考试" withContent:@"魏豪调成绩" atTime:[today dateByAddingTimeInterval:DAY*14+HOUR*22]  andState:HPTaskStateDue];

    [self addTaskTitled:@"概统考试" withContent:@"内容待定" atTime:[today dateByAddingTimeInterval:DAY*15+HOUR*16]  andState:HPTaskStateDue];
    [self addTaskTitled:@"Web考试" withContent:@"见课程网" atTime:[today dateByAddingTimeInterval:DAY*15+HOUR*22] andState:HPTaskStateDue];
    [self addTaskTitled:@"SICP考试" withContent:@"待定" atTime:[today dateByAddingTimeInterval:DAY*16+HOUR*22]  andState:HPTaskStateDue];
    [self addTaskTitled:@"JOS面测" withContent:@"待定" atTime:[today dateByAddingTimeInterval:DAY*17+HOUR*16] andState:HPTaskStateDue];
}

@end
