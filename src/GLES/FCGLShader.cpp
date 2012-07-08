//
//  FCGLShader.cpp
//  CR1
//
//  Created by Martin Linklater on 07/07/2012.
//  Copyright (c) 2012 Curly Rocket Ltd. All rights reserved.
//

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
	
}


