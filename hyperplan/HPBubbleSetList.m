//
//  HPBubbleSetList.m
//  hyperplan
//
//  Created by cowww on 12-12-29.
//  Copyright (c) 2012年 Sohu Inc. All rights reserved.
//
//  This 

#import "HPBubbleSetList.h"
#import "HPBubbleSet.h"
#import "HPItemBubble.h"
#import "HPItemIndicator.h"
#import "Task.h"
#import "Task+Layout.h"

@implementation HPBubbleSetList
{
    
}

//  initialization
- (id)init
{
    self.setList = [NSMutableArray array];
    return self;
}

//  makeSet: make a set with a bubble.
- (HPBubbleSet *) makeSet:(HPItemBubble *)x
{
    HPBubbleSet * tempSet = [HPBubbleSet alloc];
    [tempSet initWithBubble:x];
    return tempSet;
}

//  findSet: find a set with a bubbleSet.
- (HPBubbleSet *) findSet:(HPBubbleSet *)x
{
    return x.setHead;
}

//  unionSet: union two sets when needed. The structure of the setList will be changed.
//  Meanwhile, the union operation will ensure the setList in order, by ensuring that y is always joined into x.
//  Should add animation when union is called. But add HERE???
- (void) unionSet:(HPBubbleSet *)x secondSet:(HPBubbleSet *)y;
{
    //join y into x
    //  1st step: union two arrays, modify the setHead pointer:
    //  if x has only one element, we have to create a new set and insert it into the old set.
    if (x.count == 1) {
        HPBubbleSet * tempSet = [HPBubbleSet alloc];
        [tempSet initWithBubble:x.bubble];
        [x.setArray addObject:tempSet];
        tempSet.setHead = x;
    }
    //  now union
    if (y.count == 1) {
        [x.setArray addObject:y];
        y.setHead = x;
        x.count++;
        [y UIOperationWhenMergeTo:x];//    animation in union
    }
    else
    {
        int i;
        for(i=0;i<y.count;i++){
            HPBubbleSet * tempSet = y.setArray[i];
            [x.setArray addObject:tempSet];
            tempSet.setHead = x.setHead;
            x.count++;
            [tempSet UIOperationWhenMergeTo:x];    //animation in union
        }
    }
    
    //  2nd step: modify the pointers in setArray:
    x.next = y.next;
    
    //  3rd step: delete the y set from setList:
    [self.setList removeObjectIdenticalTo:y];
    
}

//  splitSet: split two sets when needed. The method split set x at the index of set y, which is in its setArray. In other words, set x will be split into two parts, and y is the split point. After splitting, setList will be refreshed.
//  Parameter notation: set x is the set to be split, x is in setList; set y is in x's setArray, where x need to be split into two parts; index1 is x's position in the setList; index2 is y's position in x's setArray.
//  Should add animation. But add HERE???
- (void) splitSet:(HPBubbleSet *)x firstSetIndex:(NSInteger)index1 scale:(CGFloat)scale
{
    //  zero step: check the end of array. if this element is too close to next set, do not split.
    if (index1+1 < [self.setList count]) {
        HPBubbleSet * nextSet = self.setList[index1+1];
        HPBubbleSet * endSet = (HPBubbleSet *)(x.setArray[x.count-1]);
        if ([endSet.bubble.task tooClose:nextSet.bubble.task.time scale:scale]) {
            return;
        }
    }
    
    //  1st step: find the split point.
    NSInteger index2 = [self findSplitPoint:x scale:scale];
    //  if no split point, return.
    if(index2 <= 0)
        return;
    HPBubbleSet * y = (HPBubbleSet *)(x.setArray[index2]);
    
    //  2nd step: create a new bubbleSet, whose delegate bubble is y's delegate bubble.
    HPBubbleSet * tempSet = [HPBubbleSet alloc];
    [tempSet initWithBubble:y.bubble];
    
    //  3rd step: append all sets start from y into the new set, meanwhile remove them from x.
    int i;
    if ([x.setArray count] - index2 > 1) {
        tempSet.count--;
        for (i = index2; i<[x.setArray count]; i++) {
            HPBubbleSet * tempSet2 = (HPBubbleSet *)(x.setArray[i]);
            [tempSet.setArray addObject:tempSet2];
            tempSet2.setHead = tempSet;
            tempSet.count++;
            [tempSet2 UIOperationWhenMergeTo:tempSet]; //  animation in split
        }
    }
    
    for (i = x.count-1; i>=index2; i--) {
        [x.setArray removeObjectAtIndex:i];
    }
    x.count = index2;
    
    //  special condition: x has only one object, clear setArray.
    if (x.count == 1) {
        [x.setArray removeAllObjects];
    }
    [tempSet UIOperationWhenSplitFrom:x];   //  animation in split
    
    //  4th step: insert the new set into setList.
    [self.setList insertObject:tempSet atIndex:(index1+1)];

    //  5th step: modify the pointers in setList:
    tempSet.next = x.next;
    x.next = tempSet;

}

//  find the split point of a set. must ensure that the source set should contain more than 1 element.
- (NSInteger)findSplitPoint:(HPBubbleSet *)sourceSet scale:(CGFloat)scale
{
    NSInteger i;
    for (i=0; i<sourceSet.count; i++) {
        HPBubbleSet * tempSet = (HPBubbleSet *)(sourceSet.setArray[i]);
        if (![sourceSet.bubble.task tooClose:tempSet.bubble.task.time scale:scale]) {
            return i;
        }
    }
    return -1;
}

@end
