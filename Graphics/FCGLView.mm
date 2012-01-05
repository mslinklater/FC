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

#import <QuartzCore/QuartzCore.h>

#import "FCCore.h"

#import "FCGLView.h"
#import "FCDevice.h"
#import "FCGLHelpers.h"
#import "FCShaderManager.h"
#import "FCRenderer.h"

@interface FCGLView(hidden)
- (void)createFramebuffer;
- (void)deleteFramebuffer;
@end

@implementation FCGLView

@synthesize context = _context;
@synthesize frustumTranslation = _frustumTranslation;
@synthesize fov = _fov;
@synthesize nearClip = _nearClip;
@synthesize farClip = _farClip;
@synthesize clearColor = _clearColor;
@synthesize depthBuffer = _depthBuffer;
@synthesize superSampling = _superSampling;
@synthesize superSamplingScale = _superSamplingScale;
@synthesize interval = _interval;

// You must implement this method

+ (Class)layerClass
{
    return [CAEAGLLayer class];
}

-(id)initWithFrame:(CGRect)aRect
{
	self = [super initWithFrame:aRect];
	if (self) {
        CAEAGLLayer *eaglLayer = (CAEAGLLayer *)self.layer;
        
        eaglLayer.opaque = TRUE;
        eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
                                        [NSNumber numberWithBool:FALSE], kEAGLDrawablePropertyRetainedBacking,
                                        kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat,
                                        nil];

		// clear some values
	
		// deal with retina
		
		self.contentScaleFactor = [UIScreen mainScreen].scale;
		
		_context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
		
		if (!self.context)
			FC_FATAL(@"Failed to create ES context");
		else if (![EAGLContext setCurrentContext:self.context])
			FC_FATAL(@"Failed to set ES context current");

		// setup some defaults
		
		self.clearColor = FC::Color4f(0.0f, 0.0f, 0.0f, 1.0f);
		
		self.depthBuffer = NO;
		self.superSampling = NO;
		self.superSamplingScale = 1.0f;
		
		FCGLLogVersions();
		FCGLLogCaps();
		
		[[FCRenderer instance] prebuildShaders];
	}
	
	return self;
}

- (void)dealloc
{
	if ([EAGLContext currentContext] == self.context)
        [EAGLContext setCurrentContext:nil];

//    [context release];

    [self deleteFramebuffer];    
	self.context = nil;
    
}

- (EAGLContext *)context
{
    return _context;
}

- (void)setContext:(EAGLContext *)newContext
{
    if (_context != newContext)
    {
        [self deleteFramebuffer];
        
        _context = newContext;
        
        [EAGLContext setCurrentContext:nil];
    }
}

- (void)createSupersampledFramebuffer
{
    if (self.context && !mSuperFramebuffer)
    {
        [EAGLContext setCurrentContext:self.context];
        
        // Create normal buffer
		glGenFramebuffers(1, &mNormalFramebuffer); GLCHECK;
		glBindFramebuffer(GL_FRAMEBUFFER, mNormalFramebuffer); GLCHECK;
        glGenRenderbuffers(1, &mNormalColorRenderbuffer); GLCHECK;
        glBindRenderbuffer(GL_RENDERBUFFER, mNormalColorRenderbuffer); GLCHECK;
		glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, mNormalColorRenderbuffer); GLCHECK;
		
		glGenFramebuffers(1, &mSuperFramebuffer); GLCHECK;
		glBindFramebuffer(GL_FRAMEBUFFER, mSuperFramebuffer); GLCHECK;

        // Create color render buffer and allocate backing store.
		
        [self.context renderbufferStorage:GL_RENDERBUFFER fromDrawable:(CAEAGLLayer *)self.layer];
		
        glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &mFramebufferWidth); GLCHECK;
        glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &mFramebufferHeight); GLCHECK;
        
		// texture
		glGenTextures(1, &mSuperOffScreenTexture); GLCHECK;
		glBindTexture(GL_TEXTURE_2D, mSuperOffScreenTexture); GLCHECK;
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR); GLCHECK;
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR); GLCHECK;
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE); GLCHECK;
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE); GLCHECK;
		
		mSupersampleBufferWidth = mFramebufferWidth * self.superSamplingScale;
		mSupersampleBufferHeight = mFramebufferHeight * self.superSamplingScale;

		// try
		glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, mSupersampleBufferWidth, mSupersampleBufferHeight, 0, GL_RGBA, GL_UNSIGNED_BYTE, 0);
		
		if (glGetError() != GL_NO_ERROR) {
			// non POT texture sizes - try to find the smallest POT texture that fits round the frame - We're in MBX land here so keep it lean 8)
			
			int maxTextureWidth = FCGLCapsMaxTextureSize();
			int maxTextureHeight = FCGLCapsMaxTextureSize();
			
			while ((maxTextureWidth/2) > mFramebufferWidth) {
				maxTextureWidth /= 2;
			}
			while ((maxTextureHeight/2) > mFramebufferHeight) {
				maxTextureHeight /= 2;
			}
			mSupersampleBufferWidth = maxTextureWidth;
			mSupersampleBufferHeight = maxTextureHeight;
			
			glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, mSupersampleBufferWidth, mSupersampleBufferHeight, 0, GL_RGBA, GL_UNSIGNED_BYTE, 0);

			if (glGetError() != GL_NO_ERROR) {
				FC_FATAL(@"can't get supersampling working");
				exit(1);
			}
		}
		
		if (self.depthBuffer)
		{
			glGenRenderbuffers(1, &mSuperDepthRenderbuffer); GLCHECK;
			glBindRenderbuffer(GL_RENDERBUFFER, mSuperDepthRenderbuffer); GLCHECK;
			glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT16, mSupersampleBufferWidth, mSupersampleBufferHeight); GLCHECK;
			glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, mSuperDepthRenderbuffer); GLCHECK;
		}
		
		glGenRenderbuffers(1, &mSuperColorRenderbuffer); GLCHECK;
		glBindRenderbuffer(GL_RENDERBUFFER, mSuperColorRenderbuffer); GLCHECK;
		glRenderbufferStorage(GL_RENDERBUFFER, GL_RGBA8_OES, mSupersampleBufferWidth, mSupersampleBufferHeight);	GLCHECK;
		glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, mSuperColorRenderbuffer); GLCHECK;
		
		// generate texture and associate it with the FBO
		
		glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, mSuperOffScreenTexture, 0); GLCHECK;
        
        if (glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE)
            FC_FATAL1(@"Failed to make complete framebuffer object '%@'", FCGLStringForEnum( glCheckFramebufferStatus(GL_FRAMEBUFFER)));
    }
}

- (void)createNormalFramebuffer
{
	NSAssert(self.superSampling == NO, @"createNormalFramebuffer when supersampling active");
		
    if(self.context && !mNormalFramebuffer)
    {
        [EAGLContext setCurrentContext:self.context];
        
        // Create default framebuffer object.
		
		glGenFramebuffers(1, &mNormalFramebuffer); GLCHECK;
		glBindFramebuffer(GL_FRAMEBUFFER, mNormalFramebuffer); GLCHECK;
        
        // Create color render buffer and allocate backing store.
        glGenRenderbuffers(1, &mNormalColorRenderbuffer); GLCHECK;
        glBindRenderbuffer(GL_RENDERBUFFER, mNormalColorRenderbuffer); GLCHECK;
		
        [self.context renderbufferStorage:GL_RENDERBUFFER fromDrawable:(CAEAGLLayer *)self.layer];
		
        glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &mFramebufferWidth); GLCHECK;
        glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &mFramebufferHeight); GLCHECK;
        
		// Create depth buffer
		
		if (self.depthBuffer) 
		{
			glGenRenderbuffers(1, &mNormalDepthRenderbuffer); GLCHECK;
			glBindRenderbuffer(GL_RENDERBUFFER, mNormalDepthRenderbuffer); GLCHECK;
			glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT16, mFramebufferWidth, mFramebufferHeight); GLCHECK;
			glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, mNormalDepthRenderbuffer); GLCHECK;
		}

		glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, mNormalColorRenderbuffer); GLCHECK;
        
        if (glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE)
            FC_FATAL1(@"Failed to make complete framebuffer object %@", FCGLStringForEnum(glCheckFramebufferStatus(GL_FRAMEBUFFER)) );
    }
}

- (void)deleteFramebuffer
{
    if (self.context)
    {
        [EAGLContext setCurrentContext:self.context];
        
        if (mNormalFramebuffer)
        {
            glDeleteFramebuffers(1, &mNormalFramebuffer);
            mNormalFramebuffer = 0;
        }
        if (mNormalColorRenderbuffer)
        {
            glDeleteRenderbuffers(1, &mNormalColorRenderbuffer);
            mNormalColorRenderbuffer = 0;
        }
		if( mNormalDepthRenderbuffer )
		{
			glDeleteRenderbuffers(1, &mNormalDepthRenderbuffer);
			mNormalDepthRenderbuffer = 0;
		}

		if (mSuperOffScreenTexture) {
			glDeleteTextures(1, &mSuperOffScreenTexture);
			mSuperOffScreenTexture = 0;
		}
		if( mSuperFramebuffer )
		{
			glDeleteRenderbuffers(1, &mSuperFramebuffer);
			mSuperFramebuffer = 0;
		}
		if( mSuperColorRenderbuffer )
		{
			glDeleteRenderbuffers(1, &mSuperColorRenderbuffer);
			mSuperColorRenderbuffer = 0;
		}
		if( mSuperDepthRenderbuffer )
		{
			glDeleteRenderbuffers(1, &mSuperDepthRenderbuffer);
			mSuperDepthRenderbuffer = 0;
		}
	}
}

- (void)setFramebuffer
{
    if (self.context)
    {
        [EAGLContext setCurrentContext:self.context];
        
		if (self.superSampling) 
		{
			if (!mSuperFramebuffer)
				[self createSupersampledFramebuffer];
			
			glBindFramebuffer(GL_FRAMEBUFFER, mSuperFramebuffer); GLCHECK;
			glBindRenderbuffer(GL_RENDERBUFFER, mSuperColorRenderbuffer); GLCHECK;
			glViewport(0, 0, mSupersampleBufferWidth, mSupersampleBufferHeight); GLCHECK;
		}
		else
		{
			if (!mNormalFramebuffer)
				[self createNormalFramebuffer];

			glBindFramebuffer(GL_FRAMEBUFFER, mNormalFramebuffer); GLCHECK;
			glViewport(0, 0, mFramebufferWidth, mFramebufferHeight); GLCHECK;
		}
		
		if (self.depthBuffer) {
			glEnable(GL_DEPTH_TEST); GLCHECK;
		}

		mAspectRatio = (float)mFramebufferHeight / (float)mFramebufferWidth;
    }
}

- (BOOL)presentFramebuffer
{
//	const GLfloat squareVertices[] = {
//        -1.0f, -1.0f,
//        1.0f, -1.0f,
//        -1.0f,  1.0f,
//        1.0f,  1.0f,
//    };

//	const GLfloat squareTextures[] = {
//        0.0f, 0.0f,
//        1.0f, 0.0f,
//        0.0f, 1.0f,
//        1.0f, 1.0f,
//    };

//    const GLubyte squareColors[] = {
//        255, 255,   255, 255,
//        255,   255, 255, 255,
//        255,     255,   255,   255,
//        255,   255, 255, 255,
//    };

    BOOL success = FALSE;
    
    if (self.context)
    {
        [EAGLContext setCurrentContext:self.context];
        
//		if (self.superSampling)
		if (0) // MSL supersampling
		{
			glBindFramebuffer(GL_FRAMEBUFFER, mNormalFramebuffer);
			glBindRenderbuffer(GL_RENDERBUFFER, mNormalColorRenderbuffer);
			glViewport(0, 0, mFramebufferWidth, mFramebufferHeight);			

			glClearColor(0.5f, 0.5f, 0.5f, 1.0f);
			glClear(GL_COLOR_BUFFER_BIT);

			// render super buffer into normal renderbuffer
			
			glDisable(GL_DEPTH_TEST);
			glDisable(GL_TEXTURE_2D);
			glEnable(GL_TEXTURE_2D);
			glBindTexture(GL_TEXTURE_2D, mSuperOffScreenTexture);
			
			// draw poly
//			glMatrixMode(GL_PROJECTION);
//			glLoadIdentity();
//			glFrustumf(-0.5, 0.5, -0.5, 0.5, 1, 100);
//			glMatrixMode(GL_MODELVIEW);
//			glLoadIdentity();
//			glTranslatef(0.0f, 0.0f, -2.0f);
			
			// clear bound buffers
			glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0); GLCHECK;
			glBindBuffer(GL_ARRAY_BUFFER, 0); GLCHECK;

//			glVertexPointer(2, GL_FLOAT, 0, squareVertices);
//			glEnableClientState(GL_VERTEX_ARRAY);
//			glColorPointer(4, GL_UNSIGNED_BYTE, 0, squareColors);
//			glEnableClientState(GL_COLOR_ARRAY);
//			glTexCoordPointer(2, GL_FLOAT, 0, squareTextures);
//			glEnableClientState(GL_TEXTURE_COORD_ARRAY);
		
			glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);

			glDisable(GL_TEXTURE_2D);
		}
		else
		{
			glBindRenderbuffer(GL_RENDERBUFFER, mNormalColorRenderbuffer);
		}
        
        success = [self.context presentRenderbuffer:GL_RENDERBUFFER];
    }
    
    return success;
}

- (void)layoutSubviews
{
    // The framebuffer will be re-created at the beginning of the next setFramebuffer method call.
    [self deleteFramebuffer];
}

-(FC::Vector2f)posOnPlane:(CGPoint)pointIn
{
	// needs offset
	
	int halfScreenWidth = ( (mFramebufferWidth / [UIScreen mainScreen].scale) / 2 );
	int halfScreenHeight = ( (mFramebufferHeight / [UIScreen mainScreen].scale) / 2 );
	
	pointIn.x -= halfScreenWidth;
	pointIn.y -= halfScreenHeight;
	pointIn.y *= -1.0f;

	// centered now...
	
	pointIn.x /= halfScreenWidth / (-self.frustumTranslation.z * self.fov);
	pointIn.y /= halfScreenHeight / (-self.frustumTranslation.z * (self.fov * mAspectRatio));
	
	return FC::Vector2f(pointIn.x, pointIn.y);
}

-(void)setProjectionMatrix
{
	FCShaderManager* shaderManager = [FCRenderer instance].shaderManager;
	FCShaderProgram* program = [shaderManager program:@"debug_debug"];
	FCShaderUniform* projectionUniform = [program getUniform:@"projection"];
	
	// build matrix
	
	FC::Matrix4f mat = FC::Matrix4f::Frustum( -self.fov, self.fov, -self.fov * mAspectRatio, self.fov * mAspectRatio, self.nearClip, self.farClip );	
	FC::Matrix4f trans = FC::Matrix4f::Translate(self.frustumTranslation.x, self.frustumTranslation.y, self.frustumTranslation.z);

	mat = trans * mat;
	
	[program setUniformValue:projectionUniform to:&mat size:sizeof(FC::Matrix4f)];
}

-(void)clear
{
	glClearColor(self.clearColor.r, self.clearColor.g, self.clearColor.b, self.clearColor.a);
	
	if (self.depthBuffer) 
	{
		glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
	}
	else
	{
		glClear(GL_COLOR_BUFFER_BIT);		
	}
}

-(void)setRenderTarget:(id)target renderAction:(SEL)action frameInterval:(int)interval
{
	mRenderTarget = target;
	mRenderAction = action;
	mFrameInterval = interval;
}

-(void)start
{
	FC_ASSERT(mRenderAction);
	FC_ASSERT(mRenderTarget);
	FC_ASSERT(!mDisplayLink);

	mDisplayLink = [CADisplayLink displayLinkWithTarget:mRenderTarget selector:mRenderAction];
	[mDisplayLink setFrameInterval:mFrameInterval];
	[mDisplayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
}

-(void)stop
{
	[mDisplayLink invalidate];
	mDisplayLink = nil;
}

-(BOOL)animating
{
	if (mDisplayLink)
		return YES;
	else
		return NO;
}

@end

#endif // TARGET_OS_IPHONE
