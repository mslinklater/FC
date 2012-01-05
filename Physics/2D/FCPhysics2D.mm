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

#if TARGET_OS_IPHONE

#import "FCPhysics2D.h"

@implementation FCPhysics2D

#pragma mark - FCGameObjectLifetime protocol

-(void)reset
{
    
}

-(void)destroy
{
    
}

#pragma mark - FCGameObjectUpdate protocol

-(void)update:(float)realTime gameTime:(float)gameTime
{
    pWorld->Step( gameTime, 6, 2 );
//	pWorld->ClearForces();
}

-(id)init
{
	self = [super init];
	if (self) 
	{
		gravity = b2Vec2( 0.0f, -9.8f );
		
		if (!pWorld) 
		{
			pWorld = new b2World( gravity, true );
		}
	}
	return self;
}

-(void)dealloc
{
	delete pWorld; 
	pWorld = 0;
}

-(FCPhysics2DBody*)newBodyWithDef:(FCPhysics2DBodyDef*)def
{
	def.world = pWorld;

	FCPhysics2DBody* newBody = [[FCPhysics2DBody alloc] initWithDef:def];

	return newBody;
}

//-(void*)userDataForObjectAtPosition:(FC::Vector2f)pos
//{
//	
//	return 0;
//}

@end

#endif // TARGET_OS_IPHONE
