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

#import "FCPhysics.h"
#import "FCLua.h"
#import "FCObjectManager.h"
#import "FCActorSystem.h"

static FCPhysics* s_pPhysics = 0;

#pragma mark - Lua Interface

static int lua_Reset( lua_State* _state )
{
	[s_pPhysics reset];
	return 0;
}

static int lua_Create2DSystem( lua_State* _state )
{
	[s_pPhysics create2DSystem];
	return 0;
}

static int lua_SetMaterial( lua_State* _state )
{
	// FCPhysics.AddMaterial( "normal", { friction = 0.5, resitiution = 0.6, density = 1} )
	
	FC_ASSERT(lua_gettop(_state) == 2);
	FC_ASSERT(lua_isstring(_state, 1));
	FC_ASSERT(lua_istable(_state, 2));
	
	// get string and components
	
	FCPhysicsMaterial* material = [[FCPhysicsMaterial alloc] init];
	
	material.name = [NSString stringWithUTF8String:lua_tostring(_state, 1)];
	
	lua_getfield(_state, 2, "density");
	if (lua_isnumber(_state, 3)) {
		material.density = (float)lua_tonumber(_state, 3);
	}
	lua_pop(_state, 1);

	lua_getfield(_state, 2, "restitution");
	if (lua_isnumber(_state, 3)) {
		material.restitution = (float)lua_tonumber(_state, 3);
	}
	lua_pop(_state, 1);

	lua_getfield(_state, 2, "friction");
	if (lua_isnumber(_state, 3)) {
		material.friction = (float)lua_tonumber(_state, 3);
	}
	lua_pop(_state, 1);

	lua_settop(_state, 0);

	// set it
	
	[s_pPhysics setMaterial:material];
	
	return 0;
}

static int lua_2DAddDistanceJoint( lua_State* _state )
{
	
	FCLua_DumpStack(_state);
	
	FC_ASSERT(lua_gettop(_state) >= 4);
	FC_ASSERT(lua_isstring(_state, 1));
	
	NSString* obj1Name = [NSString stringWithUTF8String:lua_tostring(_state, 1)];
	NSString* obj2Name;
	FC::Vector2f obj1Pos;
	FC::Vector2f obj2Pos;
	
	int obj2NameStackPos;

	FCLua_DumpStack(_state);

	if (lua_isnumber(_state, 2)) 
	{
		obj2NameStackPos = 4;
		obj1Pos.x = lua_tonumber(_state, 2);
		obj1Pos.y = lua_tonumber(_state, 3);
		FCActor* actor = [[FCActorSystem instance] actorWithId:obj1Name];
		obj1Pos += actor.position;
	} 
	else 
	{
		obj2NameStackPos = 3;
		NSDictionary* null = [[FCObjectManager instance].nulls valueForKey:[NSString stringWithUTF8String:lua_tostring(_state, 2)]];
		obj1Pos.x = [[null valueForKey:kFCKeyOffsetX] floatValue];
		obj1Pos.y = [[null valueForKey:kFCKeyOffsetY] floatValue];
	}

	FC_ASSERT(lua_isstring(_state, obj2NameStackPos));
	obj2Name = [NSString stringWithUTF8String:lua_tostring(_state, obj2NameStackPos)];

	if (lua_isnumber(_state, obj2NameStackPos+1)) 
	{
		obj2Pos.x = lua_tonumber(_state, obj2NameStackPos+1);
		obj2Pos.y = lua_tonumber(_state, obj2NameStackPos+2);
		// add actor 2 position
		FCActor* actor = [[FCActorSystem instance] actorWithId:obj2Name];
		obj2Pos += actor.position;
	} 
	else 
	{
		NSDictionary* null = [[FCObjectManager instance].nulls valueForKey:[NSString stringWithUTF8String:lua_tostring(_state, obj2NameStackPos+1)]];
		obj2Pos.x = [[null valueForKey:kFCKeyOffsetX] floatValue];
		obj2Pos.y = [[null valueForKey:kFCKeyOffsetY] floatValue];
	}
	
	// call through to OBJ-C

	
	
	return 0;
}

#pragma mark - ObjC

@implementation FCPhysics

@synthesize twoD = _twoD;
@synthesize materials = _materials;

#pragma mark - FCSingleton protocol

+(FCPhysics*)instance
{
	if (!s_pPhysics) {
		s_pPhysics = [[FCPhysics alloc] init];
	}
	return s_pPhysics;
}

-(id)init
{
	self = [super init];
	if (self) 
	{
		// Register Lua functions
		
		[[FCLua instance].coreVM createGlobalTable:@"FCPhysics"];		
//		[[FCLua instance].coreVM createGlobalTable:@"FCPhysics.TwoD"];		
		
		[[FCLua instance].coreVM registerCFunction:lua_Create2DSystem	as:@"FCPhysics.Create2DSystem"];
		[[FCLua instance].coreVM registerCFunction:lua_Reset			as:@"FCPhysics.Reset"];
		[[FCLua instance].coreVM registerCFunction:lua_SetMaterial		as:@"FCPhysics.SetMaterial"];

		// 2D
//		[[FCLua instance].coreVM registerCFunction:lua_2DAddDistanceJoint as:@"FCPhysics.TwoD.AddDistanceJoint"];

		_materials = [[NSMutableDictionary alloc] init];
	}
	return self;
}

-(void)dealloc
{
	[[FCLua instance].coreVM destroyGlobalTable:@"FCPhysics"];
	s_pPhysics = 0;
}

#pragma mark - FCGameObjectUpdate protocol

-(void)update:(float)realTime gameTime:(float)gameTime
{
	if (_twoD) {
		[_twoD update:realTime gameTime:gameTime];
	}
}

#pragma mark - FCGameObjectLifetime protocol

-(void)reset
{
	_twoD = nil;
	_materials = [[NSMutableDictionary alloc] init];
}

-(void)destroy
{
	
}

#pragma mark - Misc

-(void)setMaterial:(FCPhysicsMaterial *)material
{
	[_materials setValue:material forKey:material.name];
}

-(void)create2DSystem
{
	_twoD = [[FCPhysics2D alloc] init];	
}

-(NSString*)description
{
	return [NSString stringWithFormat:@"%@", _materials];
}

@end

#endif // defined(FC_PHYSICS)

