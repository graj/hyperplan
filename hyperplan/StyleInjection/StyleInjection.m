//
//  StyleInjection.m
//  hyperplan
//
//  Created by wuhaotian on 12-11-29.
//  Copyright (c) 2012年 Sohu Inc. All rights reserved.
//

#import "StyleInjection.h"
#import <pthread.h>

static pthread_mutex_t sInjectionMutex;
static NSMutableDictionary *sInjectionContext;

@implementation StyleInjection

+ (void)initialize {
    if (self == [StyleInjection class]) {
        sInjectionContext = [[NSMutableDictionary alloc] init];
        pthread_mutexattr_t mutexattr;
        pthread_mutexattr_init(&mutexattr);
        pthread_mutexattr_settype(&mutexattr, PTHREAD_MUTEX_RECURSIVE);
        pthread_mutex_init(&sInjectionMutex, &mutexattr);
        pthread_mutexattr_destroy(&mutexattr);
    }
}

+ (void)registerClass:(Class)aClass
{
    
}

+ (void)reset
{
    pthread_mutex_lock(&sInjectionMutex);
    [sInjectionContext removeAllObjects];
    pthread_mutex_unlock(&sInjectionMutex);
}
@end
