//
//  HPPopupMenu.h
//  hyper-plan-testfield
//
//  Created by Phil on 11/8/12.
//  Copyright (c) 2012 Sohu Inc.. All rights reserved.
//

#import <UIKit/UIKit.h>

#pragma mark delegate protocol

@protocol HPPopupMenuDelegate <NSObject>

- (void)menuItemPressed:(NSInteger)index;
- (void)splitButtonPressed:(NSInteger)index;
- (void)bigHiddenButtonPressed;

@end


#pragma mark interface

@interface HPPopupMenu : UIView <UITableViewDataSource, UITableViewDelegate>
{
    id <HPPopupMenuDelegate> _delegate;
}

@property (nonatomic) id <HPPopupMenuDelegate> delegate;

+ (id)menu;
- (void)showInContext:(UIWindow *)context;
- (void)hideFromCurrentContext;

@end

