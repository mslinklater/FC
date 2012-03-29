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
#import "FCPhysics.h"
#import "FCActorSystem.h"
#import "FCResource.h"
#import "FCCore.h"
#import "FCModel.h"

@implementation FCActor

@synthesize handle = _handle;
@synthesize name = _name;
@synthesize fullName = _fullName;
@synthesize createDef = _createDef;
@synthesize Id = _id;

#if defined (FC_GRAPHICS)
@synthesize model = _model;
#endif

#if defined (FC_PHYSICS)
@synthesize physicsBody = _physicsBody;
#endif

#pragma mark - Initializers

-(id)initWithDictionary:(NSDictionary*)dictionary 
				   body:(NSDictionary*)bodyDict 
				  model:(NSDictionary*)modelDict 
			   resource:(FCResource*)res
				   name:(NSString*)name
				 handle:(FCHandle)handle
{
	self = [super init];
	if (self) 
	{	
		_createDef = dictionary;
		_id = [self.createDef valueForKey:kFCKeyId];
		_handle = handle;
				
		// hardwired to 2D for now 8)
		
		if (bodyDict) 
		{
#if defined (FC_PHYSICS)
			FCPhysics2DBodyDef* bodyDef = [FCPhysics2DBodyDef defaultDef];
			
			FC::Vector2f pos;
			pos.Zero();
			
			pos.x += [[dictionary valueForKey:kFCKeyOffsetX] floatValue];
			pos.y += [[dictionary valueForKey:kFCKeyOffsetY] floatValue];
			
			[bodyDef setPosition:pos];	// TODO: change to property access
			bodyDef.angle = [[dictionary valueForKey:@"rotation"] floatValue];
			bodyDef.actor = self;
			
			if ([[dictionary valueForKey:kFCKeyDynamic] isEqualToString:@"yes"]) {
				bodyDef.isStatic = NO;
			} else {
				bodyDef.isStatic = YES;
			}
			
			bodyDef.canSleep = NO;
			bodyDef.shapeDef = bodyDict;
			
			_physicsBody = [[[FCPhysics instance] twoD] createBodyWithDef:bodyDef name:name actorHandle:handle];
#endif
		}
		
		// now create a model
#if defined (FC_GRAPHICS)
//		if (modelDict) 
		if ( 0 )
		{
			_model = [[FCModel alloc] initWithModel:modelDict resource:res];
		}
		else
		{
			if (bodyDict) 
			{
				// physics but no model so build a physics mode
				
				NSMutableDictionary* dict = res.userData;
				_model = [[FCModel alloc] initWithPhysicsBody:bodyDict color:[dict valueForKey:kFCKeyColor]];
			}
		}
#endif // defined(FC_GRAPHICS)
	}
	return self;
}

-(void)dealloc
{
	[[[FCPhysics instance] twoD] destroyBody:_physicsBody];	
	_physicsBody = nil;
	_model = nil;
	_createDef = nil;
	_id = nil;
	_fullName = nil;
	_name = nil;
}

#pragma mark - Joints

#pragma mark - Getters

#if defined (FC_PHYSICS)
#pragma mark - Physics methods
-(FC::Vector3f)getCenter
{
	return [_physicsBody position];
}

-(void)applyImpulse:(FC::Vector3f)impulse atWorldPos:(FC::Vector3f)pos
{
	[_physicsBody applyImpulse:impulse atWorldPos:pos];
}

#endif

#pragma mark - Position

-(void)setPosition:(FC::Vector3f)newPosition
{
#if defined (FC_PHYSICS)
	[_physicsBody setPosition:newPosition];
#endif
}

-(FC::Vector3f)position
{
#if defined (FC_PHYSICS)
	return _physicsBody.position;
#else
	return FC::Vector3f( 0.0f, 0.0f, 0.0f );
#endif
}

#pragma mark - Linear Velocity

-(void)setLinearVelocity:(FC::Vector3f)vel
{
#if defined (FC_PHYSICS)
	[_physicsBody setLinearVelocity:vel];
#endif
}

-(FC::Vector3f)linearVelocity
{
#if defined (FC_PHYSICS)
	return [_physicsBody linearVelocity];
#else
	return FC::Vector2f( 0.0f, 0.0f, 0.0f );
#endif
}

-(void)setDebugModelColor:(FC::Color4f)color
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
		FC::Vector3f pos = [_physicsBody position ];
		float rot = [_physicsBody rotation];
		
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
	[_model render];
}
#endif

-(float)radius
{
	return 0.0f;
}

-(BOOL)posWithinBounds:(FC::Vector2f)pos
{
	return NO;
}

@end


