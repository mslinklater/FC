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

#import "FCLua.h"
#import "Debug/FCDebug.h"

#pragma mark - Lua Functions

int Lua_NewThread( lua_State* state )
{
	return 0;
}

int Lua_WaitThread( lua_State* state )
{
	return 0;
}

int Lua_KillThread( lua_State* state )
{
	return 0;
}

int Lua_LoadFile( lua_State* state )
{
	return 0;
}

#pragma mark - FCLua Private Interface

@interface FCLua() {
	FCLuaVM*				m_coreVM;
	unsigned int			m_nextThreadId;
	FCPerformanceCounter*	m_perfCounter;
}
@end

#pragma mark - FCLua Implementation

@implementation FCLua
@synthesize threads = _threads;

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
	float dt = (float)[m_perfCounter secondsValue];
	[m_perfCounter zero];
	
	// update threads
	for( FCLuaThread* thread in self.threads ) 
	{
		[thread update:dt];
	}
}

#pragma mark Object Lifecycle

-(id)init
{
	self = [super init];
	if (self) {
		_threads = [[NSMutableDictionary alloc] init];
		m_coreVM = [[FCLuaVM alloc] init];
		[m_coreVM addStandardLibraries];
		[m_coreVM loadFileFromMainBundle:@"util"];
		
		// register core API
		[m_coreVM registerCFunction:Lua_NewThread as:@"NewThread"];
		[m_coreVM registerCFunction:Lua_WaitThread as:@"Wait"];
		[m_coreVM registerCFunction:Lua_KillThread as:@"KillThread"];
		[m_coreVM registerCFunction:Lua_LoadFile as:@"LoadScript"];
		
		m_nextThreadId = 1;

		m_perfCounter = [[FCPerformanceCounter alloc] init];
	}
	return self;
}

-(void)dealloc
{
	[m_coreVM release];
	[_threads release], _threads = nil;
	[m_perfCounter release];
	[super dealloc];
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

-(FCLuaThread*)newThreadWithVoidFunction:(NSString*)function
{
	FCLuaThread* thread = [[FCLuaThread alloc] initFromState:m_coreVM.state withId:m_nextThreadId];
	[_threads setObject:thread forKey:[NSNumber numberWithUnsignedInt:m_nextThreadId]];
	m_nextThreadId++;
	[thread runVoidFunction:function];
	return thread;
}

@end
