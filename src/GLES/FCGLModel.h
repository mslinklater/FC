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

#ifndef CR1_FCGLModel_h
#define CR1_FCGLModel_h

#include "Shared/Graphics/FCModel.h"
#include "Shared/Core/FCXML.h"
#include "Shared/Core/Resources/FCResource.h"

#include "GLES/FCGLMesh.h"

class FCGLModel : public IFCModel
{
public:
	
	FCGLModel();
	virtual ~FCGLModel();
	
	void InitWithModel( FCXMLNode modelXML, FCResourceRef resource );
	void InitWithPhysics( FCXMLNode physicsXML, FCColor4f& color );
	void SetDebugMeshColor( FCColor4f& color );
	void SetRotation( float rot );
	void SetPosition( FCVector3f& pos );
	FCGLMeshRefVec	Meshes(){ return m_meshes; }
	
	FCVector3f Position(){ return m_pos; }
	float Rotation(){ return m_rotation; }
	
private:
	
	struct DebugCircleInitParams
	{
		FCVector3f	fixture;
		float		radius;
	};
	
	struct DebugRectangleInitParams
	{
		FCVector3f fixture;
		FCVector3f size;
	};
	
	struct DebugPolygonInitParams
	{
		FCVector3f		fixture;
		FCVector3fVec	verts;
	};
	
	void AddDebugRectangle( DebugRectangleInitParams& params, FCColor4f& color );
	void AddDebugCircle( DebugCircleInitParams& params, FCColor4f& color );
	void AddDebugPolygon( DebugPolygonInitParams& params, FCColor4f& color );
	
	FCGLMeshRefVec	m_meshes;
	FCVector3f		m_pos;
	float			m_rotation;
};

typedef std::shared_ptr<FCGLModel>		FCGLModelRef;
typedef std::vector<FCGLModelRef>		FCGLModelRefVec;
typedef FCGLModelRefVec::iterator		FCGLModelRefVecIter;
typedef FCGLModelRefVec::const_iterator	FCGLModelRefVecConstIter;

typedef FCGLModel*						FCGLModelPtr;
typedef std::vector<FCGLModelPtr>		FCGLModelPtrVec;
typedef FCGLModelPtrVec::iterator		FCGLModelPtrVecIter;
typedef FCGLModelPtrVec::const_iterator	FCGLModelPtrVecConstIter;

#endif
