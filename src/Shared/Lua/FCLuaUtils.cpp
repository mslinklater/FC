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

#include "FCLuaUtils.h"
#include "FCLuaAsserts.h"

FCColor4f ColorFromLuaColor( lua_State* _state, int stackPos )
{
	FC_LUA_FUNCDEF("C - ColorFromLuaColor");
	lua_getfield(_state, 2, "r");
	FC_LUA_ASSERT_TYPE(-1, LUA_TNUMBER);
	float r = (float)lua_tonumber(_state, -1);
	lua_pop(_state, 1);
	
	lua_getfield(_state, 2, "g");
	FC_LUA_ASSERT_TYPE(-1, LUA_TNUMBER);
	float g = (float)lua_tonumber(_state, -1);
	lua_pop(_state, 1);
	
	lua_getfield(_state, 2, "b");
	FC_LUA_ASSERT_TYPE(-1, LUA_TNUMBER);
	float b = (float)lua_tonumber(_state, -1);
	lua_pop(_state, 1);
	
	lua_getfield(_state, 2, "a");
	FC_LUA_ASSERT_TYPE(-1, LUA_TNUMBER);
	float a = (float)lua_tonumber(_state, -1);

	return FCColor4f(r, g, b, a);
}
