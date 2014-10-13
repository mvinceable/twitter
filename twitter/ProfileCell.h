//
//  ProfileCell.h
//  twitter
//
//  Created by Vince Magistrado on 10/11/14.
//  Copyright (c) 2014 Vince Magistrado. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"

@protocol ProfileCellDelegate <NSObject>

- (void)pageChanged:(UIPageControl *)pageControl;

@end;

@interface ProfileCell : UITableViewCell

@property (strong, nonatomic) User *user;

@property (nonatomic, weak) id <ProfileCellDelegate> delegate;

@end
