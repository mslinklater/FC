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

#ifndef CR1_FCInput_h
#define CR1_FCInput_h

// subscribe to types of input

#include "Shared/Core/FCCore.h"

typedef void (*FCInputPlatformTapSubscriber)(const std::string& viewName, const FCVector2f& pos);

class FCInput : public FCBase
{
public:
	
	FCInput();
	virtual ~FCInput();
	
	static FCInput* Instance();
	
	FCHandle AddTapSubscriber( const std::string& viewName, const std::string& luaFunc );
	void RemoveTapSubscriber( const std::string& viewName, FCHandle h );
	
	static void PlatformTapSubscriber( const std::string& viewName, const FCVector2f& pos );
	
	typedef std::map<FCHandle, std::string>	TapSubscriberMap;
	typedef TapSubscriberMap::iterator		TapSubscriberMapIter;

	struct ScreenSubscribers {
		TapSubscriberMap	m_tapSubscribers;
	};

	typedef std::map<std::string,ScreenSubscribers> ScreenSubscribersMap;
	typedef ScreenSubscribersMap::iterator			ScreenSubscribersMapIter;
	
private:
	
	ScreenSubscribersMap	m_screens;
};

#endif
