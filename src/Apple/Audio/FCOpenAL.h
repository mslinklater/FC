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

#if defined( ADHOC )
#define FCALBufferData(a,b,c,d,e) alBufferData(a,b,c,d,e)
#define FCALDeleteBuffers(a,b) alDeleteBuffers(a,b)
#define FCALDeleteSources(a,b) alDeleteSources(a,b)
#define FCALGenBuffers(a,b) alGenBuffers(a,b)
#define FCALGenSources(a,b) alGenSources(a,b)
#define FCALGetSourcei(a,b,c) alGetSourcei(a,b,c)
#define FCALListenerfv(a,b) alListenerfv(a,b)
#define FCALSourcef(a,b,c) alSourcef(a,b,c)
#define FCALSourcefv(a,b,c) alSourcefv(a,b,c)
#define FCALSourcei(a,b,c) alSourcei(a,b,c)
#define FCALSourcePlay(a) alSourcePlay(a)
#define FCALSourceStop(a) alSourceStop(a)
#else
#define FCALBufferData(a,b,c,d,e) {alBufferData(a,b,c,d,e);AL_CHECK;}
#define FCALDeleteBuffers(a,b) {alDeleteBuffers(a,b);AL_CHECK;}
#define FCALDeleteSources(a,b) {alDeleteSources(a,b);AL_CHECK;}
#define FCALGenBuffers(a,b) {alGenBuffers(a,b);AL_CHECK;}
#define FCALGenSources(a,b) {alGenSources(a,b);AL_CHECK;}
#define FCALGetSourcei(a,b,c) {alGetSourcei(a,b,c);AL_CHECK;}
#define FCALListenerfv(a,b) {alListenerfv(a,b);AL_CHECK;}
#define FCALSourcef(a,b,c) {alSourcef(a,b,c);AL_CHECK;}
#define FCALSourcefv(a,b,c) {alSourcefv(a,b,c);AL_CHECK;}
#define FCALSourcei(a,b,c) {alSourcei(a,b,c);AL_CHECK;}
#define FCALSourcePlay(a) {alSourcePlay(a);AL_CHECK;}
#define FCALSourceStop(a) {alSourceStop(a);AL_CHECK;}
#endif


