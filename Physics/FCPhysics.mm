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
#import "FCFramework.h"

static FCPhysics* s_pPhysics = 0;

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
	
	FCPhysicsMaterial* material = [[FCPhysicsMaterial alloc] init];
	
	material.name = [NSString stringWithUTF8String:lua_tostring(_state, 1)];
	
	lua_getfield(_state, 2, "density");
	FC_LUA_ASSERT_TYPE(3, LUA_TNUMBER);
	material.density = (float)lua_tonumber(_state, 3);
	lua_pop(_state, 1);

	lua_getfield(_state, 2, "restitution");
	FC_LUA_ASSERT_TYPE(3, LUA_TNUMBER);
	material.restitution = (float)lua_tonumber(_state, 3);
	lua_pop(_state, 1);

	lua_getfield(_state, 2, "friction");
	FC_LUA_ASSERT_TYPE(3, LUA_TNUMBER);
	material.friction = (float)lua_tonumber(_state, 3);
	lua_pop(_state, 1);

	lua_settop(_state, 0);

	// set it
	
	[s_pPhysics setMaterial:material];
	
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
		
//		[[FCLua instance].coreVM createGlobalTable:@"FCPhysics"];		
		FCLua::Instance()->CoreVM()->CreateGlobalTable("FCPhysics");
		
//		[[FCLua instance].coreVM registerCFunction:lua_Create2DSystem	as:@"FCPhysics.Create2DSystem"];
		FCLua::Instance()->CoreVM()->RegisterCFunction(lua_Create2DSystem, "FCPhysics.Create2DSystem");
//		[[FCLua instance].coreVM registerCFunction:lua_Reset			as:@"FCPhysics.Reset"];
		FCLua::Instance()->CoreVM()->RegisterCFunction(lua_Reset, "FCPhysics.Reset");
//		[[FCLua instance].coreVM registerCFunction:lua_SetMaterial		as:@"FCPhysics.SetMaterial"];
		FCLua::Instance()->CoreVM()->RegisterCFunction(lua_SetMaterial, "FCPhysics.SetMaterial");

		_materials = [[NSMutableDictionary alloc] init];
	}
	return self;
}

-(void)dealloc
{
//	[[FCLua instance].coreVM destroyGlobalTable:@"FCPhysics"];
	FCLua::Instance()->CoreVM()->DestroyGlobalTable("FCPhysics");
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
	[_twoD prepareForDealloc];
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
	if (_twoD == nil) {
		_twoD = [[FCPhysics2D alloc] init];	
	}
}

//-(void)destroy2DSystem
//{
////	[_twoD prepareForDealloc];
//	_twoD = nil;
//}

-(NSString*)description
{
	return [NSString stringWithFormat:@"%@", _materials];
}

@end

#endif // defined(FC_PHYSICS)

