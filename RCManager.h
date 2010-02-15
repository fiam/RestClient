//
//  RCManager.h
//  Tooio
//
//  Created by Alberto García Hierro on 16/04/09.
//  Copyright 2009 Tooio Mobile S.L. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RCCall;

@interface RCManager : NSObject {
	NSString *baseURL_;
	NSMutableArray *callList_;
	id <NSObject> delegate_;
	NSThread *dispatcherThread_;
}

@property(nonatomic, copy) NSString *baseURL;
@property(nonatomic, assign) id <NSObject> delegate;

- (id)initWithBaseURL:(NSString *)theBaseURL;
- (id)initWithBaseURL:(NSString *)theBaseURL delegate:(id <NSObject>)theDelegate;

- (void)cancelCalls;
- (void)cancelCall:(RCCall *)theCall;
- (void)cancelCallsForDelegate:(NSObject *)theDelegate;
- (void)pushCall:(RCCall *)theCall;
- (void)callDidComplete:(RCCall *)theCall;

@end
