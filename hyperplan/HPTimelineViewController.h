//
//  HPTimelineViewController.h
//  hyperplan
//
//  Created by wuhaotian on 12-11-15.
//  Copyright (c) 2012年 Sohu Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HPItemBubble.h"

@interface HPTimelineViewController : UIViewController <HPItemBubbleDelegate>
{
    HPItemBubble * _currentActiveBubble;
    NSMutableArray * _bubbles;
}

- (void)initContents;

@end
