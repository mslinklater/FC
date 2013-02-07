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

#if 0

#ifndef FCGLView_h
#define FCGLView_h

#include "Shared/Core/FCCore.h"

class FCGLView : public FCBase
{
public:
	FCGLView( std::string name, std::string parent, const FCVector2i& size );
	virtual ~FCGLView();
	
	virtual void Update( float dt );
	virtual void SetDepthBuffer( bool enabled );
	virtual void SetRenderTarget( FCVoidVoidFuncPtr func );
	virtual void SetFrameBuffer();
	virtual void Clear();
	virtual void SetProjectionMatrix();
	virtual void PresentFramebuffer();
	virtual FCVector2f ViewSize();
	virtual FCVector3f PosOnPlane( const FCVector2f& point );
	virtual void SetClearColor( const FCColor4f& color );
	virtual void SetFOV( float fov );
	virtual void SetNearClip( float clip );
	virtual void SetFarClip( float clip );
	virtual void SetFrustumTranslation( const FCVector3f& trans );
protected:
	std::string	m_name;
};

typedef FCSharedPtr<FCGLView> FCGLViewRef;
typedef std::map<std::string, FCGLViewRef>	FCGLViewMap;

extern FCGLViewRef plt_FCGLView_Create( std::string name, std::string parent, const FCVector2i& size );

#endif

#endif
