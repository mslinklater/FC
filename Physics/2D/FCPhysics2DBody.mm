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

#if defined (FC_PHYSICS)

#import <Box2D/Box2D.h>

#import "FCPhysics2DBody.h"
#import "FCMacros.h"
#import "FCXMLData.h"
#import "FCPhysics.h"
#import "FCMaths.h"
#import "FCPhysics2DBodyDef.h"

@interface FCPhysics2DBody(hidden)
-(void)createFixturesFromDef:(FCPhysics2DBodyDef*)def;
-(void)createBodyFromDef:(FCPhysics2DBodyDef*)def;
@end

@implementation FCPhysics2DBody

@synthesize world = _world;
@synthesize body = _body;
//@synthesize rotation = _rotation;

//-(void)setWorld:(b2World*)world
//{
//	pWorld = world;
//}

-(id)initWithDef:(FCPhysics2DBodyDef*)def
{
	self = [super init];
	if (self) 
	{
		[self createBodyFromDef:def];
		[self createFixturesFromDef:def];
	}
	return self;
}

-(void)dealloc
{
	_world->DestroyBody(_body);
}

-(void)createBodyFromDef:(FCPhysics2DBodyDef *)def
{
//	NSDictionary* bodyXML = [physicsData dictionaryForKeyPath:@"physics2d.body"];
	
	b2BodyDef b2def;
	b2def.position.x = def.position.x;
	b2def.position.y = def.position.y;
	b2def.angle = FCDegToRad( def.angle );
	b2def.userData = (__bridge void*)def.actor;
	b2def.allowSleep = def.canSleep;
	
	// Linear damping
	if (def.linearDamping != kFCInvalidFloat) {
		b2def.linearDamping = def.linearDamping;
	} else {
		b2def.linearDamping = 0;
//		if ([bodyXML valueForKey:kFCKeyLinearDamping]) {
//			b2def.linearDamping = [[bodyXML valueForKey:kFCKeyLinearDamping] floatValue];	
//		}		
	}
	
	if (def.isStatic) 
	{
		b2def.type = b2_staticBody;
	}
	else
	{
		b2def.type = b2_dynamicBody;
	}
	
	_world = def.world;
	
	_body = _world->CreateBody( &b2def );
}

-(void)createFixturesFromDef:(FCPhysics2DBodyDef*)def
{
//	NSArray* fixtures = [physicsData arrayForKeyPath:@"physics2d.fixtures.fixture"];

	NSArray* fixtures;
	
	if ([[def.shapeDef valueForKey:@"fixture"] isKindOfClass:[NSDictionary class]]) {
		fixtures = [NSArray arrayWithObject:[def.shapeDef valueForKey:@"fixture"]];
	} else {
		fixtures = [def.shapeDef valueForKey:@"fixture"];
	}
	
	for (NSDictionary* fixture in fixtures) 
	{
		NSString* type = [fixture valueForKey:kFCKeyType];
		FC_ASSERT(type);

		b2FixtureDef fixtureDef;
		
		NSString* materialString = [fixture valueForKey:kFCKeyMaterial];
		FC_ASSERT(materialString);

		FCPhysicsMaterial* material = [[FCPhysics instance].materials valueForKey:materialString];
		FC_ASSERT(material);
		
		fixtureDef.density = material.density;
		fixtureDef.friction = material.friction;
		fixtureDef.restitution = material.restitution;
		fixtureDef.userData = (__bridge void*)def.actor;
				
		if ([type isEqualToString:kFCKeyCircle]) 
		{
			b2CircleShape shape;
			shape.m_radius = [[fixture valueForKey:kFCKeyRadius] floatValue];
			b2Vec2 circlePos;
			circlePos.x = [[fixture valueForKey:kFCKeyOffsetX] floatValue];
			circlePos.y = [[fixture valueForKey:kFCKeyOffsetY] floatValue];
			shape.m_p = circlePos;
			fixtureDef.shape = &shape;
			_body->CreateFixture( &fixtureDef );
		}
		else if ([type isEqualToString:kFCKeyRectangle]) 
		{
			b2PolygonShape shape;
			
			b2Vec2 rectanglePos;
			float rectangleAngle = [[fixture valueForKey:kFCKeyAngle] floatValue];
			rectanglePos.x = [[fixture valueForKey:kFCKeyOffsetX] floatValue];
			rectanglePos.y = [[fixture valueForKey:kFCKeyOffsetY] floatValue];
			
			shape.SetAsBox( [[fixture valueForKey:kFCKeyXSize] floatValue] * 0.5f,	// box2D uses half height etc
						   [[fixture valueForKey:kFCKeyYSize] floatValue] * 0.5f,
						   rectanglePos, rectangleAngle);
			
			fixtureDef.shape = &shape;
			_body->CreateFixture( &fixtureDef );
		}
		else if ([type isEqualToString:kFCKeyPolygon]) 
		{
			b2PolygonShape shape;
			
			NSArray* vertsArray = [[fixture valueForKey:@"verts"] componentsSeparatedByString:@" "];
			
			int numVerts = [vertsArray count] / 2;
			
			b2Vec2* verts = (b2Vec2*)malloc(sizeof(b2Vec2) * numVerts );
			
			float xOffset = [[fixture valueForKey:kFCKeyOffsetX] floatValue];
			float yOffset = [[fixture valueForKey:kFCKeyOffsetY] floatValue];
			
			for(int i = 0 ; i < numVerts ; i++ )	// backwards due to different winding between collada and box2d
			{
				verts[numVerts - 1 - i].x = [[vertsArray objectAtIndex:i * 2] floatValue] + xOffset;
				verts[numVerts - 1 - i].y = [[vertsArray objectAtIndex:(i * 2) + 1] floatValue] + yOffset;
			}

			shape.Set(verts, numVerts);
			
			
			fixtureDef.shape = &shape;
			_body->CreateFixture( &fixtureDef );
			
			delete [] verts;
		}
		else
		{
			NSAssert1( 0, @"Unknown physics fixture type %@", type);
		}
	}

//	[physicsData release];
}

//-(b2Body*)b2Body
//{
//	return pBody;
//}

#pragma mark - Position

-(FC::Vector2f)position
{
	const b2Vec2 pos = _body->GetPosition();

	return FC::Vector2f(pos.x, pos.y);
}

-(void)setPosition:(FC::Vector2f)newPos
{
	_body->SetTransform( b2Vec2( newPos.x, newPos.y ), 0.0f );
}

#pragma mark - Velocity

-(FC::Vector2f)linearVelocity
{
	b2Vec2 vel = _body->GetLinearVelocity();
	return FC::Vector2f( vel.x, vel.y );
}

-(void)setLinearVelocity:(FC::Vector2f)newVel
{
	b2Vec2 vel;
	vel.x = newVel.x;
	vel.y = newVel.y;
	_body->SetLinearVelocity( vel );
}

-(void)applyImpulse:(FC::Vector2f)impulse atWorldPos:(FC::Vector2f)pos
{
	b2Vec2 b2Imp;
	b2Vec2 b2Pos;
	
	b2Imp.x = impulse.x;
	b2Imp.y = impulse.y;
	b2Pos.x = pos.x;
	b2Pos.y = pos.y;
	
	_body->ApplyLinearImpulse( b2Imp, b2Pos );
}

-(float)rotation
{
	return _body->GetAngle();
}

#pragma mark - Create Joints

-(void)createRevoluteJointWith:(FCPhysics2DBody*)anchorBody atOffset:(FC::Vector2f)anchorOffset motorSpeed:(float)motorSpeed maxTorque:(float)maxToque lowerAngle:(float)lower upperAngle:(float)upper
{
	b2Body* pAnchorB2Body = anchorBody.body;
	
	b2Vec2 offset;	//= pAnchorB2Body->GetWorldCenter();
	offset.x = anchorOffset.x;
	offset.y = anchorOffset.y;
	
	b2RevoluteJointDef jointDef;
	jointDef.Initialize(pAnchorB2Body, _body, offset);
	
	if ((motorSpeed != kFCInvalidFloat) && (maxToque != kFCInvalidFloat)) {
		jointDef.enableMotor = true;
		jointDef.motorSpeed = motorSpeed;
		jointDef.maxMotorTorque = maxToque;
	}

	if ((lower != kFCInvalidFloat) && (upper != kFCInvalidFloat)) {
		jointDef.enableLimit = true;
		jointDef.lowerAngle = lower;
		jointDef.upperAngle = upper;
	}
	
	_world->CreateJoint(&jointDef);
}

-(void)createPrismaticJointWith:(FCPhysics2DBody*)anchorBody axis:(FC::Vector2f)axis motorSpeed:(float)motorSpeed maxForce:(float)maxForce lowerTranslation:(float)lower upperTranslation:(float)upper
{
	b2Body* pAnchorB2Body = anchorBody.body;

	b2Vec2 b2axis;
	b2axis.x = axis.x;
	b2axis.y = axis.y;
	
	b2PrismaticJointDef jointDef;
	jointDef.Initialize( pAnchorB2Body, _body, pAnchorB2Body->GetWorldCenter(), b2axis);
	
	if ((motorSpeed != kFCInvalidFloat) && (maxForce != kFCInvalidFloat)) 
	{
		jointDef.enableMotor = true;
		jointDef.maxMotorForce = maxForce;
		jointDef.motorSpeed = motorSpeed;
	}

	if ((lower != kFCInvalidFloat) && (upper != kFCInvalidFloat)) 
	{
		jointDef.enableLimit = true;
		jointDef.lowerTranslation = lower;
		jointDef.upperTranslation = upper;
	}

	_world->CreateJoint( &jointDef );
}

-(void)createDistanceJointWith:(FCPhysics2DBody*)anchorBody atOffset:(FC::Vector2f)offset anchorOffset:(FC::Vector2f)anchorOffset
{
	b2Body* pAnchorB2Body = anchorBody.body;
	
	b2Vec2 b2AnchorOffset;	//= pAnchorB2Body->GetWorldCenter();
	b2AnchorOffset.x = anchorOffset.x;
	b2AnchorOffset.y = anchorOffset.y;

	b2Vec2 b2Offset;	//= pBody->GetWorldCenter();
	b2Offset.x = offset.x;
	b2Offset.y = offset.y;

	b2DistanceJointDef jointDef;
	jointDef.Initialize(_body, pAnchorB2Body, b2Offset, b2AnchorOffset);
	jointDef.collideConnected = true;
	_world->CreateJoint(&jointDef);
}

-(void)createPulleyJointWith:(FCPhysics2DBody*)otherBody anchor1:(FC::Vector2f)anchor1 anchor2:(FC::Vector2f)anchor2 groundAnchor1:(FC::Vector2f)ground1 groundAnchor2:(FC::Vector2f)ground2 ratio:(float)ratio maxLength1:(float)maxLength1 maxLength2:(float)maxLength2
{
	b2Body* pBody2 = otherBody.body;
	
	b2PulleyJointDef jointDef;
	
	b2Vec2 b2Anchor1( anchor1.x, anchor1.y );
	b2Anchor1 += _body->GetWorldCenter();
	b2Vec2 b2Anchor2( anchor2.x, anchor2.y );
	b2Anchor2 += pBody2->GetWorldCenter();
	
	b2Vec2 b2Ground1( ground1.x, ground1.y );
	b2Vec2 b2Ground2( ground2.x, ground2.y );
	
	jointDef.Initialize( _body, pBody2, b2Ground1, b2Ground2, b2Anchor1, b2Anchor2, ratio );
	
	if (maxLength1 != kFCInvalidFloat) {
		jointDef.maxLengthA = maxLength1;
	}
	if (maxLength2 != kFCInvalidFloat) {
		jointDef.maxLengthB = maxLength2;
	}

	_world->CreateJoint( &jointDef );	
}

#pragma mark - Debugging

-(NSString*)description
{
	FC::Vector2f pos = [self position];
	return [NSString stringWithFormat:@"pos (%f,%f)", pos.x, pos.y];
}

@end

#endif // defined(FC_PHYSICS)
