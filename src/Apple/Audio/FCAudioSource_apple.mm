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

#import "FCAudioSource_apple.h"
#import "FCAudioBuffer_apple.h"
#import "FCAudioManager_apple.h"

@implementation FCAudioSource_apple

-(id)init
{
	self = [super init];
	if (self) {
		FCALGenSources(1, &_ALHandle);
	}
	return self;
}

-(void)dealloc
{
	FCALSourcei(_ALHandle, AL_BUFFER, 0);
	FCALDeleteSources(1, &_ALHandle);
}

-(BOOL)stopped
{
	ALint state;
	FCALGetSourcei(_ALHandle, AL_SOURCE_STATE, &state);
	
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

-(void)setPosition:(FCVector3f)position
{
	float sourcePosAL[] = {position.x, position.y, position.z};
	
	alSourcefv(_ALHandle, AL_POSITION, sourcePosAL);

	AL_CHECK;
}

-(void)setVolume:(float)volume
{
	FCClamp(volume, 0.0f, 1.0f);
	FCALSourcef(_ALHandle, AL_GAIN, volume * volume);
	_volume = volume;
}

-(void)setPitch:(float)pitch
{
	FCClamp(pitch, 0.01f, 9999.0f);
	FCALSourcef(_ALHandle, AL_PITCH, pitch);
	_pitch = pitch;
}

-(void)setLooping:(BOOL)looping
{
	if (looping) {
		FCALSourcei(_ALHandle, AL_LOOPING, AL_TRUE);
	} else {
		FCALSourcei(_ALHandle, AL_LOOPING, AL_FALSE);
	}
	_looping = looping;
}

-(void)setALBufferHandle:(ALuint)ALBufferHandle
{
	FCALSourcei(_ALHandle, AL_BUFFER, ALBufferHandle);

	// Turn Looping OFF
	FCALSourcei(_ALHandle, AL_LOOPING, AL_FALSE);

	float sourcePosAL[] = {0.0f, 0.0f, 0.0f};
	FCALSourcefv(_ALHandle, AL_POSITION, sourcePosAL);

	FCALSourcef(_ALHandle, AL_REFERENCE_DISTANCE, 50.0f);

	_ALBufferHandle = ALBufferHandle;
}

-(void)play
{
	FCALSourcePlay( _ALHandle );
}

-(void)stop
{
	FCALSourceStop(_ALHandle);
}

-(NSString*)description
{
	ALint state;
	FCALGetSourcei(_ALHandle, AL_SOURCE_STATE, &state);
	
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
