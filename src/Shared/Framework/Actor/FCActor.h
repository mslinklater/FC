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
#include "Shared/Core/Resources/FCResource.h"

#include "Shared/Graphics/FCGraphics.h"

#include "Shared/Graphics/FCModel.h"

class FCActor : public FCBase
{
public:
	FCActor();
	virtual ~FCActor();

	void Init(	FCXMLNode		xml,
				FCXMLNode		bodyXML,
				FCXMLNode		modelXML,
				FCResourceRef	res,
				std::string		name,
				FCHandle		handle);
	
	virtual std::string Class(){ return "FCActor"; }
	
	void SetPosition(FCVector3f pos);
	FCVector3f Position() const;
	
	void SetLinearVelocity(FCVector3f vel);
	FCVector3f LinearVelocity() const;
	
	void SetDebugModelColor(FCColor4f color);
	
	void ApplyImpulseAtWorldPos(FCVector3f impulse, FCVector3f pos);

	FCHandle	Handle() const { return m_handle; }
	void		SetHandle( FCHandle handle ){ m_handle = handle; }
	
	const std::string& FullName() const { return m_fullName; }
	void		SetFullName( std::string name ){ m_fullName = name; }

	virtual void Update(float realTime, float gameTime);
	virtual bool NeedsUpdate();
	virtual bool NeedsRender();
	virtual bool RespondsToTapGesture();
	
	virtual FCModelRefVec	RenderGather();
	
protected:
	FCHandle			m_handle;
	std::string			m_name;
	std::string			m_id;
	std::string			m_fullName;
	FCXMLNode			m_createXML;
	
	FCModelRef			m_model;

	FCPhysics2DBodyRef	m_physicsBody;
};

typedef FCSharedPtr<FCActor>	FCActorRef;

typedef std::vector<FCActorRef>		FCActorRefVec;
typedef FCActorRefVec::iterator		FCActorRefVecIter;
typedef FCActorRefVec::const_iterator	FCActorRefVecConstIter;

typedef std::map<FCHandle, FCActorRef>	FCActorRefMapByHandle;
typedef FCActorRefMapByHandle::iterator	FCActorRefMapByHandleIter;

typedef std::map<std::string, FCActorRef> FCActorRefMapByString;

#endif	// FCACTOR_H
