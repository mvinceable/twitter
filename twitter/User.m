//
//  User.m
//  twitter
//
//  Created by Vince Magistrado on 10/4/14.
//  Copyright (c) 2014 Vince Magistrado. All rights reserved.
//

#import "User.h"
#import "TwitterClient.h"

NSString * const UserDidLoginNotification = @"UserDidLoginNotification";
NSString * const UserDidLogoutNotification = @"UserDidLogoutNotification";

@interface User()

@property (nonatomic, strong) NSDictionary *dictionary;

@end

@implementation User

- (id) initWithDictionary:(NSDictionary *)dictionary  {
    self = [super init];
    if (self) {
        self.dictionary = dictionary;
        self.name = dictionary[@"name"];
        self.screenname = dictionary[@"screen_name"];
        self.profileImageUrl = dictionary[@"profile_image_url"];
        self.tagline = dictionary[@"description"];
    }
    
    return self;
}

static User *_currentUser = nil;

NSString * const kCurrentUserKey = @"kCurrentUserKey";

+ (User *)currentUser {
    if (_currentUser == nil) {
        NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:kCurrentUserKey];
        if (data != nil) {
            NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
            _currentUser = [[User alloc] initWithDictionary:dictionary];
        }
    }
    
    return _currentUser;
}

+ (void)setCurrentUser:(User *)currentUser {
    _currentUser = currentUser;
    
    if (_currentUser != nil) {
        NSData *data = [NSJSONSerialization dataWithJSONObject:currentUser.dictionary options:0 error:NULL];
        [[NSUserDefaults standardUserDefaults] setObject:data forKey:kCurrentUserKey];
    } else {
        [[NSUserDefaults standardUserDefaults] setObject:nil forKey:kCurrentUserKey];
    }
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void)logout {
    [User setCurrentUser:nil];
    [[TwitterClient sharedInstance].requestSerializer removeAccessToken];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:UserDidLogoutNotification object:nil];
}

@end
