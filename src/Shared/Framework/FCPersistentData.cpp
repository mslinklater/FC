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

#include "FCPersistentData.h"
#include "Shared/Lua/FCLua.h"
#include "Shared/FCPlatformInterface.h"

static FCPersistentData* s_pInstance = 0;

static int lua_Save( lua_State* _state )
{
	FC_LUA_ASSERT_NUMPARAMS(0);
	s_pInstance->Save();
	return 0;
}

static int lua_Load( lua_State* _state )
{
	FC_LUA_ASSERT_NUMPARAMS(0);
	s_pInstance->Load();
	return 0;
}

static int lua_Clear( lua_State* _state )
{
	FC_LUA_ASSERT_NUMPARAMS(0);
	s_pInstance->Clear();
	return 0;
}

static int lua_Print( lua_State* _state )
{
	FC_LUA_ASSERT_NUMPARAMS(0);
	s_pInstance->Print();
	return 0;
}

static int lua_SetBool( lua_State* _state )
{
	FC_LUA_ASSERT_NUMPARAMS(2);
	FC_LUA_ASSERT_TYPE(-2, LUA_TSTRING);
	FC_LUA_ASSERT_TYPE(-1, LUA_TBOOLEAN);
	
	std::string varName = lua_tostring( _state, -2);
	bool value = lua_toboolean(_state, -1);
	
	if (value) {
		s_pInstance->AddBoolForKey( true, varName );
	} else {
		s_pInstance->AddBoolForKey( false, varName );		
	}
	return 0;
}

static int lua_GetBool( lua_State* _state )
{
	FC_LUA_ASSERT_NUMPARAMS(1);
	FC_LUA_ASSERT_TYPE(-1, LUA_TSTRING);
	
	std::string varName = lua_tostring( _state, -1 );
	
	if (s_pInstance->Exists(varName) ) {
		if (s_pInstance->BoolForKey(varName)) {
			lua_pushboolean(_state, 1 );
		} else {
			lua_pushboolean(_state, 0 );			
		}
	} else {
		lua_pushnil(_state);
	}
	
	return 1;	// false, true or nil
}

static int lua_SetString( lua_State* _state )
{
	FC_LUA_ASSERT_NUMPARAMS(2);
	FC_LUA_ASSERT_TYPE(-2, LUA_TSTRING);
	FC_LUA_ASSERT_TYPE(-1, LUA_TSTRING);
	
	std::string key = lua_tostring( _state, -2);
	std::string value = lua_tostring(_state, -1);
	
	s_pInstance->AddStringForKey( value, key );
	
	return 0;
}

static int lua_GetString( lua_State* _state )
{
	FC_LUA_ASSERT_NUMPARAMS(1);
	FC_LUA_ASSERT_TYPE(-1, LUA_TSTRING);
	
	std::string key = lua_tostring( _state, -1 );

	if (s_pInstance->Exists( key )) {
		lua_pushstring( _state, s_pInstance->StringForKey(key).c_str() );
	} else {
		lua_pushnil( _state );
	}
	
	return 1;	// false, true or nil
}

static int lua_SetNumber( lua_State* _state )
{
	FC_LUA_ASSERT_NUMPARAMS(2);
	FC_LUA_ASSERT_TYPE(-2, LUA_TSTRING);
	FC_LUA_ASSERT_TYPE(-1, LUA_TNUMBER);
	
	std::string key = lua_tostring( _state, -2);
	float value = (float)lua_tonumber(_state, -1);

	s_pInstance->AddFloatForKey( value, key );
	return 0;
}

static int lua_GetNumber( lua_State* _state )
{
	FC_LUA_ASSERT_NUMPARAMS(1);
	FC_LUA_ASSERT_TYPE(-1, LUA_TSTRING);
	
	std::string key = lua_tostring( _state, -1 );

	if (s_pInstance->Exists(key)) {
		lua_pushnumber( _state, s_pInstance->FloatForKey(key));
	} else {
		lua_pushnil( _state );
	}
	
	return 1;
}

FCPersistentData* FCPersistentData::Instance()
{
	if (!s_pInstance) {
		s_pInstance = new FCPersistentData;
	}
	return s_pInstance;
}

FCPersistentData::FCPersistentData()
{
	FCLuaVM* lua = FCLua::Instance()->CoreVM();
	
	lua->CreateGlobalTable("FCPersistentData");
	lua->RegisterCFunction(lua_Save, "FCPersistentData.Save");
	lua->RegisterCFunction(lua_Load, "FCPersistentData.Load");
	lua->RegisterCFunction(lua_Clear, "FCPersistentData.Clear");
	lua->RegisterCFunction(lua_Print, "FCPersistentData.Print");
	lua->RegisterCFunction(lua_SetBool, "FCPersistentData.SetBool");
	lua->RegisterCFunction(lua_GetBool, "FCPersistentData.GetBool");
	lua->RegisterCFunction(lua_SetString, "FCPersistentData.SetString");
	lua->RegisterCFunction(lua_GetString, "FCPersistentData.GetString");
	lua->RegisterCFunction(lua_SetNumber, "FCPersistentData.SetNumber");
	lua->RegisterCFunction(lua_GetNumber, "FCPersistentData.GetNumber");
}

FCPersistentData::~FCPersistentData()
{	
}

void FCPersistentData::Load()
{
	FC_LOG("FCPersistentData:Load()");
	plt_FCPersistentData_Load();
}

void FCPersistentData::Save()
{
	FC_LOG("FCPersistentData:Save()");
	plt_FCPersistentData_Save();
}

void FCPersistentData::Clear()
{
	FC_LOG("FCPersistentData:Clear()");
	plt_FCPersistentData_Clear();
}

std::string FCPersistentData::Print()
{
	plt_FCPersistentData_Print();
	return "";
}

bool FCPersistentData::Exists( std::string key )
{
	std::string ret = plt_FCPersistentData_ValueForKey( key.c_str() );

	if (ret.size()) {
		return true;
	} else {
		return false;
	}
}

void FCPersistentData::ClearValueForKey( std::string key )
{
    plt_FCPersistentData_ClearValueForKey( key.c_str() );
}

void FCPersistentData::AddStringForKey( std::string value, std::string key )
{
	plt_FCPersistentData_SetValueForKey(value.c_str(), key.c_str());
}

std::string FCPersistentData::StringForKey( std::string key )
{
	return plt_FCPersistentData_ValueForKey( key.c_str() );
}

void FCPersistentData::AddFloatForKey( float value, std::string key )
{
	std::stringstream ss;
	ss << value;
	plt_FCPersistentData_SetValueForKey(ss.str().c_str(), key.c_str());
}

float FCPersistentData::FloatForKey( std::string key )
{
	return (float)atof( plt_FCPersistentData_ValueForKey(key.c_str()) );
}

void FCPersistentData::AddIntForKey( int32_t value, std::string key )
{
	std::stringstream ss;
	ss << value;
	plt_FCPersistentData_SetValueForKey(ss.str().c_str(), key.c_str());
}

int32_t FCPersistentData::IntForKey( std::string key )
{
	return atoi(plt_FCPersistentData_ValueForKey(key.c_str()));
}

void FCPersistentData::AddBoolForKey( bool value, std::string key )
{
	if (value) {
		plt_FCPersistentData_SetValueForKey("true", key.c_str());
	} else {
		plt_FCPersistentData_SetValueForKey("false", key.c_str());
	}
}

bool FCPersistentData::BoolForKey( std::string key )
{
	if ( strcmp( plt_FCPersistentData_ValueForKey(key.c_str()), "true") == 0) {
		return true;
	} else {
		return false;
	}
}
