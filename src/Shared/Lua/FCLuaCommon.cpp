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

#include "FCLuaCommon.h"

#include "Shared/Core/FCError.h"

void FCLua_DumpStack( lua_State* _state )
{
	FC_LOG( "-- FCLuaVM:dumpStack --" );
	int i;
	int top = lua_gettop(_state);
	for( i = 1 ; i <= top ; i++ )
	{
		int t = lua_type(_state, i);
		int negIndex = -(top - i) -1;
		FC_UNUSED(negIndex);
		std::stringstream ss;
		switch(t)
		{
			case LUA_TSTRING:
				ss << "(" << i << "/" << negIndex << std::string(") string ") + lua_tostring(_state, i);
				break;
			case LUA_TBOOLEAN:
				ss << "(" << i << "/" << negIndex << std::string(") boolean ") + (lua_toboolean(_state, i) ? "true" : "false");
				break;
			case LUA_TNUMBER:
				ss << "(" << i << "/" << negIndex << std::string(") number ") << lua_tonumber(_state, i);
				break;
			case LUA_TLIGHTUSERDATA:
				ss << "(" << i << "/" << negIndex << std::string(") userdata");
				break;
			default:
				ss << "(" << i << "/" << negIndex << std::string(")") << lua_typename(_state, t);
				break;
		}
		FC_LOG( ss.str() );
	}
}

double FCLua_GetTableNumber( lua_State* _state, int stackIdx, const char* name )
{
	lua_getfield(_state, stackIdx, name);

	FC_ASSERT( lua_isnumber(_state, stackIdx) );
	
	double ret = lua_tonumber(_state, stackIdx);
	lua_pop(_state, 1);
	return ret;
}

std::string FCLua_GetTableString( lua_State* _state, int stackIdx, const char* name )
{
	lua_getfield(_state, stackIdx, name);
	
	FC_ASSERT( lua_isstring(_state, stackIdx) );

	std::string ret = lua_tostring(_state, stackIdx);
	lua_pop(_state, 1);
	return ret;
}

bool FCLua_GetTableBool( lua_State* _state, int stackIdx, const char* name )
{
	lua_getfield(_state, stackIdx, name);
	
	FC_ASSERT( lua_isboolean(_state, stackIdx) );

	bool ret = lua_toboolean(_state, stackIdx);
	lua_pop(_state, 1);
	
	return ret;
}

bool FCLua_GetTableIsTable( lua_State* _state, int stackIdx, const char* name )
{
	lua_getfield(_state, stackIdx, name);

	bool ret = lua_istable(_state, stackIdx);
	lua_pop(_state, 1);
	return ret;
}

