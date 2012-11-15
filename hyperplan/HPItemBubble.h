//
//  HPItemBubble.h
//  hyper-plan-testfield
//
//  Created by Phil on 11/6/12.
//  Copyright (c) 2012 Sohu Inc.. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HPItemBubble : UIView
{
    NSString * _content;
    NSString * _time;
}

@property (nonatomic, strong) NSString * content;
@property (nonatomic, strong) NSString * time;

- (id)initWithContent:(NSString *)content andTime:(NSString *)time andFrame:(CGRect)frame;
+ (id)bubble:(NSString *)content atTime:(NSDate *)time andFrame:(CGRect)frame;

@end
