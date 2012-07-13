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

#include "FCGLShaderManager.h"
#include "Shared/Core/FCFile.h"

#include "GLES/ShaderPrograms/FCGLShaderProgram1TexPLit.h"
#include "GLES/ShaderPrograms/FCGLShaderProgram1TexVLit.h"
#include "GLES/ShaderPrograms/FCGLShaderProgramDebug.h"
#include "GLES/ShaderPrograms/FCGLShaderProgramFlatUnlit.h"
#include "GLES/ShaderPrograms/FCGLShaderProgramNoTexPLit.h"
#include "GLES/ShaderPrograms/FCGLShaderProgramNoTexVLit.h"
#include "GLES/ShaderPrograms/FCGLShaderProgramTest.h"
#include "GLES/ShaderPrograms/FCGLShaderProgramWireframe.h"

static FCGLShaderManager* s_pInstance = 0;

IFCShaderManager* plt_FCShaderManager_Instance()
{
	return FCGLShaderManager::Instance();
}

FCGLShaderManager::FCGLShaderManager()
{
	
}

FCGLShaderManager::~FCGLShaderManager()
{
	
}

FCGLShaderManager* FCGLShaderManager::Instance()
{
	if (!s_pInstance) {
		s_pInstance = new FCGLShaderManager;
	}
	return s_pInstance;
}

FCGLShaderRef FCGLShaderManager::AddShader( std::string name )
{
	FCGLShaderRefMapByStringIter ret = m_shaders.find( name );
	
	if( ret == m_shaders.end() )
	{
		FCFile shaderFile;
		shaderFile.Open(name, kFCFileOpenModeReadOnly, kFCFileLocationApplicationBundle);
		FCDataPtr shaderData = shaderFile.Data();
		
		// process it
		
		eFCShaderType type;
	
		std::string shaderType = name.substr( name.find(".") + 1 );
		
		if ( shaderType == "vsh" ) {
			type = kShaderTypeVertex;
		} else {
			type = kShaderTypeFragment;
		}
		
		FCGLShaderRef shader = FCGLShaderRef( new FCGLShader( type, std::string( shaderData.get(), shaderFile.Size() ) ) );
		
		FC_LOG( std::string("Compiled GL shader: ") + name);
		
		shaderFile.Close();
		
		m_shaders[ name ] = shader;
		
		ret = m_shaders.find( name );
	}
	return ret->second;
}

FCGLShaderRef FCGLShaderManager::Shader( std::string name )
{
	return m_shaders[ name ];

}

FCGLShaderProgramRef FCGLShaderManager::AddProgram( std::string name, std::string shaderName )
{
	FCGLShaderProgramRefMapByStringIter i = m_programs.find( name );
		
	if( i == m_programs.end() ) 
	{
		std::string vertexShaderName = shaderName + ".vsh";
		std::string fragmentShaderName = shaderName + ".fsh";
		
		FCGLShaderRef vertexShader = AddShader( vertexShaderName );
		FCGLShaderRef fragmentShader = AddShader( fragmentShaderName );
		
		// build program
		
		if( name == kFCKeyShaderDebug ) 
		{
			m_programs[ name ] = FCGLShaderProgramRef( new FCGLShaderProgramDebug( vertexShader, fragmentShader ) );
		} 
		else if ( name == kFCKeyShaderWireframe ) 
		{
			m_programs[ name ] = FCGLShaderProgramRef( new FCGLShaderProgramWireframe( vertexShader, fragmentShader ) );
		} 
		else if ( name == kFCKeyShaderFlatUnlit ) 
		{
			m_programs[ name ] = FCGLShaderProgramRef( new FCGLShaderProgramFlatUnlit( vertexShader, fragmentShader ) );
		} 
		else if ( name == kFCKeyShaderNoTexVLit ) 
		{
			m_programs[ name ] = FCGLShaderProgramRef( new FCGLShaderProgramNoTexVLit( vertexShader, fragmentShader ) );
		} 
		else if ( name == kFCKeyShaderNoTexPLit ) 
		{
			m_programs[ name ] = FCGLShaderProgramRef( new FCGLShaderProgramNoTexPLit( vertexShader, fragmentShader ) );
		} 
		else if ( name == kFCKeyShader1TexVLit ) 
		{
			m_programs[ name ] = FCGLShaderProgramRef( new FCGLShaderProgram1TexVLit( vertexShader, fragmentShader ) );
		} 
		else if ( name == kFCKeyShader1TexPLit ) 
		{
			m_programs[ name ] = FCGLShaderProgramRef( new FCGLShaderProgram1TexPLit( vertexShader, fragmentShader ) );
		} 
		else if ( name == kFCKeyShaderTest ) 
		{
			m_programs[ name ] = FCGLShaderProgramRef( new FCGLShaderProgramTest( vertexShader, fragmentShader ) );
		} 
		else {
			FC_FATAL( std::string("Unknown shader: ") + name );
		}
		
		FC_LOG( std::string("Linked GL program: ") + name );
		
//		[self.programs setValue:ret forKey:name];
	}
	
	return m_programs[ name ];
}

FCGLShaderProgramRef FCGLShaderManager::Program( std::string name )
{
	return m_programs[ name ];
}

FCGLShaderProgramRefVec	FCGLShaderManager::AllShaders()
{
	FCGLShaderProgramRefVec ret;
	
	for( FCGLShaderProgramRefMapByStringIter i = m_programs.begin() ; i != m_programs.end() ; i++ )
	{
		ret.push_back( i->second );
	}
	return ret;
}

void FCGLShaderManager::ActivateShader( std::string name )
{
	AddProgram(name, name);
}

