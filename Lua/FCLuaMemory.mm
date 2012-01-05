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

#import "FCLuaMemory.h"

// global memory allocation routine

void* FCLuaAlloc( void* ud, void* ptr, size_t osize, size_t nsize )
{
	if (nsize) {
		[FCLuaMemory instance].totalMemory += nsize - osize;
		
		if (osize) {
			return realloc(ptr, nsize);
		} else {
			[FCLuaMemory instance].numAllocs++;
			return malloc(nsize);			
		}
	} else {
		[FCLuaMemory instance].totalMemory -= osize;
		if (osize) {
			[FCLuaMemory instance].numAllocs--;
			free(ptr);
		}
		return NULL;
	}
}

@implementation FCLuaMemory
@synthesize totalMemory = _totalMemory;
@synthesize numAllocs = _numAllocs;

+(id)instance
{
	static FCLuaMemory* pInstance;
	if (!pInstance) {
		pInstance = [[FCLuaMemory alloc] init];
	}
	return pInstance;
}

-(id)init
{
	self = [super init];
	if (self) {
		// blah
	}
	return self;
}

-(void)setTotalMemory:(int)totalMemory
{
	_totalMemory = totalMemory;
}

@end
