//
//  TwitterClient.h
//  twitter
//
//  Created by Vince Magistrado on 10/4/14.
//  Copyright (c) 2014 Vince Magistrado. All rights reserved.
//

#import "BDBOAuth1RequestOperationManager.h"
#import "User.h"
#import "Tweet.h"

@interface TwitterClient : BDBOAuth1RequestOperationManager

+ (TwitterClient *)sharedInstance;

- (void)loginWithCompletion:(void (^)(User *user, NSError *error))completion;
- (void)loginForUser:(User *)user completion:(void (^)(User *user, NSError *error))completion;
- (void)openURL:(NSURL *)url;

- (void)userTimelineWithParams:(NSDictionary *)params user:(User *)user completion:(void (^)(NSArray *tweets, NSError *error))completion;
- (void)homeTimelineWithParams:(NSDictionary *)params completion:(void (^)(NSArray *tweets, NSError *error))completion;
- (void)mentionsTimelineWithParams:(NSDictionary *)params completion:(void (^)(NSArray *tweets, NSError *error))completion;
- (void)sendTweetWithParams:(NSDictionary *)params tweet:(Tweet *)tweet completion:(void (^)(NSString *tweetIdStr, NSError *error))completion;
- (void)retweetWithParams:(NSDictionary *)params tweet:(Tweet *)tweet completion:(void (^)(NSString *retweetIdStr, NSError *error))completion;
- (void)unretweetWithParams:(NSDictionary *)params tweet:(Tweet *)tweet completion:(void (^)(NSError *error))completion;
- (void)favoriteWithParams:(NSDictionary *)params tweet:(Tweet *)tweet completion:(void (^)(NSError *error))completion;
- (void)unfavoriteWithParams:(NSDictionary *)params tweet:(Tweet *)tweet completion:(void (^)(NSError *error))completion;

@end
