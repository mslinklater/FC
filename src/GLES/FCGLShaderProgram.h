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

#ifndef CR1_FCGLShaderProgram_h
#define CR1_FCGLShaderProgram_h

#include "GLES/FCGL.h"
#include "GLES/FCGLShader.h"
#include "GLES/FCGLShaderAttribute.h"
#include "GLES/FCGLShaderUniform.h"

class FCGLShaderProgram
{
public:
	FCGLShaderProgram( FCGLShaderPtr vertexShader, FCGLShaderPtr fragmentShader );
	virtual ~FCGLShaderProgram();
	
	FCGLShaderUniformPtr GetUniform( std::string name );
	void SetUniformValue( FCGLShaderUniformPtr uniform, void* pValues, uint32_t size );
	GLuint	GetAttribLocation( std::string name );
	
	void Use();
	void Validate();
	void BindUniformsWithMesh( FCGLMeshPtr mesh );
	void BindAttributes();
	FCGLShaderAttributePtrVec	GetActiveAttributes();
	
private:
	GLuint							m_glHandle;
	FCGLShaderPtr					m_vertexShader;
	FCGLShaderPtr					m_fragmentShader;
	FCGLShaderAttributeMapByString	m_attributes;
	FCGLShaderUniformMapByString	m_uniforms;
	uint32_t						m_stride;
};

#endif
#endif