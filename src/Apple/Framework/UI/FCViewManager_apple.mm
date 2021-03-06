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
void plt_FCViewManager_SetViewText( const char* viewName, const char* text );
void plt_FCViewManager_SetViewTextColor( const char* viewName, FCColor4f color );
FCRect plt_FCViewManager_ViewFrame( const char* viewName );
FCRect plt_FCViewManager_FullFrame();
void plt_FCViewManager_SetViewFrame( const char* viewName, const FCRect& rect, float seconds );
void plt_FCViewManager_SetViewAlpha( const char* viewName, float alpha, float seconds );
void plt_FCViewManager_SetViewOnSelectLuaFunction( const char* viewName, const char* func );
void plt_FCViewManager_SetViewImage( const char* viewName, const char* image );
void plt_FCViewManager_SetViewURL( const char* viewName, const char* url );
void plt_FCViewManager_CreateView( const char* viewName, const char* className, const char* parent );
void plt_FCViewManager_DestroyView( const char* viewName );
void plt_FCViewManager_SetViewPropertyInt( const char* viewName, const char* property, int32_t value );
void plt_FCViewManager_SetViewPropertyFloat( const char* viewName, const char* property, float value );
void plt_FCViewManager_SetViewPropertyString( const char* viewName, const char* property, const char* value );
void plt_FCViewManager_MoveViewToFront( const char* viewName );
void plt_FCViewManager_MoveViewToBack( const char* viewName );
void plt_FCViewManager_ShrinkFontToFit( const char* viewName );
bool plt_FCViewManager_ViewExists( const char* viewName );
void plt_FCViewManager_SetViewBackgroundColor( const char* viewName, const FCColor4f& color );

static FCViewManager_apple* s_pInstance;

void plt_FCViewManager_SetScreenAspectRatio( float w, float h )
{
	[s_pInstance setScreenAspectRatioWidth:w height:h];
}

void plt_FCViewManager_SetViewText( const char* viewName, const char* text )
{
	[s_pInstance setView:@(viewName) text:@(text)];
}

void plt_FCViewManager_ShrinkFontToFit( const char* viewName )
{
	[s_pInstance shrinkFontToFit:@(viewName)];
}

void plt_FCViewManager_SetViewTextColor( const char* viewName, FCColor4f color )
{
	[s_pInstance setView:@(viewName) textColor:[UIColor colorWithRed:color.r green:color.g blue:color.b alpha:color.a]];
}

FCRect plt_FCViewManager_ViewFrame( const char* viewName )
{
	CGRect rect = [s_pInstance getViewFrame:@(viewName)];
	FCRect ret = FCRect( rect.origin.x, rect.origin.y, rect.size.width, rect.size.height );
	return ret;
}

FCRect plt_FCViewManager_FullFrame()
{
	CGRect frame = s_pInstance.rootView.frame;
	FCRect ret = FCRect( frame.origin.x, frame.origin.y, frame.size.width, frame.size.height);
	return ret;	
}

void plt_FCViewManager_SetViewFrame( const char* viewName, const FCRect& rect, float seconds )
{
	[s_pInstance setView:@(viewName) 
									  frame:CGRectMake(rect.x, rect.y, rect.w, rect.h) over:seconds];
}

void plt_FCViewManager_SetViewAlpha( const char* viewName, float alpha, float seconds )
{
	[s_pInstance setView:@(viewName) alpha:alpha over:seconds];
}

void plt_FCViewManager_SetViewOnSelectLuaFunction( const char* viewName, const char* func )
{
	[s_pInstance setView:@(viewName) onSelectLuaFunc:@(func)];
}

void plt_FCViewManager_SetViewImage( const char* viewName, const char* image )
{
	[s_pInstance setView:@(viewName) image:@(image)];
}

void plt_FCViewManager_SetViewURL( const char* viewName, const char* url )
{
	[s_pInstance setView:@(viewName) 
										url:@(url)];
}

void plt_FCViewManager_CreateView( const char* viewName, const char* className, const char* parent )
{
	NSString* appleClassName = [NSString stringWithFormat:@"%s_apple", className];

	if (!NSClassFromString(appleClassName)) 
	{
		FC_FATAL( std::string("FCViewManager_apple - Unknown view class: ") + [appleClassName UTF8String] );
	}
	
	if (strlen(parent)) {
		[s_pInstance createView:@(viewName) 
										   asClass:appleClassName 
										withParent:@(parent)];
	} else {
		[s_pInstance createView:@(viewName) 
										   asClass:appleClassName 
										withParent:nil];		
	}
}

void plt_FCViewManager_DestroyView( const char* viewName )
{
	[s_pInstance destroyView:@(viewName)];
}

void plt_FCViewManager_SetViewPropertyInt( const char* viewName, const char* property, int32_t value )
{
	[s_pInstance setView:@(viewName) property:@(property) to:@(value)];
}

void plt_FCViewManager_SetViewPropertyFloat( const char* viewName, const char* property, float value )
{
	[s_pInstance setView:@(viewName) property:@(property) to:@(value)];
}

void plt_FCViewManager_SetViewPropertyString( const char* viewName, const char* property, const char* value )
{
	[s_pInstance setView:@(viewName) 
								   property:@(property) to:@(value)];
}

void plt_FCViewManager_SetViewTapFunction( const char* viewName, const char* function )
{
	[s_pInstance setView:@(viewName) tapFunction:@(function)];
}

void plt_FCViewManager_MoveViewToFront( const char*viewName )
{
	[s_pInstance moveViewToFront:@(viewName)];
}

void plt_FCViewManager_MoveViewToBack( const char* viewName )
{
	[s_pInstance moveViewToBack:@(viewName)];
}

bool plt_FCViewManager_ViewExists( const char* viewName )
{
	if ([s_pInstance viewNamed:@(viewName)]) {
		return true;
	} else {
		return false;
	}
}

void plt_FCViewManager_SetViewBackgroundColor( const char* viewName, const FCColor4f& color )
{
	UIColor* uiColor = [UIColor colorWithRed:color.r green:color.g blue:color.b alpha:color.a];
	[s_pInstance setView:@(viewName) backgroundColor:uiColor];
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
	UIView<FCManagedView_apple>* thisView = [_viewDictionary valueForKey:name];
	[_viewDictionary removeObjectForKey:name];
	[thisView removeFromSuperview];
	[thisView destroy];
}

-(void)add:(UIView*)view as:(NSString*)name
{
	// Assert the view name is unique
	if ([_viewDictionary valueForKey:name]) {
		FCFatal( std::string("Trying to add non-unique view name: ") + [name UTF8String]);
	}
	
	// Assert the view conforms to the managed view protocol
	if(![view conformsToProtocol:@protocol(FCManagedView_apple)]) {
		FCFatal( std::string("View does not conform to FCManagedView_apple protocol: ") + [name UTF8String]);
	}
	
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

-(void)moveViewToBack:(NSString*)name
{
	UIView* thisView = [_viewDictionary valueForKey:name];
	
	FC_ASSERT(thisView);
	
	[thisView.superview sendSubviewToBack:thisView];
}

-(void)moveViewToFront:(NSString*)name
{
	UIView* thisView = [_viewDictionary valueForKey:name];
	
	FC_ASSERT(thisView);
	
	[thisView.superview bringSubviewToFront:thisView];
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
	
#if defined (FC_DEBUG)
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
#if defined (FC_DEBUG)
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
		scaledFrame.size.width = containerFrame.size.width * frame.size.width;
		scaledFrame.size.height = containerFrame.size.height * frame.size.height;
		
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
	
	return frame;
}

-(void)shrinkFontToFit:(NSString *)name
{
	UIView* thisView = [_viewDictionary valueForKey:name];
	
	FC_ASSERT(thisView);
	
	if ([thisView respondsToSelector:@selector(shrinkFontToFit)])
	{
			NSMethodSignature* sig = [[thisView class] instanceMethodSignatureForSelector:@selector(setAlpha:)];
			NSInvocation* invocation = [NSInvocation invocationWithMethodSignature:sig];
			[invocation setSelector:@selector(shrinkFontToFit)];
			[invocation setTarget:thisView];
			[invocation invoke];
	} else {
		FC_FATAL( std::string("Sending 'shrinkFontToFit' to a view which does not respond to shrinkFontToFit - ") + [[thisView description] UTF8String]);
	}
	
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

-(void)setView:(NSString *)viewName tapFunction:(NSString *)function
{
	UIView* thisView = [_viewDictionary valueForKey:viewName];
	
	FC_ASSERT( thisView );
	
	if ([thisView respondsToSelector:@selector(setTapFunction:)])
	{
		NSMethodSignature* sig = [[thisView class] instanceMethodSignatureForSelector:@selector(setTapFunction:)];
		NSInvocation* invocation = [NSInvocation invocationWithMethodSignature:sig];
		[invocation setSelector:@selector(setTapFunction:)];
		[invocation setTarget:thisView];
		[invocation setArgument:&function atIndex:2];
		[invocation invoke];
		
	} else {
		FC_FATAL( std::string("Sending 'setTapFunction' to a view which does not respond to setTapFunction - ") + [[thisView description] UTF8String]);
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
