//
//  MenuViewController.h
//  twitter
//
//  Created by Vince Magistrado on 10/11/14.
//  Copyright (c) 2014 Vince Magistrado. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProfileViewController.h"
#import "AccountsViewController.h"

@interface MenuViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, ProfileViewControllerDelegate, AccountsViewControllerDelegate>

@end
