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

#include "FCApplication.h"
#include "Shared/Lua/FCLua.h"
#include "Shared/Framework/Phase/FCPhaseManager.h"
#include "Shared/Framework/UI/FCViewManager.h"
#include "Shared/Framework/FCBuild.h"
#include "Shared/Core/Debug/FCConnect.h"
#include "Shared/Framework/Analytics/FCAnalytics.h"
#include "Shared/Framework/Online/FCTwitter.h"
#include "Shared/Audio/FCAudioManager.h"
#include "Shared/Core/Device/FCDevice.h"
#include "Shared/Framework/FCPersistentData.h"
#include "Shared/Physics/FCPhysics.h"
#include "Shared/Framework/Actor/FCActorSystem.h"

static FCApplication* s_pInstance = 0;

static FCHandle	s_sessionActiveAnalyticsHandle = kFCHandleInvalid;

extern FCApplication* plt_FCApplication_Instance();

// Lua functions

static int lua_ShowStatusBar( lua_State* _state )
{
	FC_LUA_ASSERT_NUMPARAMS(1);
	FC_LUA_ASSERT_TYPE(1, LUA_TBOOLEAN);
	
	bool visible = (lua_toboolean( _state, -1) != 0);

	s_pInstance->ShowStatusBar( visible );
	return 0;
}

static int lua_SetBackgroundColor( lua_State* _state )
{
	FC_LUA_ASSERT_NUMPARAMS(1);
	FC_LUA_ASSERT_TYPE(1, LUA_TTABLE);

	FCColor4f color;
	
	lua_pushnil(_state);
	
	lua_next(_state, -2);
	FC_LUA_ASSERT_TYPE(-1, LUA_TNUMBER);
	color.r = (float)lua_tonumber(_state, -1);
	lua_pop(_state, 1);
	
	lua_next(_state, -2);
	FC_LUA_ASSERT_TYPE(-1, LUA_TNUMBER);
	color.g = (float)lua_tonumber(_state, -1);
	lua_pop(_state, 1);
	
	lua_next(_state, -2);
	FC_LUA_ASSERT_TYPE(-1, LUA_TNUMBER);
	color.b = (float)lua_tonumber(_state, -1);
	lua_pop(_state, 1);
	
	lua_next(_state, -2);
	FC_LUA_ASSERT_TYPE(-1, LUA_TNUMBER);
	color.a = (float)lua_tonumber(_state, -1);
	
	s_pInstance->SetBackgroundColor( color );
	
	return 0;
}

static int lua_ShowGameCenterLeaderboards( lua_State* _state )
{
	FC_LUA_ASSERT_NUMPARAMS(0);

	s_pInstance->ShowExternalLeaderboard();

	return 0;
}

static int lua_LaunchExternalURL( lua_State* _state )
{
	FC_LUA_ASSERT_NUMPARAMS(1);
	FC_LUA_ASSERT_TYPE(1, LUA_TSTRING);

	s_pInstance->LaunchExternalURL( lua_tostring(_state, 1) );
	
	return 0;
}

static int lua_MainViewSize( lua_State* _state )
{
	FC_LUA_ASSERT_NUMPARAMS(0);
	
	FCVector2f size = s_pInstance->MainViewSize();
	
	lua_pushnumber( _state, size.x );
	lua_pushnumber( _state, size.y );
	
	return 2;
}

static int lua_PauseGame( lua_State* _state )
{
	FC_LUA_ASSERT_NUMPARAMS(1);
	FC_LUA_ASSERT_TYPE(1, LUA_TBOOLEAN);
	
	if (lua_toboolean(_state, 1)) {
		s_pInstance->Pause();
	} else {
		s_pInstance->Resume();
	}
	
	return 0;
}

static int lua_SetUpdateFrequency( lua_State* _state )
{
	FC_LUA_ASSERT_NUMPARAMS(1);
	FC_LUA_ASSERT_TYPE(1, LUA_TNUMBER);
	
	s_pInstance->SetUpdateFrequency( lua_tointeger(_state, 1) );
	
	return 0;
}

// C++ functions

FCApplication* FCApplication::Instance()
{
	if(!s_pInstance)
	{
		s_pInstance = plt_FCApplication_Instance();
	}
	return s_pInstance;
}

FCApplication::FCApplication()
{
}

FCApplication::~FCApplication()
{
	FC_HALT;
}

void FCApplication::ColdBoot( FCApplicationColdBootParams& params )
{
	m_delegate = params.pDelegate;
	m_performanceCounter = FCPerformanceCounterRef( new FCPerformanceCounter );
	m_lua = FCLuaVMRef( FCLua::Instance()->CoreVM() );
	
	FCPhaseManager::Instance();
	FCViewManager::Instance();
	FCBuild::Instance();

	m_lua->CreateGlobalTable("FCApp");
	m_lua->RegisterCFunction(lua_ShowStatusBar, "FCApp.ShowStatusBar");
	m_lua->RegisterCFunction(lua_SetBackgroundColor, "FCApp.SetBackgroundColor");
	m_lua->RegisterCFunction(lua_ShowGameCenterLeaderboards, "FCApp.ShowGameCenterLeaderboards");
	m_lua->RegisterCFunction(lua_LaunchExternalURL, "FCApp.LaunchExternalURL");
	m_lua->RegisterCFunction(lua_MainViewSize, "FCApp.MainViewSize");
	m_lua->RegisterCFunction(lua_PauseGame, "FCApp.Pause");
	m_lua->RegisterCFunction(lua_SetUpdateFrequency, "FCApp.SetUpdateFrequency");	
	m_lua->SetGlobalBool("FCApp.paused", false);

//	FCConnect::Instance()->Start();
//	FCConnect::Instance()->EnableWithName("FCConnect");
	FCAnalytics::Instance();
	
	FCTwitter::Instance();
	FCAudioManager::Instance();
	FCDevice::Instance()->ColdProbe();
	
	FCDevice::Instance()->WarmProbe( params.allowableOrientationsMask );
	
	FCPersistentData::Instance()->Load();
	FCPhysics::Instance();
	FCActorSystem::Instance();
	
	m_lua->LoadScript("main");
	m_lua->CallFuncWithSig("FCApp.ColdBoot", true, "");
	WarmBoot();
}

void FCApplication::WarmBoot()
{
	m_delegate->InitializeSystems();
	m_delegate->RegisterPhasesWithManager( FCPhaseManager::Instance() );
	m_lua->CallFuncWithSig("FCApp.WarmBoot", true, "");
}

void FCApplication::Shutdown()
{
	FC_HALT;
}

void FCApplication::Update()
{
	static int fps = 0;
	static float seconds = 0.0f;
	
	FCPerformanceCounterRef localCounter = FCPerformanceCounterRef( new FCPerformanceCounter );
	localCounter->Zero();
	
	static float pauseSmooth = 0.0f;
	float dt = (float)m_performanceCounter->MilliValue() / 1000.0f;
	m_performanceCounter->Zero();		
	
	FCClamp<float>(dt, 0, 0.1f);
	
	float gameTime;
	
	if (m_paused) {
		pauseSmooth += (0.0f - pauseSmooth) * dt * 5;
	} else {
		pauseSmooth += (1.0f - pauseSmooth) * dt * 5;
	}
	
	if (pauseSmooth < 0.05f)
		gameTime = 0.0f;
	else
		gameTime = dt * pauseSmooth;

	m_delegate->Update(dt, gameTime);
	
	FCLua::Instance()->UpdateThreads(dt, gameTime);
	
	// update the game systems here...
	
	FCPhysics::Instance()->Update( dt, gameTime );
	
	FCActorSystem::Instance()->Update(dt, gameTime);
	
	// Keep this as the last update - since render views are updated here.
	FCPhaseManager::Instance()->Update( dt );
	
	
	for (FCApplicationUpdateFuncPtrSetIter i = m_updateSubscribers.begin(); i != m_updateSubscribers.end(); i++) {
		(*i)(dt, gameTime);
	}
	
	seconds += dt;
	if (seconds >= 1.0f) {
		if (fps < 55) {
		}		
		seconds = 0.0f;
		fps = 0;
	} else {
		fps++;
	}
//	FC_HALT;
}

void FCApplication::AddUpdateSubscriber(FCApplicationUpdateFuncPtr func)
{
	m_updateSubscribers.insert( func );
}

void FCApplication::RemoveUpdateSubscriber(FCApplicationUpdateFuncPtr func)
{
	m_updateSubscribers.erase( func );
}

void FCApplication::Pause()
{
	m_paused = true;
	m_lua->SetGlobalBool("FCApp.paused", true);
}

void FCApplication::Resume()
{
	m_paused = false;
	m_lua->SetGlobalBool("FCApp.paused", false);
}

void FCApplication::RegisterExceptionHandler()
{
	FC_HALT;
}

void FCApplication::SetAnalyticsID( std::string ident )
{
	FC_HALT;
}

void FCApplication::SetTestFlightID( std::string ident )
{
	FC_HALT;
}

void FCApplication::WillResignActive()
{
	FCConnect::Instance()->Stop();
	
	FC_ASSERT(s_sessionActiveAnalyticsHandle != kFCHandleInvalid);
	
	FCAnalytics::Instance()->EndTimedEvent(s_sessionActiveAnalyticsHandle);
	s_sessionActiveAnalyticsHandle = kFCHandleInvalid;
	FCPersistentData::Instance()->Save();
	
	m_lua->CallFuncWithSig("FCApp.WillResignActive", false, "");

	FCNotification note;
	note.notification = kFCNotificationAppWillEnterBackground;
	FCNotificationManager::Instance()->SendNotification(note);
}

void FCApplication::DidEnterBackground()
{
	m_lua->CallFuncWithSig("FCApp.DidEnterBackground", false, "");
}

void FCApplication::WillEnterForeground()
{
	m_lua->CallFuncWithSig("FCApp.WillEnterForeground", false, "");

	FCNotification note;
	note.notification = kFCNotificationAppWillEnterForeground;
	FCNotificationManager::Instance()->SendNotification(note);
}

void FCApplication::DidBecomeActive()
{
	FCConnect::Instance()->Start();
	FCConnect::Instance()->EnableWithName("FCConnect");
	
	if( s_sessionActiveAnalyticsHandle != kFCHandleInvalid )
	{
		FCAnalytics::Instance()->DiscardTimedEvent( kFCHandleInvalid );
		FC_WARNING("Analytics playSessionTime started twice - don't know why");
	}
	
	s_sessionActiveAnalyticsHandle = FCAnalytics::Instance()->BeginTimedEvent("playSessionTime");
	
	m_lua->CallFuncWithSig("FCApp.DidBecomeActive", false, "");
}

void FCApplication::WillTerminate()
{
	m_lua->CallFuncWithSig("FCApp.WillTerminate", false, "");
	
	FCNotification note;
	note.notification = kFCNotificationAppWillBeTerminated;
	FCNotificationManager::Instance()->SendNotification(note);
}

bool FCApplication::ShouldAutorotateToInterfaceOrientation( FCInterfaceOrientation orient )
{
	bool ret = true;
	
	switch (orient) {
		case kFCInterfaceOrientation_Landscape:
			FCLua::Instance()->CoreVM()->CallFuncWithSig("FCApp.SupportsLandscape", false, ">b", &ret);
			break;
		case kFCInterfaceOrientation_Portrait:
			FCLua::Instance()->CoreVM()->CallFuncWithSig("FCApp.SupportsPortrait", false, ">b", &ret);
			break;
	}
	return ret;
}

void FCApplication::SetUpdateFrequency(int freq)
{
	FC_HALT;
}

void FCApplication::ShowExternalLeaderboard()
{
	FC_HALT;
}

void FCApplication::ShowStatusBar( bool visible )
{
	FC_HALT;
}

void FCApplication::SetBackgroundColor(FCColor4f &color)
{
	m_backgroundColor = color;
}

FCVector2f FCApplication::MainViewSize()
{
	FC_HALT;
	return FCVector2f( 0.0f, 0.0f );
}

void FCApplication::LaunchExternalURL( std::string url )
{
	FC_HALT;
}
