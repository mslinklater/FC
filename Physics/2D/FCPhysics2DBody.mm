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
//#import "FCXMLData.h"
#import "FCPhysics.h"
#import "FCMaths.h"
#import "FCPhysics2DBodyDef.h"

@interface FCPhysics2DBody(hidden)
-(void)createFixturesFromDef:(FCPhysics2DBodyDef*)def;
-(void)createBodyFromDef:(FCPhysics2DBodyDef*)def;
@end

@implementation FCPhysics2DBody

@synthesize Id = _Id;
@synthesize name = _name;
@synthesize world = _world;
@synthesize b2Body = _b2Body;
@synthesize handle = _handle;

-(id)initWithDef:(FCPhysics2DBodyDef*)def
{
	self = [super init];
	if (self) 
	{
		_Id = def.Id;
		[self createBodyFromDef:def];
		[self createFixturesFromDef:def];
	}
	return self;
}

-(void)dealloc
{
	_world->DestroyBody(_b2Body);
}

-(void)createBodyFromDef:(FCPhysics2DBodyDef *)def
{
	b2BodyDef b2def;
	b2def.position.x = def.position.x;
	b2def.position.y = def.position.y;
	b2def.angle = FCDegToRad( def.angle );
	b2def.userData = (void*)def.hActor;
	b2def.allowSleep = def.canSleep;
	
	// Linear damping
	if (def.linearDamping != kFCInvalidFloat) {
		b2def.linearDamping = def.linearDamping;
	} else {
		b2def.linearDamping = 0;
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
	
	_b2Body = _world->CreateBody( &b2def );
}

-(void)createFixturesFromDef:(FCPhysics2DBodyDef*)def
{
//	NSArray* fixtures;
//	if ([[def.shapeDef valueForKey:@"fixture"] isKindOfClass:[NSDictionary class]]) {
//		fixtures = [NSArray arrayWithObject:[def.shapeDef valueForKey:@"fixture"]];
//	} else {
//		fixtures = [def.shapeDef valueForKey:@"fixture"];
//	}

	FCXMLNode shapeXML = def.shapeXML;
	FCXMLNodeVec fixtures = FCXML::VectorForChildNodesOfType( shapeXML, "fixture" );
	
//	for (NSDictionary* fixture in fixtures) 
	for (FCXMLNodeVecIter fixture = fixtures.begin(); fixture != fixtures.end(); fixture++)
	{
//		NSString* type = [fixture valueForKey:[NSString stringWithUTF8String:kFCKeyType.c_str()]];
		NSString* type = [NSString stringWithUTF8String:FCXML::StringValueForNodeAttribute(*fixture, kFCKeyType).c_str()];
		FC_ASSERT(type);

		b2FixtureDef fixtureDef;
		
//		NSString* materialString = [fixture valueForKey:[NSString stringWithUTF8String:kFCKeyMaterial.c_str()]];
		NSString* materialString = [NSString stringWithUTF8String:FCXML::StringValueForNodeAttribute(*fixture, kFCKeyMaterial).c_str()];
		FC_ASSERT(materialString);

		FCPhysicsMaterial* material = [[FCPhysics instance].materials valueForKey:materialString];
		FC_ASSERT(material);
		
		fixtureDef.density = material.density;
		fixtureDef.friction = material.friction;
		fixtureDef.restitution = material.restitution;
		fixtureDef.userData = (__bridge void*)def.actor;
				
		if ([type isEqualToString:[NSString stringWithUTF8String:kFCKeyCircle.c_str()]]) 
		{
			b2CircleShape shape;
//			shape.m_radius = [[fixture valueForKey:[NSString stringWithUTF8String:kFCKeyRadius.c_str()]] floatValue];
			shape.m_radius = FCXML::FloatValueForNodeAttribute(*fixture, kFCKeyRadius);
			b2Vec2 circlePos;
//			circlePos.x = [[fixture valueForKey:[NSString stringWithUTF8String:kFCKeyOffsetX.c_str()]] floatValue];
			circlePos.x = FCXML::FloatValueForNodeAttribute(*fixture, kFCKeyOffsetX);
//			circlePos.y = [[fixture valueForKey:[NSString stringWithUTF8String:kFCKeyOffsetY.c_str()]] floatValue];
			circlePos.y = FCXML::FloatValueForNodeAttribute(*fixture, kFCKeyOffsetY);
			shape.m_p = circlePos;
			fixtureDef.shape = &shape;
			_b2Body->CreateFixture( &fixtureDef );
		}
		else if ([type isEqualToString:[NSString stringWithUTF8String:kFCKeyBox.c_str()]]) 
		{
			b2PolygonShape shape;
			
			b2Vec2 rectanglePos;
//			float rectangleAngle = [[fixture valueForKey:[NSString stringWithUTF8String:kFCKeyAngle.c_str()]] floatValue];
			float rectangleAngle = FCXML::FloatValueForNodeAttribute(*fixture, kFCKeyAngle);
//			rectanglePos.x = [[fixture valueForKey:[NSString stringWithUTF8String:kFCKeyOffsetX.c_str()]] floatValue];
			rectanglePos.x = FCXML::FloatValueForNodeAttribute(*fixture, kFCKeyOffsetX);
//			rectanglePos.y = [[fixture valueForKey:[NSString stringWithUTF8String:kFCKeyOffsetY.c_str()]] floatValue];
			rectanglePos.y = FCXML::FloatValueForNodeAttribute(*fixture, kFCKeyOffsetY);
			
//			shape.SetAsBox( [[fixture valueForKey:[NSString stringWithUTF8String:kFCKeyXSize.c_str()]] floatValue] * 0.5f,	// box2D uses half height etc
//						   [[fixture valueForKey:[NSString stringWithUTF8String:kFCKeyYSize.c_str()]] floatValue] * 0.5f,
//						   rectanglePos, rectangleAngle);
			shape.SetAsBox( FCXML::FloatValueForNodeAttribute(*fixture, kFCKeyXSize) * 0.5f,	// box2D uses half height etc
							FCXML::FloatValueForNodeAttribute(*fixture, kFCKeyYSize) * 0.5f,
							rectanglePos, rectangleAngle);
			
			fixtureDef.shape = &shape;
			_b2Body->CreateFixture( &fixtureDef );
		}
		else if ([type isEqualToString:[NSString stringWithUTF8String:kFCKeyHull.c_str()]]) 
		{
			b2PolygonShape shape;
			
//			NSString* strippedVerts = [[fixture valueForKey:@"verts"] stringByReplacingOccurrencesOfString:@"," withString:@" "];
			NSString* vertsString = [NSString stringWithUTF8String:FCXML::StringValueForNodeAttribute(*fixture, "verts").c_str()];
			NSString* strippedVerts = [vertsString stringByReplacingOccurrencesOfString:@"," withString:@" "];
			strippedVerts = [strippedVerts stringByReplacingOccurrencesOfString:@"(" withString:@""];
			strippedVerts = [strippedVerts stringByReplacingOccurrencesOfString:@")" withString:@""];
			
			NSArray* vertsArray = [strippedVerts componentsSeparatedByString:@" "];
			
			int numVerts = [vertsArray count] / 3;
			
			b2Vec2* verts = (b2Vec2*)malloc(sizeof(b2Vec2) * numVerts );
			
//			float xOffset = [[fixture valueForKey:[NSString stringWithUTF8String:kFCKeyOffsetX.c_str()]] floatValue];
			float xOffset = FCXML::FloatValueForNodeAttribute(*fixture, kFCKeyOffsetX);
//			float yOffset = [[fixture valueForKey:[NSString stringWithUTF8String:kFCKeyOffsetY.c_str()]] floatValue];
			float yOffset = FCXML::FloatValueForNodeAttribute(*fixture, kFCKeyOffsetY);

			for(int i = 0 ; i < numVerts ; i++ )	// backwards due to different winding between collada and box2d
			{
				verts[numVerts - 1 - i].x = [[vertsArray objectAtIndex:i * 3] floatValue] + xOffset;
				verts[numVerts - 1 - i].y = [[vertsArray objectAtIndex:(i * 3) + 1] floatValue] + yOffset;
			}

			shape.Set(verts, numVerts);
			
			fixtureDef.shape = &shape;
			_b2Body->CreateFixture( &fixtureDef );
			
			delete [] verts;
		}
		else
		{
			NSAssert1( 0, @"Unknown physics fixture type %@", type);
		}
	}
}

#pragma mark - Position

-(FC::Vector3f)position
{
	const b2Vec2 pos = _b2Body->GetPosition();

	return FC::Vector3f(pos.x, pos.y, 0.0f);
}

-(void)setPosition:(FC::Vector3f)newPos
{
	float currentAngle = _b2Body->GetAngle();
	_b2Body->SetTransform( b2Vec2( newPos.x, newPos.y ), currentAngle );
}

#pragma mark - Velocity

-(FC::Vector2f)linearVelocity
{
	b2Vec2 vel = _b2Body->GetLinearVelocity();
	return FC::Vector2f( vel.x, vel.y );
}

-(void)setLinearVelocity:(FC::Vector2f)newVel
{
	b2Vec2 vel;
	vel.x = newVel.x;
	vel.y = newVel.y;
	_b2Body->SetLinearVelocity( vel );
}

#pragma mark - Apply forces & impulses

-(void)applyImpulse:(FC::Vector2f)impulse atWorldPos:(FC::Vector2f)pos
{
	b2Vec2 b2Imp;
	b2Vec2 b2Pos;
	
	b2Imp.x = impulse.x;
	b2Imp.y = impulse.y;
	b2Pos.x = pos.x;
	b2Pos.y = pos.y;
	
	_b2Body->ApplyLinearImpulse( b2Imp, b2Pos );
}

#pragma mark = Rotation

-(float)angularVelocity
{
	return _b2Body->GetAngularVelocity();
}

-(void)setAngularVelocity:(float)angularVelocity
{
	_b2Body->SetAngularVelocity(angularVelocity);
	return;
}

-(float)rotation
{
	return _b2Body->GetAngle();
}

-(void)setRotation:(float)rot
{
	const b2Vec2 currentPos = _b2Body->GetPosition();
	_b2Body->SetTransform( currentPos, rot );
}

#pragma mark - Debugging

-(NSString*)description
{
	FC::Vector3f pos = [self position];
	return [NSString stringWithFormat:@"pos (%f,%f)", pos.x, pos.y ];
}

@end

#endif // defined(FC_PHYSICS)
