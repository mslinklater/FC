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

#ifndef _FCApplication_h
#define _FCApplication_h

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
	virtual void DeregisterPhasesWithManager( FCPhaseManager* pPhaseManager ) = 0;
	virtual void InitializeSystems() = 0;
	virtual void ShutdownSystems() = 0;
	
	virtual void Update( float realTime, float gameTime ) = 0;
};

class FCApplicationColdBootParams
{
public:
	FCApplicationDelegate*	pDelegate;
	uint32_t				allowableOrientationsMask;
};

typedef void (*FCApplicationUpdateFuncPtr)( float realTime, float gameTime );

typedef std::set<FCApplicationUpdateFuncPtr>	FCApplicationUpdateFuncPtrSet;
typedef FCApplicationUpdateFuncPtrSet::iterator	FCApplicationUpdateFuncPtrSetIter;

class FCApplication
{
public:
	static FCApplication* Instance();
	static void RequestWarmBoot( int context );
	
	FCApplication();
	virtual ~FCApplication();
	
	virtual void ColdBoot( FCApplicationColdBootParams& params );
	
	void WarmBoot();	// no need for platform layer
	void WarmShutdown();
	void LoadLuaLayout();
	void LoadLuaLanguage();
	
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
	FCColor4f&	BackgroundColor(){ return m_backgroundColor; }
	
	void AddUpdateSubscriber( FCApplicationUpdateFuncPtr func );
	void RemoveUpdateSubscriber( FCApplicationUpdateFuncPtr func );
	
	virtual void SetUpdateFrequency( int freq );
	
	virtual FCVector2f MainViewSize();
	
	virtual bool LaunchExternalURL( std::string url );

	bool ShouldAutorotateToInterfaceOrientation( FCInterfaceOrientation orient );
private:
	
	FCApplicationDelegate*			m_delegate;
	FCPerformanceCounterRef			m_performanceCounter;
	FCLuaVMRef						m_lua;
	bool							m_paused;
	FCColor4f						m_backgroundColor;
	FCApplicationUpdateFuncPtrSet	m_updateSubscribers;
	
	static bool						s_warmBootRequested;
};

#endif
