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

#include <Box2D/Box2D.h>

#include "Shared/Physics/2D/FCPhysics2DBody.h"
#include "Shared/Physics/FCPhysics.h"
#include "Shared/Core/FCStringUtils.h"

FCPhysics2DBody::~FCPhysics2DBody()
{
	pWorld->DestroyBody( pBody );
}

void FCPhysics2DBody::InitWithDef(FCPhysics2DBodyDefPtr def)
{
	ID = def->ID();
	CreateBodyFromDef( def );
	CreateFixturesFromDef( def );
}

void FCPhysics2DBody::ApplyImpulseAtWorldPos( FCVector3f& impulse, FCVector3f& pos )
{
	b2Vec2 b2Imp;
	b2Vec2 b2Pos;
	
	b2Imp.x = impulse.x;
	b2Imp.y = impulse.y;
	b2Pos.x = pos.x;
	b2Pos.y = pos.y;
	
	pBody->ApplyLinearImpulse( b2Imp, b2Pos );
}

void FCPhysics2DBody::CreateFixturesFromDef( FCPhysics2DBodyDefPtr def )
{
	FCXMLNode shapeXML = def->shapeXML;
	FCXMLNodeVec fixtures = FCXML::VectorForChildNodesOfType( shapeXML, "fixture" );
	
	for (FCXMLNodeVecIter fixture = fixtures.begin(); fixture != fixtures.end(); fixture++)
	{
		std::string type = FCXML::StringValueForNodeAttribute(*fixture, kFCKeyType);

		FC_ASSERT(type.length());
		
		b2FixtureDef fixtureDef;
		
		std::string materialString = FCXML::StringValueForNodeAttribute(*fixture, kFCKeyMaterial);
		
		FCPhysicsMaterialPtr material = FCPhysics::Instance()->GetMaterials()[materialString];
		FC_ASSERT(material);
		
		fixtureDef.density = material->density;
		fixtureDef.friction = material->friction;
		fixtureDef.restitution = material->restitution;
		fixtureDef.userData = def->actor;
		
		if ( type == kFCKeyCircle )
		{
			b2CircleShape shape;
			shape.m_radius = FCXML::FloatValueForNodeAttribute(*fixture, kFCKeyRadius);
			b2Vec2 circlePos;
			circlePos.x = FCXML::FloatValueForNodeAttribute(*fixture, kFCKeyOffsetX);
			circlePos.y = FCXML::FloatValueForNodeAttribute(*fixture, kFCKeyOffsetY);
			shape.m_p = circlePos;
			fixtureDef.shape = &shape;
			pBody->CreateFixture( &fixtureDef );
		}
		else if ( type == kFCKeyBox )
		{
			b2PolygonShape shape;
			
			b2Vec2 rectanglePos;
			float rectangleAngle = FCXML::FloatValueForNodeAttribute(*fixture, kFCKeyAngle);
			rectanglePos.x = FCXML::FloatValueForNodeAttribute(*fixture, kFCKeyOffsetX);
			rectanglePos.y = FCXML::FloatValueForNodeAttribute(*fixture, kFCKeyOffsetY);
			
			shape.SetAsBox( FCXML::FloatValueForNodeAttribute(*fixture, kFCKeyXSize) * 0.5f,	// box2D uses half height etc
						   FCXML::FloatValueForNodeAttribute(*fixture, kFCKeyYSize) * 0.5f,
						   rectanglePos, rectangleAngle);
			
			fixtureDef.shape = &shape;
			pBody->CreateFixture( &fixtureDef );
		}
		else if ( type == kFCKeyHull )
		{
			b2PolygonShape shape;
			
			std::string vertsString = FCXML::StringValueForNodeAttribute(*fixture, "verts");
			FCStringUtils_ReplaceOccurencesOfStringWithString( vertsString, ",", " ");
			FCStringUtils_ReplaceOccurencesOfStringWithString( vertsString, "(", "");			
			FCStringUtils_ReplaceOccurencesOfStringWithString( vertsString, ")", "");

			FCStringVector vertsArray = FCStringUtils_ComponentsSeparatedByString(vertsString, " ");
			
			int numVerts = vertsArray.size() / 3;
			
			b2Vec2* verts = (b2Vec2*)malloc(sizeof(b2Vec2) * numVerts );
			
			float xOffset = FCXML::FloatValueForNodeAttribute(*fixture, kFCKeyOffsetX);
			float yOffset = FCXML::FloatValueForNodeAttribute(*fixture, kFCKeyOffsetY);
			
			for(int i = 0 ; i < numVerts ; i++ )	// backwards due to different winding between collada and box2d
			{
				verts[numVerts - 1 - i].x = atof(vertsArray[i * 3].c_str()) + xOffset;
				verts[numVerts - 1 - i].y = atof(vertsArray[(i * 3) + 1].c_str()) + yOffset;
			}
			
			shape.Set(verts, numVerts);
			
			fixtureDef.shape = &shape;
			pBody->CreateFixture( &fixtureDef );
			
			delete [] verts;
		}
		else
		{
			FC_HALT;
		}
	}
}

void FCPhysics2DBody::CreateBodyFromDef( FCPhysics2DBodyDefPtr def )
{
	b2BodyDef b2def;
	b2def.position.x = def->position.x;
	b2def.position.y = def->position.y;
	b2def.angle = FCDegToRad( def->angle );
	b2def.userData = (void*)def->hActor;
	b2def.allowSleep = def->canSleep;
	
	// Linear damping
	if (def->linearDamping != kFCInvalidFloat) {
		b2def.linearDamping = def->linearDamping;
	} else {
		b2def.linearDamping = 0;
	}
	
	if (def->isStatic) 
	{
		b2def.type = b2_staticBody;
	}
	else
	{
		b2def.type = b2_dynamicBody;
	}
	
	pWorld = def->pWorld;
	
	pBody = pWorld->CreateBody( &b2def );
}

float FCPhysics2DBody::Rotation()
{
	return pBody->GetAngle();
}

void FCPhysics2DBody::SetRotation( float rot )
{
	const b2Vec2 currentPos = pBody->GetPosition();
	pBody->SetTransform( currentPos, rot );
}

FCVector3f FCPhysics2DBody::Position()
{
	const b2Vec2 pos = pBody->GetPosition();
	return FCVector3f(pos.x, pos.y, 0.0f);
}

void FCPhysics2DBody::SetPosition( FCVector3f pos )
{
	float currentAngle = pBody->GetAngle();
	pBody->SetTransform( b2Vec2( pos.x, pos.y ), currentAngle );
}

float FCPhysics2DBody::AngularVelocity()
{
	return pBody->GetAngularVelocity();
}

void FCPhysics2DBody::SetAngularVelocity( float angVel )
{
	pBody->SetAngularVelocity( angVel );
}

FCVector3f FCPhysics2DBody::LinearVelocity()
{
	b2Vec2 vel = pBody->GetLinearVelocity();
	return FCVector3f( vel.x, vel.y, 0.0f );
}

void FCPhysics2DBody::SetLinearVelocity( FCVector3f& newVel )
{
	b2Vec2 vel;
	vel.x = newVel.x;
	vel.y = newVel.y;
	pBody->SetLinearVelocity( vel );
}
