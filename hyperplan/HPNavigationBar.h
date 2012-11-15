//
//  HPNavigationBar.h
//  hyper-plan-testfield
//
//  Created by Phil on 11/6/12.
//  Copyright (c) 2012 Sohu Inc.. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HPPopupMenu.h"

#pragma mark delegate protocol

@protocol HPNavigationBarDelegate <NSObject>

- (void)navbarMenuButtonPressed:(id)sender;
- (void)navbarAddButtonPressed:(id)sender;
- (void)menuItemPressed:(NSInteger)index;
- (void)splitButtonPressed:(NSInteger)index;

@end


#pragma mark interface

@interface HPNavigationBar : UIView <HPPopupMenuDelegate>
{
    id <HPNavigationBarDelegate> _delegate;
}

@property (nonatomic) id <HPNavigationBarDelegate> delegate;

@end
