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

extern "C" {
#include "lua.h"
}

#include <stdint.h>

extern void* FCLuaAlloc(void*, void*, size_t, size_t);

class FCLuaMemory
{
public:
	FCLuaMemory()
	{
		m_totalMemory = 0;
		m_numAllocs = 0;
	}
	~FCLuaMemory();

	static FCLuaMemory* Instance()
	{
		if (!s_pInstance) {
			s_pInstance = new FCLuaMemory;
		}
		return s_pInstance;
	}
	
	uint32_t	NumAllocs(){ return m_numAllocs; }
	uint32_t	TotalMemory(){ return m_totalMemory; }
	
	void TotalMemoryDelta( uint32_t delta )
	{
		m_totalMemory += delta;
	}
	void NumAllocsDelta( uint32_t delta )
	{
		m_numAllocs += delta;
	}

private:
	static FCLuaMemory* s_pInstance;
	uint32_t m_totalMemory;
	uint32_t m_numAllocs;
};
