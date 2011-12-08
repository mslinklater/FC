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

#import <Foundation/Foundation.h>
#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>
#import "Maths/FCVector.h"

extern void FCGLCheckErrors( void );

extern void FCGLLogVersions( void );
extern void FCGLLogCaps( void );
extern void FCGLLogState( void );

extern NSString* FCGLStringForEnum( GLenum thisEnum);

// Vendor stuff

extern NSString* FCGLQueryVendor( void );
extern NSString* FCGLQueryVersion( void );
extern NSString* FCGLQueryRenderer( void );
extern NSString* FCGLQueryShadingLanguageVersion( void );
extern NSArray* FCGLQueryExtensions( void );

// Caps

extern GLint FCGLCapsMaxTextureSize( void );

#if defined (DEBUG)
#define GLCHECK FCGLCheckErrors()
#else
#define GLCHECK
#endif

#endif // TARGET_OS_IPHONE
