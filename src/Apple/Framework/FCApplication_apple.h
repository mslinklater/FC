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

#ifndef FCAPPLICATION_APPLE_H
#define FCAPPLICATION_APPLE_H

#import <UIKit/UIKit.h>
#import <GameKit/GameKit.h>
#import <StoreKit/StoreKit.h>

#include "Shared/Framework/FCApplication.h"

#pragma mark - ObjC

extern UIViewController* FCRootViewController();
extern void FCSetRootViewController( UIViewController* vc );

@interface FCApplication_apple : NSObject <	GKLeaderboardViewControllerDelegate>
{
	CADisplayLink* _displayLink;
	NSURLConnection*	_connection;
#if !defined( ADHOC )
	UIView*	mDebugMenuButton;
#endif
}
@property(nonatomic, strong) CADisplayLink* displayLink;

+(FCApplication_apple*)instance;

-(void)registerExceptionHandler;
-(void)showStatusBar:(bool)visible;
-(void)setBackgroundColor:(FCColor4f&)color;
-(void)setUpdateFrequency:(int)freq;

#if !defined( ADHOC )
-(void)setDebugMenuButton:(UIView*)view;
#endif

-(void)showGameCenterLeaderboard;

-(BOOL)launchExternalURL:(NSString*)url;
-(CGSize)mainViewSize;

-(void)coldBootWithParams:(FCApplicationColdBootParams&)params;
-(void)update;
-(void)pause;
-(void)resume;
@end

#pragma mark - C++

class FCApplicationProxy : public FCApplication
{
public:
	FCApplicationProxy();
	virtual ~FCApplicationProxy();
	
	void ColdBoot( FCApplicationColdBootParams& params );
	void WarmBoot();
	void Shutdown();
	void Pause();
	void Resume();
	
	void RegisterExceptionHandler();
	void SetAnalyticsID( std::string ident );
	void SetTestFlightID( std::string ident );
	
	void WillResignActive();
	void DidEnterBackground();
	void WillEnterForeground();
	void WillTerminate();
	
	void ShowExternalLeaderboard();
	void ShowStatusBar( bool visible );
	void SetBackgroundColor( FCColor4f& color );
	void SetUpdateFrequency( int freq );
	
	FCVector2f MainViewSize();
	
	bool LaunchExternalURL( std::string url );
	
private:
	FCApplication_apple*	m_pApp;
};

#endif // FCAPPLICATION_APPLE_H
