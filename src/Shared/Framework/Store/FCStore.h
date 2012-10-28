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

#ifndef _FCStore_h
#define _FCStore_h

#include "Shared/Core/FCCore.h"
#include "FCStoreItem.h"

class FCStore {
public:
	static FCStore* Instance();
	
	FCStore();
	virtual ~FCStore();
	
	void WarmBoot();
	bool Available();

	void GetStoreItemDetailsWithLuaCallbacks( FCStringVector items, std::string luaCallback, std::string luaError );
	
	void ClearStoreItems();
	void AddStoreItem( std::string description, std::string price, std::string identifier );
	void EndStoreItems();

	void PurchaseRequest( std::string identifier, std::string luaSuccess, std::string luaError );
	
	void PurchaseSuccessful( std::string identifier );
	void PurchaseFailed( std::string identifier );
	
private:
	std::string m_storeItemDetailsLauCallback;
	std::string m_storeItemDetailsLuaError;
	
	FCStoreItemVec	m_storeItems;
	
	std::string m_purchaseSuccessLuaCallback;
	std::string m_purchaseFailLuaCallback;
};

#endif
