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

#if defined(FC_GRAPHICS)

#import "FCTextureFile.h"
#import "FCCore.h"
#import "FCGraphicsProtocols.h"
#import "FCTextureFilePVR.h"
#import "FCGL.h"

@interface FCTextureFile()
@property(nonatomic, weak) NSURL* url;
@property(nonatomic, strong) NSObject<FCTextureFileDelegate>* delegate;
@end

@implementation FCTextureFile
@synthesize name = _name;
@synthesize rawdata = _rawdata;
@synthesize size = _size;
@synthesize glHandle = _glHandle;
@synthesize hookCount = _hookCount;
@synthesize url = _url;
@synthesize sourceFormat = _sourceFormat;
@synthesize delegate = _delegate;

-(id)initWithURL:(NSURL *)url
{
	FC_ASSERT(url);
	
	self = [super init];
	if (self) {
		_glHandle = 0;
		_hookCount = 0;
		self.url = url;
		_sourceFormat = kFCTextureFileSourceUnknown;
		
		NSString* fileTypeString = [[self.url absoluteString] pathExtension];
		
		if ([fileTypeString isEqualToString:@"pvr"]) {
			_sourceFormat = kFCTextureFileSourcePVR;
			_delegate = [[FCTextureFilePVR alloc] init];
		} else {
			FC_FATAL( std::string("Unknown source type") + [fileTypeString UTF8String]);
		}
	}
	return self;
}

+(id)fcTextureFileWithURL:(NSURL *)url
{
	return [[FCTextureFile alloc] initWithURL:url];
}


-(GLuint)getGlHandle
{
	FC_ASSERT(_glHandle);
	return _glHandle;
}

-(void)hook
{
	if (self.hookCount == 0) {
		// need to setup GL texture
		FCglGenTextures(1, &_glHandle);
		FCglBindTexture(GL_TEXTURE_2D, self.glHandle);

		[_delegate loadWithContentsOfURL:self.url];
		
		FCglBindTexture(GL_TEXTURE_2D, self.glHandle);
		
		FCglTexImage2D(GL_TEXTURE_2D, 0, [self.delegate format], [self.delegate width], [self.delegate height], 0, [self.delegate format], [self.delegate type], [self.delegate pixels]);
	}
	_hookCount++;
}

-(void)unhook
{
	FC_ASSERT(self.hookCount);
		
	if (self.hookCount > 0) {
		// need to unbind texture here
		FCglDeleteTextures(1, &_glHandle);
		_glHandle = 0;
	}
	
	_hookCount--;
}

@end

#endif // defined(FC_GRAPHICS)
