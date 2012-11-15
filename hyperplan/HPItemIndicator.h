//
//  HPItemIndicator.h
//  hyper-plan-testfield
//
//  Created by Phil on 11/9/12.
//  Copyright (c) 2012 Sohu Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HPItemIndicator : UIView
{
    NSInteger _number;
}

@property (nonatomic, assign) NSInteger number;

+ (id)indicatorAt:(CGPoint)center;

@end
