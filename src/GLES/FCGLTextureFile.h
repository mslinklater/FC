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

#ifndef CR1_FCGLTextureFile_h
#define CR1_FCGLTextureFile_h

#include "Shared/Core/FCCore.h"
#include "GLES/FCGL.h"
#include "Shared/Graphics/FCGraphicsTypes.h"

class IFCGLTextureFileDelegate
{
public:	
	IFCGLTextureFileDelegate(){}
	virtual ~IFCGLTextureFileDelegate(){}
	
	virtual void Load( std::string filename ) = 0;
	virtual GLenum	Format() = 0;
	virtual GLsizei	Width() = 0;
	virtual GLsizei	Height() = 0;
	virtual GLenum	Type() = 0;
	virtual void*	Data() = 0;
};

class FCGLTextureFile
{
public:
	FCGLTextureFile( std::string filename );
	virtual ~FCGLTextureFile();
	
	void	Hook();
	void	Unhook();
	GLuint	GLHandle();

private:
	std::string					m_name;
	void*						m_pData;
	FCVector2i					m_size;
	GLuint						m_glHandle;
	int32_t						m_hookCount;
	eFCTextureFileSourceFormat	m_sourceFormat;
	std::string					m_filename;
	IFCGLTextureFileDelegate*	m_delegate;
};

#endif
