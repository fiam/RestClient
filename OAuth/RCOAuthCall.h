//
//  RCOAuthCall.h
//  RestClient
//
//  Created by Alberto García Hierro on 20/05/10.
//  Copyright 2010 Alberto García Hierro. All rights reserved.
//

#import <RestClient/RCCall.h>

@class RCOAuthToken;

@interface RCOAuthCall : RCCall {
	RCOAuthToken *token_;
	BOOL ignoresToken_;
}

@property(nonatomic, retain) RCOAuthToken *token;
@property(nonatomic) BOOL ignoresToken;

@end
