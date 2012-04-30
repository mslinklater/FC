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

#ifndef FCSharedPtr_h
#define FCSharedPtr_h

#include <algorithm>

template<typename T>
class FCSharedPtr
{
public:
	
	FCSharedPtr( T* pObject = 0 )
	: m_pObject( pObject )
	{
		m_pRefCount = new unsigned int;
		*m_pRefCount = 1;
	}

	FCSharedPtr( const FCSharedPtr<T> &other )
	: m_pObject( other.m_pObject )
	, m_pRefCount( other.m_pRefCount )
	{
		(*m_pRefCount)++;
	}
	
	~FCSharedPtr()
	{
		(*m_pRefCount)--;
		if (*m_pRefCount <= 0) {
			delete m_pObject;
			m_pObject = 0;
			delete m_pRefCount;
			m_pRefCount = 0;
		}
	}

	FCSharedPtr& operator=( const FCSharedPtr<T> &rhs )
	{
		FCSharedPtr<T> temp(rhs);
		swap(temp);
		return *this;
	}

	T& operator*() const
	{
		return *m_pObject;
	}

	T* operator->() const
	{
		return m_pObject;
	}

	operator bool() const
	{
		return m_pObject != 0;
	}
	
	T* get() const
	{
		return m_pObject;
	}
	
	void swap( FCSharedPtr<T> &other )
	{
		std::swap( m_pObject, other.m_pObject );
		std::swap( m_pRefCount, other.m_pRefCount );
	}
	
private:
	unsigned int*	m_pRefCount;
	T*				m_pObject;
};

#endif
