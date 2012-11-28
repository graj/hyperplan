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
#import "QuartzCore/CALayer.h"
#import "Task.h"
#import "CoreData+MagicalRecord.h"

#define NAV_FRAME CGRectMake(0, 0, 320, 44)
#define MAIN_FRAME CGRectMake(0,44, 320, 416)

@implementation HPViewController

HPNavigationBar * navigationBar;
HPTimelineViewController * timelineViewController;

#pragma mark Lifecycle

- (void)viewDidLoad
{

    [super viewDidLoad];
    self.view.backgroundColor = MAIN_VIEW_TEXTURE;

    /* set up navigation bar */
    navigationBar = [[HPNavigationBar alloc] initWithFrame:NAV_FRAME];
    navigationBar.delegate = self;
    [self.view addSubview:navigationBar];
    
    /* add HPTimelineViewController */
    timelineViewController = [[HPTimelineViewController alloc] init];
    [timelineViewController.view setFrame:MAIN_FRAME];
    [self.view addSubview:timelineViewController.view];
    
    Task * t = [Task createEntity];
    t.content = @"操统报告";
    t.time = [NSDate date];
    t.title = @"操统报告";
    t.state = @(1);

    [timelineViewController initContents];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
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

@end
