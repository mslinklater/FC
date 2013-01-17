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

#include "FCError.h"
#include "Debug/FCConnect.h"
#include "Shared/FCPlatformInterface.h"

void FCHalt()
{
	plt_FCHalt();
}

void FCLog( std::string log )
{
#if defined(FC_CONNECT)
	FCConnect::Instance()->SendString(log);
#endif
	plt_FCLog(log.c_str());
}

void FCWarning( std::string message )
{
#if defined(FC_CONNECT)
	FCConnect::Instance()->SendString(message);
#endif
	plt_FCWarning(message.c_str());
}

void FCFatal( std::string message )
{
#if defined(FC_CONNECT)
	FCConnect::Instance()->SendString(message);
#endif
	plt_FCFatal(message.c_str());
}

void fc_FCError_Fatal( const char* error )
{
	FCFatal( error );
}

void fc_FCError_Log( const char* error )
{
	FCLog( error );
}

void fc_FCError_Warning( const char* error )
{
	FCWarning( error );
}


