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

#import "FCTexture.h"

@implementation FCTexture
@synthesize name = _name;
@synthesize textureFile = _textureFile;
@synthesize absUV = _absUV;

-(id)init
{
	self = [super init];
	if (self) {
		// blah
	}
	return self;
}

+(id)fcTexture
{
	return [[[FCTexture alloc] init] autorelease];
}

-(void)dealloc
{
	[super dealloc];
}

-(CGRect)absUVFromRelUV:(CGRect)relUV
{
	return CGRectMake(relUV.origin.x + (relUV.size.width * self.absUV.size.width), 
					  relUV.origin.y + (relUV.size.height * self.absUV.size.height), 
					  self.absUV.size.width * relUV.size.width, 
					  self.absUV.size.height * relUV.size.height );
}

#if defined (DEBUG)
-(NSString*)description
{
	return [NSString stringWithFormat:@"frame(%f,%f,%f,%f)", self.absUV.origin.x, self.absUV.origin.y, self.absUV.size.width, self.absUV.size.height];
}
#endif

@end
