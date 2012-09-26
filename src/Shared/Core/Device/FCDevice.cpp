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

#include "FCDevice.h"
#include "../FCError.h"
#include "Shared/Lua/FCLua.h"
#include "Shared/FCPlatformInterface.h"


static int lua_ColdProbe( lua_State* _state )
{
	FC_LUA_ASSERT_NUMPARAMS(0);
	plt_FCDevice_ColdProbe();
	return 0;
}

static int lua_WarmProbe( lua_State* _state )
{
	FC_LUA_ASSERT_NUMPARAMS(0);
	plt_FCDevice_WarmProbe( 0 );	// what to do here ?
	return 0;
}

static int lua_Print( lua_State* _state )
{
	FC_LUA_ASSERT_NUMPARAMS(0);
	FCDevice::Instance()->Print();
	return 0;
}

static int lua_GetDeviceString( lua_State* _state )
{
	FC_LUA_ASSERT_NUMPARAMS(1);
	FC_LUA_ASSERT_TYPE(1, LUA_TSTRING);
	
	std::string key = lua_tostring(_state, 1);
		
	lua_pushstring(_state, FCDevice::Instance()->GetCap(key).c_str() );
	
	return 1;
}

static int lua_GetDeviceFloat( lua_State* _state )
{
	FC_LUA_ASSERT_NUMPARAMS(1);
	FC_LUA_ASSERT_TYPE(1, LUA_TSTRING);
	
	std::string key = lua_tostring(_state, 1);
		
	std::string val = FCDevice::Instance()->GetCap(key);
	
	float value = atof(val.c_str());
	
	lua_pushnumber(_state, value);
	return 1;
}

static int lua_GetDeviceInteger( lua_State* _state )
{
	FC_LUA_ASSERT_NUMPARAMS(1);
	FC_LUA_ASSERT_TYPE(1, LUA_TSTRING);
	
	std::string key = lua_tostring(_state, 1);
	
	
	std::string val = FCDevice::Instance()->GetCap(key);
	
	int value = atoi(val.c_str());
		
	lua_pushnumber(_state, value);
	return 1;
}

static int lua_GetGameCenterID( lua_State* _state )
{
	FC_LUA_ASSERT_NUMPARAMS(0);
	
	std::string ret = FCDevice::Instance()->GetCap(kFCDeviceGameCenterID);
	
	if (ret.size()) {
		lua_pushstring(_state, ret.c_str());
	} else {
		lua_pushnil(_state);
	}
	
	return 1;
}

static FCDevice* s_pInstance = 0;

FCDevice* FCDevice::Instance()
{
	if (!s_pInstance) {
		s_pInstance = new FCDevice;
	}
	return s_pInstance;
}

FCDevice::FCDevice()
{
	FCLuaVM* lua = FCLua::Instance()->CoreVM();
	
	lua->CreateGlobalTable("FCDevice");
	lua->RegisterCFunction(lua_ColdProbe, "FCDevice.ColdProbe");
	lua->RegisterCFunction(lua_WarmProbe, "FCDevice.WarmProbe");
	lua->RegisterCFunction(lua_Print, "FCDevice.Print");
	lua->RegisterCFunction(lua_GetDeviceString, "FCDevice.GetString");
	lua->RegisterCFunction(lua_GetDeviceFloat, "FCDevice.GetFloat");
	lua->RegisterCFunction(lua_GetDeviceInteger, "FCDevice.GetInteger");
	lua->RegisterCFunction(lua_GetGameCenterID, "FCDevice.GetGameCenterID");
}

FCDevice::~FCDevice()
{
	
}

void FCDevice::ColdProbe()
{
	plt_FCDevice_ColdProbe();
}

void FCDevice::WarmProbe( uint32_t options )
{
	plt_FCDevice_WarmProbe( options );
}

std::string FCDevice::GetCap(std::string cap)
{
	if (m_caps.find(cap) == m_caps.end()) {
		return std::string("");
	} else {
		return m_caps[ cap ];
	}
}

void FCDevice::SetCap(std::string cap, std::string value)
{
	m_caps[ cap ] = value;
}

void FCDevice::Print()
{
	for (FCStringStringMapConstIter i = m_caps.begin(); i != m_caps.end(); ++i) {
		FC_LOG( i->first + " : " + i->second );
	}
}
