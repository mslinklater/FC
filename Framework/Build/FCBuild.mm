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

#import "FCBuild.h"

#if defined (FC_LUA)
#import "FCLua.h"
#endif

#pragma mark - Lua methods
#if defined (FC_LUA)

static int lua_Debug( lua_State* _state )
{
	FC_LUA_ASSERT_NUMPARAMS(0);
#if DEBUG
	lua_pushboolean(_state, 1);
#else
	lua_pushboolean(_state, 0);
#endif
	
	return 1;
}

#endif

#pragma mark - Obj-C

@implementation FCBuild

#if defined (FC_LUA)
+(void)registerLuaFunctions:(FCLuaVM*)lua
{
//	[lua createGlobalTable:@"FCBuild"];
	lua->CreateGlobalTable("FCBuild");
//	[lua registerCFunction:lua_Debug as:@"FCBuild.Debug"];
	lua->RegisterCFunction(lua_Debug, "FCBuild.Debug");
}
#endif
@end

