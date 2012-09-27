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
 
 #include <jni.h>
 #include <stdio.h>
 #include "Shared/Core/FCCore.h"
 #include "Shared/FCPlatformInterface.h"

// First the JNI bridge calls

extern "C" {

JNIEXPORT jstring JNICALL
Java_com_curlyrocket_cr2_cr2_stringFromJNI2( JNIEnv* env, jobject thiz )
{
	return env->NewStringUTF( "Test 2 passed!" );
}

}
void MyTest()
{
}

extern "C" {

jint JNI_OnLoad(JavaVM* vm, void* reserved);

}

jint JNI_OnLoad(JavaVM* vm, void* reserved)
{
	printf("OnLoad");
}

// Now the impl for the platform calls

void plt_FCAudio_PlayMusic( const char* name )
{
	FC_HALT;
}

void plt_FCAudio_SetMusicVolume( float vol )
{
	FC_HALT;
}

void plt_FCAudio_SetSFXVolume( float vol )
{
	FC_HALT;
}

void plt_FCAudio_SetMusicFinishedCallback( const char* name )
{
	FC_HALT;
}

void plt_FCAudio_PauseMusic()
{
	FC_HALT;
}

void plt_FCAudio_ResumeMusic()
{
	FC_HALT;
}

void plt_FCAudio_StopMusic()
{
	FC_HALT;
}

void plt_FCAudio_DeleteBuffer( FCHandle h )
{
	FC_HALT;
}

FCHandle plt_FCAudio_LoadSimpleSound( const char* name )
{
	FC_HALT;
	return 0;
}

void plt_FCAudio_UnloadSimpleSound( FCHandle h )
{
	FC_HALT;
}

void plt_FCAudio_PlaySimpleSound( FCHandle h )
{
	FC_HALT;
}

void plt_FCAudio_SubscribeToPhysics2D()
{
	FC_HALT;
}

void plt_FCAudio_UnsubscribeToPhysics2D()
{
	FC_HALT;
}

FCHandle plt_FCAudio_CreateBufferWithFile( const char* name )
{
	FC_HALT;
	return 0;
}

void plt_FCAudio_AddCollisionTypeHandler( const char* type1, const char* type2, const char* func )
{
	FC_HALT;
}

void plt_FCAudio_RemoveCollisionTypeHandler( const char* type1, const char* type2 )
{
	FC_HALT;
}

FCHandle plt_FCAudio_PrepareSourceWithBuffer( FCHandle h, bool vital )
{
	FC_HALT;
	return 0;
}

void plt_FCAudio_SourceSetVolume( FCHandle h, float vol )
{
	FC_HALT;
}

void plt_FCAudio_SourcePlay( FCHandle h )
{
	FC_HALT;
}

void plt_FCAudio_SourceStop( FCHandle h )
{
	FC_HALT;
}

void plt_FCAudio_SourceLooping( FCHandle h, bool looping )
{
	FC_HALT;
}

void plt_FCAudio_SourcePosition( FCHandle h, float x, float y, float z )
{
	FC_HALT;
}

void plt_FCAudio_SourcePitch( FCHandle h, float pitch )
{
	FC_HALT;
}

bool plt_FCConnect_Start()
{
	FC_HALT;
}

bool plt_FCConnect_EnableWithName( std::string name )
{
	FC_HALT;
	return false;
}

void plt_FCConnect_Stop()
{
	FC_HALT;
}

void plt_FCConnect_SendString( std::string s )
{
	FC_HALT;
}

void plt_FCPerformanceCounter_New( void* instance )
{
	FC_HALT;
}

void plt_FCPerformanceCounter_Delete( void* instance )
{
	FC_HALT;
}

void plt_FCPerformanceCounter_Zero( void* instance )
{
	FC_HALT;
}

double plt_FCPerformanceCounter_NanoValue( void* instance )
{
	FC_HALT;
	return 0.0;
}


void plt_FCDevice_ColdProbe()
{
	FC_HALT;
}

void plt_FCDevice_WarmProbe( uint32_t options )
{
	FC_HALT;
}


void plt_FCHalt()
{
	FC_HALT;
}

void plt_FCLog( std::string log )
{
	FC_HALT;
}

void plt_FCWarning( std::string log )
{
	FC_HALT;
}

void plt_FCFatal( std::string log )
{
	FC_HALT;
}

std::string plt_FCFile_ApplicationBundlePathForPath( std::string filename )
{
	FC_HALT;
	return "";
}

std::string plt_FCFile_NormalPathForPath( std::string filename )
{
	FC_HALT;
	return "";
}

std::string plt_FCFile_DocumentsFolderPathForPath( std::string filename )
{
	FC_HALT;
	return "";
}

void plt_FCAds_ShowBanner( const char* key )
{
	FC_HALT;
}

void plt_FCAds_HideBanner()
{
	FC_HALT;
}

void		plt_FCAnalytics_RegisterEvent( const char* event )
{
	FC_HALT;
}

void		plt_FCAnalytics_BeginTimedEvent( const char* event )
{
	FC_HALT;
}

void		plt_FCAnalytics_EndTimedEvent( const char* event )
{
	FC_HALT;
}

FCApplication* plt_FCApplication_Instance()
{
	FC_HALT;
	return 0;
}

void plt_FCPersistentData_Load()
{
	FC_HALT;
}

void plt_FCPersistentData_Save()
{
	FC_HALT;
}

void plt_FCPersistentData_Clear()
{
	FC_HALT;
}

void plt_FCPersistentData_Print()
{
	FC_HALT;
}

void plt_FCPersistentData_SetValueForKey( std::string value, std::string key )
{
	FC_HALT;
}

std::string plt_FCPersistentData_ValueForKey( std::string key )
{
	FC_HALT;
	return "";
}

void plt_FCPersistentData_ClearValueForKey( std::string key )
{
	FC_HALT;
}

void plt_FCInput_SetTapSubscriberFunc( FCInputPlatformTapSubscriber func )
{
	FC_HALT;
}

void plt_FCInput_AddTapToView( const char* viewName )
{
	FC_HALT;
}

void plt_FCInput_RemoveTapFromView( const char* viewName )
{
	FC_HALT;
}

bool plt_FCTwitter_CanTweet()
{
	FC_HALT;
	return false;
}

bool plt_FCTwitter_TweetWithText( const char* text )
{
	FC_HALT;
	return false;
}

bool plt_FCTwitter_AddHyperlink( const char* hyperlink )
{
	FC_HALT;
	return false;
}

void plt_FCTwitter_Send()
{
	FC_HALT;
}

void plt_FCOnlineLeaderboard_Init( void )
{
	FC_HALT;
}

void plt_FCOnlineLeaderboard_Show( void )
{
	FC_HALT;
}

bool plt_FCOnlineLeaderboard_Available( void )
{
	FC_HALT;
	return false;
}

void plt_FCOnlineLeaderboard_PostScore(  const char* leaderboardName,
											  unsigned int score,
											  unsigned int handle,
											  plt_FCOnlineLeaderboard_PostCallback callback )
{
	FC_HALT;
}

void plt_FCViewManager_SetScreenAspectRatio( float w, float h )
{
	FC_HALT;
}

void plt_FCViewManager_SetViewText( const char* viewName, const char* text )
{
	FC_HALT;
}

void plt_FCViewManager_SetViewTextColor( const char* viewName, FCColor4f color )
{
	FC_HALT;
}

FCRect plt_FCViewManager_ViewFrame( const char* viewName )
{
	FC_HALT;
	return FCRect( 0.0f, 0.0f, 0.0f, 0.0f );
}

FCRect plt_FCViewManager_FullFrame()
{
	FC_HALT;
	return FCRect( 0.0f, 0.0f, 0.0f, 0.0f );
}

void plt_FCViewManager_SetViewFrame( const char* viewName, const FCRect& rect, float seconds )
{
	FC_HALT;
}

void plt_FCViewManager_SetViewAlpha( const char* viewName, float alpha, float seconds )
{
	FC_HALT;
}

void plt_FCViewManager_SetViewOnSelectLuaFunction( const char* viewName, const char* func )
{
	FC_HALT;
}

void plt_FCViewManager_SetViewImage( const char* viewName, const char* image )
{
	FC_HALT;
}

void plt_FCViewManager_SetViewURL( const char* viewName, const char* url )
{
	FC_HALT;
}

void plt_FCViewManager_SetViewBackgroundColor( const char* viewName, const FCColor4f& color )
{
	FC_HALT;
}

void plt_FCViewManager_CreateView( const char* viewName, const char* className, const char* parent )
{
	FC_HALT;
}

void plt_FCViewManager_DestroyView( const char* viewName )
{
	FC_HALT;
}

void plt_FCViewManager_SetViewPropertyInt( const char* viewName, const char* property, int32_t value )
{
	FC_HALT;
}

void plt_FCViewManager_SetViewPropertyString( const char* viewName, const char* property, const char* value )
{
	FC_HALT;
}


void plt_FCViewManager_SendViewToFront( const char* viewName )
{
	FC_HALT;
}

void plt_FCViewManager_SendViewToBack( const char* viewName )
{
	FC_HALT;
}

bool plt_FCViewManager_ViewExists( const char* viewName )
{
	FC_HALT;
	return false;
}


void plt_FCDebugDraw_2DLine( float x1, float y1, float x2, float y2 );


