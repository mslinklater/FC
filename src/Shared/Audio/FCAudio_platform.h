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

#ifndef CR2_FCAudio_platform_h
#define CR2_FCAudio_platform_h

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

#endif
