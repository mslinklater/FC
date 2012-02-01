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

@class FCShader;
@class FCShaderUniform;
@class FCVertexDescriptor;

@interface FCShaderProgram : NSObject
{
	GLuint _glHandle;
	FCShader* _vertexShader;
	FCShader* _fragmentShader;
	NSDictionary* _attributes;
	NSDictionary* _uniforms;
	FCVertexDescriptor* _requiredVertexDescriptor;
}
@property(nonatomic, readonly) GLuint glHandle;
@property(nonatomic, strong, readonly) FCShader* vertexShader;
@property(nonatomic, strong, readonly) FCShader* fragmentShader;
@property(nonatomic, strong, readonly) NSDictionary* uniforms;
@property(nonatomic, strong, readonly) NSDictionary* attributes;
@property(nonatomic, strong) FCVertexDescriptor* requiredVertexDescriptor;

-(id)initWithVertex:(FCShader*)vertexShader andFragment:(FCShader*)fragmentShader;
-(FCShaderUniform*)getUniform:(NSString*)name;
-(void)setUniformValue:(FCShaderUniform*)uniform to:(void*)pValues size:(unsigned int)size;
-(GLuint)getAttribLocation:(NSString*)name;
-(void)use;
-(void)validate;
-(NSArray*)getActiveAttributes;	// Deprecate;

@end

#endif // defined(FC_GRAPHICS)

