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

#import "FCAudioManager.h"
#import "FCAudioListener.h"
#import "FCAudioBuffer.h"
#import "FCAudioSource.h"
#import "FCActorSystem.h"

#import "FCLua.h"
#include "Shared/Physics/FCPhysics.h"

// Lua

static int lua_PlayMusic( lua_State* _state )
{
	FC_LUA_ASSERT_NUMPARAMS( 1 );
	FC_LUA_ASSERT_TYPE( 1, LUA_TSTRING );
	
	NSString* name = [NSString stringWithUTF8String:lua_tostring(_state, 1)];
	[[FCAudioManager instance] playMusic:name];
	return 0;
}

static int lua_SetMusicVolume( lua_State* _state )
{
	FC_LUA_ASSERT_NUMPARAMS(1);
	FC_LUA_ASSERT_TYPE(1, LUA_TNUMBER);
	
	float vol = lua_tonumber(_state, 1);
	[FCAudioManager instance].musicVolume = vol;

	return 0;
}

static int lua_SetSFXVolume( lua_State* _state )
{
	FC_LUA_ASSERT_NUMPARAMS(1);
	FC_LUA_ASSERT_TYPE(1, LUA_TNUMBER);
	
	float vol = lua_tonumber(_state, 1);
	[FCAudioManager instance].sfxVolume = vol;
	
	return 0;
}

static int lua_SetMusicFinishedCallback( lua_State* _state )
{
	FC_LUA_ASSERT_NUMPARAMS(1);
	FC_LUA_ASSERT_TYPE(1, LUA_TSTRING);
	
	NSString* name = [NSString stringWithUTF8String:lua_tostring(_state, 1)];
	[FCAudioManager instance].musicFinishedLuaCallback = name;
	return 0;
}

static int lua_PauseMusic( lua_State* _state )
{
	FC_LUA_ASSERT_NUMPARAMS(0);
	[[FCAudioManager instance] pauseMusic];
	return 0;
}

static int lua_ResumeMusic( lua_State* _state )
{
	FC_LUA_ASSERT_NUMPARAMS(0);
	[[FCAudioManager instance] resumeMusic];
	return 0;
}

static int lua_StopMusic( lua_State* _state )
{
	FC_LUA_ASSERT_NUMPARAMS(0);
	[[FCAudioManager instance] stopMusic];
	return 0;
}

static int lua_DeleteBuffer( lua_State* _state )
{
	FC_LUA_ASSERT_NUMPARAMS(1);
	FC_LUA_ASSERT_TYPE(1, LUA_TNUMBER);
	
	[[FCAudioManager instance] deleteBuffer:lua_tointeger(_state, 1)];
	return 0;
}

static int lua_LoadSimpleSound( lua_State* _state )
{
	FC_LUA_ASSERT_NUMPARAMS(1);
	FC_LUA_ASSERT_TYPE(1, LUA_TSTRING);
	
	NSString* name = [NSString stringWithUTF8String:lua_tostring(_state, 1)];
	
	FCHandle h = [[FCAudioManager instance] loadSimpleSound:name];

	lua_pushinteger(_state, h);
	
	return 1;
}

static int lua_UnloadSimpleSound( lua_State* _state )
{
	FC_LUA_ASSERT_NUMPARAMS(1);
	FC_LUA_ASSERT_TYPE(1, LUA_TNUMBER);

	FCHandle h = lua_tointeger(_state, 1);

	[[FCAudioManager instance] unloadSimpleSound:h];

	return 0;
}

static int lua_PlaySimpleSound( lua_State* _state )
{
	FC_LUA_ASSERT_NUMPARAMS(1);
	FC_LUA_ASSERT_TYPE(1, LUA_TNUMBER);
	
	FCHandle h = lua_tointeger(_state, 1);

	[[FCAudioManager instance] playSimpleSound:h];
	
	return 0;
}

static int lua_SubscribeToPhysics2D( lua_State* _state )
{
	FC_LUA_ASSERT_NUMPARAMS(0);
	
	[[FCAudioManager instance] subscribeToPhysics2D];
	
	return 0;
}

static int lua_UnsubscribeFromPhysics2D( lua_State* _state )
{
	FC_LUA_ASSERT_NUMPARAMS(0);
	
	[[FCAudioManager instance] unsubscribeFromPhysics2D];
	
	return 0;
}

static int lua_CreateBufferWithFile( lua_State* _state )
{
	FC_LUA_ASSERT_NUMPARAMS(1);
	FC_LUA_ASSERT_TYPE(1, LUA_TSTRING);
	
	NSString* name = [NSString stringWithUTF8String:lua_tostring(_state, 1)];

	FCHandle h = [[FCAudioManager instance] createBufferWithFile:name];

	lua_pushinteger(_state, h);	
	return 1;
}

static int lua_AddCollisionTypeHandler( lua_State* _state )
{
	FC_LUA_ASSERT_NUMPARAMS(3);
	FC_LUA_ASSERT_TYPE(1, LUA_TSTRING);
	FC_LUA_ASSERT_TYPE(2, LUA_TSTRING);
	FC_LUA_ASSERT_TYPE(3, LUA_TSTRING);
	
	NSString* type1 = [NSString stringWithUTF8String:lua_tostring(_state, 1)];
	NSString* type2 = [NSString stringWithUTF8String:lua_tostring(_state, 2)];
	NSString* luaFunc = [NSString stringWithUTF8String:lua_tostring(_state, 3)];
	
	[[FCAudioManager instance] addCollisionTypeHanderFor:type1 andType:type2 luaFunc:luaFunc];
	
	return 0;
}

static int lua_RemoveCollisionTypeHandler( lua_State* _state )
{
	FC_LUA_ASSERT_NUMPARAMS(2);
	FC_LUA_ASSERT_TYPE(1, LUA_TSTRING);
	FC_LUA_ASSERT_TYPE(2, LUA_TSTRING);
	
	NSString* type1 = [NSString stringWithUTF8String:lua_tostring(_state, 1)];
	NSString* type2 = [NSString stringWithUTF8String:lua_tostring(_state, 2)];

	[[FCAudioManager instance] removeCollisionTypeHanderFor:type1 andType:type2];
	
	return 0;
}

static int lua_PrepareSourceWithBuffer( lua_State* _state )
{
	FC_LUA_ASSERT_NUMPARAMS(2);
	FC_LUA_ASSERT_TYPE(1, LUA_TNUMBER);
	FC_LUA_ASSERT_TYPE(2, LUA_TBOOLEAN);
	
	FCHandle hBuffer = lua_tointeger(_state, 1);

	BOOL vital = lua_toboolean(_state, 2);
	
	FCHandle hSource = [[FCAudioManager instance] prepareSourceWithBuffer:hBuffer vital:vital];
	
	lua_pushinteger(_state, hSource);
	return 1;
}

static int lua_SourceSetVolume( lua_State* _state )
{
	FC_LUA_ASSERT_NUMPARAMS(2);
	FC_LUA_ASSERT_TYPE(1, LUA_TNUMBER);
	FC_LUA_ASSERT_TYPE(2, LUA_TNUMBER);
	
	FCHandle hSource = lua_tointeger(_state, 1);
	float vol = lua_tonumber(_state, 2);
	
	FCAudioSource* source = [[FCAudioManager instance].activeSources objectForKey:[NSNumber numberWithInt:hSource]];

	FC_ASSERT(source);
	
	source.volume = vol;
	
	return 0;
}

static int lua_SourcePlay( lua_State* _state )
{
	FC_LUA_ASSERT_NUMPARAMS(1);
	FC_LUA_ASSERT_TYPE(1, LUA_TNUMBER);
	
	FCHandle hSource = lua_tointeger(_state, 1);	
	FCAudioSource* source = [[FCAudioManager instance].activeSources objectForKey:[NSNumber numberWithInt:hSource]];
	
	FC_ASSERT(source);
	
	[source play];
	
	return 0;
}

static int lua_SourceStop( lua_State* _state )
{
	FC_LUA_ASSERT_NUMPARAMS(1);
	FC_LUA_ASSERT_TYPE(1, LUA_TNUMBER);
	
	FCHandle hSource = lua_tointeger(_state, 1);	
	FCAudioSource* source = [[FCAudioManager instance].activeSources objectForKey:[NSNumber numberWithInt:hSource]];
	
	FC_ASSERT(source);
	
	[source stop];
	
	return 0;
}

static int lua_SourceLooping( lua_State* _state )
{
	FC_LUA_ASSERT_NUMPARAMS(2);
	FC_LUA_ASSERT_TYPE(1, LUA_TNUMBER);
	FC_LUA_ASSERT_TYPE(2, LUA_TBOOLEAN);
	
	FCHandle hSource = lua_tointeger(_state, 1);	
	FCAudioSource* source = [[FCAudioManager instance].activeSources objectForKey:[NSNumber numberWithInt:hSource]];
	
	FC_ASSERT(source);
	
	source.looping = lua_toboolean(_state, 2);
	
	return 0;
}

static int lua_SourcePosition( lua_State* _state )
{
	FC_LUA_ASSERT_NUMPARAMS(4);
	FC_LUA_ASSERT_TYPE(1, LUA_TNUMBER);
	FC_LUA_ASSERT_TYPE(2, LUA_TNUMBER);
	FC_LUA_ASSERT_TYPE(3, LUA_TNUMBER);
	FC_LUA_ASSERT_TYPE(4, LUA_TNUMBER);
	
	FCHandle hSource = lua_tointeger(_state, 1);	
	FCAudioSource* source = [[FCAudioManager instance].activeSources objectForKey:[NSNumber numberWithInt:hSource]];

	FCVector3f pos;
	pos.x = lua_tonumber(_state, 2);
	pos.y = lua_tonumber(_state, 3);
	pos.z = lua_tonumber(_state, 4);

	source.position = pos;
	
	return 0;
}

static int lua_SourcePitch( lua_State* _state )
{
	FC_LUA_ASSERT_NUMPARAMS(2);
	FC_LUA_ASSERT_TYPE(1, LUA_TNUMBER);
	FC_LUA_ASSERT_TYPE(2, LUA_TNUMBER);
	
	FCHandle hSource = lua_tointeger(_state, 1);	
	FCAudioSource* source = [[FCAudioManager instance].activeSources objectForKey:[NSNumber numberWithInt:hSource]];

	float pitch = lua_tonumber(_state, 2);
	source.pitch = pitch;
	
	return 0;
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

		NSString* luaFunc = [[FCAudioManager instance].collisionTypeHandlers valueForKey:key];
		
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

@implementation FCAudioManager

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

+(FCAudioManager*)instance
{
	static FCAudioManager* pInstance;
	if (!pInstance) {
		pInstance = [[FCAudioManager alloc] init];
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
				NSLog(@"%@", [FCAudioManager instance].activeSources);
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
		
		// Lua stuff
		
		FCLua::Instance()->CoreVM()->CreateGlobalTable("FCAudio");
		FCLua::Instance()->CoreVM()->RegisterCFunction(lua_PlayMusic, "FCAudio.PlayMusic");
		FCLua::Instance()->CoreVM()->RegisterCFunction(lua_SetMusicVolume, "FCAudio.SetMusicVolume");
		FCLua::Instance()->CoreVM()->RegisterCFunction(lua_SetSFXVolume, "FCAudio.SetSFXVolume");
		FCLua::Instance()->CoreVM()->RegisterCFunction(lua_SetMusicFinishedCallback, "FCAudio.SetMusicFinishedCallback");
		FCLua::Instance()->CoreVM()->RegisterCFunction(lua_PauseMusic, "FCAudio.PauseMusic");
		FCLua::Instance()->CoreVM()->RegisterCFunction(lua_ResumeMusic, "FCAudio.ResumeMusic");
		FCLua::Instance()->CoreVM()->RegisterCFunction(lua_StopMusic, "FCAudio.StopMusic");

		FCLua::Instance()->CoreVM()->RegisterCFunction(lua_CreateBufferWithFile, "FCAudio.CreateBuffer");
		FCLua::Instance()->CoreVM()->RegisterCFunction(lua_DeleteBuffer, "FCAudio.DeleteBuffer");

		FCLua::Instance()->CoreVM()->RegisterCFunction(lua_PrepareSourceWithBuffer, "FCAudio.PrepareSourceWithBuffer");
		FCLua::Instance()->CoreVM()->RegisterCFunction(lua_SourceSetVolume, "FCAudio.SourceSetVolume");
		FCLua::Instance()->CoreVM()->RegisterCFunction(lua_SourcePlay, "FCAudio.SourcePlay");
		FCLua::Instance()->CoreVM()->RegisterCFunction(lua_SourceStop, "FCAudio.SourceStop");
		FCLua::Instance()->CoreVM()->RegisterCFunction(lua_SourcePosition, "FCAudio.SourcePosition");
		FCLua::Instance()->CoreVM()->RegisterCFunction(lua_SourcePitch, "FCAudio.SourcePitch");
		FCLua::Instance()->CoreVM()->RegisterCFunction(lua_SourceLooping, "FCAudio.SourceLooping");

		FCLua::Instance()->CoreVM()->RegisterCFunction(lua_AddCollisionTypeHandler, "FCAudio.AddCollisionTypeHandler");
		FCLua::Instance()->CoreVM()->RegisterCFunction(lua_RemoveCollisionTypeHandler, "FCAudio.RemoveCollisionTypeHandler");
		
		FCLua::Instance()->CoreVM()->RegisterCFunction(lua_LoadSimpleSound, "FCAudio.LoadSimpleSound");
		FCLua::Instance()->CoreVM()->RegisterCFunction(lua_UnloadSimpleSound, "FCAudio.UnloadSimpleSound");
		FCLua::Instance()->CoreVM()->RegisterCFunction(lua_PlaySimpleSound, "FCAudio.PlaySimpleSound");

		FCLua::Instance()->CoreVM()->RegisterCFunction(lua_SubscribeToPhysics2D, "FCAudio.SubscribeToPhysics2D");
		FCLua::Instance()->CoreVM()->RegisterCFunction(lua_UnsubscribeFromPhysics2D, "FCAudio.UnsubscribeFromPhysics2D");

		_listener = [[FCAudioListener alloc] init];
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
	
	FCAudioBuffer* buffer = [[FCAudioBuffer alloc] initWithFilename:filename];
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
	
	FCAudioBuffer* buffer = [_buffers objectForKey:[NSNumber numberWithInt:hBuffer]];

	NSArray* sourceKeys = [_activeSources allKeys];
	
	for( NSNumber* key in sourceKeys )
	{
		FCAudioSource* source = [_activeSources objectForKey:key];
		
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
		FCAudioSource* source = [[FCAudioSource alloc] init];
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
