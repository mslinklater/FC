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

#ifndef _FCGLTextureFilePVR_h
#define _FCGLTextureFilePVR_h

#include "Shared/Graphics/FCGraphics.h"

#include "Shared/Core/FCFile.h"
#include "FCGLTextureFile.h"


#ifdef PLATFORM_IOS
#include "PVRTTexture.h"
#endif

#ifdef PLATFORM_ANDROID
// TODO: texture formats on Android need sorting.
class PVR_Texture_Header;
#endif

class FCGLTextureFilePVR : public IFCGLTextureFileDelegate
{
public:
	FCGLTextureFilePVR(){}
	virtual ~FCGLTextureFilePVR();
	
	void Load( std::string filenam );
	GLenum	Format();
	GLsizei	Width();
	GLsizei	Height();
	GLenum	Type();
	void*	Data();
	
private:
	FCDataRef			m_imageData;
	PVR_Texture_Header*	m_pHeader;
	FCFile				m_file;
};


#endif
