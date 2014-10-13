//
//  ProfileCell.m
//  twitter
//
//  Created by Vince Magistrado on 10/11/14.
//  Copyright (c) 2014 Vince Magistrado. All rights reserved.
//

#import "ProfileCell.h"
#import "User.h"
#import "UIImageView+AFNetworking.h"

@interface ProfileCell()
@property (weak, nonatomic) IBOutlet UIImageView *profileView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *screenNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *tweetCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *followingCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *followerCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *taglineLabel;
@property (weak, nonatomic) IBOutlet UIPageControl *profilePageControl;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *namePageLeftConstraint;

@end

@implementation ProfileCell

- (void)awakeFromNib {
    // Initialization code
    
    // disable selection on cell
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setUser:(User *)user {
    // rounded corners and border for profile images
    CALayer *layer = [self.profileView layer];
    [layer setCornerRadius:6.0];
    [layer setBorderColor:[[UIColor whiteColor] CGColor]];
    [layer setBorderWidth:3.0];
    [layer setMasksToBounds:YES];
    
    [self.profileView setImageWithURL:[NSURL URLWithString:user.profileImageUrl]];
    
    self.nameLabel.text = user.name;
    self.screenNameLabel.text = [NSString stringWithFormat:@"@%@", user.screenname];
    self.taglineLabel.text = user.tagline;
    
    // fixes the line wrapping issue with auto layout
    self.taglineLabel.preferredMaxLayoutWidth = self.taglineLabel.bounds.size.width;
    
    // use friendly numbers like twitter
    self.tweetCountLabel.text = [self getFriendlyCount:user.tweetCount];
    self.followingCountLabel.text = [self getFriendlyCount:user.friendCount];
    self.followerCountLabel.text = [self getFriendlyCount:user.followerCount];
    
    // hide page control if no tagline
    if (!user.tagline || [user.tagline isEqualToString:@""]) {
        [self.profilePageControl setHidden:YES];
    } else {
        [self.profilePageControl setHidden:NO];
    }
}

- (NSString *) getFriendlyCount:(NSInteger)count {
    if (count >= 1000000) {
        return [NSString stringWithFormat:@"%.1fM", (double)count / 1000000];
    } else if (count >= 10000) {
        return [NSString stringWithFormat:@"%.1fK", (double)count / 1000];
    } else if (count >= 1000) {
        return [NSString stringWithFormat:@"%ld,%ld", (long)count / 1000, (long)count % 1000];
    } else {
        return [NSString stringWithFormat:@"%ld", (long)count];
    }
}

- (IBAction)onPageControlValueChanged:(UIPageControl *)sender {
    if (sender.currentPage == 0) {
        [UIView animateWithDuration:.24 animations:^{
            self.namePageLeftConstraint.constant = 0;
            [self layoutIfNeeded];
        }];
    } else {
        [UIView animateWithDuration:.24 animations:^{
            self.namePageLeftConstraint.constant = -self.nameLabel.bounds.size.width - 32;
            [self layoutIfNeeded];
        }];
    }
    [self.delegate pageChanged:sender];
}

@end
