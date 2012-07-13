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

#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES2/glext.h>

#include "GLES/FCGL.h"

#include "GLES/FCGLShader.h"

@interface FCShaderProgram_apple()
-(void)processUniforms;
-(void)processAttributes;
@end

@implementation FCShaderProgram_apple
@synthesize glHandle = _glHandle;
@synthesize vertexShader = _vertexShader;
@synthesize fragmentShader = _fragmentShader;
@synthesize uniforms = _uniforms;
@synthesize attributes = _attributes;
@synthesize stride = _stride;

-(id)initWithVertex:(FCGLShaderPtr)vertexShader andFragment:(FCGLShaderPtr)fragmentShader
{
	self = [super init];
	if (self) {
		_glHandle = FCglCreateProgram();
		
		FC_ASSERT( self.glHandle );
		
		_vertexShader = vertexShader;
		_fragmentShader = fragmentShader;
		
		FCglAttachShader(self.glHandle, vertexShader->Handle() );
		FCglAttachShader(self.glHandle, fragmentShader->Handle() );
		
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
				FC_FATAL( std::string("Linking program: ") +  [errorString UTF8String]);
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
	GLint numUniforms;
	FCglGetProgramiv(self.glHandle, GL_ACTIVE_UNIFORMS, &numUniforms);
	
	GLint uniformMax;	
	FCglGetProgramiv(self.glHandle, GL_ACTIVE_UNIFORM_MAX_LENGTH, &uniformMax);
	
	GLchar* uniformNameBuffer = (GLchar*)malloc(sizeof(GLchar) * uniformMax);
	
	for (GLint iUniform = 0; iUniform < numUniforms; iUniform++) 
	{
		GLsizei length;
		GLint num;
		GLenum type;
		GLint location;
		
		FCglGetActiveUniform(self.glHandle, iUniform, uniformMax, &length, &num, &type, uniformNameBuffer);
		
		location = FCglGetUniformLocation(self.glHandle, uniformNameBuffer);
		
		FCGLShaderUniformPtr uniform = FCGLShaderUniformPtr( new FCGLShaderUniform );
		
		uniform->SetLocation( location );
		uniform->SetNum( num );
		uniform->SetType( type );
		
		_uniforms[ uniformNameBuffer ] = uniform;
	}
	
	free(uniformNameBuffer);
}

-(void)processAttributes
{
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

		FCglGetActiveAttrib(self.glHandle, i, maxLength, &sizeWritten, &size, &type, attributeNameBuffer);
		
		FCGLShaderAttributePtr attribute = FCGLShaderAttributePtr( new FCGLShaderAttribute );
		
		attribute->SetLocation( FCglGetAttribLocation(self.glHandle, attributeNameBuffer) );
		attribute->SetType( type );
		attribute->SetNum( size );
		
		_attributes[ attributeNameBuffer ] = attribute;		
	}
	
	free( attributeNameBuffer );
}

-(FCGLShaderUniformPtr)getUniform:(NSString *)name
{
	FCGLShaderUniformPtrMapByStringIter i = _uniforms.find([name UTF8String]);

	if (i == _uniforms.end()) {
		return 0;
	} else {
		return i->second;
	}
}

-(GLuint)getAttribLocation:(NSString *)name
{
	GLuint location = FCglGetAttribLocation(self.glHandle, [name UTF8String]);
	return location;
}

-(void)setUniformValue:(FCGLShaderUniformPtr)uniform to:(void *)pValues size:(unsigned int)size
{
	FCglUseProgram(self.glHandle);
	
	switch (uniform->Type()) 
	{
		case GL_FLOAT:
			FC_ASSERT(size == sizeof(GLfloat) * uniform->Num());
			FCglUniform1fv(uniform->Location(), uniform->Num(), (GLfloat*)pValues);
			break;
		case GL_FLOAT_VEC2:
			FC_ASSERT(size == sizeof(GLfloat) * 2 * uniform->Num());
			FCglUniform2fv(uniform->Location(), uniform->Num(), (GLfloat*)pValues);
			break;
		case GL_FLOAT_VEC3:
			FC_ASSERT(size == sizeof(GLfloat) * 3 * uniform->Num());
			FCglUniform3fv(uniform->Location(), uniform->Num(), (GLfloat*)pValues);
			break;
		case GL_FLOAT_VEC4:
			FC_ASSERT(size == sizeof(GLfloat) * 4 * uniform->Num());
			FCglUniform4fv(uniform->Location(), uniform->Num(), (GLfloat*)pValues);
			break;
			
		case GL_INT:
			FC_ASSERT(size == sizeof(GLint) * uniform->Num());
			FCglUniform1iv(uniform->Location(), uniform->Num(), (GLint*)pValues);
			break;
		case GL_INT_VEC2:
			FC_ASSERT(size == sizeof(GLint) * 2 * uniform->Num());
			FCglUniform2iv(uniform->Location(), uniform->Num(), (GLint*)pValues);
			break;
		case GL_INT_VEC3:
			FC_ASSERT(size == sizeof(GLint) * 3 * uniform->Num());
			FCglUniform3iv(uniform->Location(), uniform->Num(), (GLint*)pValues);
			break;
		case GL_INT_VEC4:
			FC_ASSERT(size == sizeof(GLint) * 4 * uniform->Num());
			FCglUniform4iv(uniform->Location(), uniform->Num(), (GLint*)pValues);
			break;
			
		case GL_FLOAT_MAT2:
			FC_ASSERT(size == sizeof(GLfloat) * 4 * uniform->Num());
			FCglUniformMatrix2fv(uniform->Location(), uniform->Num(), GL_FALSE, (GLfloat*)pValues);
			break;			
		case GL_FLOAT_MAT3:
			FC_ASSERT(size == sizeof(GLfloat) * 9 * uniform->Num());
			FCglUniformMatrix3fv(uniform->Location(), uniform->Num(), GL_FALSE, (GLfloat*)pValues);
			break;
		case GL_FLOAT_MAT4:
			FC_ASSERT(size == sizeof(GLfloat) * 16 * uniform->Num());
			FCglUniformMatrix4fv(uniform->Location(), uniform->Num(), GL_FALSE, (GLfloat*)pValues);
			break;

		default:
			NSString* uniformType = [NSString stringWithUTF8String:FCGLStringForEnum(uniform->Type()).c_str()];
			FC_FATAL( std::string("unknown uniform type:") +  [uniformType UTF8String]);
			break;
	}
}

-(void)use
{
	FCglUseProgram(self.glHandle);
}

-(void)bindUniformsWithMesh:(FCMesh_apple*)mesh
{
	FC_HALT;
}

-(void)bindAttributes
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
			FC_FATAL( std::string("Validate fail:") + [errorString UTF8String]);
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
		
		[attribArray addObject:[NSString stringWithFormat:@"%d %s %d x %s", i, pBuffer, size, FCGLStringForEnum(type).c_str()]];
	}
	
	free( pBuffer );
	
	return [NSArray arrayWithArray:attribArray];
}

@end

#endif // defined(FC_GRAPHICS)

#endif

