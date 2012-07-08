//
//  FCGLShader.h
//  CR1
//
//  Created by Martin Linklater on 07/07/2012.
//  Copyright (c) 2012 Curly Rocket Ltd. All rights reserved.
//

#ifndef CR1_FCGLShader_h
#define CR1_FCGLShader_h

#include <string>
#include <map>

#include "FCGL.h"
#include "Shared/Graphics/FCGraphicsTypes.h"

class FCGLShader
{
public:
	FCGLShader( eFCShaderType type, std::string source );
	virtual ~FCGLShader();

	void SetHandle( GLuint handle ){ m_glHandle = handle; }
	GLuint	Handle(){ return m_glHandle; }

private:
	GLuint	m_glHandle;
};

typedef std::shared_ptr<FCGLShader>	FCGLShaderPtr;

typedef std::map<std::string, FCGLShaderPtr>	FCGLShaderPtrMapByString;
typedef FCGLShaderPtrMapByString::iterator		FCGLShaderPtrMapByStringIter;

#endif
