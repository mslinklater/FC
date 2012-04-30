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

#ifndef CR1_FCError_h
#define CR1_FCError_h

#include <string>
#include <sstream>

class lua_State;

//extern void FCError_RegisterLuaFunctions( lua_State* _state );

extern void FCHalt();

extern void FCLog( std::string log );

//extern void FCAssert( bool condition );

extern void FCFatal( std::string message );

extern void FCWarning( std::string message );

// Always present ----------------------------

#define FC_HALT FCHalt()
#define FC_UNUSED( n ) (void)n

// Only when debug ---------------------------

#if defined (DEBUG)

#define FC_LOG( n ) FCLog( n )
#define FC_WARNING( n ) FCWarning( n )
					
// Release stubs -----------------------------

#else // DEBUG

#define

#define FC_LOG( n )
#define FC_WARNING( n )

#endif // DEBUG

// Always present ----------------------------

#define FC_ASSERT( n ) if(!(n)) FC_HALT
#define FC_ASSERT_MSG( n, msg ) if(!(n)){ FC_LOG( msg ); FC_HALT; }
#define FC_FATAL( n ) FCFatal( n )

#endif
