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

#include "FCViewManager.h"
#include "Shared/Lua/FCLua.h"
#include "Shared/FCPlatformInterface.h"

static FCViewManager* s_pInstance = 0;

static int lua_SetText( lua_State* _state )
{
	FC_LUA_FUNCDEF("FCViewManager.SetText()");
	FC_LUA_ASSERT_NUMPARAMS(2);
	FC_LUA_ASSERT_TYPE(1, LUA_TSTRING);
	FC_LUA_ASSERT_TYPE(2, LUA_TSTRING);
	
	std::string viewName = lua_tostring(_state, 1);
	std::string text = lua_tostring(_state, 2);
	
	s_pInstance->SetViewText( viewName, text );
	
	return 0;
}

static int lua_SetTextColor( lua_State* _state )
{
	FC_LUA_FUNCDEF("FCViewManager.SetTextColor()");
	FC_LUA_ASSERT_NUMPARAMS(2);
	FC_LUA_ASSERT_TYPE(1, LUA_TSTRING);
	FC_LUA_ASSERT_TYPE(2, LUA_TTABLE);
	
	std::string viewName = lua_tostring(_state, 1);
	
	lua_getfield(_state, 2, "r");
	FC_LUA_ASSERT_TYPE(-1, LUA_TNUMBER);
	float r = (float)lua_tonumber(_state, -1);
	lua_pop(_state, 1);
	
	lua_getfield(_state, 2, "g");
	FC_LUA_ASSERT_TYPE(-1, LUA_TNUMBER);
	float g = (float)lua_tonumber(_state, -1);
	lua_pop(_state, 1);
	
	lua_getfield(_state, 2, "b");
	FC_LUA_ASSERT_TYPE(-1, LUA_TNUMBER);
	float b = (float)lua_tonumber(_state, -1);
	lua_pop(_state, 1);
	
	lua_getfield(_state, 2, "a");
	FC_LUA_ASSERT_TYPE(-1, LUA_TNUMBER);
	float a = (float)lua_tonumber(_state, -1);
	
	s_pInstance->SetViewTextColor(viewName, FCColor4f(r, g, b, a));

	return 0;
}

static int lua_GetFrame( lua_State* _state )
{
	FC_LUA_FUNCDEF("FCViewManager.GetFrame()");
	FC_LUA_ASSERT_NUMPARAMS(1);
	FC_LUA_ASSERT_TYPE(1, LUA_TSTRING);
	
	std::string viewName = lua_tostring(_state, 1);
	
	FCRect rect = s_pInstance->ViewFrame( viewName );
	
	lua_newtable(_state);
	int table = lua_gettop(_state);
	lua_pushinteger(_state, 1);
	lua_pushnumber(_state, rect.x);
	lua_settable(_state, table);
	lua_pushinteger(_state, 2);
	lua_pushnumber(_state, rect.y);
	lua_settable(_state, table);
	lua_pushinteger(_state, 3);
	lua_pushnumber(_state, rect.w);
	lua_settable(_state, table);
	lua_pushinteger(_state, 4);
	lua_pushnumber(_state, rect.h);
	lua_settable(_state, table);
	
	return 1;
}

static int lua_SetFrame( lua_State* _state )
{
	FC_LUA_FUNCDEF("FCViewManager.SetFrame()");
	FC_ASSERT( lua_gettop(_state) <= 3);
	FC_LUA_ASSERT_TYPE(1, LUA_TSTRING);
	FC_LUA_ASSERT_TYPE(2, LUA_TTABLE);
	
	std::string viewName = lua_tostring(_state, 1);
	float seconds = 0.0f;
	
	if ((lua_gettop(_state) > 2) && (lua_type(_state, 3) != LUA_TNIL)){
		FC_LUA_ASSERT_TYPE(3, LUA_TNUMBER);
		seconds = (float)lua_tonumber(_state, 3);
		lua_pop(_state, 1);
	}
	
	lua_getfield(_state, 2, "x");
	FC_LUA_ASSERT_TYPE(-1, LUA_TNUMBER);
	float x = (float)lua_tonumber(_state, -1);
	lua_pop(_state, 1);
	
	lua_getfield(_state, 2, "y");
	FC_LUA_ASSERT_TYPE(-1, LUA_TNUMBER);
	float y = (float)lua_tonumber(_state, -1);
	lua_pop(_state, 1);
	
	lua_getfield(_state, 2, "w");
	FC_LUA_ASSERT_TYPE(-1, LUA_TNUMBER);
	float w = (float)lua_tonumber(_state, -1);
	lua_pop(_state, 1);
	
	lua_getfield(_state, 2, "h");
	FC_LUA_ASSERT_TYPE(-1, LUA_TNUMBER);
	float h = (float)lua_tonumber(_state, -1);
	
	FCRect rect = FCRect(x, y, w, h);
	s_pInstance->SetViewFrame( viewName, rect, seconds );
	
	return 0;
}

static int lua_SetAlpha( lua_State* _state )
{
	FC_LUA_FUNCDEF("FCViewManager.SetAlpha()");
	FC_ASSERT( lua_gettop(_state) <= 3);
	FC_LUA_ASSERT_TYPE(1, LUA_TSTRING);
	FC_LUA_ASSERT_TYPE(2, LUA_TNUMBER);
	
	std::string viewName = lua_tostring(_state, 1);
	float alpha = (float)lua_tonumber(_state, 2);
	
	float seconds = 0.0f;
	
	if ((lua_gettop(_state) > 2) && (lua_type(_state, 3) != LUA_TNIL)){
		FC_LUA_ASSERT_TYPE(3, LUA_TNUMBER);
		seconds = (float)lua_tonumber(_state, 3);
	}
	
	s_pInstance->SetViewAlpha( viewName, alpha, seconds );
	
	return 0;
}

static int lua_SetOnSelectLuaFunction( lua_State* _state )
{
	FC_LUA_FUNCDEF("FCViewManager.SetOnSelectLuaFunction()");
	FC_LUA_ASSERT_NUMPARAMS(2);
	FC_LUA_ASSERT_TYPE(1, LUA_TSTRING);
	FC_ASSERT( (lua_type(_state, 2) == LUA_TSTRING) || (lua_type(_state, 2) == LUA_TNIL) );
	
	std::string viewName = lua_tostring(_state, 1);
	
	std::string funcName;
	
	if (lua_type(_state, 2) == LUA_TNIL) {
		funcName = "";
	} else {
		funcName = lua_tostring(_state, 2);
	}
	
	s_pInstance->SetViewOnSelectLuaFunction(viewName, funcName);
	
	return 0;
}

static int lua_SetBackgroundColor( lua_State* _state )
{
	FC_LUA_FUNCDEF("FCViewManager.SetBackgroundColor()");
	FC_LUA_ASSERT_NUMPARAMS(2);
	FC_LUA_ASSERT_TYPE(1, LUA_TSTRING);
	FC_LUA_ASSERT_TYPE(2, LUA_TTABLE);

	std::string viewName = lua_tostring(_state, 1);
	
	FCColor4f color = ColorFromLuaColor(_state, 2);
	
	s_pInstance->SetViewBackgroundColor( viewName, color );
	
	return 0;
}

static int lua_ShrinkFontToFit( lua_State* _state )
{
	FC_LUA_FUNCDEF("FCViewManager.ShrinkFontToFit()");
	FC_LUA_ASSERT_NUMPARAMS(1);
	FC_LUA_ASSERT_TYPE(1, LUA_TSTRING);
	
	std::string viewName = lua_tostring(_state, 1);
	s_pInstance->ShrinkFontToFit( viewName );
	
	return 0;
}

static int lua_MoveToFront( lua_State* _state )
{
	FC_LUA_FUNCDEF("FCViewManager.MoveToFront()");
	FC_LUA_ASSERT_NUMPARAMS(1);
	FC_LUA_ASSERT_TYPE(1, LUA_TSTRING);
	
	std::string viewName = lua_tostring(_state, 1);
	s_pInstance->MoveViewToFront( viewName );
	
	return 0;
}

static int lua_MoveToBack( lua_State* _state )
{
	FC_LUA_FUNCDEF("FCViewManager.MoveToBack()");
	FC_LUA_ASSERT_NUMPARAMS(1);
	FC_LUA_ASSERT_TYPE(1, LUA_TSTRING);
	
	std::string viewName = lua_tostring(_state, 1);
	s_pInstance->MoveViewToBack( viewName );
	
	return 0;
}

static int lua_SetImage( lua_State* _state )
{
	FC_LUA_FUNCDEF("FCViewManager.SetImage()");
	FC_LUA_ASSERT_NUMPARAMS(2);
	FC_LUA_ASSERT_TYPE(1, LUA_TSTRING);
	FC_LUA_ASSERT_TYPE(2, LUA_TSTRING);
	
	std::string viewName = lua_tostring(_state, 1);
	std::string imageName = lua_tostring(_state, 2);
	
	s_pInstance->SetViewImage(viewName, imageName);
	
	return 0;
}

static int lua_SetURL( lua_State* _state )
{
	FC_LUA_FUNCDEF("FCViewManager.SetURL()");
	FC_LUA_ASSERT_NUMPARAMS(2);
	FC_LUA_ASSERT_TYPE(1, LUA_TSTRING);
	FC_LUA_ASSERT_TYPE(2, LUA_TSTRING);
	
	std::string viewName = lua_tostring(_state, 1);
	std::string url = lua_tostring(_state, 2);
	
	s_pInstance->SetViewURL( viewName, url );
	
	return 0;
}

static int lua_CreateView( lua_State* _state )
{
	FC_LUA_FUNCDEF("FCViewManager.CreateView()");
	FC_ASSERT( lua_gettop(_state) > 1 );
	FC_LUA_ASSERT_TYPE(1, LUA_TSTRING);
	FC_LUA_ASSERT_TYPE(2, LUA_TSTRING);
	
	const char* first = lua_tostring(_state, 1);
	
	std::string name = first;
	
	FC_LOG( lua_typename(_state, 2));
	
	const char* second = lua_tostring(_state, 2);
	
	std::string className = second;
	
	std::string parent = "";
	
	if ( (lua_gettop(_state) > 2) && ( lua_type(_state, 3) == LUA_TSTRING) )
	{
		parent = lua_tostring(_state, 3);
	}
	
	s_pInstance->CreateView(name, className, parent);
	
	return 0;
}

static int lua_DestroyView( lua_State* _state )
{
	FC_LUA_FUNCDEF("FCViewManager.DestroyView()");
	FC_LUA_ASSERT_NUMPARAMS(1);
	FC_LUA_ASSERT_TYPE(1, LUA_TSTRING);
	
	std::string name = lua_tostring(_state, 1);
	
	s_pInstance->DestroyView(name);
	
	return 0;
}

static int lua_SetViewPropertyInteger( lua_State* _state )
{
	FC_LUA_FUNCDEF("FCViewManager.SetViewPropertyInteger()");
	FC_LUA_ASSERT_NUMPARAMS(3);
	FC_LUA_ASSERT_TYPE(1, LUA_TSTRING);
	FC_LUA_ASSERT_TYPE(2, LUA_TSTRING);
	FC_LUA_ASSERT_TYPE(3, LUA_TNUMBER);
	
	std::string name = lua_tostring(_state, 1);
	std::string property = lua_tostring(_state, 2);
	int32_t value = lua_tointeger(_state, 3);
	
	s_pInstance->SetViewPropertyInt( name, property, value );
	
	return 0;
}

static int lua_SetViewPropertyFloat( lua_State* _state )
{
	FC_LUA_FUNCDEF("FCViewManager.SetViewPropertyFloat()");
	FC_LUA_ASSERT_NUMPARAMS(3);
	FC_LUA_ASSERT_TYPE(1, LUA_TSTRING);
	FC_LUA_ASSERT_TYPE(2, LUA_TSTRING);
	FC_LUA_ASSERT_TYPE(3, LUA_TNUMBER);
	
	std::string name = lua_tostring(_state, 1);
	std::string property = lua_tostring(_state, 2);
	int32_t value = lua_tonumber(_state, 3);
	
	s_pInstance->SetViewPropertyFloat( name, property, value );
	
	return 0;
}

static int lua_SetViewPropertyString( lua_State* _state )
{
	FC_LUA_FUNCDEF("FCViewManager.SetViewPropertyString()");
	FC_LUA_ASSERT_NUMPARAMS(3);
	FC_LUA_ASSERT_TYPE(1, LUA_TSTRING);
	FC_LUA_ASSERT_TYPE(2, LUA_TSTRING);
	FC_LUA_ASSERT_TYPE(3, LUA_TSTRING);
	
	std::string name = lua_tostring(_state, 1);
	std::string property = lua_tostring(_state, 2);
	std::string value = lua_tostring(_state, 3);
	
	s_pInstance->SetViewPropertyString( name, property, value );
	
	return 0;
}

static int lua_PrintViews( lua_State* _state )
{
	return 0;
}

static int lua_SetScreenAspectRatio( lua_State* _state )	// deprecate ?
{
	FC_LUA_FUNCDEF("FCViewManager.SetScreenAspectRatio()");
	FC_LUA_ASSERT_NUMPARAMS(2);
	FC_LUA_ASSERT_TYPE(1, LUA_TNUMBER);
	FC_LUA_ASSERT_TYPE(2, LUA_TNUMBER);
	
	float w = (float)lua_tonumber(_state, 1);
	float h = (float)lua_tonumber(_state, 2);
	
	plt_FCViewManager_SetScreenAspectRatio( w, h );
	
	return 0;
}

static int lua_SetTapFunction( lua_State* _state )
{
	FC_LUA_FUNCDEF("FCViewManager.SetTapFunction()");
	FC_LUA_ASSERT_NUMPARAMS(2);
	FC_LUA_ASSERT_TYPE(1, LUA_TSTRING);

	std::string name = lua_tostring( _state, 1 );
	
	if (lua_type(_state, 2) == LUA_TNIL) {
		s_pInstance->SetViewTapFunction(name, "");
	} else if (lua_type(_state,2) == LUA_TSTRING) {
		s_pInstance->SetViewTapFunction(name, lua_tostring(_state, 2));
	} else {
		FC_ASSERT(0);
	}
	
	return 0;
}

void fc_FCViewManager_CallTapFunction( const char* func )
{
	FCLua::Instance()->CoreVM()->CallFuncWithSig( func, true, "" );
}

FCViewManager::FCViewManager()
{
	// register Lua
	
	FCLuaVM* lua = FCLua::Instance()->CoreVM();
	lua->CreateGlobalTable("FCViewManager");
	lua->RegisterCFunction(lua_SetScreenAspectRatio, "FCViewManager.SetScreenAspectRatio");
	lua->RegisterCFunction(lua_SetText, "FCViewManager.SetText");
	lua->RegisterCFunction(lua_SetTextColor, "FCViewManager.SetTextColor");
	lua->RegisterCFunction(lua_GetFrame, "FCViewManager.GetFrame");
	lua->RegisterCFunction(lua_SetFrame, "FCViewManager.SetFrame");
	lua->RegisterCFunction(lua_SetAlpha, "FCViewManager.SetAlpha");
	lua->RegisterCFunction(lua_SetOnSelectLuaFunction, "FCViewManager.SetOnSelectLuaFunction");
	lua->RegisterCFunction(lua_SetImage, "FCViewManager.SetImage");
	lua->RegisterCFunction(lua_SetURL, "FCViewManager.SetURL");
	lua->RegisterCFunction(lua_SetBackgroundColor, "FCViewManager.SetBackgroundColor");
	lua->RegisterCFunction(lua_MoveToFront, "FCViewManager.MoveViewToFront");
	lua->RegisterCFunction(lua_MoveToBack, "FCViewManager.MoveViewToBack");
	lua->RegisterCFunction(lua_ShrinkFontToFit, "FCViewManager.ShrinkFontToFit");
	
	lua->RegisterCFunction(lua_CreateView, "FCViewManager.CreateView");
	lua->RegisterCFunction(lua_DestroyView, "FCViewManager.DestroyView");

	lua->RegisterCFunction(lua_SetTapFunction, "FCViewManager.SetTapFunction");

	lua->RegisterCFunction(lua_PrintViews, "FCViewManager.PrintViews");
	lua->RegisterCFunction(lua_SetViewPropertyInteger, "FCViewManager.SetViewPropertyInteger");
	lua->RegisterCFunction(lua_SetViewPropertyString, "FCViewManager.SetViewPropertyString");
	lua->RegisterCFunction(lua_SetViewPropertyFloat, "FCViewManager.SetViewPropertyFloat");
}

FCViewManager::~FCViewManager()
{
	
}

FCViewManager* FCViewManager::Instance()
{
	if (!s_pInstance) {
		s_pInstance = new FCViewManager;
	}
	return s_pInstance;
}

void FCViewManager::SetViewText( const std::string& viewName, std::string text )
{
	plt_FCViewManager_SetViewText( viewName.c_str(), text.c_str() );
}

void FCViewManager::SetViewTextColor( const std::string& viewName, FCColor4f color)
{
	plt_FCViewManager_SetViewTextColor( viewName.c_str(), color );
}

FCRect FCViewManager::ViewFrame( const std::string& viewName)
{
	return plt_FCViewManager_ViewFrame( viewName.c_str() );
}

FCRect FCViewManager::FullFrame()
{
	return plt_FCViewManager_FullFrame();
}

void FCViewManager::ShrinkFontToFit( const std::string& viewName )
{
	plt_FCViewManager_ShrinkFontToFit( viewName.c_str() );
}

void FCViewManager::SetViewFrame(const std::string &viewName, const FCRect &rect, float seconds)
{
	plt_FCViewManager_SetViewFrame( viewName.c_str(), rect, seconds );
}

void FCViewManager::SetViewAlpha(const std::string &viewName, float alpha, float seconds)
{
	plt_FCViewManager_SetViewAlpha(viewName.c_str(), alpha, seconds);
}

void FCViewManager::SetViewOnSelectLuaFunction(const std::string& viewName, const std::string &func)
{
	plt_FCViewManager_SetViewOnSelectLuaFunction(viewName.c_str(), func.c_str());
}

void FCViewManager::SetViewImage(const std::string &viewName, const std::string &image)
{
	plt_FCViewManager_SetViewImage(viewName.c_str(), image.c_str());
}

void FCViewManager::SetViewURL(const std::string &viewName, const std::string &url)
{
	plt_FCViewManager_SetViewURL(viewName.c_str(), url.c_str());
}

void FCViewManager::SetViewBackgroundColor( const std::string& viewName, const FCColor4f& color )
{
	plt_FCViewManager_SetViewBackgroundColor( viewName.c_str(), color );
}

void FCViewManager::CreateView( const std::string& viewName, const std::string& classType, const std::string& parent )
{
//	FC_LOG(std::string("Create view: ") + viewName);
	plt_FCViewManager_CreateView(viewName.c_str(), classType.c_str(), parent.c_str());
}

void FCViewManager::DestroyView(const std::string &viewName)
{
//	FC_LOG(std::string("Destroy view: ") + viewName);
	plt_FCViewManager_DestroyView( viewName.c_str() );
}

void FCViewManager::SetViewPropertyInt(const std::string &viewName, const std::string &property, int32_t value)
{
	plt_FCViewManager_SetViewPropertyInt( viewName.c_str(), property.c_str(), value );
}

void FCViewManager::SetViewPropertyFloat(const std::string &viewName, const std::string &property, float value)
{
	plt_FCViewManager_SetViewPropertyFloat( viewName.c_str(), property.c_str(), value );
}

void FCViewManager::SetViewPropertyString(const std::string &viewName, const std::string &property, const std::string& value)
{
	plt_FCViewManager_SetViewPropertyString( viewName.c_str(), property.c_str(), value.c_str() );
}

void FCViewManager::SetViewTapFunction(const std::string &viewName, const std::string &func)
{
	plt_FCViewManager_SetViewTapFunction(viewName.c_str(), func.c_str());
}

void FCViewManager::MoveViewToFront( const std::string& viewname )
{
	plt_FCViewManager_MoveViewToFront( viewname.c_str() );
}

void FCViewManager::MoveViewToBack( const std::string& viewname )
{
	plt_FCViewManager_MoveViewToBack( viewname.c_str() );
}

bool FCViewManager::ViewExists(const std::string& viewName)
{
	return plt_FCViewManager_ViewExists( viewName.c_str() );
}

