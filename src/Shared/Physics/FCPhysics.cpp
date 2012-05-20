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

#include "FCPhysics.h"
#include "Shared/Lua/FCLua.h"

static FCPhysics* s_pInstance = 0;

static int lua_Reset( lua_State* _state )
{
	FC_LUA_ASSERT_NUMPARAMS(0);
	s_pInstance->Reset();
	return 0;
}

static int lua_Create2DSystem( lua_State* _state )
{
	FC_LUA_ASSERT_NUMPARAMS(0);
	s_pInstance->Create2DSystem();
	return 0;
}

static int lua_SetMaterial( lua_State* _state )
{
	FC_LUA_ASSERT_NUMPARAMS(2);
	FC_LUA_ASSERT_TYPE(1, LUA_TSTRING);
	FC_LUA_ASSERT_TYPE(2, LUA_TTABLE);
	
	// get string and components
	
	FCPhysicsMaterialPtr material = FCPhysicsMaterialPtr( new FCPhysicsMaterial );
	
	material->name = lua_tostring(_state, 1);
	
	lua_getfield(_state, 2, "density");
	FC_LUA_ASSERT_TYPE(3, LUA_TNUMBER);
	material->density = (float)lua_tonumber(_state, 3);
	lua_pop(_state, 1);
	
	lua_getfield(_state, 2, "restitution");
	FC_LUA_ASSERT_TYPE(3, LUA_TNUMBER);
	material->restitution = (float)lua_tonumber(_state, 3);
	lua_pop(_state, 1);
	
	lua_getfield(_state, 2, "friction");
	FC_LUA_ASSERT_TYPE(3, LUA_TNUMBER);
	material->friction = (float)lua_tonumber(_state, 3);
	lua_pop(_state, 1);
	
	lua_settop(_state, 0);
	
	// set it
	
//	[s_pPhysics setMaterial:material];
	s_pInstance->SetMaterial( material );
	
	return 0;
}

FCPhysics::FCPhysics()
{
	FCLua::Instance()->CoreVM()->CreateGlobalTable("FCPhysics");
	
	FCLua::Instance()->CoreVM()->RegisterCFunction(lua_Create2DSystem, "FCPhysics.Create2DSystem");
	FCLua::Instance()->CoreVM()->RegisterCFunction(lua_Reset, "FCPhysics.Reset");
	FCLua::Instance()->CoreVM()->RegisterCFunction(lua_SetMaterial, "FCPhysics.SetMaterial");
}

FCPhysics::~FCPhysics()
{
	FCLua::Instance()->CoreVM()->DestroyGlobalTable("FCPhysics");

}

FCPhysics* FCPhysics::Instance()
{
	if (!s_pInstance) {
		s_pInstance = new FCPhysics;
	}
	return s_pInstance;
}

void FCPhysics::Reset()
{
	if (m_2D != 0) {
		m_2D->PrepareForDealloc();
	}
	m_2D = 0;
	m_materials.clear();

}

void FCPhysics::Create2DSystem()
{
	if (m_2D == 0) {
		m_2D = FCPhysics2DPtr( new FCPhysics2D );
		m_2D->Init();
	}

}

void FCPhysics::SetMaterial( FCPhysicsMaterialPtr material )
{
	m_materials[ material->name ] = material;
}

FCPhysicsMaterialMapByString& FCPhysics::GetMaterials()
{
	return m_materials;
}

void FCPhysics::Update( float realTime, float gameTime )
{
	if (m_2D) {
		m_2D->Update(realTime, gameTime);
	}
}



