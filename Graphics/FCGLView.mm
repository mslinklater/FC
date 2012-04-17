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

#import "FCGLView.h"
#import "FCDevice.h"
#import "FCGLHelpers.h"
#import "FCShaderManager.h"
#import "FCRenderer.h"
#import "FCLua.h"

static NSMutableDictionary* s_glViews;
static FCGLView* s_currentLuaTarget;

#pragma mark - Lua Functions

static int lua_SetCurrentView( lua_State* _state )
{
	FC_LUA_ASSERT_NUMPARAMS(1);
	FC_LUA_ASSERT_TYPE(1, LUA_TSTRING);
	
	NSString* viewName = [NSString stringWithUTF8String:lua_tostring(_state, 1)];
	
	FC_ASSERT([s_glViews valueForKey:viewName]);
	
	s_currentLuaTarget = [s_glViews valueForKey:viewName];

	return 0;
}

static int lua_SetClearColor( lua_State* _state )
{
	FC_LUA_ASSERT_NUMPARAMS(1);
	FC_LUA_ASSERT_TYPE(1, LUA_TTABLE);
	
	lua_pushnil(_state);
	
	lua_next(_state, -2);
	FC_LUA_ASSERT_TYPE(-1, LUA_TNUMBER);
	float r = lua_tonumber(_state, -1);
	lua_pop(_state, 1);
	
	lua_next(_state, -2);
	FC_LUA_ASSERT_TYPE(-1, LUA_TNUMBER);
	float g = lua_tonumber(_state, -1);
	lua_pop(_state, 1);
	
	lua_next(_state, -2);
	FC_LUA_ASSERT_TYPE(-1, LUA_TNUMBER);
	float b = lua_tonumber(_state, -1);
	lua_pop(_state, 1);
	
	lua_next(_state, -2);
	FC_LUA_ASSERT_TYPE(-1, LUA_TNUMBER);
	float a = lua_tonumber(_state, -1);
	lua_pop(_state, 1);
	
	s_currentLuaTarget.clearColor = FC::Color4f( r, g, b, a );
	
	return 0;
}

static int lua_SetFOV( lua_State* _state )
{
	FC_LUA_ASSERT_NUMPARAMS(1);
	FC_LUA_ASSERT_TYPE(1, LUA_TNUMBER);
	
	s_currentLuaTarget.fov = lua_tonumber(_state, 1);
	
	return 0;
}

static int lua_SetNearFarClip( lua_State* _state )
{
	FC_LUA_ASSERT_NUMPARAMS(2);
	FC_LUA_ASSERT_TYPE(1, LUA_TNUMBER);
	FC_LUA_ASSERT_TYPE(2, LUA_TNUMBER);
	
	s_currentLuaTarget.nearClip = lua_tonumber(_state, 1);
	s_currentLuaTarget.farClip = lua_tonumber(_state, 2);
	
	return 0;
}

static int lua_SetFrustumTranslation( lua_State* _state )
{
	FC_LUA_ASSERT_NUMPARAMS(3);
	FC_LUA_ASSERT_TYPE(1, LUA_TNUMBER);
	FC_LUA_ASSERT_TYPE(2, LUA_TNUMBER);
	FC_LUA_ASSERT_TYPE(3, LUA_TNUMBER);

	s_currentLuaTarget.frustumTranslation = FC::Vector3f(
														 lua_tonumber(_state, 1),
														 lua_tonumber(_state, 2),
														 lua_tonumber(_state, 3) );
	
	return 0;
}

#pragma mark - ObjC

@interface FCGLView(hidden)
- (void)createFramebuffer;
- (void)deleteFramebuffer;
@end

@implementation FCGLView

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
		
		if (!s_glViews) 
		{
			s_glViews = [NSMutableDictionary dictionary];
			
			// register C Functions
			
			[[FCLua instance].coreVM createGlobalTable:@"GLView"];
			[[FCLua instance].coreVM registerCFunction:lua_SetCurrentView as:@"GLView.SetCurrent"];
			[[FCLua instance].coreVM registerCFunction:lua_SetClearColor as:@"GLView.SetClearColor"];
			[[FCLua instance].coreVM registerCFunction:lua_SetFOV as:@"GLView.SetFOV"];
			[[FCLua instance].coreVM registerCFunction:lua_SetNearFarClip as:@"GLView.SetNearFarClip"];
			[[FCLua instance].coreVM registerCFunction:lua_SetFrustumTranslation as:@"GLView.SetFrustumTranslation"];
		}

		FC_ASSERT([s_glViews valueForKey:managedName] == nil);
		
		[s_glViews setValue:self forKey:managedName];

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
			FC_FATAL(@"Failed to create ES context");
		else if (![EAGLContext setCurrentContext:self.context])
			FC_FATAL(@"Failed to set ES context current");

		// setup some defaults
		
		self.clearColor = FC::Color4f(0.5f, 0.5f, 0.5f, 1.0f);
		
		self.depthBuffer = NO;
		self.superSampling = NO;
		self.superSamplingScale = 1.0f;
		
		FCGLLogVersions();
		FCGLLogCaps();
		
//		[[FCRenderer instance] prebuildShaders];
	}
	
	return self;
}

- (void)dealloc
{
	if ([EAGLContext currentContext] == self.context)
        [EAGLContext setCurrentContext:nil];

//    [context release];

    [self deleteFramebuffer];    
//	self.context = nil;   
	
	[s_glViews removeObjectForKey:_managedName];
}

-(void)setCurrentLuaTarget:(FCGLView *)currentLuaTarget
{
	s_currentLuaTarget = currentLuaTarget;
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
		glGenFramebuffers(1, &_normalFrameBuffer); GLCHECK;
		glBindFramebuffer(GL_FRAMEBUFFER, _normalFrameBuffer); GLCHECK;
        glGenRenderbuffers(1, &_normalColorRenderBuffer); GLCHECK;
        glBindRenderbuffer(GL_RENDERBUFFER, _normalColorRenderBuffer); GLCHECK;
		glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _normalColorRenderBuffer); GLCHECK;
		
		glGenFramebuffers(1, &_superFrameBuffer); GLCHECK;
		glBindFramebuffer(GL_FRAMEBUFFER, _superFrameBuffer); GLCHECK;

        // Create color render buffer and allocate backing store.
		
        [self.context renderbufferStorage:GL_RENDERBUFFER fromDrawable:(CAEAGLLayer *)self.layer];
		
        glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &_frameBufferWidth); GLCHECK;
        glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &_frameBufferHeight); GLCHECK;
        
		// texture
		glGenTextures(1, &_superOffScreenTexture); GLCHECK;
		glBindTexture(GL_TEXTURE_2D, _superOffScreenTexture); GLCHECK;
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR); GLCHECK;
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR); GLCHECK;
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE); GLCHECK;
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE); GLCHECK;
		
		_supersampleBufferWidth = _frameBufferWidth * _superSamplingScale;
		_supersampleBufferHeight = _frameBufferHeight * _superSamplingScale;

		// try
		glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, _supersampleBufferWidth, _supersampleBufferHeight, 0, GL_RGBA, GL_UNSIGNED_BYTE, 0);
		
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
			
			glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, _supersampleBufferWidth, _supersampleBufferHeight, 0, GL_RGBA, GL_UNSIGNED_BYTE, 0);

			if (glGetError() != GL_NO_ERROR) {
				FC_FATAL(@"can't get supersampling working");
				exit(1);
			}
		}
		
		if (self.depthBuffer)
		{
			glGenRenderbuffers(1, &_superDepthRenderBuffer); GLCHECK;
			glBindRenderbuffer(GL_RENDERBUFFER, _superDepthRenderBuffer); GLCHECK;
			glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT16, _supersampleBufferWidth, _supersampleBufferHeight); GLCHECK;
			glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, _superDepthRenderBuffer); GLCHECK;
		}
		
		glGenRenderbuffers(1, &_superColorRenderBuffer); GLCHECK;
		glBindRenderbuffer(GL_RENDERBUFFER, _superColorRenderBuffer); GLCHECK;
		glRenderbufferStorage(GL_RENDERBUFFER, GL_RGBA8_OES, _supersampleBufferWidth, _supersampleBufferHeight);	GLCHECK;
		glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _superColorRenderBuffer); GLCHECK;
		
		// generate texture and associate it with the FBO
		
		glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, _superOffScreenTexture, 0); GLCHECK;
        
        if (glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE)
            FC_FATAL1(@"Failed to make complete framebuffer object '%@'", FCGLStringForEnum( glCheckFramebufferStatus(GL_FRAMEBUFFER)));
    }
}

- (void)createNormalFramebuffer
{
	NSAssert(self.superSampling == NO, @"createNormalFramebuffer when supersampling active");
		
    if(self.context && !_normalFrameBuffer)
    {
        [EAGLContext setCurrentContext:self.context];
        
        // Create default framebuffer object.
		
		glGenFramebuffers(1, &_normalFrameBuffer); GLCHECK;
		glBindFramebuffer(GL_FRAMEBUFFER, _normalFrameBuffer); GLCHECK;
        
        // Create color render buffer and allocate backing store.
        glGenRenderbuffers(1, &_normalColorRenderBuffer); GLCHECK;
        glBindRenderbuffer(GL_RENDERBUFFER, _normalColorRenderBuffer); GLCHECK;
		
        [self.context renderbufferStorage:GL_RENDERBUFFER fromDrawable:(CAEAGLLayer *)self.layer];
		
        glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &_frameBufferWidth); GLCHECK;
        glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &_frameBufferHeight); GLCHECK;
        
		// Create depth buffer
		
		if (self.depthBuffer) 
		{
			glGenRenderbuffers(1, &_normalDepthRenderBuffer); GLCHECK;
			glBindRenderbuffer(GL_RENDERBUFFER, _normalDepthRenderBuffer); GLCHECK;
			glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT16, _frameBufferWidth, _frameBufferHeight); GLCHECK;
			glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, _normalDepthRenderBuffer); GLCHECK;
		}

		glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _normalColorRenderBuffer); GLCHECK;
        
        if (glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE)
            FC_FATAL1(@"Failed to make complete framebuffer object %@", FCGLStringForEnum(glCheckFramebufferStatus(GL_FRAMEBUFFER)) );
    }
}

- (void)deleteFramebuffer
{
    if (self.context)
    {
        [EAGLContext setCurrentContext:self.context];
        
        if (_normalFrameBuffer)
        {
            glDeleteFramebuffers(1, &_normalFrameBuffer);
            _normalFrameBuffer = 0;
        }
        if (_normalColorRenderBuffer)
        {
            glDeleteRenderbuffers(1, &_normalColorRenderBuffer);
            _normalColorRenderBuffer = 0;
        }
		if( _normalDepthRenderBuffer )
		{
			glDeleteRenderbuffers(1, &_normalDepthRenderBuffer);
			_normalDepthRenderBuffer = 0;
		}

		if (_superOffScreenTexture) {
			glDeleteTextures(1, &_superOffScreenTexture);
			_superOffScreenTexture = 0;
		}
		if( _superFrameBuffer )
		{
			glDeleteRenderbuffers(1, &_superFrameBuffer);
			_superFrameBuffer = 0;
		}
		if( _superColorRenderBuffer )
		{
			glDeleteRenderbuffers(1, &_superColorRenderBuffer);
			_superColorRenderBuffer = 0;
		}
		if( _superDepthRenderBuffer )
		{
			glDeleteRenderbuffers(1, &_superDepthRenderBuffer);
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
			
			glBindFramebuffer(GL_FRAMEBUFFER, _superFrameBuffer); GLCHECK;
			glBindRenderbuffer(GL_RENDERBUFFER, _superColorRenderBuffer); GLCHECK;
			glViewport(0, 0, _supersampleBufferWidth, _supersampleBufferHeight); GLCHECK;
		}
		else
		{
			if (!_normalFrameBuffer)
				[self createNormalFramebuffer];

			glBindFramebuffer(GL_FRAMEBUFFER, _normalFrameBuffer); GLCHECK;
			glViewport(0, 0, _frameBufferWidth, _frameBufferHeight); GLCHECK;
		}
		
		if (self.depthBuffer) {
			glEnable(GL_DEPTH_TEST); GLCHECK;
		}

		_aspectRatio = (float)_frameBufferHeight / (float)_frameBufferWidth;
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
			glBindFramebuffer(GL_FRAMEBUFFER, _normalFrameBuffer);
			glBindRenderbuffer(GL_RENDERBUFFER, _normalColorRenderBuffer);
			glViewport(0, 0, _frameBufferWidth, _frameBufferHeight);			

			glClearColor(0.5f, 0.5f, 0.5f, 1.0f);
			glClear(GL_COLOR_BUFFER_BIT);

			// render super buffer into normal renderbuffer
			
			glDisable(GL_DEPTH_TEST);
			glDisable(GL_TEXTURE_2D);
			glEnable(GL_TEXTURE_2D);
			glBindTexture(GL_TEXTURE_2D, _superOffScreenTexture);
			
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
			glBindRenderbuffer(GL_RENDERBUFFER, _normalColorRenderBuffer);
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

-(FC::Vector3f)posOnPlane:(CGPoint)pointIn
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
	
	return FC::Vector3f(pointIn.x, pointIn.y, 0.0f);
}

-(void)setProjectionMatrix
{
	// build matrix
	
	FC::Matrix4f mat = FC::Matrix4f::Frustum( -self.fov, self.fov, -self.fov * _aspectRatio, self.fov * _aspectRatio, self.nearClip, self.farClip );	
	FC::Matrix4f trans = FC::Matrix4f::Translate(self.frustumTranslation.x, self.frustumTranslation.y, self.frustumTranslation.z);
	
	mat = trans * mat;
	
	FCShaderManager* shaderManager = [FCShaderManager instance];

	FC::Color4f ambientColor( 0.25f, 0.25f, 0.25f, 1.0f );

	NSArray* programs = [shaderManager allShaders];

	for( FCShaderProgram* program in programs )
	{
		FCShaderUniform* projectionUniform = [program getUniform:@"projection"];
		[program setUniformValue:projectionUniform to:&mat size:sizeof(FC::Matrix4f)];
		
	}
	
//	FCShaderProgram* program = [shaderManager program:kFCKeyShaderDebug];	// needs to be current shader or all active shaders
}

-(void)clear
{
	glClearColor(_clearColor.r, _clearColor.g, _clearColor.b, _clearColor.a);
	
	if (self.depthBuffer) 
	{
		glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
	}
	else
	{
		glClear(GL_COLOR_BUFFER_BIT);		
	}
}

-(void)update:(float)dt
{
	if (_renderAction && _renderTarget) 
	{
		[_renderTarget performSelector:_renderAction];
	}
}

@end

#endif // defined(FC_GRAPHICS)
