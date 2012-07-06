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

#import "FCShaderProgram1TexVLit_apple.h"
#import "FCCore.h"
#import "FCMesh_apple.h"
#import "FCShaderAttribute_apple.h"
#import "FCTextureManager_apple.h"

#include "GLES/FCGL.h"

@implementation FCShaderProgram1TexVLit_apple

@synthesize ambientUniform = _ambientUniform;
@synthesize lightColorUniform = _lightColorUniform;
@synthesize textureUniform = _textureUniform;

@synthesize positionAttribute = _positionAttribute;
@synthesize normalAttribute = _normalAttribute;
@synthesize diffuseColorAttribute = _diffuseColorAttribute;
@synthesize specularColorAttribute = _specularColorAttribute;
@synthesize uv1Attribute = _uv1Attribute;

-(id)initWithVertex:(FCShader_apple *)vertexShader andFragment:(FCShader_apple *)fragmentShader
{
	self = [super initWithVertex:vertexShader andFragment:fragmentShader];
	if (self) {		
		_stride = 36;
		self.ambientUniform = &(_uniforms[ "ambient_color" ]);
		self.lightColorUniform = &(_uniforms[ "light_color" ]);
		self.textureUniform = &(_uniforms[ "texture" ]);
		
		self.positionAttribute = [self.attributes valueForKey:@"position"];
		self.normalAttribute = [self.attributes valueForKey:@"normal"];
		self.diffuseColorAttribute = [self.attributes valueForKey:@"diffuse_color"];
		self.specularColorAttribute = [self.attributes valueForKey:@"specular_color"];
		self.uv1Attribute = [self.attributes valueForKey:@"uv1"];
	}
	return self;
}

-(void)bindUniformsWithMesh:(FCMesh_apple*)mesh
{
	FCColor4f ambientColor( 0.25f, 0.25f, 0.25f, 1.0f );
	FCColor4f lightColor( 1.0f, 1.0f, 1.0f, 1.0f );
	
	FCglUniform4fv(_ambientUniform->Location(), 1, (GLfloat*)&ambientColor);
	FCglUniform4fv(_lightColorUniform->Location(), 1, (GLfloat*)&lightColor);

	[[FCTextureManager_apple instance] bindDebugTextureTo:_textureUniform->Location()];
	
//	FCglUniform1i(_textureUniform.glLocation, 0);
}

-(void)bindAttributes // Get rid of the vertex descriptor
{
	FCglVertexAttribPointer( _positionAttribute.glLocation, 3, GL_FLOAT, GL_FALSE, _stride, (void*)0);
	FCglEnableVertexAttribArray( _positionAttribute.glLocation );
	
	FCglVertexAttribPointer( _normalAttribute.glLocation, 3, GL_SHORT, GL_TRUE, _stride, (void*)12);
	FCglEnableVertexAttribArray( _normalAttribute.glLocation );
	
	FCglVertexAttribPointer( _diffuseColorAttribute.glLocation, 4, GL_UNSIGNED_BYTE, GL_TRUE, _stride, (void*)20);
	FCglEnableVertexAttribArray( _diffuseColorAttribute.glLocation );
	
	FCglVertexAttribPointer( _specularColorAttribute.glLocation, 4, GL_UNSIGNED_BYTE, GL_TRUE, _stride, (void*)24);
	FCglEnableVertexAttribArray( _specularColorAttribute.glLocation );

	FCglVertexAttribPointer( _uv1Attribute.glLocation, 2, GL_FLOAT, GL_FALSE, _stride, (void*)28);
	FCglEnableVertexAttribArray( _uv1Attribute.glLocation );
	
//	if (_uv1Attribute) {
//		[[FCTextureManager instance] bindDebugTextureTo:_uv1Attribute.glLocation];
//	}
}

@end
