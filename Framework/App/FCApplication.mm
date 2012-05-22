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

#import <QuartzCore/QuartzCore.h>

#import "FCApplication.h"
#import "FCPersistentData.h"
#import "FCPhaseManager.h"
#import "FCPerformanceCounter.h"
#import "FCViewManager.h"
#import "FCBuild.h"
#import "FCActorSystem.h"
#import "FCShaderManager.h"
#import "FCTwitter.h"
#import "FCAudioManager.h"

#include "Shared/Core/FCCore.h"
#include "Shared/Core/Device/FCDevice.h"
#include "Shared/Core/FCError.h"
#include "Shared/Core/Debug/FCConnect.h"
#include "Shared/Framework/Analytics/FCAnalytics.h"

#if defined (FC_LUA)
static FCLuaVM*					s_lua;
#endif

static FCHandle	s_sessionActiveAnalyticsHandle = kFCHandleInvalid;

#if TARGET_OS_IPHONE
static UIViewController*		s_viewController;
static CADisplayLink*			s_displayLink;
#endif

static id<FCAppDelegate>		s_delegate;
static FCPerformanceCounterPtr	s_perfCounter;
static BOOL						s_paused;

#if defined (FC_LUA)
static int lua_ShowStatusBar( lua_State* _state )
{
	FC_LUA_ASSERT_NUMPARAMS(1);
	FC_LUA_ASSERT_TYPE(1, LUA_TBOOLEAN);
	
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
	FC_LUA_ASSERT_NUMPARAMS(1);
	FC_LUA_ASSERT_TYPE(1, LUA_TTABLE);
	
	double r, g, b, a;

	lua_pushnil(_state);
	
	lua_next(_state, -2);
	FC_LUA_ASSERT_TYPE(-1, LUA_TNUMBER);
	r = lua_tonumber(_state, -1);
	lua_pop(_state, 1);

	lua_next(_state, -2);
	FC_LUA_ASSERT_TYPE(-1, LUA_TNUMBER);
	g = lua_tonumber(_state, -1);
	lua_pop(_state, 1);

	lua_next(_state, -2);
	FC_LUA_ASSERT_TYPE(-1, LUA_TNUMBER);
	b = lua_tonumber(_state, -1);
	lua_pop(_state, 1);

	lua_next(_state, -2);
	FC_LUA_ASSERT_TYPE(-1, LUA_TNUMBER);
	a = lua_tonumber(_state, -1);
	
	s_viewController.view.backgroundColor = [UIColor colorWithRed:r green:g blue:b alpha:a];

	return 0;
}

static int lua_ShowGameCenterLeaderboards( lua_State* _state )
{
	FC_LUA_ASSERT_NUMPARAMS(0);
	[[FCApplication instance] showGameCenterLeaderboard];
	return 0;
}

static int lua_LaunchExternalURL( lua_State* _state )
{
	FC_LUA_ASSERT_NUMPARAMS(1);
	FC_LUA_ASSERT_TYPE(1, LUA_TSTRING);
	
	NSString* urlString = [NSString stringWithUTF8String:lua_tostring(_state, 1)];
	
	[[FCApplication instance] launchExternalURL:urlString];
	return 0;
}

static int lua_MainViewSize( lua_State* _state )
{
	FC_LUA_ASSERT_NUMPARAMS(0);
	
	CGSize size = s_viewController.view.frame.size;
	
	lua_pushnumber(_state, size.width);
	lua_pushnumber(_state, size.height);
	
	return 2;
}

static int lua_PauseGame( lua_State* _state )
{
	FC_LUA_ASSERT_NUMPARAMS(1);
	FC_LUA_ASSERT_TYPE(1, LUA_TBOOLEAN);
	
	if (lua_toboolean(_state, 1)) {
		[[FCApplication instance] pause];
	} else {
		[[FCApplication instance] resume];
	}
	
	return 0;
}

static int lua_SetUpdateFrequency( lua_State* _state )
{
	FC_LUA_ASSERT_NUMPARAMS(1);
	FC_LUA_ASSERT_TYPE(1, LUA_TNUMBER);
	
	[[FCApplication instance] setUpdateFrequency:lua_tointeger(_state, 1)];
	
	return 0;
}


#endif // defined(FC_LUA)

#pragma mark - Objective-C Impl

@implementation FCApplication

+(FCApplication*)instance
{
	static FCApplication* pInstance;
	if (!pInstance) {
		pInstance = [[FCApplication alloc] init];
	}
	return pInstance;
}

-(id)init
{
	self = [super init];
	if (self) {
		// blah
	}
	return self;
}

#if TARGET_OS_IPHONE
-(void)coldBootWithViewController:(UIViewController *)vc delegate:(id<FCAppDelegate>)delegate
#else
-(void)coldBootWithDelegate:(id<FCAppDelegate>)delegate
#endif
{
#if TARGET_OS_IPHONE
	s_viewController = vc;
#endif
	s_delegate = delegate;
	s_perfCounter = FCPerformanceCounterPtr( new FCPerformanceCounter );
	
#if TARGET_OS_IPHONE
	s_displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(update)];
	[s_displayLink setFrameInterval:1];
	[s_displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];

	vc.view.backgroundColor = [UIColor blackColor];
	[FCViewManager instance].rootView = vc.view;
#endif
	
	// register system lua hooks

#if defined (FC_LUA)
	s_lua = FCLua::Instance()->CoreVM();
	
	[FCPersistentData registerLuaFunctions:s_lua];
	[FCPhaseManager registerLuaFunctions:s_lua];

	[FCViewManager registerLuaFunctions:s_lua];
//	[FCBuild registerLuaFunctions:s_lua];
	FCBuild::Instance();

	s_lua->CreateGlobalTable("FCApp");
	s_lua->RegisterCFunction(lua_ShowStatusBar, "FCApp.ShowStatusBar");
	s_lua->RegisterCFunction(lua_SetBackgroundColor, "FCApp.SetBackgroundColor");
	s_lua->RegisterCFunction(lua_ShowGameCenterLeaderboards, "FCApp.ShowGameCenterLeaderboards");
	s_lua->RegisterCFunction(lua_LaunchExternalURL, "FCApp.LaunchExternalURL");
	s_lua->RegisterCFunction(lua_MainViewSize, "FCApp.MainViewSize");
	s_lua->RegisterCFunction(lua_PauseGame, "FCApp.Pause");
	s_lua->RegisterCFunction(lua_SetUpdateFrequency, "FCApp.SetUpdateFrequency");
	
	s_lua->SetGlobalBool("FCApp.paused", false);
#endif
	
#if TARGET_OS_IPHONE
	FCConnect::Instance()->Start();
	FCConnect::Instance()->EnableWithName("FCConnect");
	
//	[FCFacebook instance];
	FCAnalytics::Instance();
	[FCTwitter instance];
	[FCAudioManager instance];
#endif
	FCDevice::Instance()->ColdProbe();
	FCDevice::Instance()->WarmProbe();
	
	[[FCPersistentData instance] loadData];
#if defined (FC_PHYSICS)
	FCPhysics::Instance();
#endif
	[FCActorSystem instance];
	
#if defined(FC_LUA)
	s_lua->LoadScript("main");
	s_lua->CallFuncWithSig("FCApp.ColdBoot", true, "");
#endif
	[self warmBoot];
}

-(void)warmBoot
{
	[s_delegate registerPhasesWithManager:[FCPhaseManager instance]];
	[s_delegate initialiseSystems];
	
#if defined (FC_LUA)
	s_lua->CallFuncWithSig("FCApp.WarmBoot", true, "");
#endif
}

-(void)shutdown
{
#if TARGET_OS_IPHONE
	[s_displayLink invalidate];
#endif
	s_perfCounter = nil;
	s_delegate = nil;
	
#if defined (FC_LUA)
	s_lua->CallFuncWithSig("FCApp.Shutdown", true, "");
	s_lua = nil;
#endif
}

-(void)setUpdateFrequency:(int)fps
{
	[s_displayLink invalidate];
	s_displayLink = nil;
	
	s_displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(update)];
	[s_displayLink setFrameInterval:60 / fps];
	[s_displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
}

-(void)update
{
	static int fps = 0;
	static float seconds = 0.0f;

	FCPerformanceCounterPtr localCounter = FCPerformanceCounterPtr( new FCPerformanceCounter );
	localCounter->Zero();
	
	static float pauseSmooth = 0.0f;
	float dt = (float)s_perfCounter->MilliValue() / 1000.0f;
	s_perfCounter->Zero();		
	
	FCClamp<float>(dt, 0, 0.1);
	
	float gameTime;
	
	if (s_paused) {
		pauseSmooth += (0.0f - pauseSmooth) * dt * 5;
	} else {
		pauseSmooth += (1.0f - pauseSmooth) * dt * 5;
	}

	if (pauseSmooth < 0.05f)
		gameTime = 0.0f;
	else
		gameTime = dt * pauseSmooth;
	
	[s_delegate updateRealTime:dt gameTime:gameTime];
	
#if defined (FC_LUA)
	FCLua::Instance()->UpdateThreads(dt, gameTime);
#endif
	
	// update the game systems here...
	
#if defined (FC_PHYSICS)
	FCPhysics::Instance()->Update( dt, gameTime );
#endif
	
	[[FCActorSystem instance] update:dt gameTime:gameTime];
	
	// Keep this as the last update - since render views are updated here.
	[[FCPhaseManager instance] update:dt];

	seconds += dt;
	if (seconds >= 1.0f) {
		if (fps < 55) {
		}		
		seconds = 0.0f;
		fps = 0;
	} else {
		fps++;
	}
}

-(void)pause
{
	s_paused = YES;
#if defined (FC_LUA)
	s_lua->SetGlobalBool("FCApp.paused", true);
#endif
	[[NSNotificationCenter defaultCenter] postNotificationName:[NSString stringWithUTF8String:kFCNotificationPause.c_str()] object:nil];
}

-(void)resume
{
	s_paused = NO;
#if defined (FC_LUA)
	s_lua->SetGlobalBool("FCApp.paused", false);
#endif
	[[NSNotificationCenter defaultCenter] postNotificationName:[NSString stringWithUTF8String:kFCNotificationResume.c_str()] object:nil];
}

-(void)willResignActive
{
#if TARGET_OS_IPHONE
	FCConnect::Instance()->Stop();
	
	FC_ASSERT(s_sessionActiveAnalyticsHandle != kFCHandleInvalid);
	
	FCAnalytics::Instance()->EndTimedEvent(s_sessionActiveAnalyticsHandle);
	s_sessionActiveAnalyticsHandle = kFCHandleInvalid;
#endif
	[[FCPersistentData instance] saveData];
	
#if defined (FC_LUA)
	s_lua->CallFuncWithSig("FCApp.WillResignActive", false, "");
#endif
}

-(void)didEnterBackground
{
#if defined (FC_LUA)
	s_lua->CallFuncWithSig("FCApp.DidEnterBackground", false, "");
#endif
}

-(void)willEnterForeground
{
#if defined (FC_LUA)
	s_lua->CallFuncWithSig("FCApp.WillEnterForeground", false, "");
#endif
}

-(void)didBecomeActive
{
#if TARGET_OS_IPHONE
	FCConnect::Instance()->Start();
	FCConnect::Instance()->EnableWithName("FCConnect");
	
	FC_ASSERT(s_sessionActiveAnalyticsHandle == kFCHandleInvalid);
	
	s_sessionActiveAnalyticsHandle = FCAnalytics::Instance()->BeginTimedEvent("playSessionTime");
#endif
	
#if defined (FC_LUA)
	s_lua->CallFuncWithSig("FCApp.DidBecomeActive", false, "");
#endif
}

-(void)willTerminate
{
#if TARGET_OS_IPHONE
#endif
	
#if defined (FC_LUA)
	s_lua->CallFuncWithSig("FCApp.WillTerminate", false, "");
#endif
}

#if TARGET_OS_IPHONE
-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	BOOL ret = YES;
	if (UIInterfaceOrientationIsLandscape(interfaceOrientation)) {
		FCLua::Instance()->CoreVM()->CallFuncWithSig("FCApp.SupportsLandscape", false, ">b", &ret);
	}
	if (UIInterfaceOrientationIsPortrait(interfaceOrientation)) {
		FCLua::Instance()->CoreVM()->CallFuncWithSig("FCApp.SupportsPortrait", false, ">b", &ret);
	}
	return ret;
}

-(void)showGameCenterLeaderboard
{
    GKLeaderboardViewController *leaderboardController = [[GKLeaderboardViewController alloc] init];
	
    if (leaderboardController != nil)
    {
        leaderboardController.leaderboardDelegate = self;
        [s_viewController presentModalViewController: leaderboardController animated: YES];
    }
}

-(void)leaderboardViewControllerDidFinish:(GKLeaderboardViewController *)viewController
{
	[s_viewController dismissModalViewControllerAnimated:YES];	
	
	// call lua func ?
}
#endif

-(CGSize)mainViewSize
{
#if TARGET_OS_IPHONE
	return s_viewController.view.frame.size;
#else
	return CGSizeMake(0, 0);
#endif
}

#if defined (FC_LUA)
-(FCLuaVM*)lua
{
	return s_lua;
}
#endif

-(UIViewController*)rootViewController
{
	return s_viewController;
}

-(void)launchExternalURL:(NSString*)stringURL
{
#if TARGET_OS_IPHONE
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:stringURL]];
#endif
}

@end
