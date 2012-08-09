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

#include "FCGLShaderProgram.h"
#include "FCGLShader.h"

FCGLShaderProgram::FCGLShaderProgram( FCGLShaderRef vertexShader, FCGLShaderRef fragmentShader )
{
	m_glHandle = FCglCreateProgram();
	
	FC_ASSERT( m_glHandle );
	
	m_vertexShader = vertexShader;
	m_fragmentShader = fragmentShader;
	
	FCglAttachShader( m_glHandle, vertexShader->Handle() );
	FCglAttachShader( m_glHandle, fragmentShader->Handle() );
	
	FCglLinkProgram( m_glHandle );
	
	GLint linked;
	
	FCglGetProgramiv( m_glHandle, GL_LINK_STATUS, &linked );
	
	if (!linked) 
	{
		GLint infoLen = 0;
		
		FCglGetProgramiv( m_glHandle, GL_INFO_LOG_LENGTH, &infoLen);
		
		if (infoLen > 1) {
			char* infoLog = (char*)malloc(sizeof(char) * infoLen);
			FCglGetProgramInfoLog( m_glHandle, infoLen, NULL, infoLog);
			FC_FATAL( std::string("Linking program: ") + infoLog );
			free(infoLog);
		}
		
		FCglDeleteProgram( m_glHandle );
	}

	ProcessUniforms();
	ProcessAttributes();
//	GetActiveAttributes();
}

FCGLShaderProgram::~FCGLShaderProgram()
{
	FCglDeleteProgram( m_glHandle );
}

FCGLShaderUniformRef FCGLShaderProgram::GetUniform( std::string name )
{
	FCGLShaderUniformRefMapByStringIter i = m_uniforms.find( name );
	
	if (i == m_uniforms.end()) {
		return FCGLShaderUniformRef( 0 );
	}
	
	return i->second;
}

void FCGLShaderProgram::SetUniformValue( FCGLShaderUniformRef uniform, void* pValues, uint32_t size )
{
	FCglUseProgram( m_glHandle );
	
	switch (uniform->Type()) 
	{
		case GL_FLOAT:
			FC_ASSERT(size == sizeof(GLfloat) * uniform->Num());
			FCglUniform1fv(uniform->Location(), uniform->Num(), (GLfloat*)pValues);
			break;
		case GL_FLOAT_VEC2:
			FC_ASSERT(size == sizeof(GLfloat) * 2 * uniform->Num());
			FCglUniform2fv(uniform->Location(), uniform->Num(), (GLfloat*)pValues);
			break;
		case GL_FLOAT_VEC3:
			FC_ASSERT(size == sizeof(GLfloat) * 3 * uniform->Num());
			FCglUniform3fv(uniform->Location(), uniform->Num(), (GLfloat*)pValues);
			break;
		case GL_FLOAT_VEC4:
			FC_ASSERT(size == sizeof(GLfloat) * 4 * uniform->Num());
			FCglUniform4fv(uniform->Location(), uniform->Num(), (GLfloat*)pValues);
			break;
			
		case GL_INT:
			FC_ASSERT(size == sizeof(GLint) * uniform->Num());
			FCglUniform1iv(uniform->Location(), uniform->Num(), (GLint*)pValues);
			break;
		case GL_INT_VEC2:
			FC_ASSERT(size == sizeof(GLint) * 2 * uniform->Num());
			FCglUniform2iv(uniform->Location(), uniform->Num(), (GLint*)pValues);
			break;
		case GL_INT_VEC3:
			FC_ASSERT(size == sizeof(GLint) * 3 * uniform->Num());
			FCglUniform3iv(uniform->Location(), uniform->Num(), (GLint*)pValues);
			break;
		case GL_INT_VEC4:
			FC_ASSERT(size == sizeof(GLint) * 4 * uniform->Num());
			FCglUniform4iv(uniform->Location(), uniform->Num(), (GLint*)pValues);
			break;
			
		case GL_FLOAT_MAT2:
			FC_ASSERT(size == sizeof(GLfloat) * 4 * uniform->Num());
			FCglUniformMatrix2fv(uniform->Location(), uniform->Num(), GL_FALSE, (GLfloat*)pValues);
			break;			
		case GL_FLOAT_MAT3:
			FC_ASSERT(size == sizeof(GLfloat) * 9 * uniform->Num());
			FCglUniformMatrix3fv(uniform->Location(), uniform->Num(), GL_FALSE, (GLfloat*)pValues);
			break;
		case GL_FLOAT_MAT4:
			FC_ASSERT(size == sizeof(GLfloat) * 16 * uniform->Num());
			FCglUniformMatrix4fv(uniform->Location(), uniform->Num(), GL_FALSE, (GLfloat*)pValues);
			break;
			
		default:
//			NSString* uniformType = [NSString stringWithUTF8String:FCGLStringForEnum(uniform->Type()).c_str()];
			FC_FATAL( std::string("unknown uniform type:") + FCGLStringForEnum(uniform->Type()) );
			break;
	}	
}

GLuint FCGLShaderProgram::GetAttribLocation( std::string name )
{
	return FCglGetAttribLocation( m_glHandle, name.c_str() );
}

void FCGLShaderProgram::ProcessUniforms()
{
	GLint numUniforms;
	FCglGetProgramiv( m_glHandle, GL_ACTIVE_UNIFORMS, &numUniforms );
	
	GLint uniformMax;	
	FCglGetProgramiv( m_glHandle, GL_ACTIVE_UNIFORM_MAX_LENGTH, &uniformMax );
	
	GLchar* uniformNameBuffer = (GLchar*)malloc(sizeof(GLchar) * uniformMax );
	
	for (GLint iUniform = 0; iUniform < numUniforms; iUniform++) 
	{
		GLsizei length;
		GLint num;
		GLenum type;
		GLint location;
		
		FCglGetActiveUniform( m_glHandle, iUniform, uniformMax, &length, &num, &type, uniformNameBuffer);
		
		location = FCglGetUniformLocation( m_glHandle, uniformNameBuffer);
		
		FCGLShaderUniformRef uniform = FCGLShaderUniformRef( new FCGLShaderUniform );
		
		uniform->SetLocation( location );
		uniform->SetNum( num );
		uniform->SetType( type );
		
		m_uniforms[ uniformNameBuffer ] = uniform;
	}
	
	free(uniformNameBuffer);
}

void FCGLShaderProgram::ProcessAttributes()
{
	GLint numActive;
	GLint maxLength;
	
	FCglGetProgramiv( m_glHandle, GL_ACTIVE_ATTRIBUTES, &numActive );
	FCglGetProgramiv( m_glHandle, GL_ACTIVE_ATTRIBUTE_MAX_LENGTH, &maxLength );
	
	char* attributeNameBuffer = (char*)malloc(sizeof(char) * maxLength);
	
	for (int i = 0; i < numActive; i++) 
	{
		GLsizei sizeWritten;
		GLint size;
		GLenum type;
		
		FCglGetActiveAttrib( m_glHandle, i, maxLength, &sizeWritten, &size, &type, attributeNameBuffer );
		
		FCGLShaderAttributeRef attribute = FCGLShaderAttributeRef( new FCGLShaderAttribute );
		
		attribute->SetLocation( FCglGetAttribLocation( m_glHandle, attributeNameBuffer ) );
		attribute->SetType( type );
		attribute->SetNum( size );
		
		m_attributes[ attributeNameBuffer ] = attribute;		
	}
	
	free( attributeNameBuffer );

}

void FCGLShaderProgram::Use()
{
	FCglUseProgram( m_glHandle );
}

void FCGLShaderProgram::Validate()
{
	FCglValidateProgram( m_glHandle );
	
	GLint status;
	
	FCglGetProgramiv( m_glHandle, GL_VALIDATE_STATUS, &status );
	
	if (!status) 
	{
		GLint infoLen = 0;
		
		FCglGetProgramiv( m_glHandle, GL_INFO_LOG_LENGTH, &infoLen );
		
		if (infoLen > 1) {
			char* infoLog = (char*)malloc(sizeof(char) * infoLen);
			FCglGetProgramInfoLog( m_glHandle, infoLen, NULL, infoLog );
			FC_FATAL( std::string("Validate fail:") + infoLog );
			free( infoLog );
		}		
	}

}

//void FCGLShaderProgram::BindUniformsWithMesh( FCGLMeshPtr mesh )
//{
//	FC_HALT;
//}
//
//void FCGLShaderProgram::BindAttributes()
//{
//	
//}

FCGLShaderAttributeRefVec FCGLShaderProgram::GetActiveAttributes()
{
	FC_HALT;
	
	FCGLShaderAttributeRefVec ret;

	GLint numActive;
//	GLint maxLength;
	
	FCglGetProgramiv( m_glHandle, GL_ACTIVE_ATTRIBUTES, &numActive );
	
//	[attribArray addObject:[NSString stringWithFormat:@"Num active attributes: %d", numActive]];
//	
//	FCglGetProgramiv(self.glHandle, GL_ACTIVE_ATTRIBUTE_MAX_LENGTH, &maxLength);
//	
//	char* pBuffer = (char*)malloc(sizeof(char) * maxLength);
//	
//	for (int i = 0; i < numActive; i++) {
//		GLsizei sizeWritten;
//		GLint size;
//		GLenum type;
//		FCglGetActiveAttrib(self.glHandle, i, maxLength, &sizeWritten, &size, &type, pBuffer);
//		
//		[attribArray addObject:[NSString stringWithFormat:@"%d %s %d x %s", i, pBuffer, size, FCGLStringForEnum(type).c_str()]];
//	}
//	
//	free( pBuffer );
	
	return ret;
}
