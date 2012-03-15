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
#import <OpenAL/al.h>
#import <OpenAL/alc.h>

#import "FCCore.h"

@interface FCAudioSource : NSObject {
	FCHandle		_handle;
	ALuint			_ALHandle;
	ALuint			_ALBufferHandle;
	FC::Vector3f	_position;
	BOOL			_stopped;
	float			_volume;
	float			_pitch;	
	BOOL			_looping;
}
@property(nonatomic) FCHandle handle;
@property(nonatomic) ALuint ALHandle;
@property(nonatomic) ALuint ALBufferHandle;
@property(nonatomic) FC::Vector3f position;
@property(nonatomic, readonly) BOOL stopped;
@property(nonatomic) float volume;
@property(nonatomic) float pitch;
@property(nonatomic) BOOL looping;

-(void)play;
-(void)stop;

@end
