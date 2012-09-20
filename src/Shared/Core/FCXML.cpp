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

#include "FCXML.h"
#include "FCError.h"
#include "FCFile.h"
#include "FCStringUtils.h"

FCXML::FCXML()
: m_pData(0)
{
	
}

FCXML::~FCXML()
{
	if (m_pData) {
		delete m_pData;
	}
}

void FCXML::InitWithContentsOfFile(std::string filename)
{
	FC_ASSERT(this);
	
	m_filename = filename;
	
	std::string filepath = plt_FCFile_ApplicationBundlePathForPath( filename );
	
	FILE* hFile = fopen(filepath.c_str(), "r");

	FC_ASSERT(hFile);

	fseek(hFile, 0, SEEK_END);
	
	m_dataSize = ftell(hFile);
	
	fseek(hFile, 0, SEEK_SET);

	m_pData = new uint8_t[ m_dataSize + 16 ];
	memset(m_pData, 0, m_dataSize + 16);

	fread(m_pData, 1, m_dataSize, hFile);
	
	fclose(hFile);
	
	m_doc.parse<0>((char*)m_pData);
}

FCXMLNodeVec FCXML::VectorForKeyPath(std::string path, uint32_t flags)
{
	FC_ASSERT(this);
	
	FCXMLNodeVec ret;
	
	FCStringVector components = FCStringUtils_ComponentsSeparatedByString(path, ".");
	
	const char* szNode = components[0].c_str();
	
	FCXMLNode node = m_doc.first_node( szNode );
	
	for (unsigned long i = 1; i < components.size(); i++) 
	{
		szNode = components[i].c_str();
		node = node->first_node(szNode);
		if (!node) {
			if (flags & kFCXMLFlag_HaltOnNotFound) {
				FC_HALT;
			}
			if (flags & kFCXMLFlag_WarnOnNotFound) {
				FC_WARNING(std::string("XML keypath (") + path + std::string(") in file: " + m_filename));
			}
			return ret;
		}
	}
	
	do {
		ret.push_back(node);
		node = node->next_sibling();
	} while (node);
	
//	FC_HALT;
	
	return ret;
}

FCXMLNodeVec FCXML::VectorForChildNodesOfType( FCXMLNode& startNode, std::string type, uint32_t flags )
{
	FCXMLNodeVec ret;
	
	FCXMLNode node = startNode->first_node(type.c_str());
	
	while (node) {
		ret.push_back(node);
		node = node->next_sibling();
	}
	
	if (!ret.size()) {
		if (flags & kFCXMLFlag_HaltOnNotFound) {
			FC_HALT;
		}
		if (flags & kFCXMLFlag_WarnOnNotFound) {
			FC_WARNING(std::string("Child nodes not found of type: ") + type);
		}
	}
	
	return ret;
}

std::string FCXML::StringValueForNodeAttribute(FCXMLNode& node, std::string name, uint32_t flags)
{
	for (FCXMLAttribute attr = node->first_attribute(); attr; attr = attr->next_attribute())
	{
		if( attr->name() == name )
			return std::string(attr->value());
	}
	if (flags & kFCXMLFlag_HaltOnNotFound) {
		FC_HALT;
	}
	if (flags & kFCXMLFlag_WarnOnNotFound) {
		FC_WARNING(std::string("Attribute not found in XML node: ") + name);
	}
	return std::string("");
}

float FCXML::FloatValueForNodeAttribute(FCXMLNode& node, std::string name, uint32_t flags)
{
	for (FCXMLAttribute attr = node->first_attribute(); attr; attr = attr->next_attribute())
	{
		if( attr->name() == name )
		{
			float ret;
			sscanf(attr->value(), "%f", &ret);
			return ret;
		}
	}
	if (flags & kFCXMLFlag_HaltOnNotFound) {
		FC_HALT;
	}
	if (flags & kFCXMLFlag_WarnOnNotFound) {
		FC_WARNING(std::string("Attribute not found in XML node: ") + name);
	}
	return 0.0f;
}

int32_t FCXML::IntValueForNodeAttribute(FCXMLNode& node, std::string name, uint32_t flags)
{
	for (FCXMLAttribute attr = node->first_attribute(); attr; attr = attr->next_attribute())
	{
		if( attr->name() == name )
		{
			int32_t ret;
			sscanf(attr->value(), "%d", &ret);
			return ret;
		}
	}
	if (flags & kFCXMLFlag_HaltOnNotFound) {
		FC_HALT;
	}
	if (flags & kFCXMLFlag_WarnOnNotFound) {
		FC_WARNING(std::string("Attribute not found in XML node: ") + name);
	}
	return 0;
}

bool FCXML::BoolValueForNodeAttribute(FCXMLNode& node, std::string name, uint32_t flags)
{
	for (FCXMLAttribute attr = node->first_attribute(); attr; attr = attr->next_attribute())
	{
		if( attr->name() == name )
		{
			std::string val = attr->value();
			if ( (val == "yes") || (val == "true") || (val == "1") ) {
				return true;
			} else {
				return false;
			}
		}
	}
	if (flags & kFCXMLFlag_HaltOnNotFound) {
		FC_HALT;
	}
	if (flags & kFCXMLFlag_WarnOnNotFound) {
		FC_WARNING(std::string("Attribute not found in XML node: ") + name);
	}
	return false;
}

FCXMLAttributeMap FCXML::AttributesForNode(FCXMLNode &node, uint32_t flags)
{
	FCXMLAttributeMap ret;
	FC_HALT;	// TBD
	return ret;
}
