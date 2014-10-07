//
//  TwitterClient.m
//  twitter
//
//  Created by Vince Magistrado on 10/4/14.
//  Copyright (c) 2014 Vince Magistrado. All rights reserved.
//

#import "TwitterClient.h"
#import "Tweet.h"

NSString * const kTwitterConsumerKey = @"BhATr89VMStKeBbfMKlgsr16c";
NSString * const kTwitterConsumerSecret = @"mA0Z1R4HN68nn3wn41WWjPpcYf39ZdLpTLtJHMXaMNSucXtsrk";
NSString * const kTwitterBaseUrl = @"https://api.twitter.com";

@interface TwitterClient()

@property (nonatomic, strong) void (^loginCompletion)(User *user, NSError *error);
@end

@implementation TwitterClient

+ (TwitterClient *)sharedInstance; {
    static TwitterClient *instance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (instance == nil) {
            instance = [[TwitterClient alloc] initWithBaseURL:[NSURL URLWithString:kTwitterBaseUrl] consumerKey:kTwitterConsumerKey consumerSecret:kTwitterConsumerSecret];
        }
    });
    
    return instance;
}

- (void)loginWithCompletion:(void (^)(User *user, NSError *error))completion {
    self.loginCompletion = completion;
    
    [self.requestSerializer removeAccessToken];
    [self fetchRequestTokenWithPath:@"oauth/request_token" method:@"GET" callbackURL:[NSURL URLWithString:@"cptwitterdemo://oauth"] scope:nil success:^(BDBOAuthToken *requestToken) {
        NSLog(@"got the request token!");
        
        NSURL *authURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.twitter.com/oauth/authorize?oauth_token=%@", requestToken.token]];
        [[UIApplication sharedApplication] openURL:authURL];
        
    } failure:^(NSError *error) {
        NSLog(@"Failed to get the request token!");
        self.loginCompletion(nil, error);
    }];
}

- (void)openURL:(NSURL *)url {
    [[TwitterClient sharedInstance] fetchAccessTokenWithPath:@"https://api.twitter.com/oauth/access_token" method:@"POST" requestToken:[BDBOAuthToken tokenWithQueryString:url.query] success:^(BDBOAuthToken *accessToken) {
        NSLog(@"got the access token!");
        [self.requestSerializer saveAccessToken:accessToken];
        
        [self GET:@"1.1/account/verify_credentials.json" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
//            NSLog(@"current user: %@", responseObject);
            User *user = [[User alloc] initWithDictionary:responseObject];
            [User setCurrentUser:user];
            NSLog(@"currentuser: %@", user.name);
            self.loginCompletion(user, nil);
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"failed getting current user");
            self.loginCompletion(nil, error);
        }];
    } failure:^(NSError *error) {
        NSLog(@"fialed to get the access token!");
        self.loginCompletion(nil, error);
    }];
}

- (void)homeTimelineWithParams:(NSDictionary *)params completion:(void (^)(NSArray *tweets, NSError *error))completion {
    [self GET:@"1.1/statuses/home_timeline.json?include_my_retweet=1" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSArray *tweets = [Tweet tweetsWithArray:responseObject];
        completion(tweets, nil);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        completion(nil, error);
    }];
}

- (void)sendTweetWithParams:(NSDictionary *)params tweet:(Tweet *)tweet completion:(void (^)(NSString *, NSError *))completion {
    NSString *postUrl;
    
    if (tweet.replyToIdStr) {
        postUrl = [NSString stringWithFormat:@"1.1/statuses/update.json?status=%@&in_reply_to_status_id=%@", tweet.text, tweet.replyToIdStr];
    } else {
        postUrl = [NSString stringWithFormat:@"1.1/statuses/update.json?status=%@", tweet.text];
    }
    
    [self POST:[postUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        NSLog([NSString stringWithFormat:@"succssfully tweeted: %@", responseObject]);
        completion(responseObject[@"id_str"], nil);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        completion(nil, error);
    }];
}

- (void)retweetWithParams:(NSDictionary *)params tweet:(Tweet *)tweet completion:(void (^)(NSString *, NSError *))completion {
    NSString *postUrl = [NSString stringWithFormat:@"1.1/statuses/retweet/%@.json", tweet.idStr];
    
    [self POST:[postUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        NSLog([NSString stringWithFormat:@"successfully retweeted: %@", responseObject]);
        completion(responseObject[@"id_str"], nil);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        completion(nil, error);
    }];
}

- (void)unretweetWithParams:(NSDictionary *)params tweet:(Tweet *)tweet completion:(void (^)(NSError *error))completion {
    NSString *postUrl = [NSString stringWithFormat:@"1.1/statuses/destroy/%@.json", tweet.retweetIdStr];
    
    [self POST:[postUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        NSLog([NSString stringWithFormat:@"successfully unretweeted: %@", responseObject]);
        completion(nil);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        completion(error);
    }];
}

- (void)favoriteWithParams:(NSDictionary *)params tweet:(Tweet *)tweet completion:(void (^)(NSError *error))completion {
    NSString *postUrl = [NSString stringWithFormat:@"1.1/favorites/create.json?id=%@", tweet.idStr];
    
    [self POST:[postUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        NSLog([NSString stringWithFormat:@"successfully favorited tweet: %@", responseObject]);
        completion(nil);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        completion(error);
    }];
}

- (void)unfavoriteWithParams:(NSDictionary *)params tweet:(Tweet *)tweet completion:(void (^)(NSError *error))completion {
    NSString *postUrl = [NSString stringWithFormat:@"1.1/favorites/destroy.json?id=%@", tweet.idStr];
    
    [self POST:[postUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        NSLog([NSString stringWithFormat:@"successfully unfavorited tweet: %@", responseObject]);
        completion(nil);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        completion(error);
    }];
}

@end
