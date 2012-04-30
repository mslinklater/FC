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

#if defined(FC_LUA)

#import <Foundation/Foundation.h>

#import "FCCore.h"
#import "FCLuaVM.h"
#import "FCLuaThread.h"
#import "FCLuaClass.h"
#import "FCLuaCommon.h"
#import "FCLuaMemory.h"
#import "FCLuaAsserts.h"

// Some helpers, which should probably be moved out

void lua_pushvector3f( lua_State* _state, FC::Vector3f& vec );
FC::Vector2f lua_tovector2f( lua_State* _state );
FC::Vector3f lua_tovector3f( lua_State* _state );
FC::Color4f lua_tocolor4f( lua_State* _state );

@interface FCLua : NSObject {
	NSMutableDictionary*	_threadsDict;
	
	FCPerformanceCounterPtr	m_perfCounter;
	float					_maxCPUTime;
	float					_avgCPUTime;
	int						_avgCount;
}
@property(nonatomic, readonly) NSMutableDictionary* threadsDict;
@property(nonatomic) FCPerformanceCounterPtr perfCounter;
@property(nonatomic) float maxCPUTime;
@property(nonatomic) float avgCPUTime;
@property(nonatomic) int avgCount;

+(FCLua*)instance;

-(void)updateThreadsRealTime:(float)dt gameTime:(float)dt;

-(FCLuaVM*)coreVM;
-(FCLuaVM*)newVM;

-(void)executeLine:(NSString*)line;
-(void)printStats;

@end

#endif // defined(FC_LUA)
