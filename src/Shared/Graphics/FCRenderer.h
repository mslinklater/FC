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

#ifndef FCRenderer_h
#define FCRenderer_h

#include "FCGraphics.h"

#include "Shared/Core/FCCore.h"

class FCViewport;

class FCRenderer {
public:
	
	static void RegisterLuaFuncs();
	
	FCRenderer( std::string name );
	virtual ~FCRenderer();
	
	virtual void BeginInit( void );
	virtual void EndInit( void );

	virtual void BeginRender( void );
	virtual void EndRender( void );
	
	// test stuff
	
	virtual void RenderTestSquare( void );
	
	// proper stuff
	
	void SetBackgroundColor( FCColor4f& color );
	void SetCamera( FCHandle h );
	
protected:

	FCViewport*			m_pViewport;
	
	FCColor4f	m_backgroundColor;
};




#endif
