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

#import "FCUIButtonDef.h"

#pragma mark - FCUIButtonDef

@implementation FCUIButtonDef

@synthesize defaultImage;
@synthesize pressedImage;
@synthesize center;
@synthesize text;
@synthesize target;
@synthesize action;
@synthesize hidden;
@synthesize parentView;
@synthesize font;
@synthesize fontSize;
@synthesize width;
@synthesize height;

+(FCUIButtonDef*)def
{
	FCUIButtonDef *def = [FCUIButtonDef alloc];
	
	def.defaultImage = nil;
	def.pressedImage = nil;
	def.center = CGPointMake( 0.0f, 0.0f );
	def.text = nil;
	def.target = nil;
	def.action = nil;
	def.hidden = NO;
	def.font = nil;
	def.fontSize = 0;
	def.height = 0;
	def.width = 0;
	return def;
}
@end

#pragma mark - FCUIButton

#endif // TARGET_OS_IPHONE