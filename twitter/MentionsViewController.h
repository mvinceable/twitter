//
//  MentionsViewController.h
//  twitter
//
//  Created by Vince Magistrado on 10/11/14.
//  Copyright (c) 2014 Vince Magistrado. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ComposeViewController.h"
#import "TweetViewController.h"
#import "TweetCell.h"

@interface MentionsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, ComposeViewControllerDelegate, TweetViewControllerDelegate, TweetCellDelegate>

@property (strong, nonatomic) User *user;

@end
