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

#ifndef FCRESOURCE_H
#define FCRESOURCE_H

#include "Shared/Core/FCTypes.h"
#include "Shared/Core/FCXML.h"

class FCResource {
public:
	
	FCResource()
	: m_binaryPayload(0)
	, m_userData(0)
	{}
	~FCResource(){}
	
	void InitWithContentsOfFile( std::string filename );
	
	void*		UserData(){ return m_userData; }
	void		SetUserData( void* ud ){ m_userData = ud; }
	FCXMLPtr	XML(){ return m_xml; }
	char*		BinaryPayload(){ return m_binaryPayload; }
	void		SetName( std::string name ){ m_name = name; }
	
private:
	char*	m_binaryPayload;
	uint32_t m_binaryPayloadSize;
	FCXMLPtr m_xml;
	std::string m_name;
	void* m_userData;
};

typedef FCSharedPtr<FCResource> FCResourcePtr;

#endif // FCRESOURCE_H
