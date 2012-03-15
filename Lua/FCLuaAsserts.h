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

#ifndef CR1_FCLuaAsserts_h
#define CR1_FCLuaAsserts_h

#if defined(DEBUG)

#define FC_LUA_ASSERT_TYPE( stackpos, type )	\
{							\
	if( lua_type( _state, stackpos ) != type )	\
	{	\
		NSString* error = [NSString stringWithFormat:@"LUA (%s): Wrong type at assert, wanted %s, but found %s", __FUNCTION__, lua_typename( _state, type), lua_typename( _state, lua_type( _state, stackpos))];	\
		FC_LOG(error);	\
		FCLua_DumpStack( _state );	\
		return 0;	\
	}	\
}

#define FC_LUA_ASSERT_NUMPARAMS( n )	\
{										\
	if( lua_gettop( _state ) != n )		\
	{									\
		NSString* error = [NSString stringWithFormat:@"LUA (%s): Wrong number of paramaters. Expected %d but received %d", __FUNCTION__, n, lua_gettop( _state )];	\
		FC_LOG(error);	\
		FCLua_DumpStack( _state );		\
		return 0;	\
	}			\
}

#else

#define FC_LUA_ASSERT_TYPE(stackpos, type){}
#define FC_LUA_ASSERT_NUMPARAMS( n ){}

#endif	// DEBUG

#endif
