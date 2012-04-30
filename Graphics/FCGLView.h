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

#import <UIKit/UIKit.h>

#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

#import "Shared/Core/Maths/FCMaths.h"
#import "Shared/Core/FCTypes.h"

@interface FCGLView : UIView
{
@private
	NSString* _managedName;
	FCGLView* __weak _currentLuaTarget;
	EAGLContext* _context;
	FC::Vector3f _frustumTranslation;
	float _fov;
	float _nearClip;
	float _farClip;
	FC::Color4f _clearColor;
	BOOL _depthBuffer;
	BOOL _superSampling;
	float _superSamplingScale;
	
	id	_renderTarget;
	SEL	_renderAction;

	float _aspectRatio;
	
	// OpenGL stuff
	
    GLint			_frameBufferWidth;
    GLint			_frameBufferHeight;
    GLint			_supersampleBufferWidth;
    GLint			_supersampleBufferHeight;
	
	// normal (unsupersampled) vars
    GLuint			_normalFrameBuffer;
	GLuint			_normalColorRenderBuffer;
	GLuint			_normalDepthRenderBuffer;
	
	// supersampled vars
	GLuint			_superFrameBuffer;
	GLuint			_superColorRenderBuffer;
	GLuint			_superDepthRenderBuffer;
	GLuint			_superOffScreenTexture;		// texture
}

@property(nonatomic, strong, readonly) NSString* managedName;
@property(nonatomic, weak) FCGLView* currentLuaTarget;
@property(nonatomic, strong) EAGLContext *context;
@property(nonatomic) FC::Vector3f frustumTranslation;
@property(nonatomic) float fov;
@property(nonatomic) float nearClip;
@property(nonatomic) float farClip;
@property(nonatomic) FC::Color4f clearColor;
@property(nonatomic) BOOL depthBuffer;
@property(nonatomic) BOOL superSampling;
@property(nonatomic) float superSamplingScale;
@property(nonatomic, strong) id renderTarget;
@property(nonatomic) SEL renderAction;
@property(nonatomic) float aspectRatio;

@property(nonatomic, readonly) GLint frameBufferWidth;
@property(nonatomic, readonly) GLint frameBufferHeight;
@property(nonatomic, readonly) GLint supersampleBufferWidth;
@property(nonatomic, readonly) GLint supersampleBufferHeight;

@property(nonatomic, readonly) GLuint normalFrameBuffer;
@property(nonatomic, readonly) GLuint normalColorRenderBuffer;
@property(nonatomic, readonly) GLuint normalDepthRenderBuffer;

@property(nonatomic, readonly) GLuint superFrameBuffer;
@property(nonatomic, readonly) GLuint superColorRenderBuffer;
@property(nonatomic, readonly) GLuint superDepthRenderBuffer;
@property(nonatomic, readonly) GLuint superOffScreenTexture;

-(id)initWithFrame:(CGRect)aRect name:(NSString*)managedName;

- (void)setFramebuffer;
- (BOOL)presentFramebuffer;
-(FC::Vector3f)posOnPlane:(CGPoint)pointIn;

// rendering control

-(void)setProjectionMatrix;
-(void)clear;

-(void)update:(float)dt;
@end

#endif // defined(FC_GRAPHICS)
