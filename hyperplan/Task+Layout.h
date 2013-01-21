//
//  Task+Layout.h
//  hyperplan
//
//  Created by Phil on 11/29/12.
//  Copyright (c) 2012 Sohu Inc. All rights reserved.
//

#import "Task.h"
#import "HPConstants.h"

@interface Task (Layout)

- (CGFloat)YOffsetForScale:(CGFloat)scale inType:(HPItemBubbleScaleType)scaleType;
- (NSString *)timeRepWithMode:(HPTaskTimeRepMode)mode;
- (Boolean)tooClose:(NSDate *)time2 scale:(CGFloat)scale;//appended by Tang Yuanchao

@end
