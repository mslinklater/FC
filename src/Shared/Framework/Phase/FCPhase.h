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

#ifndef FCPHASE_H
#define FCPHASE_H


#include "Shared/Core/FCCore.h"

enum FCPhaseUpdate {
	kFCPhaseUpdateOK,
	kFCPhaseUpdateDeactivate
};

enum FCPhaseState {
	kFCPhaseStateInactive,
	kFCPhaseStateActivating,
	kFCPhaseStateUpdating,
	kFCPhaseStateDeactivating
};

class FCPhase;

typedef FCSharedPtr<FCPhase> FCPhaseRef;
typedef std::vector<FCPhaseRef>	FCPhaseRefVector;
typedef FCPhaseRefVector::iterator	FCPhaseRefVectorIter;
typedef FCPhaseRefVector::const_iterator	FCPhaseRefVectorConstIter;
typedef std::map<std::string, FCPhaseRef>	FCPhaseRefMapByString;

class FCPhase : public FCBase
{
public:
	
	FCPhase( std::string name );
	virtual ~FCPhase(){}
	
	virtual FCPhaseUpdate Update( float dt );
	virtual void WasAddedToQueue();
	virtual void WasRemovedFromQueue();
	virtual void WillActivate();
	virtual void IsNowActive();
	virtual void WillDeactivate();
	virtual void IsNowDeactive();
	virtual void WillActivatePostLua();
	virtual void IsNowActivePostLua();
	virtual void WillDeactivatePostLua();
	virtual void IsNowDeactivePostLua();
	
	const std::string&	Name() const { return m_name; }
	void SetName( std::string name ){ m_name = name; }
	
	const std::string&	LuaWillActivateFunc() const { return m_luaWillActivateFunc; }
	const std::string&	LuaWillDeactivateFunc() const { return m_luaWillDeactivateFunc; }
	const std::string&	LuaIsNowActiveFunc() const { return m_luaIsNowActiveFunc; }
	const std::string&	LuaIsNowDeactiveFunc() const { return m_luaIsNowDeactiveFunc; }
	
	FCPhaseState	State() const { return m_state; }
	void			SetState( FCPhaseState state ){ m_state = state; }
	
	float	ActivateTimer(){ return m_activateTimer; }
	void	DecrementActivateTimer( float amount ){ m_activateTimer -= amount; }

	float	DeactivateTimer(){ return m_deactivateTimer; }
	void	DecrementDeactivateTimer( float amount ){ m_deactivateTimer -= amount; }

	FCPhaseRef	m_parent;
	FCPhaseRefMapByString	m_children;

protected:
	std::string m_name;
	std::string	m_namePath;
	FCPhaseRef	m_activeChild;
	float		m_activateTimer;
	float		m_deactivateTimer;
	FCPhaseState	m_state;
	std::string	m_luaTable;
	bool		m_luaLoaded;
	std::string	m_luaUpdateFunc;
	std::string m_luaWasAddedToQueueFunc;
	std::string	m_luaWasRemovedFromQueueFunc;
	std::string	m_luaWillActivateFunc;
	std::string	m_luaIsNowActiveFunc;
	std::string	m_luaWillDeactivateFunc;
	std::string	m_luaIsNowDeactiveFunc;
};

#endif // FCPHASE_H
