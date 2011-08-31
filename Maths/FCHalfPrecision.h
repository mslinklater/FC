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

extern int singles2halfp(void *target, void *source, int numel);
extern int doubles2halfp(void *target, void *source, int numel);
extern int halfp2singles(void *target, void *source, int numel);
extern int halfp2doubles(void *target, void *source, int numel);

namespace FC {
	typedef short float16;
	
	inline float16 toFloat16( float input )
	{
		float16 result;
		singles2halfp( &result, &input, 1 );
		return result;
	}

	inline float16 toFloat16( double input )
	{
		float16 result;
		doubles2halfp( &result, &input, 1 );
		return result;
	}

	inline float toFloat( float16 input )
	{
		float result;
		halfp2singles( &result, &input, 1 );
		return result;
	}

	inline double toFloat( float16 input )
	{
		double result;
		halfp2doubles( &result, &input, 1 );
		return result;
	}
}