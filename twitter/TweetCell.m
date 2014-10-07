//
//  TweetCell.m
//  twitter
//
//  Created by Vince Magistrado on 10/4/14.
//  Copyright (c) 2014 Vince Magistrado. All rights reserved.
//

#import "TweetCell.h"
#import "UIImageView+AFNetworking.h"
#import "TwitterClient.h"

@interface TweetCell()
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *screenNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *tweetLabel;
@property (weak, nonatomic) IBOutlet UILabel *timestampLabel;
@property (weak, nonatomic) IBOutlet UIButton *replyButton;
@property (weak, nonatomic) IBOutlet UIButton *retweetButton;
@property (weak, nonatomic) IBOutlet UIButton *favoriteButton;
@property (weak, nonatomic) IBOutlet UILabel *retweetCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *favoriteCountLabel;

@end

@implementation TweetCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setTweet:(Tweet *)tweet {
    _tweet = tweet;
    
    User *user = tweet.user;
    
    // rounded corners for profile images
    CALayer *layer = [self.profileImageView layer];
    [layer setMasksToBounds:YES];
    [layer setCornerRadius:3.0];
    [self.profileImageView setImageWithURL:[NSURL URLWithString:user.profileImageUrl]];
    
    self.nameLabel.text = user.name;
    self.screenNameLabel.text = [NSString stringWithFormat:@"@%@", user.screenname];
    self.tweetLabel.text = tweet.text;
    
    // show relative time since now if 24 hours or more has elapsed
    NSTimeInterval secondsSinceTweet = -[_tweet.createdAt timeIntervalSinceNow];
    
    if (secondsSinceTweet >= 86400) {
        // show month, day, and year
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"M/d/yy"];
        self.timestampLabel.text = [dateFormat stringFromDate:_tweet.createdAt];
    } else if (secondsSinceTweet >= 3600) {
        // show hours
        self.timestampLabel.text = [NSString stringWithFormat:@"%.0fh", secondsSinceTweet/3600];
    } else if (secondsSinceTweet >= 60){
        // show minutes
        self.timestampLabel.text = [NSString stringWithFormat:@"%.0fm", secondsSinceTweet/60];
    } else {
        // show seconds
        self.timestampLabel.text = [NSString stringWithFormat:@"%.0fs", secondsSinceTweet];
    }
    
    // disable if no id
    if (!tweet.idStr) {
        self.replyButton.enabled = self.retweetButton.enabled = self.favoriteButton.enabled = NO;
    } else {
        // disable retweet for self
        if ([tweet.user.screenname isEqualToString:[User currentUser].screenname]) {
            self.replyButton.enabled = self.favoriteButton.enabled = YES;
            self.retweetButton.enabled = NO;
        } else {
            self.replyButton.enabled = self.retweetButton.enabled = self.favoriteButton.enabled = YES;
        }
    }

    if (tweet.retweetCount > 0) {
        self.retweetCountLabel.text = [NSString stringWithFormat:@"%d", tweet.retweetCount];
    } else {
        self.retweetCountLabel.text = @"";
    }

    if (tweet.favoriteCount > 0) {
        self.favoriteCountLabel.text = [NSString stringWithFormat:@"%d", tweet.favoriteCount];
    } else {
        self.favoriteCountLabel.text = @"";
    }
        
    if (tweet.retweeted) {
        self.retweetCountLabel.textColor = [UIColor greenColor];
    }  else {
        self.retweetCountLabel.textColor = [UIColor blackColor];
    }
        
    if (tweet.favorited) {
        self.favoriteCountLabel.textColor = [UIColor orangeColor];
    } else {
        self.favoriteCountLabel.textColor = [UIColor blackColor];
    }
    
    [self.retweetButton setSelected:tweet.retweeted];
    [self.favoriteButton setSelected:tweet.favorited];
}

- (void)highlightButton:(UIButton *)button highlight:(BOOL)highlight {
    if (highlight) {
        [button setSelected:YES];
    } else {
        [button setSelected:NO];
    }
}

- (IBAction)onReply:(id)sender {
    [self.delegate onReply:self];
}

- (IBAction)onRetweet:(id)sender {
    BOOL retweeted = [_tweet retweet];
    if (retweeted) {
        self.retweetCountLabel.textColor = [UIColor greenColor];
    } else {
        self.retweetCountLabel.textColor = [UIColor blackColor];
    }
    if (_tweet.retweetCount > 0) {
        self.retweetCountLabel.text = [NSString stringWithFormat:@"%d", _tweet.retweetCount];
    } else {
        self.retweetCountLabel.text = @"";
    }
    [self highlightButton:self.retweetButton highlight:retweeted];
}

- (IBAction)onFavorite:(id)sender {
    BOOL favorited = [_tweet favorite];
    if (favorited) {
        self.favoriteCountLabel.textColor = [UIColor orangeColor];
    } else {
        self.favoriteCountLabel.textColor = [UIColor blackColor];
    }
    if (_tweet.favoriteCount > 0) {
        self.favoriteCountLabel.text = [NSString stringWithFormat:@"%d", _tweet.favoriteCount];
    } else {
        self.favoriteCountLabel.text = @"";
    }
    [self highlightButton:self.favoriteButton highlight:favorited];
}

@end
