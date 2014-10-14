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
@property (weak, nonatomic) IBOutlet UIImageView *retweetView;
@property (weak, nonatomic) IBOutlet UILabel *retweetedByLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topProfileImageConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topNameConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topScreenNameConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topTimestampConstraint;

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
    Tweet *tweetToDisplay;
    
    if (tweet.retweetedTweet) {
        tweetToDisplay = tweet.retweetedTweet;
        self.retweetedByLabel.text = [NSString stringWithFormat:@"%@ retweeted", user.name];
        [self.retweetView setHidden:NO];
        [self.retweetedByLabel setHidden:NO];
        // update constraints dynamically
        self.topProfileImageConstraint.constant = 32;
        self.topNameConstraint.constant = 32;
        self.topScreenNameConstraint.constant = 33;
        self.topTimestampConstraint.constant = 32;
    } else {
        tweetToDisplay = tweet;
        [self.retweetView setHidden:YES];
        [self.retweetedByLabel setHidden:YES];
        // update constraints dynamically
        self.topProfileImageConstraint.constant = 16;
        self.topNameConstraint.constant = 16;
        self.topScreenNameConstraint.constant = 17;
        self.topTimestampConstraint.constant = 16;
    }
    
    // rounded corners for profile images
    CALayer *layer = [self.profileImageView layer];
    [layer setMasksToBounds:YES];
    [layer setCornerRadius:3.0];
    [self.profileImageView setImageWithURL:[NSURL URLWithString:tweetToDisplay.user.profileImageUrl]];
    
    self.nameLabel.text = tweetToDisplay.user.name;
    self.screenNameLabel.text = [NSString stringWithFormat:@"@%@", tweetToDisplay.user.screenname];
    self.tweetLabel.text = tweetToDisplay.text;
    
    // show relative time since now if 24 hours or more has elapsed
    NSTimeInterval secondsSinceTweet = -[tweetToDisplay.createdAt timeIntervalSinceNow];
    
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
        // disable retweet for self and not retweet
        if (!tweet.retweetedTweet && [user.screenname isEqualToString:[User currentUser].screenname]) {
            self.replyButton.enabled = self.favoriteButton.enabled = YES;
            self.retweetButton.enabled = NO;
        } else {
            self.replyButton.enabled = self.retweetButton.enabled = self.favoriteButton.enabled = YES;
        }
    }

    if (tweet.retweetCount > 0) {
        self.retweetCountLabel.text = [NSString stringWithFormat:@"%ld", (long)tweet.retweetCount];
    } else {
        self.retweetCountLabel.text = @"";
    }

    if (tweetToDisplay.favoriteCount > 0) {
        self.favoriteCountLabel.text = [NSString stringWithFormat:@"%ld", (long)tweetToDisplay.favoriteCount];
    } else {
        self.favoriteCountLabel.text = @"";
    }
        
    if (tweet.retweeted) {
        self.retweetCountLabel.textColor = [UIColor greenColor];
    }  else {
        self.retweetCountLabel.textColor = [UIColor grayColor];
    }
        
    if (tweet.favorited) {
        self.favoriteCountLabel.textColor = [UIColor orangeColor];
    } else {
        self.favoriteCountLabel.textColor = [UIColor grayColor];
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
        self.retweetCountLabel.textColor = [UIColor grayColor];
    }
    if (_tweet.retweetCount > 0) {
        self.retweetCountLabel.text = [NSString stringWithFormat:@"%ld", (long)_tweet.retweetCount];
    } else {
        self.retweetCountLabel.text = @"";
    }
    [self highlightButton:self.retweetButton highlight:retweeted];
}

- (IBAction)onFavorite:(id)sender {
    Tweet *tweetToFavorite;
    if (_tweet.retweetedTweet) {
        tweetToFavorite = _tweet.retweetedTweet;
    } else {
        tweetToFavorite = _tweet;
    }
    
    BOOL favorited = [tweetToFavorite favorite];
    
    // favorite/unfavorite the source
    if (_tweet.retweetedTweet) {
        _tweet.favorited = favorited;
    }
    
    if (favorited) {
        self.favoriteCountLabel.textColor = [UIColor orangeColor];
    } else {
        self.favoriteCountLabel.textColor = [UIColor grayColor];
    }
    if (tweetToFavorite.favoriteCount > 0) {
        self.favoriteCountLabel.text = [NSString stringWithFormat:@"%ld", (long)tweetToFavorite.favoriteCount];
    } else {
        self.favoriteCountLabel.text = @"";
    }
    [self highlightButton:self.favoriteButton highlight:favorited];
}

- (IBAction)onProfile:(id)sender {
    NSLog(@"Profile tapped");
    if (_tweet.retweetedTweet) {
        [self.delegate onProfile:_tweet.retweetedTweet.user];
    } else {
        [self.delegate onProfile:_tweet.user];
    }
}
@end
