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

#ifndef FCACTOR_H
#define FCACTOR_H

#include "Shared/Core/FCCore.h"
#include "Shared/Physics/FCPhysics.h"
#include "Shared/Core/FCXML.h"
#include "FCResource.h"

@class FCModel;

class FCActor : public FCBase
{
public:
	FCActor();
	virtual ~FCActor();

	void Init(	FCXMLNode		xml,
				FCXMLNode		bodyXML,
				FCXMLNode		modelXML,
				FCResourcePtr	res,
				std::string		name,
				FCHandle		handle);
	
	virtual std::string Class(){ return "FCActor"; }
	
	void SetPosition(FCVector3f pos);
	FCVector3f Position();
	
	void SetLinearVelocity(FCVector3f vel);
	FCVector3f LinearVelocity();
	
	void SetDebugModelColor(FCColor4f color);
	
	void ApplyImpulseAtWorldPos(FCVector3f impulse, FCVector3f pos);
	
	virtual void Update(float realTime, float gameTime);
	virtual bool NeedsUpdate();
	virtual bool NeedsRender();
	virtual bool RespondsToTapGesture();
	
	virtual NSArray*	RenderGather();

	FCHandle			m_handle;
	std::string			m_name;
	std::string			m_id;
	std::string			m_fullName;
	FCXMLNode			m_createXML;
	FCModel*			m_model;
	FCPhysics2DBodyPtr	m_physicsBody;
};

typedef std::shared_ptr<FCActor>	FCActorPtr;

typedef std::vector<FCActorPtr>		FCActorVec;
typedef FCActorVec::iterator		FCActorVecIter;
typedef FCActorVec::const_iterator	FCActorVecConstIter;

typedef std::map<FCHandle, FCActorPtr>	FCActorMapByHandle;
typedef FCActorMapByHandle::iterator	FCActorMapByHandleIter;

typedef std::map<std::string, FCActorPtr> FCActorMapByString;

#endif	// FCACTOR_H
