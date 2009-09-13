//
//  RCKeyRing.m
//  iRae
//
//  Created by Alberto García Hierro on 08/09/09.
//  Copyright 2009 Alberto García Hierro. All rights reserved.
//

#import "RCKeyRing.h"

@implementation RCKeyPair

@synthesize publicKey = publicKey_;
@synthesize privateKey = privateKey_;

- (id)initWithPublicKey:(NSString *)publicKey privateKey:(NSString *)privateKey {
	if (self = [super init]) {
		self.publicKey = publicKey;
		self.privateKey = privateKey;
	}

	return self;
}

- (void)dealloc {
	[publicKey_ release];
	[privateKey_ release];
	[super dealloc];
}

+ (RCKeyPair *)keypairWithPublicKey:(NSString *)publicKey privateKey:(NSString *)privateKey {
	return [[[self alloc] initWithPublicKey:publicKey privateKey:privateKey] autorelease];
}

@end


@interface RCKeyRingPrivate : NSObject {
	NSMutableDictionary *cache_;
	NSMutableDictionary *keyPairs_;
}

- (RCKeyPair *)keyPairForURL:(NSURL *)theURL;
- (void)addKeyPair:(RCKeyPair *)theKeyPair forURL:(NSURL *)theURL;
- (void)removeKeyPairForURL:(NSURL *)theURL;

@end

@implementation RCKeyRingPrivate

- (id)init {
	if (self = [super init]) {
		cache_ = [NSMutableDictionary new];
		keyPairs_ = [NSMutableDictionary new];
	}

	return self;
}

- (void)dealloc {
	[cache_ release];
	[keyPairs_ release];
	[super dealloc];
}

- (RCKeyPair *)keyPairForURL:(NSURL *)theURL {
	NSString *URLString = theURL.absoluteString;
	RCKeyPair *keyPair = [cache_ objectForKey:URLString];
	if (nil == keyPair) {
		for (NSString *key in keyPairs_) {
			if ([URLString hasPrefix:key]) {
				keyPair = [keyPairs_ objectForKey:key];
				[cache_ setObject:keyPair forKey:URLString];
				break;
			}
		}
	}

	return keyPair;
}

- (void)addKeyPair:(RCKeyPair *)theKeyPair forURL:(NSURL *)theURL {
	[keyPairs_ setObject:theKeyPair forKey:theURL.absoluteString];
	[cache_ removeAllObjects];
}

- (void)removeKeyPairForURL:(NSURL *)theURL {
	[keyPairs_ removeObjectForKey:theURL.absoluteString];
	[cache_ removeAllObjects];
}


@end


@implementation RCKeyRing

static RCKeyRing *_sharedKeyRing = nil;

- (id)init {
	if (self = [super init]) {
		priv_ = [RCKeyRingPrivate new];
	}

	return self;
}

- (void)dealloc {
	[priv_ release];
	[super dealloc];
}

- (RCKeyPair *)keyPairForURL:(NSURL *)theURL {
	return [priv_ keyPairForURL:theURL];
}

- (void)addKeyPair:(RCKeyPair *)theKeyPair forURL:(NSURL *)theURL {
	[priv_ addKeyPair:theKeyPair forURL:theURL];
}

- (void)removeKeyPairForURL:(NSURL *)theURL {
	[priv_ removeKeyPairForURL:theURL];
}


- (void)release {
}

- (id)retain {
	return self;
}

- (id)autorelease {
	return self;
}

- (id)copyWithZone:(NSZone *)zone {
	return self;
}

- (NSUInteger)retainCount {
	return UINT_MAX;
}

+ (RCKeyRing *)sharedKeyRing {
	@synchronized(self) {
		if (_sharedKeyRing == nil) {
			_sharedKeyRing = [self new];
		}
	}

	return _sharedKeyRing;
}

+ (id)allocWithZone:(NSZone *)zone {
	@synchronized(self) {
		if (_sharedKeyRing == nil) {
			_sharedKeyRing = [super allocWithZone:zone];
			return _sharedKeyRing;
		}
	}

	return nil;
}

@end
