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

//#include "FCAudioBuffer.h"
#import "FCAudioBuffer_apple.h"
#import "FCAudioManager_apple.h"

#import <AudioToolbox/AudioToolbox.h>
#import <AudioToolbox/ExtendedAudioFile.h>

#if 1

@implementation FCAudioBuffer_apple

@synthesize ALHandle = _ALHandle;
@synthesize bufferData = _bufferData;
@synthesize format = _format;
@synthesize size = _size;
@synthesize freq = _freq;

-(id)initWithFilename:(NSString*)filename
{
	self = [super init];
	if (self) {
		alGenBuffers(1, &_ALHandle);
		
		AL_CHECK;

		OSStatus						err = noErr;	
		ExtAudioFileRef					extRef = NULL;
		AudioStreamBasicDescription		theFileFormat;
		UInt32							thePropertySize = sizeof(theFileFormat);
		AudioStreamBasicDescription		theOutputFormat;
		SInt64							theFileLengthInFrames = 0;
		
		NSString* stringPath = [[NSBundle mainBundle] pathForResource:filename ofType:@"m4a"];
		FC_ASSERT(stringPath);
		NSURL* url = [NSURL fileURLWithPath:stringPath];
		FC_ASSERT(url);

		err = ExtAudioFileOpenURL((__bridge CFURLRef)url, &extRef);
		FC_ASSERT(!err);
		
		err = ExtAudioFileGetProperty(extRef, kExtAudioFileProperty_FileDataFormat, &thePropertySize, &theFileFormat);
		FC_ASSERT(!err);
		FC_ASSERT(theFileFormat.mChannelsPerFrame <= 2);
		
		theOutputFormat.mSampleRate = theFileFormat.mSampleRate;
		theOutputFormat.mChannelsPerFrame = theFileFormat.mChannelsPerFrame;
		
		theOutputFormat.mFormatID = kAudioFormatLinearPCM;
		theOutputFormat.mBytesPerPacket = 2 * theOutputFormat.mChannelsPerFrame;
		theOutputFormat.mFramesPerPacket = 1;
		theOutputFormat.mBytesPerFrame = 2 * theOutputFormat.mChannelsPerFrame;
		theOutputFormat.mBitsPerChannel = 16;
		theOutputFormat.mFormatFlags = kAudioFormatFlagsNativeEndian | kAudioFormatFlagIsPacked | kAudioFormatFlagIsSignedInteger;
		
		err = ExtAudioFileSetProperty(extRef, kExtAudioFileProperty_ClientDataFormat, sizeof(theOutputFormat), &theOutputFormat);
		FC_ASSERT(!err);
		
		thePropertySize = sizeof(theFileLengthInFrames);
		err = ExtAudioFileGetProperty(extRef, kExtAudioFileProperty_FileLengthFrames, &thePropertySize, &theFileLengthInFrames);
		FC_ASSERT(!err);
		
		err = ExtAudioFileGetProperty(extRef, kExtAudioFileProperty_FileLengthFrames, &thePropertySize, &theFileLengthInFrames);
		FC_ASSERT(!err);
		
		UInt32		dataSize = theFileLengthInFrames * theOutputFormat.mBytesPerFrame;;
		_bufferData = malloc(dataSize);
		
		if (_bufferData)
		{
			AudioBufferList		theDataBuffer;
			theDataBuffer.mNumberBuffers = 1;
			theDataBuffer.mBuffers[0].mDataByteSize = dataSize;
			theDataBuffer.mBuffers[0].mNumberChannels = theOutputFormat.mChannelsPerFrame;
			theDataBuffer.mBuffers[0].mData = _bufferData;
			
			// Read the data into an AudioBufferList
			err = ExtAudioFileRead(extRef, (UInt32*)&theFileLengthInFrames, &theDataBuffer);
			FC_ASSERT(!err);
			
			_size = (ALsizei)dataSize;
			_format = (theOutputFormat.mChannelsPerFrame > 1) ? AL_FORMAT_STEREO16 : AL_FORMAT_MONO16;
			_freq = (ALsizei)theOutputFormat.mSampleRate;
		}
		
		alBufferData(_ALHandle, _format, _bufferData, _size, _freq);
		
		AL_CHECK;
	}
	return self;
}

-(void)dealloc
{
	if (_bufferData) {
		free( _bufferData );
	}
	
	alDeleteBuffers(1, &_ALHandle);
}

@end

#endif
