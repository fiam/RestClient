//
//  RCSignedCall.m
//  iRae
//
//  Created by Alberto García Hierro on 07/09/09.
//  Copyright 2009 Alberto García Hierro. All rights reserved.
//

#import <CommonCrypto/CommonHMAC.h>

#import <RestClient/RCParameter.h>
#import <RestClient/Signed/RCKeyRing.h>
#import <RestClient/Signed/Base64.h>

#import "RCSignedCall.h"

NSString *kRCSignedCallSignatureError = @"signature_error";
NSString *kRCSignedCallSignatureTimestampError = @"signature_timestamp_error";
NSString *kRCSignedCallSignatureNonceError = @"signature_nonce_error";
NSString *kRCSignedCallSignatureKeyError = @"signature_key_error";
NSString *kRCSignedCallSignatureValueError = @"signature_value_error";

@implementation RCSignedCall

@synthesize publicKey = publicKey_;
@synthesize privateKey = privateKey_;

- (void)dealloc {
	[publicKey_ release];
	[privateKey_ release];
	[super dealloc];
}

- (RCKeyPair *)keyPair {
	return [[RCKeyRing sharedKeyRing] keyPairForURL:[NSURL URLWithString:self.callURL]];
}

- (NSString *)currentPublicKey {
	if (publicKey_) {
		return publicKey_;
	}

	NSString *publicKey = self.keyPair.publicKey;
	if (publicKey) {
		return publicKey;
	}

	NSException *e = [NSException exceptionWithName:@"RestClient.NoKeyException"
											 reason:@"Missing public key" userInfo:nil];
	[e raise];
	return nil;
}

- (NSString *)currentPrivateKey {
	if (privateKey_) {
		return privateKey_;
	}

	NSString *privateKey = self.keyPair.privateKey;
	if (privateKey) {
		return privateKey;
	}

	NSException *e = [NSException exceptionWithName:@"RestClient.NoKeyException"
											 reason:@"Missing private key" userInfo:nil];
	[e raise];
	return nil;
}

- (NSString *)signatureError {
	if (self.responseCode == 403) {
		NSDictionary *headers = [self.response allHeaderFields];
		return [headers objectForKey:@"X-Webservice-Signature-Error"];
	}

	return nil;
}

- (NSString *)signatureClearTextWithTimestamp:(NSString *)timestamp nonce:(NSString *)nonce {
	NSMutableArray *pairs = [NSMutableArray arrayWithCapacity:self.parameters.count];
	for (RCParameter *parameter in self.parameters) {
		[pairs addObject:[NSString stringWithFormat:@"%@=%@", parameter.name, parameter.value]];
	}
	[pairs sortUsingSelector:@selector(compare:)];
	NSString *arguments = [pairs componentsJoinedByString:@"&"];
	NSString *requestPath = self.request.URL.path;
	NSString *nonQuery = [[self.request.URL.absoluteString componentsSeparatedByString:@"?"] objectAtIndex:0];
	if ([nonQuery hasSuffix:@"/"] && ![requestPath hasSuffix:@"/"]) {
		requestPath = [NSString stringWithFormat:@"%@/", requestPath];
	}
	return [NSString stringWithFormat:@"%@&%@&%@&%@&%@", self.request.HTTPMethod, requestPath,
			arguments, timestamp, nonce];
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

- (void)prepareRequest {
	[super prepareRequest];
	NSString *timestamp = [NSString stringWithFormat:@"%d", (int)[[NSDate date] timeIntervalSince1970]];
	NSString *nonce = [[self class] makeNonce];
	NSString *clearText = [self signatureClearTextWithTimestamp:timestamp nonce:nonce];
	NSData *keyData = [self.currentPrivateKey dataUsingEncoding:NSUTF8StringEncoding];
    NSData *clearTextData = [clearText dataUsingEncoding:NSUTF8StringEncoding];
	NSString *signature = [self signatureForKeyData:keyData clearText:clearTextData];
    NSString *header = [NSString stringWithFormat:@"s=%@;k=%@;t=%@;n=%@", signature, self.currentPublicKey,
						timestamp, nonce];
	[self.request setValue:header forHTTPHeaderField:@"X-Webservice-Signature"];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	NSString *signatureError = self.signatureError;
	if (signatureError) {
#ifdef RESTCLIENT_DEBUG
		NSLog(@"Signature error from %@ (%@)", self.callURL, signatureError);
#endif
		if ([signatureError isEqualToString:kRCSignedCallSignatureNonceError]) {
			[self reset];
			[self perform];
			return;
		}
	}

	[super connectionDidFinishLoading:connection];
}

+ (NSString *)makeNonce {
    CFUUIDRef theUUID = CFUUIDCreate(NULL);
    CFStringRef string = CFUUIDCreateString(NULL, theUUID);
	CFRelease(theUUID);
    NSMakeCollectable(theUUID);
	return (NSString *)string;
}

@end
