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
 
#ifndef _FC_UTILITY_H
#define _FC_UTILITY_H

namespace FC
{
	
static const float kDegToRad = 0.01745329f;	
	
template<class T>
T Clamp(T input, T min, T max)
{
	if (input < min) {
		return min;
	} else if (input > max) {
		return max;
	} else {
		return input;
	}
}

template<class T>
void Swap(T a, T b)
{
	T temp = a;
	a = b;
	b = temp;
}

static float RoundWithTolerance( float in, float tolerance )
{
	int div = (int)(in / tolerance);
	float lower = (float)div * tolerance;
	float upper = (float)(div + ((in >= 0) ? 1 : -1)) * tolerance;
	
	if (fabsf(in - lower) < fabsf(in - upper)) 
		return lower;
	else 
		return upper;
}
}

#endif // _FC_UTILITY_H

