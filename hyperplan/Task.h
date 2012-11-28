//
//  Task.h
//  hyperplan
//
//  Created by wuhaotian on 12-11-15.
//  Copyright (c) 2012年 sohu-inc. All rights reserved.
//


/*
 本注释说明的相关调用适用于所有在该项目中定义的 ManagedObject 实例
 Creating new Entities
 
 Task *atask = [Task createEntity];

 Deleting Entities
 
 To delete a single entity:
 
 Task *t = ...;
 [t  deleteEntity];
 
 There is no delete All Entities or truncate operation in core data, so one is provided for you with Active Record for Core Data:
 
 [Task truncateAll];
 */
#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Task : NSManagedObject

@property (nonatomic, retain) NSString * content;
@property (nonatomic, retain) NSNumber * state;
@property (nonatomic, retain) NSDate * time;
@property (nonatomic, retain) NSString * title;

@end
