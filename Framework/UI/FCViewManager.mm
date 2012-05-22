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



#import "FCViewManager.h"
#import "FCError.h"
#import "FCDevice.h"
#import "FCApplication.h"

#pragma mark - Lua Interface

#if defined (FC_LUA)

#import "FCLua.h"
#import "FCLuaCommon.h"

static int lua_SetText( lua_State* _state )
{
	FC_LUA_ASSERT_NUMPARAMS(2);
	FC_LUA_ASSERT_TYPE(1, LUA_TSTRING);
	FC_LUA_ASSERT_TYPE(2, LUA_TSTRING);
	
	NSString* viewName = [NSString stringWithUTF8String:lua_tostring(_state, 1)];
	NSString* text = [NSString stringWithUTF8String:lua_tostring(_state, 2)];

	[[FCViewManager instance] setView:viewName text:text];
	
	return 0;
}

static int lua_SetTextColor( lua_State* _state )
{
	FC_LUA_ASSERT_NUMPARAMS(2);
	FC_LUA_ASSERT_TYPE(1, LUA_TSTRING);
	FC_LUA_ASSERT_TYPE(2, LUA_TTABLE);

	NSString* viewName = [NSString stringWithUTF8String:lua_tostring(_state, 1)];
	
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
	
	[[FCViewManager instance] setView:viewName textColor:[UIColor colorWithRed:r green:g blue:b alpha:a]];
	
	return 0;
}

static int lua_GetFrame( lua_State* _state )
{
	FC_LUA_ASSERT_NUMPARAMS(1);
	FC_LUA_ASSERT_TYPE(1, LUA_TSTRING);

	NSString* viewName = [NSString stringWithUTF8String:lua_tostring(_state, 1)];
	
	CGRect rect = [[FCViewManager instance] getViewFrame:viewName];
	
	lua_newtable(_state);
	int table = lua_gettop(_state);
	lua_pushstring(_state, "x");
	lua_pushnumber(_state, rect.origin.x);
	lua_settable(_state, table);
	lua_pushstring(_state, "y");
	lua_pushnumber(_state, rect.origin.y);
	lua_settable(_state, table);
	lua_pushstring(_state, "w");
	lua_pushnumber(_state, rect.size.width);
	lua_settable(_state, table);
	lua_pushstring(_state, "h");
	lua_pushnumber(_state, rect.size.height);
	lua_settable(_state, table);
	
	return 1;
}

static int lua_SetFrame( lua_State* _state )
{
	FC_ASSERT( lua_gettop(_state) <= 3);
	FC_LUA_ASSERT_TYPE(1, LUA_TSTRING);
	FC_LUA_ASSERT_TYPE(2, LUA_TTABLE);

	NSString* viewName = [NSString stringWithUTF8String:lua_tostring(_state, 1)];
	float seconds = 0.0f;

	if (lua_gettop(_state) > 2) {
		FC_LUA_ASSERT_TYPE(3, LUA_TNUMBER);
		seconds = lua_tonumber(_state, 3);
		lua_pop(_state, 1);
	}
	
	lua_pushnil(_state);
	
	lua_next(_state, -2);
	FC_LUA_ASSERT_TYPE(-1, LUA_TNUMBER);
	float x = lua_tonumber(_state, -1);
	lua_pop(_state, 1);

	lua_next(_state, -2);
	FC_LUA_ASSERT_TYPE(-1, LUA_TNUMBER);
	float y = lua_tonumber(_state, -1);
	lua_pop(_state, 1);

	lua_next(_state, -2);
	FC_LUA_ASSERT_TYPE(-1, LUA_TNUMBER);
	float w = lua_tonumber(_state, -1);
	lua_pop(_state, 1);

	lua_next(_state, -2);
	FC_LUA_ASSERT_TYPE(-1, LUA_TNUMBER);
	float h = lua_tonumber(_state, -1);
	
	[[FCViewManager instance] setView:viewName frame:CGRectMake(x, y, w, h) over:seconds];
	
	return 0;
}

static int lua_SetAlpha( lua_State* _state )
{
	FC_ASSERT( lua_gettop(_state) <= 3);
	FC_LUA_ASSERT_TYPE(1, LUA_TSTRING);
	FC_LUA_ASSERT_TYPE(2, LUA_TNUMBER);
	
	NSString* viewName = [NSString stringWithUTF8String:lua_tostring(_state, 1)];
	float alpha = lua_tonumber(_state, 2);

	float seconds = 0.0f;

	if (lua_gettop(_state) > 2) {
		FC_LUA_ASSERT_TYPE(3, LUA_TNUMBER);
		seconds = lua_tonumber(_state, 3);
	}

	[[FCViewManager instance] setView:viewName alpha:alpha over:seconds];
	
	return 0;
}

static int lua_SetOnSelectLuaFunction( lua_State* _state )
{
	FC_LUA_ASSERT_NUMPARAMS(2);
	FC_LUA_ASSERT_TYPE(1, LUA_TSTRING);
	FC_ASSERT( (lua_type(_state, 2) == LUA_TSTRING) || (lua_type(_state, 2) == LUA_TNIL) );
	
	NSString* viewName = [NSString stringWithUTF8String:lua_tostring(_state, 1)];
	
	NSString* funcName;
	
	if (lua_type(_state, 2) == LUA_TNIL) {
		funcName = nil;
	} else {
		funcName = [NSString stringWithUTF8String:lua_tostring(_state, 2)];		
	}
	
	[[FCViewManager instance] setView:viewName onSelectLuaFunc:funcName];
	
	return 0;
}

static int lua_SetImage( lua_State* _state )
{
	FC_LUA_ASSERT_NUMPARAMS(2);
	FC_LUA_ASSERT_TYPE(1, LUA_TSTRING);
	FC_LUA_ASSERT_TYPE(2, LUA_TSTRING);
	
	NSString* viewName = [NSString stringWithUTF8String:lua_tostring(_state, 1)];
	NSString* imageName = [NSString stringWithUTF8String:lua_tostring(_state, 2)];
	
	[[FCViewManager instance] setView:viewName image:imageName];
	
	return 0;
}

static int lua_SetURL( lua_State* _state )
{
	FC_LUA_ASSERT_NUMPARAMS(2);
	FC_LUA_ASSERT_TYPE(1, LUA_TSTRING);
	FC_LUA_ASSERT_TYPE(2, LUA_TSTRING);
	
	NSString* viewName = [NSString stringWithUTF8String:lua_tostring(_state, 1)];
	NSString* url = [NSString stringWithUTF8String:lua_tostring(_state, 2)];
	
	[[FCViewManager instance] setView:viewName url:url];
	
	return 0;
}

static int lua_CreateView( lua_State* _state )
{
	FC_ASSERT( lua_gettop(_state) > 1 );
	FC_LUA_ASSERT_TYPE(1, LUA_TSTRING);
	FC_LUA_ASSERT_TYPE(2, LUA_TSTRING);
	
	NSString* name = [NSString stringWithUTF8String:lua_tostring(_state, 1)];
	NSString* className = [NSString stringWithUTF8String:lua_tostring(_state, 2)];

	NSString* parent = nil;
	
	if (lua_gettop(_state) > 2) {
		FC_LUA_ASSERT_TYPE(3, LUA_TSTRING)
		parent = [NSString stringWithUTF8String:lua_tostring(_state, 3)];
	}

	[[FCViewManager instance] createView:name asClass:className withParent:parent];
	
	return 0;
}

static int lua_DestroyView( lua_State* _state )
{
	FC_LUA_ASSERT_NUMPARAMS(1);
	FC_LUA_ASSERT_TYPE(1, LUA_TSTRING);
	
	NSString* name = [NSString stringWithUTF8String:lua_tostring(_state, 1)];
	
	[[FCViewManager instance] destroyView:name];
	return 0;
}

static int lua_CreateGroup( lua_State* _state )
{
	FC_LUA_ASSERT_NUMPARAMS(1);
	FC_LUA_ASSERT_TYPE(1, LUA_TSTRING);
	NSString* groupName = [NSString stringWithUTF8String:lua_tostring(_state, 1)];
	[[FCViewManager instance] createGroup:groupName];
	return 0;
}

static int lua_RemoveGroup( lua_State* _state )
{
	FC_LUA_ASSERT_NUMPARAMS(1);
	FC_LUA_ASSERT_TYPE(1, LUA_TSTRING);
	NSString* groupName = [NSString stringWithUTF8String:lua_tostring(_state, 1)];
	[[FCViewManager instance] removeGroup:groupName];
	return 0;
}

static int lua_AddToGroup( lua_State* _state )
{
	FC_LUA_ASSERT_NUMPARAMS(2);
	FC_LUA_ASSERT_TYPE(1, LUA_TSTRING);
	FC_LUA_ASSERT_TYPE(2, LUA_TSTRING);
	
	NSString* viewName = [NSString stringWithUTF8String:lua_tostring(_state, 1)];
	NSString* groupName = [NSString stringWithUTF8String:lua_tostring(_state, 2)];
	[[FCViewManager instance] add:viewName toGroup:groupName];
	return 0;
}

static int lua_RemoveFromGroup( lua_State* _state )
{
	FC_LUA_ASSERT_NUMPARAMS(2);
	FC_LUA_ASSERT_TYPE(1, LUA_TSTRING);
	FC_LUA_ASSERT_TYPE(2, LUA_TSTRING);
	NSString* viewName = [NSString stringWithUTF8String:lua_tostring(_state, 1)];
	NSString* groupName = [NSString stringWithUTF8String:lua_tostring(_state, 2)];
	[[FCViewManager instance] remove:viewName fromGroup:groupName];
	return 0;
}

static int lua_SetViewPropertyInteger( lua_State* _state )
{
	FC_LUA_ASSERT_NUMPARAMS(3);
	FC_LUA_ASSERT_TYPE(1, LUA_TSTRING);
	FC_LUA_ASSERT_TYPE(2, LUA_TSTRING);
	FC_LUA_ASSERT_TYPE(3, LUA_TNUMBER);
	
	NSString* name = [NSString stringWithUTF8String:lua_tostring(_state, 1)];
	NSString* property = [NSString stringWithUTF8String:lua_tostring(_state, 2)];
	NSNumber* value = [NSNumber numberWithInt:lua_tointeger(_state, 3)];

	[[FCViewManager instance] setView:name property:property to:value];
	
	return 0;
}

static int lua_SetViewPropertyString( lua_State* _state )
{
	FC_LUA_ASSERT_NUMPARAMS(3);
	FC_LUA_ASSERT_TYPE(1, LUA_TSTRING);
	FC_LUA_ASSERT_TYPE(2, LUA_TSTRING);
	FC_LUA_ASSERT_TYPE(3, LUA_TSTRING);
	
	NSString* name = [NSString stringWithUTF8String:lua_tostring(_state, 1)];
	NSString* property = [NSString stringWithUTF8String:lua_tostring(_state, 2)];
	NSString* value = [NSString stringWithUTF8String:lua_tostring(_state, 3)];
	
	[[FCViewManager instance] setView:name property:property to:value];
	
	return 0;
}

static int lua_PrintViews( lua_State* _state )
{
	FC_LUA_ASSERT_NUMPARAMS(0);
	[[FCViewManager instance] printViews];
	return 0;
}

#endif // defined(FC_LUA)

//----------------------------------------------------------------------------------------------------------------------

@implementation FCViewManager

@synthesize rootView = _rootView;
@synthesize viewDictionary = _viewDictionary;
@synthesize groupDictionary = _groupDictionary;

#pragma mark - FCSingleton

+(id)instance
{
	static FCViewManager* pInstance;
	if (!pInstance) {
		pInstance = [[FCViewManager alloc] init];
	}
	return pInstance;
}

#if defined (FC_LUA)
+(void)registerLuaFunctions:(FCLuaVM *)lua
{
	lua->CreateGlobalTable("FCViewManager");
	lua->RegisterCFunction(lua_SetText, "FCViewManager.SetText");
	lua->RegisterCFunction(lua_SetTextColor, "FCViewManager.SetTextColor");
	lua->RegisterCFunction(lua_GetFrame, "FCViewManager.GetFrame");
	lua->RegisterCFunction(lua_SetFrame, "FCViewManager.SetFrame");
	lua->RegisterCFunction(lua_SetAlpha, "FCViewManager.SetAlpha");
	lua->RegisterCFunction(lua_SetOnSelectLuaFunction, "FCViewManager.SetOnSelectLuaFunction");
	lua->RegisterCFunction(lua_SetImage, "FCViewManager.SetImage");
	lua->RegisterCFunction(lua_SetURL, "FCViewManager.SetURL");

	lua->RegisterCFunction(lua_CreateView, "FCViewManager.CreateView");
	lua->RegisterCFunction(lua_DestroyView, "FCViewManager.DestroyView");

	lua->RegisterCFunction(lua_CreateGroup, "FCViewManager.CreateGroup");
	lua->RegisterCFunction(lua_RemoveGroup, "FCViewManager.RemoveGroup");
	lua->RegisterCFunction(lua_AddToGroup, "FCViewManager.AddToGroup");
	lua->RegisterCFunction(lua_RemoveFromGroup, "FCViewManager.RemoveFromGroup");

	lua->RegisterCFunction(lua_PrintViews, "FCViewManager.PrintViews");
	lua->RegisterCFunction(lua_SetViewPropertyInteger, "FCViewManager.SetViewPropertyInteger");
	lua->RegisterCFunction(lua_SetViewPropertyString, "FCViewManager.SetViewPropertyString");
}
#endif // defined(FC_LUA)

#pragma mark - Lifetime

-(id)init
{
	self = [super init];
	if (self) {
		_viewDictionary = [NSMutableDictionary dictionary];
		_groupDictionary = [NSMutableDictionary dictionary];
	}
	return self;
}

-(void)printViewsUnder:(UIView*)rootView withTab:(int)tab
{
	for( UIView* subView in _rootView.subviews )
	{
		CGRect frame = subView.frame;
		float alpha = subView.alpha;
		id<FCManagedView> managedView = (id<FCManagedView>)subView;
		
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

-(void)createView:(NSString *)name asClass:(NSString *)className withParent:(NSString *)parentView
{
	FC_ASSERT(NSClassFromString(className));
	
	UIView* thisView = [[NSClassFromString(className) alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
	[self add:thisView as:name];
	
	if (parentView) {
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

#if TARGET_OS_IPHONE
-(void)add:(UIView*)view as:(NSString*)name
#else
-(void)add:(NSView*)view as:(NSString*)name
#endif
{
	FC_ASSERT([_viewDictionary valueForKey:name] == nil);
	
	FC_ASSERT([view conformsToProtocol:@protocol(FCManagedView)]);
	
	[((id<FCManagedView>)view) setManagedViewName:name];

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

-(void)createGroup:(NSString*)groupName
{
	FC_ASSERT([_groupDictionary valueForKey:groupName] == nil);
	
	[_groupDictionary setValue:[NSMutableArray array] forKey:groupName];
}

-(void)removeGroup:(NSString*)groupName
{
	FC_ASSERT([_groupDictionary valueForKey:groupName]);

	[_groupDictionary removeObjectForKey:groupName];
}

-(void)add:(NSString*)name toGroup:(NSString*)groupName
{
	// check group exists
	
	FC_ASSERT([_groupDictionary valueForKey:groupName] != nil);

	// check object not already in array

	FC_ASSERT( [[_groupDictionary valueForKey:groupName] containsObject:name] == NO );

	// add view to group
	
	[[_groupDictionary valueForKey:groupName] addObject:groupName];
}

-(void)remove:(NSString*)name fromGroup:(NSString*)groupName
{
	// check group exists
	
	FC_ASSERT( [_groupDictionary valueForKey:groupName] != nil );
	
	// check object is in array

	FC_ASSERT( [[_groupDictionary valueForKey:groupName] containsObject:name] );
	
	// add view to group
	
	[[_groupDictionary valueForKey:groupName] removeObject:name];
}

-(void)addToRoot:(NSString*)name
{
	
}

-(void)removeFromRoot:(NSString*)name
{
	
}

-(void)sendViewToBack:(NSString*)name
{
#if TARGET_OS_IPHONE
	UIView* thisView = [_viewDictionary valueForKey:name];
	
	FC_ASSERT(thisView);
	
	[_rootView sendSubviewToBack:thisView];
#endif
}

-(void)sendViewToFront:(NSString*)name
{
#if TARGET_OS_IPHONE
	UIView* thisView = [_viewDictionary valueForKey:name];
	
	FC_ASSERT(thisView);
	
	[_rootView bringSubviewToFront:thisView];
#endif
}

-(void)makeView:(NSString*)name inFrontOf:(NSString*)relativeName
{
	
}

-(void)makeView:(NSString*)name behind:(NSString*)relativeName
{
	
}

#if TARGET_OS_IPHONE
-(CGRect)rectForRect:(CGRect)rect containedInView:(UIView*)view;
#else
-(CGRect)rectForRect:(CGRect)rect containedInView:(NSView*)view;
#endif
{
	CGRect scaledFrame;
	scaledFrame.origin.x = view.frame.size.width * rect.origin.x;			
	scaledFrame.origin.y = view.frame.size.height * rect.origin.y;				

	CGSize mainViewSize = [[FCApplication instance] mainViewSize];

	scaledFrame.size.width = mainViewSize.width * rect.size.width;
	scaledFrame.size.height = mainViewSize.height * rect.size.height;			
	
	return scaledFrame;
}

-(void)setView:(NSString*)viewName text:(NSString*)text
{
#if TARGET_OS_IPHONE
	UIView* thisView = [_viewDictionary valueForKey:viewName];
#else
	NSView* thisView = [_viewDictionary valueForKey:viewName];
#endif

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

#if TARGET_OS_IPHONE
-(void)setView:(NSString*)viewName textColor:(UIColor*)color
#else
-(void)setView:(NSString*)viewName textColor:(NSColor*)color
#endif
{
	NSArray* components = [viewName componentsSeparatedByString:@","];
	
	for( NSString* name in components )
	{
#if TARGET_OS_IPHONE
		UIView* thisView = [_viewDictionary valueForKey:[name stringByReplacingOccurrencesOfString:@" " withString:@""]];
#else
		NSView* thisView = [_viewDictionary valueForKey:[name stringByReplacingOccurrencesOfString:@" " withString:@""]];
#endif
		
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
#if TARGET_OS_IPHONE
	UIView* thisView = [_viewDictionary valueForKey:viewName];
#else
	NSView* thisView = [_viewDictionary valueForKey:viewName];
#endif
	
	FC_ASSERT( thisView );
	
	if ([thisView respondsToSelector:@selector(setFrame:)]) 
	{
		CGRect containerFrame = [thisView superview].frame;
		
		__block CGRect scaledFrame;
		scaledFrame.origin.x = containerFrame.size.width * frame.origin.x;			
		scaledFrame.origin.y = containerFrame.size.height * frame.origin.y;			
		
		CGSize mainViewSize = [[FCApplication instance] mainViewSize];
		
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

-(CGRect)getViewFrame:(NSString*)viewName
{
#if TARGET_OS_IPHONE
	UIView* thisView = [_viewDictionary valueForKey:viewName];
#else
	NSView* thisView = [_viewDictionary valueForKey:viewName];
#endif
	
	FC_ASSERT(thisView);
	
	return thisView.frame;
}

-(void)setView:(NSString*)viewName alpha:(float)alpha over:(float)seconds
{
	NSArray* components = [viewName componentsSeparatedByString:@","];
	
	for( NSString* name in components )
	{
		
		
#if TARGET_OS_IPHONE
		UIView* thisView = [_viewDictionary valueForKey:[name stringByReplacingOccurrencesOfString:@" " withString:@""]];
#else
		NSView* thisView = [_viewDictionary valueForKey:[name stringByReplacingOccurrencesOfString:@" " withString:@""]];
#endif
		
		FC_ASSERT( thisView );

		if ([thisView respondsToSelector:@selector(setAlpha:)]) 
		{
#if TARGET_OS_IPHONE
			[UIView animateWithDuration:seconds animations:^{		
				NSMethodSignature* sig = [[thisView class] instanceMethodSignatureForSelector:@selector(setAlpha:)];		
				NSInvocation* invocation = [NSInvocation invocationWithMethodSignature:sig];
				[invocation setSelector:@selector(setAlpha:)];
				[invocation setTarget:thisView];
				[invocation setArgument:(void*)&alpha atIndex:2];
				[invocation invoke];
			}];
#endif
		} else {
			FC_FATAL( std::string("Sending 'setAlpha' to a view which does not respond to setAlpha - ") + [[thisView description] UTF8String]);
		}			
	}
}

-(void)setView:(NSString*)viewName onSelectLuaFunc:(NSString*)funcName
{
#if TARGET_OS_IPHONE
	UIView* thisView = [_viewDictionary valueForKey:viewName];
#else
	NSView* thisView = [_viewDictionary valueForKey:viewName];
#endif
	
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
		FC_FATAL( std::string("Sending 'setAlpha' to a view which does not respond to setAlpha - ") + [[thisView description] UTF8String]);
	}	

}

-(void)setView:(NSString*)viewName image:(NSString *)imageName
{
#if TARGET_OS_IPHONE
	UIView* thisView = [_viewDictionary valueForKey:viewName];
#else
	NSView* thisView = [_viewDictionary valueForKey:viewName];
#endif
	
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
#if TARGET_OS_IPHONE
	UIView* thisView = [_viewDictionary valueForKey:viewName];
#else
	NSView* thisView = [_viewDictionary valueForKey:viewName];
#endif
	
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
#if TARGET_OS_IPHONE
	UIView* thisView = [_viewDictionary valueForKey:viewName];
#else
	NSView* thisView = [_viewDictionary valueForKey:viewName];
#endif
	
	FC_ASSERT( thisView );

	[thisView setValue:value forKey:property];
}

#pragma mark - View Management

@end



