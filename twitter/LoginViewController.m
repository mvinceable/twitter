//
//  LoginViewController.m
//  twitter
//
//  Created by Vince Magistrado on 10/4/14.
//  Copyright (c) 2014 Vince Magistrado. All rights reserved.
//

#import "LoginViewController.h"
#import "TwitterClient.h"
#import "TweetsViewController.h"
#import "MenuViewController.h"

@interface LoginViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *twitterLogoView;

@end

@implementation LoginViewController
- (IBAction)onLogin:(id)sender {
    // animate the logo
    [UIView animateWithDuration:.24 animations:^{
        self.twitterLogoView.transform = CGAffineTransformMakeScale(24, 24);
        self.view.backgroundColor = [UIColor whiteColor];
    }];
    [[TwitterClient sharedInstance] loginWithCompletion:^(User *user, NSError *error) {
        // bring the logo back
        self.twitterLogoView.transform = CGAffineTransformMakeScale(1, 1);
        self.view.backgroundColor = [UIColor colorWithRed:85/255.0f green:172/255.0f blue:238/255.0f alpha:1.0f];

        if (user != nil) {
            // Modally present tweets view
            NSLog(@"Welcome to %@", user.name);
            MenuViewController *vc = [[MenuViewController alloc] init];
            [self presentViewController:vc animated:YES completion:nil];
        } else {
            // Present error view
            NSLog(@"Login error");
        }
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.twitterLogoView.transform = CGAffineTransformMakeScale(1, 1);
    
    // use twitter brand bg color
    self.view.backgroundColor = [UIColor colorWithRed:85/255.0f green:172/255.0f blue:238/255.0f alpha:1.0f];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
