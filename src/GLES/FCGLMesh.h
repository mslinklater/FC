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

#ifndef _FCGLMesh_h
#define _FCGLMesh_h

#include "Shared/Graphics/FCGraphics.h"

#include "Shared/Core/FCCore.h"
#include "FCGLShaderProgram.h"

class FCGLModel;

class FCGLMesh
{
public:
	FCGLMesh( std::string shaderName, GLenum primitiveType );
	virtual ~FCGLMesh();
	
	void Render();
	
	uint16_t*	PIndexBufferAtIndex( uint16_t index );
	
	FCGLModel*	ParentModel(){ return m_pParentModel; }
	void		SetParentModel( FCGLModel* pParent ){ m_pParentModel = pParent; }

	uint32_t	VertexBufferStride(){ return m_vertexBufferStride; }
	
	uint32_t	NumVertices(){ return m_numVertices; }
	void		SetNumVertices( uint32_t numVertices );
	
	uint32_t	NumTriangles(){ return m_numTriangles; }
	void		SetNumTriangles( uint32_t numTriangles );
	
	uint32_t	NumEdges(){ return m_numEdges; }
	void		SetNumEdges( uint32_t numEdges );
	
	FCGLShaderProgramRef	ShaderProgram(){ return m_shaderProgram; }
	
	uint32_t	VertexBufferSize(){ return m_sizeVertexBuffer; }
	
	void*		VertexBuffer(){ return m_pVertexBuffer; }
	
	uint32_t	IndexBufferSize(){ return m_sizeIndexBuffer; }
	
	uint16_t*	IndexBuffer(){ return m_pIndexBuffer; }
	
	GLuint		VertexBufferHandle(){ return m_vertexBufferHandle; }
	
	GLuint		IndexBufferHandle(){ return m_indexBufferHandle; }
	
	bool		FixedUp(){ return m_fixedUp; }
	
	GLenum		PrimitiveType(){ return m_primitiveType; }
	
	FCColor4f	DiffuseColor(){ return m_diffuseColor; }
	void		SetDiffuseColor( FCColor4f& color ){ m_diffuseColor = color; }

	FCColor4f	SpecularColor(){ return m_specularColor; }
	void		SetSpecularColor( FCColor4f& color ){ m_specularColor = color; }
	
private:
	
	void	FixUpBuffers();
	
	FCGLModel*				m_pParentModel;
	uint32_t				m_vertexBufferStride;
	uint32_t				m_numVertices;
	uint32_t				m_numTriangles;
	uint32_t				m_numEdges;
	FCGLShaderProgramRef	m_shaderProgram;
	uint32_t				m_sizeVertexBuffer;
	void*					m_pVertexBuffer;
	uint32_t				m_sizeIndexBuffer;
	uint16_t*				m_pIndexBuffer;
	GLuint					m_vertexBufferHandle;
	GLuint					m_indexBufferHandle;
	bool					m_fixedUp;
	GLenum					m_primitiveType;
	
	FCColor4f				m_diffuseColor;
	FCColor4f				m_specularColor;
};

typedef FCSharedPtr<FCGLMesh>		FCGLMeshRef;
typedef std::vector<FCGLMeshRef>		FCGLMeshRefVec;
typedef FCGLMeshRefVec::iterator		FCGLMeshRefVecIter;
typedef FCGLMeshRefVec::const_iterator	FCGLMeshRefVecConstIter;

typedef FCGLMesh*						FCGLMeshPtr;
typedef std::vector<FCGLMeshPtr>		FCGLMeshPtrVec;
typedef FCGLMeshPtrVec::iterator		FCGLMeshPtrVecIter;
typedef FCGLMeshPtrVec::const_iterator	FCGLMeshPtrVecConstIter;

#endif
