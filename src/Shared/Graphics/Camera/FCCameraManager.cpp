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

#include "FCCameraManager.h"

#include "Shared/Lua/FCLua.h"
#include "FCCamera.h"

static FCCameraManager* s_pInstance;

static int lua_CreateCamera( lua_State* _state )
{
	FC_LUA_FUNCDEF("FCCameraManager.CreateCamera()");
	FC_LUA_ASSERT_NUMPARAMS(0);
	
	lua_pushinteger(_state, s_pInstance->CreateCamera() );
	
	return 1;
}

static int lua_DestroyCamera( lua_State* _state )
{
	FC_LUA_FUNCDEF("FCCameraManager.DestroyCamera()");
	FC_LUA_ASSERT_NUMPARAMS(1);
	FC_LUA_ASSERT_TYPE( 1, LUA_TNUMBER );
	
	FCHandle h = lua_tointeger(_state, 1);
	
	s_pInstance->DestroyCamera( h );
	
	return 0;
}

static int lua_SetCameraPosition( lua_State* _state )
{
	FC_LUA_FUNCDEF("FCCameraManager.SetCameraPosition()");
	FC_LUA_ASSERT_NUMPARAMS(3);
	FC_LUA_ASSERT_TYPE(1, LUA_TNUMBER);
	FC_LUA_ASSERT_TYPE(2, LUA_TTABLE);
	FC_LUA_ASSERT_TYPE(3, LUA_TNUMBER);
	
	FCHandle h = lua_tointeger(_state, 1);
	FCVector3f pos = FCVector3fFromLuaVector(_state, 2);
	float t = lua_tonumber(_state, 3);
	
	s_pInstance->SetCameraPosition( h, pos, t );
	
	return 0;
}

static int lua_SetCameraTarget( lua_State* _state )
{
	FC_LUA_FUNCDEF("FCCameraManager.SetCameraTarget()");
	FC_LUA_ASSERT_NUMPARAMS(3);
	FC_LUA_ASSERT_TYPE(1, LUA_TNUMBER);
	FC_LUA_ASSERT_TYPE(2, LUA_TTABLE);
	FC_LUA_ASSERT_TYPE(3, LUA_TNUMBER);
	
	FCHandle h = lua_tointeger(_state, 1);
	FCVector3f pos = FCVector3fFromLuaVector(_state, 2);
	float t = lua_tonumber(_state, 3);
	
	s_pInstance->SetCameraTarget( h, pos, t );
	
	return 0;
}

static int lua_SetCameraOrthographicProjection( lua_State* _state )
{
	FC_LUA_FUNCDEF("FCCameraManager.SetCameraOrthographicProjection()");
	FC_LUA_ASSERT_MINPARAMS(2);
	FC_LUA_ASSERT_TYPE(1, LUA_TNUMBER);
	FC_LUA_ASSERT_TYPE(2, LUA_TNUMBER);

	FCHandle h = lua_tointeger(_state, 1);

	float x = lua_tonumber(_state, 2);
	float y = 0.0f;

	if (lua_gettop(_state) > 2) {
		y = lua_tonumber(_state, 3);
	}
	
	s_pInstance->SetCameraOrthographicProjection( h, x, y );
	
	return 0;
}

static int lua_SetCameraPerspectiveProjection( lua_State* _state )
{
	FC_LUA_FUNCDEF("FCCameraManager.SetCameraPerspectiveProjection()");
	FC_LUA_ASSERT_MINPARAMS(2);
	FC_LUA_ASSERT_TYPE(1, LUA_TNUMBER);
	FC_LUA_ASSERT_TYPE(2, LUA_TNUMBER);
	
	FCHandle h = lua_tointeger(_state, 1);
	
	float x = lua_tonumber(_state, 2);
	float y = 0.0f;
	
	if (lua_gettop(_state) > 2) {
		y = lua_tonumber(_state, 3);
	}
	
	s_pInstance->SetCameraPerspectiveProjection( h, x, y );
	return 0;
}

// Impl

FCCameraManager* FCCameraManager::Instance()
{
	if (!s_pInstance) {
		s_pInstance = new FCCameraManager;
	}
	return s_pInstance;
}

FCCameraManager::FCCameraManager()
{
	// regsiter lua functions
	FCLua::Instance()->CoreVM()->CreateGlobalTable("FCCameraManager");
	FCLua::Instance()->CoreVM()->RegisterCFunction(lua_CreateCamera, "FCCameraManager.CreateCamera");
	FCLua::Instance()->CoreVM()->RegisterCFunction(lua_DestroyCamera, "FCCameraManager.DestroyCamera");
	FCLua::Instance()->CoreVM()->RegisterCFunction(lua_SetCameraPosition, "FCCameraManager.SetCameraPosition");
	FCLua::Instance()->CoreVM()->RegisterCFunction(lua_SetCameraTarget, "FCCameraManager.SetCameraTarget");
	FCLua::Instance()->CoreVM()->RegisterCFunction(lua_SetCameraOrthographicProjection, "FCCameraManager.SetCameraOrthographicProjection");
	FCLua::Instance()->CoreVM()->RegisterCFunction(lua_SetCameraPerspectiveProjection, "FCCameraManager.SetCameraPerspectiveProjection");
}

FCCameraManager::~FCCameraManager()
{
	// deregsiter lua functions
	FCLua::Instance()->CoreVM()->RemoveCFunction("FCCameraManager.SetCameraPerspectiveProjection");
	FCLua::Instance()->CoreVM()->RemoveCFunction("FCCameraManager.SetCameraOrthographicProjection");
	FCLua::Instance()->CoreVM()->RemoveCFunction("FCCameraManager.SetCameraTarget");
	FCLua::Instance()->CoreVM()->RemoveCFunction("FCCameraManager.SetCameraPosition");
	FCLua::Instance()->CoreVM()->RemoveCFunction("FCCameraManager.CreateCamera");
	FCLua::Instance()->CoreVM()->RemoveCFunction("FCCameraManager.DestroyCamera");
	FCLua::Instance()->CoreVM()->DestroyGlobalTable("FCCameraManager");
}

FCHandle FCCameraManager::CreateCamera()
{
	FCHandle h = FCHandleNew();
	
	m_cameras[h] = new FCCamera;
	
	return h;
}

void FCCameraManager::Update(float dt, float gameTime)
{
	for (CamerasByHandleMapIter i = m_cameras.begin(); i != m_cameras.end(); i++) {
		i->second->Update( dt, gameTime );
	}
}

void FCCameraManager::DestroyCamera(FCHandle h)
{
	FC_ASSERT(m_cameras.find(h) != m_cameras.end());
	
	delete m_cameras[h];
	
	m_cameras.erase(h);
}

FCCamera* FCCameraManager::GetCamera(FCHandle h)
{
	FC_ASSERT(m_cameras.find(h) != m_cameras.end());
	
	return m_cameras[h];
}

void FCCameraManager::SetCameraPosition(FCHandle h, FCVector3f pos, float t )
{
	FC_ASSERT(m_cameras.find(h) != m_cameras.end());
	
	m_cameras[h]->SetPosition( pos, t );
}

void FCCameraManager::SetCameraTarget(FCHandle h, FCVector3f pos, float t )
{
	FC_ASSERT(m_cameras.find(h) != m_cameras.end());
	
	m_cameras[h]->SetTarget( pos, t );
}

void FCCameraManager::SetCameraOrthographicProjection( FCHandle h, float x, float y)
{
	FC_ASSERT(m_cameras.find(h) != m_cameras.end());
	m_cameras[h]->SetOrthographicProjection( x, y );
}

void FCCameraManager::SetCameraPerspectiveProjection( FCHandle h, float x, float y)
{
	FC_ASSERT(m_cameras.find(h) != m_cameras.end());
	m_cameras[h]->SetPerspectiveProjection( x, y );
}
