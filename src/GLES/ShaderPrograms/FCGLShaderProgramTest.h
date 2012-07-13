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

#ifndef CR1_FCGLShaderProgramTest_h
#define CR1_FCGLShaderProgramTest_h

#include "GLES/FCGLShaderProgram.h"

class FCGLShaderProgramTest : public FCGLShaderProgram
{
public:
	FCGLShaderProgramTest( FCGLShaderRef vertexShader, FCGLShaderRef fragmentShader )
	: FCGLShaderProgram( vertexShader, fragmentShader )
	{
		m_stride = 28;
		m_ambientUniform = m_uniforms[ "ambient_color" ];
		m_lightColorUniform = m_uniforms[ "light_color" ];
		
		m_positionAttribute = m_attributes[ "position" ];
		m_normalAttribute = m_attributes[ "normal" ];
		m_diffuseColorAttribute = m_attributes[ "diffuse_color" ];
		m_specularColorAttribute = m_attributes[ "specular_color" ];
	}
	
	virtual ~FCGLShaderProgramTest()
	{
		
	}
	
	void BindUniformsWithMesh( FCGLMesh* mesh )
	{
		FCColor4f ambientColor( 0.25f, 0.25f, 0.25f, 1.0f );
		FCColor4f lightColor( 1.0f, 1.0f, 1.0f, 1.0f );
		
		FCglUniform4fv( m_ambientUniform->Location(), m_ambientUniform->Num(), (GLfloat*)&ambientColor );
		FCglUniform4fv( m_lightColorUniform->Location(), m_lightColorUniform->Num(), (GLfloat*)&lightColor );
	}
	
	void BindAttributes()
	{
		FCglVertexAttribPointer( m_positionAttribute->Location(), 3, GL_FLOAT, GL_FALSE, m_stride, (void*)0);
		FCglEnableVertexAttribArray( m_positionAttribute->Location() );
		
		FCglVertexAttribPointer( m_normalAttribute->Location(), 3, GL_SHORT, GL_TRUE, m_stride, (void*)12);
		FCglEnableVertexAttribArray( m_normalAttribute->Location() );
		
		FCglVertexAttribPointer( m_diffuseColorAttribute->Location(), 4, GL_UNSIGNED_BYTE, GL_TRUE, m_stride, (void*)20);
		FCglEnableVertexAttribArray( m_diffuseColorAttribute->Location() );
		
		FCglVertexAttribPointer( m_specularColorAttribute->Location(), 4, GL_UNSIGNED_BYTE, GL_TRUE, m_stride, (void*)24);
		FCglEnableVertexAttribArray( m_specularColorAttribute->Location() );

	}
	
	FCGLShaderUniformRef	m_ambientUniform;
	FCGLShaderUniformRef	m_lightColorUniform;
	
	FCGLShaderAttributeRef	m_positionAttribute;
	FCGLShaderAttributeRef	m_normalAttribute;
	FCGLShaderAttributeRef	m_diffuseColorAttribute;
	FCGLShaderAttributeRef	m_specularColorAttribute;
};


#endif
