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

#include "FCOnlineLeaderboard.h"
#include "Shared/Lua/FCLua.h"
#include "Shared/Framework/FCPersistentData.h"

static FCOnlineLeaderboard* s_pInstance = 0;

// Lua Interface

static int lua_Available( lua_State* _state )
{
	FC_LUA_FUNCDEF("FCOnlineLeaderboard.Available()");
    FC_LUA_ASSERT_NUMPARAMS(0);
    
    if ( s_pInstance->Available() ) {
        lua_pushboolean( _state, 1 );
    } else {
        lua_pushboolean( _state, 0 );
    }
    
    return 1;
}

static int lua_Show( lua_State* _state )
{
	FC_LUA_FUNCDEF("FCOnlineLeaderboard.Show()");
	FC_LUA_ASSERT_NUMPARAMS(0);
    s_pInstance->Show();
    
    return 0;
}

static int lua_PostScore( lua_State* _state )
{
	FC_LUA_FUNCDEF("FCOnlineLeaderboard.PostScore()");
    FC_LUA_ASSERT_NUMPARAMS(2);
    FC_LUA_ASSERT_TYPE( 1, LUA_TSTRING );
    FC_LUA_ASSERT_TYPE( 2, LUA_TNUMBER );
    
    s_pInstance->PostScore( lua_tostring(_state, 1), lua_tointeger(_state, 2));
    
    return 0;
}

//static int lua_CheckForStoredScore( lua_State* _state )
//{
//	FC_LUA_FUNCDEF("FCOnlineLeaderboard.CheckForStoredScore()");
//    FC_LUA_ASSERT_NUMPARAMS(1);
//    FC_LUA_ASSERT_TYPE(1, LUA_TSTRING);
//    
//    s_pInstance->CheckForStoredScore( lua_tostring(_state, 1) );
//    return 0;
//}

// Impl

FCOnlineLeaderboard* FCOnlineLeaderboard::Instance()
{
    if( !s_pInstance ) {
        s_pInstance = new FCOnlineLeaderboard;
    }
    return s_pInstance;
}

FCOnlineLeaderboard::FCOnlineLeaderboard()
{
    // register Lua functions
    
    FCLua::Instance()->CoreVM()->CreateGlobalTable("FCOnlineLeaderboard" );
    FCLua::Instance()->CoreVM()->RegisterCFunction(lua_Available, "FCOnlineLeaderboard.Available");
    FCLua::Instance()->CoreVM()->RegisterCFunction(lua_PostScore, "FCOnlineLeaderboard.PostScore");
    FCLua::Instance()->CoreVM()->RegisterCFunction(lua_Show, "FCOnlineLeaderboard.Show");
//    FCLua::Instance()->CoreVM()->RegisterCFunction(lua_CheckForStoredScore, "FCOnlineLeaderboard.CheckForStoredScore");

    // sign in ?
#if defined(FC_ONLINE)
    plt_FCOnlineLeaderboard_Init();
#endif
}

FCOnlineLeaderboard::~FCOnlineLeaderboard()
{
    
}

bool FCOnlineLeaderboard::Available()
{
#if defined(FC_ONLINE)
    return plt_FCOnlineLeaderboard_Available();
#else
	return false;
#endif
}

void FCOnlineLeaderboard::Show()
{
#if defined(FC_ONLINE)
    plt_FCOnlineLeaderboard_Show();
#endif
}

void FCOnlineLeaderboard::PostScore( std::string leaderboardName, unsigned int score )
{
#if defined(FC_ONLINE)
	plt_FCOnlineLeaderboard_PostScore( leaderboardName.c_str(), score );
#endif
}
