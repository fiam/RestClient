//
//  RCSignedCall.h
//  iRae
//
//  Created by Alberto García Hierro on 07/09/09.
//  Copyright 2009 Alberto García Hierro. All rights reserved.
//

#import <RestClient/RCCall.h>

extern NSString *kRCSignedCallSignatureError;
extern NSString *kRCSignedCallSignatureTimestampError;
extern NSString *kRCSignedCallSignatureNonceError;
extern NSString *kRCSignedCallSignatureKeyError;
extern NSString *kRCSignedCallSignatureValueError;

@interface RCSignedCall : RCCall {
	NSString *publicKey_;
	NSString *privateKey_;
}

@property(nonatomic, retain) NSString *publicKey;
@property(nonatomic, retain) NSString *privateKey;
@property(nonatomic, readonly) NSString *signatureError;

+ (NSString *)makeNonce;

@end
