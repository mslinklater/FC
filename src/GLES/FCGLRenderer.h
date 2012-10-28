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

#ifndef _FCGLRenderer_h
#define _FCGLRenderer_h

#include "Shared/Graphics/FCGraphics.h"

#include "Shared/Graphics/FCRenderer.h"
#include "GLES/FCGLModel.h"

class FCGLRenderer : public IFCRenderer
{
public:
	FCGLRenderer( std::string name);
	virtual ~FCGLRenderer();
	
	void Init( std::string );	// not used ?
	void Render();
	void AddToGatherList( FCActorRef actor );
	void RemoveFromGatherList( FCActorRef actor );
private:
	std::string		m_name;
	FCActorRefVec	m_gatherList;
};

#endif
