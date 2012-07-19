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

#include "Shared/Graphics/FCGraphics.h"

#include <string>

#include "FCGLTextureFile.h"
#include "FCGLTextureFilePVR.h"

FCGLTextureFile::FCGLTextureFile( std::string filename )
: m_glHandle(0)
, m_hookCount(0)
, m_filename("")
, m_sourceFormat( kFCTextureFileSourceUnknown )
{
	m_filename = filename;
	
	size_t dotPos = m_filename.find(".");
	
	FC_ASSERT_MSG( dotPos != std::string::npos, std::string("No dot in filename: ") + filename );
	
	std::string fileSuffix = m_filename.substr( dotPos + 1 );
	
	if (fileSuffix == "pvr") {
		m_sourceFormat = kFCTextureFileSourcePVR;
		m_delegate = new FCGLTextureFilePVR;
	}
}

FCGLTextureFile::~FCGLTextureFile()
{
	
}

void FCGLTextureFile::Hook()
{
	if (m_hookCount == 0) {
		FCglGenTextures(1, &m_glHandle);
		FCglBindTexture(GL_TEXTURE_2D, m_glHandle);
		
		m_delegate->Load( m_filename );
		
		FCglBindTexture(GL_TEXTURE_2D, m_glHandle);
		
		FCglTexImage2D(GL_TEXTURE_2D, 0, (GLint)m_delegate->Format(), m_delegate->Width(), m_delegate->Height(), 0, m_delegate->Format(), m_delegate->Type(), m_delegate->Data());
	}
	m_hookCount++;
}

void FCGLTextureFile::Unhook()
{
	FC_ASSERT(m_hookCount);
	
	m_hookCount--;
	
	if (m_hookCount == 0) {
		FCglDeleteTextures(1, &m_glHandle);
		m_glHandle = 0;
	}
}

GLuint FCGLTextureFile::GLHandle()
{
	return m_glHandle;
}

