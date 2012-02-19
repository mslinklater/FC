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

#if defined (FC_LUA)

#import <QuartzCore/QuartzCore.h>

#import "FCLua.h"
#import "FCError.h"
#import "FCLuaCommon.h"
#import "FCDebug.h"

static unsigned int common_newThread( lua_State* _state )
{
	static int s_recurseCount = 0;
	
	s_recurseCount++;

	if (s_recurseCount > 100) {
		FC_FATAL(@"Recursive Lua thread creation - try inserting FCWait(0)");
	}
	
	FCLua* fcLua = [FCLua instance];

	if ([fcLua.threadsDict count] > 1024) {
		FC_FATAL(@"Too many Lua threads");
	}
	
	FCLuaThread* thread = [[FCLuaThread alloc] initFromState:_state withId:fcLua.nextThreadId];
	
	[fcLua.threadsDict setObject:thread forKey:[NSNumber numberWithUnsignedInt:fcLua.nextThreadId]];
	
	[fcLua incrementNextThreadId];
	
	[thread resume];
	
	s_recurseCount--;
	
	return thread.threadId;
}

#pragma mark - Lua Functions

static int lua_NewThread( lua_State* _state )
{
	if (lua_isfunction(_state, 1))
	{
		unsigned int threadId = common_newThread( _state );

		lua_settop( _state, 0 );
		
		lua_pushinteger( _state, threadId );
		return 1;
	}
	FC_FATAL(@"Creating thread from not a string");
	return 0;
}

static int lua_WaitThread( lua_State* state )
{
	// find thread with this state
	FCLua* instance = [FCLua instance];
	NSArray* keys = [instance.threadsDict allKeys];
	for( id key in keys )
	{
		FCLuaThread* thread = [instance.threadsDict objectForKey:key];
		if (state == thread.luaState) {
			double time = lua_tonumber(state, 1);
			[thread pauseRealTime:time];
			int yieldVal = lua_yield(state, 0);
			return yieldVal;
		}
	}
	FC_FATAL(@"Cannot find thread");
	return 0;
}

static int lua_WaitGameThread( lua_State* state )
{
	// find thread with this state
	FCLua* instance = [FCLua instance];
	NSArray* keys = [instance.threadsDict allKeys];
	for( id key in keys )
	{
		FCLuaThread* thread = [instance.threadsDict objectForKey:key];
		if (state == thread.luaState) {
			double time = lua_tonumber(state, 1);
			[thread pauseGameTime:time];
			int yieldVal = lua_yield(state, 0);
			return yieldVal;
		}
	}
	FC_FATAL(@"Cannot find thread");
	return 0;
}

static int lua_KillThread( lua_State* state )
{
	if (!lua_isnumber(state, -1)) {
		FC_FATAL(@"Trying to pass a non-number to thread kill");
	}
	int killid = (int)lua_tointeger(state, -1);
	
	FCLua* instance = [FCLua instance];

	NSNumber* key = [NSNumber numberWithInt:killid];

	FCLuaThread* thread = [instance.threadsDict objectForKey:key];

	if (thread) {
		[thread die];
	} else
	{
		FC_WARNING(@"Trying to kill non-existent Lua thread");
	}
	return 0;
}


#pragma mark - FCLua Private Interface

@interface FCLua() {
	FCLuaVM*				m_coreVM;
}
@end

#pragma mark - FCLua Implementation

@implementation FCLua
@synthesize threadsDict = _threadsDict;
@synthesize nextThreadId = _nextThreadId;

#pragma mark - Class methods

+(FCLua*)instance
{
	static FCLua* pInstance = nil;
	if (!pInstance) {
		pInstance = [[FCLua alloc] init];
	}
	return pInstance;
}

-(void)updateThreadsRealTime:(float)dt gameTime:(float)gt
{
	// check for stack crawl
	
	// update threads
	NSArray* keys = [self.threadsDict allKeys];
	for( id key in keys ) 
	{
		FCLuaThread* thread = [self.threadsDict objectForKey:key];
		
		[thread updateRealTime:dt gameTime:gt];
		
		if (thread.state == kLuaThreadStateDead) {
			[self.threadsDict removeObjectForKey:key];
		}
	}
}

#pragma mark Object Lifecycle

-(id)init
{
	self = [super init];
	if (self) {
		_threadsDict = [[NSMutableDictionary alloc] init];
		
		// create global thread table

		m_coreVM = [[FCLuaVM alloc] init];
		[m_coreVM addStandardLibraries];
		
#if defined (DEBUG)
		lua_pushboolean([m_coreVM state], 1);
#else
		lua_pushboolean([m_coreVM state], 0);
#endif
		lua_setglobal([m_coreVM state], "DEBUG");
		
		[m_coreVM loadScript:@"fc_core"];		

		// register core API
		[m_coreVM registerCFunction:lua_NewThread as:@"FCNewThread"];
		[m_coreVM registerCFunction:lua_WaitThread as:@"FCWait"];
		[m_coreVM registerCFunction:lua_WaitGameThread as:@"FCWaitGame"];
		[m_coreVM registerCFunction:lua_KillThread as:@"FCKillThread"];
		
		_nextThreadId = 1;
	}
	return self;
}

-(void)executeLine:(NSString *)line
{
	[m_coreVM executeLine:line];
}

-(void)dealloc
{
	_threadsDict = nil;
}

-(void)incrementNextThreadId
{
	_nextThreadId++;
}

#pragma mark - VM

-(FCLuaVM*)coreVM
{
	return m_coreVM;
}

-(FCLuaVM*)newVM
{
	return [[FCLuaVM alloc] init];
}

#pragma mark - Threads

@end

#endif // defined(FC_LUA)
