//
//  Task+Layout.m
//  hyperplan
//
//  Created by Phil on 11/29/12.
//  Copyright (c) 2012 Sohu Inc. All rights reserved.
//

#import "Task+Layout.h"

@implementation Task (Layout)

//static int y = -40;

- (CGFloat)YOffsetForScale:(HPItemBubbleScaleType)scale
{
    if (scale == HPItemBubbleScaleExponential) {
        //TODO:
        CGFloat y = log([self daysSinceNow] + 1) * 200 + 20;
        NSLog(@"abs time: %f, y: %f", [self daysSinceNow], y);
        return y;
//        y += 60;
//        
//        return y;
    }
    else if (scale == HPItemBubbleScaleLinear) {
        
    }

    
    return 0;
}


- (NSTimeInterval)daysSinceNow
{
    return [self timeSinceNow] / 3600 / 24;
}

- (NSInteger)timeSinceNow
{
    return [self.time timeIntervalSinceNow];
}


@end
