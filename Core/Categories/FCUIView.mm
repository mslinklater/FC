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

#import "FCUIView.h"

#if TARGET_OS_IPHONE

@implementation UIView (FCExtensions)

-(void)setOrigin:(CGPoint)origin
{
	CGRect oldFrame = self.frame;
	oldFrame.origin.x = origin.x;
	oldFrame.origin.y = origin.y;
	self.frame = oldFrame;
}

-(void)setOriginX:(float)x
{
	CGRect oldFrame = self.frame;
	oldFrame.origin.x = x;
	self.frame = oldFrame;
}

-(void)setOriginY:(float)y
{
	CGRect oldFrame = self.frame;
	oldFrame.origin.y = y;
	self.frame = oldFrame;
}

-(void)setCenterX:(float)x
{
	CGPoint oldCenter = self.center;
	oldCenter.x = x;
	self.center = oldCenter;
}

-(void)setCenterY:(float)y
{
	CGPoint oldCenter = self.center;
	oldCenter.y = y;
	self.center = oldCenter;	
}

-(CGSize)size
{
	return self.frame.size;
}

-(void)setSize:(CGSize)size
{
	CGRect oldFrame = self.frame;
	oldFrame.size.width = size.width;
	oldFrame.size.height = size.height;
	self.frame = oldFrame;	
}

-(float)width
{
	return self.frame.size.width;
}

-(float)halfWidth
{
	return self.frame.size.width / 2;	
}

-(void)setWidth:(float)width
{
	CGRect oldFrame = self.frame;
	oldFrame.size.width = width;
	self.frame = oldFrame;
}

-(float)height
{
	return self.frame.size.height;
}

-(float)halfHeight
{
	return self.frame.size.height / 2;
}

-(void)setHeight:(float)height
{
	CGRect oldFrame = self.frame;
	oldFrame.size.height = height;
	self.frame = oldFrame;	
}

-(void)setTopRight:(CGPoint)pos
{
	CGRect oldFrame = self.frame;
	oldFrame.origin.x = pos.x - self.frame.size.width;
	oldFrame.origin.y = pos.y;
	self.frame = oldFrame;
}

-(void)setTopRightX:(float)x
{
	CGRect oldFrame = self.frame;
	oldFrame.origin.x = x - self.frame.size.width;
	self.frame = oldFrame;	
}

-(void)setTopRightY:(float)y
{
	CGRect oldFrame = self.frame;
	oldFrame.origin.y = y;
	self.frame = oldFrame;		
}

@end

#endif // TARGET_OS_IPHONE