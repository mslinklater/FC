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

#import "FCAudioManager_apple.h"
#import "FCAudioListener_apple.h"
#import "FCAudioBuffer_apple.h"
#import "FCAudioSource_apple.h"
#import "FCActorSystem.h"

#import "FCLua.h"
#include "Shared/Physics/FCPhysics.h"

void plt_FCAudio_PlayMusic( std::string name );
void plt_FCAudio_SetMusicVolume( float vol );
void plt_FCAudio_SetSFXVolume( float vol );
void plt_FCAudio_SetMusicFinishedCallback( std::string name );
void plt_FCAudio_PauseMusic();
void plt_FCAudio_ResumeMusic();
void plt_FCAudio_StopMusic();
void plt_FCAudio_DeleteBuffer( FCHandle h );
FCHandle plt_FCAudio_LoadSimpleSound( std::string name );
void plt_FCAudio_UnloadSimpleSound( FCHandle h );
void plt_FCAudio_PlaySimpleSound( FCHandle h );
void plt_FCAudio_SubscribeToPhysics2D();
void plt_FCAudio_UnsubscribeToPhysics2D();
FCHandle plt_FCAudio_CreateBufferWithFile( std::string name );
void plt_FCAudio_AddCollisionTypeHandler( std::string type1, std::string type2, std::string func );
void plt_FCAudio_RemoveCollisionTypeHandler( std::string type1, std::string type2 );
FCHandle plt_FCAudio_PrepareSourceWithBuffer( FCHandle h, bool vital );
void plt_FCAudio_SourceSetVolume( FCHandle h, float vol );
void plt_FCAudio_SourcePlay( FCHandle h );
void plt_FCAudio_SourceStop( FCHandle h );
void plt_FCAudio_SourceLooping( FCHandle h, bool looping );
void plt_FCAudio_SourcePosition( FCHandle h, float x, float y, float z );
void plt_FCAudio_SourcePitch( FCHandle h, float pitch );

void plt_FCAudio_PlayMusic( std::string name )
{
	NSString* namestring = [NSString stringWithUTF8String:name.c_str()];
	[[FCAudioManager_apple instance] playMusic:namestring];
}

void plt_FCAudio_SetMusicVolume( float vol )
{
	[[FCAudioManager_apple instance] setMusicVolume:vol];
}

void plt_FCAudio_SetSFXVolume( float vol )
{
	[[FCAudioManager_apple instance] setSfxVolume:vol];
}

void plt_FCAudio_SetMusicFinishedCallback( std::string name )
{
	NSString* namestring = [NSString stringWithUTF8String:name.c_str()];
	[[FCAudioManager_apple instance] setMusicFinishedLuaCallback:namestring];
}

void plt_FCAudio_PauseMusic()
{
	[[FCAudioManager_apple instance] pauseMusic];
}

void plt_FCAudio_ResumeMusic()
{
	[[FCAudioManager_apple instance] resumeMusic];
}

void plt_FCAudio_StopMusic()
{
	[[FCAudioManager_apple instance] stopMusic];
}

void plt_FCAudio_DeleteBuffer( FCHandle h )
{
	[[FCAudioManager_apple instance] deleteBuffer:h];
}

FCHandle plt_FCAudio_LoadSimpleSound( std::string name )
{
	NSString* namestring = [NSString stringWithUTF8String:name.c_str()];
	return [[FCAudioManager_apple instance] loadSimpleSound:namestring];
}

void plt_FCAudio_UnloadSimpleSound( FCHandle h )
{
	[[FCAudioManager_apple instance] unloadSimpleSound:h];
}

void plt_FCAudio_PlaySimpleSound( FCHandle h )
{
	[[FCAudioManager_apple instance] playSimpleSound:h];
}

void plt_FCAudio_SubscribeToPhysics2D()
{
	[[FCAudioManager_apple instance] subscribeToPhysics2D];
}

void plt_FCAudio_UnsubscribeToPhysics2D()
{
	[[FCAudioManager_apple instance] unsubscribeFromPhysics2D];
}

FCHandle plt_FCAudio_CreateBufferWithFile( std::string name )
{
	NSString* namestring = [NSString stringWithUTF8String:name.c_str()];
	
	return [[FCAudioManager_apple instance] createBufferWithFile:namestring];
}

void plt_FCAudio_AddCollisionTypeHandler( std::string type1, std::string type2, std::string func )
{
	NSString* type1string = [NSString stringWithUTF8String:type1.c_str()];
	NSString* type2string = [NSString stringWithUTF8String:type2.c_str()];
	NSString* funcstring = [NSString stringWithUTF8String:func.c_str()];
	[[FCAudioManager_apple instance] addCollisionTypeHanderFor:type1string andType:type2string luaFunc:funcstring];
}

void plt_FCAudio_RemoveCollisionTypeHandler( std::string type1, std::string type2 )
{
	NSString* type1string = [NSString stringWithUTF8String:type1.c_str()];
	NSString* type2string = [NSString stringWithUTF8String:type2.c_str()];
	[[FCAudioManager_apple instance] removeCollisionTypeHanderFor:type1string andType:type2string];
}

FCHandle plt_FCAudio_PrepareSourceWithBuffer( FCHandle h, bool vital )
{
	return [[FCAudioManager_apple instance] prepareSourceWithBuffer:h vital:vital];
}

void plt_FCAudio_SourceSetVolume( FCHandle h, float vol )
{
	FCAudioSource_apple* source = [[FCAudioManager_apple instance].activeSources objectForKey:[NSNumber numberWithInt:h]];
	
	FC_ASSERT(source);
	
	source.volume = vol;
}

void plt_FCAudio_SourcePlay( FCHandle h )
{
	FCAudioSource_apple* source = [[FCAudioManager_apple instance].activeSources objectForKey:[NSNumber numberWithInt:h]];
	
	FC_ASSERT(source);
	
	[source play];
}

void plt_FCAudio_SourceStop( FCHandle h )
{
	FCAudioSource_apple* source = [[FCAudioManager_apple instance].activeSources objectForKey:[NSNumber numberWithInt:h]];
	
	FC_ASSERT(source);
	
	[source stop];
}

void plt_FCAudio_SourceLooping( FCHandle h, bool looping )
{
	FCAudioSource_apple* source = [[FCAudioManager_apple instance].activeSources objectForKey:[NSNumber numberWithInt:h]];
	
	FC_ASSERT(source);
	
	source.looping = looping;
}

void plt_FCAudio_SourcePosition( FCHandle h, float x, float y, float z )
{
	FCAudioSource_apple* source = [[FCAudioManager_apple instance].activeSources objectForKey:[NSNumber numberWithInt:h]];
	
	FCVector3f pos( x, y, z );
	
	source.position = pos;
}

void plt_FCAudio_SourcePitch( FCHandle h, float pitch )
{	
	FCAudioSource_apple* source = [[FCAudioManager_apple instance].activeSources objectForKey:[NSNumber numberWithInt:h]];
	
	source.pitch = pitch;
}

// load sample
// move listener

static void InterruptionListener(	void *	inClientData,
						  UInt32	inInterruptionState)
{
	NSLog(@"interruptionListener");
}

static void RouteChangeListener(	void *                  inClientData,
									AudioSessionPropertyID	inID,
									UInt32					inDataSize,
									const void *            inData)
{
	NSLog(@"RouteChangeListener");
}

static void CollisionSubscriber(tCollisionMap& collisions)
{
	for (tCollisionMapIter i = collisions.begin(); i != collisions.end(); ++i) 
	{
		CollisionInfo* pCollisionInfo = &(i->second);
		
		NSDictionary* actorHandleDictionary = [FCActorSystem instance].actorHandleDictionary;
		
		id obj1 = [actorHandleDictionary objectForKey:[NSNumber numberWithInt:pCollisionInfo->hActor1]];
		id obj2 = [actorHandleDictionary objectForKey:[NSNumber numberWithInt:pCollisionInfo->hActor2]];
		
		NSString* key = [NSString stringWithFormat:@"%@%@", [obj1 class], [obj2 class]];

		NSString* luaFunc = [[FCAudioManager_apple instance].collisionTypeHandlers valueForKey:key];
		
		if( luaFunc )
		{
			FCLua::Instance()->CoreVM()->CallFuncWithSig([luaFunc UTF8String], true, "iiffff>",
				pCollisionInfo->hActor1,
				pCollisionInfo->hActor2,
				pCollisionInfo->x,
				pCollisionInfo->y,
				pCollisionInfo->z,
				pCollisionInfo->velocity);
		}
		else 
		{
#if defined (DEBUG)
//			NSLog(@"Unhandled %@", key);
#endif
			// unhandled by specific, so try the objects themselves ?
		}
	}
}

@implementation FCAudioManager_apple

@synthesize device = _device;
@synthesize context = _context;

@synthesize iPodIsPlaying = _iPodIsPlaying;
@synthesize bgPlayer = _bgPlayer;
@synthesize listener = _listener;
@synthesize activeSources = _activeSources;
@synthesize buffers = _buffers;
@synthesize simpleSounds = _simpleSounds;
@synthesize activeSimpleSounds = _activeSimpleSounds;
@synthesize musicVolume = _musicVolume;
@synthesize musicFinishedLuaCallback = _musicFinishedLuaCallback;
@synthesize sfxVolume = _sfxVolume;
@synthesize collisionTypeHandlers = _collisionTypeHandlers;

+(FCAudioManager_apple*)instance
{
	static FCAudioManager_apple* pInstance;
	if (!pInstance) {
		pInstance = [[FCAudioManager_apple alloc] init];
	}
	return pInstance;
}

+(void)checkALError
{
	ALenum error = AL_NO_ERROR;
	
	if((error = alGetError()) != AL_NO_ERROR) 
	{
		switch (error) {
			case AL_INVALID_NAME:
				FC_ASSERT_MSG(0, "OpenAL: Invalid name");
				break;
			case AL_INVALID_ENUM:
				FC_ASSERT_MSG(0, "OpenAL: Invalid enum");
				break;
			case AL_INVALID_VALUE:
				FC_ASSERT_MSG(0, "OpenAL: Invalid value");
				break;
			case AL_INVALID_OPERATION:
				FC_ASSERT_MSG(0, "OpenAL: Invalid operation");
				break;
			case AL_OUT_OF_MEMORY:
				FC_ASSERT_MSG(0, "OpenAL: Out of memory");
				break;
				
			default:
				NSLog(@"%@", [FCAudioManager_apple instance].activeSources);
				NSString* string = [NSString stringWithFormat:@"Unknown AL error %d", error];
				FC_LOG( [string UTF8String] );
				break;
		}
	}
}

-(id)init
{
	self = [super init];
	if (self) {
		
		_listener = [[FCAudioListener_apple alloc] init];
		_activeSources = [NSMutableDictionary dictionary];
		_buffers = [NSMutableDictionary dictionary];
		_simpleSounds = [NSMutableDictionary dictionary];
		_activeSimpleSounds = [NSMutableArray array];
		_collisionTypeHandlers = [NSMutableDictionary dictionary];
		
		_musicVolume = 0.0f;
		_sfxVolume = 0.0f;
		
		// audio session stuff
		
		OSStatus result = AudioSessionInitialize(NULL, NULL, InterruptionListener, (__bridge void*)self);		
		FC_ASSERT( result == 0 );
		
		UInt32 size = sizeof(_iPodIsPlaying);
		result = AudioSessionGetProperty(kAudioSessionProperty_OtherAudioIsPlaying, &size, &_iPodIsPlaying);
		FC_ASSERT( result == 0 );
		
		// if the iPod is playing, use the ambient category to mix with it
		// otherwise, use solo ambient to get the hardware for playing the app background track
		UInt32 category;
		
		if (_iPodIsPlaying)
			category = kAudioSessionCategory_AmbientSound;
		else
			category = kAudioSessionCategory_SoloAmbientSound;

#if TARGET_IPHONE_SIMULATOR
		AudioSessionSetProperty(kAudioSessionProperty_AudioCategory, sizeof(category), &category);
#else
		result = AudioSessionSetProperty(kAudioSessionProperty_AudioCategory, sizeof(category), &category);
		FC_ASSERT( result == 0 );
#endif
		
		result = AudioSessionAddPropertyListener(kAudioSessionProperty_AudioRouteChange, RouteChangeListener, (__bridge void*)self);
		FC_ASSERT( result == 0 );
		
		result = AudioSessionSetActive(true);
		FC_ASSERT( result == 0 );
		
		alGetError();
		
		_device = alcOpenDevice( NULL );
		_context = alcCreateContext( _device, 0 );
		alcMakeContextCurrent( _context );
		

	}
	return self;
}

-(void)dealloc
{
	FCPhysics::Instance()->TwoD()->ContactListener()->RemoveSubscriber(CollisionSubscriber);
	alcDestroyContext(_context);
    alcCloseDevice(_device);
}

-(void)setMusicVolume:(float)musicVolume
{
	_musicVolume = musicVolume;
	[_bgPlayer setVolume:_musicVolume];
}

-(void)setSfxVolume:(float)sfxVolume
{
	_sfxVolume = sfxVolume;
	
	// go through simple effects and set the volume
}

-(void)playMusic:(NSString*)name
{
	NSString* path = [[NSBundle mainBundle] pathForResource:name ofType:@"m4a"];
	
	FC_ASSERT(path);
	
	NSURL* url = [NSURL fileURLWithPath:path];
	
	FC_ASSERT(url);
	
	NSError* error = nil;
	_bgPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
	_bgPlayer.delegate = self;
	[_bgPlayer play];
	_bgPlayer.volume = _musicVolume;
}

-(void)pauseMusic
{
	[_bgPlayer pause];
}

-(void)resumeMusic
{
	[_bgPlayer play];
}

-(void)stopMusic
{
	[_bgPlayer stop];
}

-(FCHandle)loadSimpleSound:(NSString*)name
{
	FCHandle h = NewFCHandle();
	
	NSString* path = [[NSBundle mainBundle] pathForResource:name ofType:@"m4a"];

	FC_ASSERT(path);
	
	NSURL* url = [NSURL fileURLWithPath:path];

	NSData* data = [NSData dataWithContentsOfURL:url];

	[_simpleSounds setObject:data forKey:[NSNumber numberWithInt:h]];

	return h;
}

-(void)unloadSimpleSound:(FCHandle)handle
{
	FC_ASSERT([_simpleSounds objectForKey:[NSNumber numberWithInt:handle]]);
	
	[_simpleSounds removeObjectForKey:[NSNumber numberWithInt:handle]];
}

-(void)playSimpleSound:(FCHandle)handle
{
	NSData* data = [_simpleSounds objectForKey:[NSNumber numberWithInt:handle]];
	NSError* error = nil;
	AVAudioPlayer* avPlayer = [[AVAudioPlayer alloc] initWithData:data error:&error];

	avPlayer.delegate = self;
	avPlayer.volume = _sfxVolume;
	[avPlayer play];
	[_activeSimpleSounds addObject:avPlayer];	
}

-(FCHandle)createBufferWithFile:(NSString *)filename
{
	FCHandle h = NewFCHandle();
	
	FCAudioBuffer_apple* buffer = [[FCAudioBuffer_apple alloc] initWithFilename:filename];
	[_buffers setObject:buffer forKey:[NSNumber numberWithInt:h]];
	
	return h;
}

-(void)deleteBuffer:(FCHandle)handle
{
	FC_ASSERT([_buffers objectForKey:[NSNumber numberWithInt:handle]]);
	[_buffers removeObjectForKey:[NSNumber numberWithInt:handle]];
}

-(FCHandle)prepareSourceWithBuffer:(FCHandle)hBuffer vital:(BOOL)vital
{
	// try to reuse an existing one first
	
	FCAudioBuffer_apple* buffer = [_buffers objectForKey:[NSNumber numberWithInt:hBuffer]];

	NSArray* sourceKeys = [_activeSources allKeys];
	
	for( NSNumber* key in sourceKeys )
	{
		FCAudioSource_apple* source = [_activeSources objectForKey:key];
		
		FC_ASSERT(source);
		
		if (source.stopped) 
		{
			[_activeSources removeObjectForKey:key];
		}
	}
	
	// all active sources are still playing, so create a new one
	
	int maxPlayingVoices;
	
	if (vital) {
		maxPlayingVoices = 30;
	} else {
		maxPlayingVoices = 24;
	}
	
	if ([_activeSources count] < maxPlayingVoices) 
	{
		FCAudioSource_apple* source = [[FCAudioSource_apple alloc] init];
		source.ALBufferHandle = buffer.ALHandle;
		
		FCHandle hSource = NewFCHandle();
		source.handle = hSource;
		
		[_activeSources setObject:source forKey:[NSNumber numberWithInt:hSource]];
		
		return hSource;
	}
	
	return 0;
}

-(void)addCollisionTypeHanderFor:(NSString*)type1 
						 andType:(NSString*)type2 
						 luaFunc:(NSString*)luaFunc
{
	NSString* key = [NSString stringWithFormat:@"%@%@", type1, type2];
	
	FC_ASSERT([_collisionTypeHandlers objectForKey:key] == nil);
	
	[_collisionTypeHandlers setValue:luaFunc forKey:key];
	
	if(![type1 isEqualToString:type2])
	{
		key = [NSString stringWithFormat:@"%@%@", type2, type1];	
		
		FC_ASSERT([_collisionTypeHandlers objectForKey:key] == nil);
		
		[_collisionTypeHandlers setValue:luaFunc forKey:key];		
	}
}

-(void)removeCollisionTypeHanderFor:(NSString*)type1 andType:(NSString*)type2
{
	NSString* key = [NSString stringWithFormat:@"%@%@", type1, type2];
	
	FC_ASSERT([_collisionTypeHandlers objectForKey:key]);

	[_collisionTypeHandlers removeObjectForKey:key];
	
	if(![type1 isEqualToString:type2])
	{
		key = [NSString stringWithFormat:@"%@%@", type2, type1];	

		FC_ASSERT([_collisionTypeHandlers objectForKey:key]);

		[_collisionTypeHandlers removeObjectForKey:key];
	}
}

-(void)subscribeToPhysics2D
{
	FCPhysics::Instance()->TwoD()->ContactListener()->AddSubscriber(CollisionSubscriber);
}

-(void)unsubscribeFromPhysics2D
{
	FCPhysics::Instance()->TwoD()->ContactListener()->RemoveSubscriber(CollisionSubscriber);
}

#pragma mark - AVAudioPlayerDelegate

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
	if (player == _bgPlayer)	// Music
	{
		if (_musicFinishedLuaCallback) 
		{
			FCLua::Instance()->CoreVM()->CallFuncWithSig([_musicFinishedLuaCallback UTF8String], false, ">");
		}
		return;
	}
	
	// Simple SFX
	
	[_activeSimpleSounds removeObject:player];
}

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error
{
	
}

- (void)audioPlayerBeginInterruption:(AVAudioPlayer *)player
{
	
}

- (void)audioPlayerEndInterruption:(AVAudioPlayer *)player
{
	
}

- (void)audioPlayerEndInterruption:(AVAudioPlayer *)player withFlags:(NSUInteger)flags
{
	
}

@end
