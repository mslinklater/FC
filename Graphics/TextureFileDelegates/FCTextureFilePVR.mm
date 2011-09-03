/*
 Copyright (C) 2011 by Martin Linklater
 
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

#import "FCTextureFilePVR.h"
#import "PVRTTexture.h"

@interface FCTextureFilePVR()
@property(nonatomic, retain) NSData* imageData;
@property(nonatomic) PVR_Texture_Header* pHeader;
@end

@implementation FCTextureFilePVR
@synthesize imageData = _imageData;
@synthesize pHeader;

-(void)loadWithContentsOfURL:(NSURL*)url
{
	self.imageData = [NSData dataWithContentsOfURL:url];

	pHeader = (PVR_Texture_Header*)[self.imageData bytes];
	(void)pHeader;
}

-(GLenum)format
{
	return GL_RGB;
}

-(GLsizei)width
{
	return 0;
}

-(GLsizei)height
{
	return 0;
}

-(GLenum)type
{
	return GL_RGB;
}

-(void*)pixels
{
	return 0;
}

@end
