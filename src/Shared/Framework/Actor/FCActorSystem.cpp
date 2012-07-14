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

#include "Shared/Core/FCCore.h"
#include "Shared/Lua/FCLua.h"
#include "FCActorSystem.h"

static FCActorSystem* s_pInstance;

static int lua_Reset( lua_State* _state )
{
	FC_LUA_ASSERT_NUMPARAMS(0);
	
	s_pInstance->Reset();
	return 0;
}

static int lua_GetActorPosition( lua_State* _state )
{
	FC_LUA_ASSERT_NUMPARAMS(1);
	FC_LUA_ASSERT_TYPE(1, LUA_TNUMBER);
	
	FCActorRef actor = s_pInstance->ActorWithHandle(lua_tointeger(_state, 1));
	FCVector3f pos = actor->Position();
	
	lua_pushnumber(_state, pos.x);
	lua_pushnumber(_state, pos.y);
	lua_pushnumber(_state, pos.z);
	
	return 3;
}

static int lua_SetActorPosition( lua_State* _state )
{
	FC_LUA_ASSERT_NUMPARAMS(4);
	FC_LUA_ASSERT_TYPE(1, LUA_TNUMBER);
	FC_LUA_ASSERT_TYPE(2, LUA_TNUMBER);
	FC_LUA_ASSERT_TYPE(3, LUA_TNUMBER);
	FC_LUA_ASSERT_TYPE(4, LUA_TNUMBER);
	
	FCHandle handle = lua_tointeger(_state, 1);
	
	FCVector3f pos;
	pos.x = (float)lua_tonumber(_state, 2);
	pos.y = (float)lua_tonumber(_state, 3);
	pos.z = (float)lua_tonumber(_state, 4);
	
	FCActorRef actor = s_pInstance->ActorWithHandle( handle );
	
	actor->SetPosition( pos );
	return 0;
}

static int lua_GetActorLinearVelocity( lua_State* _state )
{
	FC_LUA_ASSERT_NUMPARAMS(1);
	FC_LUA_ASSERT_TYPE(1, LUA_TNUMBER);
	
	FCHandle handle = lua_tointeger(_state, 1);
	FCActorRef actor = s_pInstance->ActorWithHandle( handle );
	FCVector3f vel = actor->LinearVelocity();
	
	lua_pushnumber(_state, vel.x);
	lua_pushnumber(_state, vel.y);
	lua_pushnumber(_state, vel.z);
	return 3;
}

static int lua_SetActorLinearVelocity( lua_State* _state )
{
	FC_LUA_ASSERT_NUMPARAMS(4);
	FC_LUA_ASSERT_TYPE(1, LUA_TNUMBER);
	FC_LUA_ASSERT_TYPE(2, LUA_TNUMBER);
	FC_LUA_ASSERT_TYPE(3, LUA_TNUMBER);
	FC_LUA_ASSERT_TYPE(4, LUA_TNUMBER);
	
	FCHandle handle = lua_tointeger(_state, 1);
	FCActorRef actor = s_pInstance->ActorWithHandle( handle );
	actor->SetLinearVelocity( FCVector3f( (float)lua_tonumber(_state, 2), (float)lua_tonumber(_state, 3), (float)lua_tonumber(_state, 4) ) );
	
	return 0;
}

static int lua_ApplyImpulse( lua_State* _state )
{
	FC_LUA_ASSERT_NUMPARAMS(4);
	FC_LUA_ASSERT_TYPE(1, LUA_TNUMBER);
	FC_LUA_ASSERT_TYPE(2, LUA_TNUMBER);
	FC_LUA_ASSERT_TYPE(3, LUA_TNUMBER);
	FC_LUA_ASSERT_TYPE(4, LUA_TNUMBER);
	
	FCHandle handle = lua_tointeger(_state, 1);
	FCActorRef actor = s_pInstance->ActorWithHandle( handle );
	actor->ApplyImpulseAtWorldPos( FCVector3f((float)lua_tonumber(_state, 2), (float)lua_tonumber(_state, 3),(float) lua_tonumber(_state, 4)), actor->Position());
	return 0;
}

FCActorSystem::FCActorSystem()
{
	FCLua::Instance()->CoreVM()->CreateGlobalTable("FCActorSystem");
	FCLua::Instance()->CoreVM()->RegisterCFunction(lua_Reset, "FCActorSystem.Reset");
	FCLua::Instance()->CoreVM()->RegisterCFunction(lua_GetActorPosition, "FCActorSystem.GetPosition");
	FCLua::Instance()->CoreVM()->RegisterCFunction(lua_SetActorPosition, "FCActorSystem.SetPosition");
	FCLua::Instance()->CoreVM()->RegisterCFunction(lua_GetActorLinearVelocity, "FCActorSystem.GetLinearVelocity");
	FCLua::Instance()->CoreVM()->RegisterCFunction(lua_SetActorLinearVelocity, "FCActorSystem.SetLinearVelocity");
	FCLua::Instance()->CoreVM()->RegisterCFunction(lua_ApplyImpulse, "FCActorSystem.ApplyImpulse");	
}

FCActorSystem::~FCActorSystem()
{
	
}

FCActorSystem* FCActorSystem::Instance()
{
	if (!s_pInstance) {
		s_pInstance = new FCActorSystem;
	}
	return s_pInstance;
}

void FCActorSystem::Init()
{
	FC_HALT;
}

FCActorRef FCActorSystem::ActorOfClass(std::string actorClass)
{
	FC_ASSERT(m_createFuncs.find(actorClass) != m_createFuncs.end());
	
	FCActorRef actor = (m_createFuncs[ actorClass ])();
	
	m_allActorsVec.push_back( actor );
	
	if (actor->NeedsUpdate() )
	{
		m_updateActorsVec.push_back(actor);		
	}
	
	if (actor->NeedsRender()) 
	{
		m_renderActorsVec.push_back(actor);
	}
	
	if (actor->RespondsToTapGesture())
	{
		m_tapGestureActorsVec.push_back(actor);		
	}
	
	return actor;
}

FCActorRef FCActorSystem::ActorWithFullName(std::string name)
{
	return m_actorFullNameMap[ name ];
}

FCActorRef FCActorSystem::ActorWithHandle(FCHandle handle)
{
	return m_actorHandleMap[ handle ];
}

void FCActorSystem::AddToDeleteArray(FCActorRef actor)
{
	m_deleteList.push_back(actor);
}

void FCActorSystem::RemoveActor(FCActorRef actor)
{
	if (actor->m_fullName.size())
	{
		m_actorFullNameMap.erase(actor->m_fullName);
	}
	
	if (actor->NeedsUpdate()) {
		for (FCActorRefVecIter i = m_updateActorsVec.begin(); i != m_updateActorsVec.end(); i++) {
			if (*i == actor) {
				m_updateActorsVec.erase(i);
				break;
			}
		}
	}
	
	if (actor->NeedsRender()) {
		for (FCActorRefVecIter i = m_renderActorsVec.begin(); i != m_renderActorsVec.end(); i++) {
			if (*i == actor) {
				m_renderActorsVec.erase(i);
				break;
			}
		}
	}
	
	if (actor->RespondsToTapGesture()) {
		for (FCActorRefVecIter i = m_tapGestureActorsVec.begin(); i != m_tapGestureActorsVec.end(); i++) {
			if (*i == actor) {
				m_tapGestureActorsVec.erase(i);
				break;
			}
		}
	}
	
	for (FCActorRefVecIter i = m_allActorsVec.begin(); i != m_allActorsVec.end(); i++) {
		if (*i == actor) {
			m_allActorsVec.erase(i);
			break;
		}
	}
	
	m_actorHandleMap.erase(actor->m_handle);

}

void FCActorSystem::RemoveAllActors()
{
	m_allActorsVec.clear();
	m_updateActorsVec.clear();
	m_renderActorsVec.clear();
	m_tapGestureActorsVec.clear();
	m_deleteList.clear();
	
	m_actorFullNameMap.clear();
	m_actorHandleMap.clear();
}

void FCActorSystem::Reset()
{
	RemoveAllActors();
}

FCActorRefVec FCActorSystem::CreateActors(std::string actorClass, FCResourceRef res, std::string name)
{
	FCActorRefVec createdActors;
	
	FCXMLNodeVec actors;
	
	if (res) {
		actors = res->XML()->VectorForKeyPath("fcr.scene.actor");
		
		for (FCXMLNodeVecIter i = actors.begin(); i != actors.end(); i++) 
		{
			FCActorRef createdActor = CreateActor(*i, actorClass, res, name);
			createdActors.push_back(createdActor);
		}
	} else {
		FCActorRef createdActor = CreateActor(actorClass, name);
		createdActors.push_back(createdActor);
	}
		
	return createdActors;
}

FCActorRef FCActorSystem::CreateActor(std::string actorClass, std::string name)
{
	FCActorRef actor = ActorOfClass( actorClass );
	
	FCHandle handle = NewFCHandle();
	
	actor->m_handle = handle;

	m_actorHandleMap[ handle ] = actor;

	return actor;	
}

FCActorRef FCActorSystem::CreateActor(FCXMLNode actorXML, std::string actorClass, FCResourceRef res, std::string name)
{
	std::string bodyId = FCXML::StringValueForNodeAttribute(actorXML, kFCKeyBody);
	
	FCXMLNodeVec bodies = res->XML()->VectorForKeyPath("fcr.physics.bodies.body");
	
	// Find the body associated with this actor
	
	FCXMLNode bodyXML = 0;
	for (FCXMLNodeVecIter i = bodies.begin(); i != bodies.end(); i++) 
	{
		std::string thisId = FCXML::StringValueForNodeAttribute(*i, kFCKeyId);
		if (thisId == bodyId) 
		{
			bodyXML = *i;
			break;
		}
	}
	
	// get model
	
	FCXMLNode modelXML = 0;
	std::string modelId = FCXML::StringValueForNodeAttribute(actorXML, kFCKeyModel);
	if (modelId.length())
	{
		FCXMLNodeVec models = res->XML()->VectorForKeyPath("fcr.models.model");
		
		for (FCXMLNodeVecIter i = models.begin(); i != models.end(); i++) 
		{
			std::string thisId = FCXML::StringValueForNodeAttribute(*i, kFCKeyId);
			if (modelId == thisId) 
			{
				modelXML = *i;
				break;
			}
		}
	}
	
	// instantiate actor
	
	FCActorRef actor = ActorOfClass( actorClass );
	
	FCHandle handle = NewFCHandle();
	
	actor->Init(actorXML, bodyXML, modelXML, res, name, handle);
	
	// some more checks etc
	
	std::string actorId = FCXML::StringValueForNodeAttribute(actorXML, kFCKeyId);
	
	if (name.size()) // id is optional
	{
		actor->m_fullName = name + "_" + actorId;
		
		FC_ASSERT( m_actorFullNameMap.find(actor->m_fullName) == m_actorFullNameMap.end() );
		
		m_actorFullNameMap[ actor->m_fullName ] = actor;
	}
	
	// handle
	
	m_actorHandleMap[ handle ] = actor;
	
	return actor;	
}

void FCActorSystem::Update(float realTime, float gameTime)
{
	for (FCActorRefVecIter i = m_deleteList.begin(); i != m_deleteList.end(); i++) {
		RemoveActor( *i );
	}
	
	m_deleteList.clear();
	
	// update active actors
	
	for (FCActorRefVecIter i = m_updateActorsVec.begin(); i != m_updateActorsVec.end(); i++) 
	{
		(*i)->Update( realTime, gameTime );
	}
}
