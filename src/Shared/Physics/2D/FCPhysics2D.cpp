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

#include "FCPhysics2D.h"
#include "Shared/Lua/FCLua.h"

#include "Shared/Framework/Gameplay/FCObjectManager.h"

static FCPhysics2D* s_pInstance = 0;

static int lua_CreateDistanceJoint( lua_State* _state )
{	
	FC_LUA_FUNCDEF("FCPhysics2D.CreateDistanceJoint()");
	FC_ASSERT(lua_gettop(_state) >= 4);
	FC_LUA_ASSERT_TYPE(1, LUA_TSTRING);
	
	FCPhysics2DDistanceJointCreateDefRef def = FCPhysics2DDistanceJointCreateDefRef( new FCPhysics2DDistanceJointCreateDef );
	
	std::string body1Name = lua_tostring(_state, 1);
	def->body1 = s_pInstance->BodyWithName( body1Name );
	
	FC_ASSERT(def->body1);
	
	int obj2NameStackPos;
	
	if (lua_isnumber(_state, 2)) 
	{
		obj2NameStackPos = 4;
		
		FCVector2f pos = FCVector2f( (float)lua_tonumber(_state, 2), (float)lua_tonumber(_state, 3) );
		FCVector3f body1Pos = def->body1->Position();
		pos += FCVector2f( body1Pos.x, body1Pos.y );
		def->pos1 = pos;
	} 
	else 
	{
		obj2NameStackPos = 3;
		FCXMLNode null = FCObjectManager::Instance()->Nulls()[ lua_tostring(_state, 2) ];
		def->pos1 = FCVector2f( FCXML::FloatValueForNodeAttribute(null, kFCKeyOffsetX), FCXML::FloatValueForNodeAttribute(null, kFCKeyOffsetY) ); 
	}
	
	FC_LUA_ASSERT_TYPE(obj2NameStackPos, LUA_TSTRING);
	
	std::string body2Name = lua_tostring(_state, obj2NameStackPos);
	def->body2 = s_pInstance->BodyWithName( body2Name );
	
	FC_ASSERT(def->body2);
	
	if (lua_isnumber(_state, obj2NameStackPos+1)) 
	{
		FCVector2f pos = FCVector2f( (float)lua_tonumber(_state, obj2NameStackPos+1), (float)lua_tonumber(_state, obj2NameStackPos+2) );
		FCVector3f body2Pos = def->body2->Position();
		pos += FCVector2f( body2Pos.x, body2Pos.y );
		def->pos2 = pos;
	} 
	else 
	{
		FCXMLNode null = FCObjectManager::Instance()->Nulls()[ lua_tostring(_state, obj2NameStackPos+1) ];
		
		FC_ASSERT(null);
		
		def->pos2 = FCVector2f( FCXML::FloatValueForNodeAttribute(null, kFCKeyOffsetX), FCXML::FloatValueForNodeAttribute(null, kFCKeyOffsetY));
	}
	
	// call through to OBJ-C
	
	FCHandle hJoint = s_pInstance->CreateDistanceJoint( def );
	
	lua_pushinteger(_state, hJoint);
	
	return 1;
}

static int lua_CreateRevoluteJoint( lua_State* _state )
{
	FC_LUA_FUNCDEF("FCPhysics2D.CreateRevoluteJoint()");
	FC_ASSERT(lua_gettop(_state) >= 3);
	FC_LUA_ASSERT_TYPE(1, LUA_TSTRING);
	FC_LUA_ASSERT_TYPE(2, LUA_TSTRING);
	
	FCPhysics2DRevoluteJointCreateDefRef def = FCPhysics2DRevoluteJointCreateDefRef( new FCPhysics2DRevoluteJointCreateDef );
	
	def->body1 = s_pInstance->BodyWithName(lua_tostring(_state, 1));
	FC_ASSERT(def->body1);
	def->body2 = s_pInstance->BodyWithName(lua_tostring(_state, 2));
	FC_ASSERT(def->body2);
	
	if (lua_isnumber(_state, 3)) {
		FCVector2f pos = FCVector2f( (float)lua_tonumber(_state, 3), (float)lua_tonumber(_state, 4) );
		FCVector3f body2Pos = def->body2->Position();
		pos += FCVector2f( body2Pos.x, body2Pos.y );
		def->pos = pos;
	} else
	{
		FCXMLNode null = FCObjectManager::Instance()->Nulls()[ std::string(lua_tostring(_state, 3)) ];
		FC_ASSERT(null);
		def->pos = FCVector2f( FCXML::FloatValueForNodeAttribute(null, kFCKeyOffsetX), FCXML::FloatValueForNodeAttribute(null, kFCKeyOffsetY) );
	}
	
	FCHandle hJoint = s_pInstance->CreateRevoluteJoint( def );
	
	lua_pushinteger(_state, hJoint);
	
	return 1;
}

static int lua_CreatePrismaticJoint( lua_State* _state )
{
	FC_LUA_FUNCDEF("FCPhysics2D.CreatePrismaticJoint()");
	FC_LUA_ASSERT_NUMPARAMS(3);
	FC_LUA_ASSERT_TYPE(1, LUA_TSTRING);
	FC_LUA_ASSERT_TYPE(2, LUA_TSTRING);
	FC_LUA_ASSERT_TYPE(3, LUA_TSTRING);
	
	FCPhysics2DPrismaticJointCreateDefRef def = FCPhysics2DPrismaticJointCreateDefRef( new FCPhysics2DPrismaticJointCreateDef );
	
	def->body1 = s_pInstance->BodyWithName(lua_tostring(_state, 1));
	FC_ASSERT(def->body1);
	def->body2 = s_pInstance->BodyWithName(lua_tostring(_state, 2));
	FC_ASSERT(def->body2);
	
	FCXMLNode null = FCObjectManager::Instance()->Nulls()[std::string(lua_tostring(_state, 3))];
	FC_ASSERT(null);
	
	float angle = FCXML::FloatValueForNodeAttribute(null, kFCKeyRotationZ);
	angle = FCDegToRad(angle);
	FCVector2f axis( (float)sin(angle), (float)cos(angle) );
	def->axis = axis;
	
	FCHandle hJoint = s_pInstance->CreatePrismaticJoint( def );
	
	lua_pushinteger(_state, hJoint);
	
	return 1;
}

static int lua_CreatePulleyJoint( lua_State* _state )
{
	FC_LUA_FUNCDEF("FCPhysics2D.CreatePulleyJoint()");
	FC_LUA_ASSERT_NUMPARAMS(7);
	FC_LUA_ASSERT_TYPE(1, LUA_TSTRING);
	FC_LUA_ASSERT_TYPE(2, LUA_TSTRING);
	FC_LUA_ASSERT_TYPE(3, LUA_TSTRING);
	FC_LUA_ASSERT_TYPE(4, LUA_TSTRING);
	FC_LUA_ASSERT_TYPE(5, LUA_TSTRING);
	FC_LUA_ASSERT_TYPE(6, LUA_TSTRING);
	FC_LUA_ASSERT_TYPE(7, LUA_TNUMBER);
	
	FCPhysics2DPulleyJointCreateDefRef def = FCPhysics2DPulleyJointCreateDefRef( new FCPhysics2DPulleyJointCreateDef );
	
	def->body1 = s_pInstance->BodyWithName(lua_tostring(_state, 1));
	FC_ASSERT(def->body1);
	def->body2 = s_pInstance->BodyWithName(lua_tostring(_state, 2));
	FC_ASSERT(def->body2);
	
	FCXMLNode groundAnchor1 = FCObjectManager::Instance()->Nulls()[std::string(lua_tostring(_state, 3))];
	FC_ASSERT(groundAnchor1);
	def->groundAnchor1 = FCVector2f( FCXML::FloatValueForNodeAttribute(groundAnchor1, kFCKeyOffsetX), FCXML::FloatValueForNodeAttribute(groundAnchor1, kFCKeyOffsetX) );
	
	FCXMLNode groundAnchor2 = FCObjectManager::Instance()->Nulls()[std::string(lua_tostring(_state, 4))];
	FC_ASSERT(groundAnchor2);
	def->groundAnchor2 = FCVector2f( FCXML::FloatValueForNodeAttribute(groundAnchor2, kFCKeyOffsetX), FCXML::FloatValueForNodeAttribute(groundAnchor2, kFCKeyOffsetY) );
	
	FCXMLNode bodyAnchor1 = FCObjectManager::Instance()->Nulls()[std::string(lua_tostring(_state, 5))];
	FC_ASSERT(bodyAnchor1);
	def->bodyAnchor1 = FCVector2f( FCXML::FloatValueForNodeAttribute(bodyAnchor1, kFCKeyOffsetX), FCXML::FloatValueForNodeAttribute(bodyAnchor1, kFCKeyOffsetY) );
	
	FCXMLNode bodyAnchor2 = FCObjectManager::Instance()->Nulls()[std::string(lua_tostring(_state, 6))];
	FC_ASSERT(bodyAnchor2);
	def->bodyAnchor2 = FCVector2f( FCXML::FloatValueForNodeAttribute(bodyAnchor2, kFCKeyOffsetX), FCXML::FloatValueForNodeAttribute(bodyAnchor2, kFCKeyOffsetY) );
	
	def->ratio = (float)lua_tonumber(_state, 7);
	
	FCHandle hJoint = s_pInstance->CreatePulleyJoint( def );
	
	lua_pushinteger(_state, hJoint);
	
	return 1;
}

static int lua_CreateRopeJoint( lua_State* _state )
{
	FC_LUA_FUNCDEF("FCPhysics2D.CreateRopeJoint()");
	FC_LUA_ASSERT_NUMPARAMS(6);
	FC_LUA_ASSERT_TYPE(1, LUA_TSTRING);
	FC_LUA_ASSERT_TYPE(2, LUA_TSTRING);
	FC_LUA_ASSERT_TYPE(3, LUA_TNUMBER);
	FC_LUA_ASSERT_TYPE(4, LUA_TNUMBER);
	FC_LUA_ASSERT_TYPE(5, LUA_TNUMBER);
	FC_LUA_ASSERT_TYPE(6, LUA_TNUMBER);
	
	FCPhysics2DRopeJointCreateDefRef def = FCPhysics2DRopeJointCreateDefRef( new FCPhysics2DRopeJointCreateDef );
	
	def->body1 = s_pInstance->BodyWithName(lua_tostring(_state, 1));
	FC_ASSERT(def->body1);
	def->body2 = s_pInstance->BodyWithName(lua_tostring(_state, 2));
	FC_ASSERT(def->body2);
	
	def->bodyAnchor1 = FCVector2f( (float)lua_tonumber(_state, 3), (float)lua_tonumber(_state, 4) );
	def->bodyAnchor2 = FCVector2f( (float)lua_tonumber(_state, 5), (float)lua_tonumber(_state, 6) );
	
	FCHandle hJoint = s_pInstance->CreateRopeJoint( def );
	
	lua_pushinteger(_state, hJoint);
	
	return 1;
}

static int lua_SetRevoluteJointLimits( lua_State* _state )
{
	FC_LUA_FUNCDEF("FCPhysics2D.SetRevoluteJointLimits()");
	FC_LUA_ASSERT_NUMPARAMS(3);
	FC_LUA_ASSERT_TYPE(1, LUA_TNUMBER);
	FC_LUA_ASSERT_TYPE(2, LUA_TNUMBER);
	FC_LUA_ASSERT_TYPE(3, LUA_TNUMBER);
	
	FCHandle hJoint = (FCHandle)lua_tointeger(_state, 1);
	float min = (float)lua_tonumber(_state, 2);
	float max = (float)lua_tonumber(_state, 3);
	
	if ( min != max ) {
		s_pInstance->SetRevoluteJointLimits(hJoint, true, min, max);
	} else {
		s_pInstance->SetRevoluteJointLimits(hJoint, false, 0, 0);
	}
	
	return 0;
}

static int lua_SetRevoluteJointMotor( lua_State* _state )
{
	FC_LUA_FUNCDEF("FCPhysics2D.SetRevoluteJointMotor()");
	FC_LUA_ASSERT_NUMPARAMS(3);
	FC_LUA_ASSERT_TYPE(1, LUA_TNUMBER);
	FC_LUA_ASSERT_TYPE(2, LUA_TNUMBER);
	FC_LUA_ASSERT_TYPE(3, LUA_TNUMBER);
	
	FCHandle hJoint = (FCHandle)lua_tointeger(_state, 1);
	float speed = (float)lua_tonumber(_state, 2);
	float torque = (float)lua_tonumber(_state, 3);
	
	if ( (speed != 0.0f) && (torque != 0.0f) ) {
		s_pInstance->SetRevoluteJointMotor(hJoint, true, torque, speed);
	} else {
		s_pInstance->SetRevoluteJointMotor(hJoint, false, 0, 0);
	}
	
	return 0;
}

static int lua_SetPrismaticJointLimits( lua_State* _state )
{
	FC_LUA_FUNCDEF("FCPhysics2D.SetPrismaticJointLimits()");
	FC_LUA_ASSERT_NUMPARAMS(3);
	FC_LUA_ASSERT_TYPE(1, LUA_TNUMBER);
	FC_LUA_ASSERT_TYPE(2, LUA_TNUMBER);
	FC_LUA_ASSERT_TYPE(3, LUA_TNUMBER);
	
	FCHandle hJoint = (FCHandle)lua_tointeger(_state, 1);
	float min = (float)lua_tonumber(_state, 2);
	float max = (float)lua_tonumber(_state, 3);
	
	if ( min != max ) {
		s_pInstance->SetPrismaticJointLimits(hJoint, true, min, max);
	} else {
		s_pInstance->SetPrismaticJointLimits(hJoint, false, 0, 0);
	}
	
	return 0;
}

static int lua_SetPrismaticJointMotor( lua_State* _state )
{
	FC_LUA_FUNCDEF("FCPhysics2D.SetPrismaticJointMotor()");
	FC_LUA_ASSERT_NUMPARAMS(3);
	FC_LUA_ASSERT_TYPE(1, LUA_TNUMBER);
	FC_LUA_ASSERT_TYPE(2, LUA_TNUMBER);
	FC_LUA_ASSERT_TYPE(3, LUA_TNUMBER);
	
	FCHandle hJoint = (FCHandle)lua_tointeger(_state, 1);
	float speed = (float)lua_tonumber(_state, 2);
	float force = (float)lua_tonumber(_state, 3);
	
	if ( (speed != 0.0f) && (force != 0.0f) ) {
		s_pInstance->SetPrismaticJointMotor(hJoint, true, force, speed);
	} else {
		s_pInstance->SetPrismaticJointMotor(hJoint, false, 0, 0);
	}
	
	return 0;
}

static int lua_GetBodyAngularVelocity( lua_State* _state )
{
	FC_LUA_FUNCDEF("FCPhysics2D.GetBodyAngularVelocity()");
	FC_LUA_ASSERT_NUMPARAMS(1);
	FC_LUA_ASSERT_TYPE(1, LUA_TSTRING);
	
	FCPhysics2DBodyRef thisBody = s_pInstance->BodyWithName(lua_tostring(_state, 1));
	
	lua_pushnumber(_state, thisBody->AngularVelocity());
	return 1;
}



FCPhysics2D::FCPhysics2D()
: m_pWorld(0)
, m_contactListener(0)
{
	m_gravity.x = m_gravity.y = 0.0f;
	s_pInstance = this;
}

FCPhysics2D::~FCPhysics2D()
{	
	delete m_contactListener; m_contactListener = 0;
	delete m_pWorld; m_pWorld = 0;
	s_pInstance = 0;
}

void FCPhysics2D::Init()
{
	FCLua::Instance()->CoreVM()->CreateGlobalTable("FCPhysics2D");
	FCLua::Instance()->CoreVM()->RegisterCFunction(lua_CreateDistanceJoint, "FCPhysics2D.CreateDistanceJoint");
	FCLua::Instance()->CoreVM()->RegisterCFunction(lua_CreateRevoluteJoint, "FCPhysics2D.CreateRevoluteJoint");
	FCLua::Instance()->CoreVM()->RegisterCFunction(lua_CreatePrismaticJoint, "FCPhysics2D.CreatePrismaticJoint");
	FCLua::Instance()->CoreVM()->RegisterCFunction(lua_CreatePulleyJoint, "FCPhysics2D.CreatePulleyJoint");
	FCLua::Instance()->CoreVM()->RegisterCFunction(lua_CreateRopeJoint, "FCPhysics2D.CreateRopeJoint");
	
	FCLua::Instance()->CoreVM()->RegisterCFunction(lua_SetRevoluteJointMotor, "FCPhysics2D.SetRevoluteJointMotor");
	FCLua::Instance()->CoreVM()->RegisterCFunction(lua_SetRevoluteJointLimits, "FCPhysics2D.SetRevoluteJointLimits");
	FCLua::Instance()->CoreVM()->RegisterCFunction(lua_SetPrismaticJointMotor, "FCPhysics2D.SetPrismaticJointMotor");
	FCLua::Instance()->CoreVM()->RegisterCFunction(lua_SetPrismaticJointLimits, "FCPhysics2D.SetPrismaticJointLimits");
	
	FCLua::Instance()->CoreVM()->RegisterCFunction(lua_GetBodyAngularVelocity, "FCPhysics2D.GetAngularVelocity");
	
	m_gravity = b2Vec2( 0.0f, -9.8f );
	
	if (!m_pWorld) 
	{
		m_pWorld = new b2World( m_gravity );
	}
	
	m_contactListener = new FCPhysics2DContactListener;
	
	m_pWorld->SetContactListener(m_contactListener);
}

void FCPhysics2D::PrepareForDealloc()
{
	s_pInstance = 0;
}

void FCPhysics2D::Update( float realTime, float gameTime )
{
	m_contactListener->Clear();
	if (gameTime > 0.0f) {
		m_pWorld->Step( gameTime, 8, 8 );
	}
	m_contactListener->DispatchToSubscribers();
}

FCPhysics2DBodyRef FCPhysics2D::CreateBody( FCPhysics2DBodyDefRef def, std::string name, FCHandle actorHandle )
{
	def->pWorld = m_pWorld;
	def->hActor = actorHandle;
	
	FCPhysics2DBodyRef body = FCPhysics2DBodyRef( new FCPhysics2DBody );
	body->InitWithDef(def);
	
	body->handle = actorHandle;
	
	if (name.length()) 
	{
		body->name = name + "_" + body->ID;
		m_bodiesByName[body->name] = body;
	}
	
	m_bodies[actorHandle] = body;
	
	return body;
}

void FCPhysics2D::DestroyBody( FCPhysics2DBodyRef body )
{
	m_bodies.erase(body->handle);
	if (body->name.length()) {
		m_bodiesByName.erase(body->name);
	}
}

FCPhysics2DBodyRef FCPhysics2D::BodyWithName( std::string name )
{
	FC_ASSERT(m_bodiesByName.find(name) != m_bodiesByName.end());
	return m_bodiesByName[name];
}

FCHandle FCPhysics2D::CreateDistanceJoint(FCPhysics2DDistanceJointCreateDefRef def)
{
	b2Vec2 pos1;
	pos1.x = def->pos1.x;
	pos1.y = def->pos1.y;
	
	b2Vec2 pos2;
	pos2.x = def->pos2.x;
	pos2.y = def->pos2.y;
	
	b2DistanceJointDef jointDef;
	jointDef.Initialize( def->body1->pBody, def->body2->pBody, pos1, pos2);
	jointDef.collideConnected = true;
	b2Joint* joint = m_pWorld->CreateJoint(&jointDef);

	FCHandle handle = FCHandleNew();
	
	m_joints[ handle ] = joint;
	return handle;
	
}

FCHandle FCPhysics2D::CreateRevoluteJoint(FCPhysics2DRevoluteJointCreateDefRef def)
{
	b2Vec2 pos;
	pos.x = def->pos.x;
	pos.y = def->pos.y;
	
	b2RevoluteJointDef jointDef;
	jointDef.Initialize( def->body1->pBody, def->body2->pBody, pos);
	jointDef.enableMotor = false;
	jointDef.enableLimit = false;
	b2Joint* joint = m_pWorld->CreateJoint(&jointDef);
	
	FCHandle handle = FCHandleNew();
	
	m_joints[ handle ] = joint;
	return handle;
}

FCHandle FCPhysics2D::CreatePrismaticJoint(FCPhysics2DPrismaticJointCreateDefRef def)
{
	b2Vec2 axis;
	axis.x = def->axis.x;
	axis.y = def->axis.y;
	
	b2Vec2 pos;
	pos.x = def->body2->Position().x;
	pos.y = def->body2->Position().y;
	
	b2PrismaticJointDef jointDef;
	jointDef.Initialize( def->body1->pBody, def->body2->pBody, pos, axis);
	
	b2Joint* joint = m_pWorld->CreateJoint(&jointDef);
	
	FCHandle handle = FCHandleNew();
	
	m_joints[ handle ] = joint;
	return handle;
}

FCHandle FCPhysics2D::CreatePulleyJoint(FCPhysics2DPulleyJointCreateDefRef def)
{
	b2PulleyJointDef jointDef;
	b2Vec2 groundAnchor1;
	groundAnchor1.x = def->groundAnchor1.x;
	groundAnchor1.y = def->groundAnchor1.y;
	
	b2Vec2 groundAnchor2;
	groundAnchor2.x = def->groundAnchor2.x;
	groundAnchor2.y = def->groundAnchor2.y;
	
	b2Vec2 bodyAnchor1;
	bodyAnchor1.x = def->bodyAnchor1.x;
	bodyAnchor1.y = def->bodyAnchor1.y;
	
	b2Vec2 bodyAnchor2;
	bodyAnchor2.x = def->bodyAnchor2.x;
	bodyAnchor2.y = def->bodyAnchor2.y;
	
	jointDef.Initialize( def->body1->pBody, def->body2->pBody, groundAnchor1, groundAnchor2,
						bodyAnchor1, bodyAnchor2, def->ratio );
	
	b2Joint* joint = m_pWorld->CreateJoint(&jointDef);
	
	FCHandle handle = FCHandleNew();
	
	m_joints[ handle ] = joint;
	return handle;
}

FCHandle FCPhysics2D::CreateRopeJoint(FCPhysics2DRopeJointCreateDefRef def)
{
	b2RopeJointDef jointDef;
	
	jointDef.bodyA = def->body1->pBody;
	jointDef.bodyB = def->body2->pBody;
	
	b2Vec2 bodyAnchor1;
	bodyAnchor1.x = def->bodyAnchor1.x;
	bodyAnchor1.y = def->bodyAnchor1.y;
	
	b2Vec2 bodyAnchor2;
	bodyAnchor2.x = def->bodyAnchor2.x;
	bodyAnchor2.y = def->bodyAnchor2.y;
	
	jointDef.localAnchorA = bodyAnchor1;
	jointDef.localAnchorB = bodyAnchor2;
	
	jointDef.maxLength = 1.0f;
	
	b2Joint* joint = m_pWorld->CreateJoint(&jointDef);
	
	FCHandle handle = FCHandleNew();
	
	m_joints[ handle ] = joint;
	return handle;
}

//FCHandle FCPhysics2D::CreateJoint( FCPhysics2DJointCreateDefRef def )
//{
//	FCHandle handle = NewFCHandle();
//		
//	FCPhysics2DRopeJointCreateDefRef ropePtr = std::dynamic_pointer_cast<FCPhysics2DRopeJointCreateDef>(def);
//	
//	if (ropePtr) {
//		
//		m_joints[handle] = joint;
//		return handle;
//	}
//	
//	FC_ASSERT(0);
//	
//	return kFCHandleInvalid;
//}

void FCPhysics2D::SetRevoluteJointMotor( FCHandle handle, bool enabled, float torque, float speed )
{
	b2RevoluteJoint* joint = (b2RevoluteJoint*)m_joints[ handle ];
	
	if (enabled) {
		joint->EnableMotor(true);
		joint->SetMotorSpeed(speed);
		joint->SetMaxMotorTorque(torque);
	} else {
		joint->EnableMotor(false);
	}
}

void FCPhysics2D::SetRevoluteJointLimits( FCHandle handle, bool enable, float min, float max )
{
	b2RevoluteJoint* joint = (b2RevoluteJoint*)m_joints[handle];
	
	if (enable) {
		joint->EnableLimit(true);
		joint->SetLimits(min, max);
	} else {
		joint->EnableLimit(false);
	}	
}

void FCPhysics2D::SetPrismaticJointMotor( FCHandle handle, bool enable, float force, float speed )
{
	b2PrismaticJoint* joint = (b2PrismaticJoint*)m_joints[handle];
	
	if (enable) {
		joint->EnableMotor(true);
		joint->SetMotorSpeed(speed);
		joint->SetMaxMotorForce(force);
	} else {
		joint->EnableMotor(false);
	}
}

void FCPhysics2D::SetPrismaticJointLimits( FCHandle handle, bool enable, float min, float max )
{
	b2PrismaticJoint* joint = (b2PrismaticJoint*)m_joints[handle];
	
	if (enable) {
		joint->EnableLimit(true);
		joint->SetLimits(min, max);
	} else {
		joint->EnableLimit(false);
	}	
}

FCPhysics2DContactListener* FCPhysics2D::ContactListener()
{
	return m_contactListener;
}


