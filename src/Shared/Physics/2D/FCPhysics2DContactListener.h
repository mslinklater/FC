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


#ifndef CR1_FCPhysics2DContactListener_h
#define CR1_FCPhysics2DContactListener_h

#import "FCCore.h"

#include <map>
#include <set>

#include <Box2D/Box2D.h>

struct CollisionInfo {
	float velocity;
	float x;
	float y;
	float z;
	FCHandle	hActor1;
	FCHandle	hActor2;
};

typedef std::map<uint64_t, CollisionInfo>	tCollisionMap;
typedef tCollisionMap::iterator				tCollisionMapIter;

typedef void(*tCollisionSubscriber)(tCollisionMap&);

class FCPhysics2DContactListener : public b2ContactListener {
public:
	
	FCPhysics2DContactListener();
	~FCPhysics2DContactListener();
	
	void PreSolve( b2Contact* contact, const b2Manifold* oldManifold );	// input from Box2D
	
	void Clear();
	void DispatchToSubscribers();
	void AddSubscriber( tCollisionSubscriber subscriber );
	void RemoveSubscriber( tCollisionSubscriber subscriber );
	int	NumCollisions(){ return m_collisions.size(); }
private:

	typedef std::set<tCollisionSubscriber> tSubscriberSet;
	typedef tSubscriberSet::iterator tSubscriberSetIter;
	
	tCollisionMap	m_collisions;
	tSubscriberSet	m_subscribers;
};

#endif
