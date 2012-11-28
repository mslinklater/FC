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

#include "FCStore.h"
#include "FCPlatformInterface.h"
#include "Shared/Lua/FCLua.h"
#include "Shared/Framework/Analytics/FCAnalytics.h"

static FCStore* s_pInstance = 0;

void fc_FCStore_ClearStoreItems()
{
	s_pInstance->ClearStoreItems();
}

void fc_FCStore_AddStoreItem( const char* description, const char* price, const char* identifier )
{
	s_pInstance->AddStoreItem(description, price, identifier);
}

void fc_FCStore_EndStoreItems()
{
	s_pInstance->EndStoreItems();
}

void fc_FCStore_PurchaseSuccessful( const char* identifier )
{
	s_pInstance->PurchaseSuccessful( identifier );
}

void fc_FCStore_PurchaseFailed( const char* identifier )
{
	s_pInstance->PurchaseFailed( identifier );
}

static int lua_StoreAvailable( lua_State* _state )
{
	FC_LUA_FUNCDEF("FCStore.Available()");
	FC_LUA_ASSERT_NUMPARAMS(0);
	
	if (s_pInstance->Available()) {
		lua_pushboolean(_state, 1);
	} else {
		lua_pushboolean(_state, 0);
	}
	return 1;
}

static int lua_PurchaseRequest( lua_State* _state )
{
	FC_LUA_FUNCDEF("FCStore.PurchaseRequest()");
	FC_LUA_ASSERT_NUMPARAMS(3);
	FC_LUA_ASSERT_TYPE(1, LUA_TSTRING);
	FC_LUA_ASSERT_TYPE(2, LUA_TSTRING);
	FC_LUA_ASSERT_TYPE(3, LUA_TSTRING);

	s_pInstance->PurchaseRequest(lua_tostring(_state, 1),
								 lua_tostring(_state, 2),
								 lua_tostring(_state, 3) );
	
	return 0;
}

FCStore* FCStore::Instance()
{
	if (!s_pInstance) {
		s_pInstance = new FCStore;
	}
	return s_pInstance;
}

FCStore::FCStore()
{
	// register LUA interface
	
	FCLuaVM* pLua = FCLua::Instance()->CoreVM();
	
	pLua->CreateGlobalTable("FCStore");
	pLua->RegisterCFunction(lua_StoreAvailable, "FCStore.Available");
	pLua->RegisterCFunction(lua_PurchaseRequest, "FCStore.PurchaseRequest");
}

FCStore::~FCStore()
{
	
}

void FCStore::WarmBoot()
{
	plt_FCStore_WarmBoot();
}

bool FCStore::Available()
{
	return plt_FCStore_Available();
}

void FCStore::GetStoreItemDetailsWithLuaCallbacks( FCStringVector items, std::string luaCallback, std::string luaError )
{
	if(!Available())
	{
		FCLua::Instance()->CoreVM()->CallFuncWithSig(luaError, true, "");
	}
	else
	{
		m_storeItemDetailsLauCallback = luaCallback;
		m_storeItemDetailsLuaError = luaError;
		
		plt_FCStore_ClearItemRequestList();
		for (FCStringVectorConstIter i = items.begin(); i != items.end(); i++) {
			plt_FCStore_AddItemRequest( i->c_str() );
		}
		plt_FCStore_ProcessItemRequestList();
	}
}

void FCStore::ClearStoreItems()
{
	m_storeItems.clear();
}

void FCStore::AddStoreItem( std::string description, std::string price, std::string identifier )
{
	FCStoreItem item;
	item.SetDescription( description );
	item.SetPrice( price );
	item.SetIdentifier( identifier );
	
	m_storeItems.push_back( item );
}

void FCStore::EndStoreItems()
{
	// send to Lua
	
	for( FCStoreItemVecIter i = m_storeItems.begin(); i != m_storeItems.end(); i++ ) {
		FCLua::Instance()->CoreVM()->CallFuncWithSig(m_storeItemDetailsLauCallback, true, "sss>",
													 i->Description().c_str(),
													 i->Price().c_str(),
													 i->Identifier().c_str() );
	}
}

void FCStore::PurchaseRequest(std::string identifier, std::string luaSuccess, std::string luaError)
{
	m_purchaseSuccessLuaCallback = luaSuccess;
	m_purchaseFailLuaCallback = luaError;
	
	plt_FCStore_PurchaseRequest( identifier.c_str() );
}

void FCStore::PurchaseSuccessful( std::string identifier )
{
	FCLua::Instance()->CoreVM()->CallFuncWithSig(m_purchaseSuccessLuaCallback, true, "s>", identifier.c_str());
	FCAnalytics::Instance()->RegisterEvent( identifier );
}

void FCStore::PurchaseFailed( std::string identifier )
{
	FCLua::Instance()->CoreVM()->CallFuncWithSig(m_purchaseFailLuaCallback, true, "s>", identifier.c_str());
}

