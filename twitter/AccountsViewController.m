//
//  AccountsViewController.m
//  twitter
//
//  Created by Vince Magistrado on 10/12/14.
//  Copyright (c) 2014 Vince Magistrado. All rights reserved.
//

#import "AccountsViewController.h"
#import "AccountCell.h"
#import "User.h"
#import "LoginViewController.h"

@interface AccountsViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) AccountCell *panningOnCell;

@end

@implementation AccountsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    // use twitter brand bg color
    self.view.backgroundColor = [UIColor colorWithRed:85/255.0f green:172/255.0f blue:238/255.0f alpha:1.0f];

    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.estimatedRowHeight = 150;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    // register account cell nib
    [self.tableView registerNib:[UINib nibWithNibName:@"AccountCell" bundle:nil] forCellReuseIdentifier:@"AccountCell"];
    
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // unhighlight selection
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row < [User accounts].count) {
        [self.delegate switchAccount:[User accounts][indexPath.row]];
    } else {
        [self.delegate addAccount];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [User accounts].count + 1;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // last cell will be add button
    if (indexPath.row < [User accounts].count) {
        AccountCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AccountCell"];
    
        // use twitter color https://about.twitter.com/press/brand-assets
        cell.backgroundColor = [UIColor colorWithRed:85/255.0f green:172/255.0f blue:238/255.0f alpha:1.0f];
        
        cell.user = [User accounts][indexPath.row];
        
        // so we can handle the user delete action on cell
        cell.delegate = self;
        
        return cell;
    } else {
        UITableViewCell *cell = [[UITableViewCell alloc] init];
        
        cell.backgroundColor = [UIColor darkGrayColor];
        cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:64];
        cell.textLabel.text = @"+";
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        
        return cell;
    }
}

- (void)updateAccounts {
    [self.tableView reloadData];
}

- (IBAction)onPan:(UIPanGestureRecognizer *)sender {
    CGPoint location = [sender locationInView:self.view];
    CGPoint translation = [sender translationInView:self.view];
    CGPoint velocity = [sender velocityInView:self.view];
    
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:location];
    
    // don't process the "add account" cell
    if (indexPath && indexPath.row < [User accounts].count) {
        // store the cell we started panning on so it doesn't change at any point afterward unless we're done panning
        if (sender.state == UIGestureRecognizerStateBegan) {
            self.panningOnCell = (AccountCell *)[self.tableView cellForRowAtIndexPath:indexPath];
        }
        // simply relay the event to the cell that we're panning on
        [self.panningOnCell onPan:sender location:location translation:translation velocity:velocity];
    }
    
    // outside the if block so if pan ends on "add account" button, it's still routed to panned cell
    if (sender.state == UIGestureRecognizerStateEnded) {
        [self.panningOnCell onPan:sender location:location translation:translation velocity:velocity];
    }
}

- (void)onUserDelete:(User *)user {
    [User removeUser:user];
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
    // if there are no more accounts, show the main login screen
    if ([User accounts].count == 0) {
        [[NSNotificationCenter defaultCenter] postNotificationName:UserDidLogoutNotification object:nil];
    }
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
