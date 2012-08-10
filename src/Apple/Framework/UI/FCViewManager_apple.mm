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

#import "FCViewManager_apple.h"

#include "Shared/Core/FCCore.h"
#include "Shared/Framework/FCApplication.h"
#include "Shared/Core/Device/FCDevice.h"

void plt_FCViewManager_SetScreenAspectRatio( float w, float h );
void plt_FCViewManager_SetViewText( const std::string& viewName, std::string text );
void plt_FCViewManager_SetViewTextColor( const std::string& viewName, FCColor4f color );
FCRect plt_FCViewManager_ViewFrame( const std::string& viewName );
FCRect plt_FCViewManager_FullFrame();
void plt_FCViewManager_SetViewFrame( const std::string& viewName, const FCRect& rect, float seconds );
void plt_FCViewManager_SetViewAlpha( const std::string& viewName, float alpha, float seconds );
void plt_FCViewManager_SetViewOnSelectLuaFunction( const std::string& viewName, const std::string& func );
void plt_FCViewManager_SetViewImage( const std::string& viewName, const std::string& image );
void plt_FCViewManager_SetViewURL( const std::string& viewName, const std::string& url );
void plt_FCViewManager_CreateView( const std::string& viewName, const std::string& className, const std::string& parent );
void plt_FCViewManager_DestroyView( const std::string& viewName );
void plt_FCViewManager_SetViewPropertyInt( const std::string& viewName, const std::string& property, int32_t value );
void plt_FCViewManager_SetViewPropertyString( const std::string& viewName, const std::string& property, const std::string& value );
void plt_FCViewManager_SendViewToFront( const std::string& viewName );
void plt_FCViewManager_SendViewToBack( const std::string& viewName );
bool plt_FCViewManager_ViewExists( const std::string& viewName );
void plt_FCViewManager_SetViewBackgroundColor( const std::string& viewName, const FCColor4f& color );

static FCViewManager_apple* s_pInstance;

void plt_FCViewManager_SetScreenAspectRatio( float w, float h )
{
	[s_pInstance setScreenAspectRatioWidth:w height:h];
}

void plt_FCViewManager_SetViewText( const std::string& viewName, std::string text )
{
	[s_pInstance setView:[NSString stringWithUTF8String:viewName.c_str()] text:[NSString stringWithUTF8String:text.c_str()]];
}

void plt_FCViewManager_SetViewTextColor( const std::string& viewName, FCColor4f color )
{
	[s_pInstance setView:[NSString stringWithUTF8String:viewName.c_str()] textColor:[UIColor colorWithRed:color.r green:color.g blue:color.b alpha:color.a]];
}

FCRect plt_FCViewManager_ViewFrame( const std::string& viewName )
{
	CGRect rect = [s_pInstance getViewFrame:[NSString stringWithUTF8String:viewName.c_str()]];
	FCRect ret = FCRect( rect.origin.x, rect.origin.y, rect.size.width, rect.size.height );
	return ret;
}

FCRect plt_FCViewManager_FullFrame()
{
	CGRect frame = s_pInstance.rootView.frame;
	FCRect ret = FCRect( frame.origin.x, frame.origin.y, frame.size.width, frame.size.height);
	return ret;	
}

void plt_FCViewManager_SetViewFrame( const std::string& viewName, const FCRect& rect, float seconds )
{
	[s_pInstance setView:[NSString stringWithUTF8String:viewName.c_str()] 
									  frame:CGRectMake(rect.x, rect.y, rect.w, rect.h) over:seconds];
}

void plt_FCViewManager_SetViewAlpha( const std::string& viewName, float alpha, float seconds )
{
	[s_pInstance setView:[NSString stringWithUTF8String:viewName.c_str()] alpha:alpha over:seconds];
}

void plt_FCViewManager_SetViewOnSelectLuaFunction( const std::string& viewName, const std::string& func )
{
	[s_pInstance setView:[NSString stringWithUTF8String:viewName.c_str()] onSelectLuaFunc:[NSString stringWithUTF8String:func.c_str()]];
}

void plt_FCViewManager_SetViewImage( const std::string& viewName, const std::string& image )
{
	[s_pInstance setView:[NSString stringWithUTF8String:viewName.c_str()] image:[NSString stringWithUTF8String:image.c_str()]];
}

void plt_FCViewManager_SetViewURL( const std::string& viewName, const std::string& url )
{
	[s_pInstance setView:[NSString stringWithUTF8String:viewName.c_str()] 
										url:[NSString stringWithUTF8String:url.c_str()]];
}

void plt_FCViewManager_CreateView( const std::string& viewName, const std::string& className, const std::string& parent )
{
	NSString* appleClassName = [NSString stringWithFormat:@"%s_apple", className.c_str()];

	if (!NSClassFromString(appleClassName)) 
	{
		FC_FATAL( std::string("FCViewManager_apple - Unknown view class: ") + className );
	}
	
	if (parent.size()) {
		[s_pInstance createView:[NSString stringWithUTF8String:viewName.c_str()] 
										   asClass:appleClassName 
										withParent:[NSString stringWithUTF8String:parent.c_str()]];
	} else {
		[s_pInstance createView:[NSString stringWithUTF8String:viewName.c_str()] 
										   asClass:appleClassName 
										withParent:nil];		
	}
}

void plt_FCViewManager_DestroyView( const std::string& viewName )
{
	[s_pInstance destroyView:[NSString stringWithUTF8String:viewName.c_str()]];
}

void plt_FCViewManager_SetViewPropertyInt( const std::string& viewName, const std::string& property, int32_t value )
{
	[s_pInstance setView:[NSString stringWithUTF8String:viewName.c_str()]
								   property:[NSString stringWithUTF8String:property.c_str()] to:[NSNumber numberWithInt:value]];
}

void plt_FCViewManager_SetViewPropertyString( const std::string& viewName, const std::string& property, const std::string& value )
{
	[s_pInstance setView:[NSString stringWithUTF8String:viewName.c_str()] 
								   property:[NSString stringWithUTF8String:property.c_str()] to:[NSString stringWithUTF8String:value.c_str()]];
}

void plt_FCViewManager_SendViewToFront( const std::string& viewName )
{
	[s_pInstance sendViewToFront:[NSString stringWithUTF8String:viewName.c_str()]];
}

void plt_FCViewManager_SendViewToBack( const std::string& viewName )
{
	[s_pInstance sendViewToBack:[NSString stringWithUTF8String:viewName.c_str()]];
}

bool plt_FCViewManager_ViewExists( const std::string& viewName )
{
	if ([s_pInstance viewNamed:[NSString stringWithUTF8String:viewName.c_str()]]) {
		return true;
	} else {
		return false;
	}
}

void plt_FCViewManager_SetViewBackgroundColor( const std::string& viewName, const FCColor4f& color )
{
	UIColor* uiColor = [UIColor colorWithRed:color.r green:color.g blue:color.b alpha:color.a];
	[s_pInstance setView:[NSString stringWithUTF8String:viewName.c_str()] backgroundColor:uiColor];
}

//----------------------------------------------------------------------------------------------------------------------

@implementation FCViewManager_apple

#pragma mark - FCSingleton

+(id)instance
{
	if (!s_pInstance) {
		s_pInstance = [[FCViewManager_apple alloc] init];
	}
	return s_pInstance;
}

#pragma mark - Lifetime

-(id)init
{
	self = [super init];
	if (self) {
		_viewDictionary = [NSMutableDictionary dictionary];
	}
	return self;
}

-(void)printViewsUnder:(UIView*)rootView withTab:(int)tab
{
	for( UIView* subView in _rootView.subviews )
	{
		CGRect frame = subView.frame;
		float alpha = subView.alpha;
		id<FCManagedView_apple> managedView = (id<FCManagedView_apple>)subView;
		
		NSString* line = [NSString stringWithFormat:@"n: %@ f(%f %f %f %f) a:%f", [managedView managedViewName],
						  frame.origin.x, frame.origin.y, frame.size.width, frame.size.height, alpha];
		
		//		[self printViewsUnder:subView withTab:0];
		
		FC_LOG([line UTF8String]);
	}	
}

-(void)printViews
{
	[self printViewsUnder:_rootView withTab:0];
	
}

-(void)setScreenAspectRatioWidth:(float)w height:(float)h
{
	float displayWidth = (float)atof(FCDevice::Instance()->GetCap(kFCDeviceDisplayLogicalXRes).c_str());
	float displayHeight = (float)atof(FCDevice::Instance()->GetCap(kFCDeviceDisplayLogicalYRes).c_str());
	float displayAspect = displayWidth / displayHeight;
	
	float requestedAspect = w / h;
	
	if ( requestedAspect > displayAspect ) {
		// physical display is taller
		float actualWidth = displayWidth;
		float actualHeight = displayWidth / requestedAspect;
		
		_rootView.frame = CGRectMake( 0.0f, (displayHeight - actualHeight) * 0.5f, actualWidth, actualHeight );
		
	} else {
		// physical display is fatter
		float actualHeight = displayHeight;
		float actualWidth = displayHeight * requestedAspect;
		
		_rootView.frame = CGRectMake( (displayWidth - actualWidth) * 0.5f, 0.0f, actualWidth, actualHeight );
	}
	
	_rootView.clipsToBounds = YES;
	
	FC_ASSERT( _rootView );
}

-(void)createView:(NSString *)name asClass:(NSString *)className withParent:(NSString *)parentView
{
	FC_ASSERT(NSClassFromString(className));

	UIView* thisView = [[NSClassFromString(className) alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
	[self add:thisView as:name];
	
	if (parentView) {
		FC_ASSERT( [_viewDictionary valueForKey:parentView] );
		[[_viewDictionary valueForKey:parentView] addSubview:thisView];
	} else {
		[_rootView addSubview:thisView];
	}
}

-(void)destroyView:(NSString *)name
{
	UIView* thisView = [_viewDictionary valueForKey:name];
	[thisView removeFromSuperview];
	[_viewDictionary removeObjectForKey:name];
}

-(void)add:(UIView*)view as:(NSString*)name
{
	FC_ASSERT([_viewDictionary valueForKey:name] == nil);
	
	FC_ASSERT([view conformsToProtocol:@protocol(FCManagedView_apple)]);
	
	[((id<FCManagedView_apple>)view) setManagedViewName:name];
	
	[_viewDictionary setValue:view forKey:name];
}

-(void)remove:(NSString*)name
{
	FC_ASSERT([_viewDictionary valueForKey:name]);
	
	[_viewDictionary removeObjectForKey:name];
}

-(UIView*)viewNamed:(NSString*)name
{
	return [_viewDictionary valueForKey:name];
}

-(void)addToRoot:(NSString*)name
{
	
}

-(void)removeFromRoot:(NSString*)name
{
	
}

-(void)sendViewToBack:(NSString*)name
{
	UIView* thisView = [_viewDictionary valueForKey:name];
	
	FC_ASSERT(thisView);
	
	[_rootView sendSubviewToBack:thisView];
}

-(void)sendViewToFront:(NSString*)name
{
	UIView* thisView = [_viewDictionary valueForKey:name];
	
	FC_ASSERT(thisView);
	
	[_rootView bringSubviewToFront:thisView];
}

-(void)makeView:(NSString*)name inFrontOf:(NSString*)relativeName
{
	
}

-(void)makeView:(NSString*)name behind:(NSString*)relativeName
{
	
}

-(CGRect)rectForRect:(CGRect)rect containedInView:(UIView*)view;
{
	CGRect scaledFrame;
	scaledFrame.origin.x = view.frame.size.width * rect.origin.x;			
	scaledFrame.origin.y = view.frame.size.height * rect.origin.y;				
	
	CGSize mainViewSize;	//= [[FCApplication_old instance] mainViewSize];
	FCVector2f size = FCApplication::Instance()->MainViewSize();
	mainViewSize.width = size.x;
	mainViewSize.height = size.y;
	
	scaledFrame.size.width = mainViewSize.width * rect.size.width;
	scaledFrame.size.height = mainViewSize.height * rect.size.height;			
	
	return scaledFrame;
}

-(void)setView:(NSString*)viewName text:(NSString*)text
{
	UIView* thisView = [_viewDictionary valueForKey:viewName];
	
	FC_ASSERT( thisView );
	
#if defined (DEBUG)
	if ([thisView respondsToSelector:@selector(setText:)])
#endif
	{
		NSMethodSignature* sig = [[thisView class] instanceMethodSignatureForSelector:@selector(setText:)];		
		NSInvocation* invocation = [NSInvocation invocationWithMethodSignature:sig];
		[invocation setSelector:@selector(setText:)];
		[invocation setTarget:thisView];
		[invocation setArgument:&text atIndex:2];
		[invocation invoke];
	} 
#if defined (DEBUG)
	else 
	{
		FC_FATAL( std::string("Sending 'setText' to a view which does not respond to setText - ") + [[thisView description] UTF8String]);
	}
#endif
}

-(void)setView:(NSString*)viewName textColor:(UIColor*)color
{
	NSArray* components = [viewName componentsSeparatedByString:@","];
	
	for( NSString* name in components )
	{
		UIView* thisView = [_viewDictionary valueForKey:[name stringByReplacingOccurrencesOfString:@" " withString:@""]];
		
		FC_ASSERT( thisView );
		
		if ([thisView respondsToSelector:@selector(setTextColor:)]) {
			NSMethodSignature* sig = [[thisView class] instanceMethodSignatureForSelector:@selector(setTextColor:)];		
			NSInvocation* invocation = [NSInvocation invocationWithMethodSignature:sig];
			[invocation setSelector:@selector(setTextColor:)];
			[invocation setTarget:thisView];
			[invocation setArgument:&color atIndex:2];
			[invocation invoke];
		} else {
			FC_FATAL( std::string("Sending 'setTextColor' to a view which does not respond to setTextColor - ") + [[thisView description] UTF8String]);
		}	
	}
}

-(void)setView:(NSString*)viewName frame:(CGRect)frame over:(float)seconds
{
	UIView* thisView = [_viewDictionary valueForKey:viewName];
	
	FC_ASSERT( thisView );
	
	if ([thisView respondsToSelector:@selector(setFrame:)]) 
	{
		CGRect containerFrame = [thisView superview].frame;
		
		__block CGRect scaledFrame;
		scaledFrame.origin.x = containerFrame.size.width * frame.origin.x;			
		scaledFrame.origin.y = containerFrame.size.height * frame.origin.y;			
		
		CGSize mainViewSize;	//= [[FCApplication_old instance] mainViewSize];
		FCVector2f size = FCApplication::Instance()->MainViewSize();
		mainViewSize.width = size.x;
		mainViewSize.height = size.y;
		
		if (frame.size.width < 0) {
			scaledFrame.size.width = thisView.frame.size.width;
		} else {
			scaledFrame.size.width = mainViewSize.width * frame.size.width;
		}
		
		if (frame.size.height < 0) {
			scaledFrame.size.height = thisView.frame.size.height;
		} else {
			scaledFrame.size.height = mainViewSize.height * frame.size.height;			
		}
		
#if TARGET_OS_IPHONE
		[UIView animateWithDuration:seconds animations:^{		
			NSMethodSignature* sig = [[thisView class] instanceMethodSignatureForSelector:@selector(setFrame:)];		
			NSInvocation* invocation = [NSInvocation invocationWithMethodSignature:sig];
			[invocation setSelector:@selector(setFrame:)];
			[invocation setTarget:thisView];
			[invocation setArgument:(void*)&scaledFrame atIndex:2];
			[invocation invoke];
		}];
#endif
	} else {
		FC_FATAL( std::string("Sending 'setFrame' to a view which does not respond to setFrame - ") + [[thisView description] UTF8String]);
	}
	
}

-(void)setView:(NSString*)viewName backgroundColor:(UIColor*)color
{
	UIView* thisView = [_viewDictionary valueForKey:viewName];
	
	FC_ASSERT(thisView);

	thisView.backgroundColor = color;
}

-(CGRect)getViewFrame:(NSString*)viewName
{
	UIView* thisView = [_viewDictionary valueForKey:viewName];
	
	FC_ASSERT(thisView);
	
	CGRect frame = thisView.frame;
	
	CGRect containerFrame = [thisView superview].frame;
	
	frame.origin.x /= containerFrame.size.width;
	frame.size.width /= containerFrame.size.width;
	
	frame.origin.y /= containerFrame.size.height;
	frame.size.height /= containerFrame.size.height;
	
	NSLog(@"%f %f %f %f", frame.origin.x, frame.origin.y, frame.size.width, frame.size.height);
	
	return frame;
}

-(void)setView:(NSString*)viewName alpha:(float)alpha over:(float)seconds
{
	NSArray* components = [viewName componentsSeparatedByString:@","];
	
	for( NSString* name in components )
	{
		UIView* thisView = [_viewDictionary valueForKey:[name stringByReplacingOccurrencesOfString:@" " withString:@""]];
		
		FC_ASSERT( thisView );
		
		if ([thisView respondsToSelector:@selector(setAlpha:)]) 
		{
			[UIView animateWithDuration:seconds animations:^{		
				NSMethodSignature* sig = [[thisView class] instanceMethodSignatureForSelector:@selector(setAlpha:)];		
				NSInvocation* invocation = [NSInvocation invocationWithMethodSignature:sig];
				[invocation setSelector:@selector(setAlpha:)];
				[invocation setTarget:thisView];
				[invocation setArgument:(void*)&alpha atIndex:2];
				[invocation invoke];
			}];
		} else {
			FC_FATAL( std::string("Sending 'setAlpha' to a view which does not respond to setAlpha - ") + [[thisView description] UTF8String]);
		}			
	}
}

-(void)setView:(NSString*)viewName onSelectLuaFunc:(NSString*)funcName
{
	UIView* thisView = [_viewDictionary valueForKey:viewName];
	
	FC_ASSERT( thisView );
	
	if ([thisView respondsToSelector:@selector(setOnSelectLuaFunction:)]) 
	{
		NSMethodSignature* sig = [[thisView class] instanceMethodSignatureForSelector:@selector(setOnSelectLuaFunction:)];
		NSInvocation* invocation = [NSInvocation invocationWithMethodSignature:sig];
		[invocation setSelector:@selector(setOnSelectLuaFunction:)];
		[invocation setTarget:thisView];
		[invocation setArgument:&funcName atIndex:2];
		[invocation invoke];
		
	} else {
		FC_FATAL( std::string("Sending 'setOnSelectLuaFunction' to a view which does not respond to setOnSelectLuaFunction - ") + [[thisView description] UTF8String]);
	}	
	
}

-(void)setView:(NSString*)viewName image:(NSString *)imageName
{
	UIView* thisView = [_viewDictionary valueForKey:viewName];
	
	FC_ASSERT( thisView );
	
	if ([thisView respondsToSelector:@selector(setImage:)]) 
	{
		NSMethodSignature* sig = [[thisView class] instanceMethodSignatureForSelector:@selector(setImage:)];
		NSInvocation* invocation = [NSInvocation invocationWithMethodSignature:sig];
		[invocation setSelector:@selector(setImage:)];
		[invocation setTarget:thisView];
		[invocation setArgument:&imageName atIndex:2];
		[invocation invoke];
		
	} else {
		FC_FATAL( std::string("Sending 'setImage' to a view which does not respond to setImage - ") + [[thisView description] UTF8String]);
	}
}

-(void)setView:(NSString*)viewName url:(NSString *)url
{
	UIView* thisView = [_viewDictionary valueForKey:viewName];
	
	FC_ASSERT( thisView );
	
	if ([thisView respondsToSelector:@selector(setURL:)]) 
	{
		NSMethodSignature* sig = [[thisView class] instanceMethodSignatureForSelector:@selector(setURL:)];
		NSInvocation* invocation = [NSInvocation invocationWithMethodSignature:sig];
		[invocation setSelector:@selector(setURL:)];
		[invocation setTarget:thisView];
		[invocation setArgument:&url atIndex:2];
		[invocation invoke];
		
	} else {
		FC_FATAL( std::string("Sending 'setURL' to a view which does not respond to setURL - ") + [[thisView description] UTF8String]);
	}	
}

-(void)setView:(NSString *)viewName property:(NSString*)property to:(id)value
{
	UIView* thisView = [_viewDictionary valueForKey:viewName];
	
	FC_ASSERT( thisView );
	
	[thisView setValue:value forKey:property];
}

#pragma mark - View Management

@end
