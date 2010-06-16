//
//  RCOAuthToken.h
//  RestClient
//
//  Created by Alberto García Hierro on 28/05/10.
//  Copyright 2010 Alberto García Hierro. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const kOAuthTokenParameterName;
extern NSString * const kOAuthTokenSecretParameterName;
extern NSString * const kOAuthVerifierParameterName;

@interface RCOAuthToken : NSObject <NSCoding> {
	NSString *key_;
	NSString *secret_;
}

@property(nonatomic, retain) NSString *key;
@property(nonatomic, retain) NSString *secret;

- (id)initWithKey:(NSString *)theKey secret:(NSString *)theSecret;
- (id)initWithString:(NSString *)keyAndSecretString;
- (NSString *)toString;

+ (id)tokenWithKey:(NSString *)theKey secret:(NSString *)theSecret;
+ (id)tokenWithString:(NSString *)keyAndSecretString;

@end
