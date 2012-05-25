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

#include "FCActor.h"
#include "FCModel.h"

FCActor::FCActor()
{
}

FCActor::~FCActor()
{
	FCPhysics::Instance()->TwoD()->DestroyBody(m_physicsBody);
}

void FCActor::Init(	FCXMLNode		xml,
					FCXMLNode		bodyXML,
					FCXMLNode		modelXML,
					FCResourcePtr	res,
					std::string		name,
					FCHandle		handle)
{
	m_createXML = xml;
	m_id = FCXML::StringValueForNodeAttribute(m_createXML, kFCKeyId);
	m_handle = handle;
	
	// hardwired to 2D for now 8)
	
	if (bodyXML) 
	{
		FCPhysics2DBodyDefPtr bodyDef = FCPhysics2DBodyDefPtr( new FCPhysics2DBodyDef );
		
		FCVector2f pos;
		pos.Zero();
		
		pos.x += FCXML::FloatValueForNodeAttribute(m_createXML, kFCKeyOffsetX);
		pos.y += FCXML::FloatValueForNodeAttribute(m_createXML, kFCKeyOffsetY);
		
		bodyDef->position = pos;
		
		bodyDef->angle = FCXML::FloatValueForNodeAttribute(m_createXML, kFCKeyRotation);
		
		if( FCXML::BoolValueForNodeAttribute(m_createXML, kFCKeyDynamic) )
			bodyDef->isStatic = NO;
		else
			bodyDef->isStatic = YES;
		
		bodyDef->canSleep = NO;
		bodyDef->shapeXML = bodyXML;
		
		if (name.size()) {
			m_physicsBody = FCPhysics::Instance()->TwoD()->CreateBody(bodyDef, name, handle);
		}
		else {
			m_physicsBody = FCPhysics::Instance()->TwoD()->CreateBody(bodyDef, "", handle);
		}
	}
	
	// now create a model
	if (modelXML) 
	{
		m_model = [[FCModel alloc] initWithModel:modelXML resource:res];
	}
	else
	{
		if (bodyXML) 
		{
			// physics but no model so build a physics mode
			
			NSMutableDictionary* dict = (__bridge NSMutableDictionary*)res->UserData();
			m_model = [[FCModel alloc] initWithPhysicsBody:bodyXML color:[dict valueForKey:[NSString stringWithUTF8String:kFCKeyColor.c_str()]]];
		}
	}
}

void FCActor::SetPosition(FCVector3f pos)
{
	m_physicsBody->SetPosition(pos);
}

FCVector3f FCActor::Position()
{
	return m_physicsBody->Position();
}

void FCActor::SetLinearVelocity(FCVector3f vel)
{
	m_physicsBody->SetLinearVelocity(vel);
}

FCVector3f FCActor::LinearVelocity()
{
	return m_physicsBody->LinearVelocity();
}

void FCActor::SetDebugModelColor(FCColor4f color)
{
	[m_model setDebugMeshColor:color];
}

void FCActor::ApplyImpulseAtWorldPos(FCVector3f impulse, FCVector3f pos)
{
	m_physicsBody->ApplyImpulseAtWorldPos(impulse, pos);
}

//FCVector3f FCActor::GetCenter()
//{
//	FC_HALT;
//	return FCVector3f(0.0f, 0.0f, 0.0f);
//}

void FCActor::Update(float realTime, float gameTime)
{
	if( m_physicsBody )
	{
		FCVector3f pos = m_physicsBody->Position();
		float rot = m_physicsBody->Rotation();
		
		if( m_model )
		{
			[m_model setRotation:rot];
			[m_model setPosition:pos];					
		}
	}
}

bool FCActor::NeedsUpdate()
{
	return false;
}

bool FCActor::NeedsRender()
{
	return false;
}

bool FCActor::RespondsToTapGesture()
{
	return false;
}

NSArray*	FCActor::RenderGather()
{
	return nil;
}

//void FCActor::Render()
//{
//	FC_HALT;
//}
