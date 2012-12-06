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

#import "FCImageView_apple.h"

#include "Shared/Framework/UI/FCViewManagerTypes.h"
#include "Shared/Lua/FCLua.h"

@implementation FCImageView_apple

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
		_imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
		[self addSubview:_imageView];
		self.clipsToBounds = YES;
    }
    return self;
}

-(void)dealloc
{
	[_imageView removeGestureRecognizer:mTapRecognizer];
}

-(void)setFrame:(CGRect)frame
{
	[super setFrame:frame];
	_imageView.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
}

-(void)setContentMode:(int)contentMode
{
	switch (contentMode) {
		case kFCViewContentModeScaleToFill:
			_imageView.contentMode = UIViewContentModeScaleToFill; break;
		case kFCViewContentModeScaleAspectFit:
			_imageView.contentMode = UIViewContentModeScaleAspectFit; break;
		case kFCViewContentModeScaleAspectFill:
			_imageView.contentMode = UIViewContentModeScaleAspectFill; break;
		case kFCViewContentModeRedraw:
			_imageView.contentMode = UIViewContentModeRedraw; break;
		case kFCViewContentModeCenter:
			_imageView.contentMode = UIViewContentModeCenter; break;
		case kFCViewContentModeTop:
			_imageView.contentMode = UIViewContentModeTop; break;
		case kFCViewContentModeBottom:
			_imageView.contentMode = UIViewContentModeBottom; break;
		case kFCViewContentModeLeft:
			_imageView.contentMode = UIViewContentModeLeft; break;
		case kFCViewContentModeRight:
			_imageView.contentMode = UIViewContentModeRight; break;
		case kFCViewContentModeTopLeft:
			_imageView.contentMode = UIViewContentModeTopLeft; break;
		case kFCViewContentModeTopRight:
			_imageView.contentMode = UIViewContentModeTopRight; break;
		case kFCViewContentModeBottomLeft:
			_imageView.contentMode = UIViewContentModeBottomLeft; break;
		case kFCViewContentModeBottomRight:
			_imageView.contentMode = UIViewContentModeBottomRight; break;
		default:
			// TODO error returning
			break;
	}
}

-(void)setImage:(NSString *)imageName
{
	UIImage* image = [UIImage imageNamed:imageName];
	
	if( image == nil )
	{
//		_imageView.backgroundColor = [UIColor greenColor];
	}
	
	[_imageView setImage:image];
}

-(void)setTapFunction:(NSString *)tapFunction
{
	if (_tapFunction == nil) {
		mTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapResponder:)];
		[self addGestureRecognizer:mTapRecognizer];
	}
	_tapFunction = tapFunction;
}

-(void)tapResponder:(id)sender
{
	if ([_tapFunction length]) {
		FCLua::Instance()->CoreVM()->CallFuncWithSig([_tapFunction UTF8String], true, "");
	}
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

@end
