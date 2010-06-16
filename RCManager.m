//
//  RCManager.m
//  RestClient
//
//  Created by Alberto García Hierro on 16/04/09.
//  Copyright 2009 Alberto García Hierro. All rights reserved.
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
		managedCalls_ = [[NSMutableSet alloc] init];
	}

	return self;
}

- (void)dealloc {
	[baseURL_ release];
	[managedCalls_ makeObjectsPerformSelector:@selector(cancel)];
	[managedCalls_ release];
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
	if (managedCalls_.count == 0) {
		[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
	}	
}

- (void)cancelCall:(RCCall *)theCall {
	if ([managedCalls_ containsObject:theCall]) {
		@synchronized(managedCalls_) {
			[theCall cancel];
			[managedCalls_ removeObject:theCall];
			[self mayHideNetworkIndicator];
		}
	}
}

- (void)cancelCalls {
	@synchronized(managedCalls_) {
		[managedCalls_ makeObjectsPerformSelector:@selector(cancel)];
		[managedCalls_ removeAllObjects];
		[self mayHideNetworkIndicator];
	}
}

- (void)cancelCallsForDelegate:(NSObject *)theDelegate {
	@synchronized(managedCalls_) {
		NSSet *theCalls = [NSSet setWithSet:managedCalls_];
		for (RCCall *aCall in theCalls) {
			if (aCall.delegate == theDelegate) {
				[aCall cancel];
				[managedCalls_ removeObject:aCall];
			}
		}
		[self mayHideNetworkIndicator];
	}
}

- (void)pushCall:(RCCall *)theCall {
	theCall.manager = self;
	theCall.delegate = self.delegate;
	theCall.callURL = [self.baseURL stringByAppendingString:theCall.callURL];
	@synchronized(managedCalls_) {
		[managedCalls_ addObject:theCall];
		if (managedCalls_.count == 1) {
			[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
		}
	}

	[theCall perform];
}

- (void)callDidComplete:(RCCall *)theCall {
	@synchronized(managedCalls_) {
		[managedCalls_ removeObject:theCall];
		[self mayHideNetworkIndicator];
	}
}

@end
