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

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

#import <OpenAL/al.h>
#import <OpenAL/alc.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AudioToolbox/ExtendedAudioFile.h>

#import "FCCore.h"

#if defined (FC_DEBUG)
#define AL_CHECK [FCAudioManager_apple checkALError]
#else
#define AL_CHECK
#endif

@class FCAudioListener_apple;
@class FCAudioSource_apple;

@interface FCAudioManager_apple : NSObject <AVAudioPlayerDelegate> {
	ALCdevice*	_device;
	ALCcontext*	_context;

	UInt32					_iPodIsPlaying;
	AVAudioPlayer*			_bgPlayer;

	FCAudioListener_apple*	_listener;
	NSMutableDictionary*	_activeSources;
	NSMutableDictionary*	_buffers;
	NSMutableDictionary*	_simpleSounds;
	NSMutableArray*			_activeSimpleSounds;
	NSMutableDictionary*	_collisionTypeHandlers;
	
	float					_musicVolume;
	NSString*				_musicFinishedLuaCallback;

	float					_sfxVolume;
}
@property(nonatomic, readonly) ALCdevice* device;
@property(nonatomic, readonly) ALCcontext* context;

@property(nonatomic, readonly) UInt32	iPodIsPlaying;
@property(nonatomic, strong) AVAudioPlayer* bgPlayer;

@property(nonatomic, strong) FCAudioListener_apple* listener;
@property(nonatomic, strong) NSMutableDictionary* activeSources;
@property(nonatomic, strong) NSMutableDictionary* buffers;
@property(nonatomic, strong) NSMutableDictionary* simpleSounds;
@property(nonatomic, strong) NSMutableArray* activeSimpleSounds;
@property(nonatomic, strong) NSMutableDictionary* collisionTypeHandlers;

@property(nonatomic) float musicVolume;
@property(nonatomic, strong) NSString* musicFinishedLuaCallback;

@property(nonatomic) float sfxVolume;

+(FCAudioManager_apple*)instance;
+(void)checkALError;

-(FCHandle)loadSimpleSound:(NSString*)name;
-(void)unloadSimpleSound:(FCHandle)handle;
-(void)playSimpleSound:(FCHandle)handle;

-(FCHandle)createBufferWithFile:(NSString*)filename;
-(void)deleteBuffer:(FCHandle)handle;

-(FCHandle)prepareSourceWithBuffer:(FCHandle)hBuffer vital:(BOOL)vital;

-(void)playMusic:(NSString*)name;
-(void)pauseMusic;
-(void)resumeMusic;
-(void)stopMusic;

-(void)addCollisionTypeHanderFor:(NSString*)type1 andType:(NSString*)type2 luaFunc:(NSString*)luaFunc;
-(void)removeCollisionTypeHanderFor:(NSString*)type1 andType:(NSString*)type2;

-(void)subscribeToPhysics2D;
-(void)unsubscribeFromPhysics2D;

@end
