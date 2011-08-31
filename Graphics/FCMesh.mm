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

@implementation FCMesh

#pragma mark - Object lifetime

-(id)initWithNumVertices:(int)numVerts numTriangles:(int)numTriangles
{
	self = [super init];
	if (self) {
		NSAssert(!mNumVerts, @"FCMesh num verts already initialized");
		NSAssert(!m_pPrimitiveBuffer, @"Primitive buffer already allocated");
//		NSAssert(!m_pVertexBuffer, @"Vertex buffer already allocated");
//		NSAssert(!m_pNormalBuffer, @"Normal buffer already allocated");
//		NSAssert(!m_pColorBuffer, @"Color buffer already allocated");
		
		mNumVerts = numVerts;
		mNumTriangles = numTriangles;
		
		m_pPrimitiveBuffer = (FC::VertexTypeDebug*)malloc(mNumVerts * sizeof(FC::VertexTypeDebug));
		m_pIndexBuffer = (FC::Vector3s*)malloc(mNumTriangles * sizeof(FC::Vector3s));
		
		mFixedup = NO;
	}
	return self;
}

-(void)dealloc
{
	glDeleteBuffers(1, &m_indexBuffer);
	GLCHECK;
	glDeleteBuffers(1, &m_primBuffer);
	GLCHECK;
	
	[super dealloc];
}

#pragma mark - render

-(void)render
{
	NSAssert(mFixedup, @"Render called on unfinalised mesh");

	FCShaderProgram* program = [[FCRenderer instance].shaderManager program:@"simple_simple"];
	GLuint positionSlot = [program getAttribLocation:@"Position"];
	GLuint colorSlot = [program getAttribLocation:@"Color"];
	
	GLsizei stride = [self stride];
	const GLvoid* colorOffset = (GLvoid*)sizeof(FC::Vector3f);

	[program use];
	
	glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, m_indexBuffer);
	glBindBuffer(GL_ARRAY_BUFFER, m_primBuffer);
	glVertexAttribPointer(positionSlot, 3, GL_FLOAT, GL_FALSE, stride, 0);
	glVertexAttribPointer(colorSlot, 4, GL_FLOAT, GL_FALSE, stride, colorOffset);
	glEnableVertexAttribArray(positionSlot);
	glEnableVertexAttribArray(colorSlot);
	
#if defined (DEBUG)
	[program validate];
#endif
		
	glDrawElements(GL_TRIANGLES, mNumTriangles * 3, GL_UNSIGNED_SHORT, 0);
}

#pragma mark - Getters

-(FC::Vector3f*)vertexNum:(int)num
{
	NSAssert(num < mNumVerts, @"vertexNum outside bounds");
	return (FC::Vector3f*)&(m_pPrimitiveBuffer[num].vertex.x);
}

-(FC::Color4f*)colorNum:(int)num
{
	NSAssert(num < mNumVerts, @"vertexNum outside bounds");
	return (FC::Color4f*)&(m_pPrimitiveBuffer[num].color.r);
}

-(FC::Vector3s*)indexNum:(int)num
{
	NSAssert(num < mNumTriangles, @"indexNum outside bounds");
	return (FC::Vector3s*)&(m_pIndexBuffer[num].x);
}

-(int)numVerts
{
	return mNumVerts;
}

-(int)stride
{
	return sizeof(FC::VertexTypeDebug);
}

#pragma mark - Setters

#pragma mark - Misc

-(void)fixup
{
	// build VBOs
	
	glGenBuffers(1, &m_primBuffer);
	GLCHECK;
	glBindBuffer(GL_ARRAY_BUFFER, m_primBuffer);
	GLCHECK;
	glBufferData(GL_ARRAY_BUFFER, mNumVerts * sizeof(FC::VertexTypeDebug), m_pPrimitiveBuffer, GL_STATIC_DRAW);
	GLCHECK;
	
	glGenBuffers(1, &m_indexBuffer);
	GLCHECK;
	glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, m_indexBuffer);
	GLCHECK;
	glBufferData(GL_ELEMENT_ARRAY_BUFFER, mNumTriangles * sizeof(FC::Vector3s), m_pIndexBuffer, GL_STATIC_DRAW);
	GLCHECK;
	
	// release working memory
	
	if (m_pPrimitiveBuffer) {
		free( m_pPrimitiveBuffer );
		m_pPrimitiveBuffer = 0;
	}
	if (m_pIndexBuffer) {
		free( m_pIndexBuffer );
		m_pIndexBuffer = 0;
	}

	mFixedup = YES;
}

@end

#endif // TARGET_OS_IPHONE
