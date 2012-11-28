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
#include "Shared/Framework/Ads/FCAds.h"
#include "Shared/Core/Debug/FCConnect.h"
#include "Shared/Framework/Analytics/FCAnalytics.h"
#include "Shared/Framework/Online/FCTwitter.h"
#include "Shared/Audio/FCAudioManager.h"
#include "Shared/Core/Device/FCDevice.h"
#include "Shared/Framework/FCPersistentData.h"
#include "Shared/Physics/FCPhysics.h"
#include "Shared/Framework/Actor/FCActorSystem.h"
#include "Shared/Framework/Online/FCOnlineLeaderboard.h"
#include "Shared/Framework/Online/FCOnlineAchievement.h"
#include "Shared/Framework/Store/FCStore.h"

#include "Shared/FCPlatformInterface.h"

static FCApplication* s_pInstance = 0;

static FCHandle	s_sessionActiveAnalyticsHandle = kFCHandleInvalid;



// Lua functions

static int lua_ShowStatusBar( lua_State* _state )
{
	FC_TRACE;
	FC_LUA_FUNCDEF("FCApplication.ShowStatusBar()");
	FC_LUA_ASSERT_NUMPARAMS(1);
	FC_LUA_ASSERT_TYPE(1, LUA_TBOOLEAN);
	
	bool visible = (lua_toboolean( _state, -1) != 0);

	s_pInstance->ShowStatusBar( visible );
	return 0;
}

static int lua_SetBackgroundColor( lua_State* _state )
{
	FC_TRACE;
	FC_LUA_FUNCDEF("FCApplication.SetBackgroundColor()");
	FC_LUA_ASSERT_NUMPARAMS(1);
	FC_LUA_ASSERT_TYPE(1, LUA_TTABLE);

	FCColor4f color;
	
	lua_getfield(_state, 1, "r");
	FC_LUA_ASSERT_TYPE(-1, LUA_TNUMBER);
	color.r = (float)lua_tonumber(_state, -1);
	lua_pop(_state, 1);
	
	lua_getfield(_state, 1, "g");
	FC_LUA_ASSERT_TYPE(-1, LUA_TNUMBER);
	color.g = (float)lua_tonumber(_state, -1);
	lua_pop(_state, 1);
	
	lua_getfield(_state, 1, "b");
	FC_LUA_ASSERT_TYPE(-1, LUA_TNUMBER);
	color.b = (float)lua_tonumber(_state, -1);
	lua_pop(_state, 1);
	
	lua_getfield(_state, 1, "a");
	FC_LUA_ASSERT_TYPE(-1, LUA_TNUMBER);
	color.a = (float)lua_tonumber(_state, -1);
	
	s_pInstance->SetBackgroundColor( color );
	
	return 0;
}

static int lua_ShowGameCenterLeaderboards( lua_State* _state )
{
	FC_TRACE;
	FC_LUA_FUNCDEF("FCApplication.ShowGameCenterLeaderboards()");
	FC_LUA_ASSERT_NUMPARAMS(0);

	s_pInstance->ShowExternalLeaderboard();

	return 0;
}

static int lua_LaunchExternalURL( lua_State* _state )
{
	FC_TRACE;
	FC_LUA_FUNCDEF("FCApplication.LaunchExternalURL()");
	FC_LUA_ASSERT_NUMPARAMS(1);
	FC_LUA_ASSERT_TYPE(1, LUA_TSTRING);

	s_pInstance->LaunchExternalURL( lua_tostring(_state, 1) );
	
	return 0;
}

static int lua_MainViewSize( lua_State* _state )
{
	FC_TRACE;
	FC_LUA_FUNCDEF("FCApplication.MainViewSize()");
	FC_LUA_ASSERT_NUMPARAMS(0);
	
	FCVector2f size = s_pInstance->MainViewSize();
	
	lua_pushnumber( _state, size.x );
	lua_pushnumber( _state, size.y );
	
	return 2;
}

static int lua_LoadLuaLayout( lua_State* _state )
{
	FC_TRACE;
	FC_LUA_FUNCDEF("FCApplication.LoadLuaLayout()");
	FC_LUA_ASSERT_NUMPARAMS(0);
	
	s_pInstance->LoadLuaLayout();
	
	return 0;
}

static int lua_LoadLuaLanguage( lua_State* _state )
{
	FC_TRACE;
	FC_LUA_FUNCDEF("FCApplication.LoadLuaLanguage()");
	FC_LUA_ASSERT_NUMPARAMS(0);
	
	s_pInstance->LoadLuaLanguage();
	
	return 0;
}

static int lua_PauseGame( lua_State* _state )
{
	FC_TRACE;
	FC_LUA_FUNCDEF("FCApplication.PauseGame()");
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
	FC_TRACE;
	FC_LUA_FUNCDEF("FCApplication.SetUpdateFrequency()");
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
	FC_TRACE;
}

FCApplication::~FCApplication()
{
	FC_TRACE;
	FC_HALT;
}

void FCApplication::ColdBoot( FCApplicationColdBootParams& params )
{
	FC_TRACE;
	m_delegate = params.pDelegate;
	m_performanceCounter = FCPerformanceCounterRef( new FCPerformanceCounter );
	m_lua = FCLuaVMRef( FCLua::Instance()->CoreVM() );
	
	m_lua->CreateGlobalTable("FCApp");
	m_lua->RegisterCFunction(lua_ShowStatusBar, "FCApp.ShowStatusBar");
	m_lua->RegisterCFunction(lua_SetBackgroundColor, "FCApp.SetBackgroundColor");
	m_lua->RegisterCFunction(lua_ShowGameCenterLeaderboards, "FCApp.ShowGameCenterLeaderboards");
	m_lua->RegisterCFunction(lua_LaunchExternalURL, "FCApp.LaunchExternalURL");
	m_lua->RegisterCFunction(lua_MainViewSize, "FCApp.MainViewSize");
	m_lua->RegisterCFunction(lua_PauseGame, "FCApp.Pause");
	m_lua->RegisterCFunction(lua_SetUpdateFrequency, "FCApp.SetUpdateFrequency");	
	m_lua->RegisterCFunction(lua_LoadLuaLayout, "FCApp.LoadLuaLayout");
	m_lua->RegisterCFunction(lua_LoadLuaLanguage, "FCApp.LoadLuaLanguage");
	m_lua->SetGlobalBool("FCApp.paused", false);

	FCPhaseManager::Instance();
	FCViewManager::Instance();
	FCBuild::Instance();
	
#if defined(FC_ADS)
	FCAds::Instance();
#endif
	
	FCAnalytics::Instance();
    FCOnlineLeaderboard::Instance();
	
	FCTwitter::Instance();
	FCAudioManager::Instance();
	FCDevice::Instance()->ColdProbe();
	
	FCDevice::Instance()->WarmProbe( params.allowableOrientationsMask );
	FCStore::Instance()->WarmBoot();
	
	FCPersistentData::Instance()->Load();
	FCPhysics::Instance();
	FCActorSystem::Instance();
	FCOnlineAchievement::Instance();
	m_lua->LoadScript("main");
	m_lua->CallFuncWithSig("FCApp.ColdBoot", true, "");
	WarmBoot();
}

void FCApplication::WarmBoot()
{
	FC_TRACE;
	m_delegate->InitializeSystems();
	m_delegate->RegisterPhasesWithManager( FCPhaseManager::Instance() );
	m_lua->CallFuncWithSig("FCApp.WarmBoot", true, "");
	
	// Layout
	
	
	// Languages
	

}

void FCApplication::Shutdown()
{
	FC_TRACE;
	FC_HALT;
}

void FCApplication::LoadLuaLanguage()
{
	m_lua->LoadScriptOptional("Languages/en");	// default is English
	
	std::string locale = FCDevice::Instance()->GetCap(kFCDeviceLocale);
	
	if (locale != "en") {
		m_lua->LoadScriptOptional("Languages/" + locale);	// override with translations
	}
}

void FCApplication::LoadLuaLayout()
{
	m_lua->LoadScriptOptional("Layout/layout_global");
	
	std::string xString = FCDevice::Instance()->GetCap(kFCDeviceDisplayLogicalXRes);
	int32_t x = FCIntFromString( xString );
	std::string yString = FCDevice::Instance()->GetCap(kFCDeviceDisplayLogicalYRes);
	int32_t y = FCIntFromString( yString );
	
	float aspect = (float)y / (float)x;
	float aspect4by3 = 4.0f / 3.0f;
	float aspect3by2 = 3.0f / 2.0f;
	float aspect16by9 = 16.0f / 9.0f;
	
	float diff4by3 = fabsf(aspect - aspect4by3);
	float diff3by2 = fabsf(aspect - aspect3by2);
	float diff16by9 = fabsf(aspect - aspect16by9);
	
	if ((diff4by3 < diff3by2) && (diff4by3 < diff16by9)) {
		m_lua->LoadScriptOptional("Layout/layout_4by3");
	}
	if ((diff3by2 < diff4by3) && (diff3by2 < diff16by9)) {
		m_lua->LoadScriptOptional("Layout/layout_3by2");
	}
	if ((diff16by9 < diff3by2) && (diff16by9 < diff4by3)) {
		m_lua->LoadScriptOptional("Layout/layout_16by9");
	}
}

void FCApplication::Update()
{
	FC_TRACE;
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
	FC_TRACE;
	m_updateSubscribers.insert( func );
}

void FCApplication::RemoveUpdateSubscriber(FCApplicationUpdateFuncPtr func)
{
	FC_TRACE;
	m_updateSubscribers.erase( func );
}

void FCApplication::Pause()
{
	FC_TRACE;
	m_paused = true;
	m_lua->SetGlobalBool("FCApp.paused", true);
}

void FCApplication::Resume()
{
	FC_TRACE;
	m_paused = false;
	m_lua->SetGlobalBool("FCApp.paused", false);
}

void FCApplication::RegisterExceptionHandler()
{
	FC_TRACE;
	FC_HALT;
}

void FCApplication::SetAnalyticsID( std::string ident )
{
	FC_TRACE;
	FC_HALT;
}

void FCApplication::SetTestFlightID( std::string ident )
{
	FC_TRACE;
	FC_HALT;
}

void FCApplication::WillResignActive()
{
	FC_TRACE;
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
	FC_TRACE;
	m_lua->CallFuncWithSig("FCApp.DidEnterBackground", false, "");
}

void FCApplication::WillEnterForeground()
{
	FC_TRACE;
	m_lua->CallFuncWithSig("FCApp.WillEnterForeground", false, "");

	FCNotification note;
	note.notification = kFCNotificationAppWillEnterForeground;
	FCNotificationManager::Instance()->SendNotification(note);
}

void FCApplication::DidBecomeActive()
{
	FC_TRACE;
#if defined(FC_DEBUG)
	FCConnect::Instance()->Start();
	FCConnect::Instance()->EnableWithName("FCConnect");
#endif
    
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
	FC_TRACE;
	m_lua->CallFuncWithSig("FCApp.WillTerminate", false, "");
	
	FCNotification note;
	note.notification = kFCNotificationAppWillBeTerminated;
	FCNotificationManager::Instance()->SendNotification(note);
}

bool FCApplication::ShouldAutorotateToInterfaceOrientation( FCInterfaceOrientation orient )
{
	FC_TRACE;
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
	FC_TRACE;
	FC_HALT;
}

void FCApplication::ShowExternalLeaderboard()
{
	FC_TRACE;
	FC_HALT;
}

void FCApplication::ShowStatusBar( bool visible )
{
	FC_TRACE;
	FC_HALT;
}

void FCApplication::SetBackgroundColor(FCColor4f &color)
{
	FC_TRACE;
	m_backgroundColor = color;
}

FCVector2f FCApplication::MainViewSize()
{
	FC_TRACE;
	FC_HALT;
	return FCVector2f( 0.0f, 0.0f );
}

void FCApplication::LaunchExternalURL( std::string url )
{
	FC_TRACE;
	FC_HALT;
}
