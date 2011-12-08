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

static int Lua_Fatal( lua_State* state )
{
	const char* location = lua_tostring(state, -2);
	const char* error = lua_tostring(state, -1);
	[FCError fatal:[NSString stringWithCString:location encoding:NSUTF8StringEncoding] info:[NSString stringWithCString:error encoding:NSUTF8StringEncoding]];	
	return 0;
}

static int Lua_Error( lua_State* state )
{
	const char* location = lua_tostring(state, -2);
	const char* error = lua_tostring(state, -1);
	[FCError error:[NSString stringWithCString:location encoding:NSUTF8StringEncoding] info:[NSString stringWithCString:error encoding:NSUTF8StringEncoding]];	
	return 0;
}

static int Lua_Warning( lua_State* state )
{
	const char* location = lua_tostring(state, -2);
	const char* error = lua_tostring(state, -1);
	[FCError warning:[NSString stringWithCString:location encoding:NSUTF8StringEncoding] info:[NSString stringWithCString:error encoding:NSUTF8StringEncoding]];	
	return 0;
}

static int Lua_Log( lua_State* state )
{
	const char* log = lua_tostring(state, -1);
	NSString* logString = [NSString stringWithFormat:@"Lua(0x%08x):%s", state, log];
	[FCError log:logString];	
	return 0;
}

@implementation FCError

+(void)registerLuaFunctions:(FCLuaVM*)lua
{
	[lua registerCFunction:Lua_Fatal as:@"FCFatal"];
	[lua registerCFunction:Lua_Error as:@"FCError"];
	[lua registerCFunction:Lua_Warning as:@"FCWarning"];
	[lua registerCFunction:Lua_Log as:@"FCLog"];
}

#pragma mark - Fatal

+(void)fatal:(NSString*)location info:(NSString*)errorString
{
	NSLog(@"FATAL - %@ - %@", location, errorString);
	[FCError halt];
}

+(void)fatal1:(NSString*)location info:(NSString*)errorString arg1:(id)arg1
{
	NSString* infoString = [NSString stringWithFormat:errorString, arg1];
	NSLog(@"FATAL - %@ - %@", location, infoString);
	[FCError halt];
}

+(void)fatal2:(NSString*)location info:(NSString*)errorString arg1:(id)arg1 arg2:(id)arg2
{
	NSString* infoString = [NSString stringWithFormat:errorString, arg1, arg2];
	NSLog(@"FATAL - %@ - %@", location, infoString);
	[FCError halt];
}

#pragma mark - Error

+(void)error:(NSString*)location info:(NSString*)errorString
{
	NSLog(@"ERROR - %@ - %@", location, errorString);	
}

+(void)error1:(NSString*)location info:(NSString*)errorString arg1:(id)arg1
{
	NSLog(@"ERROR - %@ - %@ %@", location, errorString, arg1);
}

+(void)error2:(NSString*)location info:(NSString*)errorString arg1:(id)arg1 arg2:(id)arg2
{
	NSLog(@"ERROR - %@ - %@ %@ %@", location, errorString, arg1, arg2);
}

#pragma mark - Warning

+(void)warning:(NSString*)location info:(NSString*)warningString
{
	NSLog(@"WARNING - %@ - %@", location, warningString);	
}

+(void)warning1:(NSString*)location info:(NSString*)warningString arg1:(id)arg1
{
	NSLog(@"WARNING - %@ - %@ %@", location, warningString, arg1);
}

#pragma mark - Log

+(void)log:(id)logItem
{
	NSLog(@"%@", logItem);
}

+(void)log1:(id)logItem arg1:(id)arg1
{
	NSLog( logItem, arg1 );
}

+(void)log2:(id)logItem arg1:(id)arg1 arg2:(id)arg2
{
	NSLog( logItem, arg1, arg2 );
}

+(void)log3:(id)logItem arg1:(id)arg1 arg2:(id)arg2 arg3:(id)arg3
{
	NSLog( logItem, arg1, arg2, arg3 );
}

+(void)halt
{
	int* pHalt = 0;
	*pHalt = 0xff;
}

@end
