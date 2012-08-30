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

#include "FCPhase.h"
#include "Shared/Lua/FCLua.h"

FCPhase::FCPhase( std::string name )
{
	m_name = name;
	m_state = kFCPhaseStateInactive;
	
	m_activateTimer = 0.0f;
	m_deactivateTimer = 0.0f;
	
	m_luaUpdateFunc = name + "Phase.Update";
	m_luaWasAddedToQueueFunc = name + "Phase.WasAddedToQueue";
	m_luaWasRemovedFromQueueFunc = name + "Phase.WasRemovedFromQueue";
	m_luaWillActivateFunc = name + "Phase.WillActivate";
	m_luaIsNowActiveFunc = name + "Phase.IsNowActive";
	m_luaWillDeactivateFunc = name + "Phase.WillDeactivate";
	m_luaIsNowDeactiveFunc = name + "Phase.IsNowDeactive";
	m_luaLoaded = false;
}

FCPhaseUpdate FCPhase::Update(float dt)
{
	FCLua::Instance()->CoreVM()->CallFuncWithSig(m_luaUpdateFunc, false, "");
	return kFCPhaseUpdateOK;
}

void FCPhase::WasAddedToQueue()
{
	if (!m_luaLoaded) {
		std::string path = m_name + "phase";
		FCLua::Instance()->CoreVM()->LoadScriptOptional( path );
		m_luaLoaded = true;
	}
	FCLua::Instance()->CoreVM()->CallFuncWithSig(m_luaWasAddedToQueueFunc, false, "");
}

void FCPhase::WasRemovedFromQueue()
{
	FCLua::Instance()->CoreVM()->CallFuncWithSig( m_luaWasRemovedFromQueueFunc, false, "");	
}

void FCPhase::WillActivate()
{
	
}

void FCPhase::WillActivatePostLua()
{
	
}

void FCPhase::IsNowActive()
{
	
}

void FCPhase::IsNowActivePostLua()
{
	
}

void FCPhase::WillDeactivate()
{
	
}

void FCPhase::WillDeactivatePostLua()
{
	
}

void FCPhase::IsNowDeactive()
{
	
}

void FCPhase::IsNowDeactivePostLua()
{
	
}
