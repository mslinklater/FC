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

#ifndef _FCPhysics2DBody_h
#define _FCPhysics2DBody_h

#include "Shared/Core/FCCore.h"
#include "FCPhysics2DBodyDef.h"

class b2World;
class b2Body;

class FCPhysics2DBody : public FCBase {
public:
	
	FCPhysics2DBody(){}
	virtual ~FCPhysics2DBody();

	void	InitWithDef(FCPhysics2DBodyDefRef def);
	void	ApplyImpulseAtWorldPos( FCVector3f& impulse, FCVector3f& pos );
	void	CreateFixturesFromDef( FCPhysics2DBodyDefRef def );
	void	CreateBodyFromDef( FCPhysics2DBodyDefRef def );
	
	float		Rotation();
	void		SetRotation( float rot );
	FCVector3f	Position();
	void		SetPosition( FCVector3f pos );
	float		AngularVelocity();
	void		SetAngularVelocity( float angVel );
	FCVector3f	LinearVelocity();
	void		SetLinearVelocity( FCVector3f& vel );
	
	std::string	ID;
	std::string	name;
	b2World*	pWorld;
	b2Body*		pBody;
	FCHandle	handle;
};

typedef FCSharedPtr<FCPhysics2DBody> FCPhysics2DBodyRef;

typedef std::map<std::string, FCPhysics2DBodyRef> FCPhysics2DBodyRefMapByName;
typedef std::map<FCHandle, FCPhysics2DBodyRef> FCPhysics2DBodyRefByHandle;

#endif

