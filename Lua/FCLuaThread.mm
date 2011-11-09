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

#import "FCLuaThread.h"
#import "FCError.h"

//extern "C" {
//#include "lua.h"
//}

@interface FCLuaThread() {
	lua_State*	m_luaState;
}
@end

@implementation FCLuaThread
@synthesize state = _state;
@synthesize sleepTimeRemaining = _sleepTimeRemaining;
@synthesize threadId = _threadId;
@synthesize paused = _paused;

-(id)initFromState:(lua_State *)state withId:(unsigned int)threadId
{
	self = [super init];
	if (self) {
		m_luaState = lua_newthread(state);
		_state = kLuaThreadStateSleeping;
		_sleepTimeRemaining = 0.0;
		_threadId = threadId;
		self.paused = NO;
	}
	return self;
}

-(void)dealloc
{
	[super dealloc];
}

-(void)runVoidFunction:(NSString *)function
{
	lua_getglobal(m_luaState, [function UTF8String]);
	if (lua_isnil(m_luaState, -1)) {
		FC_FATAL1(@"Unknown Lua function", function);
	}
	int ret = lua_resume(m_luaState , 0);
	switch (ret) {
		case 0:
			break;
		case LUA_YIELD:
			break;
		case LUA_ERRRUN:
			break;
		case LUA_ERRSYNTAX:
			break;
		case LUA_ERRMEM:
			break;
		case LUA_ERRERR:
			break;
		default:
			break;
	}
}

-(void)update:(float)dt
{
	if (self.paused) {
		return;
	}

	switch (self.state) {
		case kLuaThreadStateNew:
			break;
		case kLuaThreadStateRunning:
			break;
		case kLuaThreadStateSleeping:
			break;
		case kLuaThreadStateDead:
			break;			
	}
}

@end
