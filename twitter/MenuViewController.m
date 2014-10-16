//
//  MenuViewController.m
//  twitter
//
//  Created by Vince Magistrado on 10/11/14.
//  Copyright (c) 2014 Vince Magistrado. All rights reserved.
//

#import "MenuViewController.h"
#import "ProfileViewController.h"
#import "TweetsViewController.h"
#import "MentionsViewController.h"
#import "AccountsViewController.h"
#import "TwitterClient.h"

@interface MenuViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIView *accountsView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentViewXConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentViewYConstraint;

@property (strong, nonatomic) NSArray *viewControllers;
@property (strong, nonatomic) UIViewController *currentVC;
@property (strong, nonatomic) AccountsViewController *avc;

@end

@implementation MenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    // set bg color
    self.view.backgroundColor = [UIColor colorWithRed:85/255.0f green:172/255.0f blue:238/255.0f alpha:1.0f];
    
    // reset constraint
    self.contentViewXConstraint.constant = 0;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    [self initViewControllers];
    [self.tableView reloadData];
}

- (void)initViewControllers {
    
    // Profile View
    ProfileViewController *pvc = [[ProfileViewController alloc] init];
    UINavigationController *pnvc = [[UINavigationController alloc] initWithRootViewController:pvc];
    pnvc.navigationBar.barTintColor = [UIColor colorWithRed:85/255.0f green:172/255.0f blue:238/255.0f alpha:1.0f];
    pnvc.navigationBar.tintColor = [UIColor whiteColor];
    [pnvc.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    pnvc.navigationBar.translucent = NO;
    // set self as delage for pull downs
    pvc.delegate = self;
    
    // Timeline
    TweetsViewController *tvc = [[TweetsViewController alloc] init];
    UINavigationController *tnvc = [[UINavigationController alloc] initWithRootViewController:tvc];
    tnvc.navigationBar.barTintColor = [UIColor colorWithRed:85/255.0f green:172/255.0f blue:238/255.0f alpha:1.0f];
    tnvc.navigationBar.tintColor = [UIColor whiteColor];
    [tnvc.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    tnvc.navigationBar.translucent = NO;
    
    // Mentions
    MentionsViewController *mvc = [[MentionsViewController alloc] init];
    UINavigationController *mnvc = [[UINavigationController alloc] initWithRootViewController:mvc];
    mnvc.navigationBar.barTintColor = [UIColor colorWithRed:85/255.0f green:172/255.0f blue:238/255.0f alpha:1.0f];
    mnvc.navigationBar.tintColor = [UIColor whiteColor];
    [mnvc.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    mnvc.navigationBar.translucent = NO;
    
    self.viewControllers = [NSArray arrayWithObjects:pnvc, tnvc, mnvc, nil];
    
    // set profile as initial view
    self.currentVC = pnvc;
    self.currentVC.view.frame = self.contentView.bounds;
    [self.contentView addSubview:self.currentVC.view];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row < 3) {
        // add new
        [self removeCurrentViewController];
        self.currentVC = self.viewControllers[indexPath.row];
        [self setContentController];
    } else {
        [self showAccountViewController];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 4;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.tableView.bounds.size.height / 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    switch (indexPath.row) {
        case 0:
            cell.textLabel.text = @"Profile";
            break;
        case 1:
            cell.textLabel.text = @"Timeline";
            break;
        case 2:
            cell.textLabel.text = @"Mentions";
            break;
        case 3:
            cell.textLabel.text = @"Accounts";
            break;
    }
    
    cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:21];
    cell.textLabel.textColor = [UIColor whiteColor];
    // use twitter color https://about.twitter.com/press/brand-assets
    cell.backgroundColor = [UIColor colorWithRed:85/255.0f green:172/255.0f blue:238/255.0f alpha:1.0f];
    
    return cell;
}

- (IBAction)didSwipeRight:(id)sender {
    NSLog(@"Swipe right detected");
    // reload data to handle height change since row heights are based on table height
    [self.tableView reloadData];
    [UIView animateWithDuration:.24 animations:^{
        self.contentViewXConstraint.constant = -200;
        [self.view layoutIfNeeded];
    }];
}

- (IBAction)didSwipeLeft:(id)sender {
    NSLog(@"Swipe left detected");
    [UIView animateWithDuration:.24 animations:^{
        self.contentViewXConstraint.constant = 0;
        [self.view layoutIfNeeded];
    }];
}

- (void)onPullForAccounts {
    [self showAccountViewController];
}

- (void)setAccount {
    NSLog(@"Set account");
    
    // remove old
    [self removeCurrentViewController];
    
    // reinit view controllers
    [self initViewControllers];
    
    [self.currentVC didMoveToParentViewController:self];
    
    [UIView animateWithDuration:.24 animations:^{
        self.contentViewXConstraint.constant = 0;
        self.contentViewYConstraint.constant = 0;
        [self.view layoutIfNeeded];
    }];
}

- (void)switchAccount:(User *)user {
    // if account is the same, then just return
    if ([user.screenname isEqualToString:User.currentUser.screenname]) {
        [self showProfileViewController];
        return;
    }
    
    NSLog(@"Switch account");
    [[TwitterClient sharedInstance] loginForUser:user completion:^(User *user, NSError *error) {
        if (user != nil) {
            [self removeCurrentViewController];
            User.currentUser = user;
            [self setAccount];
        } else {
            // Present error view
            NSLog(@"Login error");
        }
    }];
}

- (void)addAccount {
    NSLog(@"Add account");
    
    [[TwitterClient sharedInstance] loginWithCompletion:^(User *user, NSError *error) {
        if (user != nil) {
            [self.avc updateAccounts];
            [self removeCurrentViewController];
            User.currentUser = user;
            [self setAccount];
        } else {
            // Present error view
            NSLog(@"Login error");
        }
    }];
}

- (void)removeCurrentViewController {
//    [self.currentVC willMoveToParentViewController:nil];
//    [self.currentVC.view removeFromSuperview];
//    [self.currentVC removeFromParentViewController];
}

- (void)setContentController {
    self.currentVC.view.frame = self.contentView.bounds;
    [self.contentView addSubview:self.currentVC.view];
    [self.currentVC didMoveToParentViewController:self];
    
    [UIView animateWithDuration:.24 animations:^{
        self.contentViewXConstraint.constant = 0;
        self.contentViewYConstraint.constant = 0;
        [self.view layoutIfNeeded];
    }];
}

- (void)setAccountController {
    self.currentVC.view.frame = self.accountsView.bounds;
    [self.accountsView addSubview:self.currentVC.view];
    [self.currentVC didMoveToParentViewController:self];
    
    [UIView animateWithDuration:.24 animations:^{
        self.contentViewXConstraint.constant = 0;
        self.contentViewYConstraint.constant = -self.contentView.bounds.size.height;
        [self.view layoutIfNeeded];
    }];
}

- (void)showAccountViewController {
    [self removeCurrentViewController];
    if (!self.avc) {
        self.avc = [[AccountsViewController alloc] init];
        self.avc.delegate = self;
    } else {
        [self.avc updateAccounts];
    }
    self.currentVC = self.avc;
    [self setAccountController];
}

- (void)showProfileViewController {
    [self removeCurrentViewController];
    self.currentVC = self.viewControllers[0];
    [self setContentController];
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
