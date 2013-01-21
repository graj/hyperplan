//
//  HPBubbleSetList.h
//  hyperplan
//
//  Created by cowww on 12-12-29.
//  Copyright (c) 2012年 Sohu Inc. All rights reserved.
//
//  This class is build in order to provide us a general data structure to operate the bubbleSets.

#import <Foundation/Foundation.h>
#import "HPBubbleSet.h"

@class HPBubbleSet;
@class HPItemBubble;
@class HPItemIndicator;

@interface HPBubbleSetList : NSObject
{
    NSMutableArray * _setList;
    HPBubbleSet * _headSet;
    HPBubbleSet * _tailSet;//two pointers that allows the linked list realization, if needed.
}

@property (nonatomic, retain) NSMutableArray * setList;
@property (nonatomic, retain) HPBubbleSet * headSet;
@property (nonatomic, retain) HPBubbleSet * tailSet;

//  Methods Declaration
- (id)init;
- (HPBubbleSet *) makeSet:(HPItemBubble *)x;
- (HPBubbleSet *) findSet:(HPBubbleSet *)x;
- (void) unionSet:(HPBubbleSet *)x secondSet:(HPBubbleSet *)y;
- (void) splitSet:(HPBubbleSet *)x firstSetIndex:(NSInteger)index1 scale:(CGFloat)scale;

@end
