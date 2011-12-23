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

//#import <UIKit/UIKit.h>

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

static FCLuaVM*				s_lua;
static UIViewController*	s_viewController;
static id<FCAppDelegate>	s_delegate;
static FCPerformanceCounter*	s_perfCounter;
static CADisplayLink*			s_displayLink;

static int lua_HideStatusBar( lua_State* _state )
{
	[[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
	s_viewController.view.frame = [[UIScreen mainScreen] bounds];
	return 0;
}

static int lua_ShowStatusBar( lua_State* _state )
{
	[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
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

#if TARGET_OS_IPHONE
	[FCAnalytics registerLuaFunctions:s_lua];
	[FCDevice registerLuaFunctions:s_lua];
#endif // TARGET_OS_IPHONE

	[FCError registerLuaFunctions:s_lua];
	[s_lua createGlobalTable:@"App"];
	[s_lua registerCFunction:lua_HideStatusBar as:@"App.HideStatusBar"];
	[s_lua registerCFunction:lua_ShowStatusBar as:@"App.ShowStatusBar"];

//	[s_lua call:@"PrintTable" withSig:@"tb>", "FCCaps", true];
//	[s_lua call:@"PrintTable" withSig:@"tb>", "FCPersistentData", true];
//	[s_lua call:@"PrintTable" withSig:@"tb>", "FCAnalytics", true];

	[[FCConnect instance] start:nil];
	[[FCConnect instance] enableBonjourWithName:@"FCConnect"];
	
	[[FCPersistentData instance] loadData];
	
	[s_lua loadScript:@"main"];
	[s_lua call:@"App.ColdBoot" required:YES withSig:@""];
	[self warmBoot];
}

+(void)warmBoot
{
	[s_delegate registerPhasesWithManager:[FCPhaseManager instance]];
	
	[s_lua call:@"App.WarmBoot" required:YES withSig:@""];
}

+(void)shutdown
{
	[s_displayLink invalidate];
	s_perfCounter = nil;
	s_delegate = nil;
	[s_lua call:@"App.Shutdown" required:YES withSig:@""];
	s_lua = nil;
}

+(void)update
{
	float dt = (float)[s_perfCounter secondsValue];
		
	dt = FC::Clamp<float>(dt, 0, 0.1);
	
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
	[s_lua call:@"App.WillResignActive" required:NO withSig:@""];
	[[FCPersistentData instance] saveData];
}

+(void)didEnterBackground
{
	[s_lua call:@"App.DidEnterBackground" required:NO withSig:@""];		
}

+(void)willEnterForeground
{
	[s_lua call:@"App.WillEnterForeground" required:NO withSig:@""];	
}

+(void)didBecomeActive
{
	[[FCConnect instance] start:nil];
	[[FCConnect instance] enableBonjourWithName:@"FCConnect"];
	[s_lua call:@"App.DidBecomeActive" required:NO withSig:@""];		
}

+(void)willTerminate
{
	[s_lua call:@"App.WillTerminate" required:NO withSig:@""];		
}

+(FCLuaVM*)lua
{
	return s_lua;
}

@end

#endif
