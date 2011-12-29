/*
 Copyright (C) 2011 by Martin Linklater
 
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

#pragma mark - Lua Interface

static int lua_SetText( lua_State* _state )
{
	FC_ASSERT( lua_type(_state, 1) == LUA_TSTRING );
	FC_ASSERT( lua_type(_state, 2) == LUA_TSTRING );
	
	NSString* viewName = [NSString stringWithUTF8String:lua_tostring(_state, 1)];
	NSString* text = [NSString stringWithUTF8String:lua_tostring(_state, 2)];

	[[FCViewManager instance] setView:viewName text:text];
	
	return 0;
}

static int lua_SetTextColor( lua_State* _state )
{
	FC_ASSERT( lua_type(_state, 1) == LUA_TSTRING );
	FC_ASSERT( lua_type(_state, 2) == LUA_TTABLE );
	
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

static int lua_SetFrame( lua_State* _state )
{
	FC_ASSERT( lua_type(_state, 1) == LUA_TSTRING );
	FC_ASSERT( lua_type(_state, 2) == LUA_TTABLE );

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
	FC_ASSERT( lua_type(_state, 2) == LUA_TSTRING );
	
	NSString* viewName = [NSString stringWithUTF8String:lua_tostring(_state, 1)];
	NSString* funcName = [NSString stringWithUTF8String:lua_tostring(_state, 2)];
	
	[[FCViewManager instance] setView:viewName onSelectLuaFunc:funcName];
	
	return 0;
}

//----------------------------------------------------------------------------------------------------------------------

@implementation FCViewManager

@synthesize rootView = _rootView;
@synthesize viewDictionary = _viewDictionary;

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
	[lua registerCFunction:lua_SetFrame as:@"FCViewManager.SetFrame"];
	[lua registerCFunction:lua_SetAlpha as:@"FCViewManager.SetAlpha"];
	[lua registerCFunction:lua_SetOnSelectLuaFunction as:@"FCViewManager.SetOnSelectLuaFunction"];
}

#pragma mark - Lifetime

-(id)init
{
	self = [super init];
	if (self) {
		_viewDictionary = [[NSMutableDictionary alloc] init];
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

-(void)createGroupWith:(NSArray*)names called:(NSString*)groupName
{
	
}

-(void)remove:(NSString*)name
{
	[_viewDictionary removeObjectForKey:name];
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
		scaledFrame.size.width = [[[FCDevice instance] valueForKey:kFCDeviceDisplayLogicalXRes] floatValue] * frame.size.width;
		scaledFrame.size.height = [[[FCDevice instance] valueForKey:kFCDeviceDisplayLogicalYRes] floatValue] * frame.size.height;
		
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

-(void)setView:(NSString*)viewName alpha:(float)alpha over:(float)seconds
{
	UIView* thisView = [_viewDictionary valueForKey:viewName];
	
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
