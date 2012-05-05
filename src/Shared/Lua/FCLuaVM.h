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

#ifndef CR1_FCLuaVM_h
#define CR1_FCLuaVM_h

#include <string>
#include "Shared/Core/FCSharedPtr.h"

extern "C" {
#include <lua.h>
}

class luaL_Reg;
typedef int(*tLuaCallableCFunction)(lua_State*);

class FCLuaVM {
public:
	FCLuaVM();
	~FCLuaVM();
	
	lua_State* State(){ return m_state; }
	
	void LoadScript( std::string path );
	void LoadScriptOptional( std::string path );
	void ExecuteLine( std::string line );
	void AddStandardLibraries();
	void CreateGlobalTable( std::string tableName );
	void DestroyGlobalTable( std::string tableName );
	void RegisterCFunction( tLuaCallableCFunction func, std::string name );
	void RemoveCFunction( std::string name );
	
	int GetStackSize();
	
	// should get rid of these.
	
//	long GlobalNumber( std::string name );
	 // GlobalColor...	
//	void SetGlobalInteger( std::string name, int number );
	void SetGlobalNumber( std::string name, double number );
	void SetGlobalBool( std::string name, bool value );
	// SetGlobalColor...

	void CallFuncWithSig( std::string func, bool required, std::string sig, ... );
	
	void DumpStack();
	void DumpCallstack();
	
private:
	lua_State* m_state;
};

typedef FCSharedPtr<FCLuaVM> FCLuaVMPtr;

#endif
