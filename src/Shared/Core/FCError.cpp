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

extern void plt_FCHalt();
extern void plt_FCLog( std::string log );
extern void plt_FCWarning( std::string log );
extern void plt_FCFatal( std::string log );

void FCHalt()
{
	plt_FCHalt();
}

void FCLog( std::string log )
{
	FCConnect::Instance()->SendString(log);
	plt_FCLog(log);
}

void FCWarning( std::string message )
{
	FCConnect::Instance()->SendString(message);
	plt_FCWarning(message);
}

void FCFatal( std::string message )
{
	FCConnect::Instance()->SendString(message);
	plt_FCFatal(message);
}

