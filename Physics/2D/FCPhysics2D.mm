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

#if defined (FC_PHYSICS)

#import "FCPhysics2D.h"
//#import "FCObjectManager.h"
#import "FCPhysics2DJoint.h"

#import "FCFramework.h"

static FCPhysics2D* s_pInstance = 0;

#if defined (FC_LUA)
#import "FCLua.h"

static int lua_CreateDistanceJoint( lua_State* _state )
{	
	FC_ASSERT(lua_gettop(_state) >= 4);
	FC_LUA_ASSERT_TYPE(1, LUA_TSTRING);
	
	FCPhysics2DDistanceJointCreateDef* def = [[FCPhysics2DDistanceJointCreateDef alloc] init];

	NSString* body1Name = [NSString stringWithUTF8String:lua_tostring(_state, 1)];
	def.body1 = [s_pInstance bodyWithName:body1Name];
	
	FC_ASSERT(def.body1);
	
	int obj2NameStackPos;
	
	if (lua_isnumber(_state, 2)) 
	{
		obj2NameStackPos = 4;
		
		FC::Vector2f pos = FC::Vector2f( lua_tonumber(_state, 2), lua_tonumber(_state, 3) );
		FC::Vector3f body1Pos = def.body1.position;
		pos += FC::Vector2f( body1Pos.x, body1Pos.y );
		def.pos1 = pos;
	} 
	else 
	{
		obj2NameStackPos = 3;
		NSDictionary* null = [[FCObjectManager instance].nulls valueForKey:[NSString stringWithUTF8String:lua_tostring(_state, 2)]];
		FC_ASSERT(null);
		def.pos1 = FC::Vector2f( [[null valueForKey:kFCKeyOffsetX] floatValue], [[null valueForKey:kFCKeyOffsetY] floatValue] );
	}
	
	FC_LUA_ASSERT_TYPE(obj2NameStackPos, LUA_TSTRING);
	
	NSString* body2Name = [NSString stringWithUTF8String:lua_tostring(_state, obj2NameStackPos)];
	def.body2 = [s_pInstance bodyWithName:body2Name];
	
	FC_ASSERT(def.body2);
	
	if (lua_isnumber(_state, obj2NameStackPos+1)) 
	{
		FC::Vector2f pos = FC::Vector2f( lua_tonumber(_state, obj2NameStackPos+1), lua_tonumber(_state, obj2NameStackPos+2) );
		FC::Vector3f body2Pos = def.body2.position;
		pos += FC::Vector2f( body2Pos.x, body2Pos.y );
		def.pos2 = pos;
	} 
	else 
	{
		NSDictionary* null = [[FCObjectManager instance].nulls valueForKey:[NSString stringWithUTF8String:lua_tostring(_state, obj2NameStackPos+1)]];
		FC_ASSERT(null);
		def.pos2 = FC::Vector2f( [[null valueForKey:kFCKeyOffsetX] floatValue], [[null valueForKey:kFCKeyOffsetY] floatValue] );
	}
	
	// call through to OBJ-C

	FCHandle hJoint = [s_pInstance createJoint:def];
	
	lua_pushinteger(_state, hJoint);
	
	return 1;
}

static int lua_CreateRevoluteJoint( lua_State* _state )
{
	FC_ASSERT(lua_gettop(_state) >= 3);
	FC_LUA_ASSERT_TYPE(1, LUA_TSTRING);
	FC_LUA_ASSERT_TYPE(2, LUA_TSTRING);
	
	FCPhysics2DRevoluteJointCreateDef* def = [[FCPhysics2DRevoluteJointCreateDef alloc] init];
	
	def.body1 = [s_pInstance bodyWithName:[NSString stringWithUTF8String:lua_tostring(_state, 1)]];
	FC_ASSERT(def.body1);
	def.body2 = [s_pInstance bodyWithName:[NSString stringWithUTF8String:lua_tostring(_state, 2)]];
	FC_ASSERT(def.body2);
	
	if (lua_isnumber(_state, 3)) {
		FC::Vector2f pos = FC::Vector2f( lua_tonumber(_state, 3), lua_tonumber(_state, 4) );
		FC::Vector3f body2Pos = def.body2.position;
		pos += FC::Vector2f( body2Pos.x, body2Pos.y );
		def.pos = pos;
	} else
	{
		NSDictionary* null = [[FCObjectManager instance].nulls valueForKey:[NSString stringWithUTF8String:lua_tostring(_state, 3)]];
		FC_ASSERT(null);
		def.pos = FC::Vector2f( [[null valueForKey:kFCKeyOffsetX] floatValue], [[null valueForKey:kFCKeyOffsetY] floatValue] );
	}

	FCHandle hJoint = [s_pInstance createJoint:def];
	
	lua_pushinteger(_state, hJoint);
	
	return 1;
}

static int lua_CreatePrismaticJoint( lua_State* _state )
{
	FC_LUA_ASSERT_NUMPARAMS(3);
	FC_LUA_ASSERT_TYPE(1, LUA_TSTRING);
	FC_LUA_ASSERT_TYPE(2, LUA_TSTRING);
	FC_LUA_ASSERT_TYPE(3, LUA_TSTRING);
	
	FCPhysics2DPrismaticJointCreateDef* def = [[FCPhysics2DPrismaticJointCreateDef alloc] init];
	
	def.body1 = [s_pInstance bodyWithName:[NSString stringWithUTF8String:lua_tostring(_state, 1)]];
	FC_ASSERT(def.body1);
	def.body2 = [s_pInstance bodyWithName:[NSString stringWithUTF8String:lua_tostring(_state, 2)]];
	FC_ASSERT(def.body2);
	
	NSDictionary* null = [[FCObjectManager instance].nulls valueForKey:[NSString stringWithUTF8String:lua_tostring(_state, 3)]];
	FC_ASSERT(null);
	
	float angle = [[null valueForKey:kFCKeyRotationZ] floatValue];
	angle = FCDegToRad(angle);
	FC::Vector2f axis( sin(angle), cos(angle) );
	def.axis = axis;
	
	FCHandle hJoint = [s_pInstance createJoint:def];
	
	lua_pushinteger(_state, hJoint);
	
	return 1;
}

static int lua_CreatePulleyJoint( lua_State* _state )
{
	FC_LUA_ASSERT_NUMPARAMS(7);
	FC_LUA_ASSERT_TYPE(1, LUA_TSTRING);
	FC_LUA_ASSERT_TYPE(2, LUA_TSTRING);
	FC_LUA_ASSERT_TYPE(3, LUA_TSTRING);
	FC_LUA_ASSERT_TYPE(4, LUA_TSTRING);
	FC_LUA_ASSERT_TYPE(5, LUA_TSTRING);
	FC_LUA_ASSERT_TYPE(6, LUA_TSTRING);
	FC_LUA_ASSERT_TYPE(7, LUA_TNUMBER);
	
	FCPhysics2DPulleyJointCreateDef* def = [[FCPhysics2DPulleyJointCreateDef alloc] init];
	
	def.body1 = [s_pInstance bodyWithName:[NSString stringWithUTF8String:lua_tostring(_state, 1)]];
	FC_ASSERT(def.body1);
	def.body2 = [s_pInstance bodyWithName:[NSString stringWithUTF8String:lua_tostring(_state, 2)]];
	FC_ASSERT(def.body2);

	NSDictionary* groundAnchor1 = [[FCObjectManager instance].nulls valueForKey:[NSString stringWithUTF8String:lua_tostring(_state, 3)]];
	FC_ASSERT(groundAnchor1);
	def.groundAnchor1 = FC::Vector2f( [[groundAnchor1 valueForKey:kFCKeyOffsetX] floatValue], [[groundAnchor1 valueForKey:kFCKeyOffsetY] floatValue] );

	NSDictionary* groundAnchor2 = [[FCObjectManager instance].nulls valueForKey:[NSString stringWithUTF8String:lua_tostring(_state, 4)]];
	FC_ASSERT(groundAnchor2);
	def.groundAnchor2 = FC::Vector2f( [[groundAnchor2 valueForKey:kFCKeyOffsetX] floatValue], [[groundAnchor2 valueForKey:kFCKeyOffsetY] floatValue] );

	NSDictionary* bodyAnchor1 = [[FCObjectManager instance].nulls valueForKey:[NSString stringWithUTF8String:lua_tostring(_state, 5)]];
	FC_ASSERT(bodyAnchor1);
	def.bodyAnchor1 = FC::Vector2f( [[bodyAnchor1 valueForKey:kFCKeyOffsetX] floatValue], [[bodyAnchor1 valueForKey:kFCKeyOffsetY] floatValue] );

	NSDictionary* bodyAnchor2 = [[FCObjectManager instance].nulls valueForKey:[NSString stringWithUTF8String:lua_tostring(_state, 6)]];
	FC_ASSERT(bodyAnchor2);
	def.bodyAnchor2 = FC::Vector2f( [[bodyAnchor2 valueForKey:kFCKeyOffsetX] floatValue], [[bodyAnchor2 valueForKey:kFCKeyOffsetY] floatValue] );

	def.ratio = lua_tonumber(_state, 7);
	
	FCHandle hJoint = [s_pInstance createJoint:def];
	
	lua_pushinteger(_state, hJoint);
	
	return 1;
}

static int lua_SetRevoluteJointLimits( lua_State* _state )
{
	FC_LUA_ASSERT_NUMPARAMS(3);
	FC_LUA_ASSERT_TYPE(1, LUA_TNUMBER);
	FC_LUA_ASSERT_TYPE(2, LUA_TNUMBER);
	FC_LUA_ASSERT_TYPE(3, LUA_TNUMBER);
	
	FCHandle hJoint = (FCHandle)lua_tointeger(_state, 1);
	float min = lua_tonumber(_state, 2);
	float max = lua_tonumber(_state, 3);
	
	if ( min != max ) {
		[s_pInstance setRevoluteJoint:hJoint limitsEnabled:YES min:min max:max];
	} else {
		[s_pInstance setRevoluteJoint:hJoint limitsEnabled:NO min:0 max:0];
	}

	return 0;
}

static int lua_SetRevoluteJointMotor( lua_State* _state )
{
	FC_LUA_ASSERT_NUMPARAMS(3);
	FC_LUA_ASSERT_TYPE(1, LUA_TNUMBER);
	FC_LUA_ASSERT_TYPE(2, LUA_TNUMBER);
	FC_LUA_ASSERT_TYPE(3, LUA_TNUMBER);
	
	FCHandle hJoint = (FCHandle)lua_tointeger(_state, 1);
	float speed = lua_tonumber(_state, 2);
	float torque = lua_tonumber(_state, 3);
	
	if ( (speed != 0.0f) && (torque != 0.0f) ) {
		[s_pInstance setRevoluteJoint:hJoint motorEnabled:YES torque:torque speed:speed];
	} else {
		[s_pInstance setRevoluteJoint:hJoint motorEnabled:NO torque:0 speed:0];		
	}
	
	return 0;
}

static int lua_SetPrismaticJointLimits( lua_State* _state )
{
	FC_LUA_ASSERT_NUMPARAMS(3);
	FC_LUA_ASSERT_TYPE(1, LUA_TNUMBER);
	FC_LUA_ASSERT_TYPE(2, LUA_TNUMBER);
	FC_LUA_ASSERT_TYPE(3, LUA_TNUMBER);
	
	FCHandle hJoint = (FCHandle)lua_tointeger(_state, 1);
	float min = lua_tonumber(_state, 2);
	float max = lua_tonumber(_state, 3);
	
	if ( min != max ) {
		[s_pInstance setPrismaticJoint:hJoint limitsEnabled:YES min:min max:max];
	} else {
		[s_pInstance setPrismaticJoint:hJoint limitsEnabled:NO min:0 max:0];
	}
	
	return 0;
}

static int lua_SetPrismaticJointMotor( lua_State* _state )
{
	FC_LUA_ASSERT_NUMPARAMS(3);
	FC_LUA_ASSERT_TYPE(1, LUA_TNUMBER);
	FC_LUA_ASSERT_TYPE(2, LUA_TNUMBER);
	FC_LUA_ASSERT_TYPE(3, LUA_TNUMBER);
	
	FCHandle hJoint = (FCHandle)lua_tointeger(_state, 1);
	float speed = lua_tonumber(_state, 2);
	float force = lua_tonumber(_state, 3);
	
	if ( (speed != 0.0f) && (force != 0.0f) ) {
		[s_pInstance setPrismaticJoint:hJoint motorEnabled:YES force:force speed:speed];
	} else {
		[s_pInstance setPrismaticJoint:hJoint motorEnabled:NO force:0 speed:0];		
	}
	
	return 0;
}

#endif

@implementation FCPhysics2D

@synthesize world = _world;
@synthesize gravity = _gravity;
@synthesize joints = _joints;
@synthesize bodies = _bodies;
@synthesize contactListener = _contactListener;

#pragma mark - Object Lifecycle

-(void)prepareForDealloc
{
	s_pInstance = nil;
}

-(id)init
{
	self = [super init];
	if (self) 
	{
		s_pInstance = self;
		_bodies = [NSMutableDictionary dictionary];
		_bodiesByName = [NSMutableDictionary dictionary];
		
#if defined (FC_LUA)
		[[FCLua instance].coreVM createGlobalTable:@"FCPhysics2D"];
		[[FCLua instance].coreVM registerCFunction:lua_CreateDistanceJoint as:@"FCPhysics2D.CreateDistanceJoint"];
		[[FCLua instance].coreVM registerCFunction:lua_CreateRevoluteJoint as:@"FCPhysics2D.CreateRevoluteJoint"];
		[[FCLua instance].coreVM registerCFunction:lua_CreatePrismaticJoint as:@"FCPhysics2D.CreatePrismaticJoint"];
		[[FCLua instance].coreVM registerCFunction:lua_CreatePulleyJoint as:@"FCPhysics2D.CreatePulleyJoint"];
		
		[[FCLua instance].coreVM registerCFunction:lua_SetRevoluteJointMotor as:@"FCPhysics2D.SetRevoluteJointMotor"];
		[[FCLua instance].coreVM registerCFunction:lua_SetRevoluteJointLimits as:@"FCPhysics2D.SetRevoluteJointLimits"];
		[[FCLua instance].coreVM registerCFunction:lua_SetPrismaticJointMotor as:@"FCPhysics2D.SetPrismaticJointMotor"];
		[[FCLua instance].coreVM registerCFunction:lua_SetPrismaticJointLimits as:@"FCPhysics2D.SetPrismaticJointLimits"];
#endif
		
		_joints = [NSMutableDictionary dictionary];
		
		_gravity = b2Vec2( 0.0f, -9.8f );
		
		if (!_world) 
		{
			_world = new b2World( _gravity );
		}
		
		_contactListener = new FCPhysics2DContactListener;
		
		_world->SetContactListener(_contactListener);
	}
	return self;
}

-(void)dealloc
{
	s_pInstance = nil;
	delete _contactListener;
	delete _world; 
	_world = 0;
}

#pragma mark - FCGameObjectUpdate protocol

-(void)update:(float)realTime gameTime:(float)gameTime
{
	_contactListener->Clear();
	if (gameTime > 0.0f) {
		_world->Step( gameTime, 8, 4 );
	}
	_contactListener->DispatchToSubscribers();
}

-(FCPhysics2DBody*)newBodyWithDef:(FCPhysics2DBodyDef*)def name:(NSString *)name
{
	def.world = _world;

	FCPhysics2DBody* newBody = [[FCPhysics2DBody alloc] initWithDef:def];

	FCHandle handle = NewFCHandle();
	newBody.handle = handle;

	if (name) 
	{
		newBody.name = [NSString stringWithFormat:@"%@_%@", name, newBody.Id];
		[_bodiesByName setValue:newBody forKey:newBody.name];
	}

	[_bodies setObject:newBody forKey:[NSNumber numberWithInt:handle]];
	
	return newBody;
}

-(void)destroyBody:(FCPhysics2DBody*)body
{
	[_bodies removeObjectForKey:[NSNumber numberWithInt:body.handle]];
	if (body.name) {
		[_bodiesByName removeObjectForKey:body.name];
	}
}

-(FCPhysics2DBody*)bodyWithName:(NSString*)name
{
	FC_ASSERT( [_bodiesByName valueForKey:name] );
	return [_bodiesByName valueForKey:name];
}

#pragma mark - Joints

-(FCHandle)createJoint:(FCPhysics2DJointCreateDef*)def
{
	FCHandle handle = NewFCHandle();
	if ([def isKindOfClass:[FCPhysics2DDistanceJointCreateDef class]]) 
	{
		FCPhysics2DDistanceJointCreateDef* thisDef = (FCPhysics2DDistanceJointCreateDef*)def;
		b2Vec2 pos1;
		pos1.x = thisDef.pos1.x;
		pos1.y = thisDef.pos1.y;

		b2Vec2 pos2;
		pos2.x = thisDef.pos2.x;
		pos2.y = thisDef.pos2.y;

		b2DistanceJointDef jointDef;
		jointDef.Initialize(thisDef.body1.body, thisDef.body2.body, pos1, pos2);
		jointDef.collideConnected = true;
		b2Joint* joint = _world->CreateJoint(&jointDef);
		
		[_joints setObject:[NSNumber numberWithInt:(int)joint] forKey:[NSNumber numberWithInt:handle]];
	} 
	else if( [def isKindOfClass:[FCPhysics2DRevoluteJointCreateDef class]] )
	{
		FCPhysics2DRevoluteJointCreateDef* thisDef = (FCPhysics2DRevoluteJointCreateDef*)def;

		b2Vec2 pos;
		pos.x = thisDef.pos.x;
		pos.y = thisDef.pos.y;
		
		b2RevoluteJointDef jointDef;
		jointDef.Initialize(thisDef.body1.body, thisDef.body2.body, pos);
		jointDef.enableMotor = false;
		jointDef.enableLimit = false;
		b2Joint* joint = _world->CreateJoint(&jointDef);
		
		[_joints setObject:[NSNumber numberWithInt:(int)joint] forKey:[NSNumber numberWithInt:handle]];
	}
	else if( [def isKindOfClass:[FCPhysics2DPrismaticJointCreateDef class]] )
	{
		FCPhysics2DPrismaticJointCreateDef* thisDef = (FCPhysics2DPrismaticJointCreateDef*)def;
		
		b2Vec2 axis;
		axis.x = thisDef.axis.x;
		axis.y = thisDef.axis.y;

		b2Vec2 pos;
		pos.x = thisDef.body2.position.x;
		pos.y = thisDef.body2.position.y;

		b2PrismaticJointDef jointDef;
		jointDef.Initialize(thisDef.body1.body, thisDef.body2.body, pos, axis);

		b2Joint* joint = _world->CreateJoint(&jointDef);

		[_joints setObject:[NSNumber numberWithInt:(int)joint] forKey:[NSNumber numberWithInt:handle]];
	}
	else if( [def isKindOfClass:[FCPhysics2DPulleyJointCreateDef class]] )
	{
		FCPhysics2DPulleyJointCreateDef* thisDef = (FCPhysics2DPulleyJointCreateDef*)def;

		b2PulleyJointDef jointDef;
		b2Vec2 groundAnchor1;
		groundAnchor1.x = thisDef.groundAnchor1.x;
		groundAnchor1.y = thisDef.groundAnchor1.y;

		b2Vec2 groundAnchor2;
		groundAnchor2.x = thisDef.groundAnchor2.x;
		groundAnchor2.y = thisDef.groundAnchor2.y;

		b2Vec2 bodyAnchor1;
		bodyAnchor1.x = thisDef.bodyAnchor1.x;
		bodyAnchor1.y = thisDef.bodyAnchor1.y;

		b2Vec2 bodyAnchor2;
		bodyAnchor2.x = thisDef.bodyAnchor2.x;
		bodyAnchor2.y = thisDef.bodyAnchor2.y;

		jointDef.Initialize( thisDef.body1.body, thisDef.body2.body, groundAnchor1, groundAnchor2, 
							bodyAnchor1, bodyAnchor2, thisDef.ratio );
		
		b2Joint* joint = _world->CreateJoint(&jointDef);
		
		[_joints setObject:[NSNumber numberWithInt:(int)joint] forKey:[NSNumber numberWithInt:handle]];
	}
	else
	{
		FC_ASSERT(0);
	}
	return handle;
}

-(void)setRevoluteJoint:(FCHandle)handle motorEnabled:(BOOL)enabled torque:(float)torque speed:(float)speed
{
	NSNumber* number = [_joints objectForKey:[NSNumber numberWithInt:handle]];
	b2RevoluteJoint* joint = (b2RevoluteJoint*)[number intValue];
	
	if (enabled) {
		joint->EnableMotor(true);
		joint->SetMotorSpeed(speed);
		joint->SetMaxMotorTorque(torque);
	} else {
		joint->EnableMotor(false);
	}
}

-(void)setRevoluteJoint:(FCHandle)handle limitsEnabled:(BOOL)enabled min:(float)min max:(float)max
{
	NSNumber* number = [_joints objectForKey:[NSNumber numberWithInt:handle]];
	b2RevoluteJoint* joint = (b2RevoluteJoint*)[number intValue];
	
	if (enabled) {
		joint->EnableLimit(true);
		joint->SetLimits(min, max);
	} else {
		joint->EnableLimit(false);
	}	
}

-(void)setPrismaticJoint:(FCHandle)handle motorEnabled:(BOOL)enabled force:(float)force speed:(float)speed
{
	NSNumber* number = [_joints objectForKey:[NSNumber numberWithInt:handle]];
	b2PrismaticJoint* joint = (b2PrismaticJoint*)[number intValue];
	
	if (enabled) {
		joint->EnableMotor(true);
		joint->SetMotorSpeed(speed);
		joint->SetMaxMotorForce(force);
	} else {
		joint->EnableMotor(false);
	}
}

-(void)setPrismaticJoint:(FCHandle)handle limitsEnabled:(BOOL)enabled min:(float)min max:(float)max
{
	NSNumber* number = [_joints objectForKey:[NSNumber numberWithInt:handle]];
	b2PrismaticJoint* joint = (b2PrismaticJoint*)[number intValue];
	
	if (enabled) {
		joint->EnableLimit(true);
		joint->SetLimits(min, max);
	} else {
		joint->EnableLimit(false);
	}	
}

@end

#endif // defined(FC_PHYSICS)
