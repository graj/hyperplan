//
//  HPItemIndicator.h
//  hyper-plan-testfield
//
//  Created by Phil on 11/9/12.
//  Copyright (c) 2012 Sohu Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HPItemBubble.h"

@interface HPItemIndicator : UIView
{
    NSInteger _number;
}

@property (nonatomic, assign) NSInteger number;

// Should be deprecated
+ (id)indicatorAt:(CGPoint)center;

+ (id)indicatorForBubble:(HPItemBubble *)bubble;

@end
