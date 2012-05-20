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

#if 0

#import "FCPhysics_old.h"
#import "FCLua.h"
#import "FCFramework.h"

static FCPhysics_old* s_pPhysics = 0;

#pragma mark - Lua Interface

static int lua_Reset( lua_State* _state )
{
	FC_LUA_ASSERT_NUMPARAMS(0);
	[s_pPhysics reset];
	return 0;
}

static int lua_Create2DSystem( lua_State* _state )
{
	FC_LUA_ASSERT_NUMPARAMS(0);
	[s_pPhysics create2DSystem];
	return 0;
}

static int lua_SetMaterial( lua_State* _state )
{
	FC_LUA_ASSERT_NUMPARAMS(2);
	FC_LUA_ASSERT_TYPE(1, LUA_TSTRING);
	FC_LUA_ASSERT_TYPE(2, LUA_TTABLE);
	
	// get string and components
	
	FCPhysicsMaterialPtr material = FCPhysicsMaterialPtr( new FCPhysicsMaterial );
	
	material->name = lua_tostring(_state, 1);
	
	lua_getfield(_state, 2, "density");
	FC_LUA_ASSERT_TYPE(3, LUA_TNUMBER);
	material->density = (float)lua_tonumber(_state, 3);
	lua_pop(_state, 1);

	lua_getfield(_state, 2, "restitution");
	FC_LUA_ASSERT_TYPE(3, LUA_TNUMBER);
	material->restitution = (float)lua_tonumber(_state, 3);
	lua_pop(_state, 1);

	lua_getfield(_state, 2, "friction");
	FC_LUA_ASSERT_TYPE(3, LUA_TNUMBER);
	material->friction = (float)lua_tonumber(_state, 3);
	lua_pop(_state, 1);

	lua_settop(_state, 0);

	// set it
	
	[s_pPhysics setMaterial:material];
	
	return 0;
}

#pragma mark - ObjC

@implementation FCPhysics_old

@synthesize twoD = _twoD;

#pragma mark - FCSingleton protocol

+(FCPhysics_old*)instance
{
	if (!s_pPhysics) {
		s_pPhysics = [[FCPhysics_old alloc] init];
	}
	return s_pPhysics;
}

-(id)init
{
	self = [super init];
	if (self) 
	{
		// Register Lua functions
		
		FCLua::Instance()->CoreVM()->CreateGlobalTable("FCPhysics");
		
		FCLua::Instance()->CoreVM()->RegisterCFunction(lua_Create2DSystem, "FCPhysics.Create2DSystem");
		FCLua::Instance()->CoreVM()->RegisterCFunction(lua_Reset, "FCPhysics.Reset");
		FCLua::Instance()->CoreVM()->RegisterCFunction(lua_SetMaterial, "FCPhysics.SetMaterial");
	}
	return self;
}

-(void)dealloc
{
	FCLua::Instance()->CoreVM()->DestroyGlobalTable("FCPhysics");
	s_pPhysics = 0;
}

#pragma mark - FCGameObjectUpdate protocol

-(void)update:(float)realTime gameTime:(float)gameTime
{
	if (_twoD) {
		_twoD->Update(realTime, gameTime);
	}
}

#pragma mark - FCGameObjectLifetime protocol

-(void)reset
{
	if (_twoD != 0) {
		_twoD->PrepareForDealloc();
	}
	_twoD = 0;
	materials.clear();
}

-(void)destroy
{
	
}

#pragma mark - Misc

-(void)setMaterial:(FCPhysicsMaterialPtr)material
{
	materials[ material->name ] = material;
}

-(void)create2DSystem
{
	if (_twoD == 0) {
		_twoD = FCPhysics2DPtr( new FCPhysics2D );
		_twoD->Init();
	}
}

-(FCPhysicsMaterialMapByString&)getMaterials
{
	return materials;
}

@end

#endif // defined(FC_PHYSICS)

