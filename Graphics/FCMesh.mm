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

#if defined (FC_GRAPHICS)

#import "FCGL.h"
#import "FCMesh.h"
#import "FCGLHelpers.h"
#import "FCShaderManager.h"
#import "FCRenderer.h"
#import "FCShaderAttribute.h"

@interface FCMesh() 
{
}
@property(nonatomic) BOOL fixedUp;
-(void)fixupVBOs;
@end

@implementation FCMesh
@synthesize parentModel = _parentModel;
@synthesize vertexBufferStride = _vertexBufferStride;
@synthesize numVertices = _numVertices;
@synthesize numTriangles = _numTriangles;
@synthesize numEdges = _numEdges;
@synthesize vertexDescriptor = _vertexDescriptor;
@synthesize pVertexBuffer = _pVertexBuffer;
@synthesize pIndexBuffer = _pIndexBuffer;
@synthesize fixedUp = _fixedUp;
@synthesize shaderProgram = _shaderProgram;
@synthesize vertexBufferHandle = _vertexBufferHandle;
@synthesize indexBufferHandle = _indexBufferHandle;
@synthesize primitiveType = _primitiveType;
@synthesize sizeIndexBuffer = _sizeIndexBuffer;
@synthesize sizeVertexBuffer = _sizeVertexBuffer;

@synthesize diffuseColor = _diffuseColor;
@synthesize specularColor = _specularColor;

#pragma mark - Object lifetime

-(id)initWithVertexDescriptor:(FCVertexDescriptor*)vertexDescriptor 
				   shaderName:(NSString*)shaderName
				primitiveType:(GLenum)primitiveType
{
	self = [super init];
	if (self) {
		_numVertices = 0;
		_numTriangles = 0;
		_fixedUp = NO;
		_vertexDescriptor = vertexDescriptor;
		_pVertexBuffer = 0;
		_pIndexBuffer = 0;
		_shaderProgram = [[FCShaderManager instance] program:shaderName];
		_primitiveType = primitiveType;
		_vertexBufferStride = _shaderProgram.stride;
	}
	return self;
}

-(void)setNumVertices:(unsigned int)numVertices
{
	FC_ASSERT(_vertexBufferStride);
	FC_ASSERT1(self.numVertices == 0, @"numVertices already set - cannot do twice");
	FC_ASSERT1(numVertices < 65535, @"Cannot cope with meshes with more than 65535 verts yet");
	_numVertices = numVertices;
	_sizeVertexBuffer = self.numVertices * _vertexBufferStride;
	_pVertexBuffer = malloc(_sizeVertexBuffer);
}

-(void)setNumTriangles:(unsigned int)numTriangles
{
	if(_primitiveType == GL_TRIANGLES)
	{
		FC_ASSERT1(self.numTriangles == 0, @"numTriangles already set - cannot do twice");
		_numTriangles = numTriangles;
		_sizeIndexBuffer = self.numTriangles * 3 * sizeof(unsigned short);
		_pIndexBuffer = (unsigned short*)malloc(_sizeIndexBuffer);		
	}
}

-(void)setNumEdges:(unsigned int)numEdges
{
	if(_primitiveType == GL_LINES)
	{
		FC_ASSERT1(self.numEdges == 0, @"numEdges already set - cannot do twice");
		_numEdges = numEdges;
		_sizeIndexBuffer = self.numEdges * 2 * sizeof(unsigned short);
		_pIndexBuffer = (unsigned short*)malloc(_sizeIndexBuffer);		
	}
}


-(void)dealloc
{
	FCglDeleteBuffers(1, &_indexBufferHandle);
	GLCHECK;
	FCglDeleteBuffers(1, &_vertexBufferHandle);
	GLCHECK;
}

-(unsigned short*)pIndexBufferAtIndex:(unsigned short)index
{
	return self.pIndexBuffer + index;
}

#pragma mark - render

-(void)render
{
	if (!self.fixedUp) {
		[self fixupVBOs];
	}

	[self.shaderProgram use];
	
	FCglBindBuffer(GL_ELEMENT_ARRAY_BUFFER, self.indexBufferHandle);
	FCglBindBuffer(GL_ARRAY_BUFFER, self.vertexBufferHandle);
	
	[_shaderProgram bindUniformsWithMesh:self vertexDescriptor:self.vertexDescriptor];
	[_shaderProgram bindAttributesWithVertexDescriptor:self.vertexDescriptor];
	
#if defined (DEBUG)
	[self.shaderProgram validate];
#endif

	switch (_primitiveType) {
		case GL_TRIANGLES:
			FCglDrawElements(GL_TRIANGLES, self.numTriangles * 3, GL_UNSIGNED_SHORT, 0);
			break;
		case GL_LINES:
			FCglDrawElements(GL_LINES, self.numEdges * 2, GL_UNSIGNED_SHORT, 0);
			break;			
		default:
			FC_HALT;
			break;
	}
}

-(void)fixupVBOs
{
	FC_ASSERT(self.fixedUp == NO);
	
	// build VBOs
	
	FCglGenBuffers(1, &_vertexBufferHandle);
	FCglBindBuffer(GL_ARRAY_BUFFER, self.vertexBufferHandle);
	FCglBufferData(GL_ARRAY_BUFFER, _sizeVertexBuffer, self.pVertexBuffer, GL_STATIC_DRAW);

	FCglGenBuffers(1, &_indexBufferHandle);
	FCglBindBuffer(GL_ELEMENT_ARRAY_BUFFER, self.indexBufferHandle);
	FCglBufferData(GL_ELEMENT_ARRAY_BUFFER, _sizeIndexBuffer, self.pIndexBuffer, GL_STATIC_DRAW);

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

#endif // defined(FC_GRAPHICS)