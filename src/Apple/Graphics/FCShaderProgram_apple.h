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

#import <Foundation/Foundation.h>
#import <OpenGLES/ES2/gl.h>

#include "GLES/FCGLShaderUniform.h"
#include "GLES/FCGLShaderAttribute.h"

@class FCMesh_apple;

#include "GLES/FCGLShader.h"

@interface FCShaderProgram_apple : NSObject
{
	GLuint								_glHandle;
	FCGLShaderPtr						_vertexShader;
	FCGLShaderPtr						_fragmentShader;
	FCGLShaderAttributePtrMapByString	_attributes;
	FCGLShaderUniformPtrMapByString		_uniforms;
	unsigned int						_stride;
}
@property(nonatomic, readonly) GLuint					glHandle;
@property(nonatomic, readonly) FCGLShaderPtr			vertexShader;
@property(nonatomic, readonly) FCGLShaderPtr			fragmentShader;
@property(nonatomic) FCGLShaderUniformPtrMapByString	uniforms;
@property(nonatomic) FCGLShaderAttributePtrMapByString	attributes;
@property(nonatomic) unsigned int						stride;

-(id)initWithVertex:(FCGLShaderPtr)vertexShader andFragment:(FCGLShaderPtr)fragmentShader;

-(FCGLShaderUniformPtr)getUniform:(NSString*)name;
-(void)setUniformValue:(FCGLShaderUniformPtr)uniform to:(void*)pValues size:(unsigned int)size;

-(GLuint)getAttribLocation:(NSString*)name;

-(void)use;
-(void)validate;
-(void)bindUniformsWithMesh:(FCMesh_apple*)mesh;
-(void)bindAttributes; // Get rid of the vertex descriptor
-(NSArray*)getActiveAttributes;	// Deprecate;

@end

#endif // defined(FC_GRAPHICS)

#endif
