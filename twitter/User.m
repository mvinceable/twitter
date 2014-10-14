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
        self.backgroundImageUrl = dictionary[@"profile_background_image_url"];
        self.tweetCount = [dictionary[@"statuses_count"] integerValue];
        self.friendCount = [dictionary[@"friends_count"] integerValue];
        self.followerCount = [dictionary[@"followers_count"] integerValue];
        self.bannerUrl = dictionary[@"profile_banner_url"];
    }
    
    return self;
}

static User *_currentUser = nil;

NSString * const kCurrentUserKey = @"kCurrentUserKey";
NSString * const kAccountsKey = @"kAccountsKey";
NSString * const kTokensKey = @"kTokensKey";

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
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    if (currentUser != nil) {
        NSData *data = [NSJSONSerialization dataWithJSONObject:currentUser.dictionary options:0 error:NULL];
        [userDefaults setObject:data forKey:kCurrentUserKey];
        
        // add to list of users if it doesn't already exist
        NSData *accountData = [userDefaults objectForKey:kAccountsKey];
        
        NSMutableDictionary *accountDictionary = [NSMutableDictionary dictionary];
        if (accountData != nil) {
            NSDictionary *accounts = [NSJSONSerialization JSONObjectWithData:accountData options:0 error:NULL];
            accountDictionary = [accounts mutableCopy];
        }
        accountDictionary[currentUser.screenname] = currentUser.dictionary;
        
        NSData *newAccountData = [NSJSONSerialization dataWithJSONObject:accountDictionary options:0 error:NULL];
        [userDefaults setObject:newAccountData forKey:kAccountsKey];
        
    } else {
        [self removeUser:_currentUser];
    }
    
    _currentUser = currentUser;
    
    [userDefaults synchronize];
}

+ (NSArray *)accounts {
    NSDictionary *storedAccounts = [self getStoredAccounts];
    NSMutableArray *accounts = [NSMutableArray array];
    NSArray *accountsRaw = [storedAccounts allValues];
    
    for (NSDictionary *dictionary in accountsRaw) {
        [accounts addObject:[[User alloc] initWithDictionary:dictionary]];
    }
    
    return accounts;
}

+ (void)removeUser:(User *)user{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    NSDictionary *storedAccounts = [self getStoredAccounts];
    NSMutableDictionary *newStoredAccounts = [storedAccounts mutableCopy];
    [newStoredAccounts removeObjectForKey:user.screenname];
    
    NSData *newAccountData = [NSJSONSerialization dataWithJSONObject:newStoredAccounts options:0 error:NULL];
    [userDefaults setObject:newAccountData forKey:kAccountsKey];
    
    // if user is current user, invalidate session
    if ([user.screenname isEqualToString:_currentUser.screenname]) {
        [userDefaults setObject:nil forKey:kCurrentUserKey];
    }
    
    [userDefaults synchronize];
}

+ (void)logout {
    [User setCurrentUser:nil];
    [[TwitterClient sharedInstance].requestSerializer removeAccessToken];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:UserDidLogoutNotification object:nil];
}

+ (NSDictionary *)getStoredAccounts {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *data;
    
    NSData *accountData = [userDefaults objectForKey:kAccountsKey];
    
    if (accountData != nil) {
        data = [NSJSONSerialization JSONObjectWithData:accountData options:0 error:NULL];
    } else {
        data = [NSDictionary dictionary];
    }

    return data;
}

+ (void)storeToken:(BDBOAuthToken *)token {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSData *data = [NSJSONSerialization dataWithJSONObject:token options:0 error:NULL];
    [userDefaults setObject:data forKey:kTokensKey];
}

@end
