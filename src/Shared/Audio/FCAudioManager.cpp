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

extern void plt_FCAudio_PlayMusic( std::string name );
extern void plt_FCAudio_SetMusicVolume( float vol );
extern void plt_FCAudio_SetSFXVolume( float vol );
extern void plt_FCAudio_SetMusicFinishedCallback( std::string name );
extern void plt_FCAudio_PauseMusic();
extern void plt_FCAudio_ResumeMusic();
extern void plt_FCAudio_StopMusic();
extern void plt_FCAudio_DeleteBuffer( FCHandle h );
extern FCHandle plt_FCAudio_LoadSimpleSound( std::string name );
extern void plt_FCAudio_UnloadSimpleSound( FCHandle h );
extern void plt_FCAudio_PlaySimpleSound( FCHandle h );
extern void plt_FCAudio_SubscribeToPhysics2D();
extern void plt_FCAudio_UnsubscribeToPhysics2D();
extern FCHandle plt_FCAudio_CreateBufferWithFile( std::string name );
extern void plt_FCAudio_AddCollisionTypeHandler( std::string type1, std::string type2, std::string func );
extern void plt_FCAudio_RemoveCollisionTypeHandler( std::string type1, std::string type2 );
extern FCHandle plt_FCAudio_PrepareSourceWithBuffer( FCHandle h, bool vital );
extern void plt_FCAudio_SourceSetVolume( FCHandle h, float vol );
extern void plt_FCAudio_SourcePlay( FCHandle h );
extern void plt_FCAudio_SourceStop( FCHandle h );
extern void plt_FCAudio_SourceLooping( FCHandle h, bool looping );
extern void plt_FCAudio_SourcePosition( FCHandle h, float x, float y, float z );
extern void plt_FCAudio_SourcePitch( FCHandle h, float pitch );

static FCAudioManager* s_pInstance;

static int lua_PlayMusic( lua_State* _state )
{
	FC_LUA_ASSERT_NUMPARAMS( 1 );
	FC_LUA_ASSERT_TYPE( 1, LUA_TSTRING );
	
	plt_FCAudio_PlayMusic(lua_tostring(_state, 1));
	return 0;
}

static int lua_SetMusicVolume( lua_State* _state )
{
	FC_LUA_ASSERT_NUMPARAMS(1);
	FC_LUA_ASSERT_TYPE(1, LUA_TNUMBER);
	
	plt_FCAudio_SetMusicVolume( lua_tonumber(_state, 1) );
	
	return 0;
}

static int lua_SetSFXVolume( lua_State* _state )
{
	FC_LUA_ASSERT_NUMPARAMS(1);
	FC_LUA_ASSERT_TYPE(1, LUA_TNUMBER);
	
	plt_FCAudio_SetSFXVolume( lua_tonumber(_state, 1) );
	
	return 0;
}

static int lua_SetMusicFinishedCallback( lua_State* _state )
{
	FC_LUA_ASSERT_NUMPARAMS(1);
	FC_LUA_ASSERT_TYPE(1, LUA_TSTRING);

	plt_FCAudio_SetMusicFinishedCallback( lua_tostring(_state, 1) );
	
	return 0;
}

static int lua_PauseMusic( lua_State* _state )
{
	FC_LUA_ASSERT_NUMPARAMS(0);
	plt_FCAudio_PauseMusic();
	return 0;
}

static int lua_ResumeMusic( lua_State* _state )
{
	FC_LUA_ASSERT_NUMPARAMS(0);
	plt_FCAudio_ResumeMusic();
	return 0;
}

static int lua_StopMusic( lua_State* _state )
{
	FC_LUA_ASSERT_NUMPARAMS(0);
	plt_FCAudio_StopMusic();
	return 0;
}

static int lua_DeleteBuffer( lua_State* _state )
{
	FC_LUA_ASSERT_NUMPARAMS(1);
	FC_LUA_ASSERT_TYPE(1, LUA_TNUMBER);

	plt_FCAudio_DeleteBuffer(lua_tointeger(_state, 1));
	return 0;
}

static int lua_LoadSimpleSound( lua_State* _state )
{
	FC_LUA_ASSERT_NUMPARAMS(1);
	FC_LUA_ASSERT_TYPE(1, LUA_TSTRING);
	
	lua_pushinteger(_state, plt_FCAudio_LoadSimpleSound(lua_tostring(_state, 1)));
	
	return 1;
}

static int lua_UnloadSimpleSound( lua_State* _state )
{
	FC_LUA_ASSERT_NUMPARAMS(1);
	FC_LUA_ASSERT_TYPE(1, LUA_TNUMBER);
	
	plt_FCAudio_UnloadSimpleSound(lua_tointeger(_state, 1));
	
	return 0;
}

static int lua_PlaySimpleSound( lua_State* _state )
{
	FC_LUA_ASSERT_NUMPARAMS(1);
	FC_LUA_ASSERT_TYPE(1, LUA_TNUMBER);

	plt_FCAudio_PlaySimpleSound(lua_tointeger(_state, 1));
	
	return 0;
}

static int lua_SubscribeToPhysics2D( lua_State* _state )
{
	FC_LUA_ASSERT_NUMPARAMS(0);

	plt_FCAudio_SubscribeToPhysics2D();
	
	return 0;
}

static int lua_UnsubscribeFromPhysics2D( lua_State* _state )
{
	FC_LUA_ASSERT_NUMPARAMS(0);
	
	plt_FCAudio_UnsubscribeToPhysics2D();
	
	return 0;
}

static int lua_CreateBufferWithFile( lua_State* _state )
{
	FC_LUA_ASSERT_NUMPARAMS(1);
	FC_LUA_ASSERT_TYPE(1, LUA_TSTRING);
	
	lua_pushinteger(_state, plt_FCAudio_CreateBufferWithFile(lua_tostring(_state, 1)));	
	return 1;
}

static int lua_AddCollisionTypeHandler( lua_State* _state )
{
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
	FC_LUA_ASSERT_NUMPARAMS(2);
	FC_LUA_ASSERT_TYPE(1, LUA_TSTRING);
	FC_LUA_ASSERT_TYPE(2, LUA_TSTRING);
	
	plt_FCAudio_RemoveCollisionTypeHandler(lua_tostring(_state, 1), 
										   lua_tostring(_state, 2));
	
	return 0;
}

static int lua_PrepareSourceWithBuffer( lua_State* _state )
{
	FC_LUA_ASSERT_NUMPARAMS(2);
	FC_LUA_ASSERT_TYPE(1, LUA_TNUMBER);
	FC_LUA_ASSERT_TYPE(2, LUA_TBOOLEAN);
	
	FCHandle hBuffer = lua_tointeger(_state, 1);
	
	bool vital = lua_toboolean(_state, 2);
	
	FCHandle hSource = plt_FCAudio_PrepareSourceWithBuffer(hBuffer, vital);
	
	lua_pushinteger(_state, hSource);
	return 1;
}

static int lua_SourceSetVolume( lua_State* _state )
{
	FC_LUA_ASSERT_NUMPARAMS(2);
	FC_LUA_ASSERT_TYPE(1, LUA_TNUMBER);
	FC_LUA_ASSERT_TYPE(2, LUA_TNUMBER);
	
	FCHandle hSource = lua_tointeger(_state, 1);
	float vol = lua_tonumber(_state, 2);
	
//	FCAudioSource_apple* source = [[FCAudioManager_apple instance].activeSources objectForKey:[NSNumber numberWithInt:hSource]];

	plt_FCAudio_SourceSetVolume(hSource, vol);
	
//	FC_ASSERT(source);
	
//	source.volume = vol;
	
	return 0;
}

static int lua_SourcePlay( lua_State* _state )
{
	FC_LUA_ASSERT_NUMPARAMS(1);
	FC_LUA_ASSERT_TYPE(1, LUA_TNUMBER);
	
	FCHandle hSource = lua_tointeger(_state, 1);	
	
	plt_FCAudio_SourcePlay( hSource );
	
//	FCAudioSource_apple* source = [[FCAudioManager_apple instance].activeSources objectForKey:[NSNumber numberWithInt:hSource]];
	
//	FC_ASSERT(source);
	
//	[source play];
	
	return 0;
}

static int lua_SourceStop( lua_State* _state )
{
	FC_LUA_ASSERT_NUMPARAMS(1);
	FC_LUA_ASSERT_TYPE(1, LUA_TNUMBER);
	
	FCHandle hSource = lua_tointeger(_state, 1);	
	
	plt_FCAudio_SourceStop( hSource );
	
//	FCAudioSource_apple* source = [[FCAudioManager_apple instance].activeSources objectForKey:[NSNumber numberWithInt:hSource]];
	
//	FC_ASSERT(source);
	
//	[source stop];
	
	return 0;
}

static int lua_SourceLooping( lua_State* _state )
{
	FC_LUA_ASSERT_NUMPARAMS(2);
	FC_LUA_ASSERT_TYPE(1, LUA_TNUMBER);
	FC_LUA_ASSERT_TYPE(2, LUA_TBOOLEAN);
	
	FCHandle hSource = lua_tointeger(_state, 1);	
	
	bool looping = lua_toboolean(_state, 2);
	
	plt_FCAudio_SourceLooping(hSource, looping);
	
//	FCAudioSource_apple* source = [[FCAudioManager_apple instance].activeSources objectForKey:[NSNumber numberWithInt:hSource]];
	
//	FC_ASSERT(source);
	
//	source.looping = lua_toboolean(_state, 2);
	
	return 0;
}

static int lua_SourcePosition( lua_State* _state )
{
	FC_LUA_ASSERT_NUMPARAMS(4);
	FC_LUA_ASSERT_TYPE(1, LUA_TNUMBER);
	FC_LUA_ASSERT_TYPE(2, LUA_TNUMBER);
	FC_LUA_ASSERT_TYPE(3, LUA_TNUMBER);
	FC_LUA_ASSERT_TYPE(4, LUA_TNUMBER);
	
	FCHandle hSource = lua_tointeger(_state, 1);	
	
	plt_FCAudio_SourcePosition(hSource, lua_tonumber(_state, 2), lua_tonumber(_state, 3), lua_tonumber(_state, 4));
	
//	FCAudioSource_apple* source = [[FCAudioManager_apple instance].activeSources objectForKey:[NSNumber numberWithInt:hSource]];
	
//	FCVector3f pos;
//	pos.x = lua_tonumber(_state, 2);
//	pos.y = lua_tonumber(_state, 3);
//	pos.z = lua_tonumber(_state, 4);
	
//	source.position = pos;
	
	return 0;
}

static int lua_SourcePitch( lua_State* _state )
{
	FC_LUA_ASSERT_NUMPARAMS(2);
	FC_LUA_ASSERT_TYPE(1, LUA_TNUMBER);
	FC_LUA_ASSERT_TYPE(2, LUA_TNUMBER);
	
	FCHandle hSource = lua_tointeger(_state, 1);	
//	FCAudioSource_apple* source = [[FCAudioManager_apple instance].activeSources objectForKey:[NSNumber numberWithInt:hSource]];
	
//	float pitch = lua_tonumber(_state, 2);
//	source.pitch = pitch;

	plt_FCAudio_SourcePitch(hSource, lua_tonumber(_state, 2));
	
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
