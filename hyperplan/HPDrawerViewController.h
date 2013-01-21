//
//  HPDrawerViewController.h
//  hyperplan
//
//  Created by Phil on 12/29/12.
//  Copyright (c) 2012 Sohu Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HPItemBubble.h"

@interface HPDrawerViewController : UIViewController <HPItemBubbleDelegate>
{
    HPItemBubble * _currentActiveBubble;
    NSMutableArray * _bubbles;
}

- (void)initContents;
- (void)showPastTasks;
- (void)hidePastTasks;

@end
