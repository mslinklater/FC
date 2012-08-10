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

#import <OpenAL/al.h>
#import <OpenAL/alc.h>

#import "FCAudioListener_apple.h"

@implementation FCAudioListener_apple

-(id)init
{
	self = [super init];
	if (self) {
		self.position = FCVector3f( 0.0f, 0.0f, 0.0f );
		self.rotation = 0.0f;
	}
	return self;
}

-(void)setPosition:(FCVector3f)position
{
	float listenerPosAL[] = {position.x, position.y, position.z};
	
	alListenerfv(AL_POSITION, listenerPosAL);
}

-(void)setRotation:(float)rotation
{
	float ori[] = {static_cast<float>(cos(rotation + M_PI_2)), static_cast<float>(sin(rotation + M_PI_2)), 0., 0., 0., 1.};
	
	alListenerfv(AL_ORIENTATION, ori);
}

@end
