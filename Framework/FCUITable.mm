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

#import "FCUITable.h"

#pragma mark - FCUITableDef

@implementation FCUITableDef
@synthesize rect;
@synthesize color;
@synthesize delegateAndDataSource;
@synthesize parentView;

+(FCUITableDef*)def
{
	FCUITableDef* newDef = [[FCUITableDef alloc] autorelease];
	
	newDef.rect = CGRectMake(20, 120, 280, 320);
	
	newDef.delegateAndDataSource = nil;
	
	newDef.color = [UIColor clearColor];
	
	newDef.parentView = nil;
	
	return newDef;
}

@end

#pragma mark - FCUITable

@implementation FCUITable

@end

#endif // TARGET_OS_IPHONE
