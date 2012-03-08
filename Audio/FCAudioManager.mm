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

// Lua

// load sample
// move listener

@implementation FCAudioManager

@synthesize device = _device;
@synthesize context = _context;

@synthesize samples = _samples;

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
		
		_listener = [[FCAudioListener alloc] init];
		_samples = [NSMutableDictionary dictionary];
		_sources = [NSMutableDictionary dictionary];
		
		_device = alcOpenDevice( NULL );
		_context = alcCreateContext( _device, 0 );
		alcMakeContextCurrent( _context );

//		alGenBuffers(<#ALsizei n#>, <#ALuint *buffers#>)
//		alGenSources(<#ALsizei n#>, <#ALuint *sources#>)
//		alBufferData(<#ALuint bid#>, <#ALenum format#>, <#const ALvoid *data#>, <#ALsizei size#>, <#ALsizei freq#>)
		
		
	}
	return self;
}

@end
