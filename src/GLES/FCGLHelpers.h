#ifndef FCGLHELPERS_H
#define FCGLHELPERS_H

#ifdef __APPLE__
#include "TargetConditionals.h"

#ifdef PLATFORM_IOS
#include <OpenGLES/ES2/gl.h>
#include <OpenGLES/ES2/glext.h>
#endif

#endif	// __APPLE__

#ifdef PLATFORM_ANDROID
#include <GLES2/gl2.h>
#include <GLES2/gl2ext.h>
#include <GLES2/gl2platform.h>
#endif


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

#if defined (FC_DEBUG)
#define GLCHECK FCGLCheckErrors()
#else
#define GLCHECK
#endif

#endif // FCGLHELPERS_H
