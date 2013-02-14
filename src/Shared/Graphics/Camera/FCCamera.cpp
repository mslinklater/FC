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

#include "FCCamera.h"
#include "Shared/Core/Device/FCDevice.h"

FCCamera::FCCamera()
: m_projectionType( kProjectionTypeUnknown )
, m_positionInterpActive(false)
, m_positionStartPos( 0.0f, 0.0f, 0.0f )
, m_positionEndPos( 0.0f, 0.0f, 0.0f )
, m_positionInterp( 0.0f )
, m_positionDuration( 0.0f )
, m_targetInterpActive(false)
, m_targetStartPos( 0.0f, 0.0f, 0.0f )
, m_targetEndPos( 0.0f, 0.0f, 0.0f )
, m_targetInterp( 0.0f )
, m_targetDuration( 0.0f )
{
	
}

FCCamera::~FCCamera()
{
	
}

void FCCamera::Update(float realTime, float gameTime)
{
	// Position interpolation
	
	if (m_positionInterpActive) {
		m_positionInterp += realTime;
		FCClamp(m_positionInterp, 0.0f, m_positionDuration);

		if( m_positionInterp == m_positionDuration )
		{
			// Destination reached
			m_positionInterpActive = false;
			m_viewport.SetPosition( m_positionEndPos );
		}
		else
		{
			// Still interpolating
			float piPara = ( m_positionInterp / m_positionDuration ) * FCMaths::kPi;
			float smoothedPara = (-cos( piPara ) + 1.0f) * 0.5f;

			FCVector3f delta = m_positionDeltaPos * smoothedPara;
			FCVector3f pos = m_positionStartPos + delta;
			m_viewport.SetPosition(pos);
		}
	}

	// Target interpolation
	
	if (m_targetInterpActive) {
		m_targetInterp += realTime;
		FCClamp(m_targetInterp, 0.0f, m_targetDuration);
		
		if( m_targetInterp == m_targetDuration )
		{
			// Destination reached
			m_targetInterpActive = false;
			m_viewport.SetTarget( m_targetEndPos );
		}
		else
		{
			// Still interpolating
			float piPara = ( m_targetInterp / m_targetDuration ) * FCMaths::kPi;
			float smoothedPara = (-cos( piPara ) + 1.0f) * 0.5f;
			
			FCVector3f delta = m_targetDeltaPos * smoothedPara;
			FCVector3f pos = m_targetStartPos + delta;
			m_viewport.SetTarget(pos);
		}
	}
}

void FCCamera::SetPosition(const FCVector3f &pos, float t )
{
	if( t <= 0.0f)
	{
		m_positionInterpActive = false;
		m_viewport.SetPosition( pos );
	}
	else
	{
		// Setup interpolation
		m_positionInterpActive = true;
		m_positionDuration = t;
		m_positionInterp = 0.0f;
		m_positionStartPos = m_viewport.Position();
		m_positionEndPos = pos;
		m_positionDeltaPos = m_positionEndPos - m_positionStartPos;
	}
}

void FCCamera::SetTarget(const FCVector3f &pos, float t)
{
	if( t <= 0.0f)
	{
		m_targetInterpActive = false;
		m_viewport.SetTarget( pos );
	}
	else
	{
		// Setup interpolation
		m_targetInterpActive = true;
		m_targetDuration = t;
		m_targetInterp = 0.0f;
		m_targetStartPos = m_viewport.Target();
		m_targetEndPos = pos;
		m_targetDeltaPos = m_targetEndPos - m_targetStartPos;
	}
}

void FCCamera::SetOrthographicProjection(float x, float y)
{
	// build projection matrix here
	
	float width = x;
	float height = y;
	
	if (y == 0.0f) {
		float aspectRatio = FCDevice::Instance()->GetCapFloat(kFCDeviceDisplayAspectRatio);
		height = width * aspectRatio;
	}

	// build matrix
	
	m_viewport.SetOrthographic(width, height, 1, 100);
}

void FCCamera::SetPerspectiveProjection(float x, float y)
{
	// build projection matrix here
	
	float width = x;
	float height = y;
	
	if (y == 0.0f) {
		float aspectRatio = FCDevice::Instance()->GetCapFloat(kFCDeviceDisplayAspectRatio);
		height = width * aspectRatio;
	}
	
	// build matrix
	
	m_viewport.SetPerspective(width, height, 1, 100);
}

