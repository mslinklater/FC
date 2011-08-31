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

@interface FCMesh : NSObject 
{	
	GLuint					m_primBuffer;
	GLuint					m_indexBuffer;
	
	FC::VertexTypeDebug*	m_pPrimitiveBuffer;
	
//	FC::Vector3f*			m_pVertexBuffer;
//	FC::Vector3f*			m_pNormalBuffer;
//	FC::Vector3f*			m_pColorBuffer;
	
	FC::Vector3s*			m_pIndexBuffer;
	
	unsigned int			mNumVerts;
	unsigned int			mNumTriangles;
	BOOL					mFixedup;
}

-(id)initWithNumVertices:(int)numVerts numTriangles:(int)numTriangles;
-(void)fixup;

-(void)render;

-(FC::Vector3f*)vertexNum:(int)num;
-(FC::Color4f*)colorNum:(int)num;
-(FC::Vector3s*)indexNum:(int)num;

-(int)stride;
-(int)numVerts;
@end

#endif // TARGET_OS_IPHONE
