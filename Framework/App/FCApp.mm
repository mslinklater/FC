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

#import "FCApp.h"
#import "FCPersistentData.h"
#import "FCAnalytics.h"
#import "FCCaps.h"
#import "FCError.h"
#import "FCConnect.h"

static FCLuaVM*				s_lua;
static UIViewController*	s_viewController;

@implementation FCApp

+(void)coldBootWithViewController:(UIViewController *)vc
{
	s_viewController = vc;
	
	// register system lua hooks

	s_lua = [[FCLua instance] coreVM];
	
	[FCPersistentData registerLuaFunctions:s_lua];

#if TARGET_OS_IPHONE
	[FCAnalytics registerLuaFunctions:s_lua];
	[FCCaps registerLuaFunctions:s_lua];
#endif // TARGET_OS_IPHONE

	[FCError registerLuaFunctions:s_lua];

//	[s_lua call:@"PrintTable" withSig:@"tb>", "FCCaps", true];
//	[s_lua call:@"PrintTable" withSig:@"tb>", "FCPersistentData", true];
//	[s_lua call:@"PrintTable" withSig:@"tb>", "FCAnalytics", true];

	[[FCConnect instance] start:nil];
	[[FCConnect instance] enableBonjourWithName:@"FCConnect"];
	
	[s_lua loadScript:@"main"];
	[s_lua call:@"App.ColdBoot" required:YES withSig:@""];
	[self warmBoot];
}

+(void)warmBoot
{
	[s_lua call:@"App.WarmBoot" required:YES withSig:@""];
}

+(void)shutdown
{
	[s_lua call:@"App.Shutdown" required:YES withSig:@""];
}

+(void)update
{
	[[FCLua instance] updateThreads];
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
