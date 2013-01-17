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

#import "FCApplication_apple.h"
#import "FCViewManager_apple.h"
#import "Flurry.h"

#if defined( _FC_TESTFLIGHT )
#import "TestFlight.h"
#endif // _FC_TESTFLIGHT

#include "Shared/Core/FCCore.h"

static UIViewController* s_rootViewController = nil;

UIViewController* FCRootViewController()
{
	return s_rootViewController;
}

void FCSetRootViewController( UIViewController* vc )
{
	s_rootViewController = vc;
}

FCApplication* plt_FCApplication_Instance();

static FCApplication* s_pInstance = 0;
static FCApplication_apple* s_pInstance_apple = 0;

FCApplication* plt_FCApplication_Instance()
{
	if(!s_pInstance)
	{
		s_pInstance = new FCApplicationProxy;
	}
	return s_pInstance;
}

FCApplicationProxy::FCApplicationProxy()
{
	m_pApp = [[FCApplication_apple alloc] init];
	s_pInstance_apple = m_pApp;
}

FCApplicationProxy::~FCApplicationProxy()
{
	m_pApp = nil;
}

void FCApplicationProxy::ColdBoot( FCApplicationColdBootParams& params )
{
	[m_pApp coldBootWithParams:params];
	FCApplication::ColdBoot( params );
}

void FCApplicationProxy::WarmBoot()
{
	FCApplication::WarmBoot();
}

void FCApplicationProxy::Shutdown()
{
	FC_HALT;
	
}

//void FCApplicationProxy::Update()
//{
//	FC_HALT;
//}

void FCApplicationProxy::Pause()
{
	FCApplication::Pause();
	[m_pApp pause];
}

void FCApplicationProxy::Resume()
{
	FCApplication::Resume();
	[m_pApp resume];
}

void FCApplicationProxy::SetAnalyticsID( std::string ident )
{
	[Flurry startSession:@(ident.c_str())];
}

void FCApplicationProxy::SetTestFlightID( std::string ident )
{
#if defined( _FC_TESTFLIGHT )
	[TestFlight takeOff:[NSString stringWithUTF8String:ident.c_str()]];
#endif // _FC_TESTFLIGHT
}

void FCApplicationProxy::WillResignActive()
{
	FCApplication::WillResignActive();
}

void FCApplicationProxy::DidEnterBackground()
{
	FCApplication::DidEnterBackground();
}

void FCApplicationProxy::WillEnterForeground()
{
	FCApplication::WillEnterForeground();
}

//void FCApplicationProxy::DidBecomeActive()
//{
//	FC_HALT;
//	
//}

void FCApplicationProxy::WillTerminate()
{
	FCApplication::WillTerminate();
}

//bool FCApplicationProxy::ShouldAutorotateToInterfaceOrientation( FCInterfaceOrientation orient )
//{
//	return FCApplication::ShouldAutorotateToInterfaceOrientation(orient);
//}

void FCApplicationProxy::ShowExternalLeaderboard()
{
	[m_pApp showGameCenterLeaderboard];
}

void FCApplicationProxy::ShowStatusBar( bool visible )
{
	[m_pApp showStatusBar:visible];
}

void FCApplicationProxy::SetBackgroundColor(FCColor4f &color)
{
	FCApplication::SetBackgroundColor(color);
	
	[m_pApp setBackgroundColor:color];
}

FCVector2f FCApplicationProxy::MainViewSize()
{
	CGSize size = [m_pApp mainViewSize];
	
	return FCVector2f( size.width, size.height );
}

void FCApplicationProxy::SetUpdateFrequency(int freq)
{
	[m_pApp setUpdateFrequency:freq];
}

//FCLuaVM* FCApplicationProxy::Lua()
//{
//	FC_HALT;
//	return 0;
//}

bool FCApplicationProxy::LaunchExternalURL( std::string url )
{
	NSString* stringURL = @(url.c_str());
	return [m_pApp launchExternalURL:stringURL];
}

void FCApplicationProxy::RegisterExceptionHandler()
{
	[m_pApp registerExceptionHandler];
}

static void uncaughtExceptionHandler(NSException *exception) {
    FC_LOG( "Sending uncaught exception to Flurry" );
	
//#if defined( _FC_FLURRY )
    [Flurry logError:@"Uncaught" message:@"Crash!" exception:exception];
//#endif // _FC_FLURRY
}


#pragma mark ObjC

@implementation FCApplication_apple

@synthesize displayLink = _displayLink;

+(FCApplication_apple*)instance
{
	return s_pInstance_apple;
}

-(id)init
{
	self = [super init];
	if (self)
	{
		// plap
	}
	return self;
}

-(void)dealloc
{
	// TODO - remove display link from runloop
}

-(void)registerExceptionHandler
{
	NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);
}

-(void)setAnalyticsID:(NSString*)ident
{
}

-(void)setTestFlightID:(NSString*)ident
{
	FC_HALT;
	
}

#if !defined( ADHOC )
-(void)setDebugMenuButton:(UIView*)view
{
	mDebugMenuButton = view;
	[s_rootViewController.view addSubview:view];
}
#endif

-(void)coldBootWithParams:(FCApplicationColdBootParams &)params
{
	FC_ASSERT( s_rootViewController );
	
	_displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(update)];
	[_displayLink setFrameInterval:1];
	[_displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
	
	s_rootViewController.view.backgroundColor = [UIColor blackColor];
	
	CGRect frame = [UIScreen mainScreen].bounds;

	if (params.allowableOrientationsMask & kFCInterfaceOrientation_Landscape) {
		float temp = frame.size.width;
		frame.size.width = frame.size.height;
		frame.size.height = temp;
	}
	
    UIView* gameRootView = [[UIView alloc] initWithFrame:frame];
    [s_rootViewController.view addSubview:gameRootView];
    [FCViewManager_apple instance].rootView = gameRootView;
#if !defined(ADHOC)
	[s_rootViewController.view bringSubviewToFront:mDebugMenuButton];
#endif
}

-(void)update
{
	s_pInstance->Update();
}

-(void)pause
{
	FCNotification note;
	note.notification = kFCNotificationPause;
	
	FCNotificationManager::Instance()->SendNotification( note );
}

-(void)resume
{
	FCNotification note;
	note.notification = kFCNotificationResume;
	
	FCNotificationManager::Instance()->SendNotification( note );
}

-(void)showStatusBar:(bool)visible
{
	if (visible) {
		[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
	} else {
		[[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
		s_rootViewController.view.frame = [[UIScreen mainScreen] bounds];
	}
}

-(void)setBackgroundColor:(FCColor4f &)color
{
	[FCViewManager_apple instance].rootView.backgroundColor = [UIColor colorWithRed:color.r green:color.g blue:color.b alpha:color.a];
}

-(void)showGameCenterLeaderboard
{
	GKLeaderboardViewController *leaderboardController = [[GKLeaderboardViewController alloc] init];
	
    if (leaderboardController != nil)
    {
        leaderboardController.leaderboardDelegate = self;
        [s_rootViewController presentModalViewController: leaderboardController animated: YES];
    }
}

-(void)leaderboardViewControllerDidFinish:(GKLeaderboardViewController *)viewController
{
	[s_rootViewController dismissModalViewControllerAnimated:YES];	
	
	// call lua func ?
}

-(BOOL)launchExternalURL:(NSString *)url
{
	return [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
}

-(CGSize)mainViewSize
{
	return s_rootViewController.view.frame.size;
}

-(void)setUpdateFrequency:(int)freq
{
	[_displayLink invalidate];
	_displayLink = nil;
	
	_displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(update)];
	[_displayLink setFrameInterval:60 / freq];
	[_displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
}

@end

