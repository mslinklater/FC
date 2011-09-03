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

#import <Foundation/Foundation.h>
#import "FCVertexTypes.h"

@class FCVertexDescriptor;
@class FCShaderProgram;

@interface FCMesh : NSObject 
{	
	unsigned int		_numVertices;
	unsigned int		_numTriangles;
	FCVertexDescriptor* _vertexDescriptor;
	FCShaderProgram*	_shaderProgram;
	void*				_pVertexBuffer;	
	FC::Vector3us*		_pIndexBuffer;
	FC::Color4f		_colorUniform;
	GLuint	m_primBuffer;
	GLuint	m_indexBuffer;	
	BOOL	_fixedUp;
}
@property(nonatomic) unsigned int numVertices;
@property(nonatomic) unsigned int numTriangles;
@property(nonatomic, retain, readonly) FCVertexDescriptor* vertexDescriptor;
@property(nonatomic, readonly) void* pVertexBuffer;
@property(nonatomic, readonly) FC::Vector3us* pIndexBuffer;
@property(nonatomic) FC::Color4f colorUniform;
@property(nonatomic, retain) FCShaderProgram* shaderProgram;

-(id)initWithVertexDescriptor:(FCVertexDescriptor*)vertexDescriptor shaderName:(NSString*)shaderName;
+(id)fcMeshWithVertexDescriptor:(FCVertexDescriptor*)vertexDescriptor shaderName:(NSString*)shaderName;

-(void)render;
-(FC::Vector3us*)pIndexBufferAtIndex:(unsigned short)index;
@end

#endif // TARGET_OS_IPHONE
