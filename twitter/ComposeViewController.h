//
//  ComposeViewController.h
//  twitter
//
//  Created by Vince Magistrado on 10/4/14.
//  Copyright (c) 2014 Vince Magistrado. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Tweet.h"

@protocol ComposeViewControllerDelegate <NSObject>

- (void)didTweet:(Tweet *)tweet;

@end

@interface ComposeViewController : UIViewController <UITextViewDelegate>

@property (nonatomic, strong) Tweet *replyToTweet;

@property (nonatomic, weak) id <ComposeViewControllerDelegate> delegate;

@end
