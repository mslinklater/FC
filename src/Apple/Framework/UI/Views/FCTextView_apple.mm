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

#import "FCTextView_apple.h"

#include "Shared/Framework/UI/FCViewManagerTypes.h"
#include "Shared/FCPlatformInterface.h"

@implementation FCTextView_apple

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
		_textView = [[UITextView alloc] initWithFrame:CGRectZero];
		_textView.backgroundColor = [UIColor clearColor];
		_textView.editable = NO;
		_textView.userInteractionEnabled = NO;
		[self addSubview:_textView];
		self.clipsToBounds = YES;
    }
    return self;
}

-(void)setFrame:(CGRect)frame
{
	[super setFrame:frame];
	_textView.frame = CGRectMake(0.0, 0.0, frame.size.width, frame.size.height);
}

-(void)setText:(NSString *)text
{
	_textView.text = text;
}

-(void)setFontName:(NSString*)fontName
{
	_fontName = fontName;
}

-(void)setFontSize:(float)size
{
	_textView.font = [UIFont fontWithName:_fontName size:size];
}

-(void)setTextAlignment:(int)alignment
{
	switch (alignment) {
		case kFCViewTextAlignmentLeft:
			_textView.textAlignment = UITextAlignmentLeft;
			break;
		case kFCViewTextAlignmentCenter:
			_textView.textAlignment = UITextAlignmentCenter;
			break;
		case kFCViewTextAlignmentRight:
			_textView.textAlignment = UITextAlignmentRight;
			break;
			
		default:
			fc_FCError_Fatal("unknown enum");
			break;
	}
}

@end
