//
//  RCOAuthToken.m
//  Buzzie
//
//  Created by Alberto García Hierro on 28/05/10.
//  Copyright 2010 Alberto García Hierro. All rights reserved.
//

#import "RCOAuthToken.h"

NSString * const kOAuthTokenParameterName = @"oauth_token";
NSString * const kOAuthTokenSecretParameterName = @"oauth_token_secret";
NSString * const kOAuthVerifierParameterName = @"oauth_verifier";

static NSString *kOAuthTokenKeyCoderKey = @"key";
static NSString *kOAuthTokenSecretCoderKey = @"secret";

@implementation RCOAuthToken

@synthesize key = key_;
@synthesize secret = secret_;

- (id)initWithKey:(NSString *)theKey secret:(NSString *)theSecret {
	if (self = [super init]) {
		self.key = theKey;
		self.secret = theSecret;
	}

	return self;
}

- (id)initWithString:(NSString *)keyAndSecretString {
	NSString *theKey = nil;
	NSString *theSecret = nil;

	NSArray *theComponents = [keyAndSecretString componentsSeparatedByString:@"&"];
	for (NSString *aComponent in theComponents) {
		NSArray *componentPair = [aComponent componentsSeparatedByString:@"="];
		if (componentPair.count == 2) {
			NSString *parameterName = [componentPair objectAtIndex:0];
			if ([parameterName isEqualToString:kOAuthTokenParameterName]) {
				theKey = [[componentPair objectAtIndex:1] stringByReplacingPercentEscapesUsingEncoding:NSASCIIStringEncoding];

			} else if ([parameterName isEqualToString:kOAuthTokenSecretParameterName]) {
				theSecret = [[componentPair objectAtIndex:1] stringByReplacingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
			}
		}
	}
	if (theKey && theSecret) {
		return [self initWithKey:theKey secret:theSecret];
	}


	/* TODO: Raise */
	return nil;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
	if (self = [super init]) {
		self.key = [aDecoder decodeObjectForKey:kOAuthTokenKeyCoderKey];
		self.secret = [aDecoder decodeObjectForKey:kOAuthTokenSecretCoderKey];
	}

	return self;
}

- (void)dealloc {
	[key_ release];
	[secret_ release];
	[super dealloc];
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
	[aCoder encodeObject:self.key forKey:kOAuthTokenKeyCoderKey];
	[aCoder encodeObject:self.secret forKey:kOAuthTokenSecretCoderKey];
}

+ (id)tokenWithKey:(NSString *)theKey secret:(NSString *)theSecret {
	return [[[self alloc] initWithKey:theKey secret:theSecret] autorelease];
}

+ (id)tokenWithString:(NSString *)keyAndSecretString {
	return [[[self alloc] initWithString:keyAndSecretString] autorelease];
}

@end
