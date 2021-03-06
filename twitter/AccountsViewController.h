//
//  AccountsViewController.h
//  twitter
//
//  Created by Vince Magistrado on 10/12/14.
//  Copyright (c) 2014 Vince Magistrado. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"
#import "AccountCell.h"

@protocol AccountsViewControllerDelegate <NSObject>

- (void)switchAccount:(User *)user;
- (void)addAccount;

@end

@interface AccountsViewController : UIViewController <AccountCellDelegate>

@property (nonatomic, weak) id <AccountsViewControllerDelegate> delegate;

- (void)updateAccounts;

@end
