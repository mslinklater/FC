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

#if 0

#if defined(FC_GRAPHICS)

#import "FCCore.h"
//#import "FCShader_apple.h"
#import "FCShaderProgramDebug_apple.h"
#import "FCShaderProgramFlatUnlit_apple.h"
#import "FCShaderProgramWireframe_apple.h"
#import "FCShaderProgramNoTexVLit_apple.h"
#import "FCShaderProgramNoTexPLit_apple.h"
#import "FCShaderProgram1TexVLit_apple.h"
#import "FCShaderProgram1TexPLit_apple.h"
#import "FCShaderProgramTest_apple.h"

#include "GLES/FCGLShader.h"

IFCShaderManager* plt_FCShaderManager_Instance()
{
	static FCShaderManagerProxy* pInstance = 0;
	if (!pInstance) {
		pInstance = new FCShaderManagerProxy;
	}
	return pInstance;
}

@implementation FCShaderManager_apple
@synthesize shaders = _shaders;
@synthesize programs = _programs;

+(FCShaderManager_apple*)instance
{
	static FCShaderManager_apple* pInstance = 0;
	
	if (!pInstance) {
		pInstance = [[FCShaderManager_apple alloc] init];
	}
	return pInstance;
}

-(id)init
{
	self = [super init];
	if (self) {
		_programs = [[NSMutableDictionary alloc] init];
	}
	return self;
}


-(FCGLShaderPtr)addShader:(NSString *)name
{
	FCGLShaderPtrMapByStringIter ret = _shaders.find([name UTF8String]);
	
	if( ret == _shaders.end() )
	{
		NSString* resourceName = [name stringByDeletingPathExtension];
		NSString* resourceType = [name pathExtension];
		
		// find shader in bundle
		
		NSString* path = [[NSBundle mainBundle] pathForResource:resourceName ofType:resourceType];

		FC_ASSERT_MSG( path, std::string("Shader not found: ") + [resourceName UTF8String]);
		
		// load it
		
		NSError* error;
		NSString* source = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error]; 
		
		// process it
		
		eFCShaderType type;
		
		if ([resourceType isEqualToString:@"vsh"]) {
			type = kShaderTypeVertex;
		} else {
			type = kShaderTypeFragment;
		}
		
		FCGLShaderPtr shader = FCGLShaderPtr( new FCGLShader( type, std::string([source UTF8String]) ) );
		
		FC_LOG( std::string("Compiled GL shader: ") + [name UTF8String]);

		_shaders[ [name UTF8String] ] = shader;
		
		// free pShader ?
		
		return _shaders[[name UTF8String]];
	}
	return ret->second;
}

-(FCGLShaderPtr)shader:(NSString *)name
{
	return _shaders[[name UTF8String]];
}

-(FCShaderProgram_apple*)addProgram:(NSString *)name //as:(NSString *)shaderName
{
	FCShaderProgram_apple* ret = [self.programs valueForKey:name];
	
	if (!ret) 
	{
		NSString* vertexShaderName = [NSString stringWithFormat:@"%@.vsh", name];
		NSString* fragmentShaderName = [NSString stringWithFormat:@"%@.fsh", name];
		
		FCGLShaderPtr vertexShader = [self addShader:vertexShaderName];
		FCGLShaderPtr fragmentShader = [self addShader:fragmentShaderName];
		
		// build program
		
		if ([name isEqualToString:[NSString stringWithUTF8String:kFCKeyShaderDebug.c_str()]]) 
		{
			ret = [[FCShaderProgramDebug_apple alloc] initWithVertex:vertexShader andFragment:fragmentShader];
		} 
		else if ([name isEqualToString:[NSString stringWithUTF8String:kFCKeyShaderWireframe.c_str()]]) 
		{
			ret = [[FCShaderProgramWireframe_apple alloc] initWithVertex:vertexShader andFragment:fragmentShader];
		} 
		else if ([name isEqualToString:[NSString stringWithUTF8String:kFCKeyShaderFlatUnlit.c_str()]]) 
		{
			ret = [[FCShaderProgramFlatUnlit_apple alloc] initWithVertex:vertexShader andFragment:fragmentShader];
		} 
		else if ([name isEqualToString:[NSString stringWithUTF8String:kFCKeyShaderNoTexVLit.c_str()]]) 
		{
			ret = [[FCShaderProgramNoTexVLit_apple alloc] initWithVertex:vertexShader andFragment:fragmentShader];
		} 
		else if ([name isEqualToString:[NSString stringWithUTF8String:kFCKeyShaderNoTexPLit.c_str()]]) 
		{
			ret = [[FCShaderProgramNoTexPLit_apple alloc] initWithVertex:vertexShader andFragment:fragmentShader];
		} 
		else if ([name isEqualToString:[NSString stringWithUTF8String:kFCKeyShader1TexVLit.c_str()]]) 
		{
			ret = [[FCShaderProgram1TexVLit_apple alloc] initWithVertex:vertexShader andFragment:fragmentShader];
		} 
		else if ([name isEqualToString:[NSString stringWithUTF8String:kFCKeyShader1TexPLit.c_str()]]) 
		{
			ret = [[FCShaderProgram1TexPLit_apple alloc] initWithVertex:vertexShader andFragment:fragmentShader];
		} 
		else if ([name isEqualToString:[NSString stringWithUTF8String:kFCKeyShaderTest.c_str()]]) 
		{
			ret = [[FCShaderProgramTest_apple alloc] initWithVertex:vertexShader andFragment:fragmentShader];
		} 
		else {
			FC_FATAL( std::string("Unknown shader: ") + [name UTF8String]);
		}
		
		FC_LOG( std::string("Linked GL program: ") + [name UTF8String]);
		
		[self.programs setValue:ret forKey:name];
	}
	return ret;
}

-(void)activateShader:(NSString *)shader
{
	[self addProgram:shader];
}

-(FCShaderProgram_apple*)program:(NSString *)name
{
	FC_ASSERT_MSG([self.programs valueForKey:name] != nil, "Trying to use an unknown shader");
	return [self.programs valueForKey:name];
}

-(NSArray*)allShaders
{
	return [_programs allValues];
}

@end

#endif // defined(FC_GRAPHICS)

#endif
