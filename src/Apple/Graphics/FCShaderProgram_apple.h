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

#import <Foundation/Foundation.h>
#import <OpenGLES/ES2/gl.h>

#include "GLES/FCGLShaderUniform.h"
#include "GLES/FCGLShaderAttribute.h"

@class FCShader_apple;
@class FCMesh_apple;

@interface FCShaderProgram_apple : NSObject
{
	GLuint _glHandle;
	FCShader_apple* _vertexShader;
	FCShader_apple* _fragmentShader;
	FCGLShaderAttributeMapByString	_attributes;
	FCGLShaderUniformMapByString	_uniforms;
	unsigned int	_stride;
}
@property(nonatomic, readonly) GLuint glHandle;
@property(nonatomic, strong, readonly) FCShader_apple* vertexShader;
@property(nonatomic, strong, readonly) FCShader_apple* fragmentShader;
@property(nonatomic) FCGLShaderUniformMapByString uniforms;
@property(nonatomic) FCGLShaderAttributeMapByString attributes;
@property(nonatomic) unsigned int stride;

-(id)initWithVertex:(FCShader_apple*)vertexShader andFragment:(FCShader_apple*)fragmentShader;

-(FCGLShaderUniform*)getUniform:(NSString*)name;
-(void)setUniformValue:(FCGLShaderUniform*)uniform to:(void*)pValues size:(unsigned int)size;

-(GLuint)getAttribLocation:(NSString*)name;

-(void)use;
-(void)validate;
-(void)bindUniformsWithMesh:(FCMesh_apple*)mesh;
-(void)bindAttributes; // Get rid of the vertex descriptor
-(NSArray*)getActiveAttributes;	// Deprecate;

@end

#endif // defined(FC_GRAPHICS)

