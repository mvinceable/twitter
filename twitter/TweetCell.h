//
//  TweetCell.h
//  twitter
//
//  Created by Vince Magistrado on 10/4/14.
//  Copyright (c) 2014 Vince Magistrado. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Tweet.h"

@class TweetCell;

@protocol TweetCellDelegate <NSObject>

- (void)onReply:(TweetCell *)tweetCell;
- (void)onRetweet:(TweetCell *)tweetCell;

@end

@interface TweetCell : UITableViewCell

@property (nonatomic, strong) Tweet *tweet;

@property (nonatomic, weak) id <TweetCellDelegate> delegate;


@end