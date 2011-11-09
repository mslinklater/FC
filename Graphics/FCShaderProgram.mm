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

#import "FCShaderProgram.h"
#import "FCShader.h"
#import "FCCore.h"
#import "FCGLHelpers.h"
#import "FCShaderUniform.h"
#import "FCShaderAttribute.h"
#import "FCVertexDescriptor.h"

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
@synthesize attributes = _attributes;
@synthesize requiredVertexDescriptor = _requiredVertexDescriptor;

-(id)initWithVertex:(FCShader*)vertexShader andFragment:(FCShader*)fragmentShader
{
	self = [super init];
	if (self) {
		_glHandle = glCreateProgram();
		
		FC_ASSERT( self.glHandle );
		
		glAttachShader(self.glHandle, vertexShader.glHandle);
		glAttachShader(self.glHandle, fragmentShader.glHandle);
		
		glLinkProgram(self.glHandle);
		
		GLint linked;
		
		glGetProgramiv(self.glHandle, GL_LINK_STATUS, &linked);
		
		if (!linked) 
		{
			GLint infoLen = 0;
			
			glGetProgramiv(self.glHandle, GL_INFO_LOG_LENGTH, &infoLen);
			
			if (infoLen > 1) {
				char* infoLog = (char*)malloc(sizeof(char) * infoLen);
				glGetProgramInfoLog(self.glHandle, infoLen, NULL, infoLog);
				NSString* errorString = [NSString stringWithFormat:@"%s", infoLog];
				FC_FATAL1(@"Linking program:", errorString);
				free(infoLog);
			}
			
			glDeleteProgram(self.glHandle);
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
	[_vertexShader release];
	[_fragmentShader release];
	[_uniforms release];
	[super dealloc];
}

-(void)processUniforms
{
	NSMutableDictionary* uniforms = [NSMutableDictionary dictionary];
	
	GLint numUniforms;
	glGetProgramiv(self.glHandle, GL_ACTIVE_UNIFORMS, &numUniforms);
	
	GLint uniformMax;	
	glGetProgramiv(self.glHandle, GL_ACTIVE_UNIFORM_MAX_LENGTH, &uniformMax);
	
	GLchar* uniformNameBuffer = (GLchar*)malloc(sizeof(GLchar) * uniformMax);
	
	for (GLuint iUniform = 0; iUniform < numUniforms; iUniform++) 
	{
		GLsizei length;
		GLint num;
		GLenum type;
		GLint location;
		
		glGetActiveUniform(self.glHandle, iUniform, uniformMax, &length, &num, &type, uniformNameBuffer);
		
		location = glGetUniformLocation(self.glHandle, uniformNameBuffer);
		
		FCShaderUniform* thisUniform = [FCShaderUniform fcShaderUniform];
		
		thisUniform.glLocation = location;
		thisUniform.num = num;
		thisUniform.type = type;			
		
		[uniforms setValue:thisUniform forKey:[NSString stringWithFormat:@"%s", uniformNameBuffer]];			
	}
	
	free(uniformNameBuffer);
	
	_uniforms = [[NSDictionary dictionaryWithDictionary:uniforms] retain];	
}

-(void)processAttributes
{
	NSMutableDictionary* attributes = [NSMutableDictionary dictionary];
	
	GLint numActive;
	GLint maxLength;
	
	glGetProgramiv(self.glHandle, GL_ACTIVE_ATTRIBUTES, &numActive);
	glGetProgramiv(self.glHandle, GL_ACTIVE_ATTRIBUTE_MAX_LENGTH, &maxLength);
	
	char* attributeNameBuffer = (char*)malloc(sizeof(char) * maxLength);
	
	for (int i = 0; i < numActive; i++) 
	{
		GLsizei sizeWritten;
		GLint size;
		GLenum type;

		FCShaderAttribute* thisAttribute = [FCShaderAttribute fcShaderAttribute];

		glGetActiveAttrib(self.glHandle, i, maxLength, &sizeWritten, &size, &type, attributeNameBuffer);
		thisAttribute.glLocation = glGetAttribLocation(self.glHandle, attributeNameBuffer);
		thisAttribute.type = type;
		thisAttribute.num = size;
		
		[attributes setValue:thisAttribute forKey:[NSString stringWithFormat:@"%s", attributeNameBuffer]];
	}
	
	free( attributeNameBuffer );
	
	_attributes = [[NSDictionary dictionaryWithDictionary:attributes] retain];	

}

-(FCShaderUniform*)getUniform:(NSString *)name
{
	FCShaderUniform* uniform = [self.uniforms valueForKey:name];
	FC_ASSERT(uniform);
	return uniform;
}

-(GLuint)getAttribLocation:(NSString *)name
{
	GLuint location = glGetAttribLocation(self.glHandle, [name UTF8String]);
	
	FC_ASSERT(location != 0xffffffff);
	
	return location;
}

-(void)setUniformValue:(FCShaderUniform *)uniform to:(void *)pValues size:(unsigned int)size
{
	glUseProgram(self.glHandle);
	
	switch (uniform.type) 
	{
		case GL_FLOAT:
			FC_ASSERT(size == sizeof(GLfloat) * uniform.num);
			glUniform1fv(uniform.glLocation, uniform.num, (GLfloat*)pValues);
			break;
		case GL_FLOAT_VEC2:
			FC_ASSERT(size == sizeof(GLfloat) * 2 * uniform.num);
			glUniform2fv(uniform.glLocation, uniform.num, (GLfloat*)pValues);
			break;
		case GL_FLOAT_VEC3:
			FC_ASSERT(size == sizeof(GLfloat) * 3 * uniform.num);
			glUniform3fv(uniform.glLocation, uniform.num, (GLfloat*)pValues);
			break;
		case GL_FLOAT_VEC4:
			FC_ASSERT(size == sizeof(GLfloat) * 4 * uniform.num);
			glUniform4fv(uniform.glLocation, uniform.num, (GLfloat*)pValues);
			break;
			
		case GL_INT:
			FC_ASSERT(size == sizeof(GLint) * uniform.num);
			glUniform1iv(uniform.glLocation, uniform.num, (GLint*)pValues);
			break;
		case GL_INT_VEC2:
			FC_ASSERT(size == sizeof(GLint) * 2 * uniform.num);
			glUniform2iv(uniform.glLocation, uniform.num, (GLint*)pValues);
			break;
		case GL_INT_VEC3:
			FC_ASSERT(size == sizeof(GLint) * 3 * uniform.num);
			glUniform3iv(uniform.glLocation, uniform.num, (GLint*)pValues);
			break;
		case GL_INT_VEC4:
			FC_ASSERT(size == sizeof(GLint) * 4 * uniform.num);
			glUniform4iv(uniform.glLocation, uniform.num, (GLint*)pValues);
			break;
			
		case GL_FLOAT_MAT2:
			FC_ASSERT(size == sizeof(GLfloat) * 4 * uniform.num);
			glUniformMatrix2fv(uniform.glLocation, uniform.num, GL_FALSE, (GLfloat*)pValues);
			break;			
		case GL_FLOAT_MAT3:
			FC_ASSERT(size == sizeof(GLfloat) * 9 * uniform.num);
			glUniformMatrix3fv(uniform.glLocation, uniform.num, GL_FALSE, (GLfloat*)pValues);
			break;
		case GL_FLOAT_MAT4:
			FC_ASSERT(size == sizeof(GLfloat) * 16 * uniform.num);
			glUniformMatrix4fv(uniform.glLocation, uniform.num, GL_FALSE, (GLfloat*)pValues);
			break;

		default:
			NSString* uniformType = FCGLStringForEnum(uniform.type);
			FC_FATAL1(@"unknown uniform type", uniformType);
			break;
	}
}

-(void)use
{
	glUseProgram(self.glHandle);
}

-(void)validate
{
	glValidateProgram(self.glHandle);
	
	GLint status;
	
	glGetProgramiv(self.glHandle, GL_VALIDATE_STATUS, &status);

	if (!status) 
	{
		GLint infoLen = 0;
		
		glGetProgramiv(self.glHandle, GL_INFO_LOG_LENGTH, &infoLen);
		
		if (infoLen > 1) {
			char* infoLog = (char*)malloc(sizeof(char) * infoLen);
			glGetProgramInfoLog(self.glHandle, infoLen, NULL, infoLog);
			NSString* errorString = [NSString stringWithFormat:@"%s", infoLog];
			FC_FATAL1(@"Validate fail:", errorString);
			free(infoLog);
		}		
	}
}

-(NSArray*)getActiveAttributes
{
	NSMutableArray* attribArray = [NSMutableArray array];

	GLint numActive;
	GLint maxLength;
	
	glGetProgramiv(self.glHandle, GL_ACTIVE_ATTRIBUTES, &numActive);
	
	[attribArray addObject:[NSString stringWithFormat:@"Num active attributes: %d", numActive]];

	glGetProgramiv(self.glHandle, GL_ACTIVE_ATTRIBUTE_MAX_LENGTH, &maxLength);
	
	char* pBuffer = (char*)malloc(sizeof(char) * maxLength);

	for (int i = 0; i < numActive; i++) {
		GLsizei sizeWritten;
		GLint size;
		GLenum type;
		glGetActiveAttrib(self.glHandle, i, maxLength, &sizeWritten, &size, &type, pBuffer);
		
		[attribArray addObject:[NSString stringWithFormat:@"%d %s %d x %@", i, pBuffer, size, FCGLStringForEnum(type)]];
	}
	
	free( pBuffer );
	
	return [NSArray arrayWithArray:attribArray];
}

-(FCVertexDescriptor*)requiredVertexDescriptor
{
	if (!_requiredVertexDescriptor) {
		_requiredVertexDescriptor = [[FCVertexDescriptor alloc] init];
		
		NSLog(@"uniforms: %@", self.uniforms);
		
		NSLog(@"attributes: %@", self.attributes);
		
		NSArray* keys = [self.attributes allKeys];
		
		for( NSString* key in keys )
		{
//			FCShaderAttribute* attr = [self.attributes valueForKey:key];
			
		}
		
	}
	return _requiredVertexDescriptor;
}

@end

#endif // TARGET_OS_IPHONE

