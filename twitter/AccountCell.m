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
}

@end
