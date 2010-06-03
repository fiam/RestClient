//
//  RCOAuthCall.m
//  Buzzie
//
//  Created by Alberto García Hierro on 20/05/10.
//  Copyright 2010 Alberto García Hierro. All rights reserved.
//

#import <CommonCrypto/CommonHMAC.h>
#import <RestClient/RCParameter.h>
#import <RestClient/Signed/Base64.h>
#import <RestClient/OAuth/RCOAuthToken.h>
#import <RestClient/OAuth/RCOAuthManager.h>

#import "RCOAuthCall.h"

#define NON_NULL(x) (x ? x : @"")

static NSString * const kOAuthVersion = @"1.0";
static NSString * const kOAuthSignatureMethod = @"HMAC-SHA1";

@interface RCOAuthCall ()

+ (NSString *)makeNonce;

@end


@implementation RCOAuthCall

@synthesize token = token_;
@synthesize ignoresToken = ignoresToken_;

- (void)dealloc {
	[token_ release];
	[super dealloc];
}

- (RCOAuthToken *)token {

	if (ignoresToken_) {
		return nil;
	}

	if (token_) {
		return token_;
	}

	RCOAuthManager *theManager = (RCOAuthManager *)[self manager];
	return [theManager token];
}

- (NSString *)authError {
	if (self.responseCode == 403) {
		NSDictionary *headers = [self.response allHeaderFields];
		return [headers objectForKey:@"X-Webservice-Signature-Error"];
	}

	return nil;
}

- (NSString *)signatureForKeyData:(NSData *)keyData clearText:(NSData *)clearTextData {
	unsigned char result[20];
	char base64Result[32];
	size_t base64Length = 32;
	CCHmac(kCCHmacAlgSHA1, [keyData bytes], [keyData length],
		   [clearTextData bytes], [clearTextData length], result);
    Base64EncodeData(result, 20, base64Result, &base64Length);
	NSData *theData = [NSData dataWithBytes:base64Result length:base64Length];
	NSString *base64EncodedResult = [[NSString alloc] initWithData:theData encoding:NSUTF8StringEncoding];
    return [base64EncodedResult autorelease];
}

- (NSString *)signatureBaseStringWithConsumerKey:(NSString *)consumerKey
									   timestamp:(NSString *)theTimestamp
										   nonce:(NSString *)theNonce
										   token:(RCOAuthToken *)theToken {

	static NSString *kOAuthRequiredParameters[] = {
		@"oauth_consumer_key",
		@"oauth_signature_method",
		@"oauth_timestamp",
		@"oauth_nonce",
		@"oauth_version",
	};

	NSString *OAuthParameterValues[] = {
		consumerKey,
		kOAuthSignatureMethod,
		theTimestamp,
		theNonce,
		kOAuthVersion,
	};

    // OAuth Spec, Section 9.1.1 "Normalize Request Parameters"
    // build a sorted array of both request parameters and OAuth header parameters
    NSMutableArray *parameterPairs = [NSMutableArray  arrayWithCapacity:(6 + [[self parameters] count])];
	int end = sizeof(kOAuthRequiredParameters) / sizeof(kOAuthRequiredParameters[0]);
	for (int ii = 0; ii < end; ++ii) {
		RCParameter *aParameter = [RCParameter parameterWithName:kOAuthRequiredParameters[ii]
														   value:OAuthParameterValues[ii]];
		[parameterPairs addObject:[aParameter URLEncodedValue]];
	}

    if (theToken.key.length) {
		RCParameter *tokenParameter = [RCParameter parameterWithName:kOAuthTokenParameterName
															   value:theToken.key];
		[parameterPairs addObject:[tokenParameter URLEncodedValue]];
    }

	NSString *queryString = [self.request.URL query];
	if (queryString.length) {
		NSArray *queryParameters = [queryString componentsSeparatedByString:@"&"];
		for (NSString *queryParameter in queryParameters) {
			[parameterPairs addObject:queryParameter];
		}
	}

	if (self.callMethod == kRCCallMethodPOST) {
		NSString *contentType = [self.request valueForHTTPHeaderField:@"Content-Type"];
		if ([contentType isEqualToString:@"application/x-www-form-urlencoded"]) {
			NSData *theBody = [self.request HTTPBody];
			NSString *bodyString = [[NSString alloc] initWithData:theBody encoding:NSUTF8StringEncoding];
			NSArray *bodyParameters = [bodyString componentsSeparatedByString:@"&"];
			for (NSString *bodyParameter in bodyParameters) {
				[parameterPairs addObject:bodyParameter];
			}
			[bodyString release];
		}
	}

    NSArray *sortedPairs = [parameterPairs sortedArrayUsingSelector:@selector(compare:)];
    NSString *normalizedRequestParameters = [sortedPairs componentsJoinedByString:@"&"];

    // OAuth Spec, Section 9.1.2 "Concatenate Request Elements"
	NSURL *theURL = [self.request URL];
	NSArray *URLParts = [[theURL absoluteString] componentsSeparatedByString:@"?"];
	NSString *nonQueryURLString = [URLParts objectAtIndex:0];
    NSString *ret = [NSString stringWithFormat:@"%@&%@&%@",
					 [self.request HTTPMethod],
					 [RCParameter URLEncodedParameterString:nonQueryURLString],
					 [RCParameter URLEncodedString:normalizedRequestParameters]];

	return ret;
}

- (void)prepareRequest {
	[super prepareRequest];
	NSAssert([self.manager isKindOfClass:[RCOAuthManager class]], @"OAuth calls need to be managed by a RCOAuthManager");
	RCOAuthManager *theManager = (RCOAuthManager *)[self manager];
	NSString *consumerKey = [theManager consumerKey];
	NSString *consumerSecret = [theManager consumerSecret];
	RCOAuthToken *theToken = [self token];
	NSString *timestamp = [NSString stringWithFormat:@"%d", (int)[[NSDate date] timeIntervalSince1970]];
	NSString *nonce = [[self class] makeNonce];
	NSString *baseString = [self signatureBaseStringWithConsumerKey:consumerKey
														  timestamp:timestamp
															  nonce:nonce
															  token:theToken];
	NSString *signingKey = [NSString stringWithFormat:@"%@&%@",
							[RCParameter URLEncodedParameterString:consumerSecret],
							[RCParameter URLEncodedParameterString:NON_NULL(theToken.secret)]];
	NSData *keyData = [signingKey dataUsingEncoding:NSASCIIStringEncoding];
    NSData *clearTextData = [baseString dataUsingEncoding:NSASCIIStringEncoding];
	NSString *signature = [self signatureForKeyData:keyData clearText:clearTextData];
	NSString *extraParameters = nil;
	if (theToken) {
		extraParameters = [NSString stringWithFormat:@",%@=\"%@\"", kOAuthTokenParameterName,
						   [RCParameter URLEncodedParameterString:theToken.key]];
	}

    NSString *header = [NSString stringWithFormat:@"OAuth "
						@"oauth_consumer_key=\"%@\","
						@"oauth_nonce=\"%@\","
						@"oauth_signature_method=\"%@\","
						@"oauth_signature=\"%@\","
						@"oauth_timestamp=\"%@\","
						@"oauth_version=\"%@\"%@",
						consumerKey,
						nonce,
						kOAuthSignatureMethod,
						[RCParameter URLEncodedParameterString:signature],
						timestamp,
						kOAuthVersion,
						NON_NULL(extraParameters)];
#ifdef RESTCLIENT_DEBUG_OAUTH
	NSLog(@"Basestring: %@, Key: %@, Signature: %@", baseString, signingKey, signature);
#endif
	[self.request setValue:header forHTTPHeaderField:@"Authorization"];
}

+ (NSString *)makeNonce {
    CFUUIDRef theUUID = CFUUIDCreate(NULL);
    CFStringRef string = CFUUIDCreateString(NULL, theUUID);
	CFRelease(theUUID);
    NSMakeCollectable(theUUID);
	return (NSString *)string;
}

@end
