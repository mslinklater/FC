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

#import "FCActor.h"
#import "FCRenderer.h"
#import "FCActorSystem.h"
#import "FCResource.h"
#import "FCCore.h"
#import "FCModel.h"

@implementation FCActor

@synthesize handle = _handle;
@synthesize name = _name;
@synthesize fullName = _fullName;
@synthesize createXML = _createXML;
@synthesize Id = _id;

#if defined (FC_GRAPHICS)
@synthesize model = _model;
#endif

#if defined (FC_PHYSICS)
@synthesize physicsBody = _physicsBody;
#endif

#pragma mark - Initializers

-(id)initWithXML:(FCXMLNode)xml 
			body:(FCXMLNode)bodyXML 
		   model:(FCXMLNode)modelXML 
		resource:(FCResourcePtr)res
			name:(NSString*)name
		  handle:(FCHandle)handle
{
	self = [super init];
	if (self) 
	{	
		_createXML = xml;
		_id = [NSString stringWithUTF8String:FCXML::StringValueForNodeAttribute(_createXML, kFCKeyId).c_str()];
		_handle = handle;
				
		// hardwired to 2D for now 8)
		
		if (bodyXML) 
		{
#if defined (FC_PHYSICS)
			FCPhysics2DBodyDefPtr bodyDef = FCPhysics2DBodyDefPtr( new FCPhysics2DBodyDef );
			
			FCVector2f pos;
			pos.Zero();
			
			pos.x += FCXML::FloatValueForNodeAttribute(_createXML, kFCKeyOffsetX);
			pos.y += FCXML::FloatValueForNodeAttribute(_createXML, kFCKeyOffsetY);
			
			bodyDef->position = pos;
			
			bodyDef->angle = FCXML::FloatValueForNodeAttribute(_createXML, kFCKeyRotation);
			
			if( FCXML::BoolValueForNodeAttribute(_createXML, kFCKeyDynamic) )
				bodyDef->isStatic = NO;
			else
				bodyDef->isStatic = YES;
			
			bodyDef->canSleep = NO;
			bodyDef->shapeXML = bodyXML;
			
			if (name) {
				_physicsBody = FCPhysics::Instance()->TwoD()->CreateBody(bodyDef, [name UTF8String], handle);
			}
			else {
				_physicsBody = FCPhysics::Instance()->TwoD()->CreateBody(bodyDef, "", handle);
			}
#endif
		}
		
		// now create a model
#if defined (FC_GRAPHICS)
		if (modelXML) 
		{
			_model = [[FCModel alloc] initWithModel:modelXML resource:res];
		}
		else
		{
			if (bodyXML) 
			{
				// physics but no model so build a physics mode
				
				NSMutableDictionary* dict = (__bridge NSMutableDictionary*)res->UserData();
				_model = [[FCModel alloc] initWithPhysicsBody:bodyXML color:[dict valueForKey:[NSString stringWithUTF8String:kFCKeyColor.c_str()]]];
			}
		}
#endif // defined(FC_GRAPHICS)
	}
	return self;
}

-(void)dealloc
{
	FCPhysics::Instance()->TwoD()->DestroyBody(_physicsBody);
	_physicsBody = nil;
	_model = nil;
	_id = nil;
	_fullName = nil;
	_name = nil;
}

#pragma mark - Joints

#pragma mark - Getters

#if defined (FC_PHYSICS)
#pragma mark - Physics methods
-(FCVector3f)getCenter
{
	return _physicsBody->Position();
}

-(void)applyImpulse:(FCVector3f)impulse atWorldPos:(FCVector3f)pos
{
	_physicsBody->ApplyImpulseAtWorldPos(impulse, pos);
}

#endif

#pragma mark - Position

-(void)setPosition:(FCVector3f)newPosition
{
#if defined (FC_PHYSICS)
	_physicsBody->SetPosition(newPosition);
#endif
}

-(FCVector3f)position
{
#if defined (FC_PHYSICS)
	return _physicsBody->Position();
#else
	return FCVector3f( 0.0f, 0.0f, 0.0f );
#endif
}

#pragma mark - Linear Velocity

-(void)setLinearVelocity:(FCVector3f)vel
{
#if defined (FC_PHYSICS)
	_physicsBody->SetLinearVelocity(vel);
#endif
}

-(FCVector3f)linearVelocity
{
#if defined (FC_PHYSICS)
	return _physicsBody->LinearVelocity();
#else
	return FCVector2f( 0.0f, 0.0f, 0.0f );
#endif
}

-(void)setDebugModelColor:(FCColor4f)color
{
	[_model setDebugMeshColor:color];
	return;
}

-(BOOL)needsUpdate
{
	return NO;
}

-(BOOL)needsRender
{
	return NO;
}

-(BOOL)respondsToTapGesture
{
	return NO;
}

-(void)update:(float)gameTime;
{
	// TODO: needs to be able to handle model positioning without physics
#if defined (FC_PHYSICS)
	if( _physicsBody )
	{
		FCVector3f pos = _physicsBody->Position();
		float rot = _physicsBody->Rotation();
		
		if( _model )
		{
			[_model setRotation:rot];
			[_model setPosition:pos];					
		}
	}
#endif
}

#if defined (FC_GRAPHICS)
-(void)render
{
//	[_model render];
}
#endif

-(float)radius
{
	return 0.0f;
}

-(BOOL)posWithinBounds:(FCVector2f)pos
{
	return NO;
}

@end


