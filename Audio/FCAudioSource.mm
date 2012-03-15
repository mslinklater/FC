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

#import "FCAudioSource.h"
#import "FCAudioBuffer.h"
#import "FCAudioManager.h"

@implementation FCAudioSource

@synthesize handle = _handle;
@synthesize ALHandle = _ALHandle;
@synthesize ALBufferHandle = _ALBufferHandle;
@synthesize position = _position;
@synthesize stopped = _stopped;
@synthesize volume = _volume;
@synthesize pitch = _pitch;
@synthesize looping = _looping;

-(id)init
{
	self = [super init];
	if (self) {
		alGenSources(1, &_ALHandle);
		
		AL_CHECK;
	}
	return self;
}

-(void)dealloc
{
	alDeleteSources(1, &_ALHandle);
}

-(BOOL)stopped
{
	ALint state;
	alGetSourcei(_ALHandle, AL_SOURCE_STATE, &state);
	
	AL_CHECK;
	
	switch (state) {
		case AL_STOPPED:
			_stopped = YES;
			break;
		case AL_INITIAL:
		case AL_PLAYING:
		case AL_PAUSED:
			_stopped = NO;
			break;			
		default:
			FC_ASSERT(0);
			break;
	}
	
	return _stopped;
}

-(void)setPosition:(FC::Vector3f)position
{
	float sourcePosAL[] = {position.x, position.y, position.z};
	
	alSourcefv(_ALHandle, AL_POSITION, sourcePosAL);

	AL_CHECK;
}

-(void)setVolume:(float)volume
{
	FC::Clamp(volume, 0.0f, 1.0f);
	alSourcef(_ALHandle, AL_GAIN, volume * volume);
	AL_CHECK;
	_volume = volume;
}

-(void)setPitch:(float)pitch
{
	FC::Clamp(pitch, 0.01f, 9999.0f);
	alSourcef(_ALHandle, AL_PITCH, pitch);
	AL_CHECK;
	_pitch = pitch;
}

-(void)setLooping:(BOOL)looping
{
	if (looping) {
		alSourcei(_ALHandle, AL_LOOPING, AL_TRUE);
	} else {
		alSourcei(_ALHandle, AL_LOOPING, AL_FALSE);		
	}
	_looping = looping;
}

-(void)setALBufferHandle:(ALuint)ALBufferHandle
{
	alSourcei(_ALHandle, AL_BUFFER, ALBufferHandle);

	AL_CHECK;

	// Turn Looping OFF
	alSourcei(_ALHandle, AL_LOOPING, AL_FALSE);

	AL_CHECK;

	float sourcePosAL[] = {0.0f, 0.0f, 0.0f};
	alSourcefv(_ALHandle, AL_POSITION, sourcePosAL);

	AL_CHECK;

	alSourcef(_ALHandle, AL_REFERENCE_DISTANCE, 50.0f);

	AL_CHECK;

	_ALBufferHandle = ALBufferHandle;
}

-(void)play
{
	alSourcePlay( _ALHandle );

	AL_CHECK;
}

-(void)stop
{
	alSourceStop(_ALHandle);

	AL_CHECK;
}

-(NSString*)description
{
	ALint state;
	alGetSourcei(_ALHandle, AL_SOURCE_STATE, &state);
	
	AL_CHECK;
	
	switch (state) {
		case AL_STOPPED:
			return @"Stopped";
			break;
		case AL_INITIAL:
			return @"Initial";
			break;			
		case AL_PLAYING:
			return @"Playing";
			break;
		case AL_PAUSED:
			return @"Paused";
			break;			
		default:
			FC_ASSERT(0);
			break;
	}
	return @"";
}

@end
