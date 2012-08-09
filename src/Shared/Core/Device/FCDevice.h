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

#ifndef CR1_Device_h
#define CR1_Device_h

/*
 
 This is a singleton class. Access the global object via the 'Instance'
 method.
 
 */

#include <map>

#include "Shared/Core/FCTypes.h"

class FCDevice {
public:
	static FCDevice* Instance();
	
	FCDevice();
	~FCDevice();

	void ColdProbe();	// Once, on boot probes.
	void WarmProbe( uint32_t options );	// Repeatable, changeable probes.
	
	std::string GetCap( std::string cap );
	void SetCap( std::string cap, std::string value );
	
	void Print();
	
private:
	FCStringStringMap m_caps;
};

#endif
