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

#include "FCPerformanceCounter.h"

extern void plt_FCPerformanceCounter_New( void* instance );
extern void plt_FCPerformanceCounter_Delete( void* instance );
extern void plt_FCPerformanceCounter_Zero( void* instance );
extern double plt_FCPerformanceCounter_NanoValue( void* instance );

FCPerformanceCounter::FCPerformanceCounter()
{
	plt_FCPerformanceCounter_New( this );
}

FCPerformanceCounter::~FCPerformanceCounter()
{
	plt_FCPerformanceCounter_Delete( this );
}

void FCPerformanceCounter::Zero()
{
	plt_FCPerformanceCounter_Zero( this );
}

double FCPerformanceCounter::NanoValue()
{
	uint64_t nanoValue = plt_FCPerformanceCounter_NanoValue( this );
	return nanoValue;
}

double FCPerformanceCounter::MicroValue()
{
	uint64_t nanoValue = plt_FCPerformanceCounter_NanoValue( this );
	return nanoValue / 1000.0;
}

double FCPerformanceCounter::MilliValue()
{
	uint64_t nanoValue = plt_FCPerformanceCounter_NanoValue( this );
	return nanoValue / 1000000.0;
}

double FCPerformanceCounter::SecondsValue()
{
	uint64_t nanoValue = plt_FCPerformanceCounter_NanoValue( this );
	return nanoValue / 1000000000.0;
}
