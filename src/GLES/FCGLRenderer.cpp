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

#include "FCGLRenderer.h"
#include "FCGLDebugDraw.h"

#include <string>

IFCRenderer* plt_FCRenderer_Create( std::string name )
{
	return new FCGLRenderer( name );
}

FCGLRenderer::FCGLRenderer( std::string name)
: IFCRenderer( name )
, m_name( name )
{
}

FCGLRenderer::~FCGLRenderer()
{
	FC_HALT;	
}

void FCGLRenderer::Init( std::string )
{
	FC_HALT;
}

void FCGLRenderer::Render()
{	
	FCGLModelPtrVec renderModels;
	FCGLMeshPtrVec renderMeshes;
	
	// gather from objects on the gather list
	
	for (FCActorRefVecIter i = m_gatherList.begin(); i != m_gatherList.end(); i++)
	{
		FCModelRefVec vec = (*i)->RenderGather();
		
		for (FCModelRefVecIter j = vec.begin(); j != vec.end(); j++)
		{
			FCGLModelPtr model = FCGLModelPtr((*j).get());	// here ?

			renderModels.push_back( model );
		}
	}
	
	for( FCGLModelPtrVecIter i = renderModels.begin() ; i != renderModels.end() ; i++ )
	{
		FCGLMeshRefVec meshes = (*i)->Meshes();
		
		for( uint32_t j = 0 ; j < meshes.size() ; j++ )
		{
			renderMeshes.push_back( meshes[ j ].get() );
		}
	}
	
	// sorting here - by shader and alpha
	
	// render the models in sorted order
	
	GLuint lastShaderProgram = 99999;
	
	for( FCGLMeshPtrVecIter i = renderMeshes.begin() ; i != renderMeshes.end() ; i++ )
	{
		FCMatrix4f mat = FCMatrix4f::Identity();
		FCMatrix4f trans = FCMatrix4f::Translate((*i)->ParentModel()->Position().x, (*i)->ParentModel()->Position().y, 0.0f);
		FCMatrix4f rot = FCMatrix4f::Rotate( (*i)->ParentModel()->Rotation(), FCVector3f(0.0f, 0.0f, -1.0f) );
		
		FCVector3f lightDirection( 0.707f, 0.707f, 0.707f );		
		FCVector3f invLight = lightDirection * rot;
		
		mat = rot * trans;
		
		FCGLShaderUniformRef uniform = (*i)->ShaderProgram()->GetUniform( "modelview" );
		(*i)->ShaderProgram()->SetUniformValue( uniform, &mat, sizeof(mat) );
		
		uniform = (*i)->ShaderProgram()->GetUniform("light_direction");
		if (uniform.get()) 
		{
			(*i)->ShaderProgram()->SetUniformValue(uniform, &invLight, sizeof(invLight));
		}
		lastShaderProgram = (*i)->ShaderProgram()->GLHandle();
		
		(*i)->Render();
	}
	
	// Now do any debug drawing...
	
#if defined(DEBUG)
	
	
	
#endif
}

void FCGLRenderer::AddToGatherList( FCActorRef actor )
{
	m_gatherList.push_back( actor );
}

void FCGLRenderer::RemoveFromGatherList( FCActorRef actor )
{
	for (FCActorRefVecIter i = m_gatherList.begin(); i != m_gatherList.end(); i++) {
		if (*i == actor) {
			m_gatherList.erase(i);
			return;
		}
	}
}

