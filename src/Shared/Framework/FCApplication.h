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

#ifndef CR1_FCApplication_h
#define CR1_FCApplication_h

#include "Shared/Core/FCCore.h"
#include "Shared/Core/Debug/FCPerformanceCounter.h"
#include "Shared/Lua/FCLua.h"

class FCPhaseManager;

class FCApplicationDelegate
{
public:
	FCApplicationDelegate(){}
	virtual ~FCApplicationDelegate(){}
	
	virtual void RegisterPhasesWithManager( FCPhaseManager* pPhaseManager ) = 0;
	virtual void InitializeSystems() = 0;
	virtual void Update( float realTime, float gameTime ) = 0;
};

class FCApplication
{
public:
	static FCApplication* Instance();
	
	FCApplication();
	virtual ~FCApplication();
	
	virtual void ColdBoot( FCApplicationDelegate* pDelegate );
	
	void WarmBoot();	// no need for platform layer
	
	virtual void Shutdown();
	void Update();
	virtual void Pause();
	virtual void Resume();
	
	virtual void RegisterExceptionHandler();
	virtual void SetAnalyticsID( std::string ident );
	virtual void SetTestFlightID( std::string ident );
	
	virtual void WillResignActive();
	virtual void DidEnterBackground();
	virtual void WillEnterForeground();
	void DidBecomeActive();
	virtual void WillTerminate();
	
	virtual void ShowExternalLeaderboard();
	virtual void ShowStatusBar( bool visible );
	virtual void SetBackgroundColor( FCColor4f& color );
	virtual void SetUpdateFrequency( int freq );
	
	virtual FCVector2f MainViewSize();
//	virtual FCLuaVM* Lua();
	
	virtual void LaunchExternalURL( std::string url );

	bool ShouldAutorotateToInterfaceOrientation( FCInterfaceOrientation orient );
private:
	
	FCApplicationDelegate*	m_delegate;
	FCPerformanceCounterPtr	m_performanceCounter;
	FCLuaVMPtr				m_lua;
	bool					m_paused;
};

#endif
