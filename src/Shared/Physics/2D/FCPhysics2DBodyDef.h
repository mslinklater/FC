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

#include "Shared/Core/FCCore.h"
#include "Shared/Core/FCXML.h"

class b2World;

class FCPhysics2DBodyDef : public FCBase {
public:
	FCPhysics2DBodyDef()
	: position(0.0f, 0.0f)
	, angle(0.0f)
	, isStatic(false)
	, linearDamping( kFCInvalidFloat )
	, pWorld(0)
	, hActor(kFCHandleInvalid)
	, shapeXML(0)
	, canSleep(true)
	, actor(0)
	{
	}
	std::string	ID(){ return FCXML::StringValueForNodeAttribute(shapeXML, kFCKeyId); }
	float		angle;
	bool		isStatic;
	bool		canSleep;
	float		linearDamping;
	FCXMLNode	shapeXML;
	b2World*	pWorld;
	FCHandle	hActor;
	FCVector2f	position;
	void*		actor;	// deprecate
};

typedef FCSharedPtr<FCPhysics2DBodyDef> FCPhysics2DBodyDefRef;

