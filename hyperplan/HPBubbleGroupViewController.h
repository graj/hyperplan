//
//  HPBubbleGroupViewController.h
//  hyperplan
//
//  Created by wuhaotian on 11/29/12.
//  Copyright (c) 2012 Sohu Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Task;

@interface HPBubbleGroupViewController : UIViewController

- (CGSize)sizeWithTasks:(NSArray *)array_tasks;
- (CGSize)resizeWithAppendingTask:(Task *)task;

@end
