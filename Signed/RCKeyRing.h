//
//  RCKeyRing.h
//  RestClient
//
//  Created by Alberto García Hierro on 08/09/09.
//  Copyright 2009 Alberto García Hierro. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RCKeyRingPrivate;

@interface RCKeyPair : NSObject {
	NSString *publicKey_;
	NSString *privateKey_;
}

@property(nonatomic, retain) NSString *publicKey;
@property(nonatomic, retain) NSString *privateKey;

- (id)initWithPublicKey:(NSString *)publicKey privateKey:(NSString *)privateKey;
+ (RCKeyPair *)keypairWithPublicKey:(NSString *)publicKey privateKey:(NSString *)privateKey;

@end


@interface RCKeyRing : NSObject {
	RCKeyRingPrivate *priv_;
}

- (RCKeyPair *)keyPairForURL:(NSURL *)theURL;
- (void)addKeyPair:(RCKeyPair *)theKeyPair forURL:(NSURL *)theURL;
- (void)removeKeyPairForURL:(NSURL *)theURL;
+ (RCKeyRing *)sharedKeyRing;

@end
