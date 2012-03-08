/*
 Copyright (C) 2011-2012 by Martin Linklater
 
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


#if TARGET_OS_IPHONE

#import "FCCore.h"

#import "FCAnalytics.h"

#pragma mark - Lua Interface

#if defined (FC_LUA)

#import "FCLua.h"

static int lua_RegisterEvent( lua_State* _state )
{
	FC_ASSERT(lua_gettop(_state) == 1);
	FC_ASSERT(lua_type(_state, 1) == LUA_TSTRING);
	
	[[FCAnalytics instance] registerEvent:[NSString stringWithUTF8String:lua_tostring(_state, 1)]];
	
	return 0;
}

static int lua_BeginTimedEvent( lua_State* _state )
{
	FC_ASSERT(lua_gettop(_state) == 1);
	FC_ASSERT(lua_type(_state, 1) == LUA_TSTRING);

	FCHandle handle = [[FCAnalytics instance] beginTimedEvent:[NSString stringWithUTF8String:lua_tostring(_state, 1)]];
	
	lua_pushinteger(_state, handle);
	
	return 1;
}

static int lua_EndTimedEvent( lua_State* _state )
{
	FC_ASSERT(lua_gettop(_state) == 1);
	FC_ASSERT(lua_type(_state, 1) == LUA_TNUMBER);
	
	[[FCAnalytics instance] endTimedEvent:(FCHandle)lua_tointeger(_state, 1)];
	
	return 0;
}

#endif

//----------------------------------------------------------------------------------------------------------------------

@implementation FCAnalytics
@synthesize currentTimedEvents = _currentTimedEvents;
//@synthesize nextHandle = _nextHandle;

#pragma mark - FCSingleton

+(FCAnalytics*)instance
{
	static FCAnalytics* pInstance;
	if (!pInstance) 
	{
		pInstance = [[FCAnalytics alloc] init];

#if defined (FC_LUA)
		[[FCLua instance].coreVM createGlobalTable:@"FCAnalytics"];
		[[FCLua instance].coreVM registerCFunction:lua_RegisterEvent as:@"FCAnalytics.RegisterEvent"];
		[[FCLua instance].coreVM registerCFunction:lua_BeginTimedEvent as:@"FCAnalytics.BeginTimedEvent"];
		[[FCLua instance].coreVM registerCFunction:lua_EndTimedEvent as:@"FCAnalytics.EndTimedEvent"];
#endif // FC_LUA
		
	}
	return pInstance;
}


-(id)init
{
	self = [super init];
	if (self) {
		_currentTimedEvents = [NSMutableDictionary dictionary];
	}
	return self;
}

-(void)registerEvent:(NSString *)event
{
	[FlurryAnalytics logEvent:event];
}

-(FCHandle)beginTimedEvent:(NSString*)event
{
	[FlurryAnalytics logEvent:event timed:YES];
	FCHandle h = NewFCHandle();
	[_currentTimedEvents setObject:event forKey:[NSNumber numberWithInt:h]];
	return h;
}

-(void)endTimedEvent:(FCHandle)hEvent
{
	NSNumber* key = [NSNumber numberWithInt:hEvent];
	
	FC_ASSERT(key);
	
	NSString* eventName = [_currentTimedEvents objectForKey:key];
	[_currentTimedEvents removeObjectForKey:key];
	[FlurryAnalytics endTimedEvent:eventName withParameters:nil];
}

@end

#endif // TARGET_OS_IPHONE
