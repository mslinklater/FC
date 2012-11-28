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

#ifndef FCVIEWMANAGER_H
#define FCVIEWMANAGER_H

#include "Shared/Core/FCCore.h"

class FCViewManager : public FCBase
{
public:
	FCViewManager();
	virtual ~FCViewManager();
	
	static FCViewManager* Instance();
	
	void SetViewText( const std::string& viewName, std::string text );
	void SetViewTextColor( const std::string& viewName, FCColor4f color );
	FCRect ViewFrame( const std::string& viewName );
	FCRect FullFrame( );
	void SetViewFrame( const std::string& viewName, const FCRect& rect, float seconds );
	void SetViewAlpha( const std::string& viewName, float alpha, float seconds );
	void SetViewOnSelectLuaFunction( const std::string& viewName, const std::string& func );
	void SetViewImage( const std::string& viewName, const std::string& image );
	void SetViewURL( const std::string& viewName, const std::string& url );
	void SetViewBackgroundColor( const std::string& viewName, const FCColor4f& color );
	void CreateView( const std::string& viewName, const std::string& classType, const std::string& parent );
	void DestroyView( const std::string& viewName );
	void SetViewPropertyInt( const std::string& viewName, const std::string& property, int32_t value );
	void SetViewPropertyFloat( const std::string& viewName, const std::string& property, float value );
	void SetViewPropertyString( const std::string& viewName, const std::string& property, const std::string& value );
	
	void MoveViewToFront( const std::string& viewname );
	void MoveViewToBack( const std::string& viewname );
	bool ViewExists( const std::string& viewName );
	
private:
};

#endif