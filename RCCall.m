//
//  RCCall.m
//  Tooio
//
//  Created by Alberto García Hierro on 16/04/09.
//  Copyright 2009 Tooio Mobile S.L. All rights reserved.
//

#import "RCManager.h"
#import "RCParameter.h"

#import "RCCall.h"

@interface NSObject (RCCall)

- (NSURLRequest *)call:(RCCall *)call willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)response;

@end


static NSString *Methods[] = {
	@"HEAD",
	@"GET",
	@"POST",
	@"PUT",
	@"DELETE",
};

@implementation RCCall

@synthesize manager = manager_;
@synthesize callURL = callURL_;
@synthesize callMethod = callMethod_;
@synthesize parameters = parameters_;
@synthesize delegate = delegate_;
@synthesize didFinishSelector = didFinishSelector_;
@synthesize didFailSelector = didFailSelector_;
@synthesize request = request_;
@synthesize bodyEncoding = bodyEncoding_;
@synthesize response = response_;
@synthesize responseBody = responseBody_;
@synthesize responseError = responseError_;
@synthesize context = context_;

- (id)init {
	return [self initWithCallURL:nil method:kRCCallMethodGET parameters:nil
						delegate:nil didFinishSelector:0 didFailSelector:0];
}

- (id)initWithCallURL:(NSString *)theCallURL parameters:(NSArray *)parameters {
	return [self initWithCallURL:theCallURL parameters:parameters didFinishSelector:NULL didFailSelector:NULL];
}

- (id)initWithCallURL:(NSString *)theCallURL method:(RCCallMethod)theMethod
		   parameters:(NSArray *)theParameters didFinishSelector:(SEL)didFinishSelector
	  didFailSelector:(SEL)didFailSelector {

	return [self initWithCallURL:theCallURL method:theMethod parameters:theParameters
						delegate:nil didFinishSelector:didFinishSelector didFailSelector:didFailSelector];
}

- (id)initWithCallURL:(NSString *)theCallURL parameters:(NSArray *)theParameters
	didFinishSelector:(SEL)didFinishSelector didFailSelector:(SEL)didFailSelector {

	return [self initWithCallURL:theCallURL method:kRCCallMethodGET parameters:theParameters
			   didFinishSelector:didFinishSelector didFailSelector:didFailSelector];
}

- (id)initWithCallURL:(NSString *)theCallURL method:(RCCallMethod)theMethod
	didFinishSelector:(SEL)didFinishSelector didFailSelector:(SEL)didFailSelector {

	return [self initWithCallURL:theCallURL method:theMethod parameters:nil
			   didFinishSelector:didFinishSelector didFailSelector:didFailSelector];
}

- (id)initWithCallURL:(NSString *)theCallURL didFinishSelector:(SEL)didFinishSelector
	  didFailSelector:(SEL)didFailSelector {

	return [self initWithCallURL:theCallURL method:kRCCallMethodGET parameters:nil
			   didFinishSelector:didFinishSelector didFailSelector:didFailSelector];
}

- (id)initWithCallURL:(NSString *)theCallURL method:(RCCallMethod)theMethod
		   parameters:(NSArray *)theParameters delegate:(id <NSObject>)delegate
	didFinishSelector:(SEL)didFinishSelector didFailSelector:(SEL)didFailSelector {

	if (self = [super init]) {
		self.callURL = theCallURL;
		self.callMethod = theMethod;
		self.parameters = theParameters;
		self.delegate = delegate;
		self.didFinishSelector = didFinishSelector;
		self.didFailSelector = didFailSelector;
		self.bodyEncoding = NSUTF8StringEncoding;
		request_ = [NSMutableURLRequest new];
	}

	return self;
}

- (void)dealloc {
	[callURL_ release];
	[parameters_ release];
	[request_ release];
	[response_ release];
	[responseBody_ release];
	[connection_ cancel];
	[connection_ release];
	[responseError_ release];
	[super dealloc];
}

- (NSInteger)responseCode {
	return [response_ statusCode];
}

- (NSString *)responseBodyString {
	NSString *value = [[NSString alloc] initWithData:responseBody_ encoding:self.bodyEncoding];
	return [value autorelease];
}

- (BOOL)didSucceed {
	return (!responseError_ && self.responseCode >= 200 && self.responseCode < 300);
}

- (void)reset {
	[request_ release];
	request_ = [NSMutableURLRequest new];
}

- (void)prepareRequest {
	[self.request setURL:[NSURL URLWithString:callURL_]];
	[self.request setHTTPMethod:Methods[self.callMethod]];
	for (RCParameter *parameter in parameters_) {
		[parameter attachToCall:self];
	}
}

- (void)perform {
	[self prepareRequest];

	connection_ = [[NSURLConnection alloc] initWithRequest:self.request delegate:self startImmediately:YES];
#ifdef RESTCLIENT_DEBUG
	NSString *body = [[NSString alloc] initWithData:self.request.HTTPBody encoding:NSUTF8StringEncoding];
	NSLog(@"Calling %@ (%@) %@", self.request.URL, self.request.HTTPMethod, body);
	[body release];
#endif
}

- (void)cancel {
	[connection_ cancel];
}

#pragma mark -
#pragma mark NSURLConnectionDelegate

- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request
			redirectResponse:(NSURLResponse *)redirectResponse {

	NSURLRequest *returnedRequest = request;
	if ([self.delegate respondsToSelector:@selector(call:willSendRequest:redirectResponse:)]) {
		returnedRequest = [(id)self.delegate call:self willSendRequest:request redirectResponse:redirectResponse];
	}

	if (returnedRequest) {
		NSMutableURLRequest *mutableRequest = [returnedRequest mutableCopy];
		[request_ release];
		request_ = mutableRequest;
		if (redirectResponse) {
			self.callURL = mutableRequest.URL.absoluteString;
		}
	}

	return returnedRequest;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	[response_ release];
	response_ = [response retain];
	[responseBody_ release];
	responseBody_ = [NSMutableData new];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	[responseBody_ appendData:data];
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse {
	/* Disable the cache */
	return nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
#ifdef RESTCLIENT_DEBUG
	NSLog(@"Received from %@ (%d) '%@'", self.callURL, self.responseCode, self.responseBodyString);
#endif
	[self.delegate performSelector:self.didFinishSelector withObject:self];
	[self.manager callDidComplete:self];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
#ifdef RESTCLIENT_DEBUG
	NSLog(@"Call to %@ failed with error '%@'", self.callURL, [error localizedDescription]);
#endif
	responseError_ = [error retain];
	[self.delegate performSelector:self.didFailSelector ? self.didFailSelector : self.didFinishSelector withObject:self];
	[self.manager callDidComplete:self];
}

#pragma mark Class methods

+ (id)callWithCallURL:(NSString *)theCallURL parameters:(NSArray *)parameters {
	return [[self class] callWithCallURL:theCallURL parameters:parameters
					   didFinishSelector:NULL didFailSelector:NULL];
}

+ (id)callWithCallURL:(NSString *)theCallURL method:(RCCallMethod)theMethod
		   parameters:(NSArray *)theParameters didFinishSelector:(SEL)didFinishSelector
	  didFailSelector:(SEL)didFailSelector {

	return [[self class] callWithCallURL:theCallURL method:theMethod parameters:theParameters
						delegate:nil didFinishSelector:didFinishSelector didFailSelector:didFailSelector];
}

+ (id)callWithCallURL:(NSString *)theCallURL parameters:(NSArray *)theParameters
	didFinishSelector:(SEL)didFinishSelector didFailSelector:(SEL)didFailSelector {

	return [[self class] callWithCallURL:theCallURL method:kRCCallMethodGET parameters:theParameters
			   didFinishSelector:didFinishSelector didFailSelector:didFailSelector];
}

+ (id)callWithCallURL:(NSString *)theCallURL parameters:(NSArray *)theParameters
	didFinishSelector:(SEL)didFinishSelector {

	return [[self class] callWithCallURL:theCallURL method:kRCCallMethodGET parameters:theParameters
					   didFinishSelector:didFinishSelector didFailSelector:NULL];
}

+ (id)callWithCallURL:(NSString *)theCallURL didFinishSelector:(SEL)didFinishSelector {
	return [[self class] callWithCallURL:theCallURL method:kRCCallMethodGET parameters:nil
					   didFinishSelector:didFinishSelector didFailSelector:NULL];
}

+ (id)callWithCallURL:(NSString *)theCallURL method:(RCCallMethod)theMethod
	didFinishSelector:(SEL)didFinishSelector didFailSelector:(SEL)didFailSelector {

	return [[self class] callWithCallURL:theCallURL method:theMethod parameters:nil
			   didFinishSelector:didFinishSelector didFailSelector:didFailSelector];
}

+ (id)callWithCallURL:(NSString *)theCallURL didFinishSelector:(SEL)didFinishSelector
	  didFailSelector:(SEL)didFailSelector {

	return [[self class] callWithCallURL:theCallURL method:kRCCallMethodGET parameters:nil
			   didFinishSelector:didFinishSelector didFailSelector:didFailSelector];
}

+ (id)callWithCallURL:(NSString *)theCallURL method:(RCCallMethod)theMethod
		   parameters:(NSArray *)theParameters delegate:(id <NSObject>)delegate
	didFinishSelector:(SEL)didFinishSelector didFailSelector:(SEL)didFailSelector {

	return [[[[self class] alloc] initWithCallURL:theCallURL method:theMethod parameters:theParameters
										 delegate:delegate didFinishSelector:didFinishSelector
								  didFailSelector:didFailSelector] autorelease];
}

+ (id)callWithCallURL:(NSString *)theCallURL delegate:(id <NSObject>)delegate
	didFinishSelector:(SEL)didFinishSelector {

	return [[[[self class] alloc] initWithCallURL:theCallURL method:kRCCallMethodGET
									   parameters:nil delegate:delegate
								didFinishSelector:didFinishSelector
								  didFailSelector:NULL] autorelease];
}

+ (id)callWithCallURL:(NSString *)theCallURL parameters:(NSArray *)parameters
			 delegate:(id <NSObject>)delegate didFinishSelector:(SEL)didFinishSelector {

	return [[[[self class] alloc] initWithCallURL:theCallURL method:kRCCallMethodGET
									   parameters:parameters delegate:delegate
								didFinishSelector:didFinishSelector
								  didFailSelector:NULL] autorelease];
}


@end
