//
//  RCManager.m
//  Tooio
//
//  Created by Alberto García Hierro on 16/04/09.
//  Copyright 2009 Tooio Mobile S.L. All rights reserved.
//

#import "RCCall.h"

#import "RCManager.h"


@implementation RCManager

@synthesize baseURL = baseURL_;
@synthesize delegate = delegate_;

- (id)init {
	return [self initWithBaseURL:nil];
}

- (id)initWithBaseURL:(NSString *)theBaseURL {
	return [self initWithBaseURL:theBaseURL delegate:nil];
}

- (id)initWithBaseURL:(NSString *)theBaseURL delegate:(id <NSObject>)theDelegate {

	if (self = [super init]) {
		self.baseURL = theBaseURL;
		self.delegate = theDelegate;
		callList_ = [NSMutableArray new];
	}

	return self;
}

- (void)dealloc {
	[callList_ release];
	[baseURL_ release];
	[super dealloc];
}

- (void)setBaseURL:(NSString *)theBaseURL {
	if (!theBaseURL) {
		theBaseURL = @"";
	}

	[self willChangeValueForKey:@"baseURL"];
	NSString *copy = [theBaseURL copy];
	[baseURL_ release];
	baseURL_ = copy;
	[self didChangeValueForKey:@"baseURL"];
}

- (void)mayHideNetworkIndicator {
	if (!callList_.count) {
		[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
	}	
}

- (void)cancelCall:(RCCall *)theCall {
	@synchronized(callList_) {
		[callList_ removeObject:theCall];
		[self mayHideNetworkIndicator];
	}
	[theCall cancel];
}

- (void)cancelCalls {
	@synchronized(callList_) {
		[callList_ makeObjectsPerformSelector:@selector(cancel)];
		[callList_ removeAllObjects];
		[self mayHideNetworkIndicator];
	}
}

- (void)cancelCallsForDelegate:(NSObject *)theDelegate {
	@synchronized(callList_) {
		NSArray *calls = [NSArray arrayWithArray:callList_];
		for (RCCall *call in calls) {
			if (call.delegate == theDelegate) {
				[call cancel];
				[callList_ removeObject:call];
			}
		}
		[self mayHideNetworkIndicator];
	}
}

- (void)pushCall:(RCCall *)theCall {
	theCall.manager = self;
	theCall.delegate = self.delegate;
	theCall.callURL = [self.baseURL stringByAppendingString:theCall.callURL];
	@synchronized(callList_) {
		[callList_ addObject:theCall];
		if (callList_.count == 1) {
			[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
		}
	}

	[theCall perform];
}

- (void)callDidComplete:(RCCall *)theCall {
	@synchronized(callList_) {
		[callList_ removeObject:theCall];
		[self mayHideNetworkIndicator];
	}
}

@end
