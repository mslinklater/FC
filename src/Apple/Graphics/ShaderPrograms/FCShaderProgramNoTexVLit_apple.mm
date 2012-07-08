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

#import "FCShaderProgramNoTexVLit_apple.h"
#import "FCCore.h"
#import "FCMesh_apple.h"

#include "GLES/FCGL.h"

class FCGLShader;

/*
 
 stride = 16
 
 float	x
 float	y
 float	z
 short	nx
 short	ny
 short	nz
 short	unused
 uchar	r
 uchar	g
 uchar	b
 uchar	a
 
 */

@implementation FCShaderProgramNoTexVLit_apple

@synthesize ambientUniform = _ambientUniform;
@synthesize lightColorUniform = _lightColorUniform;

@synthesize positionAttribute = _positionAttribute;
@synthesize normalAttribute = _normalAttribute;
@synthesize diffuseColorAttribute = _diffuseColorAttribute;
@synthesize specularColorAttribute = _specularColorAttribute;

-(id)initWithVertex:(FCGLShaderPtr)vertexShader andFragment:(FCGLShaderPtr)fragmentShader
{
	self = [super initWithVertex:vertexShader andFragment:fragmentShader];
	if (self) {		
		_stride = 28;
		self.ambientUniform = _uniforms[ "ambient_color" ];
		self.lightColorUniform = _uniforms[ "light_color" ];
		
		self.positionAttribute = _attributes[ "position" ];
		self.normalAttribute = _attributes[ "normal" ];
		self.diffuseColorAttribute = _attributes[ "diffuse_color" ];
		self.specularColorAttribute = _attributes[ "specular_color" ];
	}
	return self;
}

-(void)bindUniformsWithMesh:(FCMesh_apple*)mesh
{
	FCColor4f ambientColor( 0.25f, 0.25f, 0.25f, 1.0f );
	FCColor4f lightColor( 1.0f, 1.0f, 1.0f, 1.0f );

	FCglUniform4fv( _ambientUniform->Location(), 1, (GLfloat*)&ambientColor );
	FCglUniform4fv( _lightColorUniform->Location(), 1, (GLfloat*)&lightColor );
}

-(void)bindAttributes // Get rid of the vertex descriptor
{
	FCglVertexAttribPointer( _positionAttribute->Location(), 3, GL_FLOAT, GL_FALSE, _stride, (void*)0);
	FCglEnableVertexAttribArray( _positionAttribute->Location() );
	
	FCglVertexAttribPointer( _normalAttribute->Location(), 3, GL_SHORT, GL_TRUE, _stride, (void*)12);
	FCglEnableVertexAttribArray( _normalAttribute->Location() );
	
	FCglVertexAttribPointer( _diffuseColorAttribute->Location(), 4, GL_UNSIGNED_BYTE, GL_TRUE, _stride, (void*)20);
	FCglEnableVertexAttribArray( _diffuseColorAttribute->Location() );
	
	FCglVertexAttribPointer( _specularColorAttribute->Location(), 4, GL_UNSIGNED_BYTE, GL_TRUE, _stride, (void*)24);
	FCglEnableVertexAttribArray( _specularColorAttribute->Location() );
}

@end
