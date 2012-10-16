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

#ifndef CR2_FCPlatformInterface_h
#define CR2_FCPlatformInterface_h

#include "Shared/Core/FCTypes.h"

extern void plt_FCAudio_PlayMusic( const char* name );
extern void plt_FCAudio_SetMusicVolume( float vol );
extern void plt_FCAudio_SetSFXVolume( float vol );
extern void plt_FCAudio_SetMusicFinishedCallback( const char* name );
extern void plt_FCAudio_PauseMusic();
extern void plt_FCAudio_ResumeMusic();
extern void plt_FCAudio_StopMusic();
extern void plt_FCAudio_DeleteBuffer( FCHandle h );
extern FCHandle plt_FCAudio_LoadSimpleSound( const char* name );
extern void plt_FCAudio_UnloadSimpleSound( FCHandle h );
extern void plt_FCAudio_PlaySimpleSound( FCHandle h );
extern void plt_FCAudio_SubscribeToPhysics2D();
extern void plt_FCAudio_UnsubscribeToPhysics2D();
extern FCHandle plt_FCAudio_CreateBufferWithFile( const char* name );
extern void plt_FCAudio_AddCollisionTypeHandler( const char* type1, const char* type2, const char* func );
extern void plt_FCAudio_RemoveCollisionTypeHandler( const char* type1, const char* type2 );
extern FCHandle plt_FCAudio_PrepareSourceWithBuffer( FCHandle h, bool vital );
extern void plt_FCAudio_SourceSetVolume( FCHandle h, float vol );
extern void plt_FCAudio_SourcePlay( FCHandle h );
extern void plt_FCAudio_SourceStop( FCHandle h );
extern void plt_FCAudio_SourceLooping( FCHandle h, bool looping );
extern void plt_FCAudio_SourcePosition( FCHandle h, float x, float y, float z );
extern void plt_FCAudio_SourcePitch( FCHandle h, float pitch );

extern bool plt_FCConnect_Start();
extern bool plt_FCConnect_EnableWithName( const char* name );
extern void plt_FCConnect_Stop();
extern void plt_FCConnect_SendString( const char* s );

extern void plt_FCPerformanceCounter_New( void* instance );
extern void plt_FCPerformanceCounter_Delete( void* instance );
extern void plt_FCPerformanceCounter_Zero( void* instance );
extern double plt_FCPerformanceCounter_NanoValue( void* instance );

extern void plt_FCDevice_ColdProbe();
extern void plt_FCDevice_WarmProbe( uint32_t options );

extern void plt_FCHalt();
extern void plt_FCLog( const char* log );
extern void plt_FCWarning( const char* log );
extern void plt_FCFatal( const char* log );

extern const char* plt_FCFile_ApplicationBundlePathForPath( const char* filename );
extern const char* plt_FCFile_NormalPathForPath( const char* filename );
extern const char* plt_FCFile_DocumentsFolderPathForPath( const char* filename );

extern void plt_FCAds_ShowBanner( const char* key );
extern void plt_FCAds_HideBanner();

extern void		plt_FCAnalytics_RegisterEvent( const char* event );
extern void		plt_FCAnalytics_BeginTimedEvent( const char* event );
extern void		plt_FCAnalytics_EndTimedEvent( const char* event );

class FCApplication;

extern FCApplication* plt_FCApplication_Instance();

extern void plt_FCPersistentData_Load();
extern void plt_FCPersistentData_Save();
extern void plt_FCPersistentData_Clear();
extern void plt_FCPersistentData_Print();
extern void plt_FCPersistentData_SetValueForKey( const char* value, const char* key );
extern const char* plt_FCPersistentData_ValueForKey( const char* key );
extern void plt_FCPersistentData_ClearValueForKey( const char* key );

extern void plt_FCInput_SetTapSubscriberFunc( FCInputPlatformTapSubscriber func );
extern void plt_FCInput_AddTapToView( const char* viewName );
extern void plt_FCInput_RemoveTapFromView( const char* viewName );

// Twitter

extern bool plt_FCTwitter_CanTweet();
extern bool plt_FCTwitter_TweetWithText( const char* text );
extern bool plt_FCTwitter_AddHyperlink( const char* hyperlink );
extern void plt_FCTwitter_Send();

// Online Leaderboard

typedef void (*plt_FCOnlineLeaderboard_PostCallback)( unsigned int handle, bool success );

extern void plt_FCOnlineLeaderboard_Init( void );
extern void plt_FCOnlineLeaderboard_Show( void );
extern bool plt_FCOnlineLeaderboard_Available( void );
extern void plt_FCOnlineLeaderboard_PostScore(  const char* leaderboardName,
											  unsigned int score,
											  unsigned int handle,
											  plt_FCOnlineLeaderboard_PostCallback callback );

extern void plt_FCViewManager_SetScreenAspectRatio( float w, float h );
extern void plt_FCViewManager_SetViewText( const char* viewName, const char* text );
extern void plt_FCViewManager_SetViewTextColor( const char* viewName, FCColor4f color );
extern FCRect plt_FCViewManager_ViewFrame( const char* viewName );
extern FCRect plt_FCViewManager_FullFrame();
extern void plt_FCViewManager_SetViewFrame( const char* viewName, const FCRect& rect, float seconds );
extern void plt_FCViewManager_SetViewAlpha( const char* viewName, float alpha, float seconds );
extern void plt_FCViewManager_SetViewOnSelectLuaFunction( const char* viewName, const char* func );
extern void plt_FCViewManager_SetViewImage( const char* viewName, const char* image );
extern void plt_FCViewManager_SetViewURL( const char* viewName, const char* url );
extern void plt_FCViewManager_SetViewBackgroundColor( const char* viewName, const FCColor4f& color );
extern void plt_FCViewManager_CreateView( const char* viewName, const char* className, const char* parent );
extern void plt_FCViewManager_DestroyView( const char* viewName );
extern void plt_FCViewManager_SetViewPropertyInt( const char* viewName, const char* property, int32_t value );
extern void plt_FCViewManager_SetViewPropertyString( const char* viewName, const char* property, const char* value );

extern void plt_FCViewManager_SendViewToFront( const char* viewName );
extern void plt_FCViewManager_SendViewToBack( const char* viewName );
extern bool plt_FCViewManager_ViewExists( const char* viewName );

extern void plt_FCDebugDraw_2DLine( float x1, float y1, float x2, float y2 );

#endif
