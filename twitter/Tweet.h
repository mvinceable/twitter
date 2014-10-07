//
//  Tweet.h
//  twitter
//
//  Created by Vince Magistrado on 10/4/14.
//  Copyright (c) 2014 Vince Magistrado. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"

@interface Tweet : NSObject

@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) NSDate *createdAt;
@property (nonatomic, strong) User *user;
@property (nonatomic) NSInteger retweetCount;
@property (nonatomic) NSInteger favoriteCount;
@property (nonatomic) BOOL retweeted;
@property (nonatomic) BOOL favorited;
@property (nonatomic, strong) NSString *idStr;
@property (nonatomic, strong) NSString *replyToIdStr;
@property (nonatomic, strong) NSString *retweetIdStr;

- (id) initWithDictionary:(NSDictionary *)dictionary;
- (BOOL) retweet;
- (BOOL) favorite;

+ (NSArray *)tweetsWithArray:(NSArray *)array;

@end
