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

#ifndef CR1_FCGLShaderProgram_h
#define CR1_FCGLShaderProgram_h

#include "Shared/Graphics/FCGraphics.h"

#include "GLES/FCGL.h"
#include "GLES/FCGLShader.h"
#include "GLES/FCGLShaderAttribute.h"
#include "GLES/FCGLShaderUniform.h"

class FCGLMesh;

class FCGLShaderProgram
{
public:
	FCGLShaderProgram( FCGLShaderRef vertexShader, FCGLShaderRef fragmentShader );
	virtual ~FCGLShaderProgram();
	
	FCGLShaderUniformRef GetUniform( std::string name );
	void SetUniformValue( FCGLShaderUniformRef uniform, void* pValues, uint32_t size );
	GLuint	GetAttribLocation( std::string name );
	
	void ProcessUniforms();
	void ProcessAttributes();
	
	void Use();
	void Validate();
	FCGLShaderAttributeRefVec	GetActiveAttributes();
	uint32_t	Stride(){ return m_stride; }
	GLuint		GLHandle(){ return m_glHandle; }

	virtual void BindUniformsWithMesh( FCGLMesh* mesh ){ FC_HALT; };
	virtual void BindAttributes(){ FC_HALT; };

protected:
	GLuint							m_glHandle;
	FCGLShaderRef					m_vertexShader;
	FCGLShaderRef					m_fragmentShader;
	FCGLShaderAttributeRefMapByString	m_attributes;
	FCGLShaderUniformRefMapByString	m_uniforms;
	uint32_t						m_stride;
};

typedef FCSharedPtr<FCGLShaderProgram> FCGLShaderProgramRef;

typedef std::map<std::string, FCGLShaderProgramRef> FCGLShaderProgramRefMapByString;
typedef FCGLShaderProgramRefMapByString::iterator	FCGLShaderProgramRefMapByStringIter;
typedef std::vector<FCGLShaderProgramRef>			FCGLShaderProgramRefVec;
typedef FCGLShaderProgramRefVec::iterator			FCGLShaderProgramRefVecIter;
typedef FCGLShaderProgramRefVec::const_iterator		FCGLShaderProgramRefVecConstIter;

#endif

