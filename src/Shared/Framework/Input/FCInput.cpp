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

#include "FCInput.h"
#include "Shared/Lua/FCLua.h"
#include "FCInput_platform.h"

static FCInput* s_pInstance;

void FCInput::PlatformTapSubscriber( const std::string& viewName, const FCVector2f &pos )
{
	TapSubscriberMap& tapSubscribers = s_pInstance->m_screens[ viewName ].m_tapSubscribers;
	
	for (TapSubscriberMapIter i = tapSubscribers.begin(); i != tapSubscribers.end(); i++) {
		// call Lua
		
		FCLua::Instance()->CoreVM()->CallFuncWithSig(i->second, true, "ff>", pos.x, pos.y);
	}
}

FCInput::FCInput()
{
	plt_FCInput_SetTapSubscriberFunc( PlatformTapSubscriber );
}

FCInput::~FCInput()
{
}

FCInput* FCInput::Instance()
{
	if (!s_pInstance) {
		s_pInstance = new FCInput;
	}
	return s_pInstance;
}

FCHandle FCInput::AddTapSubscriber( const std::string& viewName, const std::string& luaFunc )
{
	TapSubscriberMap& tapSubscribers = m_screens[ viewName ].m_tapSubscribers;
	
	FCHandle h = NewFCHandle();
	tapSubscribers[h] = luaFunc;
	
	plt_FCInput_AddTapToView( viewName );
	return h;
}

void FCInput::RemoveTapSubscriber( const std::string& viewName, FCHandle hFunc )
{
	TapSubscriberMap& tapSubscribers = m_screens[ viewName ].m_tapSubscribers;
	
	FC_ASSERT(tapSubscribers.find(hFunc) != tapSubscribers.end());
	
	tapSubscribers.erase( hFunc );
	plt_FCInput_RemoveTapFromView( viewName );
}


