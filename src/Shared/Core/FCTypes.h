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

#ifndef FCTypes_h
#define FCTypes_h

#include "FCColor.h"
#include "FCKeys.h"

#include <map>
#include <string>
#include <vector>
#include <set>

typedef uint32_t FCHandle;	// should last a while 8)

static const FCHandle kFCHandleInvalid = 0;
static const FCHandle kFCHandleFirstValid = 1;

extern FCHandle NewFCHandle( void );

// Some common container types.

typedef std::vector<std::string>		FCStringVector;
typedef FCStringVector::iterator		FCStringVectorIter;
typedef FCStringVector::const_iterator	FCStringVectorConstIter;

typedef std::map<std::string, std::string>	FCStringStringMap;
typedef FCStringStringMap::iterator			FCStringStringMapIter;
typedef FCStringStringMap::const_iterator	FCStringStringMapConstIter;

typedef std::set<std::string>	FCStringSet;

#endif // FCTypes_h
