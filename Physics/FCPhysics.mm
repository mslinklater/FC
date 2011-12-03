/*
 Copyright (C) 2011 by Martin Linklater
 
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

#import "FCPhysics.h"

@implementation FCPhysics

@synthesize twoD = _twoD;
@synthesize threeD = _threeD;
@synthesize materials = _materials;

#pragma mark - FCSingleton protocol

+(FCPhysics*)instance
{
	static FCPhysics* pInstance;
	
	if (!pInstance) {
		pInstance = [[FCPhysics alloc] init];
	}
	return pInstance;
}

#pragma mark - FCGameObjectLifetime protocol

-(void)reset
{
	_twoD = nil;
	
}

-(void)destroy
{
	
}

#pragma mark - FCGameObjectUpdate protocol

-(void)update:(float)realTime gameTime:(float)gameTime
{
	
}

-(id)init
{
	self = [super init];
	if (self) 
	{
		_materials = [[NSMutableDictionary alloc] init];
	}
	return self;
}

-(void)dealloc
{
	[self reset];
}

-(void)create2DComponent
{
	_twoD = [[FCPhysics2D alloc] init];	
}

-(void)create3DComponent
{
	
}
@end

#endif // TARGET_OS_IPHONE
