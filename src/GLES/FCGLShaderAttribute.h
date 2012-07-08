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

#ifndef CR1_FCGLShaderAttribute_h
#define CR1_FCGLShaderAttribute_h

#include <string>
#include <map>

#include "FCGL.h"

class FCGLShaderAttribute
{
public:
	FCGLShaderAttribute(){}
	virtual ~FCGLShaderAttribute(){}
	
	GLint	Location(){ return m_glLocation; }
	void	SetLocation( GLint location ){ m_glLocation = location; }
	
	GLint	Num(){ return m_num; }
	void	SetNum( GLint num ){ m_num = num; }
	
	GLenum	Type(){ return m_type; }
	void	SetType( GLenum type ){ m_type = type; }
	
private:
	GLint	m_glLocation;
	GLint	m_num;
	GLenum	m_type;
};

typedef std::shared_ptr<FCGLShaderAttribute>			FCGLShaderAttributePtr;
typedef std::map<std::string, FCGLShaderAttributePtr>	FCGLShaderAttributePtrMapByString;
typedef FCGLShaderAttributePtrMapByString::iterator		FCGLShaderAttributePtrMapByStringIter;

typedef std::vector<FCGLShaderAttributePtr>			FCGLShaderAttributePtrVec;
typedef FCGLShaderAttributePtrVec::iterator			FCGLShaderAttributePtrVecIter;
typedef FCGLShaderAttributePtrVec::const_iterator	FCGLShaderAttributePtrVecConstIter;

#endif
