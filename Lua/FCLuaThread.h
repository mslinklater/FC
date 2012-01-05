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

#import <Foundation/Foundation.h>
#import "FCLuaVM.h"

enum eLuaThreadState {
	kLuaThreadStateNew,
	kLuaThreadStateRunning,
	kLuaThreadStateSleeping,
	kLuaThreadStateDying,
	kLuaThreadStateDead
};

@interface FCLuaThread : NSObject {
	eLuaThreadState	_state;
	double			_sleepTimeRemaining;
	unsigned int	_threadId;
	lua_State*		_luaState;
}
@property(nonatomic, readonly) eLuaThreadState state;
@property(nonatomic, readonly) double sleepTimeRemaining;
@property(nonatomic, readonly) unsigned int threadId;
@property(nonatomic, readonly) lua_State* luaState;

-(id)initFromState:(lua_State*)state withId:(unsigned int)threadId;
-(void)runVoidFunction:(NSString*)function;
-(void)update:(float)dt;
-(void)pause:(float)seconds;
-(void)die;

@end
