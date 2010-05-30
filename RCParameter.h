//
//  RCParameter.h
//  Tooio
//
//  Created by Alberto García Hierro on 16/04/09.
//  Copyright 2009 Tooio Mobile S.L. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

@class RCCall;

@interface RCParameter : NSObject {
	NSString *name_;
	NSString *value_;
}

@property(nonatomic, copy) NSString *name;
@property(nonatomic, copy) NSString *value;

- (id)initWithName:(NSString *)theName value:(NSString *)theValue;
- (id)initWithName:(NSString *)theName intValue:(NSInteger)theIntValue;
- (id)initWithName:(NSString *)theName floatValue:(CGFloat)theFloatValue;
- (id)initWithName:(NSString *)theName boolValue:(BOOL)theBoolValue;
- (void)attachToCall:(RCCall *)theCall;
- (NSString *)URLEncodedValue;

+ (NSString *)URLEncodedString:(NSString *)theString;
+ (NSString *)URLEncodedParameterString:(NSString *)theString;

+ (id)parameterWithName:(NSString *)theName value:(NSString *)theValue;
+ (id)parameterWithName:(NSString *)theName intValue:(NSInteger)theIntValue;
+ (id)parameterWithName:(NSString *)theName floatValue:(CGFloat)theFloatValue;
+ (id)parameterWithName:(NSString *)theName boolValue:(BOOL)theBoolValue;
+ (NSArray *)parameterList:(NSString *)firstName, ... NS_REQUIRES_NIL_TERMINATION;

@end
