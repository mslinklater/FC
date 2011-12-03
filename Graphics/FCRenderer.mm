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

#import "FCCore.h"
#import "FCRenderer.h"
#import "FCGameContext.h"
#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>
#import "FCModel.h"
#import "FCProtocols.h"
#import "FCShaderManager.h"
#import "FCTextureManager.h"

@implementation FCRenderer
@synthesize shaderManager = _shaderManager;
@synthesize textureManager = _textureManager;

#pragma mark - FCSingleton protocol

+(FCRenderer*)instance
{
	static FCRenderer* pInstance;
	
	if (!pInstance) {
		pInstance = [[FCRenderer alloc] init];
	}
	return pInstance;
}

-(id)init
{
	self = [super init];
	if (self) {
		mModels = [[NSMutableArray alloc] init];
		mGatherList = [[NSMutableArray alloc] init];
		_shaderManager = [[FCShaderManager alloc] init];
		_textureManager = [[FCTextureManager alloc] init];
	}
	FC_LOG(@"FCRenderer initialised OK");
	return self;
}

-(void)dealloc
{
	 _shaderManager = nil;
}

-(void)prebuildShaders
{
	[self.shaderManager addProgram:@"debug_debug"];
}

-(void)addToGatherList:(id)obj
{
	[mGatherList addObject:obj];
}

-(void)removeFromGatherList:(id)obj
{
	[mGatherList removeObject:obj];
}

-(void)render
{
	// go through gather list and aggregate the arrays
	
	[mModels removeAllObjects];
	
	// gather from objects on the gather list
	
	for( id<FCGameObjectRender> obj in mGatherList )
	{
		[mModels addObjectsFromArray:[obj renderGather]];
	}

	// sorting here ?

	// render the models in sorted order
	
	for( FCModel* model in mModels )
	{
		[model render];
	}

	[mModels removeAllObjects];
}

@end

#endif // TARGET_OS_IPHONE
