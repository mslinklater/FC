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

#ifndef FCRenderManager_h
#define FCRenderManager_h

#include <map>
#include "Shared/Core/FCCore.h"
#include "Shared/Graphics/FCRenderer.h"

class FCRenderManager {
public:
	static FCRenderManager* Instance();

	FCRenderManager();
	virtual ~FCRenderManager();
	
	void Reset();
	
	FCHandle CreateRenderer( std::string name, std::string initFunc );
	void DestroyRenderer( FCHandle h );
	
	void SetFrameRate( FCHandle hRenderer, float rate );
	
	void ViewReadyToRender( std::string name );
	void ViewReadyToInit( std::string name );
	void SetRenderFunc( FCHandle h, std::string renderFunc );
	
private:
	
	typedef std::map<FCHandle, FCRenderer*>	FCRendererMapByHandle;
	typedef FCRendererMapByHandle::iterator		FCRendererMapByHandleIter;
	
	typedef std::map<FCRenderer*, std::string>	FCNameByRenderer;
	
	typedef std::map<std::string, FCRenderer*> FCRendererByName;
	
	FCRendererMapByHandle	m_renderersByHandle;
	FCNameByRenderer		m_namesByRenderer;
	FCRendererByName		m_renderersByName;
	FCStringHandleMap		m_handleByName;
	
	FCHandleStringMap		m_renderFuncByHandle;
	FCHandleStringMap		m_initFuncByHandle;
};

#endif
