//
//  RCOAuthManager.m
//  RestClient
//
//  Created by Alberto García Hierro on 28/05/10.
//  Copyright 2010 Alberto García Hierro. All rights reserved.
//

#import "RCOAuthManager.h"

@implementation RCOAuthManager

@synthesize consumerKey = consumerKey_;
@synthesize consumerSecret = consumerSecret_;
@synthesize token = token_;

- (void)dealloc {
	[consumerKey_ release];
	[consumerSecret_ release];
	[token_ release];
	[super dealloc];
}

@end
