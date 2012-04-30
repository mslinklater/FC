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

#include "FCPerformanceCounter_apple.h"

static NSMutableDictionary* s_performanceCounters;

void plt_FCPerformanceCounter_New( void* instance )
{
	FCPerformanceCounter* pc = [[FCPerformanceCounter alloc] init];
	[s_performanceCounters setObject:pc forKey:[NSNumber numberWithInt:(uint64_t)instance]];
}

void plt_FCPerformanceCounter_Delete( void* instance )
{
	[s_performanceCounters removeObjectForKey:[NSNumber numberWithInt:(uint64_t)instance]];
}

void plt_FCPerformanceCounter_Zero( void* instance )
{
	FCPerformanceCounter* pc = [s_performanceCounters objectForKey:[NSNumber numberWithInt:(uint64_t)instance]];
	[pc zero];
}

double plt_FCPerformanceCounter_NanoValue( void* instance )
{
	FCPerformanceCounter* pc = [s_performanceCounters objectForKey:[NSNumber numberWithInt:(uint64_t)instance]];
	return [pc nanoValue];
}

#pragma mark Methods

@implementation FCPerformanceCounter

+(void)initialize
{
	s_performanceCounters = [NSMutableDictionary dictionary];
}

-(id)init
{
	self = [super init];
	if (self) {
		mach_timebase_info(&mInfo);
		[self zero];
	}
	return self;
}

-(void)zero
{
	mZeroTime = mach_absolute_time();
}

-(double)nanoValue
{
	uint64_t timeNow = mach_absolute_time();
	uint64_t duration = timeNow - mZeroTime;
	duration *= mInfo.numer;
	duration /= mInfo.denom;
	return (double)duration;	
}

@end
