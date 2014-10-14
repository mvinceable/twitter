//
//  MentionsViewController.m
//  twitter
//
//  Created by Vince Magistrado on 10/11/14.
//  Copyright (c) 2014 Vince Magistrado. All rights reserved.
//

#import "MentionsViewController.h"
#import "ComposeViewController.h"
#import "MBProgressHUD.h"
#import "TwitterClient.h"
#import "TweetCell.h"
#import "TweetViewController.h"
#import "ProfileViewController.h"

@interface MentionsViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSArray *tweets;
@property (strong, nonatomic) UIRefreshControl *refreshTweetsControl;
@property (strong, nonatomic) MBProgressHUD *loadingIndicator;

@end

@implementation MentionsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    // add Sign Out button
    UIBarButtonItem *leftBarButton = [[UIBarButtonItem alloc] initWithTitle:@"Sign Out" style:UIBarButtonItemStylePlain target:self action:@selector(onLogout)];
    self.navigationItem.leftBarButtonItem = leftBarButton;
    
    // set title
    self.navigationItem.title = @"Mentions";
    
    // add New button icon
    UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(onNew)];
    self.navigationItem.rightBarButtonItem = rightBarButton;
    
    // register tweet cell nib
    [self.tableView registerNib:[UINib nibWithNibName:@"TweetCell" bundle:nil] forCellReuseIdentifier:@"TweetCell"];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.estimatedRowHeight = 105;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    // add pull to refresh tweets control
    self.refreshTweetsControl = [[UIRefreshControl alloc] init];
    [self.tableView addSubview:self.refreshTweetsControl];
    [self.refreshTweetsControl addTarget:self action:@selector(refreshMentions) forControlEvents:UIControlEventValueChanged];
    
    // show loading indicator
    self.loadingIndicator = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [self refreshMentions];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // unhighlight selection
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    TweetViewController *vc = [[TweetViewController alloc] init];
    vc.delegate = self;
    vc.tweet = self.tweets[indexPath.row];
    [self.navigationController pushViewController:vc animated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.tweets.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    TweetCell *tweetCell = [tableView dequeueReusableCellWithIdentifier:@"TweetCell"];
    tweetCell.tweet = self.tweets[indexPath.row];
    tweetCell.delegate = self;
        
    // if data for the last cell is requested, then obtain more data
    if (indexPath.row == self.tweets.count - 1) {
        NSLog(@"End of list reached...");
        [self getMoreTweets];
    }
        
    return tweetCell;
}

- (void)didTweet:(Tweet *)tweet {
    // process the tweet if it mentions logged in user, and then show it
    NSString *mentionPattern = [NSString stringWithFormat:@"@%@", [[User currentUser] screenname]];
    if ([tweet.text rangeOfString:mentionPattern].location != NSNotFound) {
        NSLog(@"tweet mentioned self, so adding it to list");
        NSMutableArray *temp = [NSMutableArray arrayWithArray:self.tweets];
        [temp insertObject:tweet atIndex:0];
        self.tweets = [temp copy];
        [self.tableView reloadData];
    }
}

- (void)didTweetSuccessfully {
    // so a newly generated tweet can be replied or favorited
    [self.tableView reloadData];
}

- (void)refreshMentions {
    [[TwitterClient sharedInstance] mentionsTimelineWithParams:nil completion:^(NSArray *tweets, NSError *error) {
        if (error) {
            NSLog([NSString stringWithFormat:@"Error getting mentions timeline, too many requests?: %@", error]);
        } else {
            self.tweets = tweets;
            [self.tableView reloadData];
        }
        [self.loadingIndicator hide:YES];
        [self.refreshTweetsControl endRefreshing];
        [self.tableView setHidden:NO];
    }];
}

- (void)onLogout {
    [User logout];
}

- (void)onNew {
    ComposeViewController *vc = [[ComposeViewController alloc] init];
    if (self.user && ![self.user.screenname isEqualToString:[[User currentUser] screenname]]) {
        vc.messageToUser = self.user;
    }
    UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:vc];
    nvc.navigationBar.translucent = NO;
    [self.navigationController presentViewController:nvc animated:YES completion:nil];
}

- (void)didReply:(Tweet *)tweet {
    [self didTweet:tweet];
}

- (void)didRetweet:(BOOL)didRetweet {
    [self.tableView reloadData];
}

- (void)didFavorite:(BOOL)didFavorite {
    [self.tableView reloadData];
}

- (void) getMoreTweets {
    // if no previous max id str available, then don't do anything
    NSString *maxIdStr = [self.tweets[self.tweets.count - 1] idStr];
    if (!maxIdStr) {
        return;
    }
    [[TwitterClient sharedInstance] mentionsTimelineWithParams:@{ @"max_id": maxIdStr} completion:^(NSArray *tweets, NSError *error) {
        // reload only if there is more data
        if (error) {
            NSLog([NSString stringWithFormat:@"Error getting more tweets, too many requests?: %@", error]);
        } else if (tweets.count > 0) {
            // ignore duplicate requests
            if ([[tweets[tweets.count - 1] idStr] isEqualToString:[self.tweets[self.tweets.count - 1] idStr]]) {
                NSLog(@"Ignoring duplicate data");
            } else {
                NSLog([NSString stringWithFormat:@"Got %lu more tweets", (unsigned long)tweets.count]);
                NSMutableArray *temp = [NSMutableArray arrayWithArray:self.tweets];
                [temp addObjectsFromArray:tweets];
                self.tweets = [temp copy];
                [self.tableView reloadData];
            }
        } else {
            NSLog(@"No more tweets retrieved");
        }
    }];
}

- (void)onReply:(TweetCell *)tweetCell {
    ComposeViewController *vc = [[ComposeViewController alloc] init];
    vc.delegate = self;
    UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:vc];
    nvc.navigationBar.translucent = NO;
    // set reply to tweet property
    vc.replyToTweet = tweetCell.tweet;
    [self.navigationController presentViewController:nvc animated:YES completion:nil];
}

- (void)onProfile:(User *)user {
    ProfileViewController *pvc = [[ProfileViewController alloc] init];
    [pvc setUser:user];
    [self.navigationController pushViewController:pvc animated:YES];
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
