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

#ifndef FCCOLOR_H
#define FCCOLOR_H

#include "FCBase.h"

class FCColor4f {
public:
	FCColor4f(){}
	FCColor4f( float rIn, float gIn, float bIn, float aIn ) : r(rIn), g(gIn), b(bIn), a(aIn) {}
	FCColor4f( const FCColor4f& col ) : r(col.r), g(col.g), b(col.b), a(col.a) {}
	
	void Zero( void ){ r = g = b = a = 0.0f; }
	
	float	r;
	float	g;
	float	b;
	float	a;
};

static const FCColor4f kFCColorGreen(){ return FCColor4f(0.0f, 1.0f, 0.0f, 1.0f); }

#endif // FCCOLOR_H