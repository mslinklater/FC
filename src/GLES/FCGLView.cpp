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

#include "FCGLView.h"
#include "Shared/Lua/FCLua.h"

static FCGLViewMap s_viewMap;
static FCGLViewRef s_currentLuaTarget = 0;

static int lua_SetCurrentView( lua_State* _state )
{
	FC_LUA_FUNCDEF("GLView.SetCurrentView()");
	FC_LUA_ASSERT_NUMPARAMS(1);
	FC_LUA_ASSERT_TYPE(1, LUA_TSTRING);
	
	std::string viewName = lua_tostring(_state, 1);
	FC_LOG(viewName);
	
	FC_ASSERT( s_viewMap.find(viewName) != s_viewMap.end() );
	
	s_currentLuaTarget = s_viewMap[ viewName ];

	return 0;
}

static int lua_SetClearColor( lua_State* _state )
{
	FC_LUA_FUNCDEF("GLView.SetClearColor()");
	FC_LUA_ASSERT_NUMPARAMS(1);
	FC_LUA_ASSERT_TYPE(1, LUA_TTABLE);
	
	lua_pushnil(_state);
	
	lua_next(_state, -2);
	FC_LUA_ASSERT_TYPE(-1, LUA_TNUMBER);
	float r = (float)lua_tonumber(_state, -1);
	lua_pop(_state, 1);
	
	lua_next(_state, -2);
	FC_LUA_ASSERT_TYPE(-1, LUA_TNUMBER);
	float g = (float)lua_tonumber(_state, -1);
	lua_pop(_state, 1);
	
	lua_next(_state, -2);
	FC_LUA_ASSERT_TYPE(-1, LUA_TNUMBER);
	float b = (float)lua_tonumber(_state, -1);
	lua_pop(_state, 1);
	
	lua_next(_state, -2);
	FC_LUA_ASSERT_TYPE(-1, LUA_TNUMBER);
	float a = (float)lua_tonumber(_state, -1);
	lua_pop(_state, 1);
	
	FC_ASSERT( s_currentLuaTarget );

	s_currentLuaTarget->SetClearColor( FCColor4f( r, g, b, a ) );
	
	return 0;
}

static int lua_SetFOV( lua_State* _state )
{
	FC_LUA_FUNCDEF("GLView.SetFOV()");
	FC_LUA_ASSERT_NUMPARAMS(1);
	FC_LUA_ASSERT_TYPE(1, LUA_TNUMBER);
	
	FC_ASSERT( s_currentLuaTarget );
	s_currentLuaTarget->SetFOV( (float)lua_tonumber(_state, 1) );
	
	return 0;
}

static int lua_SetNearFarClip( lua_State* _state )
{
	FC_LUA_FUNCDEF("GLView.SetNearFarClip()");
	FC_LUA_ASSERT_NUMPARAMS(2);
	FC_LUA_ASSERT_TYPE(1, LUA_TNUMBER);
	FC_LUA_ASSERT_TYPE(2, LUA_TNUMBER);
	
	FC_ASSERT( s_currentLuaTarget );
	s_currentLuaTarget->SetNearClip( (float)lua_tonumber(_state, 1) );
	s_currentLuaTarget->SetFarClip( (float)lua_tonumber(_state, 2) );
	
	return 0;
}

static int lua_SetFrustumTranslation( lua_State* _state )
{
	FC_LUA_FUNCDEF("GLView.SetFrustumTranslation()");
	FC_LUA_ASSERT_NUMPARAMS(3);
	FC_LUA_ASSERT_TYPE(1, LUA_TNUMBER);
	FC_LUA_ASSERT_TYPE(2, LUA_TNUMBER);
	FC_LUA_ASSERT_TYPE(3, LUA_TNUMBER);

	s_currentLuaTarget->SetFrustumTranslation( FCVector3f(
														 (float)lua_tonumber(_state, 1),
														 (float)lua_tonumber(_state, 2),
														 (float)lua_tonumber(_state, 3) ) );
	
	return 0;
}

FCGLView::FCGLView( std::string name, std::string parent, const FCVector2i& size )
{
	FC_LOG( name );
	m_name = name;
	if (s_viewMap.size() == 0) {
		FCLua::Instance()->CoreVM()->CreateGlobalTable("GLView");
		FCLua::Instance()->CoreVM()->RegisterCFunction(lua_SetCurrentView, "GLView.SetCurrent");
		FCLua::Instance()->CoreVM()->RegisterCFunction(lua_SetClearColor, "GLView.SetClearColor");
		FCLua::Instance()->CoreVM()->RegisterCFunction(lua_SetFOV, "GLView.SetFOV");
		FCLua::Instance()->CoreVM()->RegisterCFunction(lua_SetNearFarClip, "GLView.SetNearFarClip");
		FCLua::Instance()->CoreVM()->RegisterCFunction(lua_SetFrustumTranslation, "GLView.SetFrustumTranslation");
	}
	s_viewMap[ name ] = FCGLViewRef( this );
}

FCGLView::~FCGLView()
{
	FC_LOG( m_name );
	s_viewMap.erase(m_name);
}

void FCGLView::Update( float dt )
{
	
}

void FCGLView::SetDepthBuffer( bool enabled )
{
	
}
void FCGLView::SetRenderTarget( FCVoidVoidFuncPtr func )
{
	
}
void FCGLView::SetFrameBuffer()
{
	
}
void FCGLView::Clear()
{
	
}
void FCGLView::SetProjectionMatrix()
{
	
}
void FCGLView::PresentFramebuffer()
{
	
}

FCVector2f FCGLView::ViewSize()
{
	FC_HALT;
	return FCVector2f( 0.0f, 0.0f);
}

FCVector3f FCGLView::PosOnPlane( const FCVector2f& point )
{
	FC_HALT;
	return FCVector3f( 0.0f, 0.0f, 0.0f);
}

void FCGLView::SetClearColor(const FCColor4f &color)
{
	
}
void FCGLView::SetFOV(float fov)
{
	
}
void FCGLView::SetNearClip(float clip)
{
	
}
void FCGLView::SetFarClip(float clip)
{
	
}
void FCGLView::SetFrustumTranslation(const FCVector3f &trans)
{
	
}
