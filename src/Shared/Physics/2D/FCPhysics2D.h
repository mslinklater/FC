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

#ifndef _FCPhysics2D_h
#define _FCPhysics2D_h

#include <map>

#include <Box2D/Box2D.h>

#include "Shared/Core/FCCore.h"
#include "FCPhysics2DBody.h"
#include "FCPhysics2DContactListener.h"
#include "FCPhysics2DJoint.h"


class FCPhysics2D : public FCBase {
public:	
	FCPhysics2D();
	virtual ~FCPhysics2D();
	
	void Init();
	
//	b2World*	World(){ return m_pWorld; }
//	void		SetWorld( b2World* pWorld ){ m_pWorld = pWorld; }
//
//	b2Vec2		Gravity(){ return m_gravity; }
//	void		SetGravity( const b2Vec2& gravity ){ m_gravity = gravity; }

	void	Update( float realTime, float gameTime );
	void	PrepareForDealloc();
	
	FCPhysics2DBodyRef	CreateBody( FCPhysics2DBodyDefRef def, std::string name, FCHandle actorHandle );
	void				DestroyBody( FCPhysics2DBodyRef body );
	FCPhysics2DBodyRef	BodyWithName( std::string name );
	
//	FCHandle	CreateJoint( FCPhysics2DJointCreateDefRef def );
	
	FCHandle	CreateDistanceJoint( FCPhysics2DDistanceJointCreateDefRef def );
	FCHandle	CreateRevoluteJoint( FCPhysics2DRevoluteJointCreateDefRef def );
	FCHandle	CreatePrismaticJoint( FCPhysics2DPrismaticJointCreateDefRef def );
	FCHandle	CreatePulleyJoint( FCPhysics2DPulleyJointCreateDefRef def );
	FCHandle	CreateRopeJoint( FCPhysics2DRopeJointCreateDefRef def );
	
	void		SetRevoluteJointMotor( FCHandle joint, bool enabled, float torque, float speed );
	void		SetRevoluteJointLimits( FCHandle joint, bool enable, float min, float max );
	
	void		SetPrismaticJointMotor( FCHandle joint, bool enable, float force, float speed );
	void		SetPrismaticJointLimits( FCHandle joint, bool enable, float min, float max );
	
	FCPhysics2DContactListener* ContactListener();
	
private:
	b2World*					m_pWorld;
	b2Vec2						m_gravity;
	FCPhysics2DJointMapByHandle	m_joints;
	FCPhysics2DBodyRefByHandle	m_bodies;
	FCPhysics2DBodyRefMapByName	m_bodiesByName;
	FCPhysics2DContactListener*	m_contactListener;
};

typedef FCSharedPtr<FCPhysics2D> FCPhysics2DRef;

#endif

