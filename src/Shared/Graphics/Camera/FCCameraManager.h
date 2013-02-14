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

#ifndef FCCameraManager_h
#define FCCameraManager_h

#include "Shared/Core/FCCore.h"

class FCCamera;

class FCCameraManager {
public:
	static FCCameraManager* Instance();
	
	FCCameraManager();
	virtual ~FCCameraManager();
	
	void		Update( float dt, float gameTime );
	
	FCHandle	CreateCamera();
	void		DestroyCamera( FCHandle h );
	
	FCCamera*	GetCamera( FCHandle h );

	void		SetCameraPosition( FCHandle h, FCVector3f pos, float time );
	void		SetCameraTarget( FCHandle h, FCVector3f pos, float t );
	void		SetCameraOrthographicProjection( FCHandle h, float x, float y );
	void		SetCameraPerspectiveProjection( FCHandle h, float x, float y );
	
	// set position
	// set target
	// set upvector
	// set perspectiveprojection
	// set parallelprojection
	// set FOV
	
	// blend
		// set as parametric blend between two other cameras
	
	// animated camera
		// splines
	
protected:
	
	typedef std::map<FCHandle, FCCamera*>	CamerasByHandleMap;
	typedef CamerasByHandleMap::iterator	CamerasByHandleMapIter;

	CamerasByHandleMap	m_cameras;
};

#endif
