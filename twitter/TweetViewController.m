//
//  TweetViewController.m
//  twitter
//
//  Created by Vince Magistrado on 10/4/14.
//  Copyright (c) 2014 Vince Magistrado. All rights reserved.
//

#import "TweetViewController.h"
#import "UIImageView+AFNetworking.h"
#import "ComposeViewController.h"
#import "TwitterClient.h"

@interface TweetViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *screenNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *tweetLabel;
@property (weak, nonatomic) IBOutlet UILabel *timestampLabel;
@property (weak, nonatomic) IBOutlet UILabel *retweetCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *favoriteCountLabel;
@property (weak, nonatomic) IBOutlet UIButton *replyButton;
@property (weak, nonatomic) IBOutlet UIButton *retweetButton;
@property (weak, nonatomic) IBOutlet UIButton *favoriteButton;

@end

@implementation TweetViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    // set title
    self.navigationItem.title = @"Tweet";
    
    // add Reply button
    UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc] initWithTitle:@"Reply" style:UIBarButtonItemStylePlain target:self action:@selector(onReply)];
    self.navigationItem.rightBarButtonItem = rightBarButton;
    
    if (_tweet) {
        User *user = _tweet.user;
        
        // rounded corners for profile images
        CALayer *layer = [self.profileImageView layer];
        [layer setMasksToBounds:YES];
        [layer setCornerRadius:3.0];
        [self.profileImageView setImageWithURL:[NSURL URLWithString:user.profileImageUrl]];

        self.nameLabel.text = user.name;
        self.screenNameLabel.text = [NSString stringWithFormat:@"@%@", user.screenname];
        self.tweetLabel.text = _tweet.text;
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"M/d/yy, h:mm a"];
        self.timestampLabel.text = [dateFormat stringFromDate:_tweet.createdAt];
        self.retweetCountLabel.text = [NSString stringWithFormat:@"%ld", (long)_tweet.retweetCount];
        self.favoriteCountLabel.text = [NSString stringWithFormat:@"%ld", (long)_tweet.favoriteCount];
        
        // set action button highlight states
        [self highlightButton:self.retweetButton highlight:_tweet.retweeted];
        [self highlightButton:self.favoriteButton highlight:_tweet.favorited];
        
        // if this tweet has no id, then disable all actions
        if (!_tweet.idStr) {
            rightBarButton.enabled = NO;
            self.retweetButton.enabled = NO;
            self.replyButton.enabled = NO;
            self.favoriteButton.enabled = NO;
        }
        
        // if this is the user's own tweet, disable retweet
        if ([[[User currentUser] screenname] isEqualToString:user.screenname]) {
            self.retweetButton.enabled = NO;
        }
    }}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)onReply {
    ComposeViewController *vc = [[ComposeViewController alloc] init];
    vc.delegate = self;
    UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:vc];
    nvc.navigationBar.translucent = NO;
    // set reply to tweet property
    vc.replyToTweet = _tweet;
    [self.navigationController presentViewController:nvc animated:YES completion:nil];    
}

- (void)setTweet:(Tweet *)tweet {
    _tweet = tweet;
}

- (IBAction)onReply:(id)sender {
    [self onReply];
}

- (IBAction)onRetweet:(id)sender {
    [_tweet retweet];
    self.retweetCountLabel.text = [NSString stringWithFormat:@"%ld", _tweet.retweetCount];
    [self highlightButton:self.retweetButton highlight:_tweet.retweeted];
    [self.delegate didRetweet:_tweet.retweeted];
}

- (IBAction)onFavorite:(id)sender {
    [_tweet favorite];
    self.favoriteCountLabel.text = [NSString stringWithFormat:@"%ld", _tweet.favoriteCount];
    [self highlightButton:self.favoriteButton highlight:_tweet.favorited];
    [self.delegate didFavorite:_tweet.favorited];
}

- (void)highlightButton:(UIButton *)button highlight:(BOOL)highlight {
    if (highlight) {
        [button setSelected:YES];
    } else {
        [button setSelected:NO];
    }
}

- (void) didTweet:(Tweet *)tweet {
    [self.delegate didReply:tweet];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
