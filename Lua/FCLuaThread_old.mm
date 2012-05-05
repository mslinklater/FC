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

#import "FCLuaThread.h"
#import "FCError.h"
#import "FCLuaCommon.h"

extern "C" {
#include "lua.h"
#import "lauxlib.h"
#import "lualib.h"
}

@implementation FCLuaThread
@synthesize state = _state;
@synthesize sleepRealTimeRemaining = _sleepRealTimeRemaining;
@synthesize sleepGameTimeRemaining = _sleepGameTimeRemaining;
@synthesize threadId = _threadId;
@synthesize luaState = _luaState;
@synthesize numResumeArgs = _numResumeArgs;

-(id)initFromState:(lua_State *)state withId:(unsigned int)threadId
{
	self = [super init];
	if (self) {
		_luaState = lua_newthread(state);
		
		char buffer[32];
		sprintf(&buffer[0], "thread%d", threadId);		
		lua_setfield(state, LUA_REGISTRYINDEX, &buffer[0]);
		_state = kLuaThreadStateNew;
		_sleepRealTimeRemaining = 0.0;
		_sleepGameTimeRemaining = 0.0;
		_threadId = threadId;

		_numResumeArgs = lua_gettop(state);	// first one is function name
		
		lua_xmove(state, _luaState, _numResumeArgs);
	}
	return self;
}


-(void)resume
{
	_state = kLuaThreadStateRunning;
	int ret = lua_resume(_luaState , NULL, _numResumeArgs - 1);
	_numResumeArgs = 0;
	switch (ret) {
		case 0:
			_state = kLuaThreadStateDying;
			break;
		case LUA_YIELD:
			break;
		case LUA_ERRRUN:
			FCLua_DumpStack(_luaState);
			FC_FATAL("LUA_ERRRUN");
			break;
		case LUA_ERRSYNTAX:
			FCLua_DumpStack(_luaState);
			FC_FATAL("LUA_ERRSYNTAX");
			break;
		case LUA_ERRMEM:
			FCLua_DumpStack(_luaState);
			FC_FATAL("LUA_ERRMEM");
			break;
		case LUA_ERRERR:
			FCLua_DumpStack(_luaState);
			FC_FATAL("LUA_ERRERR");
			break;
		default:
			break;
	}
}

-(void)updateRealTime:(float)dt gameTime:(float)gt
{
	switch (self.state) {
		case kLuaThreadStateNew:
			break;
		case kLuaThreadStateRunning:
			{
				int ret = lua_resume(_luaState , NULL, 0);
				switch (ret) {
					case 0:
						_state = kLuaThreadStateDying;
						break;
					case LUA_YIELD:
						break;
					case LUA_ERRRUN:
						FCLua_DumpStack(_luaState);
						FC_FATAL("LUA_ERRRUN");
						break;
					case LUA_ERRSYNTAX:
						FCLua_DumpStack(_luaState);
						FC_FATAL("LUA_ERRSYNTAX");
						break;
					case LUA_ERRMEM:
						FCLua_DumpStack(_luaState);
						FC_FATAL("LUA_ERRMEM");
						break;
					case LUA_ERRERR:
						FCLua_DumpStack(_luaState);
						FC_FATAL("LUA_ERRERR");
						break;
					default:
						FC_FATAL("default fallthrough");
						break;
				}
			}
			break;
		case kLuaThreadStateSleeping:
			{
				if (_sleepRealTimeRemaining > 0.0f) {
					_sleepRealTimeRemaining -= dt;
				}
				
				if (_sleepGameTimeRemaining > 0.0f) {
					_sleepGameTimeRemaining -= gt;
				}
				
				if( (_sleepRealTimeRemaining <= 0.0) && (_sleepGameTimeRemaining <= 0.0)){
					_state = kLuaThreadStateRunning;
					[self updateRealTime:dt gameTime:gt];
				}
			}
			break;
		case kLuaThreadStateDying:
			_state = kLuaThreadStateDead;
			lua_pushnil(_luaState);
			char buffer[32];
			sprintf(&buffer[0], "thread%d", _threadId);		
			lua_setfield(_luaState, LUA_REGISTRYINDEX, &buffer[0]);			
			break;
		case kLuaThreadStateDead:
			break;			
	}
//	lua_gc( _luaState, LUA_GCCOLLECT, 0 );

}

-(void)die
{
	_state = kLuaThreadStateDying;
}

-(void)pauseRealTime:(float)seconds
{
	_sleepRealTimeRemaining += (float)seconds;
	_state = kLuaThreadStateSleeping;
}

-(void)pauseGameTime:(float)seconds
{
	_sleepGameTimeRemaining += (float)seconds;
	_state = kLuaThreadStateSleeping;
}

-(NSString*)description
{
	switch (_state) {
		case kLuaThreadStateDead:
			return @"Dead";
			break;
		case kLuaThreadStateDying:
			return @"Dying";
			break;
		case kLuaThreadStateNew:
			return @"New";
			break;
		case kLuaThreadStateRunning:
			return @"Running";
			break;
		case kLuaThreadStateSleeping:
			return @"Sleeping";
			break;
			
		default:
			break;
	}
}

@end

#endif // defined(FC_LUA)
#endif