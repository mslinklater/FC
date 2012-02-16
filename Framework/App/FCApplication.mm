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

#import "FCCore.h"
#import "FCApplication.h"
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
#import "FCPhysics.h"
#import "FCActorSystem.h"
#import "FCShaderManager.h"
#import "FCFacebook.h"

#if defined (FC_LUA)
static FCLuaVM*					s_lua;
#endif

static FCHandle	s_sessionActiveAnalyticsHandle = kFCHandleInvalid;

#if TARGET_OS_IPHONE
static UIViewController*		s_viewController;
static CADisplayLink*			s_displayLink;
#endif

static id<FCAppDelegate>		s_delegate;
static FCPerformanceCounter*	s_perfCounter;
static BOOL						s_paused;

#if defined (FC_LUA)
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
	[[FCApplication instance] showGameCenterLeaderboard];
	return 0;
}

static int lua_LaunchExternalURL( lua_State* _state )
{
	FC_ASSERT(lua_type(_state, 1) == LUA_TSTRING);
	
	NSString* urlString = [NSString stringWithUTF8String:lua_tostring(_state, 1)];
	
	[[FCApplication instance] launchExternalURL:urlString];
	return 0;
}

static int lua_MainViewSize( lua_State* _state )
{
	FC_ASSERT(lua_gettop(_state) == 0);
	
	CGSize size = s_viewController.view.frame.size;
	
	lua_pushnumber(_state, size.width);
	lua_pushnumber(_state, size.height);
	
	return 2;
}

static int lua_PauseGame( lua_State* _state )
{
	FC_ASSERT(lua_gettop(_state) == 1);
	FC_ASSERT(lua_isboolean(_state, 1));
	
	if (lua_toboolean(_state, 1)) {
		[[FCApplication instance] pause];
	} else {
		[[FCApplication instance] resume];
	}
	
	return 0;
}

static int lua_SetUpdateFrequency( lua_State* _state )
{
	FC_ASSERT(lua_gettop(_state) == 1);
	FC_ASSERT(lua_type(_state, 1) == LUA_TNUMBER);
	
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
	s_perfCounter = [[FCPerformanceCounter alloc] init];
	
#if TARGET_OS_IPHONE
	s_displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(update)];
	[s_displayLink setFrameInterval:1];
	[s_displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];

	vc.view.backgroundColor = [UIColor blackColor];
	[FCViewManager instance].rootView = vc.view;
#endif
	
	// register system lua hooks

#if defined (FC_LUA)
	s_lua = [[FCLua instance] coreVM];
	
	[FCPersistentData registerLuaFunctions:s_lua];
	[FCPhaseManager registerLuaFunctions:s_lua];

	[FCViewManager registerLuaFunctions:s_lua];
	[FCBuild registerLuaFunctions:s_lua];

//	[FCAnalytics registerLuaFunctions:s_lua];

	[FCError registerLuaFunctions:s_lua];

	[s_lua createGlobalTable:@"FCApp"];
	[s_lua registerCFunction:lua_ShowStatusBar as:@"FCApp.ShowStatusBar"];
	[s_lua registerCFunction:lua_SetBackgroundColor as:@"FCApp.SetBackgroundColor"];
	[s_lua registerCFunction:lua_ShowGameCenterLeaderboards as:@"FCApp.ShowGameCenterLeaderboards"];
	[s_lua registerCFunction:lua_LaunchExternalURL as:@"FCApp.LaunchExternalURL"];
	[s_lua registerCFunction:lua_MainViewSize as:@"FCApp.MainViewSize"];
	[s_lua registerCFunction:lua_PauseGame as:@"FCApp.Pause"];
	[s_lua registerCFunction:lua_SetUpdateFrequency as:@"FCApp.SetUpdateFrequency"];
	
	[s_lua setGlobal:@"FCApp.paused" boolean:NO];
#endif
	
#if TARGET_OS_IPHONE
	[[FCConnect instance] start:nil];
	[[FCConnect instance] enableBonjourWithName:@"FCConnect"];
	
	[FCFacebook instance];
	[FCAnalytics instance];
#endif
	[[FCDevice instance] probe];
	[[FCDevice instance] warmProbe];
	
	[[FCPersistentData instance] loadData];
#if defined (FC_PHYSICS)
	[FCPhysics instance];
#endif
	[FCActorSystem instance];
	
#if defined(FC_LUA)
	[s_lua loadScript:@"main"];
	[s_lua call:@"FCApp.ColdBoot" required:YES withSig:@""];
#endif
	[self warmBoot];
}

-(void)warmBoot
{
	[s_delegate registerPhasesWithManager:[FCPhaseManager instance]];
	[s_delegate initialiseSystems];
	
#if defined (FC_LUA)
	[s_lua call:@"FCApp.WarmBoot" required:YES withSig:@""];
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
	[s_lua call:@"FCApp.Shutdown" required:YES withSig:@""];
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

	FCPerformanceCounter* localCounter = [[FCPerformanceCounter alloc] init];
	[localCounter zero];
	
	static float pauseSmooth = 0.0f;
	float dt = (float)[s_perfCounter secondsValue];
	[s_perfCounter zero];

		
	
	FC::Clamp<float>(dt, 0, 0.1);
	
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
	[[FCLua instance] updateThreadsRealTime:dt gameTime:gameTime];
#endif
	
	// update the game systems here...
	
#if defined (FC_PHYSICS)
	[[FCPhysics instance] update:dt gameTime:gameTime];
#endif
	
	[[FCActorSystem instance] update:dt gameTime:gameTime];
	
	// Keep this as the last update - since render views are updated here.
	[[FCPhaseManager instance] update:dt];

//	float elapsed = [localCounter secondsValue];
	
	seconds += dt;
	if (seconds >= 1.0f) {
//		NSLog(@"fps: %d - %f", fps, 1.0f / elapsed);
		
		
		if (fps < 55) {
//			[s_displayLink invalidate];
//			s_displayLink = nil;
//			s_displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(update)];
//			[s_displayLink setFrameInterval:1];
//			[s_displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
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
	[[FCLua instance].coreVM setGlobal:@"FCApp.paused" boolean:YES];
#endif
}

-(void)resume
{
	s_paused = NO;
#if defined (FC_LUA)
	[[FCLua instance].coreVM setGlobal:@"FCApp.paused" boolean:NO];
#endif
}

-(void)willResignActive
{
#if TARGET_OS_IPHONE
	[[FCConnect instance] stop];
	
	FC_ASSERT(s_sessionActiveAnalyticsHandle != kFCHandleInvalid);
	
	[[FCAnalytics instance] endTimedEvent:s_sessionActiveAnalyticsHandle];
	s_sessionActiveAnalyticsHandle = kFCHandleInvalid;
#endif
	[[FCPersistentData instance] saveData];
	
#if defined (FC_LUA)
	[s_lua call:@"FCApp.WillResignActive" required:NO withSig:@""];
#endif
}

-(void)didEnterBackground
{
#if defined (FC_LUA)
	[s_lua call:@"FCApp.DidEnterBackground" required:NO withSig:@""];
#endif
}

-(void)willEnterForeground
{
#if defined (FC_LUA)
	[s_lua call:@"FCApp.WillEnterForeground" required:NO withSig:@""];	
#endif
}

-(void)didBecomeActive
{
#if TARGET_OS_IPHONE
	[[FCConnect instance] start:nil];
	[[FCConnect instance] enableBonjourWithName:@"FCConnect"];
	
	FC_ASSERT(s_sessionActiveAnalyticsHandle == kFCHandleInvalid);
	
	s_sessionActiveAnalyticsHandle = [[FCAnalytics instance] beginTimedEvent:@"playSessionTime"];
#endif
	
#if defined (FC_LUA)
	[s_lua call:@"FCApp.DidBecomeActive" required:NO withSig:@""];		
#endif
}

-(void)willTerminate
{
#if TARGET_OS_IPHONE
//	[[FCAnalytics instance] shutdown];
#endif
	
#if defined (FC_LUA)
	[s_lua call:@"FCApp.WillTerminate" required:NO withSig:@""];		
#endif
}

#if TARGET_OS_IPHONE
-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
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


-(void)launchExternalURL:(NSString*)stringURL
{
#if TARGET_OS_IPHONE
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:stringURL]];
#endif
}

@end
