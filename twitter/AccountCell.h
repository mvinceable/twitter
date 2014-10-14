//
//  AccountCell.h
//  twitter
//
//  Created by Vince Magistrado on 10/12/14.
//  Copyright (c) 2014 Vince Magistrado. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"

@protocol AccountCellDelegate <NSObject>

- (void)onUserDelete:(User *)user;

@end

@interface AccountCell : UITableViewCell

@property (strong, nonatomic) User *user;

- (void)onPan:(UIGestureRecognizer *)sender location:(CGPoint)location translation:(CGPoint)translation velocity:(CGPoint)velocity;

@property (nonatomic, weak) id <AccountCellDelegate> delegate;

@end
