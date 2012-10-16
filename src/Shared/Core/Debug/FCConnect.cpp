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

#include "FCConnect.h"
#include "Shared/FCPlatformInterface.h"

FCConnect* FCConnect::Instance()
{
	static FCConnect* s_pInstance = 0;
	if (!s_pInstance) {
		s_pInstance = new FCConnect;
	}
	return s_pInstance;
}

bool FCConnect::Start()
{
	return plt_FCConnect_Start();
}

bool FCConnect::EnableWithName( std::string name )
{
	return plt_FCConnect_EnableWithName( name.c_str() );
}

void FCConnect::Stop()
{
	plt_FCConnect_Stop();
}

void FCConnect::SendString( std::string s )
{
	plt_FCConnect_SendString( s.c_str() );
}