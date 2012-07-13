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

// Not really sure if this is used - hence tha halts

#include "FCGLTextureFilePVR.h"
#include "Shared/Core/FCFile.h"

FCGLTextureFilePVR::~FCGLTextureFilePVR()
{
	m_file.Close();
}

void FCGLTextureFilePVR::Load( std::string filename )
{
	m_file.Open(filename, kFCFileOpenModeReadOnly, kFCFileLocationApplicationBundle);
}

GLenum	FCGLTextureFilePVR::Format()
{
	FC_HALT;
	return GL_RGB;
}

GLsizei	FCGLTextureFilePVR::Width()
{
	FC_HALT;
	return 0;
}

GLsizei	FCGLTextureFilePVR::Height()
{
	FC_HALT;
	return 0;
}

GLenum	FCGLTextureFilePVR::Type()
{
	FC_HALT;
	return GL_RGB;
}

void*	FCGLTextureFilePVR::Data()
{
	FCDataPtr dataPtr = m_file.Data();
	
	return (void*)dataPtr.get();
}
