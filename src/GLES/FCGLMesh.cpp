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

#include "FCGLMesh.h"
#include "FCGLShaderManager.h"

FCGLMesh::FCGLMesh( std::string shaderName, GLenum primitiveType )
: m_pParentModel(0)
, m_vertexBufferStride(0)
, m_numVertices(0)
, m_numTriangles(0)
, m_numEdges(0)
, m_sizeVertexBuffer(0)
, m_pVertexBuffer(0)
, m_sizeIndexBuffer(0)
, m_pIndexBuffer(0)
, m_vertexBufferHandle(0)
, m_indexBufferHandle(0)
, m_fixedUp(false)
, m_primitiveType(primitiveType)
{
//	m_shaderProgram = FCGLShaderManager::Instance()->Program( shaderName );
//	m_vertexBufferStride = m_shaderProgram->Stride();
}

FCGLMesh::~FCGLMesh()
{
	FCglDeleteBuffers(1, &m_indexBufferHandle);
	FCglDeleteBuffers(1, &m_vertexBufferHandle);
	
	if (m_pIndexBuffer) {
		free( m_pIndexBuffer );
	}
	if (m_pVertexBuffer) {
		free( m_pVertexBuffer );
	}
}

void FCGLMesh::SetNumVertices( uint32_t numVertices )
{
	FC_ASSERT( m_vertexBufferStride );
	FC_ASSERT_MSG( m_numVertices == 0, "numVertices already set - cannot do twice" );
	FC_ASSERT_MSG( m_numVertices < 65535, "Cannot cope with meshes with more than 65535 verts yet");
	
	m_numVertices = numVertices;
	m_sizeVertexBuffer = m_numVertices * m_vertexBufferStride;
	m_pVertexBuffer = malloc( m_sizeVertexBuffer );

}

void FCGLMesh::SetNumTriangles( uint32_t numTriangles )
{
	if( m_primitiveType == GL_TRIANGLES )
	{
		FC_ASSERT_MSG( m_numTriangles == 0, "numTriangles already set - cannot do twice");
		
		m_numTriangles = numTriangles;
		m_sizeIndexBuffer = m_numTriangles * 3 * sizeof(uint16_t);
		m_pIndexBuffer = (uint16_t*)malloc( m_sizeIndexBuffer );		
	}
}

void FCGLMesh::SetNumEdges( uint32_t numEdges )
{
	if( m_primitiveType == GL_LINES )
	{
		FC_ASSERT_MSG( m_numEdges == 0, "numEdges already set - cannot do twice");
		
		m_numEdges = numEdges;
		m_sizeIndexBuffer = m_numEdges * 2 * sizeof(uint16_t);
		m_pIndexBuffer = (uint16_t*)malloc( m_sizeIndexBuffer );		
	}
}

void FCGLMesh::Render()
{
	if (!m_fixedUp) {
		FixUpBuffers();
	}
	
	m_shaderProgram->Use();
	
	FCglBindBuffer( GL_ELEMENT_ARRAY_BUFFER, m_indexBufferHandle );
	FCglBindBuffer( GL_ARRAY_BUFFER, m_vertexBufferHandle );

	m_shaderProgram->BindUniformsWithMesh( this );
	m_shaderProgram->BindAttributes();

#if defined (FC_DEBUG)
	m_shaderProgram->Validate();
#endif
	
	switch (m_primitiveType) {
		case GL_TRIANGLES:
			FCglDrawElements( GL_TRIANGLES, m_numTriangles * 3, GL_UNSIGNED_SHORT, 0 );
			break;
		case GL_LINES:
			FCglDrawElements( GL_LINES, m_numEdges * 2, GL_UNSIGNED_SHORT, 0 );
			break;			
		default:
			FC_HALT;
			break;
	}	
}

void FCGLMesh::FixUpBuffers()
{
	FC_ASSERT( !m_fixedUp );
	
	// build VBOs
	
	FCglGenBuffers( 1, &m_vertexBufferHandle);
	FCglBindBuffer( GL_ARRAY_BUFFER, m_vertexBufferHandle );
	FCglBufferData( GL_ARRAY_BUFFER, m_sizeVertexBuffer, m_pVertexBuffer, GL_STATIC_DRAW );
	
	FCglGenBuffers( 1, &m_indexBufferHandle );
	FCglBindBuffer( GL_ELEMENT_ARRAY_BUFFER, m_indexBufferHandle );
	FCglBufferData( GL_ELEMENT_ARRAY_BUFFER, m_sizeIndexBuffer, m_pIndexBuffer, GL_STATIC_DRAW );
	
	// release working memory
	
	if( m_pVertexBuffer ) 
	{
		free( m_pVertexBuffer );
		m_pVertexBuffer = 0;
	}
	
	if( m_pIndexBuffer ) 
	{
		free( m_pIndexBuffer );
		m_pIndexBuffer = 0;
	}
	
	m_fixedUp = true;
}

uint16_t* FCGLMesh::PIndexBufferAtIndex( uint16_t index )
{
	return m_pIndexBuffer + index;
}

