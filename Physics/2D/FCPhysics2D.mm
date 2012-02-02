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

#import "FCPhysics2D.h"

@implementation FCPhysics2D

@synthesize world = _world;
@synthesize gravity = _gravity;
@synthesize joints = _joints;
@synthesize bodiesByNameDict = _bodiesByNameDict;

#pragma mark - Object Lifecycle

-(id)init
{
	self = [super init];
	if (self) 
	{
		mNextHandle = 0;
		_joints = [NSMutableDictionary dictionary];
		
		_gravity = b2Vec2( 0.0f, -9.8f );
		
		if (!_world) 
		{
			_world = new b2World( _gravity, true );
		}
	}
	return self;
}

-(void)dealloc
{
	delete _world; 
	_world = 0;
}

#pragma mark - FCGameObjectUpdate protocol

-(void)update:(float)realTime gameTime:(float)gameTime
{
    _world->Step( gameTime, 6, 2 );
//	pWorld->ClearForces();
}

-(FCPhysics2DBody*)newBodyWithDef:(FCPhysics2DBodyDef*)def
{
	def.world = _world;

	FCPhysics2DBody* newBody = [[FCPhysics2DBody alloc] initWithDef:def];

	[_bodiesByNameDict setValue:newBody forKey:newBody.name];
	
	return newBody;
}

-(void)destroyBody:(FCPhysics2DBody*)body
{
	[_bodiesByNameDict setValue:nil forKey:body.name];
}

-(FCPhysics2DBody*)bodyWithName:(NSString*)name
{
	return [_bodiesByNameDict valueForKey:name];
}

#pragma mark - Joints

-(FCHandle)createJoint:(FCPhysics2DJointCreateDef*)def
{
	return (FCHandle)mNextHandle++;
}

@end

#endif // defined(FC_PHYSICS)
