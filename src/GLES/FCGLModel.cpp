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

#include "FCGLModel.h"
#include "Shared/Core/FCStringUtils.h"

FCModelRef plt_FCModel_Create()
{
	return FCModelRef( new FCGLModel );
}

static uint16_t kNumCircleSegments = 36;

FCGLModel::FCGLModel()
: m_pos( FCVector3f(0.0f, 0.0f, 0.0f))
, m_rotation(0.0f)
{
	
}

FCGLModel::~FCGLModel()
{
}

void FCGLModel::InitWithModel( FCXMLNode modelXML, FCResourceRef resource )
{
	FCXMLNodeVec meshArray = FCXML::VectorForChildNodesOfType(modelXML, kFCKeyMesh);
	
	FCXMLNodeVec binaryPayloadArray = resource->XML()->VectorForKeyPath("fcr.binarypayload.chunk");
	
	for (FCXMLNodeVecIter mesh = meshArray.begin(); mesh != meshArray.end(); mesh++)
	{
		std::string shaderName = FCXML::StringValueForNodeAttribute(*mesh, kFCKeyShader);
		
		std::string indexBufferId = FCXML::StringValueForNodeAttribute(*mesh, kFCKeyIndexBuffer);
		std::string vertexBufferId = FCXML::StringValueForNodeAttribute(*mesh, kFCKeyVertexBuffer);
		
		FCXMLNode indexBufferXML = 0;
		FCXMLNode vertexBufferXML = 0;
		
		for (FCXMLNodeVecIter chunk = binaryPayloadArray.begin(); chunk != binaryPayloadArray.end(); chunk++) 
		{
			if (FCXML::StringValueForNodeAttribute(*chunk, kFCKeyId) == indexBufferId) {
				indexBufferXML = *chunk;
			}
			if (FCXML::StringValueForNodeAttribute(*chunk, kFCKeyId) == vertexBufferId) {
				vertexBufferXML = *chunk;
			}
		}
		
		FC_ASSERT( indexBufferXML && vertexBufferXML );
		
		// all looks good so far - lets build the mesh
		
		GLenum primitiveType = GL_TRIANGLES;
		
		if (shaderName == kFCKeyShaderWireframe ) {
			primitiveType = GL_LINES;
		}
		
		FCGLMeshRef meshObject = FCGLMeshRef( new FCGLMesh( shaderName, primitiveType ) );

		meshObject->SetNumVertices( FCXML::IntValueForNodeAttribute(*mesh, kFCKeyNumVertices) );
		meshObject->SetNumTriangles( FCXML::IntValueForNodeAttribute(*mesh, kFCKeyNumTriangles) );
		meshObject->SetNumEdges( FCXML::IntValueForNodeAttribute(*mesh, kFCKeyNumEdges) );
		
		// specular color
		
		if ((FCXML::StringValueForNodeAttribute(*mesh, "specular_r").size()) && 
			(FCXML::StringValueForNodeAttribute(*mesh, "specular_g").size()) && 
			(FCXML::StringValueForNodeAttribute(*mesh, "specular_b").size()))
		{
			FCColor4f specular;
			specular.r = FCXML::FloatValueForNodeAttribute(*mesh, "specular_r");		//[[mesh valueForKey:@"specular_r"] floatValue];
			specular.g = FCXML::FloatValueForNodeAttribute(*mesh, "specular_g");	//[[mesh valueForKey:@"specular_g"] floatValue];
			specular.b = FCXML::FloatValueForNodeAttribute(*mesh, "specular_b");	//[[mesh valueForKey:@"specular_b"] floatValue];
			specular.a = 1.0f;
			meshObject->SetSpecularColor( specular );
		}
		
		// copy across vertex and index buffers
		
		uint32_t indexBufferOffset = (uint32_t)FCXML::IntValueForNodeAttribute(indexBufferXML, "offset");
		uint32_t indexBufferSize = (uint32_t)FCXML::IntValueForNodeAttribute(indexBufferXML, "size");
		
		memcpy( meshObject->IndexBuffer(), resource->BinaryPayload() + indexBufferOffset, indexBufferSize);
		
		uint32_t vertexBufferOffset = (uint32_t)FCXML::IntValueForNodeAttribute(vertexBufferXML, "offset");
		uint32_t vertexBufferSize = (uint32_t)FCXML::IntValueForNodeAttribute(vertexBufferXML, "size");
		
		memcpy( meshObject->VertexBuffer(), resource->BinaryPayload() + vertexBufferOffset, vertexBufferSize);
		
		std::string diffuseString = FCXML::StringValueForNodeAttribute(*mesh, kFCKeyDiffuseColor);
		
		if( diffuseString.size() ) {
			
			FCStringVector components = FCStringUtils_ComponentsSeparatedByString(diffuseString, ",");

			FCColor4f color = FCColor4f((float)atof(components[0].c_str()),
										(float)atof(components[1].c_str()),
										(float)atof(components[2].c_str()), 1.0f);

			meshObject->SetDiffuseColor( color );
		}
		
		meshObject->SetParentModel( this );
		m_meshes.push_back( meshObject );
	}
}

void FCGLModel::InitWithPhysics( FCXMLNode physicsXML, FCColor4f& color )
{
	FCXMLNodeVec fixtures = FCXML::VectorForChildNodesOfType( physicsXML, "fixture");
	
	for (FCXMLNodeVecIter fixture = fixtures.begin(); fixture != fixtures.end(); fixture++)
	{
		std::string type = FCXML::StringValueForNodeAttribute(*fixture, "type");
		
		float fixtureX = FCXML::FloatValueForNodeAttribute(*fixture, kFCKeyOffsetX);
		float fixtureY = FCXML::FloatValueForNodeAttribute(*fixture, kFCKeyOffsetY);
		float fixtureZ = FCXML::FloatValueForNodeAttribute(*fixture, kFCKeyOffsetZ);
		
		if( type == "box" ) 
		{
			// box
			
			DebugRectangleInitParams params;
			params.fixture.x = fixtureX;
			params.fixture.y = fixtureY;
			params.fixture.z = fixtureZ;
			params.size.x = FCXML::FloatValueForNodeAttribute(*fixture, "xSize");
			params.size.y = FCXML::FloatValueForNodeAttribute(*fixture, "ySize");
			params.size.z = FCXML::FloatValueForNodeAttribute(*fixture, "zSize");
			
			AddDebugRectangle( params, color );
		} 
		else if( type == "circle" ) 
		{
			// circle
			DebugCircleInitParams params;
			params.fixture.x = fixtureX;
			params.fixture.y = fixtureY;
			params.fixture.z = fixtureZ;
			params.radius = FCXML::FloatValueForNodeAttribute(*fixture, "radius");
			
			AddDebugCircle( params, color );
		} 
		else if( type == "hull" ) 
		{
			// polygon

			std::string strippedVerts = FCXML::StringValueForNodeAttribute(*fixture, "verts");
			
			FCStringUtils_ReplaceOccurencesOfStringWithString( strippedVerts, ",", " " );
			FCStringUtils_ReplaceOccurencesOfStringWithString( strippedVerts, "(", "" );
			FCStringUtils_ReplaceOccurencesOfStringWithString( strippedVerts, ")", "" );

			FCStringVector floatVec = FCStringUtils_ComponentsSeparatedByString(strippedVerts, " ");
			
			uint32_t numVerts = floatVec.size() / 3;

			DebugPolygonInitParams params;
			params.fixture.x = fixtureX;
			params.fixture.y = fixtureY;
			params.fixture.z = fixtureZ;

			FCStringVectorIter i = floatVec.begin();
			
			for( uint32_t count = 0 ; count < numVerts ; count++ )
			{
				FCVector3f vec;
				vec.x = (float)atof( (*i).c_str() ); i++;
				vec.y = (float)atof( (*i).c_str() ); i++;
				vec.z = (float)atof( (*i).c_str() ); i++;
				params.verts.push_back( vec );
			}
			
			AddDebugPolygon( params, color );
		}
	}

}

void FCGLModel::AddDebugRectangle( DebugRectangleInitParams& params, FCColor4f& color )
{
	FCGLMeshRef mesh = FCGLMeshRef( new FCGLMesh( kFCKeyShaderDebug, GL_TRIANGLES ) );
	
	m_meshes.push_back( mesh );
	mesh->SetParentModel( this );
	
	mesh->SetNumVertices( 4 );
	mesh->SetNumTriangles( 2 );
	
	FCVector2f size( params.size.x * 0.5f, params.size.y * 0.5f);
	
	FCVector3f center;
	center.x = params.fixture.x;
	center.y = params.fixture.y;
	center.z = 0.0f;
	
	FCVector3f* pVert;
	
	pVert = (FCVector3f*)( (unsigned long)mesh->VertexBuffer() );
	pVert->x = center.x + size.x * -1.0f;
	pVert->y = center.y + size.y * -1.0f;
	pVert->z = center.z;
	
	pVert = (FCVector3f*)((unsigned int)pVert + 12);
	pVert->x = center.x + size.x * 1.0f;
	pVert->y = center.y + size.y * -1.0f;
	pVert->z = center.z;
	
	pVert = (FCVector3f*)((unsigned int)pVert + 12);
	pVert->x = center.x + size.x * 1.0f;
	pVert->y = center.y + size.y * 1.0f;
	pVert->z = center.z;
	
	pVert = (FCVector3f*)((unsigned int)pVert + 12);
	pVert->x = center.x + size.x * -1.0f;
	pVert->y = center.y + size.y * 1.0f;
	pVert->z = center.z;
	
	mesh->SetDiffuseColor( color );
	
	unsigned short* pIndex;
	
	pIndex = mesh->PIndexBufferAtIndex( 0 );
	*pIndex = 0;
	*(pIndex+1) = 1;
	*(pIndex+2) = 2;
	pIndex = mesh->PIndexBufferAtIndex( 3 );
	*pIndex = 0;
	*(pIndex+1) = 2;
	*(pIndex+2) = 3;
}

void FCGLModel::AddDebugCircle( DebugCircleInitParams& params, FCColor4f& color )
{
	FCGLMeshRef mesh = FCGLMeshRef( new FCGLMesh( kFCKeyShaderDebug, GL_TRIANGLES ) );
	
	m_meshes.push_back( mesh );
	mesh->SetParentModel( this );
	
	mesh->SetNumVertices( kNumCircleSegments + 1 );
	mesh->SetNumTriangles( kNumCircleSegments );

	float radius = params.radius;
	
	FCVector3f* pVert;
	FCVector3f center;
	center.x = params.fixture.x;
	center.y = params.fixture.y;
	center.z = 0.0f;
	
	pVert = (FCVector3f*)((unsigned long)mesh->VertexBuffer());
	pVert->x = center.x;
	pVert->y = center.y;
	pVert->z = center.z;
	
	for( int i = 0 ; i < kNumCircleSegments ; i++ )
	{
		float angle1 = ( 3.142f * 2.0f / kNumCircleSegments ) * i;
		
		pVert = (FCVector3f*)((unsigned int)pVert + 12);
		
		pVert->x = center.x + sinf( angle1 ) * radius;
		pVert->y = center.y + cosf( angle1 ) * radius;
		pVert->z = center.z;
	}
	
	mesh->SetDiffuseColor( color );

	unsigned short* pIndex;
	
	for (uint16_t i = 0 ; i < kNumCircleSegments - 1; i++)
	{
		pIndex = mesh->PIndexBufferAtIndex(i*3);
		*pIndex = 0;
		*(pIndex+1) = i+1;
		*(pIndex+2) = i+2;
	}
	
	pIndex = mesh->PIndexBufferAtIndex((kNumCircleSegments - 1) * 3);
	*pIndex = 0;
	*(pIndex+1) = kNumCircleSegments;
	*(pIndex+2) = 1;
}

void FCGLModel::AddDebugPolygon( DebugPolygonInitParams& params, FCColor4f& color )
{
	FCGLMeshRef mesh = FCGLMeshRef( new FCGLMesh( kFCKeyShaderDebug, GL_TRIANGLES ) );
	
	m_meshes.push_back( mesh );
	mesh->SetParentModel( this );
	
	mesh->SetNumVertices( params.verts.size() );
	mesh->SetNumTriangles( mesh->NumVertices() - 2 );

	FCVector3f* pVert;
	
	FCVector3fVec& vertsArray = params.verts;
	
	pVert = (FCVector3f*)((unsigned long)mesh->VertexBuffer());
	
	float xOffset = params.fixture.x;
	float yOffset = params.fixture.y;
	float zOffset = params.fixture.z;
	
	pVert->x = vertsArray[0].x + xOffset;
	pVert->y = vertsArray[0].y + yOffset;
	pVert->z = vertsArray[0].z + zOffset;
	
	for (uint16_t i = 1 ; i < mesh->NumVertices() ; i++)
	{
		pVert = (FCVector3f*)((unsigned int)pVert + 12);
		pVert->x = vertsArray[i].x + xOffset;
		pVert->y = vertsArray[i].y + yOffset;
		pVert->z = vertsArray[i].z + zOffset;
	}
	
	mesh->SetDiffuseColor( color );

	unsigned short* pIndex;
	
	for (uint16_t i = 0; i < mesh->NumTriangles(); i++)
	{
		pIndex = mesh->PIndexBufferAtIndex( i * 3 );
		*pIndex = 0;
		*(pIndex+1) = i+1;
		*(pIndex+2) = i+2;
	}
}

void FCGLModel::SetDebugMeshColor( FCColor4f& color )
{
	for( FCGLMeshRefVecIter i = m_meshes.begin() ; i != m_meshes.end() ; i++ )
	{
		(*i)->SetDiffuseColor( color );
	}
}

void FCGLModel::SetRotation( float rot )
{
	m_rotation = rot;
}

void FCGLModel::SetPosition( FCVector3f& pos )
{
	m_pos = pos;
}
