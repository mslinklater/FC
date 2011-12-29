/*
 Copyright (C) 2011 by Martin Linklater
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 */

#import "FCError.h"
#import "FCLua.h"
#import "FCConnect.h"

static int lua_Fatal( lua_State* state )
{
	const char* location = lua_tostring(state, -2);
	const char* error = lua_tostring(state, -1);
	[FCError fatal:[NSString stringWithCString:location encoding:NSUTF8StringEncoding] info:[NSString stringWithCString:error encoding:NSUTF8StringEncoding]];	
	return 0;
}

static int lua_Error( lua_State* state )
{
	const char* location = lua_tostring(state, -2);
	const char* error = lua_tostring(state, -1);
	[FCError error:[NSString stringWithCString:location encoding:NSUTF8StringEncoding] info:[NSString stringWithCString:error encoding:NSUTF8StringEncoding]];	
	return 0;
}

static int lua_Warning( lua_State* state )
{
	const char* location = lua_tostring(state, -2);
	const char* error = lua_tostring(state, -1);
	[FCError warning:[NSString stringWithCString:location encoding:NSUTF8StringEncoding] info:[NSString stringWithCString:error encoding:NSUTF8StringEncoding]];	
	return 0;
}

static int lua_Log( lua_State* state )
{
	const char* log = lua_tostring(state, -1);
	NSString* logString = [NSString stringWithFormat:@"Lua(0x%08x):%s", state, log];
	[FCError log:logString];	
	return 0;
}

@implementation FCError

+(void)registerLuaFunctions:(FCLuaVM*)lua
{
	[lua registerCFunction:lua_Fatal as:@"FCFatal"];
	[lua registerCFunction:lua_Error as:@"FCError"];
	[lua registerCFunction:lua_Warning as:@"FCWarning"];
	[lua registerCFunction:lua_Log as:@"FCLog"];
}

#pragma mark - Fatal

+(void)fatal:(NSString*)location info:(NSString*)errorString
{
	NSString* output = [NSString stringWithFormat:@"FATAL - %@ - %@", location, errorString];
#if TARGET_OS_IPHONE
	[[FCConnect instance] sendString:[output stringByAppendingString:@"\n"]];
#endif
	NSLog( @"%@", output );
	[FCError halt];
}

+(void)fatal1:(NSString*)location info:(NSString*)errorString arg1:(id)arg1
{
	NSString* infoString = [NSString stringWithFormat:errorString, arg1];
	NSString* output = [NSString stringWithFormat:@"FATAL - %@ - %@", location, infoString];
#if TARGET_OS_IPHONE
	[[FCConnect instance] sendString:[output stringByAppendingString:@"\n"]];
#endif
	NSLog(@"%@", output);
	[FCError halt];
}

+(void)fatal2:(NSString*)location info:(NSString*)errorString arg1:(id)arg1 arg2:(id)arg2
{
	NSString* infoString = [NSString stringWithFormat:errorString, arg1, arg2];
	NSString* output = [NSString stringWithFormat:@"FATAL - %@ - %@", location, infoString];
#if TARGET_OS_IPHONE
	[[FCConnect instance] sendString:[output stringByAppendingString:@"\n"]];
#endif
	NSLog( @"%@", output );
	[FCError halt];
}

#pragma mark - Error

+(void)error:(NSString*)location info:(NSString*)errorString
{
	NSString* output = [NSString stringWithFormat:@"ERROR - %@ - %@", location, errorString];
#if TARGET_OS_IPHONE
	[[FCConnect instance] sendString:[output stringByAppendingString:@"\n"]];
#endif
	NSLog(@"%@", output);	
}

+(void)error1:(NSString*)location info:(NSString*)errorString arg1:(id)arg1
{
	NSString* concat = [NSString stringWithFormat:errorString, arg1];
	NSString* output = [NSString stringWithFormat:@"ERROR - %@ - %@", location, concat];
#if TARGET_OS_IPHONE
	[[FCConnect instance] sendString:[output stringByAppendingString:@"\n"]];
#endif
	NSLog(@"%@", output);
}

+(void)error2:(NSString*)location info:(NSString*)errorString arg1:(id)arg1 arg2:(id)arg2
{
	NSString* concat = [NSString stringWithFormat:errorString, arg1, arg2];
	NSString* output = [NSString stringWithFormat:@"ERROR - %@ - %@", location, concat];
#if TARGET_OS_IPHONE
	[[FCConnect instance] sendString:[output stringByAppendingString:@"\n"]];
#endif
	NSLog(@"%@", output);	
}

#pragma mark - Warning

+(void)warning:(NSString*)location info:(NSString*)warningString
{
	NSString* output = [NSString stringWithFormat:@"WARNING - %@ - %@", location, warningString];
#if TARGET_OS_IPHONE
	[[FCConnect instance] sendString:[output stringByAppendingString:@"\n"]];
#endif
	NSLog( @"%@", output );	
}

+(void)warning1:(NSString*)location info:(NSString*)warningString arg1:(id)arg1
{
	NSString* concat = [NSString stringWithFormat:warningString, arg1];
	NSString* output = [NSString stringWithFormat:@"WARNING - %@ - %@", location, concat];
#if TARGET_OS_IPHONE
	[[FCConnect instance] sendString:[output stringByAppendingString:@"\n"]];
#endif
	NSLog(@"%@", output );
}

#pragma mark - Log

+(void)log:(id)logItem
{
	NSString* output = [NSString stringWithFormat:@"%@", logItem];
#if TARGET_OS_IPHONE
	[[FCConnect instance] sendString:[output stringByAppendingString:@"\n"]];
#endif
	NSLog( @"%@", output );
}

+(void)log1:(id)logItem arg1:(id)arg1
{
	NSString* output = [NSString stringWithFormat:logItem, arg1];
#if TARGET_OS_IPHONE
	[[FCConnect instance] sendString:[output stringByAppendingString:@"\n"]];
#endif
	NSLog( @"%@", output );
}

+(void)log2:(id)logItem arg1:(id)arg1 arg2:(id)arg2
{
	NSString* output = [NSString stringWithFormat:logItem, arg1, arg2];
#if TARGET_OS_IPHONE
	[[FCConnect instance] sendString:[output stringByAppendingString:@"\n"]];
#endif
	NSLog( @"%@", output );
}

+(void)log3:(id)logItem arg1:(id)arg1 arg2:(id)arg2 arg3:(id)arg3
{
	NSString* output = [NSString stringWithFormat:logItem, arg1, arg2, arg3];
#if TARGET_OS_IPHONE
	[[FCConnect instance] sendString:[output stringByAppendingString:@"\n"]];
#endif
	NSLog( @"%@", output );
}

+(void)halt
{
	int* pHalt = 0;
	*pHalt = 0xff;
}

@end
