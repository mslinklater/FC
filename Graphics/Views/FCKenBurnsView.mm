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

#if TARGET_OS_IPHONE

#import "FCKenBurnsView.h"

@implementation FCKenBurnsView

@synthesize imageFilenameArray = _imageFilenameArray;

#pragma mark - Object Lifetime

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) 
	{
		// properties
		_imageFilenameArray = [[NSMutableArray alloc] init];
		
		// members
		mImageView[0] = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
		mImageView[1] = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
		mFrontImageView = mImageView[0];
		mBackImageView = mImageView[1];
    }
    return self;
}

-(void)dealloc
{
	// properties
	self.imageFilenameArray = nil;
	
	//members
	mImageView[0] = nil;
	mImageView[1] = nil;
	mFrontImageView = mBackImageView = nil;
	
}

-(void)setImageFilenameArray:(NSArray *)imageFilenameArray
{
	_imageFilenameArray = imageFilenameArray;
	
	// setup the image caches etc.
}

@end

#endif // TARGET_OS_IPHONE
