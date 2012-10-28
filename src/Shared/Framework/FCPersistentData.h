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

#ifndef _FCPersistentData_h
#define _FCPersistentData_h

#include "Shared/Core/FCCore.h"

class FCPersistentData : public FCBase
{
public:
	static FCPersistentData* Instance();
	
	FCPersistentData();
	~FCPersistentData();
	
	void Load();
	void Save();
	void Clear();
	std::string Print();
	
	bool Exists( std::string key );
	
    void ClearValueForKey( std::string key );
    
	void AddStringForKey( std::string value, std::string key );
	std::string StringForKey( std::string key );
							 
	void AddFloatForKey( float value, std::string key );
	float FloatForKey( std::string key );
	
	void AddIntForKey( int32_t value, std::string key );
	int32_t IntForKey( std::string key );

	void AddBoolForKey( bool value, std::string key );
	bool BoolForKey( std::string key );
};

#endif
