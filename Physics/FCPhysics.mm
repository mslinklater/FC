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

#if TARGET_OS_IPHONE

#import "FCPhysics.h"
#import "FCLua.h"

static FCPhysics* s_pPhysics = 0;

#pragma mark - Lua Interface

static int lua_AddMaterial( lua_State* _state )
{
	// FCPhysics.AddMaterial( "normal", { friction = 0.5, resitiution = 0.6, density = 1} )
	
	FC_ASSERT(lua_gettop(_state) == 2);
	FC_ASSERT(lua_isstring(_state, 1));
	FC_ASSERT(lua_istable(_state, 2));
	
	// get string
	
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
	return 0;
}

#pragma mark - ObjC

@implementation FCPhysics

@synthesize twoD = _twoD;
//@synthesize threeD = _threeD;
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
		[[FCLua instance].coreVM registerCFunction:lua_AddMaterial as:@"FCPhysics.AddMaterial"];
		
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
	
}

#pragma mark - FCGameObjectLifetime protocol

-(void)reset
{
	_twoD = nil;
	_materials = nil;
}

-(void)destroy
{
	
}

#pragma mark - Misc

-(void)addMaterial:(FCPhysicsMaterial *)material
{
	FC_ASSERT([_materials valueForKey:material.name] == nil);
}

-(void)create2DComponent
{
	_twoD = [[FCPhysics2D alloc] init];	
}

-(void)create3DComponent
{
	
}
@end

#endif // TARGET_OS_IPHONE
