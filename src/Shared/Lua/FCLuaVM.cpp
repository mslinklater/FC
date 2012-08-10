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

#include "Shared/Core/FCCore.h"

#include "FCLuaVM.h"
#include "FCLuaMemory.h"
#include "FCLuaCommon.h"
#include "FCLuaAsserts.h"
#include "Shared/Core/FCError.h"
#include "Shared/Core/FCFile.h"

extern "C" {
#include <lua.h>
#include <lauxlib.h>
#include <lualib.h>
}

static void common_LoadScriptForState( std::string path, lua_State* _state, bool optional)
{
	std::string filePath;
	
	// load via FCConnect - if not, get the binary out the bundle
	
	// if this is FC source, load from main bundle as plaintext
	
	if (path.find("fc_") == 0) {
		filePath = plt_FCFile_ApplicationBundlePathForPath(path + ".lua");
	}
	else
	{
#if defined (DEBUG)
		path = "Assets/LuaDebug/" + path;
#else
		path = "Assets/Lua/" + path;
#endif
		filePath = plt_FCFile_ApplicationBundlePathForPath(path + ".lua");
	}
	
	if(filePath == "")
	{ 
		if (!optional) {
			FC_FATAL( std::string("Cannot load Lua file: ") + path);
		} else {
			return;
		}
	}
	
	int ret = luaL_loadfile(_state, filePath.c_str());
	
	switch (ret) {
		case LUA_ERRSYNTAX:
			FCLua_DumpStack(_state);
			FC_FATAL( std::string("Syntax error on load of Lua file: ") + path);
			break;			
		case LUA_ERRMEM:
			FCLua_DumpStack(_state);
			FC_FATAL( std::string("Memory error on load of Lua file: ") + path);
			break;			
		case LUA_ERRFILE:
			FCLua_DumpStack(_state);
			FC_FATAL( std::string("File error on load of Lua file: ") + path);
			break;			
		case LUA_ERRERR:
			FCLua_DumpStack(_state);
			FC_FATAL( std::string("Error on load of Lua file: ") + path);
			break;			
		case LUA_ERRRUN:
			FCLua_DumpStack(_state);
			FC_FATAL( std::string("Run error on load of Lua file: ") + path);
			break;			
		default:
			break;
	}
	
	ret = lua_pcall(_state, 0, 0, 0);
	
	switch (ret) {
		case LUA_ERRRUN:
			FCLua_DumpStack(_state);
			FC_FATAL( std::string("Runtime error in Lua file: ") + path);
			break;
		case LUA_ERRMEM:
			FC_FATAL( std::string("Memory error in Lua file: ") + path);
			break;
		case LUA_ERRERR:
			FC_FATAL( std::string("Error while running error handling function in Lua file: ") + path);
			break;			
		default:
			break;
	}
	FC_LOG(std::string("Loaded script: ") + path);
}

static int lua_LoadScript( lua_State* _state )
{
	FC_LUA_ASSERT_NUMPARAMS(1);
	FC_LUA_ASSERT_TYPE(1, LUA_TSTRING);
	
	common_LoadScriptForState(lua_tostring(_state, -1), _state, false);
	return 0;
}

static int lua_LoadScriptOptional( lua_State* _state )
{
	FC_LUA_ASSERT_NUMPARAMS(1);
	FC_LUA_ASSERT_TYPE(1, LUA_TSTRING);
	
	common_LoadScriptForState(lua_tostring(_state, -1), _state, true);
	return 0;
}

#pragma mark - Internal Interface

static int panic (lua_State* _state) {
	(void)_state;  /* to avoid warnings */
	const char* pString = lua_tostring(_state, -1);
	FCLua_DumpStack(_state);
	FC_FATAL( std::string("PANIC: unprotected error in call to Lua API: ") + pString );
	return 0;
}

FCLuaVM::FCLuaVM()
{
	m_state = lua_newstate(FCLuaAlloc, NULL);

	FC_ASSERT(m_state);
	
	if (m_state) {
		lua_atpanic(m_state, &panic);
	}
	RegisterCFunction(lua_LoadScript, "FCLoadScript");
	RegisterCFunction(lua_LoadScriptOptional, "FCLoadScriptOptional");
}

FCLuaVM::~FCLuaVM()
{
	lua_close(m_state);
}

void FCLuaVM::LoadScript( std::string path )
{
	FCLog(std::string("Loading Lua script: ") + path );
	common_LoadScriptForState(path, m_state, false);
}

void FCLuaVM::LoadScriptOptional( std::string path )
{
	common_LoadScriptForState(path, m_state, true);
}

void FCLuaVM::ExecuteLine( std::string line )
{
	int ret = luaL_loadbuffer(m_state, line.c_str(), line.size(), "Injected");
	
	switch (ret) {
		case LUA_ERRSYNTAX:
			FC_FATAL( std::string("Syntax error on load of Lua line: ") + line);
			break;			
		case LUA_ERRMEM:
			FC_FATAL( std::string("Memory error on load of Lua line: ") + line);
			break;			
		default:
			break;
	}
	
	ret = lua_pcall(m_state, 0, 0, 0);
	
	switch (ret) {
		case LUA_ERRRUN:
			FCLua_DumpStack(m_state);
			FC_FATAL( std::string("Runtime error in Lua line: ") + line);
			break;
		case LUA_ERRMEM:
			FC_FATAL( std::string("Memory error in Lua line: ") + line);
			break;
		case LUA_ERRERR:
			FC_FATAL( std::string("Error while running error handling function in Lua line: ") + line);
			break;
		default:
			break;
	}	
}

void FCLuaVM::AddStandardLibraries()
{
	luaL_openlibs(m_state);
}

void FCLuaVM::CreateGlobalTable( std::string tableName )
{
	FCStringVector components = FCStringUtils_ComponentsSeparatedByString(tableName, ".");
	
	uint32_t numComponents = components.size();
	
	for (uint32_t i = 0; i < numComponents - 1; i++) 
	{
		if (i == 0) 
		{
			lua_getglobal(m_state, components[i].c_str());
		} 
		else 
		{
			lua_getfield(m_state, -1, components[i].c_str());
		}
	}
	
	lua_newtable(m_state);
	
	FC_LOG(components[numComponents - 1].c_str());
	
	if (numComponents == 1) {
		lua_setglobal(m_state, components[numComponents - 1].c_str());
	} else {
		lua_setfield(m_state, -2, components[numComponents - 1].c_str());
	}	
}

void FCLuaVM::DestroyGlobalTable( std::string tableName )
{
	FCStringVector components = FCStringUtils_ComponentsSeparatedByString(tableName, ".");
	
	uint32_t numComponents = components.size();
	
	for (uint32_t i = 0; i < numComponents - 1; i++) {
		if (i == 0) {
			lua_getglobal(m_state, components[i].c_str());
		} else {
			lua_getfield(m_state, -1, components[i].c_str());
		}
	}
	
	lua_pushnil(m_state);
	
	if (numComponents == 1) {
		lua_setglobal(m_state, components[numComponents - 1].c_str() );
	} else {
		lua_setfield(m_state, -2, components[numComponents - 1].c_str());
	}
}

void FCLuaVM::RegisterCFunction( tLuaCallableCFunction func, std::string name )
{
	FCStringVector	components = FCStringUtils_ComponentsSeparatedByString( name, "." );
	
	uint32_t numComponents = components.size();
	
	for (uint32_t i = 0; i < numComponents - 1; i++) {
		if (i == 0) {
			lua_getglobal(m_state, components[i].c_str());
		} else {
			lua_getfield(m_state, -1, components[i].c_str());
		}
	}
	
	lua_pushcfunction(m_state, func);
	
	if (numComponents == 1) {
		lua_setglobal(m_state, components[numComponents - 1].c_str());
	} else {
		lua_setfield(m_state, -2, components[numComponents - 1].c_str());
	}
	
	lua_pop(m_state, (int)(numComponents - 1));	
}

void FCLuaVM::RemoveCFunction( std::string name )
{
	FCStringVector components = FCStringUtils_ComponentsSeparatedByString(name, ".");
	
	uint32_t numComponents = components.size();
	
	for (uint32_t i = 0; i < numComponents - 1; i++) {
		if (i == 0) {
			lua_getglobal(m_state, components[i].c_str());
		} else {
			lua_getfield(m_state, -1, components[i].c_str());
		}
	}
	
	lua_pushnil(m_state);
	
	if (numComponents == 1) {
		lua_setglobal(m_state, components[numComponents - 1].c_str() );
	} else {
		lua_setfield(m_state, -2, components[numComponents - 1].c_str() );
	}
	
	lua_pop(m_state, (int)(numComponents - 1));	
}

int FCLuaVM::GetStackSize()
{
	return lua_gettop(m_state);
}


// should get rid of these.

//	long GlobalNumber( std::string name );
// GlobalColor...	
//	void SetGlobalInteger( std::string name, int number );
void FCLuaVM::SetGlobalNumber( std::string name, double number )
{
	lua_pushnumber(m_state, number);
	lua_setglobal(m_state, name.c_str());
}

void FCLuaVM::SetGlobalBool( std::string name, bool value )
{
	FCStringVector components = FCStringUtils_ComponentsSeparatedByString(name, ".");
	
	uint32_t numComponents = components.size();
	
	for (uint32_t i = 0; i < numComponents - 1; i++) {
		if (i == 0) {
			lua_getglobal(m_state, components[i].c_str());
		} else {
			lua_getfield(m_state, -1, components[i].c_str());
		}
	}
	
	lua_pushboolean(m_state, value);
	
	if (numComponents == 1) {
		lua_setglobal(m_state, components[numComponents - 1].c_str());
	} else {
		lua_setfield(m_state, -2, components[numComponents - 1].c_str());
	}
	
	lua_pop(m_state, (int)(numComponents - 1));	
}

void FCLuaVM::CallFuncWithSig( std::string func, bool required, std::string sig, ... )
{
	va_list vl;
	int narg, nres;
	
	va_start(vl, sig);
	
	FCStringVector components = FCStringUtils_ComponentsSeparatedByString(func, ".");
	
	lua_getglobal(m_state, components[0].c_str());
	
	if (lua_isnil(m_state, -1)) {
		if (required) {
			FC_FATAL( std::string("Can't find function: ") + func);
		} else {
			lua_pop(m_state, lua_gettop(m_state));
			FC_ASSERT(lua_gettop(m_state) == 0);
			return;
		}
	}
	
	uint32_t numComponents = components.size();
	uint32_t numExtraStackPopsNeeded = 0;
	
	for (uint32_t i = 1; i < numComponents; i++) {
		lua_getfield(m_state, -1, components[i].c_str());
		numExtraStackPopsNeeded++;
	}
	
	if (!lua_isfunction(m_state, -1)) {
		if (required) {
			FC_FATAL( std::string("Calling a function defined in Lua: ") + func);
		} else
		{
			lua_pop(m_state, lua_gettop(m_state));
			FC_ASSERT(lua_gettop(m_state) == 0);
			return;
		}
	}
	
	const char* csig = sig.c_str();
	
	for (narg = 0; *csig; narg++) {
		luaL_checkstack(m_state, 1, "too many arguments");
		switch (*csig) {
			case 'f': /* float argument */
				lua_pushnumber(m_state, va_arg(vl, double));
				break;
			case 'i': /* integer argument */
				lua_pushinteger(m_state, va_arg(vl, int));
				break;
			case 's': /* string argument */
				lua_pushstring(m_state, va_arg(vl, char*));
				break;
			case 'b': /* bool argument */
//				lua_pushboolean(m_state, va_arg(vl, bool));
				lua_pushboolean(m_state, va_arg(vl, int));
				break;
			case 't': /* table argument */
			{
				char* tableName = va_arg(vl, char*);
				lua_getglobal(m_state, tableName);
				if (!lua_istable(m_state, -1)) 
				{
					FC_FATAL( std::string("Trying to pass table argument which is not a table: ") + tableName);
				}					
				break;
			}
			case '>':
				csig++;
				goto endargs;
			default:
				FC_FATAL(std::string("ERROR - invalid signature option to 'call': " + *csig));
				break;
		}
		csig++;
	}
	
endargs:
	
	nres = (int)strlen(csig);
	
	if (lua_pcall(m_state, narg, nres, 0) != 0) {
		FC_LOG( std::string("Error calling ") + func + " : " + lua_tostring(m_state, -1));
		DumpCallstack();
		FC_HALT;
	}
	
	//
	
	nres = -nres;
	
	while (*csig) {
		switch (*csig++) {
			case 'f': /* float result */
				FC_ASSERT(lua_type(m_state, nres) == LUA_TNUMBER);
				*va_arg(vl, float*) = (float)lua_tonumber(m_state, nres);
				break;
				
			case 'i': /* int result */
				FC_ASSERT(lua_type(m_state, nres) == LUA_TNUMBER);
				*va_arg(vl, int*) = (int)lua_tointeger(m_state, nres);
				break;
				
			case 's': /* string result */
				FC_ASSERT(lua_type(m_state, nres) == LUA_TSTRING);
				*va_arg(vl, const char **) = lua_tostring(m_state, nres);
				break;
				
			case 'b': /* boolean result */
				FC_ASSERT(lua_type(m_state, nres) == LUA_TBOOLEAN);
				*va_arg(vl, bool*) = lua_toboolean(m_state, nres);
				break;
				
			default:
				FC_FATAL( "Unknown Lua function return type" );
				break;
		}
		nres++;
	}
	
	lua_pop(m_state, lua_gettop(m_state));
	
	FC_ASSERT(lua_gettop(m_state) == 0);
	
	va_end(vl);
}

void FCLuaVM::DumpStack()
{
	FCLua_DumpStack( m_state );
}

void FCLuaVM::DumpCallstack()
{
	lua_Debug entry;
	int depth = 0;
	
	while (lua_getstack(m_state, depth, &entry)) {
		int status = lua_getinfo(m_state, "Sln", &entry);
		if (!status) {
			FC_FATAL("ERROR in dumpCallstack");
		}
		std::stringstream ss;
		ss << entry.short_src;
		ss << "(";
		ss << entry.currentline;
		ss << "): ";
		ss << entry.name;

		FC_LOG( ss.str() );
		depth++;
	}
}
