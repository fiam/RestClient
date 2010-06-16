//
//  RCCall.h
//  RestClient
//
//  Created by Alberto García Hierro on 16/04/09.
//  Copyright 2009 Alberto García Hierro. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RCManager;

typedef enum {
	kRCCallMethodHEAD,
	kRCCallMethodGET,
	kRCCallMethodPOST,
	kRCCallMethodPUT,
	kRCCallMethodDELETE,
} RCCallMethod;

@interface RCCall : NSObject {
	RCManager *manager_;
	RCCallMethod callMethod_;
	NSString *callURL_;
	NSArray *parameters_;
	id <NSObject> delegate_;
	SEL didFinishSelector_;
	SEL didFailSelector_;
	NSMutableURLRequest *request_;
	NSMutableData *responseBody_;
	NSStringEncoding bodyEncoding_;
	NSHTTPURLResponse *response_;
	NSError *responseError_;
	NSURLConnection *connection_;
	void *context_;
}

@property(nonatomic, assign) RCManager *manager;
@property(nonatomic) RCCallMethod callMethod;
@property(nonatomic, copy) NSString *callURL;
@property(nonatomic, retain) NSArray *parameters;
@property(nonatomic, assign) id <NSObject> delegate;
@property(nonatomic) SEL didFinishSelector;
@property(nonatomic) SEL didFailSelector;
@property(nonatomic) NSStringEncoding bodyEncoding;
@property(nonatomic, readonly) NSMutableURLRequest *request;
@property(nonatomic, readonly) NSData *responseBody;
@property(nonatomic, readonly) NSHTTPURLResponse *response;
@property(nonatomic, readonly) NSInteger responseCode;
@property(nonatomic, readonly) NSError *responseError;
@property(nonatomic, readonly) NSString *responseBodyString;
@property(nonatomic, assign) void *context;
@property(nonatomic, readonly) BOOL didSucceed;

- (id)initWithCallURL:(NSString *)theCallURL parameters:(NSArray *)parameters;

- (id)initWithCallURL:(NSString *)theCallURL method:(RCCallMethod)theMethod
		   parameters:(NSArray *)theParameters didFinishSelector:(SEL)didFinishSelector
	  didFailSelector:(SEL)didFailSelector;

- (id)initWithCallURL:(NSString *)theCallURL parameters:(NSArray *)theParameters
	didFinishSelector:(SEL)didFinishSelector didFailSelector:(SEL)didFailSelector;

- (id)initWithCallURL:(NSString *)theCallURL method:(RCCallMethod)theMethod
	didFinishSelector:(SEL)didFinishSelector didFailSelector:(SEL)didFailSelector;

- (id)initWithCallURL:(NSString *)theCallURL didFinishSelector:(SEL)didFinishSelector
	  didFailSelector:(SEL)didFailSelector;

- (id)initWithCallURL:(NSString *)theCallURL method:(RCCallMethod)theMethod
		   parameters:(NSArray *)theParameters delegate:(id <NSObject>)delegate
	didFinishSelector:(SEL)didFinishSelector didFailSelector:(SEL)didFailSelector;

- (void)prepareRequest;
- (void)perform;
- (void)cancel;
- (void)reset;

+ (id)callWithCallURL:(NSString *)theCallURL parameters:(NSArray *)parameters;

+ (id)callWithCallURL:(NSString *)theCallURL method:(RCCallMethod)theMethod
		   parameters:(NSArray *)theParameters didFinishSelector:(SEL)didFinishSelector
	  didFailSelector:(SEL)didFailSelector;

+ (id)callWithCallURL:(NSString *)theCallURL parameters:(NSArray *)theParameters
	didFinishSelector:(SEL)didFinishSelector didFailSelector:(SEL)didFailSelector;

+ (id)callWithCallURL:(NSString *)theCallURL parameters:(NSArray *)theParameters
	didFinishSelector:(SEL)didFinishSelector;

+ (id)callWithCallURL:(NSString *)theCallURL didFinishSelector:(SEL)didFinishSelector;

+ (id)callWithCallURL:(NSString *)theCallURL method:(RCCallMethod)theMethod
	didFinishSelector:(SEL)didFinishSelector didFailSelector:(SEL)didFailSelector;

+ (id)callWithCallURL:(NSString *)theCallURL didFinishSelector:(SEL)didFinishSelector
	  didFailSelector:(SEL)didFailSelector;

+ (id)callWithCallURL:(NSString *)theCallURL method:(RCCallMethod)theMethod
		   parameters:(NSArray *)theParameters delegate:(id <NSObject>)delegate
	didFinishSelector:(SEL)didFinishSelector didFailSelector:(SEL)didFailSelector;

+ (id)callWithCallURL:(NSString *)theCallURL delegate:(id <NSObject>)delegate
	didFinishSelector:(SEL)didFinishSelector;

+ (id)callWithCallURL:(NSString *)theCallURL parameters:(NSArray *)parameters
			 delegate:(id <NSObject>)delegate didFinishSelector:(SEL)didFinishSelector;

@end
