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

#ifndef FCGLHELPERS_H
#define FCGLHELPERS_H

#include <OpenGLES/EAGL.h>
#include <OpenGLES/ES2/gl.h>
#include <OpenGLES/ES2/glext.h>

#include <string>

extern void FCGLCheckErrors( void );

extern void FCGLLogVersions( void );
extern void FCGLLogCaps( void );
extern void FCGLLogState( void );

extern std::string FCGLStringForEnum( GLenum thisEnum);

// Vendor stuff

extern std::string FCGLQueryVendor( void );
extern std::string FCGLQueryVersion( void );
extern std::string FCGLQueryRenderer( void );
extern std::string FCGLQueryShadingLanguageVersion( void );
extern std::string FCGLQueryExtensions( void );

// Caps

extern GLint FCGLCapsMaxTextureSize( void );

#if defined (DEBUG)
#define GLCHECK FCGLCheckErrors()
#else
#define GLCHECK
#endif

#endif // FCGLHELPERS_H