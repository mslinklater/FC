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

#if TARGET_OS_IPHONE

#import "FCRasterView.h"
#import "FCPerformanceCounter.h"

static const int kMaxTags = 10;
static const int kNumMaxFrames = 10;

#pragma mark - FCRasterViewEntry

@interface FCRasterViewEntry : NSObject {
}
@property(nonatomic, strong) UIColor* color;
@property(nonatomic) float size;
@property(nonatomic, strong) NSString* desc;
@end

@implementation FCRasterViewEntry
@synthesize color = _color;
@synthesize size = _size;
@synthesize desc = _desc;

-(NSString*)description
{
	return [NSString stringWithFormat:@"%f - %@", self.size, self.desc];
}
@end

#pragma mark - FCRasterView

@implementation FCRasterView

#pragma mark - Object Lifetime

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        mPerformanceCounter = [[FCPerformanceCounter alloc] init];
		mEntries = [[NSMutableArray alloc] init];
		maxTime = 0.0f;
		maxCount = 0;
		mMaxEntries = [[NSArray alloc] init];
    }
    return self;
}

-(void)dealloc
{
	mEntries = nil;
	mMaxEntries = nil;
	mPerformanceCounter = nil;
}

-(void)frameStart
{
	
	[mEntries removeAllObjects];
	[mPerformanceCounter zero];
	[self setNeedsDisplay];
}

-(void)tagColour:(UIColor *)color
{
	FCRasterViewEntry* entry = [[FCRasterViewEntry alloc] init];
	entry.color = color;
	entry.size = [mPerformanceCounter milliValue];
	[mPerformanceCounter zero];
	[mEntries addObject:entry];

}

#pragma mark - Drawing

-(void)drawRect:(CGRect)rect
{
	// draw
	
	float scale = rect.size.height / 66.6f;	// pixels per ms
	
	CGContextRef c = UIGraphicsGetCurrentContext();
	
	float currentPos = 0;
	
	CGRect thisRect;
	
	thisRect.origin.x = 0;
	thisRect.size.width = rect.size.width / 2;
	
	for( FCRasterViewEntry* entry in mEntries )
	{
		CGContextSetFillColorWithColor(c, entry.color.CGColor);
		thisRect.origin.y = currentPos;
		thisRect.size.height = entry.size * scale;
		currentPos += thisRect.size.height;		
		CGContextFillRect(c, thisRect);
	}

	if ((currentPos > maxTime) || (maxCount > 50) ){
		mMaxEntries = [mEntries copy];
		maxTime = currentPos;
		maxCount = 0;
	}
	else
	{
		maxCount++;
	}

	thisRect.origin.x = rect.size.width / 2;
	thisRect.size.width = rect.size.width / 2;
	currentPos = 0;
	
	for( FCRasterViewEntry* entry in mMaxEntries )
	{
		CGContextSetFillColorWithColor(c, entry.color.CGColor);
		thisRect.origin.y = currentPos;
		thisRect.size.height = entry.size * scale;
		currentPos += thisRect.size.height;		
		CGContextFillRect(c, thisRect);
	}

	// 
	
	
	return;
}

@end

#endif // TARGET_OS_IPHONE
