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

#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>
#import "FCMesh.h"
#import "FCGLHelpers.h"
#import "FCShaderManager.h"
#import "FCRenderer.h"
#import "FCVertexDescriptor.h"

@interface FCMesh() 
{
}
@property(nonatomic) BOOL fixedUp;
-(void)fixup;
@end

@implementation FCMesh
@synthesize numVertices = _numVertices;
@synthesize numTriangles = _numTriangles;
@synthesize vertexDescriptor = _vertexDescriptor;
@synthesize pVertexBuffer = _pVertexBuffer;
@synthesize pIndexBuffer = _pIndexBuffer;
@synthesize colorUniform = _colorUniform;
@synthesize fixedUp = _fixedUp;
@synthesize shaderProgram = _shaderProgram;

#pragma mark - Object lifetime

-(id)initWithVertexDescriptor:(FCVertexDescriptor*)vertexDescriptor shaderName:(NSString*)shaderName
{
	self = [super init];
	if (self) {
		_numVertices = 0;
		_numTriangles = 0;
		_fixedUp = NO;
		_vertexDescriptor = [vertexDescriptor retain];
		_pVertexBuffer = 0;
		_pIndexBuffer = 0;
		self.shaderProgram = [[FCRenderer instance].shaderManager program:shaderName];
	}
	return self;
}

+(id)fcMeshWithVertexDescriptor:(FCVertexDescriptor *)vertexDescriptor shaderName:(NSString *)shaderName
{
	return [[[FCMesh alloc] initWithVertexDescriptor:vertexDescriptor shaderName:shaderName] autorelease];
}

-(void)setNumVertices:(unsigned int)numVertices
{
	FC_ASSERT1(self.numVertices == 0, @"numVertices already set - cannot do twice");
	FC_ASSERT1(numVertices < 65535, @"Cannot cope with meshes with more than 65535 verts yet");
	_numVertices = numVertices;
	_pVertexBuffer = malloc(self.numVertices * self.vertexDescriptor.stride);
}

-(void)setNumTriangles:(unsigned int)numTriangles
{
	FC_ASSERT1(self.numTriangles == 0, @"numTriangles already set - cannot do twice");
	_numTriangles = numTriangles;
	_pIndexBuffer = (FC::Vector3us*)malloc(self.numTriangles * sizeof(FC::Vector3us));
}

-(void)dealloc
{
	glDeleteBuffers(1, &m_indexBuffer);
	GLCHECK;
	glDeleteBuffers(1, &m_primBuffer);
	GLCHECK;
	
	[_vertexDescriptor release];
	
	[super dealloc];
}

-(FC::Vector3us*)pIndexBufferAtIndex:(unsigned short)index
{
	return self.pIndexBuffer + index;
}

#pragma mark - render

-(void)render
{
	if (!self.fixedUp) {
		[self fixup];
	}

	GLuint positionSlot = [self.shaderProgram getAttribLocation:@"position"];
	
	GLsizei stride = self.vertexDescriptor.stride;

	[self.shaderProgram use];
	
	FCShaderUniform* diffuseColorUniform = [self.shaderProgram getUniform:@"diffusecolor"];
	[self.shaderProgram setUniformValue:diffuseColorUniform to:&_colorUniform size:sizeof(FC::Color4f)];
	
	glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, m_indexBuffer);
	glBindBuffer(GL_ARRAY_BUFFER, m_primBuffer);
	glVertexAttribPointer(positionSlot, 3, GL_FLOAT, GL_FALSE, stride, 0);
	glEnableVertexAttribArray(positionSlot);
	
#if defined (DEBUG)
	[self.shaderProgram validate];
#endif

	glDrawElements(GL_TRIANGLES, self.numTriangles * 3, GL_UNSIGNED_SHORT, 0);
}

-(void)fixup
{
	FC_ASSERT(self.fixedUp == NO);
	
	// build VBOs
	
	glGenBuffers(1, &m_primBuffer);
	GLCHECK;
	glBindBuffer(GL_ARRAY_BUFFER, m_primBuffer);
	GLCHECK;
	glBufferData(GL_ARRAY_BUFFER, self.numVertices * self.vertexDescriptor.stride, self.pVertexBuffer, GL_STATIC_DRAW);
	GLCHECK;

	glGenBuffers(1, &m_indexBuffer);
	GLCHECK;
	glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, m_indexBuffer);
	GLCHECK;
	glBufferData(GL_ELEMENT_ARRAY_BUFFER, self.numTriangles * sizeof(FC::Vector3s), self.pIndexBuffer, GL_STATIC_DRAW);
	GLCHECK;

	// release working memory

	if (self.pVertexBuffer) {
		free( self.pVertexBuffer );
		_pVertexBuffer = 0;
	}
	
	if (self.pIndexBuffer) {
		free( self.pIndexBuffer );
		_pIndexBuffer = 0;
	}

	self.fixedUp = YES;
}

@end

#endif // TARGET_OS_IPHONE
