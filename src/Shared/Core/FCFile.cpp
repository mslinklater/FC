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

#include "FCFile.h"

FCFile::FCFile()
: m_handle( 0 )
, m_data( 0 )
, m_fileSize( 0 )
, m_isDataInMemory( false )
{
	
}

FCFile::~FCFile()
{
	if (m_handle) {
		fclose(m_handle);
	}
//	if (m_data) {
//		delete [] m_data;
//	}
}

FCFileReturn FCFile::Open(std::string filename, FCFileOpenMode mode, FCFileLocation loc)
{
	if (m_handle) {
		Close();
	}
	
	std::string filepath;
	
	switch (loc) {
		case kFCFileLocationApplicationBundle:
			filepath = plt_FCFile_ApplicationBundlePathForPath( filename );
			break;
		case kFCFileLocationNormalFile:
			filepath = plt_FCFile_NormalPathForPath( filename );
			break;
		case kFCFileLocationDocumentsFolder:
			filepath = plt_FCFile_DocumentsFolderPathForPath( filename );
			break;			
		default:
			break;
	}

	const char* modeString;
	
	switch( mode ) 
	{
		case kFCFileOpenModeReadOnly:
			modeString = "r";
			break;
		case kFCFileOpenModeReadWrite:
			modeString = "w";
			break;
	}
	
	m_handle = fopen( filepath.c_str(), modeString );

	if (!m_handle) {
		FC_WARNING(std::string("Cannot open file: " + filename));
		return kFCFileReturnError;
	}
	
	fseek( m_handle, 0, SEEK_END );
	m_fileSize = ftell( m_handle );
	fseek( m_handle, 0, SEEK_SET );

	return kFCFileReturnOK;
}

FCFileReturn FCFile::Close()
{
	fclose( m_handle );
	m_handle = 0;
//	delete [] m_data;
//	m_data = 0;

	return kFCFileReturnOK;
}

FCDataPtr FCFile::Data()
{
	if (!m_isDataInMemory) {
		ReadIntoMemory();
	}
	
	return m_data;
}

FCFileReturn FCFile::ReadIntoMemory()
{
	FC_ASSERT(m_handle);
	FC_ASSERT(!m_isDataInMemory);
	FC_ASSERT(!m_data);
	
	m_data = FCDataPtr( new char[ m_fileSize ] );
	
	fseek( m_handle, 0, SEEK_SET );
	fread( m_data.get(), m_fileSize, 1, m_handle );
	
	return kFCFileReturnOK;
}





