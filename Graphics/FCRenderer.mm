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

#if defined(FC_GRAPHICS)

#import "FCCore.h"
#import "FCRenderer.h"
#import "FCAppContext.h"
#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>
#import "FCModel.h"
#import "FCProtocols.h"
#import "FCShaderManager.h"
#import "FCTextureManager.h"
#import "FCLua.h"
#import "FCActorSystem.h"

static NSMutableDictionary* s_renderers;
static FCRenderer* s_currentLuaTarget;

// set current renderer

static int lua_SetCurrentRenderer( lua_State* _state )
{
	FC_LUA_ASSERT_NUMPARAMS(1);
	FC_LUA_ASSERT_TYPE(1, LUA_TSTRING);

	FCRenderer* rend = [s_renderers valueForKey:[NSString stringWithUTF8String:lua_tostring(_state, 1)]];
	FC_ASSERT(rend);
	s_currentLuaTarget = rend;
	return 0;
}

// add actor to gather (actor name)

//static int lua_AddActorToGather( lua_State* _state )
//{
//	FC_ASSERT(lua_gettop(_state) == 1);
//	FC_ASSERT(lua_isstring(_state, 1));
//	
//	NSString* name = [NSString stringWithUTF8String:lua_tostring(_state, 1)];
//
//	FCActor* actor = [[FCActorSystem instance].actorNameDictionary valueForKey:name];
//
//	[s_currentLuaTarget addToGatherList:actor];
//	
//	return 0;
//}
//
//// remove actor from gather
//
//static int lua_RemoveActorFromGather( lua_State* _state )
//{
//	FC_ASSERT(lua_gettop(_state) == 1);
//	FC_ASSERT(lua_isstring(_state, 1));
//
//	NSString* name = [NSString stringWithUTF8String:lua_tostring(_state, 1)];
//	
//	FCActor* actor = [[FCActorSystem instance].actorNameDictionary valueForKey:name];
//
//	FC_ASSERT( actor );
//	
//	[s_currentLuaTarget removeFromGatherList:actor];
//	
//	return 0;
//}

@implementation FCRenderer

@synthesize name = _name;
@synthesize models = _models;
@synthesize gatherList = _gatherList;

#pragma mark - FCSingleton protocol

-(id)initWithName:(NSString*)name
{
	self = [super init];
	if (self) {
		_name = name;
		_models = [[NSMutableArray alloc] init];
		_gatherList = [[NSMutableArray alloc] init];
		
		if (!s_renderers) // one off init
		{
			s_renderers = [[NSMutableDictionary alloc] init];
			[[FCLua instance].coreVM createGlobalTable:@"FCRenderer"];
			[[FCLua instance].coreVM registerCFunction:lua_SetCurrentRenderer as:@"FCRenderer.SetCurrentRenderer"];
//			[[FCLua instance].coreVM registerCFunction:lua_AddActorToGather as:@"FCRenderer.AddActorToGather"];
//			[[FCLua instance].coreVM registerCFunction:lua_RemoveActorFromGather as:@"FCRenderer.RemoveActorFromGather"];
		}
		
		[s_renderers setValue:self forKey:name];
	}
	return self;
}

-(void)dealloc
{
	[s_renderers removeObjectForKey:_name];
}

-(void)addToGatherList:(id)obj
{
	FC_ASSERT([obj conformsToProtocol:@protocol(FCGameObjectRender)]);
	[_gatherList addObject:obj];
}

-(void)removeFromGatherList:(id)obj
{
	FC_ASSERT([obj conformsToProtocol:@protocol(FCGameObjectRender)]);
	[_gatherList removeObject:obj];
}

-(void)render
{
	// go through gather list and aggregate the arrays
	
	[_models removeAllObjects];
	
	// gather from objects on the gather list
	
	for( id<FCGameObjectRender> obj in _gatherList )
	{
		[_models addObjectsFromArray:[obj renderGather]];
	}

	// sorting here ?

	// render the models in sorted order
	
	for( FCModel* model in _models )
	{
		[model render];
	}

	[_models removeAllObjects];
}

@end

#endif // defined(FC_GRAPHICS)
