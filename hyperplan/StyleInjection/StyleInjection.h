//
//  StyleInjection.h
//  hyperplan
//
//  Created by wuhaotian on 12-11-29.
//  Copyright (c) 2012年 Sohu Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#define style_register(value) \
    + (void)initialize { \
        if (self == [value class]) { \
            [StyleInjection registerClass:[value class]]; \
        } \
    }


@interface StyleInjection : NSObject

+ (void)registerClass:(Class)aClass;

@end
