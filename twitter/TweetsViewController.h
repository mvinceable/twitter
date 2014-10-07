//
//  TweetsViewController.h
//  twitter
//
//  Created by Vince Magistrado on 10/4/14.
//  Copyright (c) 2014 Vince Magistrado. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ComposeViewController.h"
#import "TweetViewController.h"
#import "TweetCell.h"

@interface TweetsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, ComposeViewControllerDelegate, TweetViewControllerDelegate, TweetCellDelegate>

@end
