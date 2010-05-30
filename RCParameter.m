//
//  RCParameter.m
//  Tooio
//
//  Created by Alberto García Hierro on 16/04/09.
//  Copyright 2009 Tooio Mobile S.L. All rights reserved.
//

#import "RCCall.h"

#import "RCParameter.h"


@implementation RCParameter

@synthesize name = name_;
@synthesize value = value_;

- (id)initWithName:(NSString *)theName value:(NSString *)theValue {
	if (self = [super init]) {
		self.name = theName;
		self.value = theValue;
	}

	return self;
}

- (id)initWithName:(NSString *)theName intValue:(NSInteger)theIntValue {
	return [self initWithName:theName value:[NSString stringWithFormat:@"%d", theIntValue]];
}

- (id)initWithName:(NSString *)theName floatValue:(CGFloat)theFloatValue {
	return [self initWithName:theName value:[NSString stringWithFormat:@"%f", theFloatValue]];
}

- (id)initWithName:(NSString *)theName boolValue:(BOOL)theBoolValue {
	return [self initWithName:theName value:theBoolValue ? @"true" : @"false"];
}

- (void)dealloc {
	[name_ release];
	[value_ release];
	[super dealloc];
}

- (void)attachToCall:(RCCall *)theCall {
	NSString *encodedName = [[self class] URLEncodedString:self.name];
	NSString *encodedValue = [[self class] URLEncodedParameterString:self.value];
	if (theCall.callMethod == kRCCallMethodGET) {
		NSString *separator = @"&";
		NSString *currentURL = [[theCall.request URL] absoluteString];
		if ([currentURL rangeOfString:@"?"].location == NSNotFound) {
			separator = @"?";
		}
		NSString *currentParameter = [NSString stringWithFormat:@"%@%@=%@", separator, encodedName, encodedValue];
		currentURL = [currentURL stringByAppendingString:currentParameter];
		[theCall.request setURL:[NSURL URLWithString:currentURL]];
	} else if (theCall.callMethod == kRCCallMethodPOST) {
		[theCall.request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
		NSMutableString *body = [[NSMutableString alloc] initWithData:theCall.request.HTTPBody encoding:NSUTF8StringEncoding];
		NSString *separator = body.length ? @"&" : @"";
		[body appendFormat:@"%@%@=%@", separator, encodedName, encodedValue];
		[theCall.request setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
		[body release];
	}
}

- (NSString *)URLEncodedValue {
	return [NSString stringWithFormat:@"%@=%@",
			[[self class] URLEncodedString:self.name],
			[[self class] URLEncodedParameterString:self.value]];
}

- (NSString *)description {
	return [NSString stringWithFormat:@"<RCParameter: %@=%@>", self.name, self.value];
}

#pragma mark -
#pragma mark URLEncoding

+ (NSString *)URLEncodedString:(NSString *)theString {
	NSString *result = (NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                           (CFStringRef)theString,
                                                                           NULL,
                                                                           CFSTR("?=&+"),
                                                                           kCFStringEncodingUTF8);
	return [result autorelease];
}

+ (NSString *)URLEncodedParameterString:(NSString *)theString {
    NSString *result = (NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                           (CFStringRef)theString,
                                                                           NULL,
                                                                           CFSTR(":/=,!$&'()*+;[]@#?"),
                                                                           kCFStringEncodingUTF8);
	return [result autorelease];
}

+ (id)parameterWithName:(NSString *)theName value:(NSString *)theValue {
	return [[[[self class] alloc] initWithName:theName value:theValue] autorelease];
}

+ (id)parameterWithName:(NSString *)theName intValue:(NSInteger)theIntValue {
	return [[[[self class] alloc] initWithName:theName intValue:theIntValue] autorelease];
}

+ (id)parameterWithName:(NSString *)theName floatValue:(CGFloat)theFloatValue {
	return [[[[self class] alloc] initWithName:theName floatValue:theFloatValue] autorelease];
}

+ (id)parameterWithName:(NSString *)theName boolValue:(BOOL)theBoolValue {
	return [[[[self class] alloc] initWithName:theName boolValue:theBoolValue] autorelease];
}

+ (NSArray *)parameterList:(NSString *)firstName, ... {
	NSMutableArray *array = [NSMutableArray array];
	id name;
	id currentObject;
	if (firstName) {
		name = firstName;
		va_list ap;
		va_start(ap, firstName);
		while (currentObject = va_arg(ap, id)) {
			if (name) {
				RCParameter *parameter = [RCParameter parameterWithName:name value:currentObject];
				[array addObject:parameter];
				name = nil;
			} else {
				name = currentObject;
			}
		}
		va_end(ap);
	}

	if (name) {
		/* Odd number of arguments passed */
		[NSException raise:NSInvalidArgumentException format:@"Odd number of parameters passed to parameterList: (last argument was %@)", name];
	}

	return [NSArray arrayWithArray:array];
}


@end
