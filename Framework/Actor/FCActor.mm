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

@interface FCActor(hidden)
@end

@implementation FCActor

@synthesize handle = _handle;
@synthesize name = _name;
@synthesize createDef = _createDef;
@synthesize Id = _id;

#if defined (FC_GRAPHICS)
@synthesize model = _model;
#endif

#if defined (FC_PHYSICS)
@synthesize body2d = _body2d;
#endif

#pragma mark - Initializers

-(id)initWithDictionary:(NSDictionary*)dictionary body:(NSDictionary*)bodyDict model:(NSDictionary*)modelDict resource:(FCResource*)res
{
	self = [super init];
	if (self) 
	{	
		_createDef = dictionary;
		_id = [self.createDef valueForKey:kFCKeyId];
				
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
			
			_body2d = [[[FCPhysics instance] twoD] newBodyWithDef:bodyDef];
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
	
	_createDef = nil;
	_id = nil;
	
}

#pragma mark - Joints

#pragma mark - Getters

#if defined (FC_PHYSICS)
#pragma mark - Physics methods
-(FC::Vector2f)getCenter
{
	return [_body2d position];
}

-(void)applyImpulse:(FC::Vector2f)impulse atWorldPos:(FC::Vector2f)pos
{
	[_body2d applyImpulse:impulse atWorldPos:pos];
}

#endif

#pragma mark - Setters

-(void)setPosition:(FC::Vector2f)newPosition
{
#if defined (FC_PHYSICS)
	[_body2d setPosition:newPosition];
#endif
}

-(void)setDebugModelColor:(FC::Color4f)color
{
	[_model setDebugMeshColor:color];
	return;
}

-(FC::Vector2f)position
{
#if defined (FC_PHYSICS)
	return _body2d.position;
#else
	return FC::Vector2f( 0.0f, 0.0f );
#endif
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
	if( _body2d )
	{
		FC::Vector2f pos = [_body2d position ];
		float rot = [_body2d rotation];
		
		if( _model )
		{
			[_model setRotation:rot];
			[_model setPosition:FC::Vector3f(pos.x, pos.y, 0.0f)];					
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


