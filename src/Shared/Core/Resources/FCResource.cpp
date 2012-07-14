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

#include "FCResource.h"

#include "Shared/Core/FCFile.h"

void FCResource::InitWithContentsOfFile(std::string filename)
{
	std::string fcrFilename = filename + ".fcr";
	std::string binFilename = filename + ".bin";
	
	m_xml = FCXMLRef( new FCXML );
	m_xml->InitWithContentsOfFile(fcrFilename);
	
	FILE* hFile = fopen( plt_FCFile_ApplicationBundlePathForPath(binFilename).c_str(), "rb");
	
	fseek(hFile, 0, SEEK_END);
	m_binaryPayloadSize = ftell(hFile);
	fseek(hFile, 0, SEEK_SET);
	
	m_binaryPayload = new char[ m_binaryPayloadSize ];
	
	fread( m_binaryPayload, 1, m_binaryPayloadSize, hFile);
	
	fclose(hFile);
}
