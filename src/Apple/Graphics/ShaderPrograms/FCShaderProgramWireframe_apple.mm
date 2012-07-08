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

#import "FCShaderProgramWireframe_apple.h"
#import "FCCore.h"
#import "FCMesh_apple.h"

#include "GLES/FCGL.h"

class FCGLShader;

@implementation FCShaderProgramWireframe_apple

@synthesize diffuseColorUniform = _diffuseColorUniform;
@synthesize positionAttribute = _positionAttribute;

-(id)initWithVertex:(FCGLShaderPtr)vertexShader andFragment:(FCGLShaderPtr)fragmentShader
{
	self = [super initWithVertex:vertexShader andFragment:fragmentShader];
	if (self) {
		_stride = 12;
		self.diffuseColorUniform = _uniforms[ "diffuse_color" ];
		self.positionAttribute = _attributes[ "position" ];
	}
	return self;
}

-(void)bindUniformsWithMesh:(FCMesh_apple*)mesh
{
	FCColor4f diffuseColor = mesh.diffuseColor;
	FCglUniform4fv(_diffuseColorUniform->Location(), _diffuseColorUniform->Num(), (GLfloat*)&diffuseColor);
}

-(void)bindAttributes // Get rid of the vertex descriptor
{
	FCglVertexAttribPointer( _positionAttribute->Location(), 3, GL_FLOAT, GL_FALSE, 12, (void*)0);
	FCglEnableVertexAttribArray( _positionAttribute->Location() );
}

@end
