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

#include "FCRenderManager.h"
#include "Shared/Lua/FCLua.h"
#include "Shared/Core/FCCore.h"
#include "Shared/Framework/UI/FCViewManager.h"
#include "Shared/FCPlatformInterface.h"

static FCRenderManager* s_pInstance;

// Lua

static int lua_CreateRenderer( lua_State* _state )
{
	FC_LUA_FUNCDEF("FCRendererManager.CreateRenderer()");
	FC_LUA_ASSERT_NUMPARAMS(2);
	FC_LUA_ASSERT_TYPE(1, LUA_TSTRING );
	FC_LUA_ASSERT_TYPE(2, LUA_TSTRING );
	
	const char* name = lua_tostring(_state, 1 );
	const char* initFunc = lua_tostring(_state, 2 );
	
	lua_pushinteger( _state, s_pInstance->CreateRenderer( name, initFunc ) );
	
	return 1;
}

static int lua_SetRendererFrameRate( lua_State* _state )
{
	FC_LUA_FUNCDEF("FCRendererManager.SetRendererFrameRate()");
	FC_LUA_ASSERT_NUMPARAMS(2);
	FC_LUA_ASSERT_TYPE(1, LUA_TNUMBER);
	FC_LUA_ASSERT_TYPE(2, LUA_TNUMBER);
	
	FCHandle h = lua_tointeger(_state, 1);

	s_pInstance->SetFrameRate(h, lua_tonumber(_state, 2));
	
	return 0;
}

static int lua_SetRendererRenderFunc( lua_State* _state )
{
	FC_LUA_FUNCDEF("FCRendererManager.SetRendererRenderFunc()");
	FC_LUA_ASSERT_NUMPARAMS(2);
	FC_LUA_ASSERT_TYPE(1, LUA_TNUMBER);
	FC_LUA_ASSERT_TYPE(2, LUA_TSTRING);
	
	s_pInstance->SetRenderFunc( lua_tointeger(_state, 1), lua_tostring(_state, 2));
	
	return 0;
}

// FC

void fc_FCRenderer_ViewReadyToRender( const char* viewName )
{
	s_pInstance->ViewReadyToRender( viewName );
}

void fc_FCRenderer_ViewReadyToInit( const char* viewName )
{
	s_pInstance->ViewReadyToInit( viewName );
}

// Impl

FCRenderManager* FCRenderManager::Instance()
{
	if (!s_pInstance) {
		s_pInstance = new FCRenderManager;
	}
	return s_pInstance;
}

FCRenderManager::FCRenderManager()
{
	// register Lua interface
	FCLua::Instance()->CoreVM()->CreateGlobalTable("FCRenderManager");
	FCLua::Instance()->CoreVM()->RegisterCFunction(lua_CreateRenderer, "FCRenderManager.CreateRenderer");
	FCLua::Instance()->CoreVM()->RegisterCFunction(lua_SetRendererFrameRate, "FCRenderManager.SetRendererFrameRate");
	FCLua::Instance()->CoreVM()->RegisterCFunction(lua_SetRendererRenderFunc, "FCRenderManager.SetRendererRenderFunc");
}

FCRenderManager::~FCRenderManager()
{
	FCLua::Instance()->CoreVM()->RemoveCFunction("FCRenderManager.SetRendererRenderFunc");
	FCLua::Instance()->CoreVM()->RemoveCFunction("FCRenderManager.SetRendererFrameRate");
	FCLua::Instance()->CoreVM()->RemoveCFunction("FCRenderManager.CreateRenderer");
	FCLua::Instance()->CoreVM()->DestroyGlobalTable("FCRenderManager");
}

void FCRenderManager::Reset()
{
	// delete existing renderers
	
//	for (FCRendererMapByHandleIter i = m_renderersByHandle.begin(); i != m_renderersByHandle.end(); i++) {
//		delete i->second;
//	}
	
	// delete other OS shared stuff
}

FCHandle FCRenderManager::CreateRenderer( std::string name, std::string initFunc )
{
	FCHandle h = FCHandleNew();
	
	FCRenderer* pRenderer = plt_FCRenderer_Create( name.c_str() );
	
	m_renderersByHandle[h] = pRenderer;
	m_namesByRenderer[ pRenderer ] = name;
	m_renderersByName[ name ] = pRenderer;
	m_handleByName[ name ] = h;

	m_initFuncByHandle[ h ] = initFunc;
	
	return h;
}

void FCRenderManager::DestroyRenderer(FCHandle h)
{
	FC_ASSERT(m_renderersByHandle.find(h) == m_renderersByHandle.end());

	FCRenderer* pRenderer = m_renderersByHandle[h];
	std::string name = m_namesByRenderer[ pRenderer ];
	
	m_renderersByHandle.erase(h);
	m_handleByName.erase(name);
	m_renderersByName.erase(name);
	m_namesByRenderer.erase(pRenderer);
}

void FCRenderManager::SetFrameRate(FCHandle hRenderer, float rate)
{
	// get view name
	
	FCRenderer* pRenderer = m_renderersByHandle[ hRenderer ];
	std::string viewName = m_namesByRenderer[ pRenderer ];
	
	// may have to make this next bit platform independent, depending on which element
	// controls what the frame rate is.
	
	FCViewManager::Instance()->SetViewPropertyFloat(viewName, "frameRate", rate);
}

void FCRenderManager::ViewReadyToRender(std::string name)
{
	FCRenderer* pRenderer = m_renderersByName[ name ];
	FCHandle h = m_handleByName[ name ];
	std::string func = m_renderFuncByHandle[ h ];

	pRenderer->BeginRender();
	FCLua::Instance()->CoreVM()->CallFuncWithSig(func, true, "f>", 0.01f );	// delta t
	pRenderer->EndRender();
}

void FCRenderManager::ViewReadyToInit(std::string name)
{
	FCRenderer* pRenderer = m_renderersByName[ name ];
	FCHandle h = m_handleByName[ name ];
	std::string func = m_initFuncByHandle[ h ];
	
	pRenderer->BeginInit();
	FCLua::Instance()->CoreVM()->CallFuncWithSig(func, true, "f>", 0.01f );	// delta t
	pRenderer->EndInit();
}

void FCRenderManager::SetRenderFunc(FCHandle h, std::string renderFunc)
{
	m_renderFuncByHandle[ h ] = renderFunc;
}

