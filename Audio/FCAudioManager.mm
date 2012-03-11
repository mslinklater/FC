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
#import "FCAudioCollisionTypeHandler.h"

#import "FCLua.h"
#import "FCPhysics.h"

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

static int lua_CreateBuffer( lua_State* _state )
{
	FC_LUA_ASSERT_NUMPARAMS(0);
	FCHandle h = [[FCAudioManager instance] createBuffer];
	
	lua_pushinteger(_state, h);
	return 1;
}

static int lua_DeleteBuffer( lua_State* _state )
{
	FC_LUA_ASSERT_NUMPARAMS(1);
	FC_LUA_ASSERT_TYPE(1, LUA_TNUMBER);
	
	[[FCAudioManager instance] deleteBuffer:lua_tointeger(_state, 1)];
	return 0;
}

static int lua_CreateSource( lua_State* _state )
{
	FC_LUA_ASSERT_NUMPARAMS(0);
	FCHandle h = [[FCAudioManager instance] createSource];
	
	lua_pushinteger(_state, h);
	return 1;
}

static int lua_DeleteSource( lua_State* _state )
{
	FC_LUA_ASSERT_NUMPARAMS(1);
	FC_LUA_ASSERT_TYPE(1, LUA_TNUMBER);
	
	[[FCAudioManager instance] deleteSource:lua_tointeger(_state, 1)];
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
		id obj1 = (__bridge id)(i->second.actor1);
		id obj2 = (__bridge id)(i->second.actor2);

		NSString* key = [NSString stringWithFormat:@"%@%@", [obj1 class], [obj2 class]];
		
		FCAudioCollisionTypeHandler* handler = [[FCAudioManager instance].collisionTypeHandlers objectForKey:key];
		
		if( handler )
		{
			CollisionInfo* pCollisionInfo = &(i->second);
			
			NSMethodSignature* sig = [handler.theClass instanceMethodSignatureForSelector:handler.selector];		
			NSInvocation* invocation = [NSInvocation invocationWithMethodSignature:sig];
			[invocation setSelector:handler.selector];
			[invocation setTarget:handler.target];
			[invocation setArgument:(void*)&pCollisionInfo atIndex:2];
			[invocation invoke];			
		}
		else 
		{
			NSLog(@"Unhandled %@", key);
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
@synthesize sources = _sources;
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

-(id)init
{
	self = [super init];
	if (self) {
		
		// Lua stuff
		
		[[FCLua instance].coreVM createGlobalTable:@"FCAudio"];
		[[FCLua instance].coreVM registerCFunction:lua_PlayMusic as:@"FCAudio.PlayMusic"];
		[[FCLua instance].coreVM registerCFunction:lua_SetMusicVolume as:@"FCAudio.SetMusicVolume"];
		[[FCLua instance].coreVM registerCFunction:lua_SetSFXVolume as:@"FCAudio.SetSFXVolume"];
		[[FCLua instance].coreVM registerCFunction:lua_SetMusicFinishedCallback as:@"FCAudio.SetMusicFinishedCallback"];
		[[FCLua instance].coreVM registerCFunction:lua_PauseMusic as:@"FCAudio.PauseMusic"];
		[[FCLua instance].coreVM registerCFunction:lua_ResumeMusic as:@"FCAudio.ResumeMusic"];
		[[FCLua instance].coreVM registerCFunction:lua_StopMusic as:@"FCAudio.StopMusic"];

		[[FCLua instance].coreVM registerCFunction:lua_CreateBuffer as:@"FCAudio.CreateBuffer"];
		[[FCLua instance].coreVM registerCFunction:lua_DeleteBuffer as:@"FCAudio.DeleteBuffer"];
		[[FCLua instance].coreVM registerCFunction:lua_CreateSource as:@"FCAudio.CreateSource"];
		[[FCLua instance].coreVM registerCFunction:lua_DeleteSource as:@"FCAudio.DeleteSource"];
		
		[[FCLua instance].coreVM registerCFunction:lua_LoadSimpleSound as:@"FCAudio.LoadSimpleSound"];
		[[FCLua instance].coreVM registerCFunction:lua_UnloadSimpleSound as:@"FCAudio.UnloadSimpleSound"];
		[[FCLua instance].coreVM registerCFunction:lua_PlaySimpleSound as:@"FCAudio.PlaySimpleSound"];

		[[FCLua instance].coreVM registerCFunction:lua_SubscribeToPhysics2D as:@"FCAudio.SubscribeToPhysics2D"];
		[[FCLua instance].coreVM registerCFunction:lua_UnsubscribeFromPhysics2D as:@"FCAudio.UnsubscribeFromPhysics2D"];

		_listener = [[FCAudioListener alloc] init];
		_sources = [NSMutableDictionary dictionary];
		_buffers = [NSMutableDictionary dictionary];
		_simpleSounds = [NSMutableDictionary dictionary];
		_activeSimpleSounds = [NSMutableArray array];
		_collisionTypeHandlers = [NSMutableDictionary dictionary];
		
		_musicVolume = 0.0f;
		_sfxVolume = 0.0f;
		
		// audio session stuff
		
#if TARGET_IPHONE_SIMULATOR
#else
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
		
		result = AudioSessionSetProperty(kAudioSessionProperty_AudioCategory, sizeof(category), &category);
		FC_ASSERT( result == 0 );
		
		result = AudioSessionAddPropertyListener(kAudioSessionProperty_AudioRouteChange, RouteChangeListener, (__bridge void*)self);
		FC_ASSERT( result == 0 );
		
		result = AudioSessionSetActive(true);
		FC_ASSERT( result == 0 );
#endif
		
		_device = alcOpenDevice( NULL );
		_context = alcCreateContext( _device, 0 );
		alcMakeContextCurrent( _context );
	}
	return self;
}

-(void)dealloc
{
	[[FCPhysics instance] twoD].contactListener->RemoveSubscriber(CollisionSubscriber);
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
	NSURL* url = [NSURL URLWithString:path];
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

-(FCHandle)createBuffer
{
	FCHandle h = NewFCHandle();
	
	FCAudioBuffer* buffer = [[FCAudioBuffer alloc] init];
	buffer.handle = h;
	[_buffers setObject:buffer forKey:[NSNumber numberWithInt:h]];
	
	return h;
}

-(void)deleteBuffer:(FCHandle)handle
{
	FC_ASSERT([_buffers objectForKey:[NSNumber numberWithInt:handle]]);
	[_buffers removeObjectForKey:[NSNumber numberWithInt:handle]];
}

-(FCHandle)createSource
{
	FCHandle h = NewFCHandle();
	
	FCAudioSource* buffer = [[FCAudioSource alloc] init];
	buffer.handle = h;
	[_sources setObject:buffer forKey:[NSNumber numberWithInt:h]];
	
	return h;
}

-(void)deleteSource:(FCHandle)handle
{
	FC_ASSERT([_sources objectForKey:[NSNumber numberWithInt:handle]]);
	[_sources removeObjectForKey:[NSNumber numberWithInt:handle]];
}

-(void)addCollisionTypeHanderFor:(NSString*)type1 
						 andType:(NSString*)type2 
						theClass:(Class)theClass
						  target:(id)target 
						selector:(SEL)selector
{
	FCAudioCollisionTypeHandler* handler = [[FCAudioCollisionTypeHandler alloc] init];
	handler.theClass = theClass;
	handler.target = target;
	handler.selector = selector;

	NSString* key = [NSString stringWithFormat:@"%@%@", type1, type2];
	
	FC_ASSERT([_collisionTypeHandlers objectForKey:key] == nil);
	
	[_collisionTypeHandlers setObject:handler forKey:key];
	
	if(![type1 isEqualToString:type2])
	{
		key = [NSString stringWithFormat:@"%@%@", type2, type1];	
		
		FC_ASSERT([_collisionTypeHandlers objectForKey:key] == nil);
		
		[_collisionTypeHandlers setObject:handler forKey:key];		
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
	[[FCPhysics instance] twoD].contactListener->AddSubscriber(CollisionSubscriber);
}

-(void)unsubscribeFromPhysics2D
{
	[[FCPhysics instance] twoD].contactListener->RemoveSubscriber(CollisionSubscriber);
}

#pragma mark - AVAudioPlayerDelegate

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
	if (player == _bgPlayer)	// Music
	{
		if (_musicFinishedLuaCallback) 
		{
			[[FCLua instance].coreVM call:_musicFinishedLuaCallback required:NO withSig:@">"];
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
