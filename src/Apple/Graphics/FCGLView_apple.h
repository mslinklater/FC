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
#import "FCViewManager_apple.h"

#include "GLES/FCGLView.h"

@interface FCGLView_apple : UIView <FCManagedView_apple>
{
@private
	NSString* _managedName;
	FCGLView_apple* __weak _currentLuaTarget;
	EAGLContext* _context;
	FCVector3f _frustumTranslation;
	float _fov;
	float _nearClip;
	float _farClip;
	FCColor4f _clearColor;
	BOOL _depthBuffer;
	BOOL _superSampling;
	float _superSamplingScale;
	
	FCVoidVoidFuncPtr _renderTarget;
	
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
@property(nonatomic, weak) FCGLView_apple* currentLuaTarget;
@property(nonatomic, strong) EAGLContext *context;
@property(nonatomic) FCVector3f frustumTranslation;
@property(nonatomic) float fov;
@property(nonatomic) float nearClip;
@property(nonatomic) float farClip;
@property(nonatomic) FCColor4f clearColor;
@property(nonatomic) BOOL depthBuffer;
@property(nonatomic) BOOL superSampling;
@property(nonatomic) float superSamplingScale;
@property(nonatomic) FCVoidVoidFuncPtr renderTarget;
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
-(FCVector3f)posOnPlane:(CGPoint)pointIn;

// rendering control

-(void)setProjectionMatrix;
-(void)clear;

-(void)update:(float)dt;
@end

class FCGLViewProxy : public FCGLView
{
public:
	FCGLViewProxy( std::string name, std::string parent, const FCVector2i size )
	: FCGLView( name, parent, size )
	{
		m_nsName = [NSString stringWithUTF8String:name.c_str()];
		
		m_appleView = [[FCGLView_apple alloc] initWithFrame:CGRectMake(0, 0, size.x, size.y) name:m_nsName];
//		[[FCViewManager_apple instance].viewDictionary setValue:m_appleView forKey:m_nsName];
		[[FCViewManager_apple instance] add:m_appleView as:m_nsName];
		[[FCViewManager_apple instance].rootView addSubview:m_appleView];
	}	
	virtual ~FCGLViewProxy()
	{
//		[[FCViewManager_apple instance].viewDictionary removeObjectForKey:m_nsName];		
		[[FCViewManager_apple instance] remove: m_nsName];
		[m_appleView removeFromSuperview];
		m_appleView = nil;
	}
	
	void Update( float dt )
	{
		FCGLView::Update( dt );
		[m_appleView update:dt];
	}
	
	void SetDepthBuffer( bool enabled )
	{
		FCGLView::SetDepthBuffer( enabled );
		m_appleView.depthBuffer = enabled;
	}
	void SetRenderTarget( FCVoidVoidFuncPtr func)
	{
		FCGLView::SetRenderTarget( func );
		m_appleView.renderTarget = func;
	}
	void SetFrameBuffer()
	{
		FCGLView::SetFrameBuffer();
		[m_appleView setFramebuffer];
	}
	void Clear()
	{
		FCGLView::Clear();
		[m_appleView clear];
	}
	void SetProjectionMatrix()
	{
		FCGLView::SetProjectionMatrix();
		[m_appleView setProjectionMatrix];
	}
	void PresentFramebuffer()
	{
		FCGLView::PresentFramebuffer();
		[m_appleView presentFramebuffer];
	}
	FCVector2f ViewSize()
	{
		FCVector2f ret;
		ret.x = m_appleView.frame.size.width;
		ret.y = m_appleView.frame.size.height;
		return ret;
	}
	FCVector3f PosOnPlane( const FCVector2f& point )
	{
		return [m_appleView posOnPlane:CGPointMake( point.x, point.y )];
	}
	void SetClearColor( const FCColor4f& color )
	{
		FCGLView::SetClearColor( color );
		m_appleView.clearColor = color;
	}
	void SetFOV( float fov )
	{
		FCGLView::SetFOV( fov );
		m_appleView.fov = fov;
	}
	void SetNearClip( float clip )
	{
		FCGLView::SetNearClip( clip );
		m_appleView.nearClip = clip;
	}
	void SetFarClip( float clip )
	{
		FCGLView::SetFarClip( clip );
		m_appleView.farClip = clip;
	}
	void SetFrustumTranslation( const FCVector3f& trans )
	{
		FCGLView::SetFrustumTranslation(trans);
		m_appleView.frustumTranslation = trans;
	}
	
	FCGLView_apple*	m_appleView;
	NSString*		m_nsName;
};

typedef std::shared_ptr<FCGLViewProxy> FCGLViewProxyPtr;

#endif // defined(FC_GRAPHICS)
