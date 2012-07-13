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

#include "FCGLShader.h"

FCGLShader::FCGLShader( eFCShaderType type, std::string source )
{
	const char* shaderStr = source.c_str();
	GLenum glShaderType;
	
	switch (type) 
	{
		case kShaderTypeFragment:
			glShaderType = GL_FRAGMENT_SHADER;
			break;
		case kShaderTypeVertex:
			glShaderType = GL_VERTEX_SHADER;
			break;				
		default:
			break;
	}
	
	m_glHandle = FCglCreateShader( glShaderType );
	if( m_glHandle == 0 ) 
	{
		FC_FATAL( std::string("glCreateShader failed: ") + source);
	}
	
	FCglShaderSource( m_glHandle, 1, &shaderStr, NULL );
	FCglCompileShader( m_glHandle );
	
	GLint status;
	FCglGetShaderiv( m_glHandle, GL_COMPILE_STATUS, &status );
	
	if (!status) 
	{
		GLint infoLen;
		FCglGetShaderiv( m_glHandle, GL_INFO_LOG_LENGTH, &infoLen );
		if (infoLen > 1) 
		{
			char* infoLog = (char*)malloc(sizeof(char) * infoLen);
			FCglGetShaderInfoLog( m_glHandle, infoLen, NULL, infoLog );
			FC_FATAL( std::string(infoLog) );
			free(infoLog);
		}
		FCglDeleteShader( m_glHandle );
	}
}

FCGLShader::~FCGLShader()
{
	FC_LOG("");
}


