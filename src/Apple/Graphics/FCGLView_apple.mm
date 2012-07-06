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

#import <QuartzCore/QuartzCore.h>

#import "FCCore.h"

#import "FCGLView_apple.h"
#import "FCDevice.h"
#import "FCShaderManager_apple.h"
#import "FCRenderer_apple.h"
#import "FCLua.h"

#include "GLES/FCGL.h"

FCGLViewPtr plt_FCGLView_Create( std::string name, std::string parent, const FCVector2i& size )
{
	FCGLViewProxyPtr proxy = FCGLViewProxyPtr( new FCGLViewProxy( name, parent, size ) );
	return proxy;
}

#pragma mark - Lua Functions


#pragma mark - ObjC

@interface FCGLView_apple(hidden)
- (void)createFramebuffer;
- (void)deleteFramebuffer;
@end

@implementation FCGLView_apple

@synthesize managedName = _managedName;
@synthesize currentLuaTarget = _currentLuaTarget;

@synthesize context = _context;
@synthesize frustumTranslation = _frustumTranslation;
@synthesize fov = _fov;
@synthesize nearClip = _nearClip;
@synthesize farClip = _farClip;
@synthesize clearColor = _clearColor;
@synthesize depthBuffer = _depthBuffer;
@synthesize superSampling = _superSampling;
@synthesize superSamplingScale = _superSamplingScale;
@synthesize renderTarget = _renderTarget;
@synthesize renderAction = _renderAction;

@synthesize aspectRatio = _aspectRatio;

@synthesize frameBufferWidth = _frameBufferWidth;
@synthesize frameBufferHeight = _frameBufferHeight;
@synthesize supersampleBufferWidth = _supersampleBufferWidth;
@synthesize supersampleBufferHeight = _supersampleBufferHeight;

@synthesize normalFrameBuffer = _normalFrameBuffer;
@synthesize normalDepthRenderBuffer = _normalDepthRenderBuffer;
@synthesize normalColorRenderBuffer = _normalColorRenderBuffer;

@synthesize superFrameBuffer = _superFrameBuffer;
@synthesize superColorRenderBuffer = _superColorRenderBuffer;
@synthesize superDepthRenderBuffer = _superDepthRenderBuffer;
@synthesize superOffScreenTexture = _superOffScreenTexture;

// You must implement this method

+ (Class)layerClass
{
    return [CAEAGLLayer class];
}

-(id)initWithFrame:(CGRect)aRect name:(NSString*)managedName;
{
	self = [super initWithFrame:aRect];
	if (self) {
		_managedName = managedName;
		
        CAEAGLLayer *eaglLayer = (CAEAGLLayer *)self.layer;
        
        eaglLayer.opaque = FALSE;
        eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
                                        [NSNumber numberWithBool:FALSE], kEAGLDrawablePropertyRetainedBacking,
                                        kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat,
                                        nil];

		// clear some values
	
		// deal with retina
		
		self.contentScaleFactor = [UIScreen mainScreen].scale;
		
		_context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
		
		if (!self.context)
			FC_FATAL("Failed to create ES context");
		else if (![EAGLContext setCurrentContext:self.context])
			FC_FATAL("Failed to set ES context current");

		// setup some defaults
		
		self.clearColor = FCColor4f(0.5f, 0.5f, 0.5f, 1.0f);
		
		self.depthBuffer = NO;
		self.superSampling = NO;
		self.superSamplingScale = 1.0f;
		
		FCGLLogVersions();
		FCGLLogCaps();
	}
	
	return self;
}

- (void)dealloc
{
	if ([EAGLContext currentContext] == self.context)
        [EAGLContext setCurrentContext:nil];

    [self deleteFramebuffer];    
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
    if (self.context && !_superFrameBuffer)
    {
        [EAGLContext setCurrentContext:self.context];
        
        // Create normal buffer
		FCglGenFramebuffers(1, &_normalFrameBuffer); GLCHECK;
		FCglBindFramebuffer(GL_FRAMEBUFFER, _normalFrameBuffer); GLCHECK;
        FCglGenRenderbuffers(1, &_normalColorRenderBuffer); GLCHECK;
        FCglBindRenderbuffer(GL_RENDERBUFFER, _normalColorRenderBuffer); GLCHECK;
		FCglFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _normalColorRenderBuffer); GLCHECK;
		
		FCglGenFramebuffers(1, &_superFrameBuffer); GLCHECK;
		FCglBindFramebuffer(GL_FRAMEBUFFER, _superFrameBuffer); GLCHECK;

        // Create color render buffer and allocate backing store.
		
        [self.context renderbufferStorage:GL_RENDERBUFFER fromDrawable:(CAEAGLLayer *)self.layer];
		
        FCglGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &_frameBufferWidth); GLCHECK;
        FCglGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &_frameBufferHeight); GLCHECK;
        
		// texture
		FCglGenTextures(1, &_superOffScreenTexture); GLCHECK;
		FCglBindTexture(GL_TEXTURE_2D, _superOffScreenTexture); GLCHECK;
		FCglTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR); GLCHECK;
		FCglTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR); GLCHECK;
		FCglTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE); GLCHECK;
		FCglTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE); GLCHECK;
		
		_supersampleBufferWidth = _frameBufferWidth * _superSamplingScale;
		_supersampleBufferHeight = _frameBufferHeight * _superSamplingScale;

		// try
		FCglTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, _supersampleBufferWidth, _supersampleBufferHeight, 0, GL_RGBA, GL_UNSIGNED_BYTE, 0);
		
		if (glGetError() != GL_NO_ERROR) {
			// non POT texture sizes - try to find the smallest POT texture that fits round the frame - We're in MBX land here so keep it lean 8)
			
			int maxTextureWidth = FCGLCapsMaxTextureSize();
			int maxTextureHeight = FCGLCapsMaxTextureSize();
			
			while ((maxTextureWidth/2) > _frameBufferWidth) {
				maxTextureWidth /= 2;
			}
			while ((maxTextureHeight/2) > _frameBufferHeight) {
				maxTextureHeight /= 2;
			}
			_supersampleBufferWidth = maxTextureWidth;
			_supersampleBufferHeight = maxTextureHeight;
			
			FCglTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, _supersampleBufferWidth, _supersampleBufferHeight, 0, GL_RGBA, GL_UNSIGNED_BYTE, 0);

			if (FCglGetError() != GL_NO_ERROR) {
				FC_FATAL("Can't get supersampling working");
				exit(1);
			}
		}
		
		if (self.depthBuffer)
		{
			FCglGenRenderbuffers(1, &_superDepthRenderBuffer); GLCHECK;
			FCglBindRenderbuffer(GL_RENDERBUFFER, _superDepthRenderBuffer); GLCHECK;
			FCglRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT16, _supersampleBufferWidth, _supersampleBufferHeight); GLCHECK;
			FCglFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, _superDepthRenderBuffer); GLCHECK;
		}
		
		FCglGenRenderbuffers(1, &_superColorRenderBuffer); GLCHECK;
		FCglBindRenderbuffer(GL_RENDERBUFFER, _superColorRenderBuffer); GLCHECK;
		FCglRenderbufferStorage(GL_RENDERBUFFER, GL_RGBA8_OES, _supersampleBufferWidth, _supersampleBufferHeight);	GLCHECK;
		FCglFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _superColorRenderBuffer); GLCHECK;
		
		// generate texture and associate it with the FBO
		
		FCglFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, _superOffScreenTexture, 0); GLCHECK;
        
        if (FCglCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE)
            FC_FATAL( std::string("Failed to make complete framebuffer object ") + FCGLStringForEnum( FCglCheckFramebufferStatus(GL_FRAMEBUFFER)) );
    }
}

- (void)createNormalFramebuffer
{
	NSAssert(self.superSampling == NO, @"createNormalFramebuffer when supersampling active");
		
    if(self.context && !_normalFrameBuffer)
    {
        [EAGLContext setCurrentContext:self.context];
        
        // Create default framebuffer object.
		
		FCglGenFramebuffers(1, &_normalFrameBuffer); GLCHECK;
		FCglBindFramebuffer(GL_FRAMEBUFFER, _normalFrameBuffer); GLCHECK;
        
        // Create color render buffer and allocate backing store.
        FCglGenRenderbuffers(1, &_normalColorRenderBuffer); GLCHECK;
        FCglBindRenderbuffer(GL_RENDERBUFFER, _normalColorRenderBuffer); GLCHECK;
		
        [self.context renderbufferStorage:GL_RENDERBUFFER fromDrawable:(CAEAGLLayer *)self.layer];
		
        FCglGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &_frameBufferWidth); GLCHECK;
        FCglGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &_frameBufferHeight); GLCHECK;
        
		// Create depth buffer
		
		if (self.depthBuffer) 
		{
			FCglGenRenderbuffers(1, &_normalDepthRenderBuffer); GLCHECK;
			FCglBindRenderbuffer(GL_RENDERBUFFER, _normalDepthRenderBuffer); GLCHECK;
			FCglRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT16, _frameBufferWidth, _frameBufferHeight); GLCHECK;
			FCglFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, _normalDepthRenderBuffer); GLCHECK;
		}

		FCglFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _normalColorRenderBuffer); GLCHECK;
        
        if (FCglCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE)
            FC_FATAL( std::string("Failed to make complete framebuffer object ") + FCGLStringForEnum(glCheckFramebufferStatus(GL_FRAMEBUFFER)));
    }
}

- (void)deleteFramebuffer
{
    if (self.context)
    {
        [EAGLContext setCurrentContext:self.context];
        
        if (_normalFrameBuffer)
        {
            FCglDeleteFramebuffers(1, &_normalFrameBuffer);
            _normalFrameBuffer = 0;
        }
        if (_normalColorRenderBuffer)
        {
            FCglDeleteRenderbuffers(1, &_normalColorRenderBuffer);
            _normalColorRenderBuffer = 0;
        }
		if( _normalDepthRenderBuffer )
		{
			FCglDeleteRenderbuffers(1, &_normalDepthRenderBuffer);
			_normalDepthRenderBuffer = 0;
		}

		if (_superOffScreenTexture) {
			FCglDeleteTextures(1, &_superOffScreenTexture);
			_superOffScreenTexture = 0;
		}
		if( _superFrameBuffer )
		{
			FCglDeleteRenderbuffers(1, &_superFrameBuffer);
			_superFrameBuffer = 0;
		}
		if( _superColorRenderBuffer )
		{
			FCglDeleteRenderbuffers(1, &_superColorRenderBuffer);
			_superColorRenderBuffer = 0;
		}
		if( _superDepthRenderBuffer )
		{
			FCglDeleteRenderbuffers(1, &_superDepthRenderBuffer);
			_superDepthRenderBuffer = 0;
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
			if (!_superFrameBuffer)
				[self createSupersampledFramebuffer];
			
			FCglBindFramebuffer(GL_FRAMEBUFFER, _superFrameBuffer); GLCHECK;
			FCglBindRenderbuffer(GL_RENDERBUFFER, _superColorRenderBuffer); GLCHECK;
			FCglViewport(0, 0, _supersampleBufferWidth, _supersampleBufferHeight); GLCHECK;
		}
		else
		{
			if (!_normalFrameBuffer)
				[self createNormalFramebuffer];

			FCglBindFramebuffer(GL_FRAMEBUFFER, _normalFrameBuffer); GLCHECK;
			FCglViewport(0, 0, _frameBufferWidth, _frameBufferHeight); GLCHECK;
		}
		
		if (self.depthBuffer) {
			FCglEnable(GL_DEPTH_TEST); GLCHECK;
		}

		_aspectRatio = (float)_frameBufferHeight / (float)_frameBufferWidth;
    }
}

- (BOOL)presentFramebuffer
{
    BOOL success = FALSE;
    
    if (self.context)
    {
        [EAGLContext setCurrentContext:self.context];
        
//		if (self.superSampling)
		if (0) // MSL supersampling
		{
			FCglBindFramebuffer(GL_FRAMEBUFFER, _normalFrameBuffer);
			FCglBindRenderbuffer(GL_RENDERBUFFER, _normalColorRenderBuffer);
			FCglViewport(0, 0, _frameBufferWidth, _frameBufferHeight);			

			FCglClearColor(0.5f, 0.5f, 0.5f, 1.0f);
			FCglClear(GL_COLOR_BUFFER_BIT);

			// render super buffer into normal renderbuffer
			
			FCglDisable(GL_DEPTH_TEST);
			FCglDisable(GL_TEXTURE_2D);
			FCglEnable(GL_TEXTURE_2D);
			FCglBindTexture(GL_TEXTURE_2D, _superOffScreenTexture);
			
			// draw poly
//			glMatrixMode(GL_PROJECTION);
//			glLoadIdentity();
//			glFrustumf(-0.5, 0.5, -0.5, 0.5, 1, 100);
//			glMatrixMode(GL_MODELVIEW);
//			glLoadIdentity();
//			glTranslatef(0.0f, 0.0f, -2.0f);
			
			// clear bound buffers
			FCglBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0); GLCHECK;
			FCglBindBuffer(GL_ARRAY_BUFFER, 0); GLCHECK;

//			glVertexPointer(2, GL_FLOAT, 0, squareVertices);
//			glEnableClientState(GL_VERTEX_ARRAY);
//			glColorPointer(4, GL_UNSIGNED_BYTE, 0, squareColors);
//			glEnableClientState(GL_COLOR_ARRAY);
//			glTexCoordPointer(2, GL_FLOAT, 0, squareTextures);
//			glEnableClientState(GL_TEXTURE_COORD_ARRAY);
		
			FCglDrawArrays(GL_TRIANGLE_STRIP, 0, 4);

			FCglDisable(GL_TEXTURE_2D);
		}
		else
		{
			FCglBindRenderbuffer(GL_RENDERBUFFER, _normalColorRenderBuffer);
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

-(FCVector3f)posOnPlane:(CGPoint)pointIn
{
	// needs offset
	
	int halfScreenWidth = ( (_frameBufferWidth / [UIScreen mainScreen].scale) / 2 );
	int halfScreenHeight = ( (_frameBufferHeight / [UIScreen mainScreen].scale) / 2 );
	
	pointIn.x -= halfScreenWidth;
	pointIn.y -= halfScreenHeight;
	pointIn.y *= -1.0f;

	// centered now...
	
	pointIn.x /= halfScreenWidth / (-self.frustumTranslation.z * self.fov);
	pointIn.y /= halfScreenHeight / (-self.frustumTranslation.z * (self.fov * _aspectRatio));
	
	return FCVector3f(pointIn.x, pointIn.y, 0.0f);
}

-(void)setProjectionMatrix
{
	// build matrix
	
	FCMatrix4f mat = FCMatrix4f::Frustum( -self.fov, self.fov, -self.fov * _aspectRatio, self.fov * _aspectRatio, self.nearClip, self.farClip );	
	FCMatrix4f trans = FCMatrix4f::Translate(self.frustumTranslation.x, self.frustumTranslation.y, self.frustumTranslation.z);
	
	mat = trans * mat;
	
	FCShaderManager_apple* shaderManager = [FCShaderManager_apple instance];

	FCColor4f ambientColor( 0.25f, 0.25f, 0.25f, 1.0f );

	NSArray* programs = [shaderManager allShaders];

	for( FCShaderProgram_apple* program in programs )
	{
		FCShaderUniform_apple* projectionUniform = [program getUniform:@"projection"];
		[program setUniformValue:projectionUniform to:&mat size:sizeof(FCMatrix4f)];
		
	}
}

-(void)clear
{
	FCglClearColor(_clearColor.r, _clearColor.g, _clearColor.b, _clearColor.a);
	
	if (self.depthBuffer) 
	{
		FCglClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
	}
	else
	{
		FCglClear(GL_COLOR_BUFFER_BIT);		
	}
}

-(void)update:(float)dt
{
	if (_renderTarget) {
		_renderTarget();
	}
}

-(void)setManagedViewName:(NSString *)name
{
	_managedName = name;
}

-(NSString*)managedViewName
{
	return _managedName;
}

@end

#endif // defined(FC_GRAPHICS)
