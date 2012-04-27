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

#if defined(FC_GRAPHICS)

#import "FCShaderProgram.h"
#import "FCShader.h"
#import "FCCore.h"
#import "FCGLHelpers.h"
#import "FCShaderUniform.h"
#import "FCShaderAttribute.h"
#import "FCMesh.h"
#import "FCGL.h"

#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES2/glext.h>

@interface FCShaderProgram()
-(void)processUniforms;
-(void)processAttributes;
@end

@implementation FCShaderProgram
@synthesize glHandle = _glHandle;
@synthesize vertexShader = _vertexShader;
@synthesize fragmentShader = _fragmentShader;
@synthesize uniforms = _uniforms;
@synthesize perMeshUniforms = _perMeshUniforms;
@synthesize attributes = _attributes;
@synthesize stride = _stride;

-(id)initWithVertex:(FCShader*)vertexShader andFragment:(FCShader*)fragmentShader
{
	self = [super init];
	if (self) {
		_glHandle = FCglCreateProgram();
		
		FC_ASSERT( self.glHandle );
		
		_vertexShader = vertexShader;
		_fragmentShader = fragmentShader;
		
		FCglAttachShader(self.glHandle, vertexShader.glHandle);
		FCglAttachShader(self.glHandle, fragmentShader.glHandle);
		
		FCglLinkProgram(self.glHandle);
		
		GLint linked;
		
		FCglGetProgramiv(self.glHandle, GL_LINK_STATUS, &linked);
		
		if (!linked) 
		{
			GLint infoLen = 0;
			
			FCglGetProgramiv(self.glHandle, GL_INFO_LOG_LENGTH, &infoLen);
			
			if (infoLen > 1) {
				char* infoLog = (char*)malloc(sizeof(char) * infoLen);
				FCglGetProgramInfoLog(self.glHandle, infoLen, NULL, infoLog);
				NSString* errorString = [NSString stringWithFormat:@"%s", infoLog];
				FC_FATAL1(@"Linking program:%@", errorString);
				free(infoLog);
			}
			
			FCglDeleteProgram(self.glHandle);
			return nil;
		}
		
		[self processUniforms];
		[self processAttributes];
		
		[self getActiveAttributes];
	}
	return self;
}

-(void)dealloc
{
	glDeleteProgram(self.glHandle);
}

-(void)processUniforms
{
	NSMutableDictionary* uniforms = [NSMutableDictionary dictionary];
	NSMutableDictionary* perMeshUniforms = [NSMutableDictionary dictionary];
	
	GLint numUniforms;
	FCglGetProgramiv(self.glHandle, GL_ACTIVE_UNIFORMS, &numUniforms);
	
	GLint uniformMax;	
	FCglGetProgramiv(self.glHandle, GL_ACTIVE_UNIFORM_MAX_LENGTH, &uniformMax);
	
	GLchar* uniformNameBuffer = (GLchar*)malloc(sizeof(GLchar) * uniformMax);
	
	for (GLuint iUniform = 0; iUniform < numUniforms; iUniform++) 
	{
		GLsizei length;
		GLint num;
		GLenum type;
		GLint location;
		
		FCglGetActiveUniform(self.glHandle, iUniform, uniformMax, &length, &num, &type, uniformNameBuffer);
		
		location = FCglGetUniformLocation(self.glHandle, uniformNameBuffer);
		
		FCShaderUniform* thisUniform = [FCShaderUniform fcShaderUniform];
		
		thisUniform.glLocation = location;
		thisUniform.num = num;
		thisUniform.type = type;			
		
		NSString* uniformNameString = [NSString stringWithFormat:@"%s", uniformNameBuffer];
		
		[uniforms setValue:thisUniform forKey:uniformNameString];
		
		if (![uniformNameString isEqualToString:@"projection"] && ![uniformNameString isEqualToString:@"modelview"]) {
			[perMeshUniforms setValue:thisUniform forKey:uniformNameString];
		}
	}
	
	free(uniformNameBuffer);
	
	_uniforms = [NSDictionary dictionaryWithDictionary:uniforms];	
	_perMeshUniforms = [NSDictionary dictionaryWithDictionary:perMeshUniforms];
}

-(void)processAttributes
{
	NSMutableDictionary* attributes = [NSMutableDictionary dictionary];
	
	GLint numActive;
	GLint maxLength;
	
	FCglGetProgramiv(self.glHandle, GL_ACTIVE_ATTRIBUTES, &numActive);
	FCglGetProgramiv(self.glHandle, GL_ACTIVE_ATTRIBUTE_MAX_LENGTH, &maxLength);
	
	char* attributeNameBuffer = (char*)malloc(sizeof(char) * maxLength);
	
	for (int i = 0; i < numActive; i++) 
	{
		GLsizei sizeWritten;
		GLint size;
		GLenum type;

		FCShaderAttribute* thisAttribute = [FCShaderAttribute fcShaderAttribute];

		FCglGetActiveAttrib(self.glHandle, i, maxLength, &sizeWritten, &size, &type, attributeNameBuffer);
		thisAttribute.glLocation = FCglGetAttribLocation(self.glHandle, attributeNameBuffer);
		thisAttribute.type = type;
		thisAttribute.num = size;
		
		[attributes setValue:thisAttribute forKey:[NSString stringWithFormat:@"%s", attributeNameBuffer]];
	}
	
	free( attributeNameBuffer );
	
	_attributes = [NSDictionary dictionaryWithDictionary:attributes];	

}

-(FCShaderUniform*)getUniform:(NSString *)name
{
	FCShaderUniform* uniform = [self.uniforms valueForKey:name];
	return uniform;
}

-(GLuint)getAttribLocation:(NSString *)name
{
	GLuint location = FCglGetAttribLocation(self.glHandle, [name UTF8String]);
	return location;
}

-(void)setUniformValue:(FCShaderUniform *)uniform to:(void *)pValues size:(unsigned int)size
{
	FCglUseProgram(self.glHandle);
	
	switch (uniform.type) 
	{
		case GL_FLOAT:
			FC_ASSERT(size == sizeof(GLfloat) * uniform.num);
			FCglUniform1fv(uniform.glLocation, uniform.num, (GLfloat*)pValues);
			break;
		case GL_FLOAT_VEC2:
			FC_ASSERT(size == sizeof(GLfloat) * 2 * uniform.num);
			FCglUniform2fv(uniform.glLocation, uniform.num, (GLfloat*)pValues);
			break;
		case GL_FLOAT_VEC3:
			FC_ASSERT(size == sizeof(GLfloat) * 3 * uniform.num);
			FCglUniform3fv(uniform.glLocation, uniform.num, (GLfloat*)pValues);
			break;
		case GL_FLOAT_VEC4:
			FC_ASSERT(size == sizeof(GLfloat) * 4 * uniform.num);
			FCglUniform4fv(uniform.glLocation, uniform.num, (GLfloat*)pValues);
			break;
			
		case GL_INT:
			FC_ASSERT(size == sizeof(GLint) * uniform.num);
			FCglUniform1iv(uniform.glLocation, uniform.num, (GLint*)pValues);
			break;
		case GL_INT_VEC2:
			FC_ASSERT(size == sizeof(GLint) * 2 * uniform.num);
			FCglUniform2iv(uniform.glLocation, uniform.num, (GLint*)pValues);
			break;
		case GL_INT_VEC3:
			FC_ASSERT(size == sizeof(GLint) * 3 * uniform.num);
			FCglUniform3iv(uniform.glLocation, uniform.num, (GLint*)pValues);
			break;
		case GL_INT_VEC4:
			FC_ASSERT(size == sizeof(GLint) * 4 * uniform.num);
			FCglUniform4iv(uniform.glLocation, uniform.num, (GLint*)pValues);
			break;
			
		case GL_FLOAT_MAT2:
			FC_ASSERT(size == sizeof(GLfloat) * 4 * uniform.num);
			FCglUniformMatrix2fv(uniform.glLocation, uniform.num, GL_FALSE, (GLfloat*)pValues);
			break;			
		case GL_FLOAT_MAT3:
			FC_ASSERT(size == sizeof(GLfloat) * 9 * uniform.num);
			FCglUniformMatrix3fv(uniform.glLocation, uniform.num, GL_FALSE, (GLfloat*)pValues);
			break;
		case GL_FLOAT_MAT4:
			FC_ASSERT(size == sizeof(GLfloat) * 16 * uniform.num);
			FCglUniformMatrix4fv(uniform.glLocation, uniform.num, GL_FALSE, (GLfloat*)pValues);
			break;

		default:
			NSString* uniformType = FCGLStringForEnum(uniform.type);
			FC_FATAL1(@"unknown uniform type:%@", uniformType);
			break;
	}
}

-(void)use
{
	FCglUseProgram(self.glHandle);
}

-(void)bindUniformsWithMesh:(FCMesh*)mesh vertexDescriptor:(FCVertexDescriptor *)vertexDescriptor
{
	FC_HALT;
}

-(void)bindAttributesWithVertexDescriptor:(FCVertexDescriptor *)vertexDescriptor
{
	FC_HALT;
}

-(void)validate
{
	FCglValidateProgram(self.glHandle);
	
	GLint status;
	
	FCglGetProgramiv(self.glHandle, GL_VALIDATE_STATUS, &status);

	if (!status) 
	{
		GLint infoLen = 0;
		
		FCglGetProgramiv(self.glHandle, GL_INFO_LOG_LENGTH, &infoLen);
		
		if (infoLen > 1) {
			char* infoLog = (char*)malloc(sizeof(char) * infoLen);
			FCglGetProgramInfoLog(self.glHandle, infoLen, NULL, infoLog);
			NSString* errorString = [NSString stringWithFormat:@"%s", infoLog];
			FC_FATAL1(@"Validate fail:%@", errorString);
			free(infoLog);
		}		
	}
}

-(NSArray*)getActiveAttributes
{
	NSMutableArray* attribArray = [NSMutableArray array];

	GLint numActive;
	GLint maxLength;
	
	FCglGetProgramiv(self.glHandle, GL_ACTIVE_ATTRIBUTES, &numActive);
	
	[attribArray addObject:[NSString stringWithFormat:@"Num active attributes: %d", numActive]];

	FCglGetProgramiv(self.glHandle, GL_ACTIVE_ATTRIBUTE_MAX_LENGTH, &maxLength);
	
	char* pBuffer = (char*)malloc(sizeof(char) * maxLength);

	for (int i = 0; i < numActive; i++) {
		GLsizei sizeWritten;
		GLint size;
		GLenum type;
		FCglGetActiveAttrib(self.glHandle, i, maxLength, &sizeWritten, &size, &type, pBuffer);
		
		[attribArray addObject:[NSString stringWithFormat:@"%d %s %d x %@", i, pBuffer, size, FCGLStringForEnum(type)]];
	}
	
	free( pBuffer );
	
	return [NSArray arrayWithArray:attribArray];
}

@end

#endif // defined(FC_GRAPHICS)

