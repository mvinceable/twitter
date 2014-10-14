//
//  AccountCell.m
//  twitter
//
//  Created by Vince Magistrado on 10/12/14.
//  Copyright (c) 2014 Vince Magistrado. All rights reserved.
//

#import "AccountCell.h"
#import "UIImageView+AFNetworking.h"

@interface AccountCell()
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *screenNameLabel;
@property (weak, nonatomic) IBOutlet UIView *contentContainer;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentXConstraint;

@property (assign, nonatomic) CGFloat panReferenceX;

@end

@implementation AccountCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setUser:(User *)user {
    // rounded corners and border for profile images
    CALayer *layer = [self.profileImageView layer];
    [layer setCornerRadius:6.0];
    [layer setBorderColor:[[UIColor whiteColor] CGColor]];
    [layer setBorderWidth:3.0];
    [layer setMasksToBounds:YES];
    
    [self.profileImageView setImageWithURL:[NSURL URLWithString:user.profileImageUrl]];
    
    self.nameLabel.text = user.name;
    self.screenNameLabel.text = [NSString stringWithFormat:@"@%@", user.screenname];
    
    _user = user;
    
    // reset layout
    self.contentXConstraint.constant = 0;
    self.contentContainer.alpha = 1;
    self.contentContainer.transform = CGAffineTransformMakeScale(1, 1);
}

- (void)onPan:(UIGestureRecognizer *)sender location:(CGPoint)location translation:(CGPoint)translation velocity:(CGPoint)velocity {

    if (sender.state == UIGestureRecognizerStateBegan) {
        self.panReferenceX = self.contentXConstraint.constant;
    } else if (sender.state == UIGestureRecognizerStateChanged) {
        // move, lighten, spin, and shrink as you pan
        self.contentXConstraint.constant = self.panReferenceX - translation.x;
        self.contentContainer.alpha = 1 - (translation.x / 200);
        self.contentContainer.transform = CGAffineTransformMakeScale(1 - (translation.x / 700), 1 - (translation.x / 700));
    } else if (sender.state == UIGestureRecognizerStateEnded) {
        // only delete if velocity is more than 200 and translation is more than 100
        if (velocity.x >= 300 && translation.x >= 100) {
            NSLog(@"Delete account via pan");
            [self.delegate onUserDelete:self.user];
        } else {
            // animate back to original
            [UIView animateWithDuration:.24 animations:^{
                self.contentXConstraint.constant = 0;
                self.contentContainer.alpha = 1;
                self.contentContainer.transform = CGAffineTransformMakeScale(1, 1);
                [self layoutIfNeeded];
            }];
        }
    }
}


@end
