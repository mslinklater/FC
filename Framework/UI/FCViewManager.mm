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
#import "FCLua.h"
#import "FCLuaCommon.h"
#import "FCDevice.h"
#import "FCApp.h"

#pragma mark - Lua Interface

static int lua_SetText( lua_State* _state )
{
	FC_ASSERT( lua_type(_state, 1) == LUA_TSTRING );
	FC_ASSERT( lua_type(_state, 2) == LUA_TSTRING );
	FC_ASSERT( lua_gettop(_state) == 2);
	
	NSString* viewName = [NSString stringWithUTF8String:lua_tostring(_state, 1)];
	NSString* text = [NSString stringWithUTF8String:lua_tostring(_state, 2)];

	[[FCViewManager instance] setView:viewName text:text];
	
	return 0;
}

static int lua_SetTextColor( lua_State* _state )
{
	FC_ASSERT( lua_type(_state, 1) == LUA_TSTRING );
	FC_ASSERT( lua_type(_state, 2) == LUA_TTABLE );
	FC_ASSERT( lua_gettop(_state) == 2);

	NSString* viewName = [NSString stringWithUTF8String:lua_tostring(_state, 1)];
	
	lua_pushnil(_state);
	
	lua_next(_state, -2);
	FC_ASSERT(lua_type(_state, -1) == LUA_TNUMBER);
	float r = lua_tonumber(_state, -1);
	lua_pop(_state, 1);
	
	lua_next(_state, -2);
	FC_ASSERT(lua_type(_state, -1) == LUA_TNUMBER);
	float g = lua_tonumber(_state, -1);
	lua_pop(_state, 1);
	
	lua_next(_state, -2);
	FC_ASSERT(lua_type(_state, -1) == LUA_TNUMBER);
	float b = lua_tonumber(_state, -1);
	lua_pop(_state, 1);
	
	lua_next(_state, -2);
	FC_ASSERT(lua_type(_state, -1) == LUA_TNUMBER);
	float a = lua_tonumber(_state, -1);
	
	[[FCViewManager instance] setView:viewName textColor:[UIColor colorWithRed:r green:g blue:b alpha:a]];
	
	return 0;
}

static int lua_GetFrame( lua_State* _state )
{
	FC_ASSERT(lua_gettop(_state) == 1);
	FC_ASSERT(lua_isstring(_state, 1));

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
	FC_ASSERT( lua_type(_state, 1) == LUA_TSTRING );
	FC_ASSERT( lua_type(_state, 2) == LUA_TTABLE );
	FC_ASSERT( lua_gettop(_state) <= 3);

	NSString* viewName = [NSString stringWithUTF8String:lua_tostring(_state, 1)];
	float seconds = 0.0f;

	if (lua_gettop(_state) > 2) {
		FC_ASSERT( lua_type(_state, 3) == LUA_TNUMBER );
		seconds = lua_tonumber(_state, 3);
		lua_pop(_state, 1);
	}
	
	lua_pushnil(_state);
	
	lua_next(_state, -2);
	FC_ASSERT(lua_type(_state, -1) == LUA_TNUMBER);
	float x = lua_tonumber(_state, -1);
	lua_pop(_state, 1);

	lua_next(_state, -2);
	FC_ASSERT(lua_type(_state, -1) == LUA_TNUMBER);
	float y = lua_tonumber(_state, -1);
	lua_pop(_state, 1);

	lua_next(_state, -2);
	FC_ASSERT(lua_type(_state, -1) == LUA_TNUMBER);
	float w = lua_tonumber(_state, -1);
	lua_pop(_state, 1);

	lua_next(_state, -2);
	FC_ASSERT(lua_type(_state, -1) == LUA_TNUMBER);
	float h = lua_tonumber(_state, -1);
	
	[[FCViewManager instance] setView:viewName frame:CGRectMake(x, y, w, h) over:seconds];
	
	return 0;
}

static int lua_SetAlpha( lua_State* _state )
{
	FC_ASSERT( lua_type(_state, 1) == LUA_TSTRING );
	FC_ASSERT( lua_type(_state, 2) == LUA_TNUMBER );
	FC_ASSERT( lua_gettop(_state) <= 3);
	
	NSString* viewName = [NSString stringWithUTF8String:lua_tostring(_state, 1)];
	float alpha = lua_tonumber(_state, 2);

	float seconds = 0.0f;

	if (lua_gettop(_state) > 2) {
		FC_ASSERT( lua_type(_state, 3) == LUA_TNUMBER );
		seconds = lua_tonumber(_state, 3);
	}

	[[FCViewManager instance] setView:viewName alpha:alpha over:seconds];
	
	return 0;
}

static int lua_SetOnSelectLuaFunction( lua_State* _state )
{
	FC_ASSERT( lua_type(_state, 1) == LUA_TSTRING );
	FC_ASSERT( (lua_type(_state, 2) == LUA_TSTRING) || (lua_type(_state, 2) == LUA_TNIL) );
	FC_ASSERT( lua_gettop(_state) == 2);
	
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

static int lua_CreateGroup( lua_State* _state )
{
	FC_ASSERT( lua_type(_state, 1) == LUA_TSTRING );
	FC_ASSERT( lua_gettop(_state) == 1);
	NSString* groupName = [NSString stringWithUTF8String:lua_tostring(_state, 1)];
	[[FCViewManager instance] createGroup:groupName];
	return 0;
}

static int lua_RemoveGroup( lua_State* _state )
{
	FC_ASSERT( lua_type(_state, 1) == LUA_TSTRING );
	FC_ASSERT( lua_gettop(_state) == 1);
	NSString* groupName = [NSString stringWithUTF8String:lua_tostring(_state, 1)];
	[[FCViewManager instance] removeGroup:groupName];
	return 0;
}

static int lua_AddToGroup( lua_State* _state )
{
	FC_ASSERT( lua_type(_state, 1) == LUA_TSTRING );
	FC_ASSERT( lua_type(_state, 2) == LUA_TSTRING );
	FC_ASSERT( lua_gettop(_state) == 2);
	NSString* viewName = [NSString stringWithUTF8String:lua_tostring(_state, 1)];
	NSString* groupName = [NSString stringWithUTF8String:lua_tostring(_state, 2)];
	[[FCViewManager instance] add:viewName toGroup:groupName];
	return 0;
}

static int lua_RemoveFromGroup( lua_State* _state )
{
	FC_ASSERT( lua_type(_state, 1) == LUA_TSTRING );
	FC_ASSERT( lua_type(_state, 2) == LUA_TSTRING );
	FC_ASSERT( lua_gettop(_state) == 2);
	NSString* viewName = [NSString stringWithUTF8String:lua_tostring(_state, 1)];
	NSString* groupName = [NSString stringWithUTF8String:lua_tostring(_state, 2)];
	[[FCViewManager instance] remove:viewName fromGroup:groupName];
	return 0;
}

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

+(void)registerLuaFunctions:(FCLuaVM *)lua
{
	[lua createGlobalTable:@"FCViewManager"];
	[lua registerCFunction:lua_SetText as:@"FCViewManager.SetText"];
	[lua registerCFunction:lua_SetTextColor as:@"FCViewManager.SetTextColor"];
	[lua registerCFunction:lua_GetFrame as:@"FCViewManager.GetFrame"];
	[lua registerCFunction:lua_SetFrame as:@"FCViewManager.SetFrame"];
	[lua registerCFunction:lua_SetAlpha as:@"FCViewManager.SetAlpha"];
	[lua registerCFunction:lua_SetOnSelectLuaFunction as:@"FCViewManager.SetOnSelectLuaFunction"];
	[lua registerCFunction:lua_CreateGroup as:@"FCViewManager.CreateGroup"];
	[lua registerCFunction:lua_RemoveGroup as:@"FCViewManager.RemoveGroup"];
	[lua registerCFunction:lua_AddToGroup as:@"FCViewManager.AddToGroup"];
	[lua registerCFunction:lua_RemoveFromGroup as:@"FCViewManager.RemoveFromGroup"];
}

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

-(void)add:(UIView*)view as:(NSString*)name
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
	
}

-(void)sendViewToFront:(NSString*)name
{
	
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

	CGSize mainViewSize = [FCApp mainViewSize];

	scaledFrame.size.width = mainViewSize.width * rect.size.width;
	scaledFrame.size.height = mainViewSize.height * rect.size.height;			
	
	return scaledFrame;
}

-(void)setView:(NSString*)viewName text:(NSString*)text
{
	UIView* thisView = [_viewDictionary valueForKey:viewName];

	FC_ASSERT( thisView );
	
	if ([thisView respondsToSelector:@selector(setText:)]) {
		NSMethodSignature* sig = [[thisView class] instanceMethodSignatureForSelector:@selector(setText:)];		
		NSInvocation* invocation = [NSInvocation invocationWithMethodSignature:sig];
		[invocation setSelector:@selector(setText:)];
		[invocation setTarget:thisView];
		[invocation setArgument:&text atIndex:2];
		[invocation invoke];
	} else {
		FC_FATAL1(@"Sending 'setText' to a view which does not respond to setText - %@", thisView);
	}
}

-(void)setView:(NSString*)viewName textColor:(UIColor*)color
{
	UIView* thisView = [_viewDictionary valueForKey:viewName];
	
	FC_ASSERT( thisView );
	
	if ([thisView respondsToSelector:@selector(setTextColor:)]) {
		NSMethodSignature* sig = [[thisView class] instanceMethodSignatureForSelector:@selector(setTextColor:)];		
		NSInvocation* invocation = [NSInvocation invocationWithMethodSignature:sig];
		[invocation setSelector:@selector(setTextColor:)];
		[invocation setTarget:thisView];
		[invocation setArgument:&color atIndex:2];
		[invocation invoke];
	} else {
		FC_FATAL1(@"Sending 'setTextColor' to a view which does not respond to setTextColor - %@", thisView);
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
		
		CGSize mainViewSize = [FCApp mainViewSize];
		
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
		
		[UIView animateWithDuration:seconds animations:^{		
			NSMethodSignature* sig = [[thisView class] instanceMethodSignatureForSelector:@selector(setFrame:)];		
			NSInvocation* invocation = [NSInvocation invocationWithMethodSignature:sig];
			[invocation setSelector:@selector(setFrame:)];
			[invocation setTarget:thisView];
			[invocation setArgument:(void*)&scaledFrame atIndex:2];
			[invocation invoke];
		}];
	} else {
		FC_FATAL1(@"Sending 'setFrame' to a view which does not respond to setFrame - %@", thisView);
	}
	
}

-(CGRect)getViewFrame:(NSString*)viewName
{
	UIView* thisView = [_viewDictionary valueForKey:viewName];
	
	FC_ASSERT(thisView);
	
	return thisView.frame;
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
			FC_FATAL1(@"Sending 'setAlpha' to a view which does not respond to setAlpha - %@", thisView);
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
		FC_FATAL1(@"Sending 'setAlpha' to a view which does not respond to setAlpha - %@", thisView);
	}	

}

#pragma mark - View Management

@end
