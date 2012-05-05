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
#if 0
#if defined (FC_LUA)

#import <QuartzCore/QuartzCore.h>

#import "FCLua.h"
#import "FCError.h"
#import "FCLuaCommon.h"
#import "FCDebug.h"

void lua_pushvector3f( lua_State* _state, FC::Vector3f& vec )
{
	lua_newtable(_state);
	int top = lua_gettop(_state);
	
	lua_pushnumber(_state, 1);
	lua_pushnumber(_state, vec.x);
	lua_settable(_state, top);
	
	lua_pushnumber(_state, 2);
	lua_pushnumber(_state, vec.y);
	lua_settable(_state, top);
	
	lua_pushnumber(_state, 3);
	lua_pushnumber(_state, vec.z);
	lua_settable(_state, top);
}

FC::Vector2f lua_tovector2f( lua_State* _state )
{
	FC::Vector2f vec;
	
	lua_pushnil(_state);
	
	lua_next(_state, -2);
	
	FC_ASSERT(lua_type(_state, -1) == LUA_TNUMBER);
	vec.x = lua_tonumber(_state, -1);
	lua_pop(_state, 1);
	
	lua_next(_state, -2);
	FC_ASSERT(lua_type(_state, -1) == LUA_TNUMBER);
	vec.y = lua_tonumber(_state, -1);
	lua_pop(_state, 1);
	
	return vec;
}

FC::Vector3f lua_tovector3f( lua_State* _state )
{
	FC::Vector3f vec;
	
	lua_pushnil(_state);
	
	lua_next(_state, -2);
	FC_ASSERT(lua_type(_state, -1) == LUA_TNUMBER);
	vec.x = lua_tonumber(_state, -1);
	lua_pop(_state, 1);
	
	lua_next(_state, -2);
	FC_ASSERT(lua_type(_state, -1) == LUA_TNUMBER);
	vec.y = lua_tonumber(_state, -1);
	lua_pop(_state, 1);

	lua_next(_state, -2);
	FC_ASSERT(lua_type(_state, -1) == LUA_TNUMBER);
	vec.z = lua_tonumber(_state, -1);
	lua_pop(_state, 1);

	return vec;
}

FC::Color4f lua_tocolor4f( lua_State* _state )
{
	FC::Color4f color;

	lua_pushnil(_state);
	
	lua_next(_state, -2);
	FC_ASSERT(lua_type(_state, -1) == LUA_TNUMBER);
	color.r = lua_tonumber(_state, -1);
	lua_pop(_state, 1);
	
	lua_next(_state, -2);
	FC_ASSERT(lua_type(_state, -1) == LUA_TNUMBER);
	color.g = lua_tonumber(_state, -1);
	lua_pop(_state, 1);
	
	lua_next(_state, -2);
	FC_ASSERT(lua_type(_state, -1) == LUA_TNUMBER);
	color.b = lua_tonumber(_state, -1);
	lua_pop(_state, 1);
	
	lua_next(_state, -2);
	FC_ASSERT(lua_type(_state, -1) == LUA_TNUMBER);
	color.a = lua_tonumber(_state, -1);
	lua_pop(_state, 1);

	return color;
}

static unsigned int common_newThread( lua_State* _state )
{
	static int s_recurseCount = 0;
	
	s_recurseCount++;

	if (s_recurseCount > 100) {
		FC_FATAL("Recursive Lua thread creation - try inserting FCWait(0)");
	}
	
	FCLua* fcLua = [FCLua instance];

	if ([fcLua.threadsDict count] > 1024) {
		FC_FATAL("Too many Lua threads");
	}
	
	FCHandle handle = NewFCHandle();
	
	FCLuaThread* thread = [[FCLuaThread alloc] initFromState:_state withId:handle];
	
	[fcLua.threadsDict setObject:thread forKey:[NSNumber numberWithUnsignedInt:handle]];
	
	[thread resume];
	
	s_recurseCount--;
	
	return thread.threadId;
}

#pragma mark - Lua Functions

static int lua_NewThread( lua_State* _state )
{
	FC_LUA_ASSERT_TYPE(1, LUA_TFUNCTION);
	
	if (lua_isfunction(_state, 1))
	{
		unsigned int threadId = common_newThread( _state );

		lua_settop( _state, 0 );
		
		lua_pushinteger( _state, threadId );
		return 1;
	}
	FC_FATAL("Creating thread from not a string");
	return 0;
}

static int lua_WaitThread( lua_State* _state )
{
	FC_LUA_ASSERT_NUMPARAMS(1);
	FC_LUA_ASSERT_TYPE(1, LUA_TNUMBER);
	
	// find thread with this state
	FCLua* instance = [FCLua instance];
	NSArray* keys = [instance.threadsDict allKeys];
	for( id key in keys )
	{
		FCLuaThread* thread = [instance.threadsDict objectForKey:key];
		if (_state == thread.luaState) {
			double time = lua_tonumber(_state, 1);
			[thread pauseRealTime:time];
			int yieldVal = lua_yield(_state, 0);
			return yieldVal;
		}
	}
	FC_FATAL("Cannot find thread");
	return 0;
}

static int lua_WaitGameThread( lua_State* _state )
{
	FC_LUA_ASSERT_NUMPARAMS(1);
	FC_LUA_ASSERT_TYPE(1, LUA_TNUMBER);
	
	// find thread with this state
	FCLua* instance = [FCLua instance];
	NSArray* keys = [instance.threadsDict allKeys];
	for( id key in keys )
	{
		FCLuaThread* thread = [instance.threadsDict objectForKey:key];
		if (_state == thread.luaState) {
			double time = lua_tonumber(_state, 1);
			[thread pauseGameTime:time];
			int yieldVal = lua_yield(_state, 0);
			return yieldVal;
		}
	}
	FC_FATAL("Cannot find thread");
	return 0;
}

static int lua_KillThread( lua_State* _state )
{
	FC_LUA_ASSERT_NUMPARAMS(1);
	FC_LUA_ASSERT_TYPE(1, LUA_TNUMBER);
	
	if (!lua_isnumber(_state, -1)) {
		FC_FATAL("Trying to pass a non-number to thread kill");
	}
	int killid = (int)lua_tointeger(_state, -1);
	
	FCLua* instance = [FCLua instance];

	NSNumber* key = [NSNumber numberWithInt:killid];

	FCLuaThread* thread = [instance.threadsDict objectForKey:key];

	if (thread) {
		[thread die];
	} else
	{
		FC_WARNING("Trying to kill non-existent Lua thread");
	}
	return 0;
}

static int lua_PrintStats( lua_State* _state )
{
	FC_LUA_ASSERT_NUMPARAMS(0);
	
	[[FCLua instance] printStats];
	return 0;
}

static int lua_Log( lua_State* _state )
{
	FC_LUA_ASSERT_NUMPARAMS(1);
	FC_LUA_ASSERT_TYPE(1, LUA_TSTRING);
	FC_LOG(lua_tostring(_state, 1));
	return 0;
}

static int lua_Warning( lua_State* _state )
{
	FC_LUA_ASSERT_NUMPARAMS(1);
	FC_LUA_ASSERT_TYPE(1, LUA_TSTRING);
	FC_WARNING(lua_tostring(_state, 1));
	return 0;
}

static int lua_Fatal( lua_State* _state )
{
	FC_LUA_ASSERT_NUMPARAMS(1);
	FC_LUA_ASSERT_TYPE(1, LUA_TSTRING);
	FC_FATAL(lua_tostring(_state, 1));
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
@synthesize perfCounter = m_perfCounter;
@synthesize maxCPUTime = _maxCPUTime;
@synthesize avgCount = _avgCount;
@synthesize avgCPUTime = _avgCPUTime;

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
		
	m_perfCounter->Zero();
	
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
	
	float millisecs = m_perfCounter->MilliValue();
	
	if (millisecs > _maxCPUTime) {
		_maxCPUTime = millisecs;
	}
	_avgCPUTime += millisecs;
	_avgCount++;
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
		[m_coreVM registerCFunction:lua_Log as:@"FCLog"];
		[m_coreVM registerCFunction:lua_Warning as:@"FCWarning"];
		[m_coreVM registerCFunction:lua_Fatal as:@"FCFatal"];
		
		[m_coreVM createGlobalTable:@"FCLua"];
		[m_coreVM registerCFunction:lua_PrintStats as:@"FCLua.PrintStats"];
		
		m_perfCounter = new FCPerformanceCounter;
		
		_maxCPUTime = 0.0f;
		_avgCPUTime = 0.0f;
		_avgCount = 0;
	}
	return self;
}

-(void)executeLine:(NSString *)line
{
	[m_coreVM executeLine:line];
}

-(void)printStats
{
	FC_LOG("---FCLua Stats--- To be done !");
//	FC_LOG( std::string("Num threads: ") + [NSNumber numberWithInt:[_threadsDict count]] );
//	FC_LOG(@"Threads: %@", _threadsDict);
//	FC_LOG(@"Memory: %@ allocs", [NSNumber numberWithInt:[FCLuaMemory instance].numAllocs] );
//	FC_LOG(@"Memory: %@ bytes", [NSNumber numberWithInt:[FCLuaMemory instance].totalMemory] );
//	FC_LOG(@"CPU: %@ max", [NSNumber numberWithFloat:_maxCPUTime] );
//	FC_LOG(@"CPU: %@ avg", [NSNumber numberWithFloat:_avgCPUTime / _avgCount] );
}

-(void)dealloc
{
	_threadsDict = nil;
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
#endif
