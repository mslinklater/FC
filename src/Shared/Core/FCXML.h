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

#ifndef _FCXML_h
#define _FCXML_h

#include <memory>
#include <rapidxml.hpp>
#include "FCCore.h"

typedef rapidxml::xml_node<>*			FCXMLNode;
typedef std::vector< FCXMLNode >		FCXMLNodeVec;
typedef FCXMLNodeVec::iterator			FCXMLNodeVecIter;
typedef FCXMLNodeVec::const_iterator	FCXMLNodeVecConstIter;

typedef std::map<std::string, FCXMLNode>	FCXMLNodeMapByString;

typedef rapidxml::xml_attribute<>*				FCXMLAttribute;
typedef std::map<std::string, FCXMLAttribute>	FCXMLAttributeMap;

enum eFCXMLFlags {
	kFCXMLFlag_HaltOnNotFound = 1 << 0,
	kFCXMLFlag_WarnOnNotFound = 1 << 1
};

class FCXML {
public:
	FCXML();
	~FCXML();
	
	void InitWithContentsOfFile( std::string filename );
	
	FCXMLNodeVec	VectorForKeyPath( std::string path, uint32_t flags = 0 );
	
	static FCXMLNodeVec	VectorForChildNodesOfType( FCXMLNode& node, std::string type, uint32_t flags = 0 );
	
	static FCXMLAttributeMap	AttributesForNode( FCXMLNode& node, uint32_t flags = 0 );
	static std::string	StringValueForNodeAttribute( FCXMLNode& node, std::string name, uint32_t flags = 0 );
	static float		FloatValueForNodeAttribute( FCXMLNode& node, std::string name, uint32_t flags = 0 );
	static bool			BoolValueForNodeAttribute( FCXMLNode& node, std::string name, uint32_t flags = 0 );
	static int32_t		IntValueForNodeAttribute( FCXMLNode& node, std::string name, uint32_t flags = 0 );
	
private:
	std::string m_filename;
	uint8_t*	m_pData;
	uint32_t	m_dataSize;
	rapidxml::xml_document<> m_doc;
};

typedef FCSharedPtr<FCXML> FCXMLRef;

#endif
