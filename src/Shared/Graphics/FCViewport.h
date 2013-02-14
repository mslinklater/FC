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

#ifndef FCViewport_h
#define FCViewport_h

#include "Shared/Core/FCCore.h"

class FCViewport {
public:
	
	FCViewport();
	virtual ~FCViewport();
	
	void SetOrthographic( float width, float height, float near, float far );
	void SetPerspective( float width, float height, float near, float far );
	
	void SetPosition( const FCVector3f& pos );
	FCVector3f	Position(){ return m_position; }

	void SetTarget( const FCVector3f& pos );
	FCVector3f	Target(){ return m_target; }

	const FCMatrix4f	GetProjectionMatrix();
private:
	
	void Realign();
	
	FCVector3f	m_position;
	FCVector3f	m_target;
	FCVector3f	m_up;
	FCMatrix4f	m_projection;
	FCMatrix4f	m_translation;
	FCMatrix4f	m_rotation;
};

#endif
