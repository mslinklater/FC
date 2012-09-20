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

#ifndef CR2_FCSharedPtr_h
#define CR2_FCSharedPtr_h

// Based on shared_ptr impl by Itay Maman:
// http://www.codeproject.com/KB/cpp/auto_ref.aspx

#include <algorithm>

template<typename T>
class FCSharedPtr
{
	public:
	FCSharedPtr( T* pT = 0 )
	: m_pT( pT )
	{
		m_pRefCount = new unsigned int;
		*m_pRefCount = 1;
	}
	
	FCSharedPtr( const FCSharedPtr<T> &other )
	: m_pT( other.m_pT )
	, m_pRefCount( other.m_pRefCount )
	{
		(*m_pRefCount)++;
	}
	
	~FCSharedPtr()
	{
		(*m_pRefCount)--;
		
		if (*m_pRefCount <= 0) {
			delete m_pT;
			m_pT = 0;
			delete m_pRefCount;
			m_pRefCount = 0;
		}
	}
	
	// Operator equals
	
	FCSharedPtr& operator=( const FCSharedPtr<T> &rhs )
	{
		FCSharedPtr<T> temp(rhs);
		swap(temp);
		return *this;
	}
	
	T& operator*() const
	{
		return *m_pT;
	}
	
	T* operator->() const
	{
		return m_pT;
	}
	
	operator bool() const
	{
		return m_pT != 0;
	}
	
	T* get() const
	{
		return m_pT;
	}
	
	void swap( FCSharedPtr<T> &other )
	{
		std::swap( m_pT, other.m_pT );
		std::swap( m_pRefCount, other.m_pRefCount );
	}
		
private:
	unsigned int* m_pRefCount;
	T* m_pT;
	
};


#endif
