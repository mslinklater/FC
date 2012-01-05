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

#import "FCCore.h"
#import "FCShaderManager.h"
#import "FCShader.h"
#import "FCShaderProgram.h"

@interface FCShaderManager()
@property(nonatomic, strong) NSMutableDictionary* shaders;
@property(nonatomic, strong) NSMutableDictionary* programs;
@end

@implementation FCShaderManager
@synthesize shaders = _shaders;
@synthesize programs = _programs;

-(id)init
{
	self = [super init];
	if (self) {
		_shaders = [[NSMutableDictionary alloc] init];
		_programs = [[NSMutableDictionary alloc] init];
	}
	return self;
}


-(FCShader*)addShader:(NSString *)name
{
	FCShader* ret = [self.shaders valueForKey:name];
	
	if (!ret) 
	{
		NSString* resourceName = [name stringByDeletingPathExtension];
		NSString* resourceType = [name pathExtension];
		
		// find shader in bundle
		
		NSString* path = [[NSBundle mainBundle] pathForResource:resourceName ofType:resourceType];
		
		FC_ASSERT1(path, @"shader not found");
		
		// load it
		
		NSError* error;
		NSString* source = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error]; 
		
		// process it
		
		eShaderType type;
		
		if ([resourceType isEqualToString:@"vsh"]) {
			type = kShaderTypeVertex;
		} else {
			type = kShaderTypeFragment;
		}
		
//		FCShader* newShader = [[FCShader alloc] initType:type withSource:source];
		ret = [[FCShader alloc] initType:type withSource:source];
		
		[self.shaders setValue:ret forKey:name];
		
//		ret = newShader;
		
//		[ret autorelease];
	}
	return ret;
}

-(FCShader*)shader:(NSString *)name
{
	return [self.shaders valueForKey:name];
}

-(FCShaderProgram*)addProgram:(NSString *)name
{
	FCShaderProgram* ret = [self.programs valueForKey:name];
	
	if (!ret) 
	{
		NSArray* nameArray = [name componentsSeparatedByString:@"_"];
		
		FC_ASSERT( [nameArray count] == 2 );
		
		NSString* vertexShaderName = [NSString stringWithFormat:@"%@.vsh", [nameArray objectAtIndex:0]];
		NSString* fragmentShaderName = [NSString stringWithFormat:@"%@.fsh", [nameArray objectAtIndex:1]];
		
		FCShader* vertexShader = [self addShader:vertexShaderName];
		FCShader* fragmentShader = [self addShader:fragmentShaderName];
		
		// build program
		
//		FCShaderProgram* program = [[FCShaderProgram alloc] initWithVertex:vertexShader andFragment:fragmentShader];
		ret = [[FCShaderProgram alloc] initWithVertex:vertexShader andFragment:fragmentShader];
		
//		[self.programs setValue:program forKey:name];
		[self.programs setValue:ret forKey:name];
		
//		ret = program;

//		[program autorelease];
	}
	return ret;
}

-(FCShaderProgram*)program:(NSString *)name
{
	FC_ASSERT1([self.programs valueForKey:name] != nil, @"Trying to use an unknown shader");
	return [self.programs valueForKey:name];
}

@end

#endif // TARGET_OS_IPHONE

