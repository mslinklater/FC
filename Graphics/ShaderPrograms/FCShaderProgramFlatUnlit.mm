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

#import "FCShaderProgramFlatUnlit.h"
#import "FCCore.h"
#import "FCMesh.h"
#import "FCShaderAttribute.h"
#import "FCShaderUniform.h"

#import "FCGL.h"

/*

 stride = 16
 
 float	x
 float	y
 float	z
 uchar	r
 uchar	g
 uchar	b
 uchar	a
 
*/

@implementation FCShaderProgramFlatUnlit

@synthesize diffuseColorAttribute = _diffuseColorAttribute;
@synthesize positionAttribute = _positionAttribute;

-(id)initWithVertex:(FCShader *)vertexShader andFragment:(FCShader *)fragmentShader
{
	self = [super initWithVertex:vertexShader andFragment:fragmentShader];
	if (self) {	
		_stride = 16;
		self.positionAttribute = [self.attributes valueForKey:@"position"];
		self.diffuseColorAttribute = [self.attributes valueForKey:@"diffuse_color"];
	}
	return self;
}

-(void)bindUniformsWithMesh:(FCMesh*)mesh vertexDescriptor:(FCVertexDescriptor*)vertexDescriptor
{
}

-(void)bindAttributesWithVertexDescriptor:(FCVertexDescriptor*)vertexDescriptor; // Get rid of the vertex descriptor
{
	FCglVertexAttribPointer( _positionAttribute.glLocation, 3, GL_FLOAT, GL_FALSE, 16, (void*)0);
	FCglEnableVertexAttribArray( _positionAttribute.glLocation );

	FCglVertexAttribPointer( _diffuseColorAttribute.glLocation, 4, GL_UNSIGNED_BYTE, GL_TRUE, 16, (void*)12);
	FCglEnableVertexAttribArray( _diffuseColorAttribute.glLocation );
}

@end
