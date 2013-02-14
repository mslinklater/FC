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

#include "FCGraphics.h"

#include"FCRenderer.h"
#include "Shared/Lua/FCLua.h"
#include "Shared/Graphics/Camera/FCCameraManager.h"
#include "Shared/Graphics/Camera/FCCamera.h"

static FCRenderer* s_pCurrent = 0;
static int s_numRenderers = 0;

// Lua

static int lua_SetBackgroundColor( lua_State* _state )
{
	FC_LUA_FUNCDEF("SetBackgroundColor");
	FC_LUA_ASSERT_NUMPARAMS(1);
	FC_LUA_ASSERT_TYPE(1, LUA_TTABLE);
	FC_ASSERT(s_pCurrent);

	FCColor4f color = FCColorFromLuaColor(_state, 1);

	s_pCurrent->SetBackgroundColor( color );
	
	return 0;
}

static int lua_RenderTestCube( lua_State* _state )
{
	FC_LUA_FUNCDEF("FCRenderer::RenderTestCube");
	FC_LUA_ASSERT_NUMPARAMS(0);
	FC_ASSERT(s_pCurrent);
	
	s_pCurrent->RenderTestCube();
	return 0;
}

static int lua_SetCamera( lua_State* _state )
{
	FC_LUA_FUNCDEF("FCRenderer::SetCamera");
	FC_LUA_ASSERT_NUMPARAMS(1);
	FC_LUA_ASSERT_TYPE(1, LUA_TTABLE);
	FC_ASSERT(s_pCurrent);
	
	lua_getfield(_state, 1, "h");
	FC_LUA_ASSERT_TYPE(-1, LUA_TNUMBER);
	s_pCurrent->SetCamera( lua_tointeger(_state, -1) );
	lua_pop(_state, 1);
	
	return 0;
}

// Impl

void FCRenderer::RegisterLuaFuncs()
{
	FCLua::Instance()->CoreVM()->CreateGlobalTable("FCRenderer");
	FCLua::Instance()->CoreVM()->RegisterCFunction(lua_SetBackgroundColor, "FCRenderer.SetBackgroundColor");
	FCLua::Instance()->CoreVM()->RegisterCFunction(lua_RenderTestCube, "FCRenderer.RenderTestCube");
	FCLua::Instance()->CoreVM()->RegisterCFunction(lua_SetCamera, "FCRenderer.SetCamera");
}

FCRenderer::FCRenderer( std::string name )
: m_backgroundColor(0.0f, 0.0f, 0.0f, 1.0f)
{
	s_numRenderers++;
}

FCRenderer::~FCRenderer()
{
	s_numRenderers--;
}

void FCRenderer::BeginInit()
{
	s_pCurrent = this;
}

void FCRenderer::EndInit()
{
	s_pCurrent = 0;
}

void FCRenderer::BeginRender()
{
	s_pCurrent = this;
}

void FCRenderer::EndRender()
{
	s_pCurrent = 0;
}

void FCRenderer::RenderTestCube( void )
{
	
}

void FCRenderer::SetBackgroundColor(FCColor4f &color)
{
	m_backgroundColor = color;
}

void FCRenderer::SetCamera( FCHandle h )
{
	FCCamera* pCamera = FCCameraManager::Instance()->GetCamera(h);
	m_pViewport = pCamera->GetViewport();
}

