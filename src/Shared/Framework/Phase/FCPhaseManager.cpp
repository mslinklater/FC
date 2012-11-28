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

#include "FCPhaseManager.h"
#include "Shared/Lua/FCLua.h"

static FCPhaseManager* s_pInstance = 0;

static int lua_AddPhaseToQueue( lua_State* _state )
{
	FC_LUA_FUNCDEF("FCPhaseManager.AddPhaseToQueue()");
	FC_LUA_ASSERT_NUMPARAMS(1);
	FC_LUA_ASSERT_TYPE(-1, LUA_TSTRING);

	const char* pPhaseName = lua_tostring( _state, -1);

	s_pInstance->AddPhaseToQueue( pPhaseName );
	
	return 0;
}

static int lua_DeactivatePhase( lua_State* _state )
{
	FC_LUA_FUNCDEF("FCPhaseManager.DeactivatePhase()");
	FC_LUA_ASSERT_NUMPARAMS(1);
	FC_LUA_ASSERT_TYPE(-1, LUA_TSTRING);
	
	const char* pPhaseName = lua_tostring( _state, -1);
	
	s_pInstance->DeactivatePhase( pPhaseName );
	
	return 0;	
}

FCPhaseManager* FCPhaseManager::Instance()
{
	if (!s_pInstance) {
		s_pInstance = new FCPhaseManager;
	}
	return s_pInstance;
}

FCPhaseManager::FCPhaseManager()
{
	m_rootPhase = FCPhaseRef( new FCPhase( "root" ) );

	FCLua::Instance()->CoreVM()->CreateGlobalTable("FCPhaseManager");
	FCLua::Instance()->CoreVM()->RegisterCFunction(lua_AddPhaseToQueue, "FCPhaseManager.AddPhaseToQueue");
	FCLua::Instance()->CoreVM()->RegisterCFunction(lua_DeactivatePhase, "FCPhaseManager.DeactivatePhase");
}

FCPhaseManager::~FCPhaseManager()
{
	
}

void FCPhaseManager::DeactivatePhase(std::string name)
{
	for (FCPhaseRefVectorIter i = m_activePhases.begin(); i != m_activePhases.end(); i++) {
		
		FCPhaseRef phasePtr = *i;
		
		if (phasePtr->Name() == name) {
			FCPhaseRef freshPhase = m_phaseQueue[0];
			m_activePhases.push_back(freshPhase);
			m_phaseQueue.erase(m_phaseQueue.begin());
			
			freshPhase->WillActivate();
			FCLua::Instance()->CoreVM()->CallFuncWithSig(freshPhase->LuaWillActivateFunc(), false, "");
			freshPhase->WillActivatePostLua();
			
			freshPhase->SetState( kFCPhaseStateActivating );
			
			phasePtr->WillDeactivate();
			FCLua::Instance()->CoreVM()->CallFuncWithSig(phasePtr->LuaWillDeactivateFunc(), false, "");
			phasePtr->WillDeactivatePostLua();
			
			phasePtr->SetState( kFCPhaseStateDeactivating );
			return;
		}
	}
	FC_FATAL( std::string("Phase ") + name + " is not active" );
}

void FCPhaseManager::Update(float dt)
{
	if (m_activePhases.size() == 0) {
		if (m_phaseQueue.size() > 0) {
			FCPhaseRef firstPhase = m_phaseQueue[0];
			
			firstPhase->WillActivate();
			FCLua::Instance()->CoreVM()->CallFuncWithSig(firstPhase->LuaWillActivateFunc(), false, "");
			firstPhase->WillActivatePostLua();
			
			firstPhase->SetState( kFCPhaseStateActivating );
			m_activePhases.push_back(firstPhase);
			m_phaseQueue.erase(m_phaseQueue.begin());
		}
	}
	
	FCPhaseRefVector deleteVec;
	
	for (FCPhaseRefVectorConstIter i = m_activePhases.begin(); i != m_activePhases.end(); i++) 
	{
		FCPhaseRef phasePtr = *i;
		
		switch (phasePtr->Update(dt)) {
			case kFCPhaseUpdateOK:
				break;
			case kFCPhaseUpdateDeactivate:
				DeactivatePhase( phasePtr->Name() );
				break;
			default:
				break;
		}
		
		switch( phasePtr->State() ) {
			case kFCPhaseStateActivating:
				if (phasePtr->ActivateTimer() <= 0.0) {
					phasePtr->SetState( kFCPhaseStateUpdating );
					phasePtr->IsNowActive();
					FCLua::Instance()->CoreVM()->CallFuncWithSig(phasePtr->LuaIsNowActiveFunc(), false, "");
					phasePtr->IsNowActivePostLua();					
				} else {
					phasePtr->DecrementActivateTimer( dt );
				}
				break;
			case kFCPhaseStateDeactivating:
				if (phasePtr->DeactivateTimer() <= 0.0) {
					phasePtr->SetState( kFCPhaseStateInactive );
					phasePtr->IsNowDeactive();
					FCLua::Instance()->CoreVM()->CallFuncWithSig(phasePtr->LuaIsNowDeactiveFunc(), false, "");
					phasePtr->IsNowDeactivePostLua();
					deleteVec.push_back( phasePtr );
				} else {
					phasePtr->DecrementDeactivateTimer( dt );
				}
				break;
			default:
				break;
		}
	}
	
	for (FCPhaseRefVectorIter i = deleteVec.begin(); i != deleteVec.end(); i++) 
	{
		for (FCPhaseRefVectorIter j = m_activePhases.begin(); j != m_activePhases.end(); j++) 
		{
			if ((*i)->Name() == (*j)->Name())
			{
				m_activePhases.erase(j);
				break;
			}
		}
	}
}

void FCPhaseManager::AttachPhase(FCPhaseRef phase)
{
	phase->m_parent = m_rootPhase;
	m_rootPhase->m_children[ phase->Name() ] = phase;
}

void FCPhaseManager::AddPhaseToQueue(std::string name)
{
	FC_ASSERT(m_rootPhase->m_children.find(name) != m_rootPhase->m_children.end());
	
	FCPhaseRef thisPhase = m_rootPhase->m_children[ name ];
	
	m_phaseQueue.push_back(thisPhase);
	thisPhase->WasAddedToQueue();
}
