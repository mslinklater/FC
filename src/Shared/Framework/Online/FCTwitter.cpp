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

#include "FCTwitter.h"
#include "Shared/Lua/FCLua.h"
#include "FCOnline_platform.h"

static FCTwitter* s_pInstance = 0;

static int lua_CanTweet( lua_State* _state )
{
	FC_LUA_ASSERT_NUMPARAMS(0);
	
	lua_pushboolean(_state, s_pInstance->CanTweet() );
	
	return 1;
}

static int lua_TweetWithText( lua_State* _state )
{
	FC_LUA_ASSERT_NUMPARAMS(1);
	FC_LUA_ASSERT_TYPE(1, LUA_TSTRING);
	
	std::string text = lua_tostring(_state, 1);
	
	lua_pushboolean(_state, s_pInstance->TweetWithText( text ));
	
	return 1;
}

static int lua_AddHyperlink( lua_State* _state )
{
	FC_LUA_ASSERT_NUMPARAMS(1);
	FC_LUA_ASSERT_TYPE(1, LUA_TSTRING);
	
	std::string hyperlink = lua_tostring(_state, 1);
	
	lua_pushboolean(_state, s_pInstance->AddHyperlink(hyperlink));
	
	return 1;
}

static int lua_Send( lua_State* _state )
{
	FC_LUA_ASSERT_NUMPARAMS(0);
	s_pInstance->Send();
	return 0;
}

FCTwitter::FCTwitter()
{
	FCLua::Instance()->CoreVM()->CreateGlobalTable("FCTwitter");
	FCLua::Instance()->CoreVM()->RegisterCFunction(lua_CanTweet, "FCTwitter.CanSendTweet");
	FCLua::Instance()->CoreVM()->RegisterCFunction(lua_TweetWithText, "FCTwitter.TweetWithText");
	FCLua::Instance()->CoreVM()->RegisterCFunction(lua_AddHyperlink, "FCTwitter.AddHyperlink");
	FCLua::Instance()->CoreVM()->RegisterCFunction(lua_Send, "FCTwitter.Send");
}

FCTwitter::~FCTwitter()
{
	
}

FCTwitter* FCTwitter::Instance()
{
	if (!s_pInstance) {
		s_pInstance = new FCTwitter;
	}
	return s_pInstance;
}

bool FCTwitter::CanTweet()
{
	return plt_FCTwitter_CanTweet();
}

bool FCTwitter::TweetWithText( std::string text )
{
	return plt_FCTwitter_TweetWithText( text.c_str() );
}

bool FCTwitter::AddHyperlink( std::string hyperlink )
{
	return plt_FCTwitter_AddHyperlink( hyperlink.c_str() );
}

void FCTwitter::Send()
{
	plt_FCTwitter_Send();
}
