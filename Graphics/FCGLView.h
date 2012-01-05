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

#if TARGET_OS_IPHONE

#import <UIKit/UIKit.h>

#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

#import "Maths/FCMaths.h"
#import "Core/FCTypes.h"

@interface FCGLView : UIView
{
@private
	
	// OpenGL stuff
	
    GLint			mFramebufferWidth;
    GLint			mFramebufferHeight;
    GLint			mSupersampleBufferWidth;
    GLint			mSupersampleBufferHeight;
	
	// normal (unsupersampled) vars
    GLuint			mNormalFramebuffer;
	GLuint			mNormalColorRenderbuffer;
	GLuint			mNormalDepthRenderbuffer;
	
	// supersampled vars
	GLuint			mSuperFramebuffer;
	GLuint			mSuperColorRenderbuffer;
	GLuint			mSuperDepthRenderbuffer;
	GLuint			mSuperOffScreenTexture;		// texture
	
	// rendering control values	
	float		mAspectRatio;
	
	CADisplayLink*	mDisplayLink;
	id				mRenderTarget;
	SEL				mRenderAction;
	int				mFrameInterval;
}

@property(nonatomic, strong) EAGLContext *context;
@property(nonatomic) FC::Vector3f frustumTranslation;
@property(nonatomic) float fov;
@property(nonatomic) float nearClip;
@property(nonatomic) float farClip;
@property(nonatomic) FC::Color4f clearColor;
@property(nonatomic) BOOL depthBuffer;
@property(nonatomic) BOOL superSampling;
@property(nonatomic) float superSamplingScale;
@property(nonatomic) int interval;

- (void)setFramebuffer;
- (BOOL)presentFramebuffer;
-(FC::Vector2f)posOnPlane:(CGPoint)pointIn;

// rendering control

-(void)setProjectionMatrix;
-(void)clear;

-(void)setRenderTarget:(id)target renderAction:(SEL)action frameInterval:(int)interval;
-(void)start;
-(void)stop;
-(BOOL)animating;

@end

#endif // TARGET_OS_IPHONE
