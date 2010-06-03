//
//  RCOAuthManager.h
//  Buzzie
//
//  Created by Alberto García Hierro on 28/05/10.
//  Copyright 2010 Alberto García Hierro. All rights reserved.
//

#import <RestClient/RCManager.h>

@class RCOAuthToken;

@interface RCOAuthManager : RCManager {
	NSString *consumerKey_;
	NSString *consumerSecret_;
	RCOAuthToken *token_;
}

@property(nonatomic, retain) NSString *consumerKey;
@property(nonatomic, retain) NSString *consumerSecret;
@property(nonatomic, retain) RCOAuthToken *token;

@end
