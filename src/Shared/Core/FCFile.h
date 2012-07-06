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

#ifndef CR1_FCFile_h
#define CR1_FCFile_h

#include <iostream>
#include <string>

#include "Shared/Core/FCCore.h"

extern std::string plt_FCFile_ApplicationBundlePathForPath( std::string filename );
extern std::string plt_FCFile_NormalPathForPath( std::string filename );
extern std::string plt_FCFile_DocumentsFolderPathForPath( std::string filename );

enum FCFileLocation
{
	FCFileLocationApplicationBundle,
	FCFileLocationNormalFile,
	FCFileLocationDocumentsFolder
};

enum FCFileOpenMode
{
	FCFileOpenModeReadOnly,
	FCFileOpenModeReadWrite
};

enum FCFileReturn
{
	FCFileReturnOK,
	FCFileReturnError
};

class FCFile
{
public:
	
	FCFile();
	virtual ~FCFile();
	
	FCFileReturn	Open( std::string filename, FCFileOpenMode mode, FCFileLocation loc );
	FCFileReturn	ReadIntoMemory();	// this happens automatically, but nice to choose when
	FCFileReturn	Close();
	FCFileReturn	DeleteData();
	FCDataPtr		Data();
	uint32_t		Size(){ return m_fileSize; }
private:
	
	// internal state
	
	FILE*		m_handle;
	char*		m_data;
	uint32_t	m_fileSize;
	bool		m_isDataInMemory;
};

typedef std::shared_ptr<FCFile> FCFilePtr;

#endif