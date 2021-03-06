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
#import "Task.h"
#import "CoreData+MagicalRecord.h"

#define NAV_FRAME CGRectMake(0, 0, 320, 47)
#define MAIN_FRAME CGRectMake(0,44, 320, 416)

@implementation HPViewController
{
    HPNavigationBar * navigationBar;
    HPTimelineViewController * timelineViewController;
}

#pragma mark Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initTestData];
    
    self.view.backgroundColor = MAIN_VIEW_TEXTURE;

    /* add HPTimelineViewController */
    timelineViewController = [[HPTimelineViewController alloc] init];
    [timelineViewController.view setFrame:MAIN_FRAME];
    [self.view addSubview:timelineViewController.view];
    
    [timelineViewController initContents];
    
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
    [self addTaskTitled:@"Web作业" withContent:@"第十次" atTime:[[NSDate date] dateByAddingTimeInterval:DAY] andState:HPTaskStateDue];
    [self addTaskTitled:@"毛概论文" withContent:@"毛概论文三篇" atTime:[[NSDate date] dateByAddingTimeInterval:DAY*4] andState:HPTaskStateDue];
    [self addTaskTitled:@"操统实习报告" withContent:@"操统实习报告，Lab4报告，小测" atTime:[[NSDate date] dateByAddingTimeInterval:DAY*4+HOUR*4]  andState:HPTaskStateDue];
    [self addTaskTitled:@"数理作业" withContent:@"P559 14(2 4 5)" atTime:[[NSDate date] dateByAddingTimeInterval:DAY*5]  andState:HPTaskStateDue];

    [self addTaskTitled:@"操统实习小测" withContent:@"" atTime:[[NSDate date] dateByAddingTimeInterval:DAY*7]  andState:HPTaskStateDue];
    [self addTaskTitled:@"一周后" withContent:@"" atTime:[[NSDate date] dateByAddingTimeInterval:DAY*8] andState:HPTaskStateDue];
    [self addTaskTitled:@"操统实习课堂报告" withContent:@"" atTime:[[NSDate date] dateByAddingTimeInterval:DAY*15]  andState:HPTaskStateDue];
    [self addTaskTitled:@"一个月后" withContent:@"" atTime:[[NSDate date] dateByAddingTimeInterval:DAY*32] andState:HPTaskStateDue];
}

@end
