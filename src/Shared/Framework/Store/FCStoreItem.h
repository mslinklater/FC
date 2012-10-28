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

#ifndef _FCStoreItem_h
#define _FCStoreItem_h

#include "Shared/Core/FCCore.h"

class FCStoreItem {
public:
	FCStoreItem(){}
	virtual ~FCStoreItem(){}
	
	void SetDescription( std::string desc ){ m_description = desc; }
	void SetPrice( std::string price ){ m_price = price; }
	void SetIdentifier( std::string ident ){ m_identifier = ident; }

	std::string Description(){ return m_description; }
	std::string Price(){ return m_price; }
	std::string Identifier(){ return m_identifier; }
	
private:
	std::string m_description;
	std::string m_price;
	std::string m_identifier;
};

typedef std::vector<FCStoreItem>			FCStoreItemVec;
typedef FCStoreItemVec::iterator	FCStoreItemVecIter;

#endif
