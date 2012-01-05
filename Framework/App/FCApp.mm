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
#import "FCApp.h"
#import "FCPersistentData.h"
#import "FCAnalytics.h"
#import "FCDevice.h"
#import "FCError.h"
#import "FCConnect.h"
#import "FCPhaseManager.h"
#import "FCPerformanceCounter.h"
#import "FCAnalytics.h"
#import "FCViewManager.h"
#import "FCBuild.h"

static FCLuaVM*				s_lua;
static UIViewController*	s_viewController;
static id<FCAppDelegate>	s_delegate;
static FCPerformanceCounter*	s_perfCounter;
static CADisplayLink*			s_displayLink;

static int lua_ShowStatusBar( lua_State* _state )
{
	FC_ASSERT( lua_type(_state, -1) == LUA_TBOOLEAN );
	
	int visible = lua_toboolean( _state, -1);

	if (visible) {
		[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
	} else {
		[[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
		s_viewController.view.frame = [[UIScreen mainScreen] bounds];
	}
	return 0;
}

static int lua_SetBackgroundColor( lua_State* _state )
{
	FC_ASSERT(lua_type(_state, 1) == LUA_TTABLE);
	
	double r, g, b, a;

	lua_pushnil(_state);
	
	lua_next(_state, -2);
	FC_ASSERT(lua_type(_state, -1) == LUA_TNUMBER);
	r = lua_tonumber(_state, -1);
	lua_pop(_state, 1);

	lua_next(_state, -2);
	FC_ASSERT(lua_type(_state, -1) == LUA_TNUMBER);
	g = lua_tonumber(_state, -1);
	lua_pop(_state, 1);

	lua_next(_state, -2);
	FC_ASSERT(lua_type(_state, -1) == LUA_TNUMBER);
	b = lua_tonumber(_state, -1);
	lua_pop(_state, 1);

	lua_next(_state, -2);
	FC_ASSERT(lua_type(_state, -1) == LUA_TNUMBER);
	a = lua_tonumber(_state, -1);
	
	s_viewController.view.backgroundColor = [UIColor colorWithRed:r green:g blue:b alpha:a];

	return 0;
}

static int lua_ShowGameCenterLeaderboards( lua_State* _state )
{
	[FCApp showGameCenterLeaderboard];
	return 0;
}

static int lua_LaunchExternalURL( lua_State* _state )
{
	FC_ASSERT(lua_type(_state, 1) == LUA_TSTRING);
	
	NSString* urlString = [NSString stringWithUTF8String:lua_tostring(_state, 1)];
	
	[FCApp launchExternalURL:urlString];
	return 0;
}

@implementation FCApp

+(void)coldBootWithViewController:(UIViewController *)vc delegate:(id<FCAppDelegate>)delegate
{
	s_viewController = vc;
	s_delegate = delegate;
	s_perfCounter = [[FCPerformanceCounter alloc] init];
	s_displayLink = [CADisplayLink displayLinkWithTarget:[FCApp class] selector:@selector(update)];
	[s_displayLink setFrameInterval:1];
	[s_displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];

	vc.view.backgroundColor = [UIColor blackColor];
	
	// register system lua hooks

	s_lua = [[FCLua instance] coreVM];
	
	[FCPersistentData registerLuaFunctions:s_lua];
	[FCPhaseManager registerLuaFunctions:s_lua];

	[FCViewManager instance].rootView = vc.view;
	[FCViewManager registerLuaFunctions:s_lua];
	[FCBuild registerLuaFunctions:s_lua];

#if TARGET_OS_IPHONE
	[FCAnalytics registerLuaFunctions:s_lua];
	[FCDevice registerLuaFunctions:s_lua];
#endif // TARGET_OS_IPHONE

	[FCError registerLuaFunctions:s_lua];
	[s_lua createGlobalTable:@"FCApp"];
	[s_lua registerCFunction:lua_ShowStatusBar as:@"FCApp.ShowStatusBar"];
	[s_lua registerCFunction:lua_SetBackgroundColor as:@"FCApp.SetBackgroundColor"];
	[s_lua registerCFunction:lua_ShowGameCenterLeaderboards as:@"FCApp.ShowGameCenterLeaderboards"];
	[s_lua registerCFunction:lua_LaunchExternalURL as:@"FCApp.LaunchExternalURL"];

//	[s_lua call:@"PrintTable" withSig:@"tb>", "FCCaps", true];
//	[s_lua call:@"PrintTable" withSig:@"tb>", "FCPersistentData", true];
//	[s_lua call:@"PrintTable" withSig:@"tb>", "FCAnalytics", true];

	[[FCConnect instance] start:nil];
	[[FCConnect instance] enableBonjourWithName:@"FCConnect"];
	[[FCDevice instance] probe];
	[[FCDevice instance] warmProbe];
	
	[[FCPersistentData instance] loadData];
	
	[s_lua loadScript:@"main"];
	[s_lua call:@"FCApp.ColdBoot" required:YES withSig:@""];
	[self warmBoot];
}

+(void)warmBoot
{
	[s_delegate registerPhasesWithManager:[FCPhaseManager instance]];
	
	[s_lua call:@"FCApp.WarmBoot" required:YES withSig:@""];
}

+(void)shutdown
{
	[s_displayLink invalidate];
	s_perfCounter = nil;
	s_delegate = nil;
	[s_lua call:@"FCApp.Shutdown" required:YES withSig:@""];
	s_lua = nil;
}

+(void)update
{
	float dt = (float)[s_perfCounter secondsValue];
		
	FC::Clamp<float>(dt, 0, 0.1);
	
	[s_perfCounter zero];

	[[FCPhaseManager instance] update:dt];
	[[FCLua instance] updateThreads:dt];
}

+(void)startInternalUpdate
{
	
}

+(void)stopInternalUpdate
{
	
}

+(void)willResignActive
{
	[[FCConnect instance] stop];
	[[FCAnalytics instance] eventEndPlaySession];
	[[FCPersistentData instance] saveData];
	
	[s_lua call:@"FCApp.WillResignActive" required:NO withSig:@""];
}

+(void)didEnterBackground
{
	[s_lua call:@"FCApp.DidEnterBackground" required:NO withSig:@""];		
}

+(void)willEnterForeground
{
	[s_lua call:@"FCApp.WillEnterForeground" required:NO withSig:@""];	
}

+(void)didBecomeActive
{
	[[FCConnect instance] start:nil];
	[[FCConnect instance] enableBonjourWithName:@"FCConnect"];
	[[FCAnalytics instance] eventStartPlaySession];
	
	[s_lua call:@"FCApp.DidBecomeActive" required:NO withSig:@""];		
}

+(void)willTerminate
{
	[[FCAnalytics instance] shutdown];
	
	[s_lua call:@"FCApp.WillTerminate" required:NO withSig:@""];		
}

+(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	BOOL ret = YES;
	if (UIInterfaceOrientationIsLandscape(interfaceOrientation)) {
		[[[FCLua instance] coreVM] call:@"FCApp.SupportsLandscape" required:NO withSig:@">b", &ret];
	}
	if (UIInterfaceOrientationIsPortrait(interfaceOrientation)) {
		[[[FCLua instance] coreVM] call:@"FCApp.SupportsPortrait" required:NO withSig:@">b", &ret];
	}
	return ret;
}

+(FCLuaVM*)lua
{
	return s_lua;
}

+(void)showGameCenterLeaderboard
{
    GKLeaderboardViewController *leaderboardController = [[GKLeaderboardViewController alloc] init];
	
    if (leaderboardController != nil)
    {
        leaderboardController.leaderboardDelegate = self;
        [s_viewController presentModalViewController: leaderboardController animated: YES];
    }
}

+(void)leaderboardViewControllerDidFinish:(GKLeaderboardViewController *)viewController
{
	[s_viewController dismissModalViewControllerAnimated:YES];	
	
	// call lua func ?
}

+(void)launchExternalURL:(NSString*)stringURL
{
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:stringURL]];
}

@end

#endif
