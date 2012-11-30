//
//  Task+Layout.m
//  hyperplan
//
//  Created by Phil on 11/29/12.
//  Copyright (c) 2012 Sohu Inc. All rights reserved.
//

#import "Task+Layout.h"

@implementation Task (Layout)

- (CGFloat)YOffsetForScale:(HPItemBubbleScaleType)scale
{
    if (scale == HPItemBubbleScaleExponential) {
        CGFloat y = log([self daysSinceNow] + 1) * 200 + 20;
        NSLog(@"abs time: %f, y: %f", [self daysSinceNow], y);
        return y;
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

- (NSString *)timeRepWithMode:(HPTaskTimeRepMode)mode
{
    NSDateFormatter * df = [[NSDateFormatter alloc] init];
    
    //FIXME: need to correct the formats
    if (mode == HPTaskTimeRepDateOnly) {
        [df setDateFormat:@"yyyy年M月d日"];
        return [df stringFromDate:self.time];
    }
    else if (mode == HPTaskTimeRepDateAndTime) {
        [df setDateFormat:@"yyyy年M月d日 HH:mm"];
        return [df stringFromDate:self.time];
    }
    else if (mode == HPTaskTimeRepCompactDateAndTime) {
        [df setDateFormat:@"M月d日 HH:mm"];
        return [df stringFromDate:self.time];
    }
    else if (mode == HPTaskTimeRepCompactDateOnly) {
        [df setDateFormat:@"M月d日"];
        return [df stringFromDate:self.time];
    }
    
    return @"";
}

@end
