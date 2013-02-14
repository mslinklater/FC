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

#include "FCViewport.h"

FCViewport::FCViewport()
: m_position( 0.0f, 0.0f, 0.0f )
, m_target( 0.0f, 0.0f, 0.0f )
, m_up( 0.0f, 1.0f, 0.0f )
{
	
}

FCViewport::~FCViewport()
{
	
}

void FCViewport::SetOrthographic(float width, float height, float near, float far)
{
	m_projection = FCMatrix4f::Orthographic( width, height, near, far );
}

void FCViewport::SetPerspective(float width, float height, float near, float far)
{
	m_projection = FCMatrix4f::Frustum( -width, width, -height, height, near, far );
}

void FCViewport::SetPosition(const FCVector3f &pos)
{
	m_position = pos;
	m_translation = FCMatrix4f::Translate(-pos.x, -pos.y, -pos.z);
	
	Realign();
}

void FCViewport::SetTarget(const FCVector3f &pos)
{
	m_target = pos;
	Realign();
}

void FCViewport::Realign()
{
	// set rotation matrix
	
	m_rotation = FCMatrix4f::Identity();
	
	FCVector3f dir = m_position - m_target;
	dir.Normalize();
	FCVector3f right = m_up * dir;
	right.Normalize();
	FCVector3f up = dir * right;
	up.Normalize();
	
	m_rotation.e[0] = right.x;
	m_rotation.e[1] = up.x;
	m_rotation.e[2] = dir.x;
	m_rotation.e[4] = right.y;
	m_rotation.e[5] = up.y;
	m_rotation.e[6] = dir.y;
	m_rotation.e[8] = right.z;
	m_rotation.e[9] = up.z;
	m_rotation.e[10] = dir.z;
}

const FCMatrix4f FCViewport::GetProjectionMatrix()
{
	FCMatrix4f ret;
	
	ret = m_translation * m_rotation * m_projection;
	
	return ret;
}
