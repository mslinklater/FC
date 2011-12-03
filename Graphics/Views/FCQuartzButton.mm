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

#import "FCQuartzButton.h"

@interface FCQuartzButton(hidden)
-(void)drawDefaultRect:(NSValue*)frameValue;
@end

@implementation FCQuartzButton
@synthesize style = _style;
@synthesize delegate = _delegate;

#pragma mark - Object Lifetime

-(id)initWithFrame:(CGRect)frame withStyle:(FCQuartzButtonStyle)style
{
	self = [super initWithFrame:frame];
	
	if (self) {		
		_style = style;
		self.frame = frame;
		
		switch (self.style) {
			case kFCQuartzButtonStyleDefault:
//				mDrawDelegate = self;
//				mDrawSelector = @selector(drawDefaultRect:);
				break;
			case kFCQuartzButtonStyleCustom:
//				mDrawSelector = nil;
//				mDrawDelegate = nil;
			default:
				break;
		}
	}
	return self;
}


#pragma mark - Setters

-(void)setDrawDelegate:(id)del withSelector:(SEL)selector
{
//	mDrawDelegate = del;
//	mDrawSelector = selector;
}

#pragma mark - Getters

#pragma mark - Drawing

-(void)drawRect:(CGRect)rect
{
//	[super drawRect:rect];
//	
//	NSAssert(mDrawDelegate && mDrawSelector, @"Drawing delegate or delector nil");
//	
//	NSValue* frameValue = [NSValue valueWithCGRect:rect];		
//	[mDrawDelegate performSelector:mDrawSelector withObject:frameValue];
	
	return;
}

-(void)drawDefaultRect:(NSValue*)frameValue
{
//	CGRect frame = [frameValue CGRectValue];
//	CGContextRef context = UIGraphicsGetCurrentContext();
}

@end

#endif // TARGET_OS_IPHONE
