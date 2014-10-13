//
//  ProfileViewController.h
//  twitter
//
//  Created by Vince Magistrado on 10/11/14.
//  Copyright (c) 2014 Vince Magistrado. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ComposeViewController.h"
#import "TweetCell.h"
#import "TweetViewController.h"
#import "ProfileCell.h"

@protocol ProfileViewControllerDelegate <NSObject>

- (void)onPullForAccounts;

@end

@interface ProfileViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, ComposeViewControllerDelegate, TweetCellDelegate, TweetViewControllerDelegate, ProfileCellDelegate>

@property (strong, nonatomic) User *user;

@property (nonatomic, weak) id <ProfileViewControllerDelegate> delegate;

@end
