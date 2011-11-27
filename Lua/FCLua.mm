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

#import <QuartzCore/QuartzCore.h>

#import "FCLua.h"
#import "FCError.h"
#import "FCLuaCommon.h"
#import "Debug/FCDebug.h"

unsigned int common_newThreadWithVoidFunction( const char* function )
{
	FCLua* fcLua = [FCLua instance];
	
	FCLuaThread* thread = [[FCLuaThread alloc] initFromState:[[FCLua instance] coreVM].state withId:fcLua.nextThreadId];
	
	[fcLua.threadsDict setObject:thread forKey:[NSNumber numberWithUnsignedInt:fcLua.nextThreadId]];
	
	[fcLua incrementNextThreadId];
	
	[thread runVoidFunction:[NSString stringWithCString:function encoding:NSUTF8StringEncoding]];
	
	return thread.threadId;
}

#pragma mark - Lua Functions

int Lua_NewThread( lua_State* state )
{
	// TODO - handle passing function as arg instead of string
	
	if (lua_isstring(state, 1)) 
	{
		const char* function = lua_tostring(state, -1);
		lua_pop(state, 1);
		
		unsigned int threadId = common_newThreadWithVoidFunction( function );

		lua_pushinteger( state, threadId );
		return 1;
	}
	FC_FATAL(@"Creating thread from not a string");
	return 0;
}

int Lua_WaitThread( lua_State* state )
{
	// find thread with this state
	FCLua* instance = [FCLua instance];
	NSArray* keys = [instance.threadsDict allKeys];
	for( id key in keys )
	{
		FCLuaThread* thread = [instance.threadsDict objectForKey:key];
		if (state == thread.luaState) {
			double time = lua_tonumber(state, 1);
			[thread pause:time];
			int yieldVal = lua_yield(state, 0);
			return yieldVal;
		}
	}
	FC_FATAL(@"Cannot find thread");
	return 0;
}

int Lua_KillThread( lua_State* state )
{
	FCLua* instance = [FCLua instance];
	NSArray* keys = [instance.threadsDict allKeys];
	for( id key in keys )
	{
		FCLuaThread* thread = [instance.threadsDict objectForKey:key];
		if (state == thread.luaState) {
			[thread die];
//			double time = lua_tonumber(state, 1);
//			[thread pause:time];
//			int yieldVal = lua_yield(state, 0);
//			return yieldVal;
		}
	}
	FC_FATAL(@"Cannot find thread");

	return 0;
}


#pragma mark - FCLua Private Interface

@interface FCLua() {
	FCLuaVM*				m_coreVM;
	FCPerformanceCounter*	m_perfCounter;
	CADisplayLink*			m_displayLink;
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

-(void)updateThreads
{
	NSLog(@"%d %d", [self.threadsDict count], _nextThreadId);
	float dt = (float)[m_perfCounter secondsValue];
	[m_perfCounter zero];
	
	// update threads
	NSArray* keys = [self.threadsDict allKeys];
	for( id key in keys ) 
	{
		FCLuaThread* thread = [self.threadsDict objectForKey:key];
		[thread update:dt];
		if (thread.state == kLuaThreadStateDead) {
			[self.threadsDict removeObjectForKey:key];
			[thread release];
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
		[m_coreVM loadScript:@"util"];
		
		// register core API
		[m_coreVM registerCFunction:Lua_NewThread as:@"FCNewThread"];
		[m_coreVM registerCFunction:Lua_WaitThread as:@"FCWait"];
		[m_coreVM registerCFunction:Lua_KillThread as:@"FCKillThread"];
		
		_nextThreadId = 1;

		m_perfCounter = [[FCPerformanceCounter alloc] init];
		
		// setup display link
		
		m_displayLink = [[CADisplayLink displayLinkWithTarget:self selector:@selector(updateThreads)] retain];
		[m_displayLink setFrameInterval:1];
		[m_displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];

	}
	return self;
}

-(void)dealloc
{
	[m_displayLink invalidate];
	[m_coreVM release];
	[_threadsDict release], _threadsDict = nil;
	[m_perfCounter release];
	[super dealloc];
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

-(unsigned int)newThreadWithVoidFunction:(NSString*)function
{
	return common_newThreadWithVoidFunction( [function cStringUsingEncoding:NSUTF8StringEncoding] );
}

@end
