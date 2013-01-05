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

#include "FCAudioManager.h"
#include "Shared/Lua/FCLua.h"
#include "Shared/FCPlatformInterface.h"

static FCAudioManager* s_pInstance;

static int lua_PlayMusic( lua_State* _state )
{
	FC_LUA_FUNCDEF("FCAudio.PlayMusic()");
	FC_LUA_ASSERT_NUMPARAMS( 1 );
	FC_LUA_ASSERT_TYPE( 1, LUA_TSTRING );
	
	plt_FCAudio_PlayMusic(lua_tostring(_state, 1));
	return 0;
}

static int lua_SetMusicVolume( lua_State* _state )
{
	FC_LUA_FUNCDEF("FCAudio.SetMusicVolume()");
	FC_LUA_ASSERT_NUMPARAMS(1);
	FC_LUA_ASSERT_TYPE(1, LUA_TNUMBER);
	
	plt_FCAudio_SetMusicVolume( (float)lua_tonumber(_state, 1) );
	
	return 0;
}

static int lua_SetSFXVolume( lua_State* _state )
{
	FC_LUA_FUNCDEF("FCAudio.SetSFXVolume()");
	FC_LUA_ASSERT_NUMPARAMS(1);
	FC_LUA_ASSERT_TYPE(1, LUA_TNUMBER);
	
	plt_FCAudio_SetSFXVolume( (float)lua_tonumber(_state, 1) );
	
	return 0;
}

static int lua_SetMusicFinishedCallback( lua_State* _state )
{
	FC_LUA_FUNCDEF("FCAudio.SetMusicFinishedCallback()");
	FC_LUA_ASSERT_NUMPARAMS(1);
	FC_LUA_ASSERT_TYPE(1, LUA_TSTRING);

	plt_FCAudio_SetMusicFinishedCallback( lua_tostring(_state, 1) );
	
	return 0;
}

static int lua_PauseMusic( lua_State* _state )
{
	FC_LUA_FUNCDEF("FCAudio.PauseMusic()");
	FC_LUA_ASSERT_NUMPARAMS(0);
	plt_FCAudio_PauseMusic();
	return 0;
}

static int lua_ResumeMusic( lua_State* _state )
{
	FC_LUA_FUNCDEF("FCAudio.ResumeMusic()");
	FC_LUA_ASSERT_NUMPARAMS(0);
	plt_FCAudio_ResumeMusic();
	return 0;
}

static int lua_StopMusic( lua_State* _state )
{
	FC_LUA_FUNCDEF("FCAudio.StopMusic()");
	FC_LUA_ASSERT_NUMPARAMS(0);
	plt_FCAudio_StopMusic();
	return 0;
}

static int lua_DeleteBuffer( lua_State* _state )
{
	FC_LUA_FUNCDEF("FCAudio.DeleteBuffer()");
	FC_LUA_ASSERT_NUMPARAMS(1);
	FC_LUA_ASSERT_TYPE(1, LUA_TNUMBER);

	plt_FCAudio_DeleteBuffer(lua_tointeger(_state, 1));
	return 0;
}

static int lua_LoadSimpleSound( lua_State* _state )
{
	FC_LUA_FUNCDEF("FCAudio.LoadSimpleSound()");
	FC_LUA_ASSERT_NUMPARAMS(1);
	FC_LUA_ASSERT_TYPE(1, LUA_TSTRING);
	
	lua_pushinteger(_state, plt_FCAudio_LoadSimpleSound(lua_tostring(_state, 1)));
	
	return 1;
}

static int lua_UnloadSimpleSound( lua_State* _state )
{
	FC_LUA_FUNCDEF("FCAudio.UnloadSimpleSound()");
	FC_LUA_ASSERT_NUMPARAMS(1);
	FC_LUA_ASSERT_TYPE(1, LUA_TNUMBER);
	
	plt_FCAudio_UnloadSimpleSound(lua_tointeger(_state, 1));
	
	return 0;
}

static int lua_PlaySimpleSound( lua_State* _state )
{
	FC_LUA_FUNCDEF("FCAudio.PlaySimpleSound()");
	FC_LUA_ASSERT_NUMPARAMS(1);
	FC_LUA_ASSERT_TYPE(1, LUA_TNUMBER);

	plt_FCAudio_PlaySimpleSound(lua_tointeger(_state, 1));
	
	return 0;
}

static int lua_SubscribeToPhysics2D( lua_State* _state )
{
	FC_LUA_FUNCDEF("FCAudio.SubscribeToPhysics2D()");
	FC_LUA_ASSERT_NUMPARAMS(0);

	plt_FCAudio_SubscribeToPhysics2D();
	
	return 0;
}

static int lua_UnsubscribeFromPhysics2D( lua_State* _state )
{
	FC_LUA_FUNCDEF("FCAudio.UnsubscribeFromPhysics2D");
	FC_LUA_ASSERT_NUMPARAMS(0);
	
	plt_FCAudio_UnsubscribeToPhysics2D();
	
	return 0;
}

static int lua_CreateBufferWithFile( lua_State* _state )
{
	FC_LUA_FUNCDEF("FCAudio.CreateBufferWithFile()");
	FC_LUA_ASSERT_NUMPARAMS(1);
	FC_LUA_ASSERT_TYPE(1, LUA_TSTRING);
	
	lua_pushinteger(_state, plt_FCAudio_CreateBufferWithFile(lua_tostring(_state, 1)));	
	return 1;
}

static int lua_AddCollisionTypeHandler( lua_State* _state )
{
	FC_LUA_FUNCDEF("FCAudio.AddCollisionTypeHandler()");
	FC_LUA_ASSERT_NUMPARAMS(3);
	FC_LUA_ASSERT_TYPE(1, LUA_TSTRING);
	FC_LUA_ASSERT_TYPE(2, LUA_TSTRING);
	FC_LUA_ASSERT_TYPE(3, LUA_TSTRING);

	plt_FCAudio_AddCollisionTypeHandler(lua_tostring(_state, 1), 
										lua_tostring(_state, 2),
										lua_tostring(_state, 3));
	
	return 0;
}

static int lua_RemoveCollisionTypeHandler( lua_State* _state )
{
	FC_LUA_FUNCDEF("FCAudio.RemoveCollisionTypeHandler()");
	FC_LUA_ASSERT_NUMPARAMS(2);
	FC_LUA_ASSERT_TYPE(1, LUA_TSTRING);
	FC_LUA_ASSERT_TYPE(2, LUA_TSTRING);
	
	plt_FCAudio_RemoveCollisionTypeHandler(lua_tostring(_state, 1), 
										   lua_tostring(_state, 2));
	
	return 0;
}

static int lua_PrepareSourceWithBuffer( lua_State* _state )
{
	FC_LUA_FUNCDEF("FCAudio.PrepareSourceWithBuffer()");
	FC_LUA_ASSERT_NUMPARAMS(2);
	FC_LUA_ASSERT_TYPE(1, LUA_TNUMBER);
	FC_LUA_ASSERT_TYPE(2, LUA_TBOOLEAN);
	
	FCHandle hBuffer = lua_tointeger(_state, 1);
	
	bool vital = lua_toboolean(_state, 2);
	
	FCHandle hSource = plt_FCAudio_PrepareSourceWithBuffer(hBuffer, vital);
	
	lua_pushinteger(_state, hSource);
	return 1;
}

static int lua_DeleteSource( lua_State* _state )
{
	FC_LUA_FUNCDEF("FCAudio.DeleteSource()");
	FC_LUA_ASSERT_NUMPARAMS(1);
	FC_LUA_ASSERT_TYPE(1, LUA_TNUMBER);
	
	plt_FCAudio_DeleteSource( lua_tointeger(_state, 1));
	
	return 0;
}

static int lua_SourceSetVolume( lua_State* _state )
{
	FC_LUA_FUNCDEF("FCAudio.SourceSetVolume()");

	FC_LUA_ASSERT_NUMPARAMS(2);
	FC_LUA_ASSERT_TYPE(1, LUA_TNUMBER);
	FC_LUA_ASSERT_TYPE(2, LUA_TNUMBER);
	
	FCHandle hSource = lua_tointeger(_state, 1);
	float vol = (float)lua_tonumber(_state, 2);
	
	plt_FCAudio_SourceSetVolume(hSource, vol);
	
	return 0;
}

static int lua_SourcePlay( lua_State* _state )
{
	FC_LUA_FUNCDEF("FCAudio.SourcePlay()");
	FC_LUA_ASSERT_NUMPARAMS(1);
	FC_LUA_ASSERT_TYPE(1, LUA_TNUMBER);
	
	FCHandle hSource = lua_tointeger(_state, 1);	
	
	plt_FCAudio_SourcePlay( hSource );
	
	return 0;
}

static int lua_SourceStop( lua_State* _state )
{
	FC_LUA_FUNCDEF("FCAudio.SourceStop");
	FC_LUA_ASSERT_NUMPARAMS(1);
	FC_LUA_ASSERT_TYPE(1, LUA_TNUMBER);
	
	FCHandle hSource = lua_tointeger(_state, 1);	
	
	plt_FCAudio_SourceStop( hSource );
	
	return 0;
}

static int lua_SourceLooping( lua_State* _state )
{
	FC_LUA_FUNCDEF("FCAudio.SourceLooping()");
	FC_LUA_ASSERT_NUMPARAMS(2);
	FC_LUA_ASSERT_TYPE(1, LUA_TNUMBER);
	FC_LUA_ASSERT_TYPE(2, LUA_TBOOLEAN);
	
	FCHandle hSource = lua_tointeger(_state, 1);	
	
	bool looping = lua_toboolean(_state, 2);
	
	plt_FCAudio_SourceLooping(hSource, looping);
	
	return 0;
}

static int lua_SourcePosition( lua_State* _state )
{
	FC_LUA_FUNCDEF("FCAudio.SourcePosition()");
	FC_LUA_ASSERT_NUMPARAMS(4);
	FC_LUA_ASSERT_TYPE(1, LUA_TNUMBER);
	FC_LUA_ASSERT_TYPE(2, LUA_TNUMBER);
	FC_LUA_ASSERT_TYPE(3, LUA_TNUMBER);
	FC_LUA_ASSERT_TYPE(4, LUA_TNUMBER);
	
	FCHandle hSource = lua_tointeger(_state, 1);	
	
	plt_FCAudio_SourcePosition(hSource, (float)lua_tonumber(_state, 2), (float)lua_tonumber(_state, 3), (float)lua_tonumber(_state, 4));
	
	return 0;
}

static int lua_SourcePitch( lua_State* _state )
{
	FC_LUA_FUNCDEF("FCAudio.SourcePitch()");
	FC_LUA_ASSERT_NUMPARAMS(2);
	FC_LUA_ASSERT_TYPE(1, LUA_TNUMBER);
	FC_LUA_ASSERT_TYPE(2, LUA_TNUMBER);
	
	FCHandle hSource = lua_tointeger(_state, 1);	

	plt_FCAudio_SourcePitch(hSource, (float)lua_tonumber(_state, 2));
	
	return 0;
}

FCAudioManager* FCAudioManager::Instance()
{
	if (!s_pInstance) {
		s_pInstance = new FCAudioManager;
	}
	return s_pInstance;
}

FCAudioManager::FCAudioManager()
{
	// register lua functions
	FCLua::Instance()->CoreVM()->CreateGlobalTable("FCAudio");
	FCLua::Instance()->CoreVM()->RegisterCFunction(lua_PlayMusic, "FCAudio.PlayMusic");
	FCLua::Instance()->CoreVM()->RegisterCFunction(lua_SetMusicVolume, "FCAudio.SetMusicVolume");
	FCLua::Instance()->CoreVM()->RegisterCFunction(lua_SetSFXVolume, "FCAudio.SetSFXVolume");
	FCLua::Instance()->CoreVM()->RegisterCFunction(lua_SetMusicFinishedCallback, "FCAudio.SetMusicFinishedCallback");
	FCLua::Instance()->CoreVM()->RegisterCFunction(lua_PauseMusic, "FCAudio.PauseMusic");
	FCLua::Instance()->CoreVM()->RegisterCFunction(lua_ResumeMusic, "FCAudio.ResumeMusic");
	FCLua::Instance()->CoreVM()->RegisterCFunction(lua_StopMusic, "FCAudio.StopMusic");
	
	FCLua::Instance()->CoreVM()->RegisterCFunction(lua_CreateBufferWithFile, "FCAudio.CreateBuffer");
	FCLua::Instance()->CoreVM()->RegisterCFunction(lua_DeleteBuffer, "FCAudio.DeleteBuffer");
	
	FCLua::Instance()->CoreVM()->RegisterCFunction(lua_PrepareSourceWithBuffer, "FCAudio.PrepareSourceWithBuffer");
	FCLua::Instance()->CoreVM()->RegisterCFunction(lua_SourceSetVolume, "FCAudio.SourceSetVolume");
	FCLua::Instance()->CoreVM()->RegisterCFunction(lua_SourcePlay, "FCAudio.SourcePlay");
	FCLua::Instance()->CoreVM()->RegisterCFunction(lua_DeleteSource, "FCAudio.DeleteSource");
	FCLua::Instance()->CoreVM()->RegisterCFunction(lua_SourceStop, "FCAudio.SourceStop");
	FCLua::Instance()->CoreVM()->RegisterCFunction(lua_SourcePosition, "FCAudio.SourcePosition");
	FCLua::Instance()->CoreVM()->RegisterCFunction(lua_SourcePitch, "FCAudio.SourcePitch");
	FCLua::Instance()->CoreVM()->RegisterCFunction(lua_SourceLooping, "FCAudio.SourceLooping");
	
	FCLua::Instance()->CoreVM()->RegisterCFunction(lua_AddCollisionTypeHandler, "FCAudio.AddCollisionTypeHandler");
	FCLua::Instance()->CoreVM()->RegisterCFunction(lua_RemoveCollisionTypeHandler, "FCAudio.RemoveCollisionTypeHandler");
	
	FCLua::Instance()->CoreVM()->RegisterCFunction(lua_LoadSimpleSound, "FCAudio.LoadSimpleSound");
	FCLua::Instance()->CoreVM()->RegisterCFunction(lua_UnloadSimpleSound, "FCAudio.UnloadSimpleSound");
	FCLua::Instance()->CoreVM()->RegisterCFunction(lua_PlaySimpleSound, "FCAudio.PlaySimpleSound");
	
	FCLua::Instance()->CoreVM()->RegisterCFunction(lua_SubscribeToPhysics2D, "FCAudio.SubscribeToPhysics2D");
	FCLua::Instance()->CoreVM()->RegisterCFunction(lua_UnsubscribeFromPhysics2D, "FCAudio.UnsubscribeFromPhysics2D");
}

FCAudioManager::~FCAudioManager()
{
	
}
