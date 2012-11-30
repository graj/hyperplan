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
    UIImageView * _backgroundView;
    UILabel * _label;
}

@property (nonatomic, assign) NSInteger number;
@property (nonatomic, retain) UIImageView * backgroundView;
@property (nonatomic, retain) UILabel * label;

// Should be deprecated
+ (id)indicatorAt:(CGPoint)center;

+ (id)indicatorForBubble:(UIView *)bubble;

- (void)enableEditMode;
- (void)cancelEditMode;

@end
